import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n_global.dart';
import '../models/portrait_style.dart';

/// Níveis da caravana — sobem com semanas firmes, nunca descem.
enum LeagueTier { semente, videira, oliveira, cedro, estrela }

extension LeagueTierX on LeagueTier {
  String get label => switch (this) {
    LeagueTier.semente => L10n.current.leagueTierSemente,
    LeagueTier.videira => L10n.current.leagueTierVideira,
    LeagueTier.oliveira => L10n.current.leagueTierOliveira,
    LeagueTier.cedro => L10n.current.leagueTierCedro,
    LeagueTier.estrela => L10n.current.leagueTierEstrela,
  };

  /// Nome curto para zonas do ranking.
  String get shortLabel => label;
}

/// Resultado da semana anterior, aguardando o usuário ver.
enum LeagueOutcome { promoted }

enum LeaguePillKind { role, walk, online }

class LeagueMetaPill {
  final LeaguePillKind kind;
  final String label;
  final bool emphasis;

  const LeagueMetaPill({
    required this.kind,
    required this.label,
    this.emphasis = false,
  });
}

/// Ritmo da etapa do mês da Caravana ([LeagueService.goalPace]).
enum GoalPace { starting, onTrack, behind, reached }

/// O momento da etapa, para a fala do Anan ([LeagueService.goalMood]).
enum GoalMood { starting, stalled, fast, finalStretch, steady }

class LeagueEntry {
  final String? uid;
  final String name;
  final int steps;
  final bool isUser;

  /// Última caminhada (`YYYY-MM-DD`).
  final String? lastWalkDate;

  /// Último dia online (`YYYY-MM-DD`).
  final String? lastSeenDate;
  final String? photoUrl;
  final PortraitStyle portraitStyle;

  /// Passos de cenas novas nesta semana.
  final int weekSteps;

  /// Passos do mês no começo de hoje (`null` = sem passo hoje = [steps]).
  final int? dayStartSteps;

  /// Peregrino+ ativo: selo + no avatar.
  final bool plus;

  const LeagueEntry({
    this.uid,
    required this.name,
    required this.steps,
    this.isUser = false,
    this.lastWalkDate,
    this.lastSeenDate,
    this.photoUrl,
    this.portraitStyle = PortraitStyle.photo,
    this.weekSteps = 0,
    this.dayStartSteps,
    this.plus = false,
  });

  int get stepsAtDayStart => dayStartSteps ?? steps;

  static String? formatShortBrDate(String? yyyyMmDd) {
    if (yyyyMmDd == null || yyyyMmDd.isEmpty) return null;
    final parts = yyyyMmDd.split('-');
    if (parts.length != 3) return null;
    return '${parts[2]}/${parts[1]}';
  }

