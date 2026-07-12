import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/main.dart';

void main() {
  testWidgets('App loads splash screen', (tester) async {
    await tester.pumpWidget(const TrilhaApp());
    expect(find.text('Trilha'), findsOneWidget);
  });
}
