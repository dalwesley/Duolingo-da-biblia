import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/services/progress_service.dart';
import 'package:trilha_app/theme/app_theme.dart';
import 'package:trilha_app/widgets/hero_card_atmosphere.dart';
import 'package:trilha_app/widgets/hero_continue_card.dart';
import 'package:trilha_app/widgets/ui_primitives.dart';

void main() {
  test('walked today stays alive even if ice was used', () {
    expect(
      resolveHeroCardMood(
        atRisk: false,
        yesterdayFrozen: true,
        walkedToday: true,
        returningAfterGap: false,
      ),
      HeroCardMood.alive,
    );
  });

  test('ice covering yesterday freezes the card until today is walked', () {
    expect(
      resolveHeroCardMood(
        atRisk: true,
        yesterdayFrozen: true,
        walkedToday: false,
        returningAfterGap: false,
      ),
      HeroCardMood.frozen,
    );
  });

  test('at-risk today without ice cover is dusty', () {
    expect(
      resolveHeroCardMood(
        atRisk: true,
        yesterdayFrozen: false,
        walkedToday: false,
        returningAfterGap: false,
      ),
      HeroCardMood.dusty,
    );
  });

  test('ice used earlier this week does not protect a new gap', () {
    expect(
      resolveHeroCardMood(
        atRisk: false,
        yesterdayFrozen: false,
        walkedToday: false,
        returningAfterGap: true,
      ),
      HeroCardMood.dusty,
    );
  });

  test('hero stage is a palco, not a tile', () {
    expect(AppMetrics.heroStageHeight(800), 416);
    expect(AppMetrics.heroStageHeight(600), 380);
    expect(AppMetrics.heroStageHeight(1200), 520);
  });

  testWidgets('home CTA fills about half the phone', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const mission = Mission(
      slug: 'salmo-23',
      title: 'O Senhor é o meu pastor',
      subtitle: 'O pastor guia — inclusive no vale.',
      intro: '',
      type: 'lesson',
      stepsReward: 60,
      questions: [],
      hookNote: 'O pastor guia — inclusive no vale.',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ProgressService(),
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: HeroContinueCard(
              mission: mission,
              trailTitle: 'Ansiedade',
              trailSlug: 'ansiedade',
              goalMet: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('O Senhor é o meu pastor'), findsOneWidget);
    expect(find.text('AMANHÃ'), findsOneWidget);
    expect(find.text('ABRIR AGORA'), findsOneWidget);

    final card = tester.getSize(find.byType(HeroContinueCard));
    expect(card.height, AppMetrics.heroStageHeight(800));
    expect(card.height, greaterThanOrEqualTo(380));
  });
}
