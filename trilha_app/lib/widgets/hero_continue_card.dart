import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Palco da próxima lição — primeiro impacto da Home (não card flat).
class HeroContinueCard extends StatefulWidget {
  final Mission? mission;
  final String trailTitle;
  final String trailSlug;
  final String trailColor;
  final VoidCallback? onTap;
  final VoidCallback? onExploreTrails;
  final bool goalMet;
  final int streak;

  const HeroContinueCard({
    super.key,
    required this.mission,
    required this.trailTitle,
    this.trailSlug = 'genesis-1-11',
    this.trailColor = '#1B3A5C',
    this.onTap,
    this.onExploreTrails,
    this.goalMet = false,
    this.streak = 0,
  });

  @override
  State<HeroContinueCard> createState() => _HeroContinueCardState();
}

class _HeroContinueCardState extends State<HeroContinueCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mission = widget.mission;
    if (mission == null) return _completedState(context);

    final a = Appearance.of(context);
    final stepLabel = widget.goalMet ? 'Mais uma lição' : 'Próxima lição';
    final ctaLabel = widget.goalMet ? 'Seguir' : 'Continuar';

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          final glow = 0.28 + 0.18 * _pulse.value;
          return Container(
            constraints: const BoxConstraints(minHeight: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  a.cardFillSoft,
                  a.cardFill,
                  Color.lerp(a.cardFill, AppColors.primaryDark, 0.35)!,
                ],
              ),
              border: Border.all(
                color: AppMetrics.accentBorder(
                  alpha: 0.35 + 0.2 * _pulse.value,
                ),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: glow * 0.55),
                  blurRadius: 28,
                  spreadRadius: -4,
                  offset: const Offset(0, 10),
                ),
                ...AppMetrics.cardShadow(elevated: true),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
              child: Stack(
                children: [
                  // Energia — órbita dourada
                  Positioned(
                    right: -60,
                    top: -40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accent.withValues(alpha: 0.22 + 0.1 * _pulse.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -50,
                    bottom: -30,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 24,
                    child: Opacity(
                      opacity: 0.18,
                      child: CinematicIcon.mission(
                        mission.title,
                        isBoss: mission.isBoss,
                        size: 120,
                        accent: AppColors.accent,
                        glowing: false,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _Chip(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CinematicIcon(
                                    glyph: CinematicGlyphResolver.forTrail(
                                      widget.trailSlug,
                                    ),
                                    size: 16,
                                    accent: AppColors.accent,
                                    glowing: false,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.trailTitle.toUpperCase(),
                                    style: AppTypography.label(
                                      size: 10,
                                      letterSpacing: 1.1,
                                      color: a.text.withValues(alpha: 0.92),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (widget.streak > 0)
                              _Chip(
                                accent: true,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CinematicIcon(
                                      glyph: CinematicGlyph.flame,
                                      size: 14,
                                      accent: AppColors.streak,
                                      framed: false,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${widget.streak}',
                                      style: AppTypography.title(
                                        size: 13,
                                        color: AppColors.streak,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          stepLabel.toUpperCase(),
                          style: AppTypography.label(
                            size: 12,
                            letterSpacing: 2.2,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          mission.title,
                          style: AppTypography.display(
                            size: 34,
                            height: 1.08,
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
                              color: a.textMuted(0.65),
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        // CTA full-bleed
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: AppGradients.gold,
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(
                                  alpha: 0.45 + 0.25 * _pulse.value,
                                ),
                                blurRadius: 22,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ctaLabel.toUpperCase(),
                                style: AppTypography.cta(size: 16),
                              ),
                              const SizedBox(width: 10),
                              Icon(
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
                              weight: FontWeight.w700,
                              color: a.textMuted(0.55),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _completedState(BuildContext context) {
    final a = Appearance.of(context);
    return GestureDetector(
      onTap: widget.onExploreTrails,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          color: a.cardFill,
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.45)),
        ),
        child: Column(
          children: [
            const CinematicIcon(
              glyph: CinematicGlyph.crown,
              size: 64,
              accent: AppColors.accent,
              glowing: true,
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
            if (widget.onExploreTrails != null) ...[
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
  final bool accent;

  const _Chip({required this.child, this.accent = false});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: accent
            ? AppColors.streak.withValues(alpha: 0.12)
            : a.cardFill,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: accent
              ? AppColors.streak.withValues(alpha: 0.4)
              : a.cardBorder,
        ),
      ),
      child: child,
    );
  }
}
