import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';

class ImmersiveBackground extends StatefulWidget {
  final Widget child;
  final AppearanceStyle? appearance;

  const ImmersiveBackground({super.key, required this.child, this.appearance});

  @override
  State<ImmersiveBackground> createState() => _ImmersiveBackgroundState();
}

class _ImmersiveBackgroundState extends State<ImmersiveBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _twinkle;

  @override
  void initState() {
    super.initState();
    _twinkle = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.appearance ?? Appearance.of(context);
    final phase = style.phase;
    final showStars = DayPhaseHelper.showStars(phase) || style.look == AppearanceLook.night;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(gradient: DayPhaseHelper.backgroundGradient(phase)),
        ),
        if (showStars)
          AnimatedBuilder(
            animation: _twinkle,
            builder: (context, _) => CustomPaint(
              painter: _StarsPainter(phase: _twinkle.value, denser: style.look == AppearanceLook.night),
              size: Size.infinite,
            ),
          ),
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: style.look == AppearanceLook.night ? 0.22 : 0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        if (phase == DayPhase.evening || style.look == AppearanceLook.night)
          Positioned(
            bottom: -40,
            left: 0,
            right: 0,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppColors.accent.withValues(alpha: 0.12), Colors.transparent],
                ),
              ),
            ),
          ),
        Positioned(
          top: 120,
          left: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accent.withValues(alpha: style.look == AppearanceLook.morning ? 0.18 : 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _StarsPainter extends CustomPainter {
  final double phase;
  final bool denser;
  _StarsPainter({required this.phase, this.denser = false});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(42);
    final count = denser ? 42 : 30;
    for (var i = 0; i < count; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height * 0.7;
      final r = rnd.nextDouble() * 1.5 + 0.4;
      final opacity = 0.15 + 0.5 * math.sin(phase * math.pi * 2 + i).abs();
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = Colors.white.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter old) => old.phase != phase || old.denser != denser;
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = Appearance.of(context);
    final useDark = style.onDark;

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: useDark ? style.cardGradient : null,
        color: useDark ? (style.cardGradient == null ? style.cardFill : null) : Colors.white.withValues(alpha: 0.92),
        border: Border.all(color: useDark ? style.cardBorder : Colors.white.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: useDark ? (style.look == AppearanceLook.night ? 0.45 : 0.28) : 0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(26), child: content),
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
