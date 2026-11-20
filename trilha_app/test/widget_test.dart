import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/main.dart';
import 'package:trilha_app/widgets/stway_brand.dart';

void main() {
  testWidgets('App loads splash screen', (tester) async {
    await tester.pumpWidget(const TrilhaApp());
    expect(find.byType(StwayWordmark), findsOneWidget);
    // O slogan "A Bíblia, cena a cena" saiu da splash; hoje ela mostra a
    // marca, o lema e o "preparando" (traduzido conforme o aparelho).
    expect(find.byType(StwayTagline), findsOneWidget);
    expect(find.textContaining('UMA JORNADA'), findsOneWidget);
  });
}
