import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n_global.dart';
import 'analytics_service.dart';
import 'notification_service.dart';
import 'remote_config_service.dart';

/// Assinatura "Peregrino+" via RevenueCat.
///
/// Sem chave de API configurada (`_apiKeyAndroid`/`_apiKeyIos` vazias), o SDK
/// nunca é inicializado e [isPeregrinoPlus] fica sempre `false` — o app
/// funciona normalmente sem nenhuma conta RevenueCat criada. Criar a conta,
/// os produtos na App Store Connect/Play Console e preencher as chaves é um
/// passo manual fora deste código.
///
/// Recursos do Peregrino+ checam [hasPlus], nunca [isPeregrinoPlus]: durante
/// o lançamento (`plus_launch_free_until` no Remote Config) todos têm acesso.
class SubscriptionService extends ChangeNotifier {
  SubscriptionService() {
    RemoteConfigService.instance.addListener(notifyListeners);
    if (kDebugMode) unawaited(_debugRestore());
  }

  static const _entitlementId = 'peregrino_plus';

  /// Oferta da RevenueCat com as compras avulsas de apoio (consumíveis).
  static const supportOfferingId = 'apoio';
  static const _supportProductPrefix = 'apoio';

  // Preencher ao criar o projeto no dashboard da RevenueCat.
  static const _apiKeyAndroid = '';
  static const _apiKeyIos = '';

  bool isPeregrinoPlus = false;

  /// Já fez alguma compra de apoio (não libera nada, só o selo).
  bool isSupporter = false;

  /// Assinatura ativa — para "Seu plano" e "Gerenciar assinatura".
  String? plusProductId;
  DateTime? plusExpiresAt;
  bool plusWillRenew = false;
  bool plusInTrial = false;
  bool plusBillingIssue = false;

  /// Link da loja para mudar de plano ou cancelar (RevenueCat).
  String? managementUrl;
  List<Package> availablePackages = const [];
  List<Package> supportPackages = const [];

  /// Chamado quando o selo de apoiador muda (perfil público).
  void Function(bool hasBadge)? onBadgeChanged;
  bool loading = false;
  String? lastError;
  bool _initialized = false;
  String? _boundUid;

  /// Último dia da promoção de lançamento, se ela ainda vale hoje.
  DateTime? get launchFreeUntil {
    final until = launchPromoDate;
    if (until == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.isAfter(until) ? null : until;
  }

  bool get launchPromoActive => launchFreeUntil != null;

  /// Último dia da promoção no Remote Config, mesmo que já tenha passado.
  DateTime? get launchPromoDate => _debugPromoOverride
      ? _debugPromoUntil
      : RemoteConfigService.instance.plusLaunchFreeUntil;

  /// Acesso aos recursos do Peregrino+: assinatura ou promoção de lançamento.
  bool get hasPlus => isPeregrinoPlus || launchPromoActive;

  /// Selo de apoiador: quem paga o Peregrino+ ou já apoiou. A promoção de
  /// lançamento não dá selo.
  bool get hasBadge => isPeregrinoPlus || isSupporter;

  /// Apoio avulso disponível na loja.
  bool get supportConfigured => isConfigured && supportPackages.isNotEmpty;

  /// Recursos do Peregrino+ abertos: com assinatura/promoção, ou enquanto
  /// não há como comprar (sem loja e sem promoção) — nada trava sem saída.
  bool get plusFeaturesOpen => hasPlus || !showsPlus;

  /// Há algo do Peregrino+ para mostrar (loja configurada ou promoção).
  bool get showsPlus => isConfigured || launchPromoActive;

  bool get isConfigured =>
      _debugFakeStore ||
      (defaultTargetPlatform == TargetPlatform.iOS && _apiKeyIos.isNotEmpty) ||
      (defaultTargetPlatform == TargetPlatform.android &&
          _apiKeyAndroid.isNotEmpty);

  @override
  void dispose() {
    RemoteConfigService.instance.removeListener(notifyListeners);
    super.dispose();
  }

  Future<void> init({String? uid}) async {
    if (!isConfigured) return;
    if (_initialized) {
      await bindUid(uid);
      return;
    }
    _initialized = true;
    try {
      final apiKey = defaultTargetPlatform == TargetPlatform.iOS
          ? _apiKeyIos
          : _apiKeyAndroid;
      await Purchases.configure(
        PurchasesConfiguration(apiKey)..appUserID = uid,
      );
      _boundUid = uid;
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfo);
      final info = await Purchases.getCustomerInfo();
      _onCustomerInfo(info);
      await _loadOfferings();
    } catch (e) {
      debugPrint('SubscriptionService.init falhou: $e');
    }
  }

