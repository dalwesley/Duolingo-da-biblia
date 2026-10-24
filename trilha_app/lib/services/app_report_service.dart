import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/app_report.dart';
import 'backend_service.dart';

/// Envia relatos sobre o app (erro, conta, assinatura, sugestão) para o admin.
/// Coleção: `app_reports` — leva versão, plataforma e idioma para reproduzir.
class AppReportService {
  AppReportService._();
  static final AppReportService instance = AppReportService._();

  static const collection = 'app_reports';

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<bool> submit({
    required BackendService backend,
    required AppReportCategory category,
    required String comment,
    required String locale,
  }) async {
    if (!backend.isFirebaseReady) {
      debugPrint('AppReportService: Firebase indisponível');
      return false;
    }
    final uid = backend.uid;
    if (uid == null || uid.isEmpty) {
      debugPrint('AppReportService: usuário não autenticado');
      return false;
    }

    try {
      final info = await PackageInfo.fromPlatform();
      await _db.collection(collection).add({
        'category': category.id,
        'comment': _clip(comment, 800),
        'appVersion': info.version,
        'buildNumber': info.buildNumber,
        'platform': kIsWeb ? 'web' : Platform.operatingSystem,
        if (!kIsWeb) 'osVersion': _clip(Platform.operatingSystemVersion, 120),
        'locale': locale,
        'uid': uid,
        if (backend.userEmail != null) 'email': backend.userEmail,
        if (backend.userDisplayName != null)
          'displayName': backend.userDisplayName,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('AppReportService submit failed: $e');
      return false;
    }
  }

  static String _clip(String value, int max) {
    final t = value.trim();
    if (t.length <= max) return t;
    return t.substring(0, max);
  }
}
