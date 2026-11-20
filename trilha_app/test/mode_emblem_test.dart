import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/l10n/app_language.dart';
import 'package:trilha_app/models/difficulty.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/models/trail_catalog.dart';
import 'package:trilha_app/theme/app_theme.dart';
import 'package:trilha_app/utils/difficulty_visuals.dart';
import 'package:trilha_app/widgets/journey_path.dart';
import 'package:trilha_app/widgets/mode_emblem.dart';

void main() {
  testWidgets('cleared observation emblem is labeled concluída', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: const Scaffold(
          body: ModeEmblem(difficulty: TrailDifficulty.semente, cleared: true),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Observação concluída'), findsOneWidget);
    expect(find.bySemanticsLabel('Observação bloqueada'), findsNothing);
  });

  testWidgets('strip stamps observation and locks interpretation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: const Scaffold(
          body: ModeEmblemStrip(
            clearedModeIds: ['semente'],
            activeDifficultyId: 'semente',
            labeled: true,
            emblemSize: 32,
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Observação concluída'), findsOneWidget);
    expect(find.text('concluída'), findsOneWidget);
    expect(find.byKey(const ValueKey('mode-emblem-caminhada')), findsOneWidget);
    expect(find.bySemanticsLabel('Interpretação bloqueada'), findsOneWidget);
  });

  testWidgets('completed journey station takes the sealed mode color', (
    tester,
  ) async {
    final trail = Trail(
      slug: 'genesis-1-11',
      title: 'Gênesis 1-11',
      description: 'O começo',
      icon: '📖',
      order: 1,
      comingSoon: false,
      color: '#D4A84B',
      modules: const [
        TrailModule(
          title: 'A Criação',
          icon: '🌍',
          missions: [
            Mission(
              slug: 'm1',
              title: 'M1',
              intro: '',
              type: 'lesson',
              stepsReward: 50,
              questions: [],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: Scaffold(
          body: SingleChildScrollView(
            child: JourneyPath(
              items: [
                JourneyPathItem(
                  trail: trail,
                  state: JourneyNodeState.completed,
                  category: TrailCategory.pentateuco,
                  done: 1,
                  total: 1,
                  statusLabel: 'Observação concluída',
                  clearedModeIds: const ['semente'],
                ),
              ],
              accent: AppColors.accent,
              glow: AppColors.accent,
              onTap: (_) {},
            ),
          ),
        ),
      ),
    );

    // Desde a 1.0.36 a estação não carrega mais o selo: o modo selado
    // tinge o card e a linha de status diz qual foi.
    final card = tester.widget<JourneyStationCard>(
      find.byType(JourneyStationCard),
    );
    expect(card.chrome, DifficultyVisuals.accentFor(TrailDifficulty.semente));
    expect(find.text('Observação concluída'), findsOneWidget);
    expect(find.byType(ModeEmblem), findsNothing);
  });

  testWidgets('sealed observation card points to Compreensão', (tester) async {
    final trail = Trail(
      slug: 'genesis-1-11',
      title: 'Gênesis 1-11',
      description: 'O começo',
      icon: '📖',
      order: 1,
      comingSoon: false,
      color: '#D4A84B',
      modules: const [
        TrailModule(
          title: 'A Criação',
          icon: '🌍',
          missions: [
            Mission(
              slug: 'm1',
              title: 'M1',
              intro: '',
              type: 'lesson',
              stepsReward: 50,
              questions: [],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: Scaffold(
          body: SingleChildScrollView(
            child: JourneyPath(
              items: [
                JourneyPathItem(
                  trail: trail,
                  state: JourneyNodeState.completed,
                  category: TrailCategory.pentateuco,
                  done: 1,
                  total: 1,
                  statusLabel: 'Compreensão à frente',
                  clearedModeIds: const ['semente'],
                  activeDifficultyId: 'caminhada',
                ),
              ],
              accent: AppColors.accent,
              glow: AppColors.accent,
              onTap: (_) {},
            ),
          ),
        ),
      ),
    );

    final card = tester.widget<JourneyStationCard>(
      find.byType(JourneyStationCard),
    );
    expect(
      card.chrome,
      DifficultyVisuals.accentFor(TrailDifficulty.caminhada),
    );
    expect(find.text('Compreensão à frente'), findsOneWidget);
  });

  testWidgets('current journey station names the active mode', (tester) async {
    final trail = Trail(
      slug: 'genesis-12-50',
      title: 'Gênesis 12-50',
      description: 'A promessa',
      icon: '📖',
      order: 2,
      comingSoon: false,
      color: '#D4A84B',
      modules: const [
        TrailModule(
          title: 'Abraão',
          icon: '⭐',
          missions: [
            Mission(
              slug: 'n1',
              title: 'N1',
              intro: '',
              type: 'lesson',
              stepsReward: 50,
              questions: [],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: Scaffold(
          body: SingleChildScrollView(
            child: JourneyPath(
              items: [
                JourneyPathItem(
                  trail: trail,
                  state: JourneyNodeState.current,
                  category: TrailCategory.pentateuco,
                  done: 7,
                  total: 23,
                  statusLabel: 'Observação · 7 de 23 passos',
                  activeDifficultyId: 'semente',
                ),
              ],
              accent: AppColors.accent,
              glow: AppColors.accent,
              onTap: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Modo Observação'), findsOneWidget);
    expect(find.text('Faltam 16 cenas'), findsOneWidget);
    expect(find.text('Agora'), findsOneWidget);
    // O card inteiro é o toque; não há mais botão "Entrar".
    expect(find.text('Entrar'), findsNothing);
    expect(find.text('você está aqui'), findsNothing);
  });

  testWidgets('labeled strip reports the tapped mode', (tester) async {
    TrailDifficulty? tapped;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark,
        home: Scaffold(
          body: ModeEmblemStrip(
            clearedModeIds: const ['semente'],
            activeDifficultyId: 'caminhada',
            labeled: true,
            emblemSize: 32,
            onSelect: (d) => tapped = d,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('mode-emblem-semente')));
    await tester.pump();
    expect(tapped, TrailDifficulty.semente);

    await tester.tap(find.byKey(const ValueKey('mode-emblem-caminhada')));
    await tester.pump();
    expect(tapped, TrailDifficulty.caminhada);
  });
}