  /// Liga a compra à conta Firebase quando o login completa (ou troca).
  Future<void> bindUid(String? uid) async {
    if (!isConfigured) return;
    if (!_initialized) {
      await init(uid: uid);
      return;
    }
    if (uid == null || uid.isEmpty || uid == _boundUid) return;
    _boundUid = uid;
    try {
      await Purchases.logIn(uid);
      final info = await Purchases.getCustomerInfo();
      _onCustomerInfo(info);
    } catch (e) {
      debugPrint('SubscriptionService.bindUid falhou: $e');
    }
  }

  /// Conta excluída: a compra deixa de apontar para o uid apagado.
  Future<void> logOut() async {
    if (!_initialized || _boundUid == null) return;
    _boundUid = null;
    try {
      final info = await Purchases.logOut();
      _onCustomerInfo(info);
    } catch (e) {
      debugPrint('SubscriptionService.logOut falhou: $e');
    }
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      availablePackages = offerings.current?.availablePackages ?? const [];
      supportPackages = [
        ...?offerings.all[supportOfferingId]?.availablePackages,
      ]..sort((a, b) => a.storeProduct.price.compareTo(b.storeProduct.price));
      notifyListeners();
    } catch (e) {
      debugPrint('Falha ao carregar ofertas: $e');
    }
  }

  void _onCustomerInfo(CustomerInfo info) {
    final entitlement = info.entitlements.active[_entitlementId];
    final badgeBefore = hasBadge;
    isPeregrinoPlus = entitlement != null;
    plusProductId = entitlement?.productIdentifier;
    plusExpiresAt = DateTime.tryParse(entitlement?.expirationDate ?? '');
    plusWillRenew = entitlement?.willRenew ?? false;
    plusInTrial = entitlement?.periodType == PeriodType.trial;
    plusBillingIssue = entitlement?.billingIssueDetectedAt != null;
    managementUrl = info.managementURL;
    isSupporter = info.nonSubscriptionTransactions.any(
      (t) => t.productIdentifier.startsWith(_supportProductPrefix),
    );
    notifyListeners();
    if (hasBadge != badgeBefore) onBadgeChanged?.call(hasBadge);

    final expiration = entitlement?.expirationDate;
    if (entitlement != null &&
        entitlement.periodType == PeriodType.trial &&
        expiration != null) {
      final when = DateTime.tryParse(expiration);
      if (when != null) {
        unawaited(
          NotificationService.instance.scheduleTrialEndingReminder(when),
        );
      }
    } else {
      unawaited(NotificationService.instance.cancelTrialEndingReminder());
    }
  }

  Future<bool> purchase(Package package) async {
    lastError = null;
    if (_debugFakeStore) {
      return _debugFakePurchase(() => _debugGrantPlus(package));
    }
    loading = true;
    notifyListeners();
    final productId = package.storeProduct.identifier;
    void track(String stage) => unawaited(
      AnalyticsService.instance.logPurchase(stage: stage, productId: productId),
    );
    track('start');
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _onCustomerInfo(result.customerInfo);
      track(isPeregrinoPlus ? 'success' : 'fail');
      return isPeregrinoPlus;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        track('cancel');
      } else {
        track('fail');
        lastError = L10n.current.paywallPurchaseFailed;
        debugPrint('Falha na compra: $code $e');
      }
      return false;
    } catch (e) {
      track('fail');
      lastError = L10n.current.paywallPurchaseFailed;
      debugPrint('Falha na compra: $e');
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Compra de apoio avulsa. `true` se concluiu.
  Future<bool> purchaseSupport(Package package) async {
    lastError = null;
    if (_debugFakeStore) return _debugFakePurchase(() => isSupporter = true);
    loading = true;
    notifyListeners();
    final productId = package.storeProduct.identifier;
    void track(String stage) => unawaited(
      AnalyticsService.instance.logEvent('support_purchase', {
        'stage': stage,
        'product_id': productId,
      }),
    );
    track('start');
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _onCustomerInfo(result.customerInfo);
      track('success');
      return true;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        track('cancel');
      } else {
        track('fail');
        lastError = L10n.current.paywallPurchaseFailed;
        debugPrint('Falha no apoio: $code $e');
      }
      return false;
    } catch (e) {
      track('fail');
      lastError = L10n.current.paywallPurchaseFailed;
      debugPrint('Falha no apoio: $e');
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> restore() async {
    if (!isConfigured || _debugFakeStore) return;
    loading = true;
    notifyListeners();
    try {
      final info = await Purchases.restorePurchases();
      _onCustomerInfo(info);
    } catch (e) {
      lastError = L10n.current.paywallRestoreFailed;
      debugPrint('Falha ao restaurar compra: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Vitalício: assinatura ativa sem data de fim.
  bool get plusLifetime => isPeregrinoPlus && plusExpiresAt == null;

  /// Tipo do plano ativo (anual, mensal…), pelo produto da oferta.
  PackageType? get plusPackageType => availablePackages
      .where((p) => p.storeProduct.identifier == plusProductId)
      .firstOrNull
      ?.packageType;

  /// Abre a tela da loja para mudar de plano ou cancelar.
  Future<void> openManagement() async {
    final url =
        managementUrl ??
        (defaultTargetPlatform == TargetPlatform.iOS
            ? 'https://apps.apple.com/account/subscriptions'
            : 'https://play.google.com/store/account/subscriptions');
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Falha ao abrir gerenciamento da assinatura: $e');
    }
  }

  /// Plano anual da oferta atual, se houver.
  Package? get annualPackage => availablePackages
      .where((p) => p.packageType == PackageType.annual)
      .firstOrNull;

  /// Dias do teste grátis do pacote, se houver.
  static int? trialDays(Package p) {
    final intro = p.storeProduct.introductoryPrice;
    if (intro == null || intro.price > 0) return null;
    final n = intro.periodNumberOfUnits;
    return switch (intro.periodUnit) {
      PeriodUnit.day => n,
      PeriodUnit.week => n * 7,
      PeriodUnit.month => n * 30,
      PeriodUnit.year => n * 365,
      PeriodUnit.unknown => null,
    };
  }

  static String packageLabel(Package package) {
    final product = package.storeProduct;
    final price = product.priceString;
    final l10n = L10n.current;
    final label = switch (package.packageType) {
      PackageType.monthly => l10n.paywallPriceMonthly(price),
      PackageType.annual => l10n.paywallPriceAnnual(price),
      PackageType.lifetime => l10n.paywallPriceLifetime(price),
      PackageType.weekly => l10n.paywallPriceWeekly(price),
      PackageType.sixMonth => l10n.paywallPriceMonths(6, price),
      PackageType.threeMonth => l10n.paywallPriceMonths(3, price),
      PackageType.twoMonth => l10n.paywallPriceMonths(2, price),
      _ => '',
    };
    if (label.isEmpty) {
      final title = product.title.trim();
      return title.isEmpty
          ? product.priceString
          : '$title · ${product.priceString}';
    }
    return label;
  }

  // --- Laboratório do Peregrino+ (só em build de desenvolvimento) ---------

  bool _debugFakeStore = false;
  bool _debugPromoOverride = false;
  DateTime? _debugPromoUntil;

  bool get debugFakeStore => _debugFakeStore;
  bool get debugPromoOverride => _debugPromoOverride;

  /// Preenche o plano simulado como a loja faria.
  void _debugGrantPlus(Package? package) {
    isPeregrinoPlus = true;
    final type = package?.packageType ?? PackageType.annual;
    final trial = package == null ? null : trialDays(package);
    plusProductId = package?.storeProduct.identifier ?? 'plus_annual';
    plusInTrial = trial != null;
    plusWillRenew = type != PackageType.lifetime;
    plusBillingIssue = false;
    final now = DateTime.now();
    plusExpiresAt = switch (type) {
      PackageType.lifetime => null,
      _ when trial != null => now.add(Duration(days: trial)),
      PackageType.monthly => DateTime(now.year, now.month + 1, now.day),
      _ => DateTime(now.year + 1, now.month, now.day),
    };
  }

  /// Assinante simulado (sem loja).
  void debugSetPlus(bool value) {
    if (!kDebugMode) return;
    final before = hasBadge;
    if (value) {
      _debugGrantPlus(
        availablePackages
            .where((p) => p.packageType == PackageType.annual)
            .firstOrNull,
      );
    } else {
      isPeregrinoPlus = false;
      plusProductId = null;
      plusExpiresAt = null;
    }
    unawaited(_debugSave());
    notifyListeners();
    if (hasBadge != before) onBadgeChanged?.call(hasBadge);
  }

  /// Apoiador simulado (sem loja).
  void debugSetSupporter(bool value) {
    if (!kDebugMode) return;
    final before = hasBadge;
    isSupporter = value;
    unawaited(_debugSave());
    notifyListeners();
    if (hasBadge != before) onBadgeChanged?.call(hasBadge);
  }

  /// Troca a data da promoção. [override] false volta ao Remote Config.
  void debugSetPromo({required bool override, DateTime? until}) {
    if (!kDebugMode) return;
    _debugPromoOverride = override;
    _debugPromoUntil = until == null
        ? null
        : DateTime(until.year, until.month, until.day);
    unawaited(_debugSave());
    notifyListeners();
  }

  /// Loja falsa: planos e apoios de mentira; compras viram sucesso na hora.
  void debugSetFakeStore(bool value) {
    if (!kDebugMode) return;
    _debugFakeStore = value;
    if (value) {
      availablePackages = _debugPlans();
      supportPackages = _debugSupport();
    } else {
      availablePackages = const [];
      supportPackages = const [];
    }
    unawaited(_debugSave());
    notifyListeners();
  }

  static const _debugPrefsKey = 'plusLabState';

  /// Guarda a simulação: sobrevive a fechar o app (testar a oferta da Home).
  Future<void> _debugSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_debugPrefsKey, [
      'plus=$isPeregrinoPlus',
      'supporter=$isSupporter',
      'store=$_debugFakeStore',
      'promo=$_debugPromoOverride',
      'until=${_debugPromoUntil?.toIso8601String().substring(0, 10) ?? ''}',
    ]);
  }

  Future<void> _debugRestore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_debugPrefsKey);
    if (raw == null) return;
    final m = {
      for (final e in raw)
        if (e.contains('=')) e.split('=').first: e.split('=').last,
    };
    isSupporter = m['supporter'] == 'true';
    _debugPromoOverride = m['promo'] == 'true';
    _debugPromoUntil = DateTime.tryParse(m['until'] ?? '');
    if (m['store'] == 'true') {
      _debugFakeStore = true;
      availablePackages = _debugPlans();
      supportPackages = _debugSupport();
    }
    if (m['plus'] == 'true') _debugGrantPlus(annualPackage);
    notifyListeners();
  }

  Future<bool> _debugFakePurchase(void Function() grant) async {
    final before = hasBadge;
    loading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    grant();
    unawaited(_debugSave());
    loading = false;
    notifyListeners();
    if (hasBadge != before) onBadgeChanged?.call(hasBadge);
    return true;
  }

  static Package _debugPackage(
    String id,
    PackageType type,
    double price,
    String priceString, {
    String offering = 'default',
    String? perMonth,
    IntroductoryPrice? intro,
  }) => Package(
    id,
    type,
    StoreProduct(
      id,
      '',
      id,
      price,
      priceString,
      'BRL',
      introductoryPrice: intro,
      pricePerMonthString: perMonth,
    ),
    PresentedOfferingContext(offering, null, null),
  );

  static List<Package> _debugPlans() => [
    _debugPackage('plus_monthly', PackageType.monthly, 12.90, r'R$ 12,90'),
    _debugPackage(
      'plus_annual',
      PackageType.annual,
      79.90,
      r'R$ 79,90',
      perMonth: r'R$ 6,66',
      intro: const IntroductoryPrice(
        0,
        r'R$ 0,00',
        'P14D',
        1,
        PeriodUnit.day,
        14,
      ),
    ),
    _debugPackage('plus_lifetime', PackageType.lifetime, 199.0, r'R$ 199,00'),
  ];

  static List<Package> _debugSupport() => [
    for (final (id, price) in [(5, 5.0), (15, 15.0), (30, 30.0)])
      _debugPackage(
        'apoio_$id',
        PackageType.custom,
        price,
        'R\$ $id,00',
        offering: supportOfferingId,
      ),
  ];
}
