import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/walk_companion.dart';
import 'backend_service.dart';
import 'progress_service.dart';

/// Companhia — até 3 pares de caminhada (friend streak de passos).
/// Local + sync Firebase quando autenticado.
class CompanionService extends ChangeNotifier {
  static const _keyCodes = 'companionCodes';
  static const maxCompanions = 3;

  final BackendService backend;

  List<WalkCompanion> companions = const [];
  bool loading = false;
  String? lastError;
  bool _loaded = false;

  CompanionService(this.backend);

  bool get isLoaded => _loaded;
  bool get canAdd => companions.length < maxCompanions;

  Future<void> init() async {
    await refresh();
    _loaded = true;
    notifyListeners();
  }

  Future<List<String>> _loadCodes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyCodes) ?? const [];
  }

  Future<void> _saveCodes(List<String> codes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCodes, codes);
  }

  Future<void> refresh() async {
    final codes = await _loadCodes();
    if (codes.isEmpty) {
      companions = const [];
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
    await _saveCodes(codes);
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
    );
    loading = false;
    if (joined == null) {
      lastError = 'Código inválido ou companhia já está completa.';
      notifyListeners();
      return false;
    }
    final codes = await _loadCodes();
    if (!codes.contains(joined.code)) {
      await _saveCodes([...codes, joined.code]);
    }
    await refresh();
    return true;
  }

  /// Publica que o usuário caminhou hoje e recalcula dias juntos.
  Future<void> syncWalksIfNeeded(ProgressService progress) async {
    if (!backend.isActive || companions.isEmpty) return;
    if (!progress.walkedToday && progress.missionsToday <= 0) return;
    await backend.publishCompanionWalks(
      codes: companions.map((c) => c.code).toList(),
      userName: progress.userName,
    );
    await refresh();
  }

  Future<void> leave(String code) async {
    lastError = null;
    if (backend.isActive) {
      await backend.leaveCompanion(code);
    }
    final codes = [for (final c in await _loadCodes()) if (c != code) c];
    await _saveCodes(codes);
    await refresh();
  }

  /// Debug / testes.
  @visibleForTesting
  Future<void> replaceCodesForTest(List<String> codes) async {
    await _saveCodes(codes);
  }

  Map<String, dynamic> debugSnapshot() => {
        'companions': companions.length,
        'codes': companions.map((c) => c.code).toList(),
      };

  @override
  String toString() => jsonEncode(debugSnapshot());
}
