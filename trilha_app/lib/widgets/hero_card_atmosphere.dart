import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Humor cinematográfico do card de continuar.
enum HeroCardMood {
  /// Gelo já cobriu um dia nesta semana — cristal, frio, brilho.
  frozen,

  /// Em risco, mas ainda dá tempo — pó, sépia, filme velho.
  dusty,

  /// Em dia — vidro limpo, reflexo, luz viva.
  alive,
}

/// Overlay animado por mood — partículas + grade de cor + borda viva.
class HeroCardAtmosphere extends StatefulWidget {
  final HeroCardMood mood;

  const HeroCardAtmosphere({super.key, required this.mood});

  @override
  State<HeroCardAtmosphere> createState() => _HeroCardAtmosphereState();
}

class _HeroCardAtmosphereState extends State<HeroCardAtmosphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late List<_Spec> _specs;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
    _specs = _buildSpecs(widget.mood);
  }

  @override
  void didUpdateWidget(covariant HeroCardAtmosphere oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) {
      _specs = _buildSpecs(widget.mood);
    }
  }

  List<_Spec> _buildSpecs(HeroCardMood mood) {
    final rng = math.Random(mood.index * 97 + 11);
    final count = switch (mood) {
      HeroCardMood.frozen => 36,
      HeroCardMood.dusty => 80,
      HeroCardMood.alive => 18,
    };
    return List.generate(count, (i) {
      return _Spec(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: switch (mood) {
          HeroCardMood.frozen => 2.4 + rng.nextDouble() * 5.2,
          HeroCardMood.dusty => 1.4 + rng.nextDouble() * 3.4,
          HeroCardMood.alive => 1.8 + rng.nextDouble() * 3.6,
        },
        speed: 0.35 + rng.nextDouble() * 0.85,
        phase: rng.nextDouble(),
        drift: (rng.nextDouble() - 0.5) * 0.22,
        kind: i % 4,
      );
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          return CustomPaint(
            painter: _AtmospherePainter(
              mood: widget.mood,
              t: _pulse.value,
              specs: _specs,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Spec {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;
  final double drift;
  final int kind;

  const _Spec({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.drift,
    required this.kind,
  });
}

class _AtmospherePainter extends CustomPainter {
  final HeroCardMood mood;
  final double t;
  final List<_Spec> specs;

  _AtmospherePainter({
    required this.mood,
    required this.t,
    required this.specs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (mood) {
      case HeroCardMood.frozen:
        _paintFrozen(canvas, size);
      case HeroCardMood.dusty:
        _paintDusty(canvas, size);
      case HeroCardMood.alive:
        _paintAlive(canvas, size);
    }
  }

  // ─── GELO ─────────────────────────────────────────────────────────────

  void _paintFrozen(Canvas canvas, Size size) {
    final breathe = 0.5 + 0.5 * math.sin(t * math.pi * 2);

    // Filme de gelo — lavagem ciano densa
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.iceSoft.withValues(alpha: 0.38 + breathe * 0.08),
            AppColors.ice.withValues(alpha: 0.28),
            AppColors.iceDeep.withValues(alpha: 0.62),
            const Color(0xFF061018).withValues(alpha: 0.72),
          ],
          stops: const [0.0, 0.28, 0.62, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Geada grossa nos cantos + bordas
    _frostCorner(canvas, size, Alignment.topLeft, breathe, 0.55);
    _frostCorner(canvas, size, Alignment.topRight, breathe, 0.62);
    _frostCorner(canvas, size, Alignment.bottomLeft, breathe * 0.75, 0.48);
    _frostCorner(canvas, size, Alignment.bottomRight, breathe * 0.55, 0.38);

    // Camada de geada na borda superior (vidro congelado)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.22),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.32 + breathe * 0.08),
            AppColors.iceSoft.withValues(alpha: 0.14),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromLTWH(0, 0, size.width, size.height * 0.22),
        ),
    );

    // Rachaduras de gelo (padrão cristalino)
    _drawIceCracks(canvas, size, breathe);

    // Cristais flutuando
    for (final s in specs) {
      final cycle = (t * s.speed + s.phase) % 1.0;
      final y = (s.y + cycle * 0.55) % 1.2 - 0.1;
      final x = (s.x + math.sin((t + s.phase) * math.pi * 2) * s.drift) % 1.0;
      final alpha =
          (0.3 + 0.55 * (1 - (cycle - 0.5).abs() * 2)).clamp(0.0, 0.9);
      final c = Color.lerp(
        AppColors.iceSoft,
        Colors.white,
        s.kind.isEven ? 0.65 : 0.25,
      )!;
      final paint = Paint()..color = c.withValues(alpha: alpha);
      final ox = x * size.width;
      final oy = y * size.height;
      canvas.save();
      canvas.translate(ox, oy);
      canvas.rotate(cycle * math.pi + s.phase * math.pi);
      if (s.kind == 0 || s.kind == 2) {
        _drawCrystal(canvas, s.size * 1.15, paint);
      } else {
        canvas.drawCircle(Offset.zero, s.size * 0.4, paint);
      }
      canvas.restore();
    }

    // Brilho frio varrendo (reflexo no gelo)
    final sweep = (t * 0.55) % 1.0;
    final sweepX = size.width * (sweep * 1.4 - 0.2);
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(26),
      ),
    );
    canvas.drawRect(
      Rect.fromLTWH(sweepX - 28, 0, 56, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.14 + breathe * 0.05),
            AppColors.iceSoft.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(sweepX - 28, 0, 56, size.height)),
    );
    canvas.restore();

    // Borda de cristal
    final inset = Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inset, const Radius.circular(26)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.7 + breathe * 0.2),
            AppColors.iceSoft.withValues(alpha: 0.55),
            AppColors.ice.withValues(alpha: 0.25),
            AppColors.iceSoft.withValues(alpha: 0.45),
          ],
        ).createShader(inset),
    );
  }

  void _drawIceCracks(Canvas canvas, Size size, double breathe) {
    final crack = Paint()
      ..color = Colors.white.withValues(alpha: 0.16 + breathe * 0.06)
      ..strokeWidth = 1.15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final soft = Paint()
      ..color = AppColors.iceSoft.withValues(alpha: 0.1)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Fractal leve a partir do canto superior direito
    final origin = Offset(size.width * 0.92, size.height * 0.08);
    void branch(Offset from, double angle, double len, int depth) {
      if (depth <= 0 || len < 8) return;
      final to = Offset(
        from.dx + math.cos(angle) * len,
        from.dy + math.sin(angle) * len,
      );
      canvas.drawLine(from, to, soft);
      canvas.drawLine(from, to, crack);
      branch(to, angle - 0.55, len * 0.62, depth - 1);
      branch(to, angle + 0.42, len * 0.55, depth - 1);
      if (depth >= 2) {
        branch(to, angle + 0.05, len * 0.48, depth - 2);
      }
    }

    branch(origin, math.pi * 0.72, size.shortestSide * 0.28, 4);
    branch(
      Offset(size.width * 0.08, size.height * 0.12),
      math.pi * 0.28,
      size.shortestSide * 0.18,
      3,
    );
  }

  void _frostCorner(
    Canvas canvas,
    Size size,
    Alignment align,
    double breathe,
    double strength,
  ) {
    final cx = align.x < 0 ? 0.0 : size.width;
    final cy = align.y < 0 ? 0.0 : size.height;
    final radius = size.shortestSide * (0.48 + breathe * 0.04) * strength * 1.35;
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.42 * strength),
            AppColors.iceSoft.withValues(alpha: 0.28 * strength),
            AppColors.ice.withValues(alpha: 0.1 * strength),
            Colors.transparent,
          ],
          stops: const [0.0, 0.28, 0.55, 1.0],
        ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        ),
    );

    // Veios de gelo densos
    final vein = Paint()
      ..color = Colors.white.withValues(alpha: 0.22 + breathe * 0.1)
      ..strokeWidth = 1.25
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final dirX = align.x < 0 ? 1.0 : -1.0;
    final dirY = align.y < 0 ? 1.0 : -1.0;
    for (var i = 0; i < 7; i++) {
      final a = 0.14 + i * 0.1;
      final path = Path()
        ..moveTo(cx, cy)
        ..lineTo(cx + dirX * radius * a, cy + dirY * radius * a * 0.32)
        ..lineTo(
          cx + dirX * radius * a * 0.72,
          cy + dirY * radius * (a + 0.07),
        );
      canvas.drawPath(path, vein);
    }
  }

  void _drawCrystal(Canvas canvas, double s, Paint paint) {
    final path = Path()
      ..moveTo(0, -s)
      ..lineTo(s * 0.55, 0)
      ..lineTo(0, s)
      ..lineTo(-s * 0.55, 0)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawLine(
      Offset(0, -s * 0.7),
      Offset(0, s * 0.7),
      Paint()
        ..color = paint.color
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke,
    );
    canvas.drawLine(
      Offset(-s * 0.35, 0),
      Offset(s * 0.35, 0),
      Paint()
        ..color = paint.color.withValues(alpha: paint.color.a * 0.7)
        ..strokeWidth = 0.7
        ..style = PaintingStyle.stroke,
    );
  }

  // ─── POEIRA / TEIA ────────────────────────────────────────────────────

  void _paintDusty(Canvas canvas, Size size) {
    final flicker = 0.9 + 0.1 * math.sin(t * math.pi * 9);
    final breathe = 0.5 + 0.5 * math.sin(t * math.pi * 2);

    // Véu de terra leve — suja sem apagar o texto (camada fica por cima)
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF5A3820).withValues(alpha: 0.22 * flicker),
            const Color(0xFF241610).withValues(alpha: 0.12),
            const Color(0xFF0A0604).withValues(alpha: 0.26),
          ],
          stops: const [0.0, 0.42, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Manchas / mofo — densas nos cantos
    for (final spot in const [
      (Alignment(-0.92, -0.78), 0.44, 0.55),
      (Alignment(0.94, -0.6), 0.52, 0.58),
      (Alignment(-0.72, 0.84), 0.4, 0.5),
      (Alignment(0.82, 0.9), 0.46, 0.52),
      (Alignment(0.15, -0.5), 0.3, 0.22),
      (Alignment(-0.4, 0.35), 0.28, 0.14),
      (Alignment(0.5, 0.25), 0.26, 0.12),
    ]) {
      final (align, scale, strength) = spot;
      final cx = (align.x * 0.5 + 0.5) * size.width;
      final cy = (align.y * 0.5 + 0.5) * size.height;
      final r = size.shortestSide * (scale + breathe * 0.03);
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF8A6840).withValues(alpha: 0.4 * strength),
              const Color(0xFF4A3018).withValues(alpha: 0.16 * strength),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
      );
    }

    _drawGrimeStreaks(canvas, size, breathe);
    _drawWearCracks(canvas, size, breathe);

    // Poeira acumulada só na borda inferior
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF8A6840).withValues(alpha: 0.16),
            const Color(0xFF3A2410).withValues(alpha: 0.36),
          ],
        ).createShader(
          Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3),
        ),
    );

    // Vinheta — cantos mortos
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.06),
          radius: 1.08,
          colors: [
            Colors.transparent,
            const Color(0xFF140C06).withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.58),
          ],
          stops: const [0.2, 0.6, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Uma teia só — canto superior direito, seda limpa
    _drawCornerWeb(
      canvas,
      origin: Offset(size.width - 1, 1),
      radius: size.shortestSide * 0.34,
      startAngle: math.pi / 2, // baixo → esquerda
      alpha: 0.34,
    );
    _drawDescendingSpider(canvas, size, breathe);

    // Poeira flutuando
    for (final s in specs) {
      final cycle = (t * s.speed * 0.35 + s.phase) % 1.0;
      final y = 1.1 - ((s.y + cycle) % 1.25);
      final x = (s.x +
              math.sin((t * 0.5 + s.phase) * math.pi * 2) * s.drift * 1.7) %
          1.0;
      final alpha =
          (0.04 + 0.1 * math.sin(cycle * math.pi)).clamp(0.0, 0.14);
      final dust = Color.lerp(
        const Color(0xFFA88858),
        const Color(0xFFE0C898),
        s.kind / 3,
      )!;
      final pos = Offset(x * size.width, y * size.height);
      final r = s.size * (1.0 + 0.45 * breatheNoise(s.phase));
      canvas.drawCircle(
        pos,
        r,
        Paint()..color = dust.withValues(alpha: alpha * flicker),
      );
      if (s.kind == 0 || s.kind == 2) {
        canvas.drawCircle(
          pos.translate(r * 0.65, -r * 0.3),
          r * 0.48,
          Paint()..color = dust.withValues(alpha: alpha * 0.4 * flicker),
        );
      }
    }

    _drawFilmGrain(canvas, size, flicker);

    // Arranhões
    for (var i = 0; i < 3; i++) {
      final scratchX = size.width * ((t * (1.5 + i * 0.6) + i * 0.2) % 1.0);
      canvas.drawLine(
        Offset(scratchX, 0),
        Offset(scratchX + (i.isEven ? 3.5 : -2.5), size.height),
        Paint()
          ..color = const Color(0xFFD4B896).withValues(
            alpha: (0.07 + i * 0.025) * flicker,
          )
          ..strokeWidth = 1.2,
      );
    }

    _drawWornBorder(canvas, size, breathe);
  }

  void _drawGrimeStreaks(Canvas canvas, Size size, double breathe) {
    final seeds = <(double, double, double, double)>[
      (0.08, 0.0, 0.12, 0.4),
      (0.22, 0.02, 0.18, 0.52),
      (0.74, 0.0, 0.8, 0.36),
      (0.9, 0.03, 0.94, 0.46),
      (0.14, 0.55, 0.2, 0.96),
      (0.82, 0.52, 0.88, 0.94),
    ];
    for (var i = 0; i < seeds.length; i++) {
      final (x0, y0, x1, y1) = seeds[i];
      final wobble = 0.012 * math.sin(t * math.pi * 2 + i);
      final path = Path()
        ..moveTo(size.width * x0, size.height * y0)
        ..cubicTo(
          size.width * (x0 + wobble),
          size.height * ((y0 + y1) * 0.35),
          size.width * (x1 - wobble),
          size.height * ((y0 + y1) * 0.7),
          size.width * x1,
          size.height * y1,
        );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2.2 + (i % 3) * 1.0
          ..color = const Color(0xFF3A2814).withValues(
            alpha: 0.2 + breathe * 0.05 + (i % 2) * 0.04,
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.1),
      );
    }
  }

  void _drawWearCracks(Canvas canvas, Size size, double breathe) {
    final crack = Paint()
      ..color = const Color(0xFF1A1008).withValues(alpha: 0.4 + breathe * 0.08)
      ..strokeWidth = 1.25
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final soft = Paint()
      ..color = const Color(0xFF6B4A28).withValues(alpha: 0.18)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    void branch(Offset from, double angle, double len, int depth) {
      if (depth <= 0 || len < 6) return;
      final to = Offset(
        from.dx + math.cos(angle) * len,
        from.dy + math.sin(angle) * len,
      );
      canvas.drawLine(from, to, soft);
      canvas.drawLine(from, to, crack);
      branch(to, angle - 0.48, len * 0.58, depth - 1);
      branch(to, angle + 0.38, len * 0.5, depth - 1);
    }

    branch(
      Offset(size.width * 0.1, size.height * 0.16),
      math.pi * 0.35,
      size.shortestSide * 0.2,
      3,
    );
    branch(
      Offset(size.width * 0.8, size.height * 0.58),
      math.pi * 1.15,
      size.shortestSide * 0.18,
      3,
    );
  }

  void _drawFilmGrain(Canvas canvas, Size size, double flicker) {
    final rng = math.Random(((t * 36).floor() + 17));
    final paint = Paint();
    for (var i = 0; i < 72; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      paint.color = (rng.nextBool()
              ? const Color(0xFFE8D4B0)
              : const Color(0xFF2A1C10))
          .withValues(alpha: (0.035 + rng.nextDouble() * 0.08) * flicker);
      canvas.drawRect(
        Rect.fromLTWH(x, y, 1.1 + rng.nextDouble() * 1.6, 1.0),
        paint,
      );
    }
  }

  void _drawWornBorder(Canvas canvas, Size size, double breathe) {
    final inset = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    final rrect = RRect.fromRectAndRadius(inset, const Radius.circular(26));

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.2
        ..color = const Color(0xFF4A3010).withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.8),
    );

    final worn = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFA88850).withValues(alpha: 0.4 + breathe * 0.08),
          const Color(0xFF5A3A18).withValues(alpha: 0.65),
          const Color(0xFF8A6840).withValues(alpha: 0.35),
          const Color(0xFF3A2810).withValues(alpha: 0.6),
        ],
      ).createShader(inset);

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      var on = true;
      while (d < metric.length) {
        final len = on ? 13.0 + (d % 8) : 5.0 + (d % 4);
        final next = (d + len).clamp(0.0, metric.length);
        if (on) canvas.drawPath(metric.extractPath(d, next), worn);
        d = next;
        on = !on;
      }
    }

    // Fuligem nos cantos lascados
    canvas.drawCircle(
      Offset(size.width * 0.94, 10),
      20,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF0A0604).withValues(alpha: 0.75),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(size.width * 0.94, 10), radius: 20),
        ),
    );
    canvas.drawCircle(
      Offset(8, size.height * 0.9),
      16,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF0A0604).withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(8, size.height * 0.9), radius: 16),
        ),
    );
  }

  /// Teia de canto — orb web clássica (raios + arcos), seda fina.
  void _drawCornerWeb(
    Canvas canvas, {
    required Offset origin,
    required double radius,
    required double startAngle,
    required double alpha,
    double sweep = math.pi / 2,
  }) {
    const rayCount = 6;
    const ringCount = 4;

    final glow = Paint()
      ..color = const Color(0xFFE8E0D0).withValues(alpha: alpha * 0.2)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);

    final silk = Paint()
      ..color = const Color(0xFFE4DCC8).withValues(alpha: alpha)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final silkSoft = Paint()
      ..color = const Color(0xFFD4CCB8).withValues(alpha: alpha * 0.65)
      ..strokeWidth = 0.55
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    Offset polar(double angle, double r) => Offset(
          origin.dx + math.cos(angle) * r,
          origin.dy + math.sin(angle) * r,
        );

    // Raios
    for (var i = 0; i < rayCount; i++) {
      final a = startAngle + sweep * (i / (rayCount - 1));
      final len = radius * (0.88 + (i.isEven ? 0.08 : 0.0));
      final end = polar(a, len);
      // Leve curva de tensão
      final ctrl = polar(a, len * 0.5).translate(
        math.cos(a + math.pi / 2) * 1.4,
        math.sin(a + math.pi / 2) * 1.4,
      );
      final path = Path()
        ..moveTo(origin.dx, origin.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);
      canvas.drawPath(path, glow);
      canvas.drawPath(path, i == 0 || i == rayCount - 1 ? silk : silkSoft);
    }

    // Anéis concêntricos (arcos reais)
    for (var ring = 1; ring <= ringCount; ring++) {
      final r = radius * (0.22 + (ring / ringCount) * 0.7);
      final rect = Rect.fromCircle(center: origin, radius: r);
      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        Paint()
          ..color = const Color(0xFFE8E0D0).withValues(alpha: alpha * 0.16)
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0),
      );
      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        Paint()
          ..color = const Color(0xFFE4DCC8).withValues(
            alpha: alpha * (ring.isOdd ? 0.7 : 0.9),
          )
          ..strokeWidth = ring == ringCount ? 0.65 : 0.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true,
      );
    }
  }

  void _drawDescendingSpider(Canvas canvas, Size size, double breathe) {
    final anchor = Offset(size.width - 18, 8);
    final drop = 0.14 + 0.1 * (0.5 + 0.5 * math.sin(t * math.pi * 2 - 0.4));
    final sway = math.sin(t * math.pi * 2 * 0.7) * 3.5;
    final spider = Offset(
      anchor.dx + sway,
      anchor.dy + size.height * drop,
    );

    final thread = Paint()
      ..color = const Color(0xFFE4DCC8).withValues(alpha: 0.32)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    canvas.drawLine(anchor, spider, thread);

    final body =
        Paint()..color = const Color(0xFF1A140E).withValues(alpha: 0.85);
    final bodySoft =
        Paint()..color = const Color(0xFF3A2E20).withValues(alpha: 0.8);
    canvas.drawOval(
      Rect.fromCenter(center: spider.translate(0, 1.6), width: 5.5, height: 7),
      body,
    );
    canvas.drawCircle(spider.translate(0, -2.0), 2.4, bodySoft);

    final legPaint = Paint()
      ..color = const Color(0xFF120E08).withValues(alpha: 0.75)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final kick = math.sin(t * math.pi * 2 * 1.4 + breathe) * 0.1;
    for (var side in [-1.0, 1.0]) {
      for (var i = 0; i < 4; i++) {
        final base = -0.55 + i * 0.35 + kick * side;
        final hip = spider.translate(side * 1.6, -1.0 + i * 1.1);
        final mid = hip.translate(
          side * (4.5 + i * 0.3) * math.cos(base),
          2.4 + i * 0.55,
        );
        final tip = mid.translate(
          side * (3.6 - i * 0.2) * math.cos(base + 0.4),
          2.8,
        );
        canvas.drawLine(hip, mid, legPaint);
        canvas.drawLine(mid, tip, legPaint);
      }
    }
  }

  double breatheNoise(double phase) =>
      0.5 + 0.5 * math.sin((t + phase) * math.pi * 2);

  // ─── VIDRO / EM DIA ───────────────────────────────────────────────────

  void _paintAlive(Canvas canvas, Size size) {
    final breathe = 0.5 + 0.5 * math.sin(t * math.pi * 2);
    final sheen = (t * 0.7) % 1.0;

    // Base de vidro — leve tint azul-cristal + claridade
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1 + breathe * 0.04),
            AppColors.primaryLight.withValues(alpha: 0.06),
            Colors.transparent,
            AppColors.accent.withValues(alpha: 0.04),
          ],
          stops: const [0.0, 0.25, 0.7, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Reflexo especular diagonal (vidro polido)
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(26),
      ),
    );

    // Faixa de brilho que varre o card
    final bandX = size.width * (sheen * 1.6 - 0.3);
    final bandPath = Path()
      ..moveTo(bandX - 18, 0)
      ..lineTo(bandX + 42, 0)
      ..lineTo(bandX + 8, size.height)
      ..lineTo(bandX - 52, size.height)
      ..close();
    canvas.drawPath(
      bandPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.04),
            Colors.white.withValues(alpha: 0.22 + breathe * 0.06),
            Colors.white.withValues(alpha: 0.06),
            Colors.transparent,
          ],
          stops: const [0.0, 0.28, 0.5, 0.72, 1.0],
        ).createShader(Rect.fromLTWH(bandX - 52, 0, 94, size.height)),
    );

    // Highlight de bisel no topo (aresta de vidro)
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(8, 5, size.width - 16, 2.2),
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.55 + breathe * 0.2),
            Colors.white.withValues(alpha: 0.7),
            Colors.transparent,
          ],
          stops: const [0.0, 0.25, 0.7, 1.0],
        ).createShader(Rect.fromLTWH(8, 5, size.width - 16, 2.2)),
    );

    // Borda interna esquerda (luz lateral)
    canvas.drawRect(
      Rect.fromLTWH(4, 12, 1.4, size.height - 28),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(4, 12, 1.4, size.height - 28)),
    );

    canvas.restore();

    // Aurora quente no canto superior direito
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.12),
      size.shortestSide * 0.58,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.accentBright.withValues(alpha: 0.28 + breathe * 0.1),
            AppColors.accent.withValues(alpha: 0.12),
            AppColors.primaryLight.withValues(alpha: 0.04),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 0.6, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.88, size.height * 0.12),
            radius: size.shortestSide * 0.58,
          ),
        ),
    );

    // Caústicos / manchas de luz no vidro
    for (var i = 0; i < 5; i++) {
      final phase = (t + i * 0.17) % 1.0;
      final cx = size.width * (0.15 + i * 0.18 + 0.04 * math.sin(phase * math.pi * 2));
      final cy = size.height * (0.25 + 0.12 * math.cos(phase * math.pi * 2 + i));
      final r = size.shortestSide * (0.08 + 0.04 * math.sin(phase * math.pi));
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: r * 2.4, height: r),
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.1 + breathe * 0.04),
              Colors.white.withValues(alpha: 0.02),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCenter(center: Offset(cx, cy), width: r * 2.4, height: r),
          ),
      );
    }

    // Partículas de luz — faíscas limpas
    for (final s in specs) {
      final cycle = (t * s.speed + s.phase) % 1.0;
      final y = 1.1 - cycle * 1.25;
      final x = (s.x + math.sin((t + s.phase) * math.pi * 2) * s.drift) % 1.0;
      final alpha = (math.sin(cycle * math.pi) * 0.85).clamp(0.0, 0.9);
      final c = switch (s.kind) {
        0 => AppColors.accentBright,
        1 => Colors.white,
        2 => AppColors.primaryLight,
        _ => AppColors.accentSoft,
      };
      final paint = Paint()..color = c.withValues(alpha: alpha);
      final ox = x * size.width;
      final oy = y * size.height;
      if (s.kind == 0) {
        // Cruz de brilho (sparkle)
        final spark = Paint()
          ..color = c.withValues(alpha: alpha)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(ox, oy - s.size * 1.4),
          Offset(ox, oy + s.size * 1.4),
          spark,
        );
        canvas.drawLine(
          Offset(ox - s.size * 1.0, oy),
          Offset(ox + s.size * 1.0, oy),
          spark,
        );
        canvas.drawCircle(Offset(ox, oy), s.size * 0.25, paint);
      } else {
        canvas.drawCircle(Offset(ox, oy), s.size * 0.45, paint);
      }
    }

    // Borda de vidro — highlight + sombra interna
    final inset = Rect.fromLTWH(1.2, 1.2, size.width - 2.4, size.height - 2.4);
    final rrect = RRect.fromRectAndRadius(inset, const Radius.circular(26));

    // Glow externo suave na borda
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..color = AppColors.accentBright.withValues(alpha: 0.12 + breathe * 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = ui.Gradient.linear(
          inset.topLeft,
          inset.bottomRight,
          [
            Colors.white.withValues(alpha: 0.75 + breathe * 0.15),
            AppColors.accentBright.withValues(alpha: 0.55),
            AppColors.primaryLight.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.4),
          ],
          const [0.0, 0.3, 0.7, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter old) =>
      old.mood != mood || old.t != t;
}

