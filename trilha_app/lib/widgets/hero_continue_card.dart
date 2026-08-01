import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/trail_visuals.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Próxima lição — card sóbrio, sem glow pulsante.
class HeroContinueCard extends StatelessWidget {
  final Mission? mission;
  final String trailTitle;
  final String trailSlug;
  final String trailColor;
  final VoidCallback? onTap;
  final VoidCallback? onExploreTrails;
  final bool goalMet;

  const HeroContinueCard({
    super.key,
    required this.mission,
    required this.trailTitle,
    this.trailSlug = 'genesis-1-11',
    this.trailColor = '#1B3A5C',
    this.onTap,
    this.onExploreTrails,
    this.goalMet = false,
  });

  @override
  Widget build(BuildContext context) {
    final mission = this.mission;
    if (mission == null) return _completedState(context);

    final a = Appearance.of(context);
    final visuals = TrailVisuals.forSlug(trailSlug, color: trailColor);
    final trailAccent = visuals.accent;
    final stepLabel = goalMet ? 'Mais uma lição' : 'Próxima lição';
    final ctaLabel = goalMet ? 'Seguir' : 'Continuar';
    final rewardColor = mission.isBoss ? AppColors.sand : trailAccent;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap?.call();
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 280),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
          color: a.cardFill,
          border: Border.all(
            color: AppMetrics.accentBorder(alpha: 0.55, color: trailAccent),
            width: 1.25,
          ),
          boxShadow: AppMetrics.cardShadow(elevated: true),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Chip(
                tone: trailAccent,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CinematicIcon(
                      glyph: visuals.glyph,
                      size: 16,
                      accent: trailAccent,
                      glowing: false,
                      framed: false,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      trailTitle.toUpperCase(),
                      style: AppTypography.label(
                        size: 10,
                        letterSpacing: 1.1,
                        color: a.text.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                stepLabel.toUpperCase(),
                style: AppTypography.label(
                  size: 12,
                  letterSpacing: 1.6,
                  color: trailAccent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                mission.title,
                style: AppTypography.display(
                  size: 32,
                  height: 1.1,
                  weight: FontWeight.w900,
                  color: a.text,
                ),
              ),
              if (mission.isBoss) ...[
                const SizedBox(height: 10),
                Text(
                  'Desafio especial · mais passos',
                  style: AppTypography.body(
                    size: 14,
                    weight: FontWeight.w700,
                    color: AppColors.sand.withValues(alpha: 0.9),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppGradients.gold,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ctaLabel.toUpperCase(),
                      style: AppTypography.cta(size: 16),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: AppColors.inkOnAccent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  '+${mission.stepsReward} passos nesta lição',
                  style: AppTypography.body(
                    size: 13,
                    weight: FontWeight.w800,
                    color: rewardColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _completedState(BuildContext context) {
    final a = Appearance.of(context);
    return GestureDetector(
      onTap: onExploreTrails,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          color: a.cardFill,
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
          boxShadow: AppMetrics.cardShadow(),
        ),
        child: Column(
          children: [
            const CinematicIcon(
              glyph: CinematicGlyph.crown,
              size: 56,
              accent: AppColors.accent,
              glowing: false,
            ),
            const SizedBox(height: 16),
            Text(
              'Trilha concluída',
              style: AppTypography.display(size: 28, color: a.text),
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha a próxima e continue aprendendo.',
              textAlign: TextAlign.center,
              style: AppTypography.body(color: a.textMuted(0.6)),
            ),
            if (onExploreTrails != null) ...[
              const SizedBox(height: 20),
              const CopperCta(
                label: 'Explorar trilhas',
                expanded: false,
                onTap: null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final Widget child;
  final Color? tone;

  const _Chip({required this.child, this.tone});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final ink = tone;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: ink != null ? ink.withValues(alpha: 0.12) : a.cardFill,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: ink != null ? ink.withValues(alpha: 0.45) : a.cardBorder,
        ),
      ),
      child: child,
    );
  }
}
