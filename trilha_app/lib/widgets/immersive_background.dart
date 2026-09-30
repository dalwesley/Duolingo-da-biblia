import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import 'ui_primitives.dart';

/// Atmosfera Stway — gradiente sóbrio, sem orbs nem wash de luz.
class AmbientAtmosphere extends StatelessWidget {
  final DayPhase? phase;

  const AmbientAtmosphere({super.key, this.phase});

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
        background ?? AmbientAtmosphere(phase: style.phase),
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

  /// Palco: com valor (0–1), o card ganha brilho de [tint] no topo e um
  /// filamento aceso na borda — para cards que são “lugar”, não lista
  /// (duelo, dupla, passaporte). Sobe o tom quando o card pede ação.
  final double? glow;

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
    this.glow,
  });

  @override
  Widget build(BuildContext context) {
    final style = Appearance.of(context);
    if (glow != null) return _stage(style);

    final fill =
        color ??
        (tint != null
            ? Color.lerp(style.cardFill, tint, 0.12)!
            : style.cardFill);
    final borderColor =
        (accent
            ? AppMetrics.accentBorder(alpha: elevated ? 0.85 : 0.7)
            : tint != null
            ? tint!.withValues(alpha: 0.45)
            : style.cardBorder);

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: fill,
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

    return _tappable(content);
  }

  Widget _tappable(Widget content) {
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      ),
    );
  }

  Widget _stage(AppearanceStyle style) {
    final tone = tint ?? AppRoles.chrome;
    final g = glow!.clamp(0.0, 1.0);
    final base = color ?? style.cardFill;
    const border = AppMetrics.cardBorderWidth;
    final content = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(base, tone, 0.06 + 0.12 * g)!,
            base,
            Color.lerp(base, AppColors.night, 0.35)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border.all(
          color: tone.withValues(alpha: 0.3 + 0.4 * g),
          width: border,
        ),
        boxShadow: [
          ...AppMetrics.cardShadow(elevated: true),
          BoxShadow(
            color: tone.withValues(alpha: 0.05 + 0.17 * g),
            blurRadius: 18 + 14 * g,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - border),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: -40,
              height: 180,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.2),
                      radius: 0.8,
                      colors: [
                        tone.withValues(alpha: 0.08 + 0.2 * g),
                        tone.withValues(alpha: 0.03),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 32,
              right: 32,
              top: 0,
              child: CardFilament(color: tone),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
    return _tappable(content);
  }
}

/// Linha fina que acende no meio e some nas pontas — topo dos palcos.
class CardFilament extends StatelessWidget {
  final Color color;
  final double height;

  const CardFilament({
    super.key,
    this.color = AppRoles.chrome,
    this.height = 1.2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            color.withValues(alpha: 0.15),
            color,
            color.withValues(alpha: 0.15),
            Colors.transparent,
          ],
          stops: const [0, 0.18, 0.5, 0.82, 1],
        ),
      ),
    );
  }
}