  static String? formatBrDate(String? yyyyMmDd) {
    if (yyyyMmDd == null || yyyyMmDd.isEmpty) return null;
    final parts = yyyyMmDd.split('-');
    if (parts.length != 3) return null;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  bool get isOnlineToday => _daysSince(lastSeenDate) == 0;

  bool get walkedToday => _daysSince(lastWalkDate) == 0;

  /// Pílulas curtas para o card — papel, caminhada e presença.
  List<LeagueMetaPill> metaPills({int? rank}) {
    final l = L10n.current;
    final pills = <LeagueMetaPill>[];

    if (rank != null && rank <= 3) {
      pills.add(
        LeagueMetaPill(
          kind: LeaguePillKind.role,
          label: switch (rank) {
            1 => l.leagueRoleLeader,
            2 => l.leagueRoleVice,
            _ => l.leagueRolePodium,
          },
          emphasis: true,
        ),
      );
    }

    final walkBr = formatShortBrDate(lastWalkDate);
    final seenBr = formatShortBrDate(lastSeenDate);
    final walkedToday = this.walkedToday;
    final onlineToday = isOnlineToday;

    if (walkedToday) {
      pills.add(
        LeagueMetaPill(
          kind: LeaguePillKind.walk,
          label: l.leagueWalkedToday,
          emphasis: true,
        ),
      );
    } else if (walkBr != null) {
      pills.add(LeagueMetaPill(kind: LeaguePillKind.walk, label: walkBr));
    }

    if (onlineToday && !walkedToday) {
      pills.add(
        LeagueMetaPill(
          kind: LeaguePillKind.online,
          label: l.leagueSeenToday,
          emphasis: true,
        ),
      );
    } else if (seenBr != null && !onlineToday && lastSeenDate != lastWalkDate) {
      pills.add(
        LeagueMetaPill(
          kind: LeaguePillKind.online,
          label: l.leagueSeenDate(seenBr),
        ),
      );
    }

    return pills;
  }

  /// Uma linha curta para o card do ranking.
  String? get activitySummary {
    final l = L10n.current;
    final walkDays = _daysSince(lastWalkDate);
    final seenDays = _daysSince(lastSeenDate);
    final walkBr = formatShortBrDate(lastWalkDate);
    final seenBr = formatShortBrDate(lastSeenDate);

    if (walkDays == null && seenDays == null) return null;

    final walkedToday = walkDays == 0;
    final onlineToday = seenDays == 0;

    if (walkedToday && onlineToday) return l.leagueActiveToday;
    if (walkedToday) return l.leagueWalkedToday;
    if (onlineToday && walkBr != null) {
      return l.leagueSeenTodayWalked(walkBr);
    }
    if (onlineToday) return l.leagueSeenToday;
    if (walkBr != null && seenBr != null && lastWalkDate != lastSeenDate) {
      return l.leagueWalkedSeen(walkBr, seenBr);
    }
    if (walkBr != null) return l.leagueWalkedDate(walkBr);
    if (seenBr != null) return l.leagueSeenDate(seenBr);
    return null;
  }

  String? get lastOnlineLabel {
    if (lastSeenDate == null || lastSeenDate!.isEmpty) return null;
    if (_daysSince(lastSeenDate) == 0) return L10n.current.leagueSeenToday;
    final br = formatBrDate(lastSeenDate);
    return br != null ? L10n.current.leagueSeenOn(br) : null;
  }

  static int? _daysSince(String? yyyyMmDd) {
    if (yyyyMmDd == null || yyyyMmDd.isEmpty) return null;
    final parts = yyyyMmDd.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    // Datas em UTC: diferença em dias civis, imune à troca de horário.
    final last = DateTime.utc(y, m, d);
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    return today.difference(last).inDays.clamp(0, 999);
  }
}

/// Caravana: um ranking só, o do mês (jogadores reais do Firestore + o
/// usuário). O nível sobe com semanas firmes e sincroniza em users/{uid}.
class LeagueService extends ChangeNotifier {
  static const _keyTier = 'leagueTier';
  static const _keySteadyWeeks = 'leagueSteadyWeeks';
  static const _keyProcessedWeek = 'leagueProcessedWeek';
  static const _keyOutcome = 'leaguePendingOutcome';

  static const promotionBonusXp = 50;

  /// Cenas novas que firmam uma semana.
  static const steadyWeekScenes = 5;

  /// Semanas firmes (seguidas ou não) para subir um nível.
  static const steadyWeeksToRise = 3;

  static int get maxTierIndex => LeagueTier.values.length - 1;

  /// Outros peregrinos mínimos para o ranking ter tensão (você + 1).
  static const minPeerCount = 1;

  /// Campo competitivo: pelo menos [minPeerCount] par real.
  static bool fieldIsCompetitive(int peerCount) => peerCount >= minPeerCount;

  /// Peregrinos vistos hoje, na ordem do ranking (posição original).
  static List<({LeagueEntry entry, int rank})> onlineNow(
    List<LeagueEntry> entries,
  ) {
    return [
      for (var i = 0; i < entries.length; i++)
        if (entries[i].isOnlineToday) (entry: entries[i], rank: i + 1),
    ];
  }

  static String onlineCountLabel(int n) => L10n.current.leagueStudying(n);

