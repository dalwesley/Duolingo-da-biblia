import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Deep links: `stway://companhia/CODIGO` · `stway://sala/CODIGO` · `stway://juntos`
/// · `stway://redeem_web_purchase?…` (Peregrino+ comprado no site)
/// · `stway://passe/CODIGO` (passe de trilha do Peregrino+)
/// Link https do grupo (câmera / WhatsApp): [roomHttpsUrl]
class InviteDeepLinkService extends ChangeNotifier {
  InviteDeepLinkService._();
  static final InviteDeepLinkService instance = InviteDeepLinkService._();

  static const scheme = 'stway';
  static const companionHost = 'companhia';
  static const juntosHost = 'juntos';
  static const roomHost = 'sala';

  /// Link de resgate que o RevenueCat manda depois da compra no site.
  static const webPurchaseHost = 'redeem_web_purchase';

  /// Passe de trilha: alguém com o Peregrino+ liberou uma trilha.
  static const trailGiftHost = 'passe';

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  String? _pendingCompanionCode;
  String? _pendingRoomCode;
  String? _pendingWebPurchaseLink;
  String? _pendingTrailGiftCode;
  bool _wantJuntosTab = false;
  bool _wantCompanhiaTab = false;
  bool _wantGruposTab = false;

  String? get pendingCompanionCode => _pendingCompanionCode;
  String? get pendingRoomCode => _pendingRoomCode;
  String? get pendingTrailGiftCode => _pendingTrailGiftCode;

  /// Link tocável no WhatsApp / QR — convite.
  static String companionUri(String code) =>
      '$scheme://$companionHost/${code.trim().toUpperCase()}';

  /// Abre o app na aba Juntos → Companhia (animar / voltar à caminhada).
  static String juntosUri() => '$scheme://$juntosHost';

  /// Link https clicável no WhatsApp — redireciona para [juntosUri].
  /// Hosting: `admin/public/abrir/juntos/` → Firebase Hosting.
  static const juntosHttpsUrl = 'https://trilha-biblia.web.app/abrir/juntos/';

  /// Página que a câmera abre e redireciona para [roomUri].
  /// Hosting: `site/abrir/sala/` → stway-app.web.app.
  static const roomHttpsBase = 'https://stway-app.web.app/abrir/sala';

  static String roomUri(String code) =>
      '$scheme://$roomHost/${code.trim().toUpperCase()}';

  static String roomHttpsUrl(String code) =>
      '$roomHttpsBase?c=${Uri.encodeQueryComponent(code.trim().toUpperCase())}';

  /// Página do passe (WhatsApp): abre [trailGiftUri] ou leva à loja.
  /// Hosting: `site/abrir/passe/` → stway-app.web.app.
  static const trailGiftHttpsBase = 'https://stway-app.web.app/abrir/passe';

  static String trailGiftUri(String code) =>
      '$scheme://$trailGiftHost/${code.trim().toUpperCase()}';

  static String trailGiftHttpsUrl(String code) =>
      '$trailGiftHttpsBase?c=${Uri.encodeQueryComponent(code.trim().toUpperCase())}';

  /// Código do passe num texto colado: o link dentro da mensagem do
  /// WhatsApp, ou só as 8 letras. Palavra solta não vira código.
  static String? findTrailGiftCode(String? raw) {
    if (raw == null) return null;
    for (final token in raw.split(RegExp(r'\s+'))) {
      final code = extractTrailGiftCode(token);
      if (code != null) return code;
    }
    final plain = raw.trim().toUpperCase();
    // Só o alfabeto do passe (sem 0/O/1/I): "OBRIGADO" não é código.
    return RegExp(r'^[A-HJ-NP-Z2-9]{8}$').hasMatch(plain) ? plain : null;
  }

