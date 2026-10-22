import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/screens/paywall_screen.dart';
import 'package:trilha_app/services/progress_service.dart';
import 'package:trilha_app/services/subscription_service.dart';

import 'helpers/l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpPaywall(
    WidgetTester tester,
    SubscriptionService sub,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SubscriptionService>.value(value: sub),
          ChangeNotifierProvider<ProgressService>.value(
            value: ProgressService(),
          ),
        ],
        child: l10nApp(const PaywallScreen(source: 'test')),
      ),
    );
    await tester.pump();
  }

  testWidgets('assinar abre a comemoração do Anan', (tester) async {
    final sub = SubscriptionService();
    sub.debugSetFakeStore(true);
    await pumpPaywall(tester, sub);

    expect(find.text('Você é Peregrino+!'), findsNothing);

    final cta = find.text('Começar 14 dias grátis');
    await tester.scrollUntilVisible(
      cta,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(cta);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Você é Peregrino+!'), findsOneWidget);
    expect(
      find.text('Seu apoio mantém o Stway grátis para quem não pode pagar.'),
      findsOneWidget,
    );
    expect(find.text('Entendi'), findsOneWidget);
  });

  testWidgets('quem já é Peregrino+ não vê a festa de novo', (tester) async {
    final sub = SubscriptionService();
    sub.debugSetFakeStore(true);
    sub.debugSetPlus(true);
    await pumpPaywall(tester, sub);

    expect(find.text('Você já é Peregrino+'), findsOneWidget);
    expect(find.text('Você é Peregrino+!'), findsNothing);
  });
}
