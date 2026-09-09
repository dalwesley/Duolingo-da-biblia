import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/walk_companion.dart';
import 'backend_service.dart';
import 'progress_service.dart';
import 'subscription_service.dart';

/// Companhia — pares de caminhada (friend streak de passos).
/// Local + sync Firebase quando autenticado.
class CompanionService extends ChangeNotifier {
  static const _keyCodes = 'companionCodes';
  static const _freeMaxCompanions = 3;
  static const _plusMaxCompanions = 6;

  final BackendService backend;
  final SubscriptionService? subscription;

  List<WalkCompanion> companions = const [];
  bool loading = false;
  String? lastError;
  bool _loaded = false;
  bool _cloudSynced = false;

  CompanionService(this.backend, [this.subscription]) {
    subscription?.addListener(_onSubscriptionChanged);
  }

  void _onSubscriptionChanged() => notifyListeners();

  bool get isLoaded => _loaded;

  /// Primeiro aceno pendente — a Home usa para o card e as 👋.
  WalkCompanion? get incomingNudge {
    for (final c in companions) {
      if (c.hasIncomingNudge) return c;
    }
    return null;
  }

  /// Peregrino+ dobra o limite de companheiros simultâneos.
  int get maxCompanions => subscription?.isPeregrinoPlus == true
      ? _plusMaxCompanions
      : _freeMaxCompanions;

  bool get canAdd => companions.length < maxCompanions;
  bool get cloudSynced => _cloudSynced;

  void markCloudUnsynced() {
    _cloudSynced = false;
  }

  Future<void> init() async {
    await refresh();
    _loaded = true;
    notifyListeners();
  }

  Future<List<String>> _loadCodes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyCodes) ?? const [];
  }

  Future<void> _saveCodes(
    List<String> codes, {
    ProgressService? progress,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCodes, codes);
    if (progress != null) {
      await progress.setSyncedCompanionCodes(codes);
    }
  }

  /// Une códigos da nuvem com o aparelho (troca de device).
  Future<void> applyCloudCodes(
    List<String> cloudCodes,
    ProgressService progress,
  ) async {
    final local = await _loadCodes();
    final merged = <String>{
      ...local,
      for (final c in cloudCodes)
        if (c.trim().isNotEmpty) c.trim().toUpperCase(),
    }.toList();
    await _saveCodes(merged, progress: progress);
    await refresh();
  }

  Future<void> refresh() async {
    final codes = await _loadCodes();
    if (codes.isEmpty) {
      companions = const [];
      _cloudSynced = backend.isActive;
      notifyListeners();
      return;
    }
    if (!backend.isActive) {
      companions = [
        for (final c in codes)
          WalkCompanion(
            code: c,
            displayName: 'Companheiro',
            sharedDays: 0,
            iWalkedToday: false,
            theyWalkedToday: false,
            awaitingPartner: true,
            isHost: true,
          ),
      ];
      _cloudSynced = false;
      notifyListeners();
      return;
    }
    loading = true;
    notifyListeners();
    final out = <WalkCompanion>[];
    final valid = <String>[];
    for (final code in codes) {
      final c = await backend.fetchCompanion(code);
      if (c == null) continue;
      out.add(c);
      valid.add(code);
    }
    if (valid.length != codes.length) await _saveCodes(valid);
    companions = out;
    loading = false;
    _cloudSynced = true;
    notifyListeners();
  }

  Future<WalkCompanion?> createInvite(ProgressService progress) async {
    lastError = null;
    if (!canAdd) {
      lastError = 'No máximo $maxCompanions companheiros.';
      notifyListeners();
      return null;
    }
    if (!backend.isActive) {
      lastError = 'Entre com Google para criar uma companhia.';
      notifyListeners();
      return null;
    }
    loading = true;
    notifyListeners();
    final created = await backend.createCompanionInvite(
      userName: progress.userName,
    );
    loading = false;
    if (created == null) {
      lastError = 'Não foi possível criar o convite.';
      notifyListeners();
      return null;
    }
    final codes = [...await _loadCodes(), created.code];
    await _saveCodes(codes, progress: progress);
    await refresh();
    for (final c in companions) {
      if (c.code == created.code) return c;
    }
    return created;
  }

  Future<bool> joinWithCode(String rawCode, ProgressService progress) async {
    lastError = null;
    if (!canAdd) {
      lastError = 'No máximo $maxCompanions companheiros.';
      notifyListeners();
      return false;
    }
    if (!backend.isActive) {
      lastError = 'Entre com Google para entrar numa companhia.';
      notifyListeners();
      return false;
    }
    loading = true;
    notifyListeners();
    final joined = await backend.joinCompanion(
      code: rawCode,
      userName: progress.userName,
      hadMissionsAtJoin: progress.completedMissions.isNotEmpty,
    );
    loading = false;
    if (joined == null) {
      lastError = 'Código inválido ou companhia já está completa.';
      notifyListeners();
      return false;
    }
    final codes = await _loadCodes();
    if (!codes.contains(joined.code)) {
      await _saveCodes([...codes, joined.code], progress: progress);
    }
    await refresh();
    return true;
  }

  /// Publica presença (visto + passos semanais) e, se caminhou hoje, o passo.
  /// Retorna os códigos cuja recompensa de referral acabou de ser concedida
  /// (convidado completou a 1ª missão), para o chamador celebrar na UI.
  Future<List<String>> syncPresence(ProgressService progress) async {
    if (!backend.isActive || companions.isEmpty) return const [];
    final codes = companions.map((c) => c.code).toList();
    await backend.syncCompanionPresence(
      codes: codes,
      userName: progress.userName,
      weeklySteps: progress.weeklySteps,
      walkedToday: progress.walkedToday,
      completedFirstMission: progress.completedMissions.isNotEmpty,
    );
    await refresh();
    final rewarded = <String>[];
    for (final c in companions) {
      if (c.isHost && c.guestFirstMissionDone) {
        final granted = await progress.claimReferralReward(c.code);
        if (granted) rewarded.add(c.code);
      }
    }
    return rewarded;
  }

  /// Envia um aceno no app. WhatsApp continua opcional no sheet.
  Future<bool> sendNudge({
    required String code,
    required String fromName,
    required String message,
  }) async {
    lastError = null;
    if (!backend.isActive) {
      lastError = 'Entre na conta para acenar no app.';
      notifyListeners();
      return false;
    }
    final ok = await backend.sendCompanionNudge(
      code: code,
      fromName: fromName,
      message: message,
    );
    if (!ok) {
      lastError = 'Não foi possível enviar o aceno.';
      notifyListeners();
      return false;
    }
    await refresh();
    return true;
  }

  Future<void> leave(String code, {ProgressService? progress}) async {
    lastError = null;
    if (backend.isActive) {
      await backend.leaveCompanion(code);
    }
    final codes = [
      for (final c in await _loadCodes())
        if (c != code) c,
    ];
    await _saveCodes(codes, progress: progress);
    await refresh();
  }

  @override
  void dispose() {
    subscription?.removeListener(_onSubscriptionChanged);
    super.dispose();
  }

  @override
  String toString() => jsonEncode({
    'companions': companions.length,
    'codes': companions.map((c) => c.code).toList(),
  });
}