  /// Código do passe em `stway://passe/CODIGO` ou `https://…/abrir/passe?c=`.
  static String? extractTrailGiftCode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final uri = Uri.tryParse(raw.trim());
    if (uri == null) return null;
    final segs = _segments(uri);
    final query = _query(uri, 'c') ?? _query(uri, 'code');
    if (uri.scheme == scheme) {
      if (uri.host.toLowerCase() == trailGiftHost) {
        return segs.isNotEmpty
            ? _normalizeCode(segs.first)
            : _normalizeCode(query);
      }
      if (segs.length >= 2 && segs.first.toLowerCase() == trailGiftHost) {
        return _normalizeCode(segs[1]);
      }
      return null;
    }
    if (uri.scheme == 'https' || uri.scheme == 'http') {
      final i = segs.indexWhere((s) => s.toLowerCase() == trailGiftHost);
      if (i < 0) return null;
      if (query != null && query.isNotEmpty) return _normalizeCode(query);
      if (i + 1 < segs.length) return _normalizeCode(segs[i + 1]);
    }
    return null;
  }

  /// Bloco padrão pro fim das mensagens de Animar.
  static String openAppFooter() {
    return '''
Abre o Stway:
$juntosHttpsUrl
'''
        .trim();
  }

  /// Extrai código de URI ou texto solto.
  static String? extractCompanionCode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final text = raw.trim();
    final uri = Uri.tryParse(text);
    if (uri != null && uri.scheme == scheme) {
      final host = uri.host.toLowerCase();
      if (host == companionHost || host == 'c' || host == 'companion') {
        final fromPath = _segments(uri);
        if (fromPath.isNotEmpty) {
          return _normalizeCode(fromPath.first);
        }
        final q = _query(uri, 'code') ?? _query(uri, 'c');
        return _normalizeCode(q);
      }
      // stway:///companhia/CODE (path-only)
      final segs = _segments(uri);
      if (segs.length >= 2 &&
          (segs.first.toLowerCase() == companionHost ||
              segs.first.toLowerCase() == 'c')) {
        return _normalizeCode(segs[1]);
      }
    }
    return _normalizeCode(text);
  }

  /// Código de grupo em `stway://sala/CODIGO` ou `https://…/abrir/sala?c=CODIGO`.
  static String? extractRoomCode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final uri = Uri.tryParse(raw.trim());
    if (uri == null) return null;

    if (uri.scheme == scheme) {
      final host = uri.host.toLowerCase();
      if (host == roomHost || host == 'grupo' || host == 'room') {
        return _firstPathCode(uri) ??
            _normalizeCode(_query(uri, 'c') ?? _query(uri, 'code'));
      }
      final segs = _segments(uri);
      if (segs.length >= 2 &&
          (segs.first.toLowerCase() == roomHost ||
              segs.first.toLowerCase() == 'grupo')) {
        return _normalizeCode(segs[1]);
      }
      return null;
    }

    if (uri.scheme == 'https' || uri.scheme == 'http') {
      final segs = _segments(uri);
      final salaIndex = segs.indexWhere((s) => s.toLowerCase() == roomHost);
      if (salaIndex < 0) return null;
      final query = _query(uri, 'c') ?? _query(uri, 'code');
      if (query != null && query.isNotEmpty) return _normalizeCode(query);
      if (salaIndex + 1 < segs.length) {
        return _normalizeCode(segs[salaIndex + 1]);
      }
    }
    return null;
  }

  static String? _firstPathCode(Uri uri) {
    final segs = _segments(uri);
    if (segs.isEmpty) return null;
    return _normalizeCode(segs.first);
  }

  /// `%FF` passa no `Uri.tryParse` mas não decodifica: `pathSegments` e
  /// `queryParameters` jogam FormatException. Link torto = sem código.
  static List<String> _segments(Uri uri) {
    try {
      return uri.pathSegments.where((s) => s.isNotEmpty).toList();
    } on FormatException {
      return const [];
    } on ArgumentError {
      return const [];
    }
  }

  static String? _query(Uri uri, String key) {
    try {
      return uri.queryParameters[key];
    } on FormatException {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  static String? _normalizeCode(String? raw) {
    if (raw == null) return null;
    final match = RegExp(
      r'[A-Z0-9]{4,8}',
      caseSensitive: false,
    ).firstMatch(raw.toUpperCase());
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

  /// Link de fora pode vir torto: nunca derruba o app (era fatal no
  /// Crashlytics — erro no listener do stream não tem quem pegue).
  void _ingestUri(Uri uri) {
    try {
      _ingestUriNow(uri);
    } catch (e) {
      debugPrint('InviteDeepLink ingest: $e');
    }
  }

  void _ingestUriNow(Uri uri) {
    if (uri.scheme == scheme && uri.host.toLowerCase() == webPurchaseHost) {
      _pendingWebPurchaseLink = uri.toString();
      notifyListeners();
      return;
    }
    // Antes do convite de companhia: sem isto `stway://passe/X` virava
    // código de companhia ("STWAY").
    final giftCode = extractTrailGiftCode(uri.toString());
    if (giftCode != null) {
      _pendingTrailGiftCode = giftCode;
      notifyListeners();
      return;
    }
    final roomCode = extractRoomCode(uri.toString());
    if (roomCode != null) {
      offerRoomCode(roomCode);
      return;
    }
    if (uri.scheme != scheme) return;
    final host = uri.host.toLowerCase();
    // stway://juntos  ou  stway:///juntos
    final pathSegs = _segments(uri);
    final pathFirst = pathSegs.isEmpty ? null : pathSegs.first.toLowerCase();
    if (host == juntosHost || pathFirst == juntosHost) {
      _wantJuntosTab = true;
      _wantCompanhiaTab = true;
      notifyListeners();
      return;
    }
    // Widget da home: só abre o app (não é convite).
    if (host == 'hoje' || host == 'home' || pathFirst == 'hoje') {
      return;
    }
    final code = extractCompanionCode(uri.toString());
    if (code == null) return;
    offerCompanionCode(code);
  }

  void offerRoomCode(String code) {
    final normalized = _normalizeCode(code);
    if (normalized == null) return;
    _pendingRoomCode = normalized;
    _wantJuntosTab = true;
    _wantGruposTab = true;
    _wantCompanhiaTab = false;
    notifyListeners();
  }

  void offerCompanionCode(String code) {
    final normalized = _normalizeCode(code);
    if (normalized == null) return;
    _pendingCompanionCode = normalized;
    _wantJuntosTab = true;
    _wantCompanhiaTab = true;
    notifyListeners();
  }

  /// MainShell consome o pedido de abrir a aba Juntos.
  bool takeWantJuntosTab() {
    if (!_wantJuntosTab) return false;
    _wantJuntosTab = false;
    return true;
  }

  /// LeagueScreen consome o pedido de ir em Grupos.
  bool takeWantGruposTab() {
    if (!_wantGruposTab) return false;
    _wantGruposTab = false;
    return true;
  }

  /// LeagueScreen consome o pedido de ir em Companhia.
  bool takeWantCompanhiaTab() {
    if (!_wantCompanhiaTab) return false;
    _wantCompanhiaTab = false;
    return true;
  }

  /// LeagueScreen consome o código de grupo pendente (uma vez).
  String? takePendingRoomCode() {
    final code = _pendingRoomCode;
    _pendingRoomCode = null;
    return code;
  }

  /// MainShell consome o link de resgate da compra no site (uma vez).
  String? takePendingWebPurchaseLink() {
    final link = _pendingWebPurchaseLink;
    _pendingWebPurchaseLink = null;
    return link;
  }

  /// MainShell consome o passe de trilha pendente (uma vez).
  String? takePendingTrailGiftCode() {
    final code = _pendingTrailGiftCode;
    _pendingTrailGiftCode = null;
    return code;
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
