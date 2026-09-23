import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/widgets/reset_progress_sheet.dart';

void main() {
  Future<void> openSheet(WidgetTester tester, {required Future<bool> Function() show}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => show(),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('confirm stays off until the wait ends and the box is checked', (
    tester,
  ) async {
    Future<bool>? pending;
    await openSheet(tester, show: () {
      final context = tester.element(find.text('abrir'));
      pending = showResetProgressSheet(context);
      return pending!;
    });

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    FilledButton confirm() => tester.widget<FilledButton>(find.byType(FilledButton));

    expect(find.text('Confirmar · 10s'), findsOneWidget);
    expect(confirm().onPressed, isNull);

    await tester.tap(find.text('Estou ciente de que vou perder o progresso'));
    await tester.pumpAndSettle();
    expect(confirm().onPressed, isNull);

    await tester.pump(const Duration(seconds: 10));

    expect(find.text('Confirmar'), findsOneWidget);
    expect(confirm().onPressed, isNotNull);

    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(await pending, isTrue);
  });

  testWidgets('checkbox alone does not enable confirm before the wait', (
    tester,
  ) async {
    await openSheet(tester, show: () {
      final context = tester.element(find.text('abrir'));
      return showResetProgressSheet(context);
    });

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Estou ciente de que vou perder o progresso'));
    await tester.pump(const Duration(seconds: 9));

    final confirm = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(confirm.onPressed, isNull);
    expect(find.textContaining('Confirmar ·'), findsOneWidget);
  });
}
