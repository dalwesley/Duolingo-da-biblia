import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart';
import '../models/study_room.dart';
import '../models/walk_companion.dart';
import 'analytics_service.dart';
import 'league_service.dart';
import 'progress_service.dart';

/// Jogador real vindo da nuvem (liga da semana).
class CloudPlayer {
  final String uid;
  final String name;
  final int steps;

  const CloudPlayer({required this.uid, required this.name, required this.steps});
}

/// Resultado de uma tentativa de login (Google ou Apple).
class AuthSignInResult {
  final bool ok;
  final String? error;
  final String? displayName;
  final String? email;

  const AuthSignInResult({
    required this.ok,
    this.error,
    this.displayName,
    this.email,
  });
}

/// @nodoc Compat — mesmo tipo que [AuthSignInResult].
typedef GoogleSignInResult = AuthSignInResult;

/// Resultado tipado de leitura de `users/{uid}` — não confunde erro com ausência.
class UserBackupResult {
  final Map<String, dynamic>? data;
  final String? error;
  final bool missing;

  const UserBackupResult._({this.data, this.error, this.missing = false});

  const UserBackupResult.found(Map<String, dynamic> data)
      : this._(data: data);

  const UserBackupResult.missing() : this._(missing: true);

  const UserBackupResult.error(String message) : this._(error: message);

  bool get hasDocument => data != null;
  bool get isError => error != null;
  bool get isMissing => missing;
}

/// Backend Firebase. Quando configurado, ativa:
///   - login obrigatório (Google; Apple no iOS)
///   - backup do progresso em `users/{uid}`
///   - liga real em `leagues/{semana}/players/{uid}`
///   - salas privadas em `rooms/{code}`
class BackendService extends ChangeNotifier {
  static const _codeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  bool _firebaseReady = false;
  bool _available = false;
  bool _initializing = true;
  bool _googleBusy = false;
  bool _googleInitialized = false;
  String? _uid;
  String? lastError;
  DateTime? lastCloudSaveAt;
  Timer? _debounce;
  StreamSubscription<User?>? _authSub;

  /// Serializa writes; gerações descartam saves obsoletos.
  Future<void> _saveChain = Future<void>.value();
  int _saveGeneration = 0;

  bool get isActive => _available && _uid != null;
  bool get isFirebaseReady => _firebaseReady;
  bool get isInitializing => _initializing;
  bool get isAuthBusy => _googleBusy;
  bool get isGoogleBusy => _googleBusy;
  String? get uid => _uid;

  User? get currentUser =>
      _firebaseReady ? FirebaseAuth.instance.currentUser : null;

