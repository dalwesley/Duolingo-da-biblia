import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/spiritual_growth.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Marcos da sequência — progresso de hábito, sem pet genérico.
class LivingSeedCard extends StatelessWidget {
  const LivingSeedCard({super.key});

  CinematicGlyph _glyph(GrowthStage stage) {
    return switch (stage) {
      GrowthStage.seed => CinematicGlyph.spark,
      GrowthStage.sprout => CinematicGlyph.flame,
      GrowthStage.sapling => CinematicGlyph.path,
      GrowthStage.olive => CinematicGlyph.crown,
      GrowthStage.lamp => CinematicGlyph.crown,
    };
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final growth = SpiritualGrowth.fromStreak(progress.streak);
    final a = Appearance.of(context);

    return GlassCard(
      padding: AppMetrics.cardPadding,
      child: Row(
        children: [
          CinematicIcon(
            glyph: _glyph(growth.stage),
            size: 52,
            accent: growth.stage == GrowthStage.lamp
                ? AppColors.accent
                : AppColors.primaryLight,
            glowing: false,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CardHeader(label: 'Sequência'),
                const SizedBox(height: 2),
                Text(
                  growth.title,
                  style: AppTypography.display(
                    size: 20,
                    weight: FontWeight.w800,
                    color: a.text,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(
                  growth.subtitle,
                  style: AppTypography.body(
                    size: 12,
                    color: a.textMuted(0.6),
                  ),
                ),
                if (growth.stage != GrowthStage.lamp) ...[
                  const SizedBox(height: AppSpace.sm),
                  AppProgressBar(value: growth.progressToNext),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
