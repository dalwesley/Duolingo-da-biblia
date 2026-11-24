import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart'
    show ITunesSearchAPI, ITunesResults, PlayStoreSearchAPI, PlayStoreResults;
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n_global.dart';

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

/// Compara a versão instalada com a versão publicada na loja (Play Store /
/// App Store, via `upgrader`). Nada para editar no painel a cada release.
///
/// `content_meta/app_release` continua opcional, só para casos raros:
/// - `minBuild` (int) — abaixo disso = update obrigatório
/// - `enabled` (bool, default true) — `false` desliga a checagem
/// - `message` (string) — texto da sheet
class AppUpdateService {
  AppUpdateService._();

  static const _docPath = 'content_meta/app_release';
  static const _snoozeKey = 'app_update_snooze_until_ms';
  static const _snoozeDays = 3;
  static const _storeCountry = 'BR';
  static const _storeLanguage = 'pt';
  static const _timeout = Duration(seconds: 8);

  static const androidStoreUrl =
      'https://play.google.com/store/apps/details?id=com.trilha.trilha_app';
  static const iosStoreUrl = 'https://apps.apple.com/br/app/stway/id6801332526';

  static String get _defaultMessage => L10n.current.updateDefaultMessage;

  /// Uma vez por sessão (soft auto-check).
  static bool _sessionPromptShown = false;

  /// O aviso de atualização já apareceu nesta sessão (outras folhas cedem).
  static bool get promptShownThisSession => _sessionPromptShown;

  /// `flutter run --dart-define=FORCE_UPDATE_PROMPT=true` — prévia da sheet
  /// 1×/sessão, mesmo com o build local à frente da loja.
  static const forceUpdatePrompt = bool.fromEnvironment(
    'FORCE_UPDATE_PROMPT',
    defaultValue: false,
  );

  /// Soft só quando a loja tem versão maior. Abaixo de [minBuild], obrigatório.
  /// [preview] existe só para o dart-define acima — debug comum não força.
  static AppUpdateKind resolveKind({
    required String localVersion,
    required String? storeVersion,
    required int localBuild,
    required int minBuild,
    bool preview = false,
  }) {
    if (minBuild > 0 && localBuild < minBuild) return AppUpdateKind.force;
    final store = storeVersion?.trim() ?? '';
    if (store.isEmpty) return AppUpdateKind.none;
    if (compareVersions(localVersion, store) < 0) return AppUpdateKind.soft;
    if (preview) return AppUpdateKind.soft;
    return AppUpdateKind.none;
  }

  /// Compara "1.0.49" com "1.0.50" número a número. Negativo = [a] menor.
  /// Partes não numéricas (ex. "1.0.49-beta") contam só os dígitos iniciais.
  static int compareVersions(String a, String b) {
    List<int> parts(String v) => v
        .split('+')
        .first
        .split('.')
        .map((p) => int.tryParse(RegExp(r'^\d+').stringMatch(p) ?? '') ?? 0)
        .toList();
    final pa = parts(a);
    final pb = parts(b);
    final n = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < n; i++) {
      final x = i < pa.length ? pa[i] : 0;
      final y = i < pb.length ? pb[i] : 0;
      if (x != y) return x.compareTo(y);
    }
    return 0;
  }

  static Future<AppUpdateStatus> check({bool ignoreSnooze = false}) async {
    final info = await PackageInfo.fromPlatform();
    final localVersion = info.version;
    final localBuild = int.tryParse(info.buildNumber) ?? 0;
    final defaultUrl = _defaultStoreUrl();

    final results = await Future.wait([
      _storeLookup(info.packageName),
      _remoteConfig(),
    ]);
    final store = results[0] as _StoreLookup?;
    final remote = results[1] as Map<String, dynamic>?;

    final storeUrl = store?.url ?? defaultUrl;
    final message = (remote?['message'] as String?)?.trim().isNotEmpty == true
        ? (remote!['message'] as String).trim()
        : _defaultMessage;

    if (remote?['enabled'] == false) {
      return AppUpdateStatus(
        kind: AppUpdateKind.none,
        localVersion: localVersion,
        localBuild: localBuild,
        latestVersion: store?.version,
        message: L10n.current.updateCheckDisabled,
        storeUrl: storeUrl,
      );
    }

    final minBuild = (remote?['minBuild'] as num?)?.toInt() ?? 0;
    var storeVersion = store?.version;
    if (forceUpdatePrompt && (storeVersion == null || storeVersion.isEmpty)) {
      storeVersion = localVersion;
    }

    var kind = resolveKind(
      localVersion: localVersion,
      storeVersion: storeVersion,
      localBuild: localBuild,
      minBuild: minBuild,
      preview: forceUpdatePrompt,
    );
    final skipSnooze = ignoreSnooze || forceUpdatePrompt;
    if (kind == AppUpdateKind.soft && !skipSnooze && await _isSnoozed()) {
      kind = AppUpdateKind.none;
    }

    if (store == null && kind == AppUpdateKind.none) {
      return AppUpdateStatus(
        kind: kind,
        localVersion: localVersion,
        localBuild: localBuild,
        message: L10n.current.updateCheckFailed,
        storeUrl: storeUrl,
        remoteReachable: false,
      );
    }

    return AppUpdateStatus(
      kind: kind,
      localVersion: localVersion,
      localBuild: localBuild,
      latestVersion: storeVersion,
      message: message,
      storeUrl: storeUrl,
    );
  }

  /// Versão publicada na loja da plataforma. `null` se não deu para ler.
  static Future<_StoreLookup?> _storeLookup(String packageName) async {
    if (kIsWeb || packageName.isEmpty) return null;
    try {
      if (Platform.isAndroid) {
        final api = PlayStoreSearchAPI();
        final doc = await api
            .lookupById(
              packageName,
              country: _storeCountry,
              language: _storeLanguage,
            )
            .timeout(_timeout);
        if (doc == null) return null;
        final v = api.version(doc);
        if (v == null || v.isEmpty) return null;
        return _StoreLookup(v, androidStoreUrl);
      }
      if (Platform.isIOS) {
        final api = ITunesSearchAPI();
        final res = await api
            .lookupByBundleId(
              packageName,
              country: _storeCountry,
              language: _storeLanguage,
            )
            .timeout(_timeout);
        if (res == null) return null;
        final v = api.version(res);
        if (v == null || v.isEmpty) return null;
        final url = api.trackViewUrl(res);
        return _StoreLookup(v, url?.isNotEmpty == true ? url! : iosStoreUrl);
      }
    } catch (e, st) {
      debugPrint('AppUpdateService store lookup failed: $e\n$st');
    }
    return null;
  }

  /// `content_meta/app_release` (opcional). `null` se ausente/inacessível.
  static Future<Map<String, dynamic>?> _remoteConfig() async {
    if (Firebase.apps.isEmpty) return null;
    try {
      final snap = await FirebaseFirestore.instance
          .doc(_docPath)
          .get()
          .timeout(_timeout);
      return snap.data();
    } catch (e) {
      debugPrint('AppUpdateService remote config failed: $e');
      return null;
    }
  }

  /// Soft update automático — no máximo 1× por sessão e respeita snooze
  /// (exceto com FORCE_UPDATE_PROMPT).
  static Future<AppUpdateStatus?> checkForPrompt() async {
    if (_sessionPromptShown) return null;
    final status = await check(ignoreSnooze: forceUpdatePrompt);
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
    if (!kIsWeb && Platform.isIOS) return iosStoreUrl;
    return androidStoreUrl;
  }
}

class _StoreLookup {
  final String version;
  final String url;
  const _StoreLookup(this.version, this.url);
}
