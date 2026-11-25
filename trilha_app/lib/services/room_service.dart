import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/l10n_global.dart';
import '../models/room_plan.dart';
import '../models/room_week.dart';
import '../models/study_room.dart';
import '../utils/reading_growth.dart';
import 'backend_service.dart';
import 'league_service.dart';
import 'moderation_service.dart';
import 'analytics_service.dart';
import 'notification_service.dart';
import 'progress_service.dart';

/// Orquestra salas privadas: código local + sync Firebase via [BackendService].
class RoomService extends ChangeNotifier {
  static const _keyActiveCode = 'activeRoomCode';

  final BackendService backend;

  StudyRoom? activeRoom;
  List<RoomMember> members = const [];

  /// Último grupo meu que encontrei encerrado (aviso + "Reabrir" do líder).
  /// Some ao dispensar ou ao entrar noutro grupo.
  StudyRoom? closedRoom;

  /// Progresso visto por último — para limpar o código do grupo também na
  /// nuvem quando quem chama não passa o progresso (abertura do app).
  ProgressService? _progress;

  /// Membros já chamados hoje (um chamado por pessoa por dia).
  Set<String> nudgedToday = const {};

  /// Convites em que eu participo (enviados ou recebidos).
  List<RoomInvite> invites = const [];
  bool loading = false;
  String? lastError;

  /// A sala salva não abriu por falha de rede (o código continua guardado).
  bool loadFailed = false;

  /// Líder do piloto (`users/{uid}.groupsPilot`): cria grupo mesmo com
  /// `groups_enabled` desligado. Os grupos dele nascem `pilot`.
  bool pilotLeader = false;

  /// Último fechamento da semana do grupo ativo (a revelação).
  RoomClosing? latestClosing;

  /// Fechamentos já vistos neste aparelho ("CÓDIGO@semana").
  Set<String> _seenClosings = const {};
  static const _keySeenClosings = 'roomClosingsSeen';
  bool _loaded = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _inviteSub;
  String? _listeningUid;

  RoomService(this.backend) {
    ModerationService.instance.addListener(notifyListeners);
  }

  bool get isLoaded => _loaded;
  String? get activeCode => activeRoom?.code;
  bool get hasRoom => activeRoom != null;
  bool get isFull => members.length >= kRoomMemberLimit;

  /// Convites que chegaram para mim e ainda estão abertos.
  List<RoomInvite> get incoming {
    final uid = backend.uid;
    if (uid == null) return const [];
    return [
      for (final invite in invites)
        if (invite.toUid == uid &&
            invite.isPending &&
            !ModerationService.instance.isBlocked(invite.fromUid))
          invite,
    ];
  }

  /// Pessoas que eu chamei para o grupo atual e ainda não responderam.
  Set<String> get pendingTargets {
    final code = activeRoom?.code;
    final uid = backend.uid;
    if (code == null || uid == null) return const {};
    return {
      for (final invite in invites)
        if (invite.roomCode == code &&
            invite.fromUid == uid &&
            invite.isPending)
          invite.toUid,
    };
  }

  /// O grupo existe de verdade ([kRoomMinMembers]+ pessoas)? Abaixo disso
  /// está se formando: estudo, leitura e propósito ficam esperando.
  bool get isFormed => roomIsFormed(members.length);

  /// Pessoas que faltam para o grupo começar (0 = já começou).
  int get missingToForm => isFormed ? 0 : kRoomMinMembers - members.length;

  /// Estudo marcado para a semana corrente (ou `null`).
  RoomStudy? get currentStudy =>
      isFormed ? activeRoom?.studyFor(LeagueService.weekKey()) : null;

  /// Leitura da Bíblia marcada para a semana corrente (ou `null`).
  RoomReading? get currentReading =>
      isFormed ? activeRoom?.readingFor(LeagueService.weekKey()) : null;

  /// Grupos abertos para esta pessoa: a chave geral, ou o piloto (líder do
  /// piloto ou membro de um grupo do piloto).
  bool groupsOpen(bool groupsFlag) =>
      groupsFlag ||
      pilotLeader ||
      (activeRoom?.pilot ?? false) ||
      incoming.any((i) => i.pilot);

  /// Criar grupo: a chave geral ou líder do piloto.
  bool canCreate(bool groupsFlag) => groupsFlag || pilotLeader;

  /// Participação da semana (lista do líder e fechamento).
  RoomWeek get week => RoomWeek.of(
    members: members,
    study: currentStudy,
    reading: currentReading,
    week: LeagueService.weekKey(),
  );

