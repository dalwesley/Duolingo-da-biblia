import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'backend_service.dart';

/// Indica um autor que ainda não está no mapa.
/// Coleção: `content_author_suggestions`.
class AuthorSuggestionService {
  AuthorSuggestionService._();
  static final AuthorSuggestionService instance = AuthorSuggestionService._();

  static const collection = 'content_author_suggestions';
  static const minName = 2;
  static const maxName = 80;
  static const maxPhone = 24;
  static const maxEmail = 120;
  static const maxInstagram = 30;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _instagram = RegExp(r'^[a-z0-9._]{1,30}$');

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  static String normalizeName(String value) {
    final t = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.length <= maxName) return t;
    return t.substring(0, maxName);
  }

  static String phoneDigits(String value) => value.replaceAll(RegExp(r'\D'), '');

  static String normalizeEmail(String value) => value.trim().toLowerCase();

  static String normalizeInstagram(String value) {
    var t = value.trim();
    if (t.isEmpty) return '';
    final uri = Uri.tryParse(t.contains('://') ? t : 'https://$t');
    if (uri != null && uri.host.contains('instagram.com')) {
      final segs = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segs.isNotEmpty) t = segs.first;
    }
    if (t.startsWith('@')) t = t.substring(1);
    return t.trim().toLowerCase();
  }

  static bool isValidName(String value) {
    final t = normalizeName(value);
    return t.length >= minName && t.length <= maxName;
  }

  /// Vazio é válido: o telefone é opcional.
  static bool isValidPhone(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return true;
    if (raw.length > maxPhone) return false;
    final digits = phoneDigits(raw);
    return digits.length >= 10 && digits.length <= 15;
  }

  /// Vazio é válido: o e-mail é opcional.
  static bool isValidEmail(String value) {
    final t = normalizeEmail(value);
    if (t.isEmpty) return true;
    return t.length <= maxEmail && _email.hasMatch(t);
  }

  /// Vazio é válido: o Instagram é opcional.
  static bool isValidInstagram(String value) {
    final t = normalizeInstagram(value);
    if (value.trim().isEmpty) return true;
    return _instagram.hasMatch(t);
  }

  static bool hasContact({
    required String phone,
    required String email,
    required String instagram,
  }) {
    return phoneDigits(phone).isNotEmpty ||
        normalizeEmail(email).isNotEmpty ||
        normalizeInstagram(instagram).isNotEmpty;
  }

  static bool isReady({
    required String name,
    required String phone,
    required String email,
    required String instagram,
  }) {
    return isValidName(name) &&
        isValidPhone(phone) &&
        isValidEmail(email) &&
        isValidInstagram(instagram) &&
        hasContact(phone: phone, email: email, instagram: instagram);
  }

  Future<bool> submit({
    required BackendService backend,
    required String name,
    required String phone,
    required String email,
    required String instagram,
  }) async {
    if (!backend.isFirebaseReady) {
      debugPrint('AuthorSuggestionService: Firebase indisponível');
      return false;
    }
    final uid = backend.uid;
    if (uid == null || uid.isEmpty) {
      debugPrint('AuthorSuggestionService: usuário não autenticado');
      return false;
    }
    if (!isReady(name: name, phone: phone, email: email, instagram: instagram)) {
      return false;
    }

    final phoneValue = phoneDigits(phone);
    final emailValue = normalizeEmail(email);
    final instagramValue = normalizeInstagram(instagram);

    try {
      await _db.collection(collection).add({
        'name': normalizeName(name),
        'phone': phoneValue,
        'email': emailValue,
        'instagram': instagramValue,
        'uid': uid,
        if (backend.userEmail != null) 'submitterEmail': backend.userEmail,
        if (backend.userDisplayName != null)
          'submitterName': backend.userDisplayName,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('AuthorSuggestionService submit failed: $e');
      return false;
    }
  }
}
