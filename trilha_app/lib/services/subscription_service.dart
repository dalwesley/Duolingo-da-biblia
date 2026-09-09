import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'notification_service.dart';

/// Assinatura "Peregrino+" via RevenueCat.
///
/// Sem chave de API configurada (`_apiKeyAndroid`/`_apiKeyIos` vazias), o SDK
/// nunca é inicializado e [isPeregrinoPlus] fica sempre `false` — o app
/// funciona normalmente sem nenhuma conta RevenueCat criada. Criar a conta,
/// os produtos na App Store Connect/Play Console e preencher as chaves é um
/// passo manual fora deste código.
class SubscriptionService extends ChangeNotifier {
  static const _entitlementId = 'peregrino_plus';

  // Preencher ao criar o projeto no dashboard da RevenueCat.
  static const _apiKeyAndroid = '';
  static const _apiKeyIos = '';

  bool isPeregrinoPlus = false;
  List<Package> availablePackages = const [];
  bool loading = false;
  String? lastError;
  bool _initialized = false;
  String? _boundUid;

  bool get isConfigured =>
      (defaultTargetPlatform == TargetPlatform.iOS && _apiKeyIos.isNotEmpty) ||
      (defaultTargetPlatform == TargetPlatform.android &&
          _apiKeyAndroid.isNotEmpty);

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

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      availablePackages = offerings.current?.availablePackages ?? const [];
      notifyListeners();
    } catch (e) {
      debugPrint('Falha ao carregar ofertas: $e');
    }
  }

  void _onCustomerInfo(CustomerInfo info) {
    final entitlement = info.entitlements.active[_entitlementId];
    isPeregrinoPlus = entitlement != null;
    notifyListeners();

    final expiration = entitlement?.expirationDate;
    if (entitlement != null &&
        entitlement.periodType == PeriodType.trial &&
        expiration != null) {
      final when = DateTime.tryParse(expiration);
      if (when != null) {
        unawaited(NotificationService.instance.scheduleTrialEndingReminder(when));
      }
    } else {
      unawaited(NotificationService.instance.cancelTrialEndingReminder());
    }
  }

  Future<bool> purchase(Package package) async {
    lastError = null;
    loading = true;
    notifyListeners();
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _onCustomerInfo(result.customerInfo);
      return isPeregrinoPlus;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code != PurchasesErrorCode.purchaseCancelledError) {
        lastError = 'Não foi possível concluir a compra.';
        debugPrint('Falha na compra: $code $e');
      }
      return false;
    } catch (e) {
      lastError = 'Não foi possível concluir a compra.';
      debugPrint('Falha na compra: $e');
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
      lastError = 'Não foi possível restaurar a compra.';
      debugPrint('Falha ao restaurar compra: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  static String packageLabel(Package package) {
    final product = package.storeProduct;
    final period = switch (package.packageType) {
      PackageType.monthly => 'por mês',
      PackageType.annual => 'por ano',
      PackageType.lifetime => 'pagamento único',
      PackageType.weekly => 'por semana',
      PackageType.sixMonth => 'por 6 meses',
      PackageType.threeMonth => 'por 3 meses',
      PackageType.twoMonth => 'por 2 meses',
      _ => '',
    };
    if (period.isEmpty) {
      final title = product.title.trim();
      return title.isEmpty ? product.priceString : '$title · ${product.priceString}';
    }
    return '${product.priceString} $period';
  }
}
