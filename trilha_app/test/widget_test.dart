import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/main.dart';
import 'package:trilha_app/widgets/stway_brand.dart';

void main() {
  testWidgets('App loads splash screen', (tester) async {
    await tester.pumpWidget(const TrilhaApp());
    expect(find.byType(StwayWordmark), findsOneWidget);
    expect(find.textContaining('Bíblia'), findsWidgets);
  });
}
