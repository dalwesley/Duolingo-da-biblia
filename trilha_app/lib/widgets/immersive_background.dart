import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import 'ui_primitives.dart';

/// Mundo contínuo — céu, luz e vinheta. Pintado uma única vez (sem loops).
class ImmersiveBackground extends StatelessWidget {
  final Widget child;
  final AppearanceStyle? appearance;

  const ImmersiveBackground({super.key, required this.child, this.appearance});

  @override
  Widget build(BuildContext context) {
    final style = appearance ?? Appearance.of(context);
    final phase = style.phase;
    final night = phase == DayPhase.night || phase == DayPhase.evening;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(gradient: DayPhaseHelper.backgroundGradient(phase)),
        ),
        // Luz ambiente — manhã = aurora fria; tarde = teal aberto
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (phase == DayPhase.afternoon
                          ? AppColors.teal
                          : AppColors.primaryLight)
                      .withValues(
                    alpha: night
                        ? 0.12
                        : phase == DayPhase.afternoon
                            ? 0.26
                            : 0.16,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 160,
          left: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accent.withValues(
                    alpha: night
                        ? 0.08
                        : phase == DayPhase.morning
                            ? 0.16
                            : 0.05,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Horizonte — forte na aurora, quase sumido à tarde
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: phase == DayPhase.afternoon ? 140 : 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    (phase == DayPhase.afternoon
                            ? AppColors.teal
                            : AppColors.accent)
                        .withValues(
                      alpha: switch (phase) {
                        DayPhase.morning => 0.18,
                        DayPhase.afternoon => 0.08,
                        DayPhase.evening => 0.16,
                        DayPhase.night => 0.04,
                      },
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        // Vinheta
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.15,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(
                      alpha: night
                          ? 0.32
                          : phase == DayPhase.morning
                              ? 0.18
                              : 0.14,
                    ),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Painel unificado — usa Appearance (mesmo card em todas as abas).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final bool elevated;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = AppMetrics.cardPadding,
    this.onTap,
    this.radius = AppMetrics.cardRadius,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = Appearance.of(context);

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: style.cardFill,
        gradient: style.cardGradient,
        border: Border.all(
          color: elevated
              ? style.cardBorder.withValues(alpha: 0.9)
              : style.cardBorder,
        ),
        boxShadow: AppTheme.cardShadow(elevated: elevated),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: content,
        ),
      );
    }
    return content;
  }
}