  /// Posições ganhas hoje por linha de [sorted] (já ordenada pelo placar):
  /// compara com a ordem pelos passos do começo do dia. Só subida — quem
  /// ficou para trás não ganha seta.
  static List<int> placesUpToday(List<LeagueEntry> sorted) {
    final before = [...sorted]
      ..sort((a, b) => _compareBy(a, b, (e) => e.stepsAtDayStart));
    // Só quem andou hoje sobe: empate em 0 (ordem do servidor ≠ ordem por
    // nome) não pode virar seta.
    return [
      for (var i = 0; i < sorted.length; i++)
        sorted[i].steps <= sorted[i].stepsAtDayStart
            ? 0
            : (before.indexOf(sorted[i]) - i).clamp(0, sorted.length),
    ];
  }

  /// Fecha uma semana: [scenes] cenas novas nela. Puro, testável.
  static ({int tierIndex, int steadyWeeks, bool promoted}) settleSteadyWeek({
    required int scenes,
    required int tierIndex,
    required int steadyWeeks,
  }) {
    if (scenes < steadyWeekScenes || tierIndex >= maxTierIndex) {
      return (tierIndex: tierIndex, steadyWeeks: steadyWeeks, promoted: false);
    }
    final firm = steadyWeeks + 1;
    if (firm < steadyWeeksToRise) {
      return (tierIndex: tierIndex, steadyWeeks: firm, promoted: false);
    }
    return (tierIndex: tierIndex + 1, steadyWeeks: 0, promoted: true);
  }

  int tierIndex = 0;

  /// Semanas firmes acumuladas no nível atual (0…[steadyWeeksToRise] − 1).
  int steadyWeeks = 0;
  LeagueOutcome? pendingOutcome;
  String? _processedWeek;
  bool _loaded = false;
  bool _cloudHydrated = false;

  bool get isLoaded => _loaded;
  LeagueTier get tier => LeagueTier.values[tierIndex];
  bool get isMaxTier => tierIndex >= maxTierIndex;

  static String weekKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    final monday = DateTime(d.year, d.month, d.day - (d.weekday - 1));
    return monday.toIso8601String().substring(0, 10);
  }

