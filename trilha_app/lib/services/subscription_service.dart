import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n_global.dart';
import '../utils/plus_access.dart';
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
/// O gate das telas é [plusFeaturesOpen]: sem loja configurada abre tudo;
/// com loja, fecha sem Plus mesmo se a oferta falhar — o cache do último
/// entitlement segura o assinante até vencer + 7 dias de graça.
class SubscriptionService extends ChangeNotifier {
  SubscriptionService() {
    RemoteConfigService.instance.addListener(notifyListeners);
    unawaited(_restoreLocalState());
    if (kDebugMode) unawaited(_debugRestore());
    _listenPioneerCount();
  }

  /// Histórico primeiro (o mais antigo), cache depois (o mais recente):
  /// em sequência, para a semeadura do fim do Plus não correr com a
  /// leitura do histórico e a data regredir.
  Future<void> _restoreLocalState() async {
    await _restorePlusHistory();
    await _restoreEntitlementCache();
  }

  static const _entitlementId = 'peregrino_plus';

  /// Produto anual de lançamento (R$ 89,90 travado enquanto renovar).
  /// Produto separado porque na loja o preço mora no produto: ao fim do
  /// corte ele sai da oferta e quem assinou continua no preço original.
  static const founderProductId = 'plus_founder_annual';

  /// Teto das primeiras compras do Pioneiro, se o servidor ainda não disse.
  static const pioneerCapDefault = 200;
  static const _pioneerStatsPath = 'stats/pioneer';

  /// Produto anual regular (o "herói", único com teste grátis).
  static const annualProductId = 'plus_annual';

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

  bool loading = false;
  String? lastError;
  bool _initialized = false;
  String? _boundUid;
  Future<void> _bindChain = Future<void>.value();

  /// A oferta da loja chegou com planos. Falha ou lista vazia não trava nada.
  bool _offeringsReady = false;

  /// Elegibilidade de teste grátis por produto (RevenueCat). Sem resposta
  /// ou "desconhecido", a tela NÃO promete trial: no Android o status é
  /// sempre desconhecido, e a própria loja mostra o teste na compra.
  Map<String, IntroEligibilityStatus> _trialEligibility = const {};

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

  /// Veio do cache local (loja ainda não respondeu nesta abertura).
  bool _plusFromCache = false;

  /// A loja já respondeu nesta sessão: o cache não fala mais depois disso.
  bool _storeAnswered = false;

  /// Conta dona do cache restaurado (vazio em cache antigo, sem dono).
  String? _cachedUid;

  /// Quando o Plus acabou pela última vez (para o convite de retorno).
  DateTime? _lastPlusEndedAt;

  /// Conta a que esse fim pertence (histórico antigo pode não ter dono).
  String? _historyUid;

  /// Último fim do Peregrino+ conhecido **desta conta**, ou null.
  /// Histórico de outra conta neste aparelho não vaza: sem dono gravado
  /// (cache antigo) vale; com dono diferente da conta ligada, não.
  DateTime? get lastPlusEndedAt {
    final ended = _lastPlusEndedAt;
    if (ended == null) return null;
    final owner = _historyUid;
    if (owner != null &&
        owner.isNotEmpty &&
        _boundUid != null &&
        owner != _boundUid) {
      return null;
    }
    return ended;
  }

  /// Assinatura vencida há pouco, ainda dentro da graça do cache.
  bool get plusInGrace =>
      _plusFromCache &&
      isPeregrinoPlus &&
      plusExpiresAt != null &&
      DateTime.now().isAfter(plusExpiresAt!);

  /// Acesso aos recursos do Peregrino+: assinatura, promoção de
  /// lançamento ou cache dentro da validade/graça (ver [PlusAccess]).
  bool get hasPlus => isPeregrinoPlus || launchPromoActive;

  /// Algum selo (laboratório e checagens genéricas).
  bool get hasBadge => isPeregrinoPlus || isSupporter;

  /// Selo de Peregrino: exclusivo de quem assina o Peregrino+. A promoção
  /// de lançamento não dá selo.
  bool get hasPilgrimBadge => isPeregrinoPlus;

