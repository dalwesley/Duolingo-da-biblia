import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Partículas de arena — volt, streak, cobalto.
class ConfettiOverlay extends StatefulWidget {
  final bool active;
  /// Burst mais denso e longo — telas de conquista.
  final bool cinematic;

  const ConfettiOverlay({
    super.key,
    required this.active,
    this.cinematic = false,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(42);
    final count = widget.cinematic ? 56 : 36;
    final palette = [
      AppColors.accent,
      AppColors.accentBright,
      AppColors.primaryLight,
      AppColors.teal,
      AppColors.streak,
      Colors.white,
      AppColors.sand,
    ];
    _particles = List.generate(count, (i) {
      final kind = i % 5;
      return _Particle(
        x: rng.nextDouble(),
        delay: rng.nextDouble() * (widget.cinematic ? 0.55 : 0.4),
        speed: 0.45 + rng.nextDouble() * 0.9,
        size: 3.5 + rng.nextDouble() * (widget.cinematic ? 8 : 6),
        color: palette[i % palette.length],
        drift: (rng.nextDouble() - 0.5) * (widget.cinematic ? 0.18 : 0.08),
        spin: (rng.nextDouble() - 0.5) * math.pi * 2,
        kind: kind,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.cinematic ? 3400 : 2400),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ConfettiPainter(
              progress: _controller.value,
              particles: _particles,
              cinematic: widget.cinematic,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Particle {
  final double x;
  final double delay;
  final double speed;
  final double size;
  final Color color;
  final double drift;
  final double spin;
  final int kind;

  const _Particle({
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.color,
    required this.drift,
    required this.spin,
    required this.kind,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;
  final bool cinematic;

  _ConfettiPainter({
    required this.progress,
    required this.particles,
    required this.cinematic,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = ((progress - p.delay) / p.speed).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final fade = cinematic
          ? (t < 0.15 ? t / 0.15 : (1 - ((t - 0.15) / 0.85))).clamp(0.0, 1.0)
          : (1 - t);
      final x = (p.x + p.drift * t) * size.width;
      final y = -28 + t * (size.height + 56);
      final paint = Paint()..color = p.color.withValues(alpha: fade * 0.92);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * t);
      switch (p.kind) {
        case 0:
          // Faísca alongada
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: p.size * 0.45,
                height: p.size * 2.4,
              ),
              const Radius.circular(2),
            ),
            paint,
          );
        case 1:
          canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
        case 2:
          // Losango
          final path = Path()
            ..moveTo(0, -p.size)
            ..lineTo(p.size * 0.55, 0)
            ..lineTo(0, p.size)
            ..lineTo(-p.size * 0.55, 0)
            ..close();
          canvas.drawPath(path, paint);
        default:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: p.size,
                height: p.size * 1.6,
              ),
              const Radius.circular(2),
            ),
            paint,
          );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress || old.cinematic != cinematic;
}
