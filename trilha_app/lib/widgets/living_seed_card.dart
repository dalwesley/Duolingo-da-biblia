import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/spiritual_growth.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';

/// Companion emocional próprio da Trilha — crescimento por streak, sem pet genérico.
class LivingSeedCard extends StatelessWidget {
  const LivingSeedCard({super.key});

  CinematicGlyph _glyph(GrowthStage stage) {
    return switch (stage) {
      GrowthStage.seed => CinematicGlyph.seed,
      GrowthStage.sprout => CinematicGlyph.tree,
      GrowthStage.sapling => CinematicGlyph.tree,
      GrowthStage.olive => CinematicGlyph.tree,
      GrowthStage.lamp => CinematicGlyph.lamp,
    };
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final growth = SpiritualGrowth.fromStreak(progress.streak);
    final a = Appearance.of(context);

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                Text(
                  'SUA SEMENTE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    color: AppColors.accent.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  growth.title,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: a.text,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  growth.subtitle,
                  style: TextStyle(fontSize: 12, color: a.textMuted(0.6)),
                ),
                if (growth.stage != GrowthStage.lamp) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: growth.progressToNext,
                      minHeight: 4,
                      backgroundColor: a.progressTrack,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
