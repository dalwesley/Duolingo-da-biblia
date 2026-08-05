import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import 'ui_primitives.dart';

/// Atmosfera Stway — gradiente sóbrio, sem orbs nem wash de luz.
class AmbientAtmosphere extends StatelessWidget {
  final DayPhase? phase;
  final Color? accent;
  final Color? glow;
  final double vignetteStrength;

  const AmbientAtmosphere({
    super.key,
    this.phase,
    this.accent,
    this.glow,
    this.vignetteStrength = 0.06,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedPhase = phase ?? Appearance.of(context).phase;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: DayPhaseHelper.backgroundGradient(resolvedPhase),
      ),
    );
  }
}

/// Mundo contínuo — céu sóbrio. Pintado uma única vez (sem loops).
class ImmersiveBackground extends StatelessWidget {
  final Widget child;
  final AppearanceStyle? appearance;
  final Widget? background;

  const ImmersiveBackground({
    super.key,
    required this.child,
    this.appearance,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final style = appearance ?? Appearance.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        background ??
            AmbientAtmosphere(phase: style.phase, vignetteStrength: 0.05),
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
  final Widget? background;

  const ImmersiveScaffold({
    super.key,
    required this.mode,
    required this.style,
    required this.body,
    this.bottomNavigationBar,
    this.extendBody = false,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = DayPhaseHelper.scaffoldBackground(style.phase);
    final statusLight = style.onDark || style.look == AppearanceLook.morning;

    return Appearance(
      mode: mode,
      style: style,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: statusLight
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: statusLight
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: scaffoldBg,
          extendBody: extendBody,
          body: ImmersiveBackground(
            appearance: style,
            background: background,
            child: body,
          ),
          bottomNavigationBar: bottomNavigationBar,
        ),
      ),
    );
  }
}

/// Painel sólido Stway — cards de jogo (lip duro + borda HUD).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final bool elevated;
  final bool accent;
  final Color? color;
  final Color? tint;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = AppMetrics.cardPadding,
    this.onTap,
    this.radius = AppMetrics.cardRadius,
    this.elevated = false,
    this.accent = false,
    this.color,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final style = Appearance.of(context);
    final fill =
        color ??
        (tint != null
            ? Color.lerp(style.cardFill, tint, 0.12)!
            : style.cardFill);
    final borderColor = accent
        ? AppMetrics.accentBorder(alpha: elevated ? 0.85 : 0.7)
        : tint != null
        ? tint!.withValues(alpha: 0.45)
        : style.cardBorder;

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(fill, Colors.white, 0.07)!,
            fill,
            Color.lerp(fill, Colors.black, 0.14)!,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
        border: Border.all(
          color: borderColor,
          width: accent || tint != null
              ? AppMetrics.cardBorderWidth + 0.25
              : AppMetrics.cardBorderWidth,
        ),
        boxShadow: AppMetrics.cardShadow(
          elevated: elevated,
          accent: accent,
          tint: tint,
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
