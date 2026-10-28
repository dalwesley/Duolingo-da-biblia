import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/l10n/app_language.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/models/trail_catalog.dart';
import 'package:trilha_app/theme/app_theme.dart';
import 'package:trilha_app/widgets/cinematic_icon.dart';
import 'package:trilha_app/widgets/journey_path.dart';
import 'package:trilha_app/widgets/ui_primitives.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final bold = await rootBundle.load('assets/fonts/Nunito-Bold.ttf');
    final loader = FontLoader('Nunito_700')..addFont(Future.value(bold));
    await loader.load();
  });

  Trail trail({String title = 'Ansiedade'}) {
    return Trail(
      slug: 'ansiedade',
      title: title,
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

  testWidgets('trilha Plus fora da estação em curso: cadeado, sem botão', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Título de duas linhas: o botão ainda cabe no card padrão.
    final item = JourneyPathItem(
      trail: trail(title: 'Família e Relacionamentos'),
      state: JourneyNodeState.upcoming,
      category: TrailCategory.discipulado,
      total: 4,
      plusLocked: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
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
    // Sem botão: o amarelo fica só na estação em curso.
    expect(find.byType(CopperCta), findsNothing);
    expect(tester.getSize(find.byType(JourneyStationCard)).height, 129);
    expect(find.text('Só no Peregrino+'), findsOneWidget);
    final plate = find.byWidgetPredicate(
      (w) => w is CinematicIcon && w.glyph == CinematicGlyph.lock,
    );
    expect(plate, findsOneWidget);
  });

  testWidgets('fonte grande do app (1,35×): card Plus não estoura', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final state in [
      JourneyNodeState.current,
      JourneyNodeState.upcoming,
      JourneyNodeState.locked,
    ]) {
      final item = JourneyPathItem(
        trail: trail(title: 'Família e Relacionamentos'),
        state: state,
        category: TrailCategory.discipulado,
        done: 1,
        total: 4,
        plusLocked: state != JourneyNodeState.locked,
        lockedBy: 'Sermão do Monte',
        activeDifficultyId: 'semente',
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.35),
              disableAnimations: true,
            ),
            child: child!,
          ),
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
      expect(tester.takeException(), isNull, reason: '$state estourou');
    }
  });
}
