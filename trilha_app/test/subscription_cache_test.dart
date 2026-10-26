import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/l10n/gen/app_localizations.dart';
import 'package:trilha_app/screens/paywall_screen.dart';
import 'package:trilha_app/services/subscription_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SubscriptionService> bootWithCache(List<String> cache) async {
    SharedPreferences.setMockInitialValues({'plusEntitlementCache': cache});
    final sub = SubscriptionService();
    // As restaurações do construtor são assíncronas (prefs mockadas).
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return sub;
  }

  test('vencido com o app fechado semeia o fim do Plus (winback)', () async {
    final ended = DateTime.now().subtract(const Duration(days: 20));
    final sub = await bootWithCache([
      'plus=true',
      'supporter=false',
      'product=plus_annual',
      'expires=${ended.toIso8601String()}',
      'willRenew=false',
      'trial=false',
      'billing=false',
      'uid=uid-1',
    ]);
    expect(sub.isPeregrinoPlus, isFalse);
    expect(sub.lastPlusEndedAt, isNotNull);
    expect(
      DateTime.now().difference(sub.lastPlusEndedAt!).inDays,
      inInclusiveRange(19, 21),
    );
  });

  test('trial só é prometido para quem a loja diz elegível', () async {
    SharedPreferences.setMockInitialValues({});
    final sub = SubscriptionService();
    sub.debugSetFakeStore(true);
    final annual = sub.annualPackage;
    expect(annual, isNotNull);
    // Laboratório: elegível por padrão, promete os 14 dias do anual falso.
    expect(sub.trialDaysFor(annual!), 14);
    // Já testou/assinou antes (o público do winback): nada de promessa.
    sub.debugSetTrialEligible('plus_annual', false);
    expect(sub.trialDaysFor(annual), isNull);
  });

  test('Fundador é anual, mas não rouba o anual do trial', () {
    SharedPreferences.setMockInitialValues({});
    final sub = SubscriptionService();
    sub.debugSetFakeStore(true);

    final founder = sub.founderPackage;
    expect(founder, isNotNull);
    expect(SubscriptionService.isFounderPackage(founder!), isTrue);
    // O getter do trial continua apontando para o anual regular.
    expect(
      sub.annualPackage?.storeProduct.identifier,
      SubscriptionService.annualProductId,
    );
    // No lançamento o Pioneiro também tem os 14 dias de teste.
    expect(sub.trialDaysFor(founder), 14);
    expect(sub.trialDaysFor(sub.annualPackage!), 14);

    // Laboratório espelha a loja decidida: sem vitalício, apoio de 50.
    expect(
      sub.availablePackages.any((p) => p.packageType == PackageType.lifetime),
      isFalse,
    );
    expect(
      sub.supportPackages.map((p) => p.storeProduct.identifier),
      contains('apoio_50'),
    );

    // Quem assina o Pioneiro vê esse nome no plano ativo.
    sub.plusProductId = SubscriptionService.founderProductId;
    expect(sub.plusIsFounder, isTrue);
    // Selo de Pioneiro só com a assinatura ativa.
    sub.isPeregrinoPlus = false;
    expect(sub.hasPioneerBadge, isFalse);
    sub.isPeregrinoPlus = true;
    expect(sub.hasPioneerBadge, isTrue);
    final l10n = lookupAppLocalizations(const Locale('pt'));
    expect(plusPlanLabel(l10n, sub), 'Pioneiro');
  });

  List<String> forSale(SubscriptionService sub) => [
    for (final p in sub.packagesForSale) p.storeProduct.identifier,
  ];

  test('no lançamento o Pioneiro é o único anual à venda', () {
    SharedPreferences.setMockInitialValues({});
    final sub = SubscriptionService();
    sub.debugSetFakeStore(true);
    sub.debugSetPioneerUntil(null);

    sub.debugSetPioneerCount(199, cap: 200);
    expect(sub.pioneerOnSale, isTrue);
    expect(forSale(sub), contains(SubscriptionService.founderProductId));
    expect(forSale(sub), isNot(contains(SubscriptionService.annualProductId)));
    expect(sub.annualOnSale, same(sub.founderPackage));
  });

  test('vagas esgotadas: o anual regular volta no lugar do Pioneiro', () {
    SharedPreferences.setMockInitialValues({});
    final sub = SubscriptionService();
    sub.debugSetFakeStore(true);
    sub.debugSetPioneerUntil(null);

    sub.debugSetPioneerCount(200, cap: 200);
    expect(sub.pioneerSoldOut, isTrue);
    expect(sub.pioneerOnSale, isFalse);
    expect(sub.founderPackage, isNull);
    expect(forSale(sub), contains(SubscriptionService.annualProductId));
    expect(forSale(sub), isNot(contains(SubscriptionService.founderProductId)));
    expect(
      sub.annualOnSale?.storeProduct.identifier,
      SubscriptionService.annualProductId,
    );
  });

  test('prazo do Pioneiro: vale até o dia, inclusive', () {
    SharedPreferences.setMockInitialValues({});
    final sub = SubscriptionService();
    sub.debugSetFakeStore(true);
    sub.debugSetPioneerCount(10, cap: 200);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    sub.debugSetPioneerUntil(today);
    expect(sub.pioneerOnSale, isTrue);

    sub.debugSetPioneerUntil(today.subtract(const Duration(days: 1)));
    expect(sub.pioneerOnSale, isFalse);
    expect(forSale(sub), contains(SubscriptionService.annualProductId));
  });

  test('cache dentro da validade concede o Plus, sem fim gravado', () async {
    final expires = DateTime.now().add(const Duration(days: 30));
    final sub = await bootWithCache([
      'plus=true',
      'supporter=false',
      'product=plus_annual',
      'expires=${expires.toIso8601String()}',
      'willRenew=true',
      'trial=false',
      'billing=false',
      'uid=uid-1',
    ]);
    expect(sub.isPeregrinoPlus, isTrue);
    expect(sub.lastPlusEndedAt, isNull);
  });

  List<String> validCache() => [
    'plus=true',
    'supporter=false',
    'product=plus_annual',
    'expires=${DateTime.now().add(const Duration(days: 30)).toIso8601String()}',
    'willRenew=true',
    'trial=false',
    'billing=false',
    'uid=uid-1',
  ];

  test('boot antes do login (bindUid null) não apaga o cache', () async {
    SharedPreferences.setMockInitialValues({
      'plusEntitlementCache': validCache(),
    });
    final sub = SubscriptionService();
    // Como no main.dart: o provider liga antes de o auth restaurar.
    unawaited(sub.init());
    unawaited(sub.bindUid(null));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(sub.isPeregrinoPlus, isTrue);
    await sub.bindUid('uid-1');
    expect(sub.isPeregrinoPlus, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('plusEntitlementCache'), isNotNull);
  });

  test('sair da conta depois do login apaga o cache', () async {
    final sub = await bootWithCache(validCache());
    await sub.bindUid('uid-1');
    expect(sub.isPeregrinoPlus, isTrue);
    await sub.logOut();
    expect(sub.isPeregrinoPlus, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('plusEntitlementCache'), isNull);
  });

  test('cache de outra conta não passa para quem entra', () async {
    final sub = await bootWithCache(validCache());
    await sub.bindUid(null);
    await sub.bindUid('uid-2');
    expect(sub.isPeregrinoPlus, isFalse);
  });
}
