import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/study_room.dart';
import 'backend_service.dart';
import 'league_service.dart';
import 'progress_service.dart';

/// Orquestra salas privadas: código local + sync Firebase via [BackendService].
class RoomService extends ChangeNotifier {
  static const _keyActiveCode = 'activeRoomCode';

  final BackendService backend;

  StudyRoom? activeRoom;
  List<RoomMember> members = const [];

  /// Membros já chamados hoje (um chamado por pessoa por dia).
  Set<String> nudgedToday = const {};

  /// Convites em que eu participo (enviados ou recebidos).
  List<RoomInvite> invites = const [];
  bool loading = false;
  String? lastError;
  bool _loaded = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _inviteSub;
  String? _listeningUid;

  RoomService(this.backend);

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
        if (invite.toUid == uid && invite.isPending) invite,
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

  /// Estudo marcado para a semana corrente (ou `null`).
  RoomStudy? get currentStudy => activeRoom?.studyFor(LeagueService.weekKey());

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_keyActiveCode);
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
    _inviteSub = FirebaseFirestore.instance
        .collection('roomInvites')
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .listen((snap) {
          invites = [
            for (final doc in snap.docs)
              ?RoomInvite.fromDoc(doc.id, doc.data()),
          ];
          notifyListeners();
        }, onError: (Object e) => debugPrint('Convites do grupo: $e'));
  }

  void _stopInviteListener({required bool clear}) {
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
    super.dispose();
  }

  /// Recarrega a sala ativa (útil depois que o backend fica disponível).
  Future<void> syncIfNeeded() async {
    ensureInviteListener();
    if (!backend.isActive) return;
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
      lastError = 'Entre com Google para criar um grupo.';
      notifyListeners();
      return false;
    }
    loading = true;
    notifyListeners();
    final previous = activeRoom?.code;
    final room = await backend.createRoom(
      name: name,
      userName: progress.userName,
      weeklySteps: progress.weeklySteps,
      lastWalkDate: progress.lastPlayedDate,
      playDates: progress.playDates,
      kind: kind,
      weeklyGoalSteps: weeklyGoalSteps,
    );
    loading = false;
    if (room == null) {
      lastError = 'Não foi possível criar o grupo. Tente de novo.';
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
      lastError = 'Entre com Google para entrar num grupo.';
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
        userName: progress.userName,
        weeklySteps: progress.weeklySteps,
        lastWalkDate: progress.lastPlayedDate,
        playDates: progress.playDates,
      );
    } on RoomFullException {
      loading = false;
      lastError =
          'Este grupo já tem $kRoomMemberLimit pessoas. '
          'Peça ao líder para abrir outro grupo.';
      notifyListeners();
      return false;
    }
    loading = false;
    if (room == null) {
      lastError = 'Código inválido ou grupo não encontrado.';
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
    loading = true;
    notifyListeners();
    final room = await backend.fetchRoom(code);
    if (room == null) {
      activeRoom = null;
      members = const [];
      await _persistCode(null, progress: progress);
      lastError = 'Não achamos o grupo em que você estava.';
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
    ]);
    members = results[0] as List<RoomMember>;
    nudgedToday = results[1] as Set<String>;
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
    if (!progress.completedMissions.contains(study.missionSlug)) return;
    final key = RoomMember.studyDoneKey(study);
    final me = members.where((m) => m.isUser).firstOrNull;
    if (me?.studyDone == key) return;
    final ok = await backend.markRoomStudyDone(room.code, key);
    if (ok) await refreshMembers();
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
      lastError = 'Crie o grupo antes de chamar alguém.';
      notifyListeners();
      return false;
    }
    if (toUid.isEmpty || toUid == backend.uid) return false;
    if (members.any((m) => m.uid == toUid)) return true;
    if (isFull) {
      lastError = 'Este grupo já tem $kRoomMemberLimit pessoas.';
      notifyListeners();
      return false;
    }
    final ok = await backend.sendRoomInvite(
      code: room.code,
      roomName: room.name,
      kind: room.kind,
      fromName: progress.userName,
      toUid: toUid,
      toName: toName,
      toPhotoUrl: toPhotoUrl,
    );
    if (!ok) {
      lastError = 'Não deu para enviar o convite. Tente de novo.';
      notifyListeners();
      return false;
    }
    final invite = RoomInvite(
      id: RoomInvite.docId(room.code, toUid),
      roomCode: room.code,
      roomName: room.name,
      kind: room.kind,
      fromUid: backend.uid ?? '',
      fromName: progress.userName,
      toUid: toUid,
      toName: toName,
      status: RoomInviteStatus.pending,
      fromPhotoUrl: backend.userPhotoUrl,
      toPhotoUrl: toPhotoUrl,
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

  Future<bool> nudge(RoomMember member, ProgressService progress) async {
    final room = activeRoom;
    if (room == null || !backend.isActive) return false;
    final ok = await backend.sendRoomNudge(
      code: room.code,
      toUid: member.uid,
      fromName: progress.userName,
      roomName: room.name,
    );
    if (ok) {
      nudgedToday = {...nudgedToday, member.uid};
      notifyListeners();
    }
    return ok;
  }

  /// Líder encerra o grupo para todos.
  Future<bool> closeRoom({ProgressService? progress}) async {
    final code = activeRoom?.code;
    if (code == null || !backend.isActive) return false;
    final ok = await backend.deleteRoom(code);
    if (!ok) return false;
    activeRoom = null;
    members = const [];
    nudgedToday = const {};
    lastError = null;
    await _persistCode(null, progress: progress);
    notifyListeners();
    return true;
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
    lastError = null;
    await _persistCode(null, progress: progress);
    notifyListeners();
  }
}
