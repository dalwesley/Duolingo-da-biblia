import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';
import '../l10n/app_language.dart';

/// Oferta de reparo — restaura a sequência após faltar 1 dia (1×/mês).
class StreakRepairBanner extends StatelessWidget {
  const StreakRepairBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    if (!progress.showStreakRepairOffer) return const SizedBox.shrink();

    final a = Appearance.of(context);
    final broken = progress.brokenStreak;
    final restored = broken + 1;

    return GlassCard(
      elevated: true,
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.frost,
                size: AppMetrics.leadingIcon,
                accent: AppColors.streak,
                glowing: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.streakRepairTitle,
                      style: AppTypography.title(size: 16, color: a.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.streakRepairBody(broken, restored),
                      style: AppTypography.body(
                        size: 12,
                        height: 1.35,
                        weight: FontWeight.w600,
                        color: a.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: CopperCta(
                  label: context.l10n.streakRepairAction,
                  trailing: CinematicGlyph.flame,
                  onTap: () async {
                    final ok = await progress.claimStreakRepair();
                    if (!context.mounted || !ok) return;
                    showAppToastFor(
                      context,
                      message: context.l10n.streakRepairDone(restored),
                      glyph: CinematicGlyph.flame,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              TextCta(
                label: context.l10n.streakRepairDismiss,
                color: a.textFaint,
                onTap: () async {
                  await progress.dismissStreakRepair();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Oferta na celebração — quieta, sem segundo CTA ouro.
class StreakRepairCelebrationCard extends StatelessWidget {
  const StreakRepairCelebrationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    if (!progress.showStreakRepairOffer) return const SizedBox.shrink();

    final a = Appearance.of(context);
    final broken = progress.brokenStreak;
    final restored = broken + 1;

    return GlassCard(
      tint: AppColors.streak,
      padding: AppMetrics.cardPaddingCompact,
      child: Row(
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.flame,
            size: 36,
            accent: AppColors.streak,
            framed: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.streakRepairCanReturn(broken),
                  style: AppTypography.title(size: 14, color: a.text),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.streakRepairContinueWith(restored),
                  style: AppTypography.body(
                    size: 12,
                    height: 1.3,
                    weight: FontWeight.w600,
                    color: a.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextCta(
            label: context.l10n.streakRepairAction,
            color: AppColors.streak,
            onTap: () async {
              await progress.claimStreakRepair();
            },
          ),
        ],
      ),
    );
  }
}
