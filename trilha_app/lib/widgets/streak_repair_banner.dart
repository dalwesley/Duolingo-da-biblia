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

/// Card compacto na tela de celebração.
class StreakRepairCelebrationCard extends StatelessWidget {
  const StreakRepairCelebrationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    if (!progress.showStreakRepairOffer) return const SizedBox.shrink();

    final broken = progress.brokenStreak;
    final restored = broken + 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.streak.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sua sequência de $broken dias ainda pode voltar',
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 14, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Reparar agora e seguir com $restored dias — 1× neste mês.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              height: 1.35,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 12),
          CopperCta(
            label: 'Reparar sequência',
            trailing: CinematicGlyph.flame,
            onTap: () async {
              HapticFeedback.mediumImpact();
              await progress.claimStreakRepair();
            },
          ),
          TextButton(
            onPressed: () => progress.dismissStreakRepair(),
            child: Text(
              'Recomeçar do 1',
              style: AppTypography.body(
                weight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