  /// Selo de Apoiador: exclusivo de quem fez apoio avulso — é o campo
  /// [isSupporter], sem mistura com o de Peregrino.

  /// Apoio avulso disponível na loja.
  bool get supportConfigured => isConfigured && supportPackages.isNotEmpty;

  /// Há plano comprável na tela. Chave sem oferta (rede, loja vazia) não conta.
  bool get canPurchase =>
      isConfigured && _offeringsReady && availablePackages.isNotEmpty;

  /// Aberto com Plus, ou num build sem loja configurada. Loja configurada
  /// sem oferta (falha/rede) não abre mais: fecha com o cache de graça.
  bool get plusFeaturesOpen =>
      PlusAccess.featuresOpen(hasPlus: hasPlus, storeConfigured: isConfigured);

  /// Há algo do Peregrino+ para mostrar (loja configurada ou promoção).
  bool get showsPlus => isConfigured || launchPromoActive;

  bool get isConfigured =>
      _debugFakeStore ||
      (defaultTargetPlatform == TargetPlatform.iOS && _apiKeyIos.isNotEmpty) ||
      (defaultTargetPlatform == TargetPlatform.android &&
          _apiKeyAndroid.isNotEmpty);

  /// Compras do Pioneiro já contadas. Null enquanto `stats/pioneer` não existe.
  int? _pioneerCount;
  int _pioneerCap = pioneerCapDefault;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _pioneerListen;

  /// Vagas ocupadas, no máximo o teto. Zero enquanto o documento não existe.
  int get pioneerTaken {
    final n = _pioneerCount ?? 0;
    if (n <= 0) return 0;
    return n > _pioneerCap ? _pioneerCap : n;
  }

  int get pioneerCap => _pioneerCap;

  void _listenPioneerCount() {
    if (Firebase.apps.isEmpty) return;
    _pioneerListen = FirebaseFirestore.instance
        .doc(_pioneerStatsPath)
        .snapshots()
        .listen(
          (snap) {
            if (!snap.exists) {
              _pioneerCount = null;
            } else {
              final data = snap.data();
              final raw = data?['count'];
              _pioneerCount = raw is int
                  ? raw
                  : raw is num
                  ? raw.toInt()
                  : null;
              final cap = data?['cap'];
              if (cap is int && cap > 0) {
                _pioneerCap = cap;
              } else if (cap is num && cap > 0) {
                _pioneerCap = cap.toInt();
              }
            }
            notifyListeners();
          },
          onError: (Object e) {
            debugPrint('Contagem do Pioneiro indisponível: $e');
          },
        );
  }

