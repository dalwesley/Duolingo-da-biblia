import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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
    final until = RemoteConfigService.instance.plusLaunchFreeUntil;
    if (until == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.isAfter(until) ? null : until;
  }

  bool get launchPromoActive => launchFreeUntil != null;

  /// Último dia da promoção no Remote Config, mesmo que já tenha passado.
  DateTime? get launchPromoDate =>
      RemoteConfigService.instance.plusLaunchFreeUntil;

  /// Acesso aos recursos do Peregrino+: assinatura ou promoção de lançamento.
  bool get hasPlus => isPeregrinoPlus || launchPromoActive;

  /// Selo de apoiador: quem paga o Peregrino+ ou já apoiou. A promoção de
  /// lançamento não dá selo.
  bool get hasBadge => isPeregrinoPlus || isSupporter;

  /// Apoio avulso disponível na loja.
  bool get supportConfigured => isConfigured && supportPackages.isNotEmpty;

  /// Há algo do Peregrino+ para mostrar (loja configurada ou promoção).
  bool get showsPlus => isConfigured || launchPromoActive;

  bool get isConfigured =>
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
    if (!isConfigured) return;
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
}
