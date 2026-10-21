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
  static const _keyLeagueServerSettlement = 'league_server_settlement';
  static const _keyPlusLaunchFreeUntil = 'plus_launch_free_until';
  static const _keyPioneerUntil = 'pioneer_until';
  static const _keyGroupsEnabled = 'groups_enabled';
  static const _keyCompanionEnabled = 'companion_enabled';
  static const _keyChallengeEnabled = 'challenge_enabled';

  static const _defaults = <String, Object>{
    _keyReferralBonus: 50,
    _keyRoomChestBonus: 15,
    _keyLeagueGroupSize: 20,
    _keyLeagueServerSettlement: false,
    _keyPlusLaunchFreeUntil: '',
    _keyPioneerUntil: '',
    _keyGroupsEnabled: false,
    _keyCompanionEnabled: false,
    _keyChallengeEnabled: false,
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

  bool _bool(String key) => _rc?.getBool(key) ?? (_defaults[key] as bool);

  String _string(String key) =>
      _rc?.getString(key) ?? (_defaults[key] as String);

  /// Bônus ao host quando o convidado completa a 1ª missão (referral).
  int get referralFirstMissionBonus => _int(_keyReferralBonus);

  /// Recompensa do baú de grupo na sala de estudo.
  int get roomChestBonusSteps => _int(_keyRoomChestBonus);

  /// Tamanho do grupo (pool) de cada divisão da Caravana.
  int get leagueGroupSize => _int(_keyLeagueGroupSize);

  /// Subida/descida decidida pela Cloud Function `settleLeagueWeek`
  /// (`users/{uid}.leagueResult`). Desligado: o app fecha a semana sozinho.
  bool get leagueServerSettlement => _bool(_keyLeagueServerSettlement);

  /// Grupos (criar, entrar, convites). Desligado: a aba mostra "em breve"
  /// até existirem os planos Líder/Igreja. [debugGroupsEnabled] força no
  /// laboratório.
  bool get groupsEnabled =>
      (kDebugMode && debugGroupsEnabled) || _bool(_keyGroupsEnabled);

  bool debugGroupsEnabled = false;

  void debugSetGroupsEnabled(bool value) {
    if (!kDebugMode) return;
    debugGroupsEnabled = value;
    notifyListeners();
  }

  /// Companhia (par 1:1, aceno, convite por código). Desligada: a aba
  /// Companhia mostra "em breve" e nada chama para a companhia.
  /// [debugCompanionEnabled] força no laboratório.
  bool get companionEnabled =>
      (kDebugMode && debugCompanionEnabled) || _bool(_keyCompanionEnabled);

  bool debugCompanionEnabled = false;

  void debugSetCompanionEnabled(bool value) {
    if (!kDebugMode) return;
    debugCompanionEnabled = value;
    notifyListeners();
  }

  /// Desafio (mesma cena até domingo). Desligado: o painel Desafio mostra
  /// "em breve" e some da Home, do perfil da Caravana e do Perfil.
  /// [debugChallengeEnabled] força no laboratório.
  bool get challengeEnabled =>
      (kDebugMode && debugChallengeEnabled) || _bool(_keyChallengeEnabled);

  bool debugChallengeEnabled = false;

  void debugSetChallengeEnabled(bool value) {
    if (!kDebugMode) return;
    debugChallengeEnabled = value;
    notifyListeners();
  }

  /// Último dia (YYYY-MM-DD, inclusive) do Peregrino+ grátis no lançamento.
  /// Vazio ou inválido: sem promoção.
  DateTime? get plusLaunchFreeUntil => _date(_keyPlusLaunchFreeUntil);

  /// Último dia (YYYY-MM-DD, inclusive) de venda do Pioneiro. Vazio ou
  /// inválido: sem prazo, vale só o teto de vagas.
  DateTime? get pioneerUntil => _date(_keyPioneerUntil);

  DateTime? _date(String key) {
    final raw = _string(key).trim();
    if (raw.isEmpty) return null;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
}
