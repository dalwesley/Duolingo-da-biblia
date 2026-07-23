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

/// Resultado de uma tentativa de login com Google.
class GoogleSignInResult {
  final bool ok;
  final String? error;
  final String? displayName;
  final String? email;

  const GoogleSignInResult({
    required this.ok,
    this.error,
    this.displayName,
    this.email,
  });
}

/// Backend Firebase. Quando configurado, ativa:
///   - login obrigatório com Google
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

  bool get isActive => _available && _uid != null;
  bool get isFirebaseReady => _firebaseReady;
  bool get isInitializing => _initializing;
  bool get isGoogleBusy => _googleBusy;
  String? get uid => _uid;

  User? get currentUser =>
      _firebaseReady ? FirebaseAuth.instance.currentUser : null;

  bool get isGoogleSignedIn {
    final user = currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'google.com');
  }

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
    await _google.initialize(
      serverClientId: DefaultFirebaseOptions.googleWebClientId,
    );
    _googleInitialized = true;
  }

  /// Login com Google. Se já houver sessão anônima, tenta vincular a conta
  /// (preserva o uid). Se a conta Google já existir, entra nela.
  Future<GoogleSignInResult> signInWithGoogle() async {
    if (!_firebaseReady) {
      await init();
      if (!_firebaseReady) {
        return GoogleSignInResult(
          ok: false,
          error: lastError ?? 'Firebase ainda não está pronto.',
        );
      }
    }

    _googleBusy = true;
    lastError = null;
    notifyListeners();

    try {
      await _ensureGoogleSignInInitialized();
      final googleUser = await _google.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        return const GoogleSignInResult(
          ok: false,
          error:
              'Google não retornou idToken. Confira se o provedor Google está ativo no Firebase e se o SHA-1 do app está cadastrado.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final auth = FirebaseAuth.instance;
      final current = auth.currentUser;
      UserCredential cred;

      if (current != null && current.isAnonymous) {
        try {
          cred = await current.linkWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use' ||
              e.code == 'email-already-in-use') {
            // Conta Google já existe: troca para ela.
            await _google.signOut();
            cred = await auth.signInWithCredential(credential);
          } else {
            rethrow;
          }
        }
      } else {
        cred = await auth.signInWithCredential(credential);
      }

      _applyUser(cred.user);
      notifyListeners();
      return GoogleSignInResult(
        ok: true,
        displayName: cred.user?.displayName ?? googleUser.displayName,
        email: cred.user?.email ?? googleUser.email,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const GoogleSignInResult(ok: false, error: 'Login cancelado.');
      }
      lastError = 'Google Sign-In: ${e.description ?? e.code.name}';
      return GoogleSignInResult(ok: false, error: lastError);
    } on FirebaseAuthException catch (e) {
      lastError = _authErrorMessage(e);
      debugPrint('Google Auth falhou: ${e.code} — ${e.message}');
      return GoogleSignInResult(ok: false, error: lastError);
    } catch (e) {
      lastError = e.toString();
      debugPrint('Google Sign-In falhou: $e');
      return GoogleSignInResult(ok: false, error: lastError);
    } finally {
      _googleBusy = false;
      notifyListeners();
    }
  }

  /// Sai do Google e encerra a sessão (volta à tela de login).
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
    if (!isActive) return false;
    try {
      final batch = _db.batch();
      batch.set(
        _db.doc('users/$_uid'),
        _payload(progress, league: league),
        SetOptions(merge: true),
      );
      batch.set(_db.doc('leagues/$week/players/$_uid'), {
        'name': progress.userName,
        'xp': progress.weeklySteps,
        'updatedAt': FieldValue.serverTimestamp(),
      });
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
      if (roomCode != null && roomCode.isNotEmpty) {
        batch.set(_db.doc('rooms/$roomCode/members/$_uid'), {
          'name': progress.userName,
          'xp': progress.weeklySteps,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      await batch.commit();
      lastCloudSaveAt = DateTime.now();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Falha ao salvar na nuvem: $e');
      return false;
    }
  }

  /// Carrega o progresso do Firebase (fonte da verdade) para a memória da sessão.
  /// Se a nuvem estiver vazia, tenta migrar dados legados do aparelho uma vez.
  /// Retorna true se havia documento na nuvem.
  Future<bool> hydrateProgress(
    ProgressService progress, {
    LeagueService? league,
  }) async {
    if (!isActive) return false;
    try {
      final data = await fetchBackup();
      if (data != null) {
        await progress.applyFromCloud(data);
        if (league != null) await league.applyFromCloud(data);
        await progress.clearLegacyLocalPrefs();
        return true;
      }
      final legacy = await progress.readLegacyLocalSnapshot();
      if (legacy != null) {
        await progress.applyFromCloud(legacy);
      }
      return false;
    } catch (e) {
      debugPrint('Falha ao hidratar progresso: $e');
      return false;
    }
  }

  /// Agenda um backup (chamado a cada mudança de progresso; agrupa rajadas).
  void scheduleSave(
    ProgressService progress,
    String week, {
    String? roomCode,
    LeagueService? league,
  }) {
    if (!isActive) return;
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
        final existing = await ref.get();
        if (existing.exists) continue;

        await ref.set({
          'name': trimmed,
          'ownerId': _uid,
          'ownerName': userName,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await ref.collection('members').doc(_uid).set({
          'name': userName,
          'xp': weeklySteps,
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
  Future<Map<String, dynamic>?> fetchBackup() async {
    if (!isActive) return null;
    try {
      final doc = await _db.doc('users/$_uid').get();
      return doc.data();
    } catch (e) {
      debugPrint('Falha ao restaurar da nuvem: $e');
      return null;
    }
  }

  /// Jogadores reais da liga desta semana (exclui o próprio usuário).
  Future<List<CloudPlayer>> fetchWeekPlayers(String week, {int limit = 30}) async {
    if (!isActive) return const [];
    try {
      final snap = await _db
          .collection('leagues/$week/players')
          .orderBy('xp', descending: true)
          .limit(limit)
          .get();
      return [
        for (final d in snap.docs)
          if (d.id != _uid)
            CloudPlayer(
              uid: d.id,
              name: (d.data()['name'] as String?)?.trim().isNotEmpty == true
                  ? d.data()['name'] as String
                  : 'Aprendiz',
              steps: (d.data()['xp'] as num?)?.toInt() ?? 0,
            ),
      ];
    } catch (e) {
      debugPrint('Falha ao buscar liga na nuvem: $e');
      return const [];
    }
  }

  /// Jogadores reais do ranking geral (exclui o próprio usuário).
  Future<List<CloudPlayer>> fetchOverallPlayers({int limit = 30}) async {
    if (!isActive) return const [];
    try {
      final snap = await _db
          .collection('overallPlayers')
          .orderBy('xp', descending: true)
          .limit(limit)
          .get();
      return [
        for (final d in snap.docs)
          if (d.id != _uid)
            CloudPlayer(
              uid: d.id,
              name: (d.data()['name'] as String?)?.trim().isNotEmpty == true
                  ? d.data()['name'] as String
                  : 'Aprendiz',
              steps: (d.data()['xp'] as num?)?.toInt() ?? 0,
            ),
      ];
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
        final existing = await ref.get();
        if (existing.exists) continue;
        await ref.set({
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
      final doc = await ref.get();
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      final hostId = data['hostId'] as String? ?? '';
      if (hostId == _uid) {
        return _companionFromDoc(normalized, data);
      }
      final guestId = data['guestId'] as String?;
      if (guestId != null && guestId.isNotEmpty && guestId != _uid) {
        return null; // já tem parceiro
      }
      await ref.set({
        'guestId': _uid,
        'guestName': userName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      final refreshed = await ref.get();
      return _companionFromDoc(normalized, refreshed.data() ?? data);
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
        final doc = await ref.get();
        if (!doc.exists || doc.data() == null) continue;
        final data = Map<String, dynamic>.from(doc.data()!);
        final hostId = data['hostId'] as String? ?? '';
        final guestId = data['guestId'] as String?;
        final isHost = hostId == _uid;
        if (!isHost && guestId != _uid) continue;

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
        await ref.set(updates, SetOptions(merge: true));
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
    super.dispose();
  }
}
