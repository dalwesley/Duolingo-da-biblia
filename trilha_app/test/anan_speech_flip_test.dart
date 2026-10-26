import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/widgets/anan_speech.dart';

void main() {
  testWidgets('balão gira ao virar pela primeira vez', (tester) async {
    Widget app(bool flipped) => MaterialApp(
      home: Scaffold(
        body: AnanSideSpeech(
          flipped: flipped,
          // Como no gesto: o verso da dica já está no balão.
          back: const Text('dica'),
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

  testWidgets('Anan com ajuda: selo, convite e toque', (tester) async {
    var taps = 0;
    Widget app({required bool beckon, String? caption}) => MaterialApp(
      home: Scaffold(
        body: AnanSideSpeech(
          onAnanTap: () => taps++,
          ananLabel: 'Pedir ajuda ao Anan',
          beckon: beckon,
          caption: caption,
          child: const Text('pergunta'),
        ),
      ),
    );

    await tester.pumpWidget(app(beckon: true, caption: 'Toque em mim'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('!'), findsOneWidget);
    expect(find.text('Toque em mim'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Pedir ajuda ao Anan'));
    expect(taps, 1);

    // Sem convite: o balanço para e a legenda some.
    await tester.pumpWidget(app(beckon: false));
    await tester.pumpAndSettle();
    expect(find.text('Toque em mim'), findsNothing);
    expect(find.text('!'), findsOneWidget);
  });
}
