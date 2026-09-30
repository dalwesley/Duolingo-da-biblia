import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/theme/app_theme.dart';
import 'package:trilha_app/widgets/cinematic_icon.dart';
import 'package:trilha_app/widgets/set_piece.dart';

import 'helpers/l10n.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('SetPieceMemory', () {
    test('each moment is claimed only once', () async {
      expect(await SetPieceMemory.claim('streak:7'), isTrue);
      expect(await SetPieceMemory.claim('streak:7'), isFalse);
      expect(await SetPieceMemory.claim('streak:30'), isTrue);
    });

    test('first open only records the season; a change turns it', () async {
      expect(await SetPieceMemory.seasonTurned('ordinary'), isFalse);
      expect(await SetPieceMemory.seasonTurned('ordinary'), isFalse);
      expect(await SetPieceMemory.seasonTurned('advent'), isTrue);
      expect(await SetPieceMemory.seasonTurned('advent'), isFalse);
    });

    test('streak milestones are the goal and the round numbers', () {
      expect(SetPieceMemory.isStreakMilestone(14, goal: 14), isTrue);
      expect(SetPieceMemory.isStreakMilestone(7, goal: 30), isTrue);
      expect(SetPieceMemory.isStreakMilestone(100, goal: 7), isTrue);
      expect(SetPieceMemory.isStreakMilestone(8, goal: 7), isFalse);
      expect(SetPieceMemory.isStreakMilestone(0, goal: 7), isFalse);
    });
  });

  testWidgets('stage plays out, shows the words and closes on the CTA', (
    tester,
  ) async {
    var closed = false;
    await tester.pumpWidget(
      l10nApp(
        Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () async {
                await showSetPiece(
                  context,
                  const SetPiece(
                    eyebrow: 'Trilha concluída',
                    title: 'Gênesis 1–11',
                    line: 'Você chegou ao fim desta trilha.',
                    glyph: CinematicGlyph.flag,
                    light: AppRoles.reward,
                    cta: 'Continuar',
                  ),
                );
                closed = true;
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2400));

    expect(find.text('Gênesis 1–11'), findsOneWidget);
    expect(find.text('Você chegou ao fim desta trilha.'), findsOneWidget);

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
    expect(find.text('Gênesis 1–11'), findsNothing);
  });
}