  @override
  void dispose() {
    RemoteConfigService.instance.removeListener(notifyListeners);
    unawaited(_pioneerListen?.cancel());
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

  /// Liga a compra à conta Firebase. Sem uid, encerra a sessão da loja
  /// para a próxima pessoa não herdar o Plus na memória.
  Future<void> bindUid(String? uid) {
    final run = _bindChain.then((_) => _bindNow(uid));
    _bindChain = run.catchError((Object _) {});
    return run;
  }

  Future<void> _bindNow(String? uid) async {
    if (uid == null || uid.isEmpty) {
      await _endSession();
      return;
    }
    // Cache de outra conta neste aparelho não atravessa a troca: sem
    // isto, a pessoa nova herdava o Plus até a loja responder — e para
    // sempre, se a resposta falhasse.
    if (_plusFromCache &&
        _cachedUid != null &&
        _cachedUid!.isNotEmpty &&
        _cachedUid != uid) {
      _clearLocalPlus();
    }
    if (!isConfigured) return;
    if (!_initialized) {
      await init(uid: uid);
      return;
    }
    if (uid == _boundUid) return;
    // Troca de conta: o Plus de quem sai cai antes de a loja responder
    // pela conta nova — nada de janela com o acesso do dono anterior,
    // e a transição não grava o fim do Plus de um no histórico do outro.
    final switching = _boundUid != null;
    if (switching) _clearLocalPlus();
    // Histórico de ex-assinante de outra conta não atravessa a troca.
    if (_historyUid != null && _historyUid!.isNotEmpty && _historyUid != uid) {
      _lastPlusEndedAt = null;
      _historyUid = null;
      unawaited(_savePlusHistory());
    }
    _boundUid = uid;
    try {
      await Purchases.logIn(uid);
      final info = await Purchases.getCustomerInfo();
      _onCustomerInfo(info);
    } catch (e) {
      // Troca de conta sem resposta da loja: solta o Plus de quem saiu.
      if (switching) _clearLocalPlus();
      debugPrint('SubscriptionService.bindUid falhou: $e');
    }
  }

  /// Sai da conta ou exclui: solta o RevenueCat e esquece o Plus local.
  Future<void> logOut() => bindUid(null);

  Future<void> _endSession() async {
    final wasBound = _boundUid != null;
    _boundUid = null;
    _clearLocalPlus();
    if (kDebugMode) unawaited(_debugSave());
    if (!_initialized || !wasBound) return;
    try {
      final info = await Purchases.logOut();
      _onCustomerInfo(info);
    } catch (e) {
      debugPrint('SubscriptionService.logOut falhou: $e');
    }
  }

  /// Não publica o selo: sair da conta não apaga o apoiador na Caravana.
  void _clearLocalPlus() {
    isPeregrinoPlus = false;
    isSupporter = false;
    plusProductId = null;
    plusExpiresAt = null;
    plusWillRenew = false;
    plusInTrial = false;
    plusBillingIssue = false;
    _plusFromCache = false;
    unawaited(_clearEntitlementCache());
    notifyListeners();
  }

  // --- Cache do entitlement (graça offline) --------------------------------
  //
  // A loja é a fonte; isto é só a última resposta dela, gravada no aparelho.
  // Se a próxima abertura não conseguir falar com a loja, o assinante não
  // perde o Plus na hora: vale até vencer, mais [PlusAccess.graceDays].

  static const _cachePrefsKey = 'plusEntitlementCache';

  Future<void> _saveEntitlementCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_cachePrefsKey, [
        'plus=$isPeregrinoPlus',
        'supporter=$isSupporter',
        'product=${plusProductId ?? ''}',
        'expires=${plusExpiresAt?.toIso8601String() ?? ''}',
        'willRenew=$plusWillRenew',
        'trial=$plusInTrial',
        'billing=$plusBillingIssue',
        'uid=${_boundUid ?? ''}',
      ]);
    } catch (e) {
      debugPrint('SubscriptionService cache falhou: $e');
    }
  }

  Future<void> _clearEntitlementCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachePrefsKey);
    } catch (_) {}
  }

  Future<void> _restoreEntitlementCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_cachePrefsKey);
      if (raw == null) return;
      final m = {
        for (final e in raw)
          if (e.contains('=')) e.split('=').first: e.split('=').last,
      };
      final expires = DateTime.tryParse(m['expires'] ?? '');
      final active = PlusAccess.cachedPlusActive(
        cachedPlus: m['plus'] == 'true',
        expiresAt: expires,
        now: DateTime.now(),
      );
      // A loja já respondeu nesta sessão (ou o debug concedeu): o cache
      // é só a foto anterior — não ressuscita Plus que a loja encerrou,
      // nem o da conta anterior neste aparelho.
      if (_storeAnswered || isPeregrinoPlus) return;
      _cachedUid = (m['uid'] ?? '').isEmpty ? null : m['uid'];
      isSupporter = m['supporter'] == 'true';
      if (!active) {
        // Plus que acabou com o app fechado (além da graça): a data do
        // cache é o fim dele. Sem isto, o convite de retorno (14 dias)
        // só alcançava quem voltasse na 1ª semana — justamente quem
        // menos precisava ser chamado de volta.
        if (m['plus'] == 'true' && expires != null) {
          if (_lastPlusEndedAt == null || expires.isAfter(_lastPlusEndedAt!)) {
            _lastPlusEndedAt = expires;
            _historyUid = _cachedUid;
            unawaited(_savePlusHistory());
          }
        }
        notifyListeners();
        return;
      }
      _plusFromCache = true;
      isPeregrinoPlus = true;
      plusProductId = (m['product'] ?? '').isEmpty ? null : m['product'];
      plusExpiresAt = expires;
      plusWillRenew = m['willRenew'] == 'true';
      plusInTrial = m['trial'] == 'true';
      plusBillingIssue = m['billing'] == 'true';
      notifyListeners();
    } catch (e) {
      debugPrint('SubscriptionService restore cache falhou: $e');
    }
  }

  static const _historyPrefsKey = 'plusHistoryCache';

  Future<void> _savePlusHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyPrefsKey, [
        'ended=${_lastPlusEndedAt?.toIso8601String() ?? ''}',
        'uid=${_boundUid ?? _historyUid ?? ''}',
      ]);
    } catch (_) {}
  }

  Future<void> _restorePlusHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_historyPrefsKey);
      if (raw == null) return;
      for (final e in raw) {
        if (e.startsWith('ended=')) {
          // Só um fim de verdade entra: '' não apaga o que o cache semeou.
          final parsed = DateTime.tryParse(e.substring(6));
          if (parsed != null) _lastPlusEndedAt = parsed;
        }
        if (e.startsWith('uid=')) {
          final owner = e.substring(4);
          if (owner.isNotEmpty) _historyUid = owner;
        }
      }
      if (_lastPlusEndedAt != null) notifyListeners();
    } catch (_) {}
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      availablePackages = offerings.current?.availablePackages ?? const [];
      supportPackages = [
        ...?offerings.all[supportOfferingId]?.availablePackages,
      ]..sort((a, b) => a.storeProduct.price.compareTo(b.storeProduct.price));
      _offeringsReady = availablePackages.isNotEmpty;
      notifyListeners();
      await _loadTrialEligibility();
    } catch (e) {
      _offeringsReady = false;
      availablePackages = const [];
      debugPrint('Falha ao carregar ofertas: $e');
      notifyListeners();
    }
  }

  Future<void> _loadTrialEligibility() async {
    if (_debugFakeStore) return; // o laboratório marca todo mundo elegível
    final ids = [for (final p in availablePackages) p.storeProduct.identifier];
    if (ids.isEmpty) return;
    try {
      final map = await Purchases.checkTrialOrIntroductoryPriceEligibility(ids);
      _trialEligibility = {for (final e in map.entries) e.key: e.value.status};
      notifyListeners();
    } catch (e) {
      debugPrint('SubscriptionService elegibilidade falhou: $e');
    }
  }

  /// Dias de teste grátis que dá para **prometer na tela** para [p]:
  /// só com elegibilidade confirmada. Quem já testou/assinou (o público
  /// do winback!) ou está em status desconhecido vê a assinatura direta
  /// — prometer trial para inelegível é cobrança-surpresa e reembolso.
  int? trialDaysFor(Package p) {
    final status = _trialEligibility[p.storeProduct.identifier];
    if (status != IntroEligibilityStatus.introEligibilityStatusEligible) {
      return null;
    }
    return trialDays(p);
  }

  void _onCustomerInfo(CustomerInfo info) {
    final entitlement = info.entitlements.active[_entitlementId];
    final wasPlus = isPeregrinoPlus;
    final prevExpiry = plusExpiresAt;
    _storeAnswered = true;
    _plusFromCache = false;
    isPeregrinoPlus = entitlement != null;
    if (wasPlus && !isPeregrinoPlus) {
      // O Plus acabou: guarda quando (e de quem), para o retorno (winback).
      _lastPlusEndedAt = prevExpiry ?? DateTime.now();
      _historyUid = _boundUid;
      unawaited(_savePlusHistory());
    }
    if (wasPlus != isPeregrinoPlus && availablePackages.isNotEmpty) {
      unawaited(_loadTrialEligibility());
    }
    plusProductId = entitlement?.productIdentifier;
    plusExpiresAt = DateTime.tryParse(entitlement?.expirationDate ?? '');
    plusWillRenew = entitlement?.willRenew ?? false;
    plusInTrial = entitlement?.periodType == PeriodType.trial;
    plusBillingIssue = entitlement?.billingIssueDetectedAt != null;
    managementUrl = info.managementURL;
    isSupporter = info.nonSubscriptionTransactions.any(
      (t) => t.productIdentifier.startsWith(_supportProductPrefix),
    );
    unawaited(_saveEntitlementCache());
    notifyListeners();

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
      unawaited(
        AnalyticsService.instance.logRestore(isPeregrinoPlus ? 'plus' : 'none'),
      );
    } catch (e) {
      lastError = L10n.current.paywallRestoreFailed;
      unawaited(AnalyticsService.instance.logRestore('error'));
      debugPrint('Falha ao restaurar compra: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Vitalício: assinatura ativa sem data de fim.
  bool get plusLifetime => isPeregrinoPlus && plusExpiresAt == null;

  /// O pacote é o anual Fundador (mesmo tipo anual, outro produto).
  static bool isFounderPackage(Package p) =>
      p.storeProduct.identifier == founderProductId;

  /// A assinatura ativa é o Fundador de lançamento.
  bool get plusIsFounder => plusProductId == founderProductId;

  /// Pacote Fundador da oferta atual, se ainda estiver à venda.
  Package? get founderPackage =>
      availablePackages.where(isFounderPackage).firstOrNull;

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

  /// Plano anual regular da oferta atual, se houver. O Fundador é anual
  /// também, mas não entra aqui: quem usa este getter quer o plano com
  /// teste grátis (folha de oferta, aviso de promoção).
  Package? get annualPackage => availablePackages
      .where((p) => p.packageType == PackageType.annual && !isFounderPackage(p))
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
    final trial = package == null
        ? null
        : SubscriptionService.trialDays(package);
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
  }

  /// Apoiador simulado (sem loja).
  void debugSetSupporter(bool value) {
    if (!kDebugMode) return;
    isSupporter = value;
    unawaited(_debugSave());
    notifyListeners();
  }

  /// Simula elegibilidade de trial no laboratório (testar o winback
  /// sem promessa de teste para quem já testou).
  void debugSetTrialEligible(String productId, bool eligible) {
    if (!kDebugMode) return;
    _trialEligibility = {
      ..._trialEligibility,
      productId: eligible
          ? IntroEligibilityStatus.introEligibilityStatusEligible
          : IntroEligibilityStatus.introEligibilityStatusIneligible,
    };
    notifyListeners();
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
      _offeringsReady = true;
      _trialEligibility = {
        for (final p in availablePackages)
          p.storeProduct.identifier:
              IntroEligibilityStatus.introEligibilityStatusEligible,
      };
    } else {
      availablePackages = const [];
      supportPackages = const [];
      _offeringsReady = false;
      _trialEligibility = const {};
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
      _offeringsReady = true;
      _trialEligibility = {
        for (final p in availablePackages)
          p.storeProduct.identifier:
              IntroEligibilityStatus.introEligibilityStatusEligible,
      };
    }
    if (m['plus'] == 'true') _debugGrantPlus(annualPackage);
    notifyListeners();
  }

  Future<bool> _debugFakePurchase(void Function() grant) async {
    loading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    grant();
    unawaited(_debugSave());
    loading = false;
    notifyListeners();
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

  // Espelha a loja real decidida em out/2026 (ver MONETIZATION.md):
  // mensal 19,90 · Fundador 89,90 sem teste · anual 119,90 com 14 dias.
  static List<Package> _debugPlans() => [
    _debugPackage('plus_monthly', PackageType.monthly, 19.90, r'R$ 19,90'),
    _debugPackage(
      founderProductId,
      PackageType.annual,
      89.90,
      r'R$ 89,90',
      perMonth: r'R$ 7,49',
    ),
    _debugPackage(
      annualProductId,
      PackageType.annual,
      119.90,
      r'R$ 119,90',
      perMonth: r'R$ 9,99',
      intro: const IntroductoryPrice(
        0,
        r'R$ 0,00',
        'P14D',
        1,
        PeriodUnit.day,
        14,
      ),
    ),
  ];

  static List<Package> _debugSupport() => [
    for (final (id, price) in [(5, 5.0), (15, 15.0), (30, 30.0), (50, 50.0)])
      _debugPackage(
        'apoio_$id',
        PackageType.custom,
        price,
        'R\$ $id,00',
        offering: supportOfferingId,
      ),
  ];
}
