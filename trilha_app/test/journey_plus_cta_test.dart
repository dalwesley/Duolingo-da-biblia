import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/l10n/app_language.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/models/trail_catalog.dart';
import 'package:trilha_app/theme/app_theme.dart';
import 'package:trilha_app/widgets/journey_path.dart';
import 'package:trilha_app/widgets/ui_primitives.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final bold = await rootBundle.load('assets/fonts/Nunito-Bold.ttf');
    final loader = FontLoader('Nunito_700')..addFont(Future.value(bold));
    await loader.load();
  });

  Trail trail() {
    return Trail(
      slug: 'ansiedade',
      title: 'Ansiedade',
      description: 'Descrição',
      icon: '📖',
      order: 1,
      comingSoon: false,
      color: '#D4A84B',
      modules: [
        TrailModule(
          title: 'Módulo',
          icon: '🌍',
          missions: [
            Mission(
              slug: 'ansiedade-m1',
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

  testWidgets('o botão Peregrino+ cabe em duas linhas inteiras', (
    tester,
  ) async {
    // Redmi Note 8: 1080 px / 2.75 = 393 dp.
    await tester.binding.setSurfaceSize(const Size(393, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final item = JourneyPathItem(
      trail: trail(),
      state: JourneyNodeState.current,
      category: TrailCategory.discipulado,
      done: 2,
      total: 4,
      plusLocked: true,
      activeDifficultyId: 'semente',
    );

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
            items: [item],
            accent: AppColors.accent,
            glow: AppColors.accent,
            onTap: (_) {},
            phaseCards: false,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('com o Peregrino+'), findsOneWidget);
    // O nome não volta cortado no canto do card ("Peregr…").
    expect(find.textContaining('Peregr'), findsOneWidget);

    final line = tester.getSize(find.text('com o Peregrino+'));
    final verb = tester.getSize(find.text('Continuar'));
    expect(line.height, lessThan(22), reason: 'a segunda linha quebrou');
    expect(verb.height, lessThan(22), reason: 'Continuar quebrou');

    final button = tester.getSize(find.byType(CopperCta));
    final card = tester.getSize(find.byType(JourneyStationCard));
    expect(button.height, lessThan(64));
    expect(button.width, greaterThan(card.width * 0.8));

    final detail = tester.widget<Text>(find.text('com o Peregrino+'));
    final style = DefaultTextStyle.of(
      tester.element(find.text('com o Peregrino+')),
    ).style.merge(detail.style);
    final painter = TextPainter(
      text: TextSpan(text: 'com o Peregrino+', style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    expect(
      line.width,
      greaterThanOrEqualTo(painter.width - 1),
      reason: '“com o Peregrino+” foi cortado com reticências',
    );
    // padding 12+12 e ícone 20+8. A frase precisa de folga, não só caber.
    final room = button.width - 24 - 28;
    expect(painter.width, lessThan(room - 8));
  });
}
