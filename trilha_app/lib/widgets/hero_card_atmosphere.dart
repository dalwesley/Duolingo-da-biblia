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
      HeroCardMood.dusty => 58,
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
    final flicker = 0.92 + 0.08 * math.sin(t * math.pi * 11);
    final breathe = 0.5 + 0.5 * math.sin(t * math.pi * 2);

    // Lavagem de terra / pergaminho velho — bem opaca
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6A4528).withValues(alpha: 0.62 * flicker),
            const Color(0xFF2E1C10).withValues(alpha: 0.55),
            const Color(0xFF0E0804).withValues(alpha: 0.78),
          ],
          stops: const [0.0, 0.42, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Manchas de umidade / pó acumulado
    for (final spot in const [
      Alignment(-0.85, -0.7),
      Alignment(0.9, -0.55),
      Alignment(-0.6, 0.75),
      Alignment(0.75, 0.85),
      Alignment(0.1, 0.2),
      Alignment(-0.2, -0.15),
    ]) {
      final cx = (spot.x * 0.5 + 0.5) * size.width;
      final cy = (spot.y * 0.5 + 0.5) * size.height;
      final r = size.shortestSide * (0.3 + breathe * 0.035);
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF9A7850).withValues(alpha: 0.34),
              const Color(0xFF5A3A1C).withValues(alpha: 0.14),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
      );
    }

    // Poeira acumulada nas bordas inferiores
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.38),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF8A6840).withValues(alpha: 0.18),
            const Color(0xFF5A3A18).withValues(alpha: 0.42),
          ],
        ).createShader(
          Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.38),
        ),
    );

    // Vinheta gasta
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.05),
          radius: 1.15,
          colors: [
            Colors.transparent,
            const Color(0xFF1A1008).withValues(alpha: 0.45),
            Colors.black.withValues(alpha: 0.78),
          ],
          stops: const [0.25, 0.65, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Teias grandes e legíveis
    _drawCornerWeb(
      canvas,
      origin: Offset(size.width - 4, 4),
      radius: size.shortestSide * 0.52,
      flipX: true,
      alpha: 0.58,
    );
    _drawCornerWeb(
      canvas,
      origin: const Offset(4, 6),
      radius: size.shortestSide * 0.36,
      flipX: false,
      alpha: 0.48,
    );
    // Teia menor no canto inferior esquerdo
    _drawCornerWeb(
      canvas,
      origin: Offset(8, size.height - 6),
      radius: size.shortestSide * 0.22,
      flipX: false,
      flipY: true,
      alpha: 0.32,
    );
    _drawDescendingSpider(canvas, size, breathe);

    // Poeira densa flutuando
    for (final s in specs) {
      final cycle = (t * s.speed * 0.4 + s.phase) % 1.0;
      final y = 1.08 - ((s.y + cycle) % 1.2);
      final x = (s.x +
              math.sin((t * 0.55 + s.phase) * math.pi * 2) * s.drift * 1.6) %
          1.0;
      final alpha =
          (0.1 + 0.22 * math.sin(cycle * math.pi)).clamp(0.0, 0.32);
      final dust = Color.lerp(
        const Color(0xFFB8956A),
        const Color(0xFFE8D4B0),
        s.kind / 3,
      )!;
      final pos = Offset(x * size.width, y * size.height);
      final r = s.size * (0.85 + 0.4 * breatheNoise(s.phase));
      canvas.drawCircle(
        pos,
        r,
        Paint()..color = dust.withValues(alpha: alpha * flicker),
      );
      if (s.kind == 0) {
        canvas.drawCircle(
          pos.translate(r * 0.6, -r * 0.3),
          r * 0.45,
          Paint()..color = dust.withValues(alpha: alpha * 0.55 * flicker),
        );
      }
    }

    // Riscos de filme / arranhões
    final scratch = Paint()
      ..color = const Color(0xFFD4B896).withValues(alpha: 0.09 + 0.05 * flicker)
      ..strokeWidth = 1.15;
    final scratchX = size.width * ((t * 2.9) % 1.0);
    canvas.drawLine(
      Offset(scratchX, 0),
      Offset(scratchX + 3, size.height),
      scratch,
    );
    final scratchX2 = size.width * ((t * 1.7 + 0.55) % 1.0);
    canvas.drawLine(
      Offset(scratchX2, 0),
      Offset(scratchX2 - 2, size.height),
      scratch
        ..color = const Color(0xFFC4A070).withValues(alpha: 0.06),
    );

    // Borda de barro
    final inset = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inset, const Radius.circular(26)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFC4A070).withValues(alpha: 0.6 + breathe * 0.12),
            const Color(0xFF6B4A28).withValues(alpha: 0.5),
            const Color(0xFFA87840).withValues(alpha: 0.55),
          ],
        ).createShader(inset),
    );
  }

  void _drawCornerWeb(
    Canvas canvas, {
    required Offset origin,
    required double radius,
    required bool flipX,
    required double alpha,
    bool flipY = false,
  }) {
    final silk = Paint()
      ..color = const Color(0xFFE8E0D0).withValues(alpha: alpha)
      ..strokeWidth = 1.35
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final silkSoft = Paint()
      ..color = const Color(0xFFD8D0C0).withValues(alpha: alpha * 0.72)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final halo = Paint()
      ..color = Colors.black.withValues(alpha: alpha * 0.35)
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final sx = flipX ? -1.0 : 1.0;
    final sy = flipY ? -1.0 : 1.0;

    // Raios do canto
    const rays = 9;
    for (var i = 0; i < rays; i++) {
      final a = (i / (rays - 1)) * (math.pi / 2);
      // Leve ondulação — teia orgânica
      final wobble = 1.0 + 0.04 * math.sin(i * 1.7 + t * math.pi * 2);
      final dx = math.cos(a) * radius * sx * wobble;
      final dy = math.sin(a) * radius * sy * wobble;
      final end = origin.translate(dx, dy);
      canvas.drawLine(origin, end, halo);
      canvas.drawLine(origin, end, silk);
    }

    // Arcos concêntricos irregulares
    for (var ring = 1; ring <= 6; ring++) {
      final r = radius * (ring / 6.2);
      final path = Path();
      var first = true;
      for (var i = 0; i <= 24; i++) {
        final a = (i / 24) * (math.pi / 2);
        final wobble = 1.0 + 0.06 * math.sin(i * 0.9 + ring * 1.3);
        final dx = math.cos(a) * r * sx * wobble;
        final dy = math.sin(a) * r * sy * wobble;
        final p = origin.translate(dx, dy);
        if (first) {
          path.moveTo(p.dx, p.dy);
          first = false;
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, halo..strokeWidth = 2.2);
      canvas.drawPath(path, ring.isEven ? silk : silkSoft);
    }
  }

  void _drawDescendingSpider(Canvas canvas, Size size, double breathe) {
    final anchor = Offset(size.width - 32, 22);
    final drop = 0.2 + 0.16 * (0.5 + 0.5 * math.sin(t * math.pi * 2 - 0.4));
    final sway = math.sin(t * math.pi * 2 * 0.7) * 5.5;
    final spider = Offset(
      anchor.dx + sway,
      anchor.dy + size.height * drop,
    );

    final thread = Paint()
      ..color = const Color(0xFFE8E0D0).withValues(alpha: 0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    canvas.drawLine(anchor, spider, thread);

    final body =
        Paint()..color = const Color(0xFF1A140E).withValues(alpha: 0.96);
    final bodySoft =
        Paint()..color = const Color(0xFF3A2E20).withValues(alpha: 0.95);
    // Abdômen + cefalotórax um pouco maiores
    canvas.drawOval(
      Rect.fromCenter(center: spider.translate(0, 2.6), width: 9, height: 11),
      body,
    );
    canvas.drawCircle(spider.translate(0, -3.2), 3.8, bodySoft);

    final legPaint = Paint()
      ..color = const Color(0xFF120E08).withValues(alpha: 0.95)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final kick = math.sin(t * math.pi * 2 * 1.4 + breathe) * 0.14;
    for (var side in [-1.0, 1.0]) {
      for (var i = 0; i < 4; i++) {
        final base = -0.55 + i * 0.35 + kick * side;
        final hip = spider.translate(side * 2.6, -1.8 + i * 1.8);
        final mid = hip.translate(
          side * (7.5 + i * 0.45) * math.cos(base),
          4.0 + i * 0.9,
        );
        final tip = mid.translate(
          side * (6.2 - i * 0.3) * math.cos(base + 0.4),
          4.8,
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

  /// Sépia forte — pergaminho / terra.
  static const _dustMatrix = <double>[
    0.45, 0.4, 0.1, 0, 22,
    0.3, 0.35, 0.08, 0, 10,
    0.1, 0.15, 0.14, 0, 0,
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
          border: AppColors.iceSoft.withValues(alpha: 0.9),
          borderWidth: 2.0,
          glow: AppColors.ice.withValues(alpha: 0.4),
          label: AppColors.iceSoft,
          footer: AppColors.iceSoft.withValues(alpha: 0.95),
          stepLabel: 'Protegido pelo gelo',
        ),
      HeroCardMood.dusty => HeroCardMoodStyle(
          border: const Color(0xFFB88848).withValues(alpha: 0.9),
          borderWidth: 2.2,
          glow: const Color(0xFF6B4A28).withValues(alpha: 0.4),
          label: const Color(0xFFD4B896),
          footer: const Color(0xFFC4A070),
          stepLabel: 'Ficando para trás',
        ),
      HeroCardMood.alive => HeroCardMoodStyle(
          border: Colors.white.withValues(alpha: 0.45),
          borderWidth: 1.5,
          glow: trailAccent.withValues(alpha: 0.28),
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
