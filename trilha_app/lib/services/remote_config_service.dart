import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Calibração de gamificação via Firebase Remote Config.
///
/// Cada valor tem um default igual ao que hoje está fixo no código — nada
/// muda até alguém configurar o parâmetro correspondente no Firebase Console.
class RemoteConfigService extends ChangeNotifier {
  RemoteConfigService._();
  static final RemoteConfigService instance = RemoteConfigService._();

  static const _keyReferralBonus = 'referral_first_mission_bonus';
  static const _keyRoomChestBonus = 'room_chest_bonus_steps';
  static const _keyLeagueGroupSize = 'league_group_size';

  static const _defaults = <String, Object>{
    _keyReferralBonus: 50,
    _keyRoomChestBonus: 15,
    _keyLeagueGroupSize: 20,
  };

  FirebaseRemoteConfig? _rc;
  StreamSubscription<RemoteConfigUpdate>? _updates;

  Future<void> init() async {
    if (_rc != null) return;
    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 8),
          minimumFetchInterval: const Duration(hours: 6),
        ),
      );
      await rc.setDefaults(_defaults);
      _rc = rc;
      await rc.fetchAndActivate();
      notifyListeners();
      await _updates?.cancel();
      _updates = rc.onConfigUpdated.listen((_) async {
        await rc.activate();
        notifyListeners();
      });
    } catch (e) {
      debugPrint('RemoteConfigService.init falhou: $e');
    }
  }

  int _int(String key) => _rc?.getInt(key) ?? (_defaults[key] as int);

  /// Bônus ao host quando o convidado completa a 1ª missão (referral).
  int get referralFirstMissionBonus => _int(_keyReferralBonus);

  /// Recompensa do baú de grupo na sala de estudo.
  int get roomChestBonusSteps => _int(_keyRoomChestBonus);

  /// Tamanho do grupo (pool) de cada divisão da Caravana.
  int get leagueGroupSize => _int(_keyLeagueGroupSize);
}
