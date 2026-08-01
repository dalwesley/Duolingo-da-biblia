import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Deep links de convite: `stway://companhia/CODIGO`
class InviteDeepLinkService extends ChangeNotifier {
  InviteDeepLinkService._();
  static final InviteDeepLinkService instance = InviteDeepLinkService._();

  static const scheme = 'stway';
  static const companionHost = 'companhia';

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  String? _pendingCompanionCode;
  bool _wantJuntosTab = false;

  String? get pendingCompanionCode => _pendingCompanionCode;
  bool get wantJuntosTab => _wantJuntosTab;

  /// Link tocável no WhatsApp / QR.
  static String companionUri(String code) =>
      '$scheme://$companionHost/${code.trim().toUpperCase()}';

  /// Extrai código de URI ou texto solto.
  static String? extractCompanionCode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final text = raw.trim();
    final uri = Uri.tryParse(text);
    if (uri != null && uri.scheme == scheme) {
      final host = uri.host.toLowerCase();
      if (host == companionHost || host == 'c' || host == 'companion') {
        final fromPath = uri.pathSegments.where((s) => s.isNotEmpty).toList();
        if (fromPath.isNotEmpty) {
          return _normalizeCode(fromPath.first);
        }
        final q = uri.queryParameters['code'] ?? uri.queryParameters['c'];
        return _normalizeCode(q);
      }
      // stway:///companhia/CODE (path-only)
      final segs = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segs.length >= 2 &&
          (segs.first.toLowerCase() == companionHost ||
              segs.first.toLowerCase() == 'c')) {
        return _normalizeCode(segs[1]);
      }
    }
    return _normalizeCode(text);
  }

  static String? _normalizeCode(String? raw) {
    if (raw == null) return null;
    final match = RegExp(r'[A-Z0-9]{4,8}', caseSensitive: false)
        .firstMatch(raw.toUpperCase());
    return match?.group(0);
  }

  Future<void> init() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _ingestUri(initial);
    } catch (e) {
      debugPrint('InviteDeepLink initial: $e');
    }
    _sub = _appLinks.uriLinkStream.listen(
      _ingestUri,
      onError: (e) => debugPrint('InviteDeepLink stream: $e'),
    );
  }

  void _ingestUri(Uri uri) {
    final code = extractCompanionCode(uri.toString());
    if (code == null) return;
    offerCompanionCode(code);
  }

  void offerCompanionCode(String code) {
    final normalized = _normalizeCode(code);
    if (normalized == null) return;
    _pendingCompanionCode = normalized;
    _wantJuntosTab = true;
    notifyListeners();
  }

  /// MainShell consome o pedido de abrir a aba Juntos.
  bool takeWantJuntosTab() {
    if (!_wantJuntosTab) return false;
    _wantJuntosTab = false;
    return true;
  }

  /// LeagueScreen consome o código pendente (uma vez).
  String? takePendingCompanionCode() {
    final code = _pendingCompanionCode;
    _pendingCompanionCode = null;
    return code;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