  // ───────────── Propósito do grupo ─────────────

  /// Propósito do grupo (próximo, em curso ou terminado e não trocado).
  /// Grupo ainda se formando: nenhum.
  RoomPlan? get plan => isFormed ? activeRoom?.plan : null;

  /// Contas do grupo no propósito (null sem propósito).
  PlanGroup? get planGroup {
    final p = plan;
    return p == null ? null : PlanGroup(p, members);
  }

  /// Meu progresso no propósito atual (vazio se ainda não comecei).
  PlanProgress? get myPlan {
    final p = plan;
    if (p == null) return null;
    final mine = members.where((m) => m.isUser).firstOrNull?.plan;
    return p.progressOf(mine) ?? PlanProgress(planId: p.id);
  }

  /// Respostas carregadas por dia ("planId_n").
  final Map<String, List<PlanAnswer>> _answers = {};
  final Set<String> _answersLoading = {};

  List<PlanAnswer>? answersFor(int day) {
    final p = plan;
    if (p == null) return null;
    final list = _answers[PlanAnswer.dayKey(p.id, day)];
    if (list == null) return null;
    return [
      for (final a in list)
        if (!ModerationService.instance.isBlocked(a.uid)) a,
    ];
  }

  bool answersLoading(int day) {
    final p = plan;
    return p != null && _answersLoading.contains(PlanAnswer.dayKey(p.id, day));
  }

  Future<void> loadAnswers(int day, {bool force = false}) async {
    final room = activeRoom;
    final p = plan;
    if (room == null || p == null || !backend.isActive) return;
    final key = PlanAnswer.dayKey(p.id, day);
    if (_answersLoading.contains(key)) return;
    if (!force && _answers.containsKey(key)) return;
    _answersLoading.add(key);
    notifyListeners();
    // Respostas fechadas pelo líder: o membro lê só a própria.
    final me = backend.uid;
    final List<PlanAnswer> list;
    if (room.answersPrivate && !room.isOwner(me)) {
      final mine = me == null
          ? const <int, String>{}
          : await backend.fetchMemberPlanAnswers(room.code, p.id, me, [day]);
      list = [
        if (mine[day] != null) PlanAnswer(uid: me!, name: '', text: mine[day]!),
      ];
    } else {
      list = await backend.fetchRoomPlanAnswers(room.code, p.id, day);
    }
    _answersLoading.remove(key);
    _answers[key] = list;
    notifyListeners();
  }

  /// O que já foi feito de cada coisa do dia.
  static ({bool reading, bool scene, bool question}) dayItems(
    RoomPlan plan,
    PlanDay day,
    PlanProgress mine,
    ProgressService progress,
  ) {
    final r = day.reading;
    return (
      reading:
          r == null ||
          progress.chaptersReadSince(r.bookAbbrev, r.from, r.to, plan.start) >=
              r.chapters,
      scene:
          day.scene == null ||
          // Feita no período do propósito (refazer vale), não antes.
          progress.sceneDoneSince(day.scene!.slug, plan.start),
      question: !day.hasQuestion || mine.answered.contains(day.n),
    );
  }

  static bool dayComplete(
    RoomPlan plan,
    PlanDay day,
    PlanProgress mine,
    ProgressService progress,
  ) {
    if (day.isManual) return mine.done.containsKey(day.n);
    final items = dayItems(plan, day, mine, progress);
    return items.reading && items.scene && items.question;
  }

  /// Grava no meu membro os dias que fechei (capítulos lidos, cena feita,
  /// pergunta respondida). Dia feito depois da data conta como recuperado.
  Future<void> syncPlan(ProgressService progress) async {
    final room = activeRoom;
    final p = plan;
    final mine = myPlan;
    if (room == null || p == null || mine == null || !backend.isActive) {
      await _syncPlanReminders(progress);
      return;
    }
    final today = planYmd(DateTime.now());
    final done = {...mine.done};
    var changed = false;
    for (final d in p.openDays()) {
      if (done.containsKey(d.n) || d.isManual) continue;
      if (dayComplete(p, d, mine, progress)) {
        done[d.n] = today;
        changed = true;
        unawaited(
          AnalyticsService.instance.logEvent('group_plan_day_done', {
            'day': d.n,
            'late': d.date.compareTo(today) < 0 ? 1 : 0,
          }),
        );
      }
    }
    if (changed) await _writePlan(room.code, mine.copyWith(done: done));
    await _syncPlanReminders(progress);
  }

