import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Identidade do dispositivo + backup/restauração de progresso.
class SyncService extends ChangeNotifier {
  static const _keyDeviceId = 'deviceId';
  static const _keyLastSync = 'lastSyncAt';

  String? deviceId;
  DateTime? lastSyncAt;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    deviceId = prefs.getString(_keyDeviceId);
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_keyDeviceId, deviceId!);
    }
    final last = prefs.getString(_keyLastSync);
    if (last != null) lastSyncAt = DateTime.tryParse(last);
    notifyListeners();
  }

  Map<String, dynamic> exportPayload({
    required int steps,
    required int streak,
    required String? lastPlayedDate,
    required List<String> completedMissions,
    required int missionsToday,
    required String userName,
  }) {
    return {
      'version': 1,
      'deviceId': deviceId,
      'exportedAt': DateTime.now().toIso8601String(),
      'xp': steps, // legado
      'steps': steps,
      'streak': streak,
      'lastPlayedDate': lastPlayedDate,
      'completedMissions': completedMissions,
      'missionsToday': missionsToday,
      'userName': userName,
    };
  }

  String exportJson({
    required int steps,
    required int streak,
    required String? lastPlayedDate,
    required List<String> completedMissions,
    required int missionsToday,
    required String userName,
  }) {
    return const JsonEncoder.withIndent('  ').convert(exportPayload(
      steps: steps,
      streak: streak,
      lastPlayedDate: lastPlayedDate,
      completedMissions: completedMissions,
      missionsToday: missionsToday,
      userName: userName,
    ));
  }

  ({int steps, int streak, String? lastPlayedDate, List<String> completedMissions, int missionsToday, String userName})? parseImport(String json) {
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      if (data['version'] != 1) return null;
      return (
        steps: (data['steps'] as int?) ?? (data['xp'] as int?) ?? 0,
        streak: data['streak'] as int? ?? 0,
        lastPlayedDate: data['lastPlayedDate'] as String?,
        completedMissions: (data['completedMissions'] as List?)?.cast<String>() ?? [],
        missionsToday: data['missionsToday'] as int? ?? 0,
        userName: data['userName'] as String? ?? 'Peregrino',
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> markSynced() async {
    lastSyncAt = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSync, lastSyncAt!.toIso8601String());
    notifyListeners();
  }
}
