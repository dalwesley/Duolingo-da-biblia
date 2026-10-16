import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

/// Minha caminhada: o ano mês a mês (aberto a todos) e, no Peregrino+, o
/// acerto de primeira por modo e por gesto.
///
/// Calendário de constância, trilhas e acerto geral já ficam no Perfil.
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
    final year = DateTime.now().year;
    final stats = WalkStats.from(
      answerCorrect: progress.answerCorrect,
      answerTotal: progress.answerTotal,
      missionCompletedOn: progress.missionCompletedOn,
      playDates: progress.playDates,
      year: year,
    );
    final quiet = stats.scenesThisYear == 0 && stats.answered == 0;

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
                      const SizedBox(height: AppSpace.lg),
                      _YearCard(stats: stats, year: year),
                      const SizedBox(height: AppSpace.section),
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

class _YearCard extends StatelessWidget {
  final WalkStats stats;
  final int year;

  const _YearCard({required this.stats, required this.year});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RelicChapter(title: l10n.myWalkYearHeader(year), divided: false),
          const SizedBox(height: AppSpace.md),
          Row(
            children: [
              Expanded(
                child: _Figure(
                  value: '${stats.daysWalkedThisYear}',
                  label: l10n.myWalkDaysLabel(stats.daysWalkedThisYear),
                ),
              ),
              Expanded(
                child: _Figure(
                  value: '${stats.scenesThisYear}',
                  label: l10n.myWalkScenesLabel(stats.scenesThisYear),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          _MonthBars(perMonth: stats.scenesPerMonth),
          if (stats.scenesThisYear == 0) ...[
            const SizedBox(height: AppSpace.sm),
            Text(
              l10n.myWalkYearEmpty,
              textAlign: TextAlign.center,
              style: AppTypography.body(size: 12, color: a.textFaint),
            ),
          ],
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  final String value;
  final String label;

  const _Figure({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      children: [
        Text(value, style: AppTypography.display(size: 28, color: a.text)),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.body(size: 12, color: a.textSecondary),
        ),
      ],
    );
  }
}

/// Cenas novas por mês: uma série, uma cor, número só no pico.
class _MonthBars extends StatelessWidget {
  final List<int> perMonth;

  const _MonthBars({required this.perMonth});

  static const _height = 72.0;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final peak = perMonth.fold(0, (m, v) => v > m ? v : m);
    final peakIndex = peak == 0 ? -1 : perMonth.indexOf(peak);
    final current = DateTime.now().month - 1;
    final initials = DateFormat.MMM(l10n.localeName);

    return Semantics(
      label: l10n.myWalkMonthsSemantics(perMonth.fold(0, (s, v) => s + v)),
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var m = 0; m < 12; m++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 16,
                        child: m == peakIndex
                            ? Text(
                                '$peak',
                                style: AppTypography.body(
                                  size: 11,
                                  weight: FontWeight.w700,
                                  color: a.text,
                                ),
                              )
                            : null,
                      ),
                      Container(
                        height: peak == 0
                            ? 2
                            : (perMonth[m] / peak * _height).clamp(
                                2.0,
                                _height,
                              ),
                        decoration: BoxDecoration(
                          color: perMonth[m] == 0 ? a.insetFill : a.chrome,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        initials
                            .format(DateTime(2000, m + 1))
                            .substring(0, 1)
                            .toUpperCase(),
                        style: AppTypography.body(
                          size: 10,
                          weight: m == current
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: m == current ? a.text : a.textFaint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
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
