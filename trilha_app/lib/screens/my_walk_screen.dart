import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../models/difficulty.dart';
import '../models/exercise.dart';
import '../services/analytics_service.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/walk_stats.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/immersive_background.dart';
import '../widgets/relic_panel.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import 'paywall_screen.dart';

/// Minha caminhada (Peregrino+): acerto de primeira por modo e por gesto,
/// com ponto forte e o que reforçar.
///
/// Constância, dias caminhados, cenas e acerto geral ficam no Perfil — esta
/// tela não repete nada disso.
class MyWalkScreen extends StatefulWidget {
  const MyWalkScreen({super.key});

  @override
  State<MyWalkScreen> createState() => _MyWalkScreenState();
}

class _MyWalkScreenState extends State<MyWalkScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logPlusFeatureOpen(
      feature: 'my_walk',
      hasPlus: context.read<SubscriptionService>().hasPlus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = context.watch<ProgressService>();
    final hasPlus = context.watch<SubscriptionService>().hasPlus;
    final stats = WalkStats.from(
      answerCorrect: progress.answerCorrect,
      answerTotal: progress.answerTotal,
    );
    final quiet = stats.answered == 0;

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
                  title: l10n.myWalkTitle,
                  onBack: () => Navigator.pop(context),
                  leadingGlyph: CinematicGlyph.path,
                ),
              ),
              Expanded(
                child: ContentFrame(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.screen,
                      AppSpace.md,
                      AppSpace.screen,
                      AppSpace.xl,
                    ),
                    children: [
                      Center(
                        child: CloudMascot(
                          face: quiet ? CloudFace.triste : CloudFace.feliz,
                          size: 88,
                        ),
                      ),
                      const SizedBox(height: AppSpace.md),
                      Text(
                        l10n.myWalkIntro,
                        textAlign: TextAlign.center,
                        style: AppTypography.body(
                          size: 14,
                          color: Appearance.of(context).textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpace.lg),
                      if (hasPlus) ...[
                        _ModesCard(stats: stats),
                        const SizedBox(height: AppSpace.section),
                        _GesturesCard(stats: stats),
                      ] else
                        _PlusLock(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PaywallScreen(source: 'my_walk'),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModesCard extends StatelessWidget {
  final WalkStats stats;

  const _ModesCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RelicChapter(title: l10n.myWalkModesHeader, divided: false),
          const SizedBox(height: AppSpace.sm),
          Text(
            l10n.myWalkModesBody,
            style: AppTypography.body(size: 12, color: a.textSecondary),
          ),
          const SizedBox(height: AppSpace.md),
          for (final mode in TrailDifficulty.values) ...[
            _MeterRow(label: mode.labelPt, accuracy: stats.byMode[mode]!),
            const SizedBox(height: AppSpace.md),
          ],
        ],
      ),
    );
  }
}

class _MeterRow extends StatelessWidget {
  final String label;
  final Accuracy accuracy;

  const _MeterRow({required this.label, required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final empty = accuracy.total == 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.title(size: 14, color: a.text),
              ),
            ),
            Text(
              empty
                  ? l10n.myWalkNoAnswersYet
                  : l10n.myWalkAccuracyLine(
                      accuracy.percent,
                      accuracy.correct,
                      accuracy.total,
                    ),
              style: AppTypography.body(size: 12, color: a.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AppProgressBar(value: empty ? 0 : accuracy.percent / 100),
      ],
    );
  }
}

class _GesturesCard extends StatelessWidget {
  final WalkStats stats;

  const _GesturesCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final strong = stats.strongest;
    final weak = stats.weakest;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RelicChapter(title: l10n.myWalkGesturesHeader, divided: false),
          const SizedBox(height: AppSpace.md),
          if (stats.byGesture.isEmpty)
            Text(
              l10n.myWalkGesturesEmpty,
              style: AppTypography.body(size: 13, color: a.textSecondary),
            )
          else ...[
            if (strong != null)
              _Highlight(
                glyph: CinematicGlyph.rise,
                label: l10n.myWalkStrongest,
                gesture: strong.$1,
                accuracy: strong.$2,
              ),
            if (weak != null) ...[
              const SizedBox(height: AppSpace.sm),
              _Highlight(
                glyph: CinematicGlyph.target,
                label: l10n.myWalkToStrengthen,
                gesture: weak.$1,
                accuracy: weak.$2,
              ),
            ],
            if (strong == null)
              Text(
                l10n.myWalkGesturesFew(WalkStats.minGestureAnswers),
                style: AppTypography.body(size: 12, color: a.textFaint),
              ),
            const SizedBox(height: AppSpace.lg),
            for (final (type, acc) in stats.byGesture) ...[
              _MeterRow(label: type.labelPt, accuracy: acc),
              const SizedBox(height: AppSpace.md),
            ],
          ],
        ],
      ),
    );
  }
}

class _Highlight extends StatelessWidget {
  final CinematicGlyph glyph;
  final String label;
  final ExerciseType gesture;
  final Accuracy accuracy;

  const _Highlight({
    required this.glyph,
    required this.label,
    required this.gesture,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: a.insetFill,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: a.insetBorder),
      ),
      child: Row(
        children: [
          CinematicIcon(
            glyph: glyph,
            size: AppMetrics.iconLg,
            accent: a.chrome,
            framed: false,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.body(size: 12, color: a.textSecondary),
                ),
                Text(
                  gesture.labelPt,
                  style: AppTypography.title(size: 15, color: a.text),
                ),
              ],
            ),
          ),
          Text(
            '${accuracy.percent}%',
            style: AppTypography.title(size: 15, color: a.text),
          ),
        ],
      ),
    );
  }
}

class _PlusLock extends StatelessWidget {
  final VoidCallback onTap;

  const _PlusLock({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.lock,
                size: AppMetrics.iconLg,
                accent: a.chrome,
                framed: false,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Text(
                  l10n.myWalkPlusTitle,
                  style: AppTypography.title(size: 15, color: a.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            l10n.myWalkPlusBody,
            style: AppTypography.body(size: 13, color: a.textSecondary),
          ),
          const SizedBox(height: AppSpace.lg),
          CopperCta(
            label: l10n.weeklyReviewSeePlus,
            expanded: true,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}