  bool get isGoogleSignedIn {
    final user = currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'google.com');
  }

  bool get isAppleSignedIn {
    final user = currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'apple.com');
  }

  bool get isSignedIn => isGoogleSignedIn || isAppleSignedIn;

  bool get isAnonymous => currentUser?.isAnonymous ?? false;

  String? get userEmail => currentUser?.email;
  String? get userDisplayName => currentUser?.displayName;
  String? get userPhotoUrl => currentUser?.photoURL;

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  GoogleSignIn get _google => GoogleSignIn.instance;

  Future<void> init() async {
    _initializing = true;
    lastError = null;
    notifyListeners();
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _firebaseReady = true;
      await AnalyticsService.instance.init();
      await AnalyticsService.instance.setUserId(
        FirebaseAuth.instance.currentUser?.uid,
      );
      await _ensureGoogleSignInInitialized();

      final auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      // App exige Google — descarta sessão anônima residual.
      if (user != null && user.isAnonymous) {
        await auth.signOut();
        user = null;
      }
      _applyUser(user);
      await _authSub?.cancel();
      _authSub = auth.authStateChanges().listen((u) {
        final wasActive = isActive;
        if (u != null && u.isAnonymous) {
          _applyUser(null);
        } else {
          _applyUser(u);
        }
        if (wasActive != isActive) notifyListeners();
      });
    } catch (e) {
      _firebaseReady = false;
      _available = false;
      _uid = null;
      lastError = e.toString();
      debugPrint('Backend indisponível (modo offline): $e');
    }
    _initializing = false;
    notifyListeners();
  }

  /// Tenta reconectar (útil depois de ativar Auth/Firestore no Console).
  Future<void> retry() => init();

  void _applyUser(User? user) {
    _uid = user?.uid;
    _available = _uid != null;
    if (_available) lastError = null;
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleInitialized) return;
    _authLog(
      'initialize GoogleSignIn serverClientId=${DefaultFirebaseOptions.googleWebClientId}',
    );
    await _google.initialize(
      serverClientId: DefaultFirebaseOptions.googleWebClientId,
    );
    _googleInitialized = true;
    _authLog('GoogleSignIn initialized ok');
  }

  /// Logs visíveis em release via `adb logcat | grep STWAY:Auth`.
  static void _authLog(String message) {
    // ignore: avoid_print — intencional para depurar login em --release
    print('[STWAY:Auth] $message');
  }

  /// Login nativo com Google + Firebase (idToken).
  /// O SHA real da Play (`45:E8:CB:89…`) precisa estar no Firebase.
  Future<GoogleSignInResult> signInWithGoogle() async {
    _authLog(
      'signIn start firebaseReady=$_firebaseReady '
      'googleInit=$_googleInitialized '
      'currentUid=${Firebase.apps.isEmpty ? null : FirebaseAuth.instance.currentUser?.uid} '
      'project=${DefaultFirebaseOptions.android.projectId}',
    );
    if (!_firebaseReady) {
      await init();
      if (!_firebaseReady) {
        final err = lastError ?? 'Firebase ainda não está pronto.';
        _authLog('abort: Firebase not ready → $err');
        return GoogleSignInResult(ok: false, error: err);
      }
    }

    _googleBusy = true;
    lastError = null;
    notifyListeners();

    try {
      await _ensureGoogleSignInInitialized();
      // Limpa sessão Google residual (cache de falhas SHA antigas).
      try {
        await _google.signOut();
      } catch (_) {}

      _authLog('calling authenticate()…');
      final googleUser = await _google.authenticate();
      final idToken = googleUser.authentication.idToken;
      _authLog(
        'authenticate ok email=${googleUser.email} '
        'displayName=${googleUser.displayName} '
        'idTokenLen=${idToken?.length ?? 0}',
      );
      if (idToken == null || idToken.isEmpty) {
        const err =
            'Google não retornou idToken. Confira se o SHA-1 da Play está no Firebase.';
        lastError = err;
        _authLog('fail: empty idToken');
        return const GoogleSignInResult(ok: false, error: err);
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final auth = FirebaseAuth.instance;
      final current = auth.currentUser;
      UserCredential cred;

      if (current != null && current.isAnonymous) {
        _authLog('linking credential to anonymous uid=${current.uid}');
        try {
          cred = await _firebaseAuthWithRetry(
            () => current.linkWithCredential(credential),
            label: 'linkWithCredential',
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use' ||
              e.code == 'email-already-in-use') {
            _authLog('link failed ${e.code} — signInWithCredential instead');
            await _google.signOut();
            cred = await _firebaseAuthWithRetry(
              () => auth.signInWithCredential(credential),
              label: 'signInWithCredential',
            );
          } else {
            rethrow;
          }
        }
      } else {
        _authLog('signInWithCredential…');
        cred = await _firebaseAuthWithRetry(
          () => auth.signInWithCredential(credential),
          label: 'signInWithCredential',
        );
      }

      _applyUser(cred.user);
      notifyListeners();
      _authLog(
        'success uid=${cred.user?.uid} email=${cred.user?.email} '
        'providers=${cred.user?.providerData.map((p) => p.providerId).toList()}',
      );
      return AuthSignInResult(
        ok: true,
        displayName: cred.user?.displayName ?? googleUser.displayName,
        email: cred.user?.email ?? googleUser.email,
      );
    } on GoogleSignInException catch (e) {
      _authLog(
        'GoogleSignInException code=${e.code.name} '
        'description=${e.description} details=${e.details}',
      );
      if (e.code == GoogleSignInExceptionCode.canceled) {
        lastError =
            'Login cancelado. [${e.code.name}] ${e.description ?? ''}'.trim();
        return AuthSignInResult(ok: false, error: lastError);
      }
      lastError =
          'Google Sign-In [${e.code.name}]: ${e.description ?? e.code.name}'
          '${e.details != null ? ' (${e.details})' : ''}';
      return AuthSignInResult(ok: false, error: lastError);
    } on FirebaseAuthException catch (e) {
      lastError = _authErrorMessage(e);
      _authLog(
        'FirebaseAuthException code=${e.code} message=${e.message} '
        'plugin=${e.plugin} details=${e.toString()}',
      );
      return AuthSignInResult(ok: false, error: lastError);
    } catch (e, st) {
      lastError = e.toString();
      _authLog('unexpected error: $e\n$st');
      return AuthSignInResult(ok: false, error: lastError);
    } finally {
      _googleBusy = false;
      notifyListeners();
    }
  }

  /// Login com Apple (iOS/macOS) via Firebase Auth provider nativo.
  /// Requer: Sign in with Apple no App ID + provider Apple no Firebase Console.
  Future<AuthSignInResult> signInWithApple() async {
    _authLog(
      'signInWithApple start firebaseReady=$_firebaseReady '
      'currentUid=${Firebase.apps.isEmpty ? null : FirebaseAuth.instance.currentUser?.uid}',
    );
    if (!_firebaseReady) {
      await init();
      if (!_firebaseReady) {
        final err = lastError ?? 'Firebase ainda não está pronto.';
        _authLog('abort Apple: Firebase not ready → $err');
        return AuthSignInResult(ok: false, error: err);
      }
    }

    _googleBusy = true;
    lastError = null;
    notifyListeners();

    try {
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      final auth = FirebaseAuth.instance;
      final current = auth.currentUser;
      late UserCredential cred;

      if (current != null && current.isAnonymous) {
        _authLog('linking Apple to anonymous uid=${current.uid}');
        try {
          cred = await _firebaseAuthWithRetry(
            () => current.linkWithProvider(appleProvider),
            label: 'linkWithProvider(apple)',
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use' ||
              e.code == 'email-already-in-use' ||
              e.code == 'provider-already-linked') {
            _authLog('Apple link failed ${e.code} — signInWithProvider');
            cred = await _firebaseAuthWithRetry(
              () => auth.signInWithProvider(appleProvider),
              label: 'signInWithProvider(apple)',
            );
          } else {
            rethrow;
          }
        }
      } else {
        cred = await _firebaseAuthWithRetry(
          () => auth.signInWithProvider(appleProvider),
          label: 'signInWithProvider(apple)',
        );
      }

      _applyUser(cred.user);
      notifyListeners();
      _authLog(
        'Apple success uid=${cred.user?.uid} email=${cred.user?.email} '
        'providers=${cred.user?.providerData.map((p) => p.providerId).toList()}',
      );
      return AuthSignInResult(
        ok: true,
        displayName: cred.user?.displayName,
        email: cred.user?.email,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled' || e.code == 'web-context-canceled') {
        lastError = 'Login com Apple cancelado.';
        _authLog('Apple canceled: ${e.code}');
        return AuthSignInResult(ok: false, error: lastError);
      }
      lastError = _authErrorMessage(e);
      _authLog(
        'Apple FirebaseAuthException code=${e.code} message=${e.message}',
      );
      return AuthSignInResult(ok: false, error: lastError);
    } catch (e, st) {
      lastError = e.toString();
      _authLog('Apple unexpected error: $e\n$st');
      return AuthSignInResult(ok: false, error: lastError);
    } finally {
      _googleBusy = false;
      notifyListeners();
    }
  }

  /// Firebase Auth às vezes falha com reset de conexão (rede transitória).
  static bool _isTransientAuthNetworkError(FirebaseAuthException e) {
    final msg = (e.message ?? '').toLowerCase();
    if (e.code == 'network-request-failed') return true;
    if (e.code != 'unknown' && e.code != 'internal-error') return false;
    return msg.contains('connection reset') ||
        msg.contains('connection refused') ||
        msg.contains('broken pipe') ||
        msg.contains('timed out') ||
        msg.contains('timeout') ||
        msg.contains('i/o error') ||
        msg.contains('failed to connect') ||
        msg.contains('software caused connection abort');
  }

  Future<UserCredential> _firebaseAuthWithRetry(
    Future<UserCredential> Function() action, {
    required String label,
    int maxAttempts = 3,
  }) async {
    FirebaseAuthException? last;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        _authLog('$label attempt $attempt/$maxAttempts');
        return await action();
      } on FirebaseAuthException catch (e) {
        last = e;
        final retry = _isTransientAuthNetworkError(e) && attempt < maxAttempts;
        _authLog(
          '$label failed attempt=$attempt code=${e.code} '
          'message=${e.message} retry=$retry',
        );
        if (!retry) rethrow;
        final delayMs = 400 * (1 << (attempt - 1)); // 400, 800
        await Future<void>.delayed(Duration(milliseconds: delayMs));
      }
    }
    throw last!;
  }

  /// Encerra a sessão (volta à tela de login).
  Future<bool> signOutGoogle() async {
    if (!_firebaseReady) return false;
    _googleBusy = true;
    notifyListeners();
    try {
      if (_googleInitialized) {
        await _google.signOut();
      }
      await FirebaseAuth.instance.signOut();
      _applyUser(null);
      return true;
    } catch (e) {
      lastError = e.toString();
      return false;
    } finally {
      _googleBusy = false;
      notifyListeners();
    }
  }

  static String _authErrorMessage(FirebaseAuthException e) {
    final msg = (e.message ?? '').toLowerCase();
    final looksLikeNetwork = e.code == 'network-request-failed' ||
        msg.contains('connection reset') ||
        msg.contains('i/o error') ||
        msg.contains('timed out') ||
        msg.contains('timeout') ||
        msg.contains('failed to connect');

    return switch (e.code) {
      'operation-not-allowed' || 'admin-restricted-operation' =>
        'Ative os provedores no Firebase Console: Authentication → Sign-in method → Anonymous e/ou Google.',
      'network-request-failed' =>
        'Sem conexão com a internet. Verifique o Wi‑Fi/dados do aparelho.',
      'too-many-requests' =>
        'Muitas tentativas. Aguarde um pouco e tente de novo.',
      'account-exists-with-different-credential' =>
        'Já existe uma conta com este e-mail usando outro método de login.',
      'invalid-credential' =>
        'Credencial Google inválida. Cadastre o SHA-1 do app no Firebase e baixe o google-services.json de novo.',
      _ when looksLikeNetwork =>
        'Falha de rede ao falar com o Firebase Auth (conexão resetada). Tente de novo em Wi‑Fi estável ou dados móveis.',
      _ => 'Erro de Auth (${e.code}): ${e.message ?? e.code}',
    };
  }

  Map<String, dynamic> _payload(ProgressService p, {LeagueService? league}) {
    final user = currentUser;
    return {
      ...p.toCloudMap(),
      if (league != null) ...league.toCloudMap(),
      'email': user?.email,
      'photoUrl': user?.photoURL,
      'authProvider': isGoogleSignedIn ? 'google' : 'unknown',
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Backup imediato + publicação nos rankings semanal, mensal e geral
  /// (e na sala ativa, se houver).
  Future<bool> saveNow(
    ProgressService progress,
    String week, {
    String? roomCode,
    LeagueService? league,
  }) async {
    if (!isActive) {
      _authLog('saveNow skipped — backend inactive');
      return false;
    }
    if (!progress.canPersistCloud) {
      _authLog('saveNow skipped — cloud not hydrated yet');
      return false;
    }

    final generation = ++_saveGeneration;
    final completer = Completer<bool>();
    _saveChain = _saveChain.then((_) async {
      if (generation != _saveGeneration) {
        _authLog('saveNow skipped — superseded gen=$generation');
        completer.complete(false);
        return;
      }
      final ok = await _saveNowBody(
        progress,
        week,
        roomCode: roomCode,
        league: league,
        generation: generation,
      );
      completer.complete(ok);
    }).catchError((Object e, StackTrace st) {
      _authLog('saveNow chain error: $e\n$st');
      if (!completer.isCompleted) completer.complete(false);
    });
    return completer.future;
  }

  Future<bool> _saveNowBody(
    ProgressService progress,
    String week, {
    String? roomCode,
    LeagueService? league,
    required int generation,
  }) async {
    if (!isActive || !progress.canPersistCloud) return false;
    if (generation != _saveGeneration) return false;

    // Evita gravar placeholder se a conta Google tem nome.
    if (ProgressService.isPlaceholderUserName(progress.userName)) {
      await progress.ensureUserNameFromAuth(userDisplayName);
    }

    // Espelho local ANTES da nuvem — sobrevive a kill/hot restart.
    progress.bindCacheUid(_uid);
    await progress.persistLocalCache();

    if (generation != _saveGeneration) return false;

    try {
      // 1) Progresso do usuário — nunca depende do ranking.
      // Timeout evita travar a cadeia _saveChain (e a aba Caravana) se a
      // rede/Firestore não responde.
      await _db
          .doc('users/$_uid')
          .set(
            _payload(progress, league: league),
            SetOptions(merge: true),
          )
          .timeout(const Duration(seconds: 12));
      if (generation != _saveGeneration) return false;
      lastCloudSaveAt = DateTime.now();
      // Não notifyListeners aqui — evita refresh em cascata (companions).
      _authLog(
        'saveNow user ok uid=$_uid week=$week '
        'steps=${progress.steps} streak=${progress.streak} '
        'missions=${progress.completedMissions.length} '
        'weeklySteps=${progress.weeklySteps} '
        'weeklyWeek=${progress.weeklyWeek} '
        'playDates=${progress.playDates.length} '
        'lastPlayed=${progress.lastPlayedDate}',
      );
    } on TimeoutException catch (e) {
      _authLog('saveNow USER TIMEOUT uid=$_uid: $e');
      debugPrint('Timeout ao salvar progresso na nuvem: $e');
      return false;
    } catch (e) {
      _authLog('saveNow USER FAILED uid=$_uid: $e');
      debugPrint('Falha ao salvar progresso na nuvem: $e');
      return false;
    }

    // 2) Rankings — best-effort (falha aqui não apaga o save do usuário).
    try {
      final batch = _db.batch();
      final tier = league?.tierIndex ?? 0;
      final playerPayload = {
        'name': progress.userName,
        'xp': progress.weeklySteps,
        'tier': tier,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      batch.set(
        _db.doc('leagues/$week/tiers/$tier/players/$_uid'),
        playerPayload,
      );
      batch.set(_db.doc('leagues/$week/players/$_uid'), playerPayload);
      final month = LeagueService.monthKey();
      batch.set(_db.doc('monthlyLeagues/$month/players/$_uid'), {
        'name': progress.userName,
        'xp': progress.monthlySteps,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.set(_db.doc('overallPlayers/$_uid'), {
        'name': progress.userName,
        'xp': progress.steps,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final effectiveRoom = roomCode ?? progress.activeRoomCode;
      if (effectiveRoom != null && effectiveRoom.isNotEmpty) {
        batch.set(_db.doc('rooms/$effectiveRoom/members/$_uid'), {
          'name': progress.userName,
          'xp': progress.weeklySteps,
          'lastWalk': DateTime.now().toIso8601String().substring(0, 10),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      await batch.commit().timeout(const Duration(seconds: 12));
    } on TimeoutException catch (e) {
      _authLog('saveNow rankings TIMEOUT (user ok): $e');
      debugPrint('Timeout ao salvar rankings: $e');
    } catch (e) {
      _authLog('saveNow rankings FAILED (user ok): $e');
      debugPrint('Falha ao salvar rankings: $e');
    }
    return true;
  }

  /// Resultado de [hydrateProgress].
  /// - [fromCloud]: doc `users/{uid}` aplicado
  /// - [fromLegacy]: migração local
  /// - [empty]: sem nuvem nem legado (usuário novo)
  /// - [failed]: erro — NÃO deve sobrescrever a nuvem com defaults
  static const hydrateFromCloud = 'cloud';
  static const hydrateFromLegacy = 'legacy';
  static const hydrateEmpty = 'empty';
  static const hydrateFailed = 'failed';

  /// Carrega o progresso do Firebase (fonte da verdade) para a memória da sessão.
  /// Se a nuvem estiver vazia, tenta migrar dados legados do aparelho uma vez.
  /// Retorna um dos códigos [hydrateFromCloud]/[hydrateFailed].
  Future<String> hydrateProgress(
    ProgressService progress, {
    LeagueService? league,
  }) async {
    if (!isActive) {
      progress.markCloudNotReady();
      return hydrateFailed;
    }
    progress.bindCacheUid(_uid);
    progress.markCloudNotReady();
    try {
      final backup = await fetchBackupResult();
      if (backup.isError) {
        _authLog('hydrate FAILED (fetch error): ${backup.error}');
        // Tenta espelho local da MESMA conta — não marca ready para nuvem.
        final local = await progress.readLocalCache(forUid: _uid);
        if (local != null) {
          await progress.applyFromCloud(local);
          await progress.ensureUserNameFromAuth(userDisplayName);
          _authLog(
            'hydrate FAILED but restored local cache '
            'missions=${progress.completedMissions.length}',
          );
        }
        // Sem markCloudHydrated — impede wipe na nuvem.
        return hydrateFailed;
      }

      if (backup.hasDocument) {
        final data = backup.data!;
        _authLog(
          'hydrate cloud keys=${data.keys.length} '
          'steps=${data['steps'] ?? data['xp']} '
          'streak=${data['streak']} '
          'missions=${(data['completedMissions'] as List?)?.length ?? 0} '
          'weeklySteps=${data['weeklySteps'] ?? data['weeklyXp']} '
          'weeklyWeek=${data['weeklyWeek']} '
          'lastPlayed=${data['lastPlayedDate']} '
          'userName=${data['userName']}',
        );
        await progress.applyFromCloud(data);
        // Se a nuvem veio vazia/atrasada, recupera espelho local mais rico (mesmo uid).
        final local = await progress.readLocalCache(forUid: _uid);
        if (local != null && _localCacheRicher(local, progress)) {
          _authLog(
            'hydrate: merging richer local cache '
            '(local missions=${(local['completedMissions'] as List?)?.length ?? 0} '
            'steps=${local['steps'] ?? local['xp']})',
          );
          await progress.applyFromCloud(local);
        }
        if (league != null) await league.applyFromCloud(data);
        await progress.clearLegacyLocalPrefs();
        await progress.persistLocalCache();
        final restored =
            await progress.ensureUserNameFromAuth(userDisplayName);
        progress.markCloudHydrated();
        _authLog(
          'hydrate ok steps=${progress.steps} streak=${progress.streak} '
          'missions=${progress.completedMissions.length} '
          'weeklySteps=${progress.weeklySteps} week=${progress.weeklyWeek} '
          'playDates=${progress.playDates.length} '
          'userName=${progress.userName}'
          '${restored ? ' (restored from Google)' : ''}',
        );
        return hydrateFromCloud;
      }

      _authLog('hydrate: no cloud doc — trying local cache / legacy');
      final local = await progress.readLocalCache(forUid: _uid);
      if (local != null) {
        await progress.applyFromCloud(local);
        await progress.ensureUserNameFromAuth(userDisplayName);
        progress.markCloudHydrated();
        _authLog(
          'hydrate local-cache ok steps=${progress.steps} '
          'missions=${progress.completedMissions.length}',
        );
        return hydrateFromLegacy;
      }
      final legacy = await progress.readLegacyLocalSnapshot();
      if (legacy != null) {
        await progress.applyFromCloud(legacy);
        await progress.ensureUserNameFromAuth(userDisplayName);
        progress.markCloudHydrated();
        _authLog(
          'hydrate legacy ok steps=${progress.steps} '
          'missions=${progress.completedMissions.length} '
          'userName=${progress.userName}',
        );
        return hydrateFromLegacy;
      }
      await progress.ensureUserNameFromAuth(userDisplayName);
      progress.markCloudHydrated(); // usuário novo — defaults ok para gravar
      return hydrateEmpty;
    } catch (e, st) {
      _authLog('hydrate FAILED: $e\n$st');
      debugPrint('Falha ao hidratar progresso: $e');
      try {
        final local = await progress.readLocalCache(forUid: _uid);
        if (local != null) {
          await progress.applyFromCloud(local);
          _authLog(
            'hydrate FAILED but restored local cache '
            'missions=${progress.completedMissions.length}',
          );
        }
      } catch (_) {}
      progress.markCloudNotReady();
      return hydrateFailed;
    }
  }

  /// Cache local tem mais progresso que o estado atual (nuvem vazia/atrasada).
  bool _localCacheRicher(Map<String, dynamic> local, ProgressService progress) {
    final localSteps = (local['steps'] as num?)?.toInt() ??
        (local['xp'] as num?)?.toInt() ??
        0;
    final localMissions = (local['completedMissions'] as List?)?.length ?? 0;
    final localPlays = (local['playDates'] as List?)?.length ?? 0;
    if (localMissions > progress.completedMissions.length) return true;
    if (localSteps > progress.steps) return true;
    if (localPlays > progress.playDates.length) return true;
    final localLast = (local['lastPlayedDate'] as String?)?.trim();
    if ((localLast != null && localLast.isNotEmpty) &&
        (progress.lastPlayedDate == null || progress.lastPlayedDate!.isEmpty)) {
      return true;
    }
    return false;
  }

  /// Agenda um backup (chamado a cada mudança de progresso; agrupa rajadas).
  void scheduleSave(
    ProgressService progress,
    String week, {
    String? roomCode,
    LeagueService? league,
  }) {
    if (!isActive) return;
    if (!progress.canPersistCloud) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      saveNow(progress, week, roomCode: roomCode, league: league);
    });
  }

  String _generateRoomCode() {
    final rng = Random.secure();
    return List.generate(
      6,
      (_) => _codeAlphabet[rng.nextInt(_codeAlphabet.length)],
    ).join();
  }

  /// Cria uma sala e já entra como dono/membro.
  Future<StudyRoom?> createRoom({
    required String name,
    required String userName,
    required int weeklySteps,
  }) async {
    if (!isActive) return null;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    try {
      for (var attempt = 0; attempt < 8; attempt++) {
        final code = _generateRoomCode();
        final ref = _db.doc('rooms/$code');
        try {
          await _db.runTransaction((tx) async {
            final existing = await tx.get(ref);
            if (existing.exists) throw StateError('taken');
            tx.set(ref, {
              'name': trimmed,
              'ownerId': _uid,
              'ownerName': userName,
              'createdAt': FieldValue.serverTimestamp(),
            });
          });
        } on StateError {
          continue;
        }

        await ref.collection('members').doc(_uid).set({
          'name': userName,
          'xp': weeklySteps,
          'lastWalk': DateTime.now().toIso8601String().substring(0, 10),
          'joinedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return StudyRoom(
          code: code,
          name: trimmed,
          ownerId: _uid!,
          ownerName: userName,
          createdAt: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      debugPrint('Falha ao criar sala: $e');
      return null;
    }
  }

  /// Entra numa sala pelo código de convite.
  Future<StudyRoom?> joinRoom({
    required String code,
    required String userName,
    required int weeklySteps,
  }) async {
    if (!isActive) return null;
    final normalized = code.trim().toUpperCase();
    if (normalized.length < 4) return null;
    try {
      final ref = _db.doc('rooms/$normalized');
      final doc = await ref.get();
      if (!doc.exists || doc.data() == null) return null;

      await ref.collection('members').doc(_uid).set({
        'name': userName,
        'xp': weeklySteps,
        'lastWalk': DateTime.now().toIso8601String().substring(0, 10),
        'joinedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return StudyRoom.fromMap(normalized, doc.data()!);
    } catch (e) {
      debugPrint('Falha ao entrar na sala: $e');
      return null;
    }
  }

  Future<StudyRoom?> fetchRoom(String code) async {
    if (!isActive) return null;
    final normalized = code.trim().toUpperCase();
    try {
      final doc = await _db.doc('rooms/$normalized').get();
      if (!doc.exists || doc.data() == null) return null;
      return StudyRoom.fromMap(normalized, doc.data()!);
    } catch (e) {
      debugPrint('Falha ao buscar sala: $e');
      return null;
    }
  }

  Future<List<RoomMember>> fetchRoomMembers(String code) async {
    if (!isActive) return const [];
    final normalized = code.trim().toUpperCase();
    try {
      final snap = await _db
          .collection('rooms/$normalized/members')
          .orderBy('xp', descending: true)
          .limit(50)
          .get();
      return [
        for (final d in snap.docs)
          RoomMember(
            uid: d.id,
            name: (d.data()['name'] as String?)?.trim().isNotEmpty == true
                ? d.data()['name'] as String
                : 'Aprendiz',
            steps: (d.data()['xp'] as num?)?.toInt() ?? 0,
            isUser: d.id == _uid,
            lastWalk: d.data()['lastWalk'] as String?,
          ),
      ];
    } catch (e) {
      debugPrint('Falha ao buscar membros da sala: $e');
      return const [];
    }
  }

  Future<bool> leaveRoom(String code) async {
    if (!isActive) return false;
    final normalized = code.trim().toUpperCase();
    try {
      await _db.doc('rooms/$normalized/members/$_uid').delete();
      return true;
    } catch (e) {
      debugPrint('Falha ao sair da sala: $e');
      return false;
    }
  }

  /// Restaura o backup da nuvem (retorna null se não houver).
  /// Prefira [fetchBackupResult] quando precisar distinguir erro de doc ausente.
  Future<Map<String, dynamic>?> fetchBackup() async {
    final result = await fetchBackupResult();
    if (result.isError || !result.hasDocument) return null;
    return result.data;
  }

  /// Distingue documento ausente de falha de rede/permissão.
  Future<UserBackupResult> fetchBackupResult() async {
    if (!isActive) {
      return const UserBackupResult.error('backend inactive');
    }
    try {
      final doc = await _db.doc('users/$_uid').get();
      if (!doc.exists || doc.data() == null) {
        return const UserBackupResult.missing();
      }
      return UserBackupResult.found(doc.data()!);
    } catch (e) {
      debugPrint('Falha ao restaurar da nuvem: $e');
      return UserBackupResult.error(e.toString());
    }
  }

  /// Jogadores reais da liga desta semana nesta divisão (exclui o próprio usuário).
  ///
  /// Mescla `tiers/{tier}/players` com o board flat legado — senão quem já
  /// gravou no path novo “esconde” os demais e a lista fica diferente por login.
  Future<List<CloudPlayer>> fetchWeekPlayers(
    String week, {
    required int tier,
    int limit = 30,
  }) async {
    if (!isActive) return const [];
    final byUid = <String, CloudPlayer>{};

    void put(CloudPlayer p) {
      final prev = byUid[p.uid];
      if (prev == null || p.steps > prev.steps) {
        byUid[p.uid] = p;
      } else if (prev.steps == p.steps &&
          ProgressService.isPlaceholderUserName(prev.name) &&
          !ProgressService.isPlaceholderUserName(p.name)) {
        byUid[p.uid] = p;
      }
    }

    try {
      final tierSnap = await _db
          .collection('leagues/$week/tiers/$tier/players')
          .orderBy('xp', descending: true)
          .limit(limit)
          .get();
      for (final p in _mapCloudPlayers(tierSnap.docs)) {
        put(p);
      }
    } catch (e) {
      debugPrint('Liga tier/$tier falhou: $e');
    }

    try {
      final legacy = await _db
          .collection('leagues/$week/players')
          .orderBy('xp', descending: true)
          .limit(limit * 2)
          .get();
      for (final d in legacy.docs) {
        if (d.id == _uid) continue;
        final data = d.data();
        final docTier = (data['tier'] as num?)?.toInt();
        // Sem tier (legado antigo) entra em qualquer divisão na migração.
        if (docTier != null && docTier != tier) continue;
        put(
          CloudPlayer(
            uid: d.id,
            name: (data['name'] as String?)?.trim().isNotEmpty == true
                ? data['name'] as String
                : 'Aprendiz',
            steps: (data['xp'] as num?)?.toInt() ?? 0,
          ),
        );
      }
    } catch (e) {
      debugPrint('Liga flat legado falhou: $e');
    }

    final list = byUid.values.toList()
      ..sort((a, b) {
        if (b.steps != a.steps) return b.steps.compareTo(a.steps);
        return a.name.compareTo(b.name);
      });
    return list.take(limit).toList();
  }

  List<CloudPlayer> _mapCloudPlayers(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return [
      for (final d in docs)
        if (d.id != _uid)
          CloudPlayer(
            uid: d.id,
            name: (d.data()['name'] as String?)?.trim().isNotEmpty == true
                ? d.data()['name'] as String
                : 'Aprendiz',
            steps: (d.data()['xp'] as num?)?.toInt() ?? 0,
          ),
    ];
  }

  /// Fecha a semana da caravana (se preciso) e sincroniza tier/outcome na nuvem.
  Future<void> settleAndSyncLeague(
    ProgressService progress,
    LeagueService league, {
    String? roomCode,
  }) async {
    final closed = league.processedWeek;
    final current = LeagueService.weekKey();
    var peerSteps = const <int>[];
    if (isActive && closed != null && closed != current) {
      final peers = await fetchWeekPlayers(closed, tier: league.tierIndex);
      peerSteps = [for (final p in peers) p.steps];
    }
    await league.settleWeekIfNeeded(
      lastWeekSteps: progress.lastWeekSteps,
      lastWeekKey: progress.lastWeekKey,
      peerSteps: peerSteps,
    );
    if (isActive) {
      await saveNow(
        progress,
        LeagueService.weekKey(),
        roomCode: roomCode,
        league: league,
      );
    }
  }

  /// Jogadores reais do ranking geral (exclui o próprio usuário).
  ///
  /// Prefere o espelho leve `overallPlayers` (ordenado por xp). `users/` entra
  /// só como complemento — docs cheios sem orderBy falhavam em aparelhos
  /// lentos e devolviam um recorte arbitrário (listas diferentes por login).
  Future<List<CloudPlayer>> fetchOverallPlayers({int limit = 50}) async {
    if (!isActive) return const [];
    try {
      final byUid = <String, CloudPlayer>{};
      final fetchLimit = limit + 5;

      void ingest(QueryDocumentSnapshot<Map<String, dynamic>> d) {
        if (d.id == _uid) return;
        final data = d.data();
        final steps = (data['steps'] as num?)?.toInt() ??
            (data['xp'] as num?)?.toInt() ??
            0;
        final rawName = (data['userName'] as String?)?.trim().isNotEmpty == true
            ? data['userName'] as String
            : (data['name'] as String?)?.trim().isNotEmpty == true
                ? data['name'] as String
                : 'Aprendiz';
        final prev = byUid[d.id];
        if (prev == null || steps > prev.steps) {
          byUid[d.id] = CloudPlayer(uid: d.id, name: rawName, steps: steps);
        } else if (prev.steps == steps &&
            ProgressService.isPlaceholderUserName(prev.name) &&
            !ProgressService.isPlaceholderUserName(rawName)) {
          byUid[d.id] = CloudPlayer(uid: d.id, name: rawName, steps: steps);
        }
      }

      try {
        final overallSnap = await _db
            .collection('overallPlayers')
            .orderBy('xp', descending: true)
            .limit(fetchLimit)
            .get();
        for (final d in overallSnap.docs) {
          ingest(d);
        }
      } catch (e) {
        debugPrint('Ranking geral via overallPlayers (orderBy) falhou: $e');
        try {
          final overallSnap =
              await _db.collection('overallPlayers').limit(fetchLimit).get();
          for (final d in overallSnap.docs) {
            ingest(d);
          }
        } catch (e2) {
          debugPrint('Ranking geral via overallPlayers falhou: $e2');
        }
      }

      if (byUid.length < limit) {
        try {
          final usersSnap = await _db
              .collection('users')
              .orderBy('steps', descending: true)
              .limit(fetchLimit)
              .get();
          for (final d in usersSnap.docs) {
            ingest(d);
          }
        } catch (e) {
          debugPrint('Ranking geral via users/ falhou: $e');
        }
      }

      final list = byUid.values.toList()
        ..sort((a, b) {
          if (b.steps != a.steps) return b.steps.compareTo(a.steps);
          return a.name.compareTo(b.name);
        });
      return list.take(limit).toList();
    } catch (e) {
      debugPrint('Falha ao buscar ranking geral: $e');
      return const [];
    }
  }

  // ---- Companhia (pares de caminhada) ------------------------------------

  String _todayKey() => DateTime.now().toIso8601String().substring(0, 10);

  String _yesterdayKey() {
    final d = DateTime.now().subtract(const Duration(days: 1));
    return d.toIso8601String().substring(0, 10);
  }

  WalkCompanion _companionFromDoc(
    String code,
    Map<String, dynamic> data,
  ) {
    final today = _todayKey();
    final hostId = data['hostId'] as String? ?? '';
    final guestId = data['guestId'] as String?;
    final hostName = (data['hostName'] as String?)?.trim().isNotEmpty == true
        ? data['hostName'] as String
        : 'Aprendiz';
    final guestName = (data['guestName'] as String?)?.trim();
    final isHost = hostId == _uid;
    final awaiting = guestId == null || guestId.isEmpty;
    final otherName = awaiting
        ? 'Aguardando'
        : (isHost ? (guestName ?? 'Companheiro') : hostName);
    final hostWalk = data['hostLastWalk'] as String?;
    final guestWalk = data['guestLastWalk'] as String?;
    final iWalked = isHost ? hostWalk == today : guestWalk == today;
    final theyWalked = awaiting
        ? false
        : (isHost ? guestWalk == today : hostWalk == today);

    return WalkCompanion(
      code: code,
      displayName: otherName,
      sharedDays: (data['sharedDays'] as num?)?.toInt() ?? 0,
      lastSharedDate: data['lastSharedDate'] as String?,
      iWalkedToday: iWalked,
      theyWalkedToday: theyWalked,
      awaitingPartner: awaiting,
      isHost: isHost,
    );
  }

  Future<WalkCompanion?> createCompanionInvite({
    required String userName,
  }) async {
    if (!isActive) return null;
    try {
      for (var attempt = 0; attempt < 8; attempt++) {
        final code = _generateRoomCode();
        final ref = _db.doc('companies/$code');
        try {
          await _db.runTransaction((tx) async {
            final existing = await tx.get(ref);
            if (existing.exists) throw StateError('taken');
            tx.set(ref, {
              'hostId': _uid,
              'hostName': userName,
              'guestId': null,
              'guestName': null,
              'sharedDays': 0,
              'lastSharedDate': null,
              'hostLastWalk': null,
              'guestLastWalk': null,
              'createdAt': FieldValue.serverTimestamp(),
            });
          });
        } on StateError {
          continue;
        }
        return _companionFromDoc(code, {
          'hostId': _uid,
          'hostName': userName,
          'sharedDays': 0,
        });
      }
      return null;
    } catch (e) {
      debugPrint('Falha ao criar companhia: $e');
      return null;
    }
  }

  Future<WalkCompanion?> joinCompanion({
    required String code,
    required String userName,
  }) async {
    if (!isActive) return null;
    final normalized = code.trim().toUpperCase();
    if (normalized.length < 4) return null;
    try {
      final ref = _db.doc('companies/$normalized');
      await _db.runTransaction((tx) async {
        final doc = await tx.get(ref);
        if (!doc.exists || doc.data() == null) {
          throw StateError('missing');
        }
        final data = doc.data()!;
        final hostId = data['hostId'] as String? ?? '';
        if (hostId == _uid) return;
        final guestId = data['guestId'] as String?;
        if (guestId != null && guestId.isNotEmpty && guestId != _uid) {
          throw StateError('full');
        }
        if (guestId == _uid) return;
        tx.set(ref, {
          'guestId': _uid,
          'guestName': userName,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
      final refreshed = await ref.get();
      if (!refreshed.exists || refreshed.data() == null) return null;
      return _companionFromDoc(normalized, refreshed.data()!);
    } on StateError catch (e) {
      if (e.message == 'missing' || e.message == 'full') return null;
      debugPrint('Falha ao entrar na companhia: $e');
      return null;
    } catch (e) {
      debugPrint('Falha ao entrar na companhia: $e');
      return null;
    }
  }

  Future<WalkCompanion?> fetchCompanion(String code) async {
    if (!isActive) return null;
    final normalized = code.trim().toUpperCase();
    try {
      final doc = await _db.doc('companies/$normalized').get();
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      final hostId = data['hostId'] as String? ?? '';
      final guestId = data['guestId'] as String?;
      if (hostId != _uid && guestId != _uid) return null;
      return _companionFromDoc(normalized, data);
    } catch (e) {
      debugPrint('Falha ao buscar companhia: $e');
      return null;
    }
  }

  Future<void> publishCompanionWalks({
    required List<String> codes,
    required String userName,
  }) async {
    if (!isActive || codes.isEmpty) return;
    final today = _todayKey();
    final yesterday = _yesterdayKey();
    for (final raw in codes) {
      final code = raw.trim().toUpperCase();
      try {
        final ref = _db.doc('companies/$code');
        await _db.runTransaction((tx) async {
          final doc = await tx.get(ref);
          if (!doc.exists || doc.data() == null) return;
          final data = Map<String, dynamic>.from(doc.data()!);
          final hostId = data['hostId'] as String? ?? '';
          final guestId = data['guestId'] as String?;
          final isHost = hostId == _uid;
          if (!isHost && guestId != _uid) return;

          final updates = <String, dynamic>{
            if (isHost) 'hostLastWalk': today else 'guestLastWalk': today,
            if (isHost) 'hostName': userName else 'guestName': userName,
            'updatedAt': FieldValue.serverTimestamp(),
          };

          final hostWalk = isHost ? today : data['hostLastWalk'] as String?;
          final guestWalk = isHost ? data['guestLastWalk'] as String? : today;
          final bothToday = hostWalk == today && guestWalk == today;
          if (bothToday && guestId != null && guestId.isNotEmpty) {
            final lastShared = data['lastSharedDate'] as String?;
            if (lastShared != today) {
              var days = (data['sharedDays'] as num?)?.toInt() ?? 0;
              if (lastShared == yesterday) {
                days += 1;
              } else {
                days = 1;
              }
              updates['sharedDays'] = days;
              updates['lastSharedDate'] = today;
            }
          }
          tx.set(ref, updates, SetOptions(merge: true));
        });
      } catch (e) {
        debugPrint('Falha ao publicar caminhada $code: $e');
      }
    }
  }

  Future<void> leaveCompanion(String code) async {
    if (!isActive) return;
    final normalized = code.trim().toUpperCase();
    try {
      final ref = _db.doc('companies/$normalized');
      final doc = await ref.get();
      if (!doc.exists || doc.data() == null) return;
      final data = doc.data()!;
      final hostId = data['hostId'] as String? ?? '';
      final guestId = data['guestId'] as String?;
      if (hostId == _uid) {
        // Host sai: se há guest, promove; senão apaga.
        if (guestId != null && guestId.isNotEmpty) {
          await ref.set({
            'hostId': guestId,
            'hostName': data['guestName'],
            'guestId': null,
            'guestName': null,
            'hostLastWalk': data['guestLastWalk'],
            'guestLastWalk': null,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          await ref.delete();
        }
      } else if (guestId == _uid) {
        await ref.set({
          'guestId': null,
          'guestName': null,
          'guestLastWalk': null,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Falha ao sair da companhia: $e');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    unawaited(_authSub?.cancel());
    super.dispose();
  }
}
