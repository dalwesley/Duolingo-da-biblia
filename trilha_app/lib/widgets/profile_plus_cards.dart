import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../models/difficulty.dart';
import '../models/exercise.dart';
import '../screens/paywall_screen.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/walk_stats.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'relic_panel.dart';
import 'ui_primitives.dart';

/// Perfil · Peregrino+: acerto de primeira por modo e por gesto, com ponto
/// forte e o que reforçar.
class ProfileAccuracyCard extends StatelessWidget {
  const ProfileAccuracyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final progress = context.watch<ProgressService>();
    final stats = WalkStats.from(
      answerCorrect: progress.answerCorrect,
      answerTotal: progress.answerTotal,
    );
    final strong = stats.strongest;
    final weak = stats.weakest;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RelicChapter(title: l10n.profileAccuracyHeader, divided: false),
          const SizedBox(height: AppSpace.sm),
          Text(
            stats.answered == 0
                ? l10n.profileAccuracyEmpty
                : l10n.profileAccuracyBody,
            style: AppTypography.body(size: 12, color: a.textSecondary),
          ),
          if (stats.answered > 0) ...[
            const SizedBox(height: AppSpace.md),
            for (final mode in TrailDifficulty.values) ...[
              _MeterRow(label: mode.labelPt, accuracy: stats.byMode[mode]!),
              const SizedBox(height: AppSpace.md),
            ],
            if (strong != null) ...[
              const SizedBox(height: AppSpace.sm),
              _Highlight(
                glyph: CinematicGlyph.rise,
                label: l10n.profileAccuracyStrongest,
                gesture: strong.$1,
                accuracy: strong.$2,
              ),
            ],
            if (weak != null) ...[
              const SizedBox(height: AppSpace.sm),
              _Highlight(
                glyph: CinematicGlyph.target,
                label: l10n.profileAccuracyToStrengthen,
                gesture: weak.$1,
                accuracy: weak.$2,
              ),
            ],
            if (strong == null)
              Text(
                l10n.profileAccuracyFewGestures(WalkStats.minGestureAnswers),
                style: AppTypography.body(size: 12, color: a.textFaint),
              ),
          ],
        ],
      ),
    );
  }
}

/// Perfil sem Peregrino+: um cartão só no lugar da constância e do acerto.
class ProfilePlusTeaser extends StatelessWidget {
  const ProfilePlusTeaser({super.key});

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
                glyph: CinematicGlyph.crown,
                size: AppMetrics.iconLg,
                accent: a.chrome,
                framed: false,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Text(
                  l10n.profilePlusTeaserTitle,
                  style: AppTypography.title(size: 15, color: a.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            l10n.profilePlusTeaserBody,
            style: AppTypography.body(size: 13, color: a.textSecondary),
          ),
          const SizedBox(height: AppSpace.lg),
          CopperCta(
            label: l10n.weeklyReviewSeePlus,
            expanded: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PaywallScreen(source: 'profile'),
              ),
            ),
          ),
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
                  ? l10n.profileAccuracyNoAnswers
                  : l10n.profileAccuracyLine(
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