/// Grade de cor sobre o conteúdo (sépia / frio / limpo).
class HeroCardColorGrade extends StatelessWidget {
  final HeroCardMood mood;
  final Widget child;

  const HeroCardColorGrade({
    super.key,
    required this.mood,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final matrix = switch (mood) {
      HeroCardMood.frozen => _freezeMatrix,
      HeroCardMood.dusty => _dustMatrix,
      // Clareza + contraste — vidro limpo
      HeroCardMood.alive => _glassMatrix,
    };
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(matrix),
      child: child,
    );
  }

  /// Leve empurrão pro ciano / frio no backdrop.
  static const _freezeMatrix = <double>[
    0.78, 0.05, 0.2, 0, 12,
    0.05, 0.88, 0.22, 0, 16,
    0.05, 0.15, 1.22, 0, 28,
    0, 0, 0, 1, 0,
  ];

  /// Sépia escura — abandono / terra.
  static const _dustMatrix = <double>[
    0.4, 0.36, 0.08, 0, 10,
    0.26, 0.3, 0.06, 0, 4,
    0.08, 0.12, 0.12, 0, -4,
    0, 0, 0, 1, 0,
  ];

  /// Contraste + saturação leve — limpo como vidro.
  static const _glassMatrix = <double>[
    1.08, -0.02, -0.02, 0, 6,
    -0.02, 1.06, -0.01, 0, 4,
    -0.01, -0.01, 1.1, 0, 8,
    0, 0, 0, 1, 0,
  ];
}