  Future<void> _syncPlanReminders(ProgressService progress) async {
    final p = plan;
    final mine = myPlan;
    final live = p != null && p.phase() != PlanPhase.ended;
    await NotificationService.instance.syncGroupPlan(
      plan: live ? p : null,
      done: mine?.done.keys.toSet() ?? const {},
      enabled:
          progress.notificationsPrompted && progress.settings.notifications,
    );
  }

  Future<bool> _writePlan(String code, PlanProgress next) async {
    final ok = await backend.setRoomPlanProgress(code, next);
    if (!ok) return false;
    final uid = backend.uid;
    members = [
      for (final m in members)
        if (m.uid == uid) _withPlan(m, next) else m,
    ];
    notifyListeners();
    return true;
  }

  static RoomMember _withPlan(RoomMember m, PlanProgress plan) => RoomMember(
    uid: m.uid,
    name: m.name,
    steps: m.steps,
    isUser: m.isUser,
    lastWalk: m.lastWalk,
    photoUrl: m.photoUrl,
    portraitStyle: m.portraitStyle,
    studyDone: m.studyDone,
    weekDays: m.weekDays,
    readingDone: m.readingDone,
    readingWeek: m.readingWeek,
    sealWeeks: m.sealWeeks,
    growthPts: m.growthPts,
    growthWeek: m.growthWeek,
    plan: plan,
  );

  /// "Estou dentro": a pessoa assume o propósito antes de começar.
  Future<bool> joinPlan() async {
    final room = activeRoom;
    final mine = myPlan;
    if (room == null || mine == null) return false;
    if (mine.joined) return true;
    final ok = await _writePlan(room.code, mine.copyWith(joined: true));
    if (ok) {
      unawaited(AnalyticsService.instance.logEvent('group_plan_join'));
    }
    return ok;
  }

  /// Dia sem capítulo, cena nem pergunta: a pessoa marca à mão.
  Future<bool> markManualDay(PlanDay day, ProgressService progress) async {
    final room = activeRoom;
    final mine = myPlan;
    if (room == null || mine == null || !day.isManual) return false;
    final ok = await _writePlan(
      room.code,
      mine.copyWith(
        joined: true,
        done: {...mine.done, day.n: planYmd(DateTime.now())},
      ),
    );
    if (ok) await _syncPlanReminders(progress);
    return ok;
  }

  /// Responde a pergunta do dia. Depois as respostas do grupo aparecem.
  Future<bool> answerDay(
    PlanDay day,
    String text,
    ProgressService progress,
  ) async {
    final room = activeRoom;
    final p = plan;
    final mine = myPlan;
    if (room == null || p == null || mine == null) return false;
    final ok = await backend.saveRoomPlanAnswer(
      code: room.code,
      planId: p.id,
      day: day.n,
      name: progress.publicUserName,
      text: text,
    );
    if (!ok) return false;
    unawaited(
      AnalyticsService.instance.logEvent('group_plan_answer', {'day': day.n}),
    );
    await _writePlan(
      room.code,
      mine.copyWith(joined: true, answered: {...mine.answered, day.n}),
    );
    await syncPlan(progress);
    await loadAnswers(day.n, force: true);
    return true;
  }

  /// Apaga uma resposta (a minha, ou qualquer uma se sou o líder).
  Future<bool> deleteAnswer(int day, PlanAnswer answer) async {
    final room = activeRoom;
    final p = plan;
    if (room == null || p == null) return false;
    final ok = await backend.deleteRoomPlanAnswer(
      code: room.code,
      planId: p.id,
      day: day,
      uid: answer.uid,
    );
    if (!ok) return false;
    final key = PlanAnswer.dayKey(p.id, day);
    _answers[key] = [
      for (final a in _answers[key] ?? const <PlanAnswer>[])
        if (a.uid != answer.uid) a,
    ];
    notifyListeners();
    return true;
  }

  /// Líder grava (ou tira, com `null`) o propósito do grupo.
  Future<bool> setPlan(RoomPlan? next) async {
    // Grupo se formando não começa propósito (nem troca o que ficou gravado).
    if (next != null && !isFormed) return false;
    final previous = plan;
    final ok = await _updateRoom(
      {'plan': next?.toMap()},
      (r) =>
          next == null ? r.copyWith(clearPlan: true) : r.copyWith(plan: next),
    );
    if (ok && next != null && previous?.id != next.id) {
      // Quem cria o propósito já está dentro: não faz sentido o líder
      // confirmar o que ele mesmo marcou.
      unawaited(joinPlan());
      unawaited(
        AnalyticsService.instance.logEvent('group_plan_created', {
          'days': next.total,
          'reading': next.days.any((d) => d.reading != null) ? 1 : 0,
          'scene': next.days.any((d) => d.scene != null) ? 1 : 0,
          'question': next.days.any((d) => d.hasQuestion) ? 1 : 0,
        }),
      );
    }
    return ok;
  }

