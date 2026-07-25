import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Severidade do update remoto.
enum AppUpdateKind { none, soft, force }

/// Resultado de [AppUpdateService.check].
class AppUpdateStatus {
  final AppUpdateKind kind;
  final String localVersion;
  final int localBuild;
  final String? latestVersion;
  final int? latestBuild;
  final String message;
  final String storeUrl;
  final bool remoteReachable;

  const AppUpdateStatus({
    required this.kind,
    required this.localVersion,
    required this.localBuild,
    this.latestVersion,
    this.latestBuild,
    required this.message,
    required this.storeUrl,
    this.remoteReachable = true,
  });

  bool get updateAvailable =>
      kind == AppUpdateKind.soft || kind == AppUpdateKind.force;

  String get localLabel => '$localVersion ($localBuild)';

  String get latestLabel {
    final v = latestVersion;
    final b = latestBuild;
    if (v == null && b == null) return '—';
    if (v != null && b != null) return '$v ($b)';
    return v ?? '$b';
  }
}

/// Lê `content_meta/app_release` e compara com o build local.
///
/// Campos no Firestore:
/// - `latestVersion` (string) — ex. "1.0.3"
/// - `latestBuild` (int) — versionCode / CFBundleVersion
/// - `minBuild` (int) — abaixo disso = update obrigatório
/// - `androidStoreUrl` / `iosStoreUrl` (string)
/// - `message` (string)
/// - `enabled` (bool, default true)
class AppUpdateService {
  AppUpdateService._();

  static const _docPath = 'content_meta/app_release';
  static const _snoozeKey = 'app_update_snooze_until_ms';
  static const _snoozeDays = 3;

  static const _androidStoreDefault =
      'https://play.google.com/store/apps/details?id=com.trilha.trilha_app';
  static const _iosStoreDefault =
      'https://apps.apple.com/br/search?term=STWAY';

  static const _defaultMessage =
      'Uma nova versão do STWAY está pronta — melhorias e correções te esperam.';

  /// Uma vez por sessão (soft auto-check).
  static bool _sessionPromptShown = false;

  static Future<AppUpdateStatus> check({bool ignoreSnooze = false}) async {
    final info = await PackageInfo.fromPlatform();
    final localVersion = info.version;
    final localBuild = int.tryParse(info.buildNumber) ?? 0;
    final storeUrl = _defaultStoreUrl();

    if (Firebase.apps.isEmpty) {
      return AppUpdateStatus(
        kind: AppUpdateKind.none,
        localVersion: localVersion,
        localBuild: localBuild,
        message: 'Firebase indisponível.',
        storeUrl: storeUrl,
        remoteReachable: false,
      );
    }

    try {
      final snap = await FirebaseFirestore.instance.doc(_docPath).get();
      if (!snap.exists) {
        return AppUpdateStatus(
          kind: AppUpdateKind.none,
          localVersion: localVersion,
          localBuild: localBuild,
          message: 'Nenhuma versão publicada na nuvem.',
          storeUrl: storeUrl,
          remoteReachable: true,
        );
      }

      final data = snap.data() ?? const <String, dynamic>{};
      final enabled = data['enabled'] != false;
      if (!enabled) {
        return AppUpdateStatus(
          kind: AppUpdateKind.none,
          localVersion: localVersion,
          localBuild: localBuild,
          latestVersion: data['latestVersion'] as String?,
          latestBuild: (data['latestBuild'] as num?)?.toInt(),
          message: 'Checagem desligada.',
          storeUrl: _storeUrlFrom(data) ?? storeUrl,
        );
      }

      final latestBuild = (data['latestBuild'] as num?)?.toInt() ?? 0;
      final minBuild = (data['minBuild'] as num?)?.toInt() ?? 0;
      final latestVersion = data['latestVersion'] as String? ?? '';
      final message = (data['message'] as String?)?.trim().isNotEmpty == true
          ? (data['message'] as String).trim()
          : _defaultMessage;
      final url = _storeUrlFrom(data) ?? storeUrl;

      AppUpdateKind kind = AppUpdateKind.none;
      if (minBuild > 0 && localBuild < minBuild) {
        kind = AppUpdateKind.force;
      } else if (latestBuild > 0 && localBuild < latestBuild) {
        kind = AppUpdateKind.soft;
      }

      if (kind == AppUpdateKind.soft && !ignoreSnooze) {
        if (await _isSnoozed()) {
          kind = AppUpdateKind.none;
        }
      }

      return AppUpdateStatus(
        kind: kind,
        localVersion: localVersion,
        localBuild: localBuild,
        latestVersion: latestVersion.isEmpty ? null : latestVersion,
        latestBuild: latestBuild > 0 ? latestBuild : null,
        message: message,
        storeUrl: url,
      );
    } catch (e, st) {
      debugPrint('AppUpdateService.check failed: $e\n$st');
      return AppUpdateStatus(
        kind: AppUpdateKind.none,
        localVersion: localVersion,
        localBuild: localBuild,
        message: 'Não foi possível verificar agora.',
        storeUrl: storeUrl,
        remoteReachable: false,
      );
    }
  }

  /// Soft update automático — no máximo 1× por sessão e respeita snooze.
  static Future<AppUpdateStatus?> checkForPrompt() async {
    if (_sessionPromptShown) return null;
    final status = await check();
    if (!status.updateAvailable) return null;
    _sessionPromptShown = true;
    return status;
  }

  static Future<void> snoozeSoftPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final until = DateTime.now()
        .add(const Duration(days: _snoozeDays))
        .millisecondsSinceEpoch;
    await prefs.setInt(_snoozeKey, until);
  }

  static Future<bool> openStore(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    if (!kIsWeb && Platform.isAndroid) {
      final id = uri.queryParameters['id'];
      if (id != null && id.isNotEmpty) {
        final market = Uri.parse('market://details?id=$id');
        if (await canLaunchUrl(market)) {
          return launchUrl(market, mode: LaunchMode.externalApplication);
        }
      }
    }

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static Future<bool> _isSnoozed() async {
    final prefs = await SharedPreferences.getInstance();
    final until = prefs.getInt(_snoozeKey);
    if (until == null) return false;
    return DateTime.now().millisecondsSinceEpoch < until;
  }

  static String _defaultStoreUrl() {
    if (!kIsWeb && Platform.isIOS) return _iosStoreDefault;
    return _androidStoreDefault;
  }

  static String? _storeUrlFrom(Map<String, dynamic> data) {
    final key = (!kIsWeb && Platform.isIOS) ? 'iosStoreUrl' : 'androidStoreUrl';
    final raw = (data[key] as String?)?.trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }
}
