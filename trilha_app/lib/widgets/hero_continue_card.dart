import 'package:flutter/material.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import '../utils/trail_visuals.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// CTA da próxima missão — card dominante na home.
class HeroContinueCard extends StatelessWidget {
  final Mission? mission;
  final String trailTitle;
  final String trailSlug;
  final String trailColor;
  final VoidCallback? onTap;
  final VoidCallback? onExploreTrails;
  /// Meta diária já cumprida — copy de “continue” em vez de urgência.
  final bool goalMet;

  const HeroContinueCard({
    super.key,
    required this.mission,
    required this.trailTitle,
    this.trailSlug = 'genesis-1-11',
    this.trailColor = '#243F36',
    this.onTap,
    this.onExploreTrails,
    this.goalMet = false,
  });

  @override
  Widget build(BuildContext context) {
    final mission = this.mission;
    if (mission == null) return _completedState();

    final visuals = TrailVisuals.forSlug(trailSlug);
    final stepLabel = goalMet ? 'Continue à frente' : 'Próximo passo';
    final ctaLabel = goalMet ? 'Mais um passo' : 'Caminhar';
    final hook = goalMet
        ? 'Meta ok · um passo a mais fortalece a caravana'
        : mission.isBoss
        ? 'Desafio especial · mais passos na jornada'
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          child: Stack(
            children: [
              // Fundo da missão
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1E342C),
                        AppColors.primaryDark,
                        Color.lerp(visuals.accent, AppColors.night, 0.55)!,
                      ],
                    ),
                  ),
                ),
              ),
              // Luz superior
              Positioned(
                right: -40,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -40,
                bottom: -50,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Vinheta
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.4, -0.2),
                      radius: 1.2,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
              ),
              // Glifo fantasma
              Positioned(
                right: 4,
                top: 12,
                child: Opacity(
                  opacity: 0.4,
                  child: CinematicIcon.mission(
                    mission.title,
                    isBoss: mission.isBoss,
                    size: 100,
                    accent: visuals.accent,
                    glowing: false,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpace.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpace.md,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CinematicIcon(
                                glyph: CinematicGlyphResolver.forTrail(trailSlug),
                                size: 20,
                                accent: AppColors.accent,
                                glowing: false,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                trailTitle.toUpperCase(),
                                style: AppTypography.label(
                                  size: 10,
                                  letterSpacing: 1.1,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (mission.isBoss) ...[
                          const SizedBox(width: AppSpace.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppGradients.gold,
                              borderRadius: BorderRadius.circular(AppRadii.pill),
                            ),
                            child: Text(
                              'DESAFIO',
                              style: AppTypography.label(
                                size: 9,
                                letterSpacing: 1,
                                color: AppColors.inkOnAccent,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpace.xl),
                    SectionLabel(stepLabel),
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      mission.title,
                      style: AppTypography.display(
                        size: 30,
                        height: 1.12,
                      ),
                    ),
                    if (hook != null) ...[
                      const SizedBox(height: AppSpace.sm),
                      Text(
                        hook,
                        style: AppTypography.body(
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.68),
                          height: 1.3,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpace.xxl),
                    Row(
                      children: [
                        Expanded(
                          child: CopperCta(
                            label: ctaLabel,
                            onTap: null,
                          ),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Text(
                            '+${mission.stepsReward} passos',
                            style: AppTypography.title(
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _completedState() {
    return GestureDetector(
      onTap: onExploreTrails,
      child: Container(
        padding: const EdgeInsets.all(AppRadii.xl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.nightMid, AppColors.night],
          ),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            const CinematicIcon(
              glyph: CinematicGlyph.path,
              size: 56,
              accent: AppColors.accent,
              glowing: false,
            ),
            const SizedBox(height: AppSpace.md + 2),
            Text(
              'Trecho concluído',
              style: AppTypography.display(size: 26),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              'Escolha uma nova trilha e continue\nconhecendo a Cristo.',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
            if (onExploreTrails != null) ...[
              const SizedBox(height: AppSpace.lg + 2),
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
