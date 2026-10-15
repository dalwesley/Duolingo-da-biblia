import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Partículas da festa — ouro do botão, azul da nuvem, caminho branco.
class ConfettiOverlay extends StatefulWidget {
  final bool active;

  /// Burst mais denso e longo — telas de conquista.
  final bool cinematic;

  /// Centro da origem, em fração da área (0–1).
  /// Sem origem, as partículas caem do topo em toda a largura.
  final Offset? source;

  /// Largura da origem, em fração da área. A explosão nasce nessa faixa.
  final double sourceSpan;

  const ConfettiOverlay({
    super.key,
    required this.active,
    this.cinematic = false,
    this.source,
    this.sourceSpan = 0,
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
    final fromCloud = widget.source != null;
    final count = fromCloud ? 140 : (widget.cinematic ? 56 : 36);
    final palette = [
      AppColors.accent,
      AppColors.glow,
      AppColors.primary,
      const Color(0xFFE1E7EE),
    ];
    _particles = List.generate(count, (i) {
      final kind = i % 5;
      final along = rng.nextDouble();
      var burstVx = 0.0;
      var burstVy = 0.0;
      var burstG = 0.0;
      if (fromCloud) {
        final side = along * 2 - 1;
        final flare = -side * (0.45 + side.abs() * 1.15);
        final kick = side.abs() > 0.58 && rng.nextDouble() > 0.35
            ? -side.sign * (0.3 + rng.nextDouble() * 0.7)
            : 0.0;
        final angle =
            math.pi / 2 + flare + kick + (rng.nextDouble() - 0.5) * 0.5;
        final power = 0.2 + rng.nextDouble() * 0.55;
        burstVx = math.cos(angle) * power;
        burstVy = math.sin(angle) * power;
        burstG = 0.4 + rng.nextDouble() * 0.55;
      }
      return _Particle(
        x: fromCloud ? along : rng.nextDouble(),
        delay:
            rng.nextDouble() *
            (fromCloud ? 0.06 : (widget.cinematic ? 0.55 : 0.4)),
        speed: fromCloud
            ? 0.7 + rng.nextDouble() * 0.4
            : 0.45 + rng.nextDouble() * 0.9,
        size: fromCloud
            ? 5 + rng.nextDouble() * 11
            : 3.5 + rng.nextDouble() * (widget.cinematic ? 8 : 6),
        color: palette[i % palette.length],
        drift:
            (rng.nextDouble() - 0.5) *
            (fromCloud ? 1 : (widget.cinematic ? 0.18 : 0.08)),
        spin: (rng.nextDouble() - 0.5) * math.pi * (fromCloud ? 6 : 2),
        kind: kind,
        burstVx: burstVx,
        burstVy: burstVy,
        burstG: burstG,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: fromCloud ? 2400 : (widget.cinematic ? 3400 : 2400),
      ),
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
              source: widget.source,
              sourceSpan: widget.sourceSpan,
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
  final double burstVx;
  final double burstVy;
  final double burstG;

  const _Particle({
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.color,
    required this.drift,
    required this.spin,
    required this.kind,
    this.burstVx = 0,
    this.burstVy = 0,
    this.burstG = 0,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;
  final bool cinematic;
  final Offset? source;
  final double sourceSpan;

  _ConfettiPainter({
    required this.progress,
    required this.particles,
    required this.cinematic,
    this.source,
    this.sourceSpan = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final origin = source == null
        ? null
        : Offset(source!.dx * size.width, source!.dy * size.height);
    for (final p in particles) {
      final t = ((progress - p.delay) / p.speed).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final fade = origin != null
          ? (t < 0.05 ? t / 0.05 : (1 - ((t - 0.05) / 0.95)).clamp(0.0, 1.0))
          : cinematic
          ? (t < 0.15 ? t / 0.15 : (1 - ((t - 0.15) / 0.85))).clamp(0.0, 1.0)
          : (1 - t);
      final double x;
      final double y;
      if (origin != null) {
        final span = (sourceSpan <= 0 ? 0.46 : sourceSpan) * size.width;
        final spawnX = origin.dx + (p.x - 0.5) * span;
        final spawnY = origin.dy + p.drift * 10;
        x = spawnX + p.burstVx * size.width * t;
        y =
            spawnY +
            p.burstVy * size.width * t +
            p.burstG * size.height * t * t;
      } else {
        x = (p.x + p.drift * t) * size.width;
        y = -28 + t * (size.height + 56);
      }
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
      old.progress != progress ||
      old.cinematic != cinematic ||
      old.source != source ||
      old.sourceSpan != sourceSpan;
}
