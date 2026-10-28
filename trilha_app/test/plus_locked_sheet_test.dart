import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/l10n/app_language.dart';
import 'package:trilha_app/theme/app_theme.dart';
import 'package:trilha_app/widgets/plus_locked_sheet.dart';
import 'package:trilha_app/widgets/ui_primitives.dart';

void main() {
  testWidgets('folha da trilha Plus explica e oferece o Peregrino+', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showPlusLockedSheet(
                context,
                title: 'Jejum e Disciplinas',
                description: 'Disciplinas da vida com Deus.',
                source: 'test',
                chips: const ['4 cenas'],
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Jejum e Disciplinas'), findsOneWidget);
    expect(find.textContaining('faz parte do Peregrino+'), findsOneWidget);
    expect(find.byType(CopperCta), findsOneWidget);
    expect(find.text('Conhecer o Peregrino+'), findsOneWidget);
  });
}
