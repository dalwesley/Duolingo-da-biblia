import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backend_service.dart';

/// Motivo de uma denúncia. O id vai para o Firestore e para o painel admin.
enum UserReportReason {
  offensiveName('offensive_name'),
  offensivePhoto('offensive_photo'),
  harassment('harassment'),
  spam('spam'),
  other('other');

  final String id;
  const UserReportReason(this.id);
}

/// Onde a pessoa foi vista ao ser denunciada — ajuda a moderação a achar.
enum UserReportSource {
  ranking('ranking'),
  recognition('recognition'),
  roomInvite('room_invite'),
  room('room'),
  corner('corner'),
  companion('companion');

  final String id;
  const UserReportSource(this.id);
}

/// Denunciar e bloquear outros peregrinos (App Store 1.2).
///
/// Bloqueios moram em `users/{uid}/blocks/{blockedUid}` — só o dono lê.
/// As regras do Firestore usam esses docs para recusar convite,
/// reconhecimento, desafio e chamado vindos de quem foi bloqueado.
/// Denúncias vão para `user_reports` e aparecem em Relatos no painel.
class ModerationService extends ChangeNotifier {
  ModerationService._();
  static final ModerationService instance = ModerationService._();

  static const reportsCollection = 'user_reports';
  static const _cacheKey = 'moderationBlocked';

  /// uid → nome no momento do bloqueio (para a lista em Ajustes).
  Map<String, String> _blocked = {};
  String? _boundUid;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Map<String, String> get blocked => Map.unmodifiable(_blocked);

  bool isBlocked(String? uid) =>
      uid != null && uid.isNotEmpty && _blocked.containsKey(uid);

  /// Liga à sessão. Chamado a cada notify do [BackendService]; só recarrega
  /// quando a conta muda.
  Future<void> syncBinding(BackendService backend) async {
    final uid = backend.isActive ? backend.uid : null;
    if (uid == _boundUid) return;
    _boundUid = uid;
    if (uid == null) {
      if (_blocked.isNotEmpty) {
        _blocked = {};
        notifyListeners();
      }
      return;
    }
    await _loadCache(uid);
    try {
      final snap = await _db
          .collection('users/$uid/blocks')
          .get()
          .timeout(const Duration(seconds: 10));
      if (_boundUid != uid) return;
      _blocked = {
        for (final d in snap.docs) d.id: (d.data()['name'] as String?) ?? '',
      };
      notifyListeners();
      unawaited(_saveCache(uid));
    } catch (e) {
      debugPrint('ModerationService: falha ao ler bloqueios: $e');
    }
  }

  Future<bool> block({required String uid, required String name}) async {
    final me = _boundUid;
    if (me == null || uid.isEmpty || uid == me) return false;
    try {
      await _db.doc('users/$me/blocks/$uid').set({
        'name': _clip(name, 120),
        'createdAt': FieldValue.serverTimestamp(),
      });
      _blocked = {..._blocked, uid: name};
      notifyListeners();
      unawaited(_saveCache(me));
      return true;
    } catch (e) {
      debugPrint('ModerationService: falha ao bloquear: $e');
      return false;
    }
  }

  Future<bool> unblock(String uid) async {
    final me = _boundUid;
    if (me == null) return false;
    try {
      await _db.doc('users/$me/blocks/$uid').delete();
      _blocked = {..._blocked}..remove(uid);
      notifyListeners();
      unawaited(_saveCache(me));
      return true;
    } catch (e) {
      debugPrint('ModerationService: falha ao desbloquear: $e');
      return false;
    }
  }

  Future<bool> report({
    required BackendService backend,
    required String targetUid,
    required String targetName,
    required UserReportReason reason,
    required UserReportSource source,
    String comment = '',
    String? roomCode,
    String? roomName,
  }) async {
    final me = backend.uid;
    if (!backend.isActive || me == null || targetUid == me) return false;
    try {
      await _db.collection(reportsCollection).add({
        'reporterUid': me,
        'targetUid': targetUid,
        'targetName': _clip(targetName, 120),
        'reason': reason.id,
        'source': source.id,
        'comment': _clip(comment, 800),
        if (roomCode != null && roomCode.isNotEmpty) 'roomCode': roomCode,
        if (roomName != null && roomName.isNotEmpty)
          'roomName': _clip(roomName, 40),
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('ModerationService: falha ao denunciar: $e');
      return false;
    }
  }

  Future<void> _loadCache(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_cacheKey.$uid');
      if (raw == null) return;
      final data = jsonDecode(raw);
      if (data is! Map || _boundUid != uid) return;
      _blocked = {for (final e in data.entries) '${e.key}': '${e.value}'};
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveCache(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_cacheKey.$uid', jsonEncode(_blocked));
    } catch (_) {}
  }

  static String _clip(String value, int max) {
    final t = value.trim();
    return t.length <= max ? t : t.substring(0, max);
  }
}
