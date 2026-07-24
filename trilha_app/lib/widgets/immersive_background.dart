import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import 'ui_primitives.dart';

/// Atmosfera Stway — gradiente, luz ambiente e vinheta.
/// Sem montanhas, estrelas ou paisagem ilustrada.
class AmbientAtmosphere extends StatelessWidget {
  final DayPhase? phase;
  final Color? accent;
  final Color? glow;
  /// Vinheta mais forte em telas full-bleed (jornada).
  final double vignetteStrength;

  const AmbientAtmosphere({
    super.key,
    this.phase,
    this.accent,
    this.glow,
    this.vignetteStrength = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedPhase =
        phase ?? Appearance.of(context).phase;
    final night =
        resolvedPhase == DayPhase.night || resolvedPhase == DayPhase.evening;
    final afternoon = resolvedPhase == DayPhase.afternoon;

    final glowColor = glow ??
        (afternoon ? AppColors.teal : AppColors.primaryLight);
    final accentColor = accent ?? AppColors.accent;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: DayPhaseHelper.backgroundGradient(resolvedPhase),
          ),
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

/// Chrome Stway — mesmo envelope da Home (Appearance + system UI + céu).
class ImmersiveScaffold extends StatelessWidget {
  final AppearanceMode mode;
  final AppearanceStyle style;
  final Widget body;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  const ImmersiveScaffold({
    super.key,
    required this.mode,
    required this.style,
    required this.body,
    this.bottomNavigationBar,
    this.extendBody = false,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = DayPhaseHelper.scaffoldBackground(style.phase);
    final statusLight =
        style.onDark || style.look == AppearanceLook.morning;

    return Appearance(
      mode: mode,
      style: style,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              statusLight ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness:
              statusLight ? Brightness.light : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: scaffoldBg,
          extendBody: extendBody,
          body: ImmersiveBackground(
            appearance: style,
            child: body,
          ),
          bottomNavigationBar: bottomNavigationBar,
        ),
      ),
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