/// Tokens de UI por mood — borda, labels, CTA.
class HeroCardMoodStyle {
  final Color border;
  final double borderWidth;
  final Color glow;
  final Color label;
  final Color footer;
  final String stepLabel;

  const HeroCardMoodStyle({
    required this.border,
    required this.borderWidth,
    required this.glow,
    required this.label,
    required this.footer,
    required this.stepLabel,
  });

  static HeroCardMoodStyle of(
    HeroCardMood mood, {
    required Color trailAccent,
  }) {
    return switch (mood) {
      HeroCardMood.frozen => HeroCardMoodStyle(
          border: AppColors.iceSoft.withValues(alpha: 0.95),
          borderWidth: 2.4,
          glow: AppColors.ice.withValues(alpha: 0.45),
          label: AppColors.iceSoft,
          footer: AppColors.iceSoft.withValues(alpha: 0.95),
          stepLabel: 'Protegido pelo gelo',
        ),
      HeroCardMood.dusty => HeroCardMoodStyle(
          border: const Color(0xFF6B4A28).withValues(alpha: 0.7),
          borderWidth: 1.6,
          glow: const Color(0xFF1A1008).withValues(alpha: 0.5),
          label: const Color(0xFFB89868),
          footer: const Color(0xFF9A7850),
          stepLabel: 'Ficando para trás',
        ),
      HeroCardMood.alive => HeroCardMoodStyle(
          border: Colors.white.withValues(alpha: 0.5),
          borderWidth: 2.0,
          glow: trailAccent.withValues(alpha: 0.32),
          label: trailAccent,
          footer: trailAccent,
          stepLabel: 'Em dia',
        ),
    };
  }
}

/// Resolve mood a partir do progresso.
///
/// Em risco (ainda dá para cumprir) → empoeirado.
/// Congelado só depois que o gelo de fato cobriu um dia.
HeroCardMood resolveHeroCardMood({
  required bool atRisk,
  required bool freezeUsedThisWeek,
}) {
  if (atRisk) return HeroCardMood.dusty;
  if (freezeUsedThisWeek) return HeroCardMood.frozen;
  return HeroCardMood.alive;
}
