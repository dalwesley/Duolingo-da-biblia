import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';

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
        if (DayPhaseHelper.showStars(phase))
          RepaintBoundary(
            child: CustomPaint(
              painter: _StarsPainter(dense: phase == DayPhase.night),
              size: Size.infinite,
            ),
          ),
        // Orbital glow — luz narrativa
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryLight.withValues(alpha: night ? 0.18 : 0.28),
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
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accent.withValues(
                    alpha: phase == DayPhase.morning ? 0.2 : 0.1,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Horizonte dourado
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.accent.withValues(
                      alpha: phase == DayPhase.morning
                          ? 0.18
                          : phase == DayPhase.evening
                              ? 0.14
                              : 0.06,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        // Vinheta — bem mais leve de dia
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.15,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: night ? 0.35 : 0.14),
                  ],
                  stops: const [0.45, 1.0],
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

class _StarsPainter extends CustomPainter {
  final bool dense;

  _StarsPainter({required this.dense});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(42);
    final starCount = dense ? 55 : 38;
    final paint = Paint();

    for (var i = 0; i < starCount; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height * 0.78;
      final r = rnd.nextDouble() * 1.6 + 0.3;
      final alpha = 0.15 + rnd.nextDouble() * 0.4;
      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter old) => old.dense != dense;
}

/// Painel de vidro — sem blur real (BackdropFilter é caro demais em lista).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final bool elevated;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.radius = 24,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = Appearance.of(context);
    final useDark = style.onDark;

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: useDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: elevated ? 0.18 : 0.12),
                  Colors.white.withValues(alpha: elevated ? 0.08 : 0.05),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.88),
                  Colors.white.withValues(alpha: 0.72),
                ],
              ),
        border: Border.all(
          color: useDark
              ? Colors.white.withValues(alpha: elevated ? 0.22 : 0.12)
              : Colors.white.withValues(alpha: 0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: useDark ? 0.25 : 0.08),
            blurRadius: elevated ? 24 : 16,
            offset: const Offset(0, 8),
          ),
        ],
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

class RingProgress extends StatelessWidget {
  final double value;
  final double size;
  final double stroke;
  final Color color;
  final Widget center;

  const RingProgress({
    super.key,
    required this.value,
    required this.center,
    this.size = 88,
    this.stroke = 8,
    this.color = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value.clamp(0, 1),
              strokeWidth: stroke,
              backgroundColor: color.withValues(alpha: 0.15),
              color: color,
              strokeCap: StrokeCap.round,
            ),
          ),
          center,
        ],
      ),
    );
  }
}
