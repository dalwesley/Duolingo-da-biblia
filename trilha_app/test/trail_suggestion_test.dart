import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/trail_suggestion_service.dart';
import 'package:trilha_app/theme/app_theme.dart';
import 'package:trilha_app/widgets/coming_soon_trails_card.dart';

void main() {
  test('normalize trims, collapses spaces and clips at max', () {
    expect(TrailSuggestionService.normalize('  Salmos   de   Davi  '), 'Salmos de Davi');
    expect(
      TrailSuggestionService.normalize('a' * 500).length,
      TrailSuggestionService.maxText,
    );
  });

  test('text needs at least four characters', () {
    expect(TrailSuggestionService.isValidText('Rute'), isTrue);
    expect(TrailSuggestionService.isValidText('  hi  '), isFalse);
    expect(TrailSuggestionService.isValidText(''), isFalse);
  });

  test('realm id must be a known path, including outros', () {
    expect(TrailSuggestionService.isValidRealmId(null), isFalse);
    expect(TrailSuggestionService.isValidRealmId(''), isFalse);
    expect(TrailSuggestionService.isValidRealmId('vida-crista'), isTrue);
    expect(TrailSuggestionService.isValidRealmId('outros'), isTrue);
    expect(TrailSuggestionService.isValidRealmId('unknown'), isFalse);
    expect(
      TrailSuggestionRealm.values.map((r) => r.id).toList(),
      [
        'antigo-testamento',
        'novo-testamento',
        'vida-crista',
        'teologia',
        'outros',
      ],
    );
  });

  testWidgets('coming soon card shows launch copy and suggest action', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: ComingSoonTrailsCard(onSuggest: () => taps++),
        ),
      ),
    );

    expect(find.text('Lançamentos em breve'), findsOneWidget);
    expect(find.text('SUGERIR UMA TRILHA'), findsOneWidget);

    await tester.tap(find.text('Lançamentos em breve'));
    expect(taps, 1);
  });
}
