import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/l10n/app_language.dart';
import 'package:trilha_app/widgets/reset_progress_sheet.dart';
import 'package:trilha_app/widgets/ui_primitives.dart';

void main() {
  Future<void> openSheet(
    WidgetTester tester, {
    required Future<bool> Function() show,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // Sem a reação da nuvem: o relógio do teste é só da contagem.
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) =>
                TextButton(onPressed: () => show(), child: const Text('abrir')),
          ),
        ),
      ),
    );
  }

  GhostCta confirmCta(WidgetTester tester) => tester
      .widgetList<GhostCta>(find.byType(GhostCta))
      .firstWhere((c) => c.danger);

  testWidgets('confirm stays off until the wait ends and the box is checked', (
    tester,
  ) async {
    Future<bool>? pending;
    await openSheet(
      tester,
      show: () {
        final context = tester.element(find.text('abrir'));
        pending = showResetProgressSheet(context);
        return pending!;
      },
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Confirmar · 10s'), findsOneWidget);
    expect(confirmCta(tester).onTap, isNull);

    await tester.tap(find.text('Estou ciente de que vou perder o progresso'));
    await tester.pumpAndSettle();
    expect(confirmCta(tester).onTap, isNull);

    await tester.pump(const Duration(seconds: 10));

    expect(find.text('Confirmar'), findsOneWidget);
    expect(confirmCta(tester).onTap, isNotNull);

    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(await pending, isTrue);
  });

  testWidgets('checkbox alone does not enable confirm before the wait', (
    tester,
  ) async {
    await openSheet(
      tester,
      show: () {
        final context = tester.element(find.text('abrir'));
        return showResetProgressSheet(context);
      },
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Estou ciente de que vou perder o progresso'));
    await tester.pump(const Duration(seconds: 9));

    expect(confirmCta(tester).onTap, isNull);
    expect(find.textContaining('Confirmar ·'), findsOneWidget);
  });
}
