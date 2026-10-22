import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/widgets/anan_speech.dart';

void main() {
  testWidgets('balão gira ao virar pela primeira vez', (tester) async {
    Widget app(bool flipped) => MaterialApp(
      home: Scaffold(
        body: AnanSideSpeech(
          flipped: flipped,
          // Como no gesto: o verso só existe depois que a dica é pedida.
          back: flipped ? const Text('dica') : null,
          child: const Text('pergunta'),
        ),
      ),
    );
    List<double> scales() => tester
        .widgetList<Transform>(find.byType(Transform))
        .map((w) => w.transform.storage[5])
        .toList();

    await tester.pumpWidget(app(false));
    await tester.pumpWidget(app(true));
    await tester.pump(const Duration(milliseconds: 150));
    final mid = scales();
    await tester.pumpAndSettle();
    final end = scales();
    // No meio do giro o balão está inclinado; no fim, de frente de novo.
    expect(mid, isNot(equals(end)));
    expect(find.text('dica'), findsOneWidget);
  });
}
