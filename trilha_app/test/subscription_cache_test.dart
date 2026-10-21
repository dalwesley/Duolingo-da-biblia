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
    expect(sub.trialDaysFor(founder), isNull);
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
    final l10n = lookupAppLocalizations(const Locale('pt'));
    expect(plusPlanLabel(l10n, sub), 'Pioneiro');
  });

  test('Pioneiro some da venda quando as vagas acabam', () {
    SharedPreferences.setMockInitialValues({});
    final sub = SubscriptionService();
    sub.debugSetFakeStore(true);

    sub.debugSetPioneerCount(199, cap: 200);
    expect(sub.pioneerSoldOut, isFalse);
    expect(sub.founderPackage, isNotNull);

    sub.debugSetPioneerCount(200);
    expect(sub.pioneerSoldOut, isTrue);
    expect(sub.founderPackage, isNull);
    expect(
      sub.packagesForSale.any(SubscriptionService.isFounderPackage),
      isFalse,
    );
    // O anual e o mensal continuam à venda.
    expect(sub.annualPackage, isNotNull);
    expect(sub.packagesForSale, hasLength(sub.availablePackages.length - 1));
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
}
