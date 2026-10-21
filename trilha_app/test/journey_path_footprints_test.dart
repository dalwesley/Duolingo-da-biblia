import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/l10n/app_language.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/models/trail_catalog.dart';
import 'package:trilha_app/theme/app_theme.dart';
import 'package:trilha_app/widgets/cloud_mascot.dart';
import 'package:trilha_app/widgets/journey_path.dart';
import 'package:trilha_app/widgets/winding_trail.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Trail trail(String slug, String title, int order) {
    return Trail(
      slug: slug,
      title: title,
      description: 'Descrição',
      icon: '📖',
      order: order,
      comingSoon: false,
      color: '#D4A84B',
      modules: [
        TrailModule(
          title: 'Módulo',
          icon: '🌍',
          missions: [
            Mission(
              slug: '$slug-m1',
              title: 'Cena',
              intro: '',
              type: 'lesson',
              stepsReward: 50,
              questions: const [],
            ),
          ],
        ),
      ],
    );
  }

  JourneyPathItem item(Trail trail, JourneyNodeState state) {
    return JourneyPathItem(
      trail: trail,
      state: state,
      category: TrailCategory.pentateuco,
      done: state == JourneyNodeState.completed ? 1 : 0,
      total: 1,
    );
  }

  Future<void> pumpPath(
    WidgetTester tester,
    List<JourneyPathItem> items, {
    bool phaseCards = true,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          );
        },
        home: Scaffold(
          body: JourneyPath(
            items: items,
            accent: AppColors.accent,
            glow: AppColors.accent,
            onTap: (_) {},
            phaseCards: phaseCards,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Rect cardOf(WidgetTester tester, String title) {
    return tester.getRect(
      find.ancestor(
        of: find.text(title),
        matching: find.byType(JourneyStationCard),
      ),
    );
  }

  void expectAnanAtEntrance(WidgetTester tester, String title) {
    final anan = tester.getRect(find.byType(CloudMascot));
    final card = cardOf(tester, title);
    expect(
      (anan.center.dy - card.center.dy).abs(),
      lessThan(8),
      reason: 'Anan fora da entrada de $title',
    );
    final onLeft =
        (anan.right - card.left).abs() <= 16 && anan.center.dx < card.center.dx;
    final onRight =
        (anan.left - card.right).abs() <= 16 && anan.center.dx > card.center.dx;
    expect(
      onLeft || onRight,
      isTrue,
      reason: 'Anan não está na borda de $title\nanan=$anan\ncard=$card',
    );
  }

  testWidgets('pegadas param no card atual e o Anan fica na entrada', (
    tester,
  ) async {
    final gen1 = trail('genesis-1-11', 'Gênesis 1-11', 1);
    final gen2 = trail('genesis-12-50', 'Gênesis 12-50', 2);
    final exodus = trail('exodo', 'Êxodo', 3);

    await pumpPath(tester, [
      item(gen1, JourneyNodeState.current),
      item(gen2, JourneyNodeState.locked),
      item(exodus, JourneyNodeState.locked),
    ]);

    final trailWidget = tester.widget<FlowingWindingTrail>(
      find.byType(FlowingWindingTrail),
    );
    expect(trailWidget.showAhead, isFalse);
    expectAnanAtEntrance(tester, 'Gênesis 1-11');

    await pumpPath(tester, [
      item(gen1, JourneyNodeState.completed),
      item(gen2, JourneyNodeState.current),
      item(exodus, JourneyNodeState.locked),
    ]);
    expectAnanAtEntrance(tester, 'Gênesis 12-50');

    await pumpPath(tester, [
      item(gen1, JourneyNodeState.completed),
      item(gen2, JourneyNodeState.completed),
      item(exodus, JourneyNodeState.current),
    ]);
    expectAnanAtEntrance(tester, 'Êxodo');
  });

  testWidgets('sem marco, o Anan senta na base do primeiro card', (
    tester,
  ) async {
    final gen1 = trail('genesis-1-11', 'Gênesis 1-11', 1);
    final gen2 = trail('genesis-12-50', 'Gênesis 12-50', 2);

    await pumpPath(
      tester,
      [
        item(gen1, JourneyNodeState.current),
        item(gen2, JourneyNodeState.locked),
      ],
      phaseCards: false,
    );

    final anan = tester.getRect(find.byType(CloudMascot));
    final card = cardOf(tester, 'Gênesis 1-11');
    final next = cardOf(tester, 'Gênesis 12-50');
    expect(
      (anan.center.dx - card.center.dx).abs(),
      lessThan(8),
      reason: 'Anan fora do conector da base\nanan=$anan\ncard=$card',
    );
    expect((anan.top - card.bottom).abs(), lessThan(16));
    expect(anan.bottom, lessThanOrEqualTo(next.top + 1));
  });
}
