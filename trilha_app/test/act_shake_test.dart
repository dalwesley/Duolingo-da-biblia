import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/widgets/act_feel.dart';

void main() {
  Widget host({required bool active}) {
    return MaterialApp(
      home: Scaffold(
        body: ActShake(
          active: active,
          child: const SizedBox(key: Key('target'), width: 48, height: 48),
        ),
      ),
    );
  }

  double dx(WidgetTester tester) {
    final transform = tester.widget<Transform>(
      find.ancestor(
        of: find.byKey(const Key('target')),
        matching: find.byType(Transform),
      ),
    );
    return transform.transform.getTranslation().x;
  }

  testWidgets('shakes the first time active flips to true', (tester) async {
    await tester.pumpWidget(host(active: false));
    expect(dx(tester), 0);

    await tester.pumpWidget(host(active: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    expect(dx(tester).abs(), greaterThan(0.5));
  });

  testWidgets('shakes when first built already active', (tester) async {
    await tester.pumpWidget(host(active: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    expect(dx(tester).abs(), greaterThan(0.5));
  });
}
