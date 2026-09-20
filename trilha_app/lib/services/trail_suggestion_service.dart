import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'backend_service.dart';

/// Caminho pedido no mapa — os 4 reinos + catch-all.
enum TrailSuggestionRealm {
  antigoTestamento,
  novoTestamento,
  vidaCrista,
  teologia,
  outros;

  String get id => switch (this) {
        antigoTestamento => 'antigo-testamento',
        novoTestamento => 'novo-testamento',
        vidaCrista => 'vida-crista',
        teologia => 'teologia',
        outros => 'outros',
      };

  String get label => switch (this) {
        antigoTestamento => 'Antigo Testamento',
        novoTestamento => 'Novo Testamento',
        vidaCrista => 'Vida Cristã',
        teologia => 'Teologia',
        outros => 'Outros',
      };

  String get hint => switch (this) {
        antigoTestamento => 'Ex.: Salmos, Êxodo, os profetas…',
        novoTestamento => 'Ex.: o Sermão do Monte, Romanos, Atos…',
        vidaCrista => 'Ex.: oração, jejum, a história da igreja…',
        teologia => 'Ex.: Trindade, hermenêutica, hebraico…',
        outros => 'Ex.: um tema, um livro ou uma pergunta que ainda falta…',
      };

  static TrailSuggestionRealm? fromId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final realm in values) {
      if (realm.id == id) return realm;
    }
    return null;
  }
}

/// Envia ideias de novas trilhas para o mapa.
/// Coleção: `content_trail_suggestions`.
class TrailSuggestionService {
  TrailSuggestionService._();
  static final TrailSuggestionService instance = TrailSuggestionService._();

  static const collection = 'content_trail_suggestions';
  static const minText = 4;
  static const maxText = 400;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  static String normalize(String value) {
    final t = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.length <= maxText) return t;
    return t.substring(0, maxText);
  }

  static bool isValidText(String value) {
    final t = normalize(value);
    return t.length >= minText && t.length <= maxText;
  }

  static bool isValidRealmId(String? realmId) {
    return TrailSuggestionRealm.fromId(realmId) != null;
  }

  Future<bool> submit({
    required BackendService backend,
    required String text,
    required String realmId,
  }) async {
    if (!backend.isFirebaseReady) {
      debugPrint('TrailSuggestionService: Firebase indisponível');
      return false;
    }
    final uid = backend.uid;
    if (uid == null || uid.isEmpty) {
      debugPrint('TrailSuggestionService: usuário não autenticado');
      return false;
    }

    final body = normalize(text);
    if (!isValidText(body) || !isValidRealmId(realmId)) return false;

    try {
      await _db.collection(collection).add({
        'text': body,
        'realmId': realmId,
        'uid': uid,
        if (backend.userEmail != null) 'email': backend.userEmail,
        if (backend.userDisplayName != null)
          'displayName': backend.userDisplayName,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('TrailSuggestionService submit failed: $e');
      return false;
    }
  }
}
