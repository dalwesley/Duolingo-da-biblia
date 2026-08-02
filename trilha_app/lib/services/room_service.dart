import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/study_room.dart';
import 'backend_service.dart';
import 'progress_service.dart';

/// Orquestra salas privadas: código local + sync Firebase via [BackendService].
class RoomService extends ChangeNotifier {
  static const _keyActiveCode = 'activeRoomCode';

  final BackendService backend;

  StudyRoom? activeRoom;
  List<RoomMember> members = const [];
  bool loading = false;
  String? lastError;
  bool _loaded = false;

  RoomService(this.backend);

  bool get isLoaded => _loaded;
  String? get activeCode => activeRoom?.code;
  bool get hasRoom => activeRoom != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_keyActiveCode);
    _loaded = true;
    if (code != null && code.isNotEmpty && backend.isActive) {
      await openRoom(code);
    } else {
      notifyListeners();
    }
  }

  /// Recarrega a sala ativa (útil depois que o backend fica disponível).
  Future<void> syncIfNeeded() async {
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

  Future<bool> createRoom(String name, ProgressService progress) async {
    lastError = null;
    if (!backend.isActive) {
      lastError = 'Conecte-se à nuvem para criar salas.';
      notifyListeners();
      return false;
    }
    loading = true;
    notifyListeners();
    final room = await backend.createRoom(
      name: name,
      userName: progress.userName,
      weeklySteps: progress.weeklySteps,
    );
    loading = false;
    if (room == null) {
      lastError = 'Não foi possível criar a sala. Tente de novo.';
      notifyListeners();
      return false;
    }
    activeRoom = room;
    await _persistCode(room.code, progress: progress);
    await refreshMembers();
    return true;
  }

  Future<bool> joinRoom(String code, ProgressService progress) async {
    lastError = null;
    if (!backend.isActive) {
      lastError = 'Conecte-se à nuvem para entrar em salas.';
      notifyListeners();
      return false;
    }
    loading = true;
    notifyListeners();
    final room = await backend.joinRoom(
      code: code,
      userName: progress.userName,
      weeklySteps: progress.weeklySteps,
    );
    loading = false;
    if (room == null) {
      lastError = 'Código inválido ou sala não encontrada.';
      notifyListeners();
      return false;
    }
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
      lastError = 'Sala anterior não encontrada.';
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
    members = await backend.fetchRoomMembers(code);
    loading = false;
    notifyListeners();
  }

  Future<void> leaveRoom({ProgressService? progress}) async {
    final code = activeRoom?.code;
    if (code != null && backend.isActive) {
      await backend.leaveRoom(code);
    }
    activeRoom = null;
    members = const [];
    lastError = null;
    await _persistCode(null, progress: progress);
    notifyListeners();
  }
}
