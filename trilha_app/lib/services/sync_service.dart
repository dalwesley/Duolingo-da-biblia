import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'league_service.dart';
import 'progress_service.dart';

/// Identidade do dispositivo + backup/restauração completo (mesmo mapa do Firestore).
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

  /// Backup de emergência = snapshot v2 idêntico ao documento `users/{uid}`.
  Map<String, dynamic> exportPayload(
    ProgressService progress, {
    LeagueService? league,
  }) {
    return {
      ...progress.toCloudMap(),
      if (league != null) ...league.toCloudMap(),
      'deviceId': deviceId,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  String exportJson(
    ProgressService progress, {
    LeagueService? league,
  }) {
    return const JsonEncoder.withIndent('  ').convert(
      exportPayload(progress, league: league),
    );
  }

  /// Aceita v2 (completo) ou v1 legado (subconjunto).
  Map<String, dynamic>? parseImport(String json) {
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final version = (data['version'] as num?)?.toInt() ?? 0;
      if (version < 1) return null;
      if (version == 1) {
        // Normaliza v1 para o formato que [ProgressService.applyFromCloud] entende.
        return {
          'version': 1,
          'steps': (data['steps'] as num?)?.toInt() ??
              (data['xp'] as num?)?.toInt() ??
              0,
          'xp': (data['steps'] as num?)?.toInt() ??
              (data['xp'] as num?)?.toInt() ??
              0,
          'streak': (data['streak'] as num?)?.toInt() ?? 0,
          'lastPlayedDate': data['lastPlayedDate'] as String?,
          'completedMissions': data['completedMissions'],
          'missionsToday': (data['missionsToday'] as num?)?.toInt() ?? 0,
          'userName': data['userName'] as String? ?? 'Aprendiz',
        };
      }
      return data;
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
