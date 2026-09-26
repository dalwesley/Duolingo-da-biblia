import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/trail_suggestion_service.dart';
import 'package:trilha_app/theme/app_theme.dart';
import 'package:trilha_app/widgets/coming_soon_trails_card.dart';
import 'package:trilha_app/widgets/ui_primitives.dart';

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

  testWidgets('coming soon card suggests a trail or an author', (tester) async {
    var trailTaps = 0;
    var authorTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: ComingSoonTrailsCard(
            onSuggest: () => trailTaps++,
            onSuggestAuthor: () => authorTaps++,
          ),
        ),
      ),
    );

    expect(find.text('Lançamentos em breve'), findsOneWidget);
    expect(find.text('Sugerir uma trilha'), findsOneWidget);
    expect(find.text('Sugerir um autor'), findsOneWidget);

    await tester.tap(find.text('Lançamentos em breve'));
    expect(trailTaps, 1);
    expect(authorTaps, 0);

    await tester.tap(find.text('Sugerir um autor'));
    await tester.pump();
    expect(trailTaps, 1);
    expect(authorTaps, 1);
  });

  testWidgets('donate card is a solid gift band and opens donate', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: DonateCard(onDonate: () => taps++),
        ),
      ),
    );

    expect(find.text('Ajude a continuar'), findsOneWidget);
    expect(find.text('Doar'), findsOneWidget);
    expect(find.byType(CopperCta), findsOneWidget);

    await tester.tap(find.text('Doar'));
    expect(taps, 1);
  });
}