  static String monthKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}';
  }

  /// Mês anterior a [month] ("YYYY-MM").
  static String previousMonthKey(String month) {
    final parts = month.split('-');
    final y = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    return monthKey(DateTime(y, m - 1, 1));
  }

  /// Dias restantes até a semana fechar (domingo inclui hoje).
  static int daysLeft([DateTime? now]) {
    final d = now ?? DateTime.now();
    return 8 - d.weekday;
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Cloud (hydrate) tem prioridade se ja chegou enquanto o prefs carregava.
      if (_cloudHydrated) return;
      tierIndex = (prefs.getInt(_keyTier) ?? 0).clamp(0, maxTierIndex);
      steadyWeeks = prefs.getInt(_keySteadyWeeks) ?? 0;
      _processedWeek = prefs.getString(_keyProcessedWeek);
      final rawOutcome = prefs.getString(_keyOutcome);
      if (rawOutcome != null) {
        for (final o in LeagueOutcome.values) {
          if (o.name == rawOutcome) pendingOutcome = o;
        }
      }
    } catch (e) {
      debugPrint('LeagueService.init falhou: $e');
    } finally {
      // Nunca deixar a aba Caravana em spinner eterno.
      if (!_loaded && !_cloudHydrated) {
        _loaded = true;
        notifyListeners();
      }
    }
  }

  /// Campos persistidos em users/{uid} junto com o progresso.
  Map<String, dynamic> toCloudMap() {
    return {
      'leagueTier': tierIndex,
      'leagueSteadyWeeks': steadyWeeks,
      'leagueProcessedWeek': _processedWeek,
      'leaguePendingOutcome': pendingOutcome?.name,
    };
  }

  /// Aplica estado da nuvem (fonte da verdade entre dispositivos).
  Future<void> applyFromCloud(Map<String, dynamic> data) async {
    if (data.containsKey('leagueTier')) {
      tierIndex = ((data['leagueTier'] as num?)?.toInt() ?? tierIndex).clamp(
        0,
        maxTierIndex,
      );
    }
    if (data.containsKey('leagueSteadyWeeks')) {
      steadyWeeks = (data['leagueSteadyWeeks'] as num?)?.toInt() ?? steadyWeeks;
    }
    if (data.containsKey('leagueProcessedWeek')) {
      _processedWeek = data['leagueProcessedWeek'] as String? ?? _processedWeek;
    }
    if (data.containsKey('leaguePendingOutcome')) {
      final raw = data['leaguePendingOutcome'] as String?;
      pendingOutcome = null;
      if (raw != null) {
        for (final o in LeagueOutcome.values) {
          if (o.name == raw) pendingOutcome = o;
        }
      }
    }
    _cloudHydrated = true;
    _loaded = true;
    await _persist();
    notifyListeners();
  }

  /// Fecha a semana anterior se virou a semana. [lastWeekScenes] são as
  /// cenas novas da semana [lastWeekKey] (vindas do ProgressService).
  Future<void> settleWeekIfNeeded({
    required int lastWeekScenes,
    required String? lastWeekKey,
  }) async {
    final current = weekKey();
    if (_processedWeek == current) return;

    // Primeira vez: só marca a semana atual, sem resultado.
    if (_processedWeek == null) {
      _processedWeek = current;
      await _persist();
      notifyListeners();
      return;
    }

    final closedWeek = _processedWeek!;
    final settled = settleSteadyWeek(
      scenes: lastWeekKey == closedWeek ? lastWeekScenes : 0,
      tierIndex: tierIndex,
      steadyWeeks: steadyWeeks,
    );
    tierIndex = settled.tierIndex;
    steadyWeeks = settled.steadyWeeks;
    if (settled.promoted) pendingOutcome = LeagueOutcome.promoted;
    _processedWeek = current;
    await _persist();
    notifyListeners();
  }

  Future<void> dismissOutcome() async {
    pendingOutcome = null;
    await _persist();
    notifyListeners();
  }

  /// Limpa estado local (logout / troca de conta).
  Future<void> resetForLogout() async {
    tierIndex = 0;
    steadyWeeks = 0;
    pendingOutcome = null;
    _processedWeek = null;
    _cloudHydrated = false;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTier);
    await prefs.remove(_keySteadyWeeks);
    await prefs.remove(_keyProcessedWeek);
    await prefs.remove(_keyOutcome);
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTier, tierIndex);
    await prefs.setInt(_keySteadyWeeks, steadyWeeks);
    if (_processedWeek != null) {
      await prefs.setString(_keyProcessedWeek, _processedWeek!);
    }
    if (pendingOutcome != null) {
      await prefs.setString(_keyOutcome, pendingOutcome!.name);
    } else {
      await prefs.remove(_keyOutcome);
    }
  }

  /// Classificação do mês. Só pessoas reais do Firebase + o usuário.
  List<LeagueEntry> monthStandings({
    required String userName,
    required int userMonthSteps,
    required int userWeekSteps,
    required int userDayStartSteps,
    String? userUid,
    String? userLastWalkDate,
    String? userLastSeenDate,
    String? userPhotoUrl,
    PortraitStyle userPortraitStyle = PortraitStyle.photo,
    List<LeagueEntry> realPlayers = const [],
  }) {
    final entries = [
      ...realPlayers,
      LeagueEntry(
        uid: userUid,
        name: userName,
        steps: userMonthSteps,
        isUser: true,
        lastWalkDate: userLastWalkDate,
        lastSeenDate: userLastSeenDate,
        photoUrl: userPhotoUrl,
        portraitStyle: userPortraitStyle,
        weekSteps: userWeekSteps,
        dayStartSteps: userDayStartSteps,
      ),
    ]..sort(_compareEntries);
    return entries;
  }

  int userRank(List<LeagueEntry> entries) =>
      entries.indexWhere((e) => e.isUser) + 1;

  /// Meta coletiva: cenas por pessoa que caminhou no mês passado.
  static const goalScenesPerWalker = 12;

  /// Meta mínima (caravana pequena ou mês sem histórico).
  static const goalFloor = 60;

  /// Cenas novas próprias no mês para guardar o postal da Caravana.
  static const goalMinScenes = 3;

  /// Marcos da meta: cada um revela um pedaço do postal.
  static const goalMilestones = [0.25, 0.5, 1.0];

  /// Meta de cenas do mês, arredondada para dezenas.
  static int monthSceneGoal(int lastMonthWalkers) {
    final raw = lastMonthWalkers * goalScenesPerWalker;
    return math.max(goalFloor, (raw / 10).ceil() * 10);
  }

  /// Ritmo da etapa: começando (primeiros 2 dias, pouco dado), no ritmo
  /// (chega antes do fim do mês, [arrivalDay] = dia previsto), atrasada
  /// ([perDay] = cenas por dia até o fim) ou vencida. Puro, testável.
  static ({GoalPace pace, int arrivalDay, int perDay, int left}) goalPace({
    required int done,
    required int goal,
    DateTime? now,
  }) {
    final n = now ?? DateTime.now();
    final start = DateTime(n.year, n.month, 1);
    final end = DateTime(n.year, n.month + 1, 1);
    final left = math.max(0, goal - done);
    if (left == 0) {
      return (pace: GoalPace.reached, arrivalDay: 0, perDay: 0, left: 0);
    }
    final daysLeft = math.max(1.0, end.difference(n).inMinutes / 1440);
    final perDay = (left / daysLeft).ceil();
    final elapsed = n.difference(start).inMinutes / 1440;
    if (elapsed < 2) {
      return (
        pace: GoalPace.starting,
        arrivalDay: 0,
        perDay: perDay,
        left: left,
      );
    }
    final rate = done / elapsed;
    if (rate <= 0) {
      return (pace: GoalPace.behind, arrivalDay: 0, perDay: perDay, left: left);
    }
    final eta = n.add(Duration(minutes: (left / rate * 1440).ceil()));
    if (!eta.isBefore(end)) {
      return (pace: GoalPace.behind, arrivalDay: 0, perDay: perDay, left: left);
    }
    return (
      pace: GoalPace.onTrack,
      arrivalDay: eta.day,
      perDay: perDay,
      left: left,
    );
  }

  /// Dias sem a caravana avançar para o Anan dizer que ela parou.
  static const stalledDays = 2;

  /// Chegada prevista com tantos dias de folga = "rápida".
  static const fastLeadDays = 5;

  /// Últimos dias do mês = reta final.
  static const finalDays = 3;

  /// O momento da etapa para a fala do Anan (antes da chegada). Ordem:
  /// início, reta final, parada, rápida, senão o passo comum. Puro.
  /// [daysSinceAdvance] = dias desde a última vez que a soma subiu.
  static ({GoalMood mood, int days, int left, int arrivalDay}) goalMood({
    required int done,
    required int goal,
    required int daysSinceAdvance,
    DateTime? now,
  }) {
    final n = now ?? DateTime.now();
    final pace = goalPace(done: done, goal: goal, now: n);
    final lastDay = DateTime(n.year, n.month + 1, 0).day;
    final daysLeft = lastDay - n.day + 1;
    GoalMood mood;
    var days = 0;
    if (pace.pace == GoalPace.reached) {
      mood = GoalMood.steady;
    } else if (pace.pace == GoalPace.starting) {
      mood = GoalMood.starting;
    } else if (daysLeft <= finalDays) {
      mood = GoalMood.finalStretch;
      days = daysLeft;
    } else if (daysSinceAdvance >= stalledDays) {
      mood = GoalMood.stalled;
      days = daysSinceAdvance;
    } else if (pace.pace == GoalPace.onTrack &&
        lastDay - pace.arrivalDay >= fastLeadDays) {
      mood = GoalMood.fast;
    } else {
      mood = GoalMood.steady;
    }
    return (
      mood: mood,
      days: days,
      left: pace.left,
      arrivalDay: pace.arrivalDay,
    );
  }

  /// Índice do último pouso alcançado em [goalMilestones] (-1 = nenhum).
  static int goalStop({required int scenes, required int goal}) {
    if (goal <= 0) return -1;
    final f = scenes / goal;
    var stop = -1;
    for (var i = 0; i < goalMilestones.length; i++) {
      if (f >= goalMilestones[i]) stop = i;
    }
    return stop;
  }

  /// Quanto do postal aparece: o último marco atingido (0 antes do 1º).
  static double goalReveal({required int scenes, required int goal}) {
    if (goal <= 0) return 0;
    final f = scenes / goal;
    var shown = 0.0;
    for (final m in goalMilestones) {
      if (f >= m) shown = m;
    }
    return shown;
  }

  /// Caravana até este tamanho aparece inteira no cartão.
  static const windowShowAll = 8;

  /// Pódio sempre visível acima do trecho.
  static const windowPodium = 3;

  /// Vizinhos acima: "alcançáveis" em até tantas cenas.
  static const reachScenes = 3;

  /// Passos por cena quando ainda não há média própria no mês.
  static const fallbackSceneSteps = 60;

  /// Passos que [reachScenes] cenas rendem para quem tem [monthSteps] em
  /// [monthScenes] cenas no mês.
  static int reachSteps({required int monthSteps, required int monthScenes}) {
    final perScene = monthScenes > 0 && monthSteps > 0
        ? (monthSteps / monthScenes).round()
        : fallbackSceneSteps;
    return reachScenes * perScene.clamp(20, 200);
  }

  /// O trecho do cartão: pódio, `···` (linha `null`) e você com os vizinhos
  /// — sempre umas 8 linhas, com 10 ou 10 mil pessoas. Puro, testável.
  ///
  /// [top] vem do 1º para baixo, [above]/[below] do mais perto para o mais
  /// longe; nenhuma lista traz [me]. [ahead] = quantos têm mais passos que
  /// [me]; [total] conta [me].
  static List<({LeagueEntry? entry, int rank})> caravanWindow({
    required LeagueEntry me,
    required List<LeagueEntry> top,
    required List<LeagueEntry> above,
    required List<LeagueEntry> below,
    required int ahead,
    required int total,
    required int reach,
  }) {
    final myRank = ahead + 1;
    // Caravana pequena ou eu perto do topo: uma lista só, sem buraco.
    if (total <= windowShowAll || myRank <= windowShowAll - 1) {
      final sorted = [...top, me]..sort(_compareEntries);
      final upTo = total <= windowShowAll
          ? sorted.length
          : math.max(windowPodium + 2, sorted.indexOf(me) + 2);
      return [
        for (var i = 0; i < math.min(upTo, sorted.length); i++)
          (entry: sorted[i], rank: i + 1),
      ];
    }

    // Acima: só quem dá para alcançar (no máximo 2); o mais perto sempre.
    final reachable = [
      for (final p in above.take(2))
        if (p.steps - me.steps <= reach) p,
    ];
    final shownAbove = reachable.isEmpty ? above.take(1).toList() : reachable;
    final rows = <({LeagueEntry? entry, int rank})>[
      for (var i = 0; i < math.min(windowPodium, top.length); i++)
        (entry: top[i], rank: i + 1),
    ];
    final firstAboveRank = myRank - shownAbove.length;
    if (firstAboveRank > windowPodium + 1) rows.add((entry: null, rank: 0));
    for (var i = shownAbove.length - 1; i >= 0; i--) {
      final rank = myRank - 1 - i;
      if (rank > windowPodium) rows.add((entry: shownAbove[i], rank: rank));
    }
    rows.add((entry: me, rank: myRank));
    if (below.isNotEmpty) rows.add((entry: below.first, rank: myRank + 1));
    return rows;
  }

  /// Quem passar primeiro: o vizinho logo acima em [rows] e quantos passos
  /// faltam (pelo menos 1 — empate não passa). `null` se você lidera.
  static ({LeagueEntry who, int steps})? nextToPass(
    List<({LeagueEntry? entry, int rank})> rows,
  ) {
    final i = rows.indexWhere((r) => r.entry?.isUser ?? false);
    if (i <= 0) return null;
    final me = rows[i].entry!;
    final next = rows[i - 1].entry;
    if (next == null) return null;
    return (who: next, steps: math.max(1, next.steps - me.steps + 1));
  }

  static int _compareEntries(LeagueEntry a, LeagueEntry b) =>
      _compareBy(a, b, (e) => e.steps);

  static int _compareBy(
    LeagueEntry a,
    LeagueEntry b,
    int Function(LeagueEntry) score,
  ) {
    final sa = score(a);
    final sb = score(b);
    if (sb != sa) return sb.compareTo(sa);
    // Empate: usuário fica na frente (gentileza de produto).
    if (a.isUser) return -1;
    if (b.isUser) return 1;
    return a.name.compareTo(b.name);
  }
}
