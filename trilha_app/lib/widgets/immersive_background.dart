import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import 'ui_primitives.dart';

/// Atmosfera Stway — gradiente, luz ambiente e vinheta.
/// Sem montanhas, estrelas ou paisagem ilustrada.
class AmbientAtmosphere extends StatelessWidget {
  /// Céu custom (ex.: reino). Se null, usa a fase do dia.
  final List<Color>? skyColors;
  final DayPhase? phase;
  final Color? accent;
  final Color? glow;
  /// Vinheta mais forte em telas full-bleed (jornada).
  final double vignetteStrength;

  const AmbientAtmosphere({
    super.key,
    this.skyColors,
    this.phase,
    this.accent,
    this.glow,
    this.vignetteStrength = 0.1,
  });

  LinearGradient _skyGradient(DayPhase resolvedPhase) {
    final sky = skyColors;
    if (sky != null && sky.isNotEmpty) {
      final c0 = sky[0];
      final c1 = sky.length > 1 ? sky[1] : sky[0];
      final c2 = sky.length > 2
          ? sky[2]
          : Color.lerp(sky.last, AppColors.night, 0.2)!;
      final c3 = Color.lerp(sky.last, AppColors.night, 0.45)!;
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [c0, c1, c2, c3],
        stops: const [0.0, 0.35, 0.7, 1.0],
      );
    }
    return DayPhaseHelper.backgroundGradient(resolvedPhase);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedPhase =
        phase ?? Appearance.of(context).phase;
    final night =
        resolvedPhase == DayPhase.night || resolvedPhase == DayPhase.evening;
    final afternoon = resolvedPhase == DayPhase.afternoon;

    // Acentos padrão acompanham a Home; overrides só para tintas sutis de UI.
    final glowColor = glow ??
        (afternoon
            ? AppColors.teal
            : resolvedPhase == DayPhase.morning
                ? AppColors.primaryLight
                : AppColors.primaryLight);
    final accentColor = accent ?? AppColors.accent;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(gradient: _skyGradient(resolvedPhase)),
        ),
        Positioned(
          top: -100,
          right: -80,
          child: _Orb(
            size: 280,
            color: glowColor.withValues(
              alpha: night
                  ? 0.12
                  : afternoon
                      ? 0.26
                      : 0.16,
            ),
          ),
        ),
        Positioned(
          top: 160,
          left: -60,
          child: _Orb(
            size: 200,
            color: accentColor.withValues(
              alpha: night
                  ? 0.08
                  : resolvedPhase == DayPhase.morning
                      ? 0.16
                      : 0.05,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: afternoon ? 140 : 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    (afternoon ? AppColors.teal : accentColor).withValues(
                      alpha: switch (resolvedPhase) {
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
                          ? vignetteStrength.clamp(0.06, 0.35)
                          : (vignetteStrength * 0.6).clamp(0.04, 0.2),
                    ),
                  ],
                  stops: const [0.55, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;

  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}

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
        AmbientAtmosphere(
          phase: phase,
          vignetteStrength: night ? 0.1 : 0.06,
        ),
        child,
      ],
    );
  }
}

/// Painel sólido Stway — mesmo card em Home, onboarding, trilha, etc.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final bool elevated;
  /// Borda açafrão + glow — card hero / ativo.
  final bool accent;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = AppMetrics.cardPadding,
    this.onTap,
    this.radius = AppMetrics.cardRadius,
    this.elevated = false,
    this.accent = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final style = Appearance.of(context);

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: color ?? style.cardFill,
        border: Border.all(
          color: accent
              ? AppMetrics.accentBorder(alpha: elevated ? 0.55 : 0.42)
              : style.cardBorder,
          width: accent ? 1.5 : 1,
        ),
        boxShadow: AppMetrics.cardShadow(
          elevated: elevated || accent,
          accent: accent,
        ),
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