  /// Líder fecha o propósito: grava o fechamento (revelação) com id = fim.
  Future<RoomClosing?> closePlan() async {
    final room = activeRoom;
    final group = planGroup;
    if (room == null || group == null || !room.isOwner(backend.uid)) {
      return null;
    }
    final closing = group.close();
    final ok = await backend.saveRoomClosing(room.code, closing);
    if (!ok) return null;
    latestClosing = closing;
    notifyListeners();
    return closing;
  }

  /// O propósito atual já foi fechado (há revelação dele).
  bool get planClosed {
    final p = plan;
    final c = latestClosing;
    return p != null && c != null && c.isPlan && c.week == p.end;
  }

  /// Fechamento que esta pessoa ainda não viu (só o da semana corrente ou
  /// da anterior — revelação velha não volta).
  RoomClosing? get unseenClosing {
    final c = latestClosing;
    final code = activeRoom?.code;
    if (c == null || code == null) return null;
    if (_seenClosings.contains('$code@${c.week}')) return null;
    if (c.isPlan) {
      // Propósito: a data é o fim; vale por duas semanas depois dele.
      final end = parsePlanYmd(c.week);
      if (end == null) return null;
      return DateTime.now().difference(end).inDays <= 14 ? c : null;
    }
    final current = LeagueService.weekKey();
    final previous = LeagueService.weekKey(
      DateTime.now().subtract(const Duration(days: 7)),
    );
    return c.week == current || c.week == previous ? c : null;
  }

