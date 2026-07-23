import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Partículas de arena — volt, streak, cobalto.
class ConfettiOverlay extends StatefulWidget {
  final bool active;

  const ConfettiOverlay({super.key, required this.active});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(36, (i) => _Particle(
          x: rng.nextDouble(),
          delay: rng.nextDouble() * 0.4,
          speed: 0.5 + rng.nextDouble() * 0.8,
          size: 4 + rng.nextDouble() * 6,
          color: [AppColors.accent, AppColors.accentBright, AppColors.primaryLight, AppColors.teal, AppColors.streak, Colors.white][i % 6],
        ));
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..forward();
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
            painter: _ConfettiPainter(progress: _controller.value, particles: _particles),
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

  const _Particle({required this.x, required this.delay, required this.speed, required this.size, required this.color});
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;

  _ConfettiPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = ((progress - p.delay) / p.speed).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final x = p.x * size.width;
      final y = -20 + t * (size.height + 40);
      final paint = Paint()..color = p.color.withValues(alpha: (1 - t) * 0.9);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y), width: p.size, height: p.size * 1.6), const Radius.circular(2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.progress != progress;
}
