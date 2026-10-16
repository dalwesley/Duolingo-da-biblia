import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/widgets/cloud_mascot.dart';

void main() {
  for (final face in CloudFace.values) {
    testWidgets('$face reacts, idles and leaves no timer behind', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Center(child: CloudMascot(face: face))),
      );
      await tester.pump(const Duration(seconds: 7));
      expect(find.byType(CustomPaint), findsWidgets);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('face change mid reaction morphs from where it is', (
    tester,
  ) async {
    Widget app(CloudFace face) =>
        MaterialApp(home: Center(child: CloudMascot(face: face)));
    await tester.pumpWidget(app(CloudFace.carregando));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(app(CloudFace.erro));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpWidget(app(CloudFace.carregando));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('reduced motion shows the final face without animating', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Center(child: CloudMascot(face: CloudFace.sucesso)),
        ),
      ),
    );
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(const SizedBox());
  });
}