  /// Grupo que tem [missionSlug] como estudo desta semana, ou `null`. Se
  /// o líder tem o Peregrino+, a cena abre para o grupo inteiro.
  StudyRoom? roomStudying(String missionSlug) {
    if (currentStudy?.missionSlug == missionSlug) return activeRoom;
    // Cena de um dia do propósito que já abriu.
    final p = plan;
    if (p != null && p.openDays().any((d) => d.scene?.slug == missionSlug)) {
      return activeRoom;
    }
    return null;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_keyActiveCode);
    _seenClosings = (prefs.getStringList(_keySeenClosings) ?? const []).toSet();
    unawaited(_loadPilot());
    _loaded = true;
    ensureInviteListener();
    if (code != null && code.isNotEmpty && backend.isActive) {
      await openRoom(code);
    } else {
      notifyListeners();
    }
  }

  /// Ouve convites em tempo real. Pode ser chamado no build: não notifica
  /// na hora, só quando a lista muda.
  void ensureInviteListener() {
    final uid = backend.uid;
    if (!backend.isActive || uid == null) {
      _stopInviteListener(clear: true);
      return;
    }
    if (_listeningUid == uid && _inviteSub != null) return;
    _listeningUid = uid;
    _inviteSub?.cancel();
    _invitesSeen = false;
    _inviteSub = FirebaseFirestore.instance
        .collection('roomInvites')
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .listen(
          (snap) {
            // Snapshot sem mudança de documento (só confirmação do servidor):
            // nada novo para a barra/Juntos redesenhar.
            if (snap.docChanges.isEmpty && _invitesSeen) return;
            _invitesSeen = true;
            invites = [
              for (final doc in snap.docs)
                ?RoomInvite.fromDoc(doc.id, doc.data()),
            ];
            notifyListeners();
          },
          onError: (Object e) {
            // Stream morre no erro: solta para o próximo
            // ensureInviteListener reabrir.
            debugPrint('Convites do grupo: $e');
            _stopInviteListener(clear: false);
          },
        );
  }

  bool _invitesSeen = false;

  void _stopInviteListener({required bool clear}) {
    _invitesSeen = false;
    _inviteSub?.cancel();
    _inviteSub = null;
    _listeningUid = null;
    if (!clear || invites.isEmpty) return;
    invites = const [];
    scheduleMicrotask(notifyListeners);
  }

  @override
  void dispose() {
    _inviteSub?.cancel();
    ModerationService.instance.removeListener(notifyListeners);
    super.dispose();
  }

  Future<void> _loadPilot() async {
    if (!backend.isActive) return;
    final pilot = await backend.fetchGroupsPilot();
    if (pilot == pilotLeader) return;
    pilotLeader = pilot;
    notifyListeners();
  }

  /// O grupo do código é do piloto? (link de convite com a chave desligada)
  Future<bool> isPilotRoom(String code) async {
    try {
      return (await backend.fetchRoom(code))?.pilot ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Recarrega a sala ativa (útil depois que o backend fica disponível).
  Future<void> syncIfNeeded() async {
    ensureInviteListener();
    if (!backend.isActive) return;
    unawaited(_loadPilot());
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_keyActiveCode);
    if (code == null || code.isEmpty) return;
    if (activeRoom?.code == code && members.isNotEmpty) {
      await refreshMembers();
      return;
    }
    await openRoom(code);
  }

  /// Aplica sala vinda da nuvem (troca de device).
  Future<void> applyCloudCode(String? code, {ProgressService? progress}) async {
    final normalized = code?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getString(_keyActiveCode);
    if (local == null || local.isEmpty) {
      await _persistCode(normalized, progress: progress);
    }
    if (backend.isActive) {
      await openRoom(prefs.getString(_keyActiveCode) ?? normalized);
    }
  }

  Future<void> _persistCode(String? code, {ProgressService? progress}) async {
    _progress = progress ?? _progress;
    progress = _progress;
    if (code != null && code.isNotEmpty) closedRoom = null;
    final prefs = await SharedPreferences.getInstance();
    if (code == null || code.isEmpty) {
      await prefs.remove(_keyActiveCode);
    } else {
      await prefs.setString(_keyActiveCode, code);
    }
    if (progress != null) {
      await progress.setSyncedRoomCode(code);
    }
  }

  Future<bool> createRoom(
    String name,
    ProgressService progress, {
    RoomKind kind = RoomKind.celula,
    int? weeklyGoalSteps,
  }) async {
    lastError = null;
    if (!backend.isActive) {
      lastError = L10n.current.roomErrorSignInCreate;
      notifyListeners();
      return false;
    }
    loading = true;
    notifyListeners();
    final previous = activeRoom?.code;
    final room = await backend.createRoom(
      name: name,
      userName: progress.publicUserName,
      weeklySteps: progress.weeklySteps,
      lastWalkDate: progress.lastPlayedDate,
      playDates: progress.playDates,
      kind: kind,
      weeklyGoalSteps: weeklyGoalSteps,
      pilot: pilotLeader,
    );
    loading = false;
    if (room == null) {
      lastError = L10n.current.roomErrorCreate;
      notifyListeners();
      return false;
    }
    await _dropPrevious(previous, room.code);
    activeRoom = room;
    await _persistCode(room.code, progress: progress);
    await refreshMembers();
    return true;
  }

  Future<bool> joinRoom(String code, ProgressService progress) async {
    lastError = null;
    if (!backend.isActive) {
      lastError = L10n.current.roomErrorSignInJoin;
      notifyListeners();
      return false;
    }
    loading = true;
    notifyListeners();
    final previous = activeRoom?.code;
    StudyRoom? room;
    try {
      room = await backend.joinRoom(
        code: code,
        userName: progress.publicUserName,
        weeklySteps: progress.weeklySteps,
        lastWalkDate: progress.lastPlayedDate,
        playDates: progress.playDates,
      );
    } on RoomFullException {
      loading = false;
      lastError = L10n.current.roomErrorFullAskLeader(kRoomMemberLimit);
      notifyListeners();
      return false;
    } on RoomClosedException {
      loading = false;
      lastError = L10n.current.roomErrorClosedJoin;
      notifyListeners();
      return false;
    }
    loading = false;
    if (room == null) {
      lastError = L10n.current.roomErrorInvalidCode;
      notifyListeners();
      return false;
    }
    await _dropPrevious(previous, room.code);
    activeRoom = room;
    await _persistCode(room.code, progress: progress);
    await refreshMembers();
    return true;
  }

  Future<void> openRoom(String code, {ProgressService? progress}) async {
    if (!backend.isActive) return;
    _progress = progress ?? _progress;
    loading = true;
    lastError = null;
    notifyListeners();
    final StudyRoom? room;
    try {
      room = await backend.fetchRoom(code);
    } catch (_) {
      // Rede caiu: não é "perdeu o grupo" — guarda o código e deixa tentar.
      lastError = L10n.current.roomErrorLoad;
      loadFailed = true;
      loading = false;
      notifyListeners();
      return;
    }
    loadFailed = false;
    if (room == null || room.isClosed) {
      // Sai do grupo também na nuvem — senão o código volta a cada abertura
      // e a presença continua indo para um grupo que não está mais ativo.
      activeRoom = null;
      members = const [];
      await _persistCode(null, progress: progress);
      closedRoom = room;
      lastError = room == null ? L10n.current.roomErrorLostGroup : null;
      loading = false;
      notifyListeners();
      return;
    }
    activeRoom = room;
    await _persistCode(room.code, progress: progress);
    await refreshMembers();
  }

  Future<void> refreshMembers() async {
    final code = activeRoom?.code;
    if (code == null || !backend.isActive) {
      loading = false;
      notifyListeners();
      return;
    }
    final results = await Future.wait([
      backend.fetchRoomMembers(code),
      backend.fetchRoomNudgedToday(code),
      backend.fetchLatestRoomClosing(code),
    ]);
    // Trocou ou saiu do grupo durante a busca: não pinta o grupo novo com
    // os membros do anterior.
    if (activeRoom?.code != code) {
      if (activeRoom == null && loading) {
        loading = false;
        notifyListeners();
      }
      return;
    }
    members = results[0] as List<RoomMember>;
    nudgedToday = results[1] as Set<String>;
    latestClosing = results[2] as RoomClosing?;
    loading = false;
    notifyListeners();
  }

  /// Um grupo por pessoa: ao trocar, sai da lista do anterior.
  Future<void> _dropPrevious(String? previous, String next) async {
    if (previous == null || previous == next) return;
    await backend.leaveRoom(previous);
  }

  /// Grava no membro que o estudo da semana foi feito, se a missão já consta
  /// nas concluídas. Chamado ao abrir a aba e ao voltar da missão.
  Future<void> syncStudyDone(ProgressService progress) async {
    final room = activeRoom;
    final study = currentStudy;
    if (room == null || study == null || !backend.isActive) return;
    // Só conta a cena feita nesta semana do estudo (refazer vale); quem fez
    // meses antes precisa fazer de novo.
    if (!progress.sceneDoneSince(study.missionSlug, study.week)) return;
    final key = RoomMember.studyDoneKey(study);
    final me = members.where((m) => m.isUser).firstOrNull;
    if (me?.studyDone == key) return;
    final ok = await backend.markRoomStudyDone(room.code, key);
    if (ok) await refreshMembers();
  }

  /// Grava no membro quantos capítulos da leitura da semana a pessoa leu
  /// (lidos nesta semana). Chamado junto com [syncStudyDone].
  Future<void> syncReading(ProgressService progress) async {
    final room = activeRoom;
    final reading = currentReading;
    if (room == null || reading == null || !backend.isActive) return;
    final done = progress.chaptersReadSince(
      reading.bookAbbrev,
      reading.from,
      reading.to,
      reading.week,
    );
    final me = members.where((m) => m.isUser).firstOrNull;
    if (me != null && me.readingDoneFor(reading) == done) return;
    final ok = await backend.markRoomReading(room.code, reading.week, done);
    if (ok) await refreshMembers();
  }

  /// Grava no membro o crescimento do acerto nesta semana ("quem mais
  /// cresceu" no fechamento). Sem dados suficientes, não grava nada.
  Future<void> syncGrowth(ProgressService progress) async {
    final room = activeRoom;
    if (room == null || !backend.isActive) return;
    final week = LeagueService.weekKey();
    final pts = ReadingGrowth.weekDelta(
      correct: progress.weekAnswerCorrect,
      total: progress.weekAnswerTotal,
      week: ReadingGrowth.weekKey(DateTime.now()),
    );
    if (pts == null) return;
    final me = members.where((m) => m.isUser).firstOrNull;
    if (me != null && me.growthFor(week) == pts) return;
    final ok = await backend.markRoomGrowth(room.code, week, pts);
    if (ok) await refreshMembers();
  }

  /// Líder marca (ou tira, com `null`) a leitura da semana.
  Future<bool> setReading(RoomReading? reading) {
    return _updateRoom(
      {'reading': reading?.toMap()},
      (r) => reading == null
          ? r.copyWith(clearReading: true)
          : r.copyWith(reading: reading),
    );
  }

  /// Líder fecha a semana corrente: grava o fechamento para a revelação.
  Future<RoomClosing?> closeWeek() async {
    final room = activeRoom;
    // Grupo se formando não fecha semana (nem dá selo).
    if (room == null || !room.isOwner(backend.uid) || !isFormed) return null;
    final closing = week.close(week: LeagueService.weekKey());
    final ok = await backend.saveRoomClosing(room.code, closing);
    if (!ok) return null;
    latestClosing = closing;
    notifyListeners();
    return closing;
  }

  /// A revelação foi vista neste aparelho.
  Future<void> markClosingSeen(RoomClosing closing) async {
    final code = activeRoom?.code;
    if (code == null) return;
    _seenClosings = {..._seenClosings, '$code@${closing.week}'};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keySeenClosings, _seenClosings.toList());
    notifyListeners();
  }

  /// Quem ficou entre os fiéis guarda o selo da semana no próprio membro
  /// (aparece no grupo) e no progresso (aparece no Perfil).
  Future<bool> claimSeal(RoomClosing closing, ProgressService progress) async {
    final code = activeRoom?.code;
    final uid = backend.uid;
    if (code == null || uid == null || !closing.faithful.contains(uid)) {
      return false;
    }
    await progress.addGroupSeals(['$code@${closing.week}']);
    final me = members.where((m) => m.isUser).firstOrNull;
    if (me != null && me.sealWeeks.contains(closing.week)) return true;
    final ok = await backend.claimRoomSeal(code, closing.week);
    if (ok) await refreshMembers();
    return ok;
  }

  /// Selos ganhos neste grupo em outro aparelho chegam ao Perfil.
  Future<void> syncSeals(ProgressService progress) async {
    final code = activeRoom?.code;
    final me = members.where((m) => m.isUser).firstOrNull;
    if (code == null || me == null || me.sealWeeks.isEmpty) return;
    await progress.addGroupSeals([for (final w in me.sealWeeks) '$code@$w']);
  }

  Future<bool> _updateRoom(
    Map<String, Object?> fields,
    StudyRoom Function(StudyRoom) apply,
  ) async {
    final room = activeRoom;
    if (room == null || !backend.isActive) return false;
    final ok = await backend.updateRoom(room.code, fields);
    if (ok) {
      activeRoom = apply(room);
      notifyListeners();
    }
    return ok;
  }

  /// Líder abre ou fecha as respostas do propósito para os membros.
  Future<bool> setAnswersPrivate(bool private) {
    _answers.clear();
    return _updateRoom({
      'answersPrivate': private ? true : null,
    }, (r) => r.copyWith(answersPrivate: private));
  }

  Future<bool> editRoom({required String name, required RoomKind kind}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return Future.value(false);
    return _updateRoom({
      'name': trimmed,
      'kind': kind.storageKey,
    }, (r) => r.copyWith(name: trimmed, kind: kind));
  }

  /// Líder marca (ou tira, com `null`) o estudo da semana.
  Future<bool> setStudy(RoomStudy? study) {
    return _updateRoom(
      {'study': study?.toMap()},
      (r) => study == null
          ? r.copyWith(clearStudy: true)
          : r.copyWith(study: study),
    );
  }

  /// Passa a liderança para outro membro. Depois disso, só ele edita.
  Future<bool> transferOwnership(RoomMember to) {
    return _updateRoom({
      'ownerId': to.uid,
      'ownerName': to.name,
    }, (r) => r.copyWith(ownerId: to.uid, ownerName: to.name));
  }

  /// Chama alguém da caravana. O convite aparece no app dela.
  Future<bool> inviteMember({
    required String toUid,
    required String toName,
    required ProgressService progress,
    String? toPhotoUrl,
  }) async {
    lastError = null;
    final room = activeRoom;
    if (room == null || !backend.isActive) {
      lastError = L10n.current.roomErrorCreateFirst;
      notifyListeners();
      return false;
    }
    if (toUid.isEmpty || toUid == backend.uid) return false;
    if (members.any((m) => m.uid == toUid)) return true;
    if (isFull) {
      lastError = L10n.current.roomErrorFull(kRoomMemberLimit);
      notifyListeners();
      return false;
    }
    final ok = await backend.sendRoomInvite(
      code: room.code,
      roomName: room.name,
      kind: room.kind,
      fromName: progress.publicUserName,
      toUid: toUid,
      toName: toName,
      toPhotoUrl: toPhotoUrl,
      pilot: room.pilot,
    );
    if (!ok) {
      lastError = L10n.current.cornerSendFailed;
      notifyListeners();
      return false;
    }
    final invite = RoomInvite(
      id: RoomInvite.docId(room.code, toUid),
      roomCode: room.code,
      roomName: room.name,
      kind: room.kind,
      fromUid: backend.uid ?? '',
      fromName: progress.publicUserName,
      toUid: toUid,
      toName: toName,
      status: RoomInviteStatus.pending,
      fromPhotoUrl: backend.userPhotoUrl,
      toPhotoUrl: toPhotoUrl,
      pilot: room.pilot,
    );
    invites = [
      for (final existing in invites)
        if (existing.id != invite.id) existing,
      invite,
    ];
    notifyListeners();
    return true;
  }

  Future<bool> acceptInvite(RoomInvite invite, ProgressService progress) async {
    final joined = await joinRoom(invite.roomCode, progress);
    if (!joined) return false;
    final ok = await backend.setRoomInviteStatus(
      invite.id,
      RoomInviteStatus.accepted,
    );
    if (!ok) {
      lastError = null;
    }
    return true;
  }

  Future<bool> declineInvite(RoomInvite invite) async {
    return backend.setRoomInviteStatus(invite.id, RoomInviteStatus.declined);
  }

  Future<bool> cancelInvite(String toUid) async {
    final room = activeRoom;
    if (room == null) return false;
    final id = RoomInvite.docId(room.code, toUid);
    final ok = await backend.setRoomInviteStatus(
      id,
      RoomInviteStatus.cancelled,
    );
    if (!ok) return false;
    invites = [
      for (final invite in invites)
        if (invite.id == id)
          invite.copyWith(status: RoomInviteStatus.cancelled)
        else
          invite,
    ];
    notifyListeners();
    return true;
  }

  Future<bool> nudge(
    RoomMember member,
    ProgressService progress, {
    String? kind,
  }) async {
    final room = activeRoom;
    if (room == null || !backend.isActive) return false;
    final ok = await backend.sendRoomNudge(
      code: room.code,
      toUid: member.uid,
      fromName: progress.publicUserName,
      roomName: room.name,
      kind: kind,
    );
    if (ok) {
      nudgedToday = {...nudgedToday, member.uid};
      notifyListeners();
    }
    return ok;
  }

  /// Líder encerra o grupo para todos. Nada é apagado: o grupo fica
  /// inativo no banco e pode ser reaberto ([reopenClosedRoom]).
  Future<bool> closeRoom({ProgressService? progress}) async {
    final room = activeRoom;
    if (room == null || !backend.isActive) return false;
    final byName = (progress ?? _progress)?.publicUserName ?? room.ownerName;
    final ok = await backend.closeRoom(room.code, byName: byName);
    if (!ok) return false;
    unawaited(AnalyticsService.instance.logEvent('group_closed'));
    activeRoom = null;
    members = const [];
    nudgedToday = const {};
    latestClosing = null;
    lastError = null;
    await _persistCode(null, progress: progress);
    closedRoom = StudyRoom(
      code: room.code,
      name: room.name,
      ownerId: room.ownerId,
      ownerName: room.ownerName,
      kind: room.kind,
      closedAt: DateTime.now(),
      closedBy: backend.uid,
      closedByName: byName,
    );
    notifyListeners();
    return true;
  }

  /// Líder reabre o grupo que encerrou; volta a ser o grupo ativo.
  Future<bool> reopenClosedRoom({ProgressService? progress}) async {
    final room = closedRoom;
    if (room == null || !backend.isActive || !room.isOwner(backend.uid)) {
      return false;
    }
    final ok = await backend.reopenRoom(room.code);
    if (!ok) {
      lastError = L10n.current.roomReopenFailed;
      notifyListeners();
      return false;
    }
    unawaited(AnalyticsService.instance.logEvent('group_reopened'));
    closedRoom = null;
    await _persistCode(room.code, progress: progress);
    await openRoom(room.code, progress: progress);
    return activeRoom != null;
  }

  /// Fecha o aviso de grupo encerrado.
  void dismissClosedRoom() {
    if (closedRoom == null && lastError == null) return;
    closedRoom = null;
    lastError = null;
    notifyListeners();
  }

  /// Dono ajusta (ou limpa, com `null`) a meta semanal de passos da sala.
  Future<bool> setWeeklyGoal(int? goal) async {
    final room = activeRoom;
    if (room == null || !backend.isActive) return false;
    final ok = await backend.setRoomWeeklyGoal(room.code, goal);
    if (ok) {
      activeRoom = (goal != null && goal > 0)
          ? room.copyWith(weeklyGoalSteps: goal)
          : room.copyWith(clearGoal: true);
      notifyListeners();
    }
    return ok;
  }

  Future<void> leaveRoom({ProgressService? progress}) async {
    final code = activeRoom?.code;
    if (code != null && backend.isActive) {
      await backend.leaveRoom(code);
    }
    activeRoom = null;
    members = const [];
    nudgedToday = const {};
    latestClosing = null;
    lastError = null;
    await _persistCode(null, progress: progress);
    notifyListeners();
  }
}
