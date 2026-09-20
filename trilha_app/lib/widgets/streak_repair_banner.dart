import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

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
                size: 40,
                accent: AppColors.streak,
                glowing: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reparar sequência',
                      style: AppTypography.title(size: 14, color: a.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Você tinha $broken dias. Restaure para $restored — 1× neste mês.',
                      style: AppTypography.body(
                        size: 12,
                        height: 1.35,
                        weight: FontWeight.w600,
                        color: a.textMuted(0.7),
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
                  label: 'Reparar',
                  trailing: CinematicGlyph.flame,
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    final ok = await progress.claimStreakRepair();
                    if (!context.mounted || !ok) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sequência restaurada · $restored dias',
                          style: AppTypography.body(
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: AppColors.streak.withValues(alpha: 0.92),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () async {
                  await progress.dismissStreakRepair();
                },
                child: Text(
                  'Deixar',
                  style: AppTypography.body(
                    weight: FontWeight.w700,
                    color: a.textMuted(0.55),
                  ),
                ),
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
                  '$broken dias ainda podem voltar',
                  style: AppTypography.title(size: 14, color: a.text),
                ),
                const SizedBox(height: 2),
                Text(
                  'Segue com $restored · 1× neste mês',
                  style: AppTypography.body(
                    size: 12,
                    height: 1.3,
                    weight: FontWeight.w600,
                    color: a.textMuted(0.7),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              await progress.claimStreakRepair();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Reparar',
              style: AppTypography.title(
                size: 13,
                color: AppColors.streak,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
