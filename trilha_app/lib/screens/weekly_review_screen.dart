import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/question_bank.dart';
import '../data/trail_repository.dart';
import '../l10n/app_language.dart';
import '../models/difficulty.dart';
import '../models/season_walk.dart';
import '../models/trail.dart';
import '../services/analytics_service.dart';
import '../services/content_catalog_service.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/immersive_background.dart';
import '../widgets/relic_panel.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import 'lesson_screen.dart';
import 'paywall_screen.dart';

/// Revisão da semana (Peregrino+): o "Hoje:" de cada cena feita na semana e
/// 3 perguntas tiradas delas, de preferência as que a pessoa errou.
///
/// Sem Peregrino+, mostra quantas e quais cenas foram — sem os "Hoje:" nem as
/// perguntas — e leva ao paywall.
class WeeklyReviewScreen extends StatefulWidget {
  const WeeklyReviewScreen({super.key});

  @override
  State<WeeklyReviewScreen> createState() => _WeeklyReviewScreenState();
}

typedef _Scene = ({Mission mission, Trail trail});

class _WeeklyReviewScreenState extends State<WeeklyReviewScreen> {
  late final String _week;
  List<_Scene>? _scenes;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    final progress = context.read<ProgressService>();
    _week = progress.weeklyReviewWeekKey();
    AnalyticsService.instance.logPlusFeatureOpen(
      feature: 'weekly_review',
      hasPlus: context.read<SubscriptionService>().hasPlus,
    );
    _load();
  }

  Future<void> _load() async {
    final slugs = context.read<ProgressService>().missionsCompletedInWeek(
      _week,
    );
    final trails = await TrailRepository().getTrails();
    final bySlug = <String, _Scene>{
      for (final trail in trails)
        for (final mod in trail.modules)
          for (final mission in mod.missions)
            mission.slug: (mission: mission, trail: trail),
    };
    if (!mounted) return;
    setState(() {
      _scenes = [
        for (final slug in slugs)
          if (bySlug[slug] != null) bySlug[slug]!,
      ];
    });
  }

  String _range(AppLocalizations l10n) {
    final monday = DateTime.parse(_week);
    final sunday = DateTime(monday.year, monday.month, monday.day + 6);
    String fmt(DateTime d) =>
        DateFormat('d MMM', l10n.localeName).format(d).replaceAll('.', '');
    return l10n.weeklyReviewRange(fmt(monday), fmt(sunday));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasPlus = context.watch<SubscriptionService>().plusFeaturesOpen;
    final done = context.select(
      (ProgressService p) => p.isWeeklyReviewDone(_week),
    );
    final scenes = _scenes;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ImmersiveBackground(
        frameChild: false,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.screen,
                ),
                child: TopBar(
                  title: l10n.weeklyReviewTitle,
                  subtitle: _range(l10n),
                  onBack: () => Navigator.pop(context),
                  leadingGlyph: CinematicGlyph.scroll,
                ),
              ),
              Expanded(
                child: ContentFrame(
                  child: scenes == null
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpace.screen,
                            AppSpace.md,
                            AppSpace.screen,
                            AppSpace.xl,
                          ),
                          children: _body(
                            context,
                            scenes: scenes,
                            hasPlus: hasPlus,
                            done: done,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _body(
    BuildContext context, {
    required List<_Scene> scenes,
    required bool hasPlus,
    required bool done,
  }) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final empty = scenes.length < ProgressService.weeklyReviewMinScenes;
    final face = empty
        ? CloudFace.triste
        : done
        ? CloudFace.sucesso
        : CloudFace.feliz;

    return [
      Center(child: CloudMascot(face: face, size: 96)),
      const SizedBox(height: AppSpace.md),
      Text(
        empty
            ? l10n.weeklyReviewEmptyTitle
            : l10n.weeklyReviewHeadline(scenes.length),
        textAlign: TextAlign.center,
        style: AppTypography.display(size: 24, color: a.text),
      ),
      const SizedBox(height: AppSpace.sm),
      Text(
        empty
            ? l10n.weeklyReviewEmptyBody(ProgressService.weeklyReviewMinScenes)
            : done
            ? l10n.weeklyReviewDoneBody
            : hasPlus
            ? l10n.weeklyReviewIntro
            : l10n.weeklyReviewPlusBody,
        textAlign: TextAlign.center,
        style: AppTypography.body(size: 14, color: a.textSecondary),
      ),
      if (!empty) ...[
        const SizedBox(height: AppSpace.xl),
        if (hasPlus)
          RelicChapter(title: l10n.weeklyReviewInsightsHeader, divided: false),
        if (hasPlus) const SizedBox(height: 12),
        for (final scene in scenes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SceneCard(scene: scene, showInsight: hasPlus),
          ),
        const SizedBox(height: AppSpace.lg),
        if (!hasPlus)
          CopperCta(
            label: l10n.weeklyReviewSeePlus,
            expanded: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PaywallScreen(source: 'weekly_review'),
              ),
            ),
          )
        else if (!done)
          CopperCta(
            label: _starting
                ? l10n.weeklyReviewPreparing
                : l10n.weeklyReviewStart,
            expanded: true,
            onTap: _starting ? null : () => _start(scenes),
          ),
      ],
    ];
  }

  /// Até 3 perguntas, uma por cena em rodízio, preferindo as erradas.
  Future<void> _start(List<_Scene> scenes) async {
    setState(() => _starting = true);
    final progress = context.read<ProgressService>();
    for (final slug in {for (final s in scenes) s.trail.slug}) {
      await ContentCatalogService.instance.ensureTrailBank(slug);
    }
    final pools = <List<String>>[];
    for (final scene in scenes) {
      final pool = await QuestionBank.instance.listForMission(
        difficulty:
            TrailDifficulty.fromId(
              progress.difficultyForTrail(scene.trail.slug),
            ) ??
            TrailDifficulty.semente,
        moduleTitle: null,
        section: scene.mission.slug,
        trailSlug: scene.trail.slug,
      );
      pools.add([for (final q in pool) q.id]);
    }
    final ids = <String>[];
    for (var round = 0; ids.length < 3 && round < 3; round++) {
      for (final pool in pools) {
        if (ids.length >= 3) break;
        final id = SeasonWalkAccess.pickReviewActId(
          poolIds: pool.where((id) => !ids.contains(id)),
          mistakeIds: progress.mistakeQuestionIds,
          usedIds: progress.usedQuestionIds,
        );
        if (id != null) ids.add(id);
      }
    }
    if (!mounted) return;
    setState(() => _starting = false);
    if (ids.isEmpty) {
      showAppToastFor(
        context,
        message: context.l10n.weeklyReviewNoQuestions,
        face: CloudFace.erro,
      );
      return;
    }
    final insights = [
      for (final s in scenes)
        if ((s.mission.localizedCentralInsight ?? '').trim().isNotEmpty)
          s.mission.localizedCentralInsight!.trim(),
    ];
    final review = Mission(
      slug: '${ProgressService.weeklyReviewSlugPrefix}$_week',
      title: context.l10n.weeklyReviewMissionTitle,
      intro: context.l10n.weeklyReviewMissionIntro,
      type: 'lesson',
      stepsReward: 30,
      questions: const [],
      centralInsight: insights.take(3).join(' · '),
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          missionSlug: review.slug,
          practiceMode: true,
          missionOverride: review,
          questionIdsOverride: ids,
        ),
      ),
    );
    if (!mounted) return;
    if (context.read<ProgressService>().isWeeklyReviewDone(_week)) {
      AnalyticsService.instance.logEvent('weekly_review_complete', {
        'scenes': scenes.length,
        'questions': ids.length,
      });
    }
  }
}

class _SceneCard extends StatelessWidget {
  final _Scene scene;
  final bool showInsight;

  const _SceneCard({required this.scene, required this.showInsight});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final insight = scene.mission.localizedCentralInsight?.trim() ?? '';
    return GlassCard(
      padding: AppMetrics.cardPaddingCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.weeklyReviewSceneLine(
              scene.trail.localizedTitle,
              scene.mission.localizedTitle,
            ),
            style: AppTypography.body(size: 12, color: a.textFaint),
          ),
          if (showInsight && insight.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              context.l10n.weeklyReviewTodayInsight(insight),
              style: AppTypography.title(size: 14, color: a.text),
            ),
          ],
        ],
      ),
    );
  }
}
