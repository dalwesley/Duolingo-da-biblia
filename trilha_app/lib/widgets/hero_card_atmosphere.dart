import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'ui_primitives.dart';

/// Humor cinematográfico do card de continuar.
enum HeroCardMood {
  /// Gelo já cobriu um dia nesta semana — cristal, frio, brilho.
  frozen,

  /// Em risco, mas ainda dá tempo — pó, sépia, filme velho.
  dusty,

  /// Em dia — vitalidade quente, luz viva.
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
      duration: const Duration(milliseconds: 4800),
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
      HeroCardMood.frozen => 28,
      HeroCardMood.dusty => 42,
      HeroCardMood.alive => 22,
    };
    return List.generate(count, (i) {
      return _Spec(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: switch (mood) {
          HeroCardMood.frozen => 2.2 + rng.nextDouble() * 4.5,
          HeroCardMood.dusty => 1.2 + rng.nextDouble() * 2.8,
          HeroCardMood.alive => 1.6 + rng.nextDouble() * 3.2,
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

  void _paintFrozen(Canvas canvas, Size size) {
    final breathe = 0.5 + 0.5 * math.sin(t * math.pi * 2);

    // Grade gelada
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.iceSoft.withValues(alpha: 0.22 + breathe * 0.06),
            AppColors.iceDeep.withValues(alpha: 0.45),
            const Color(0xFF0A1A28).withValues(alpha: 0.55),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Geada nos cantos
    _frostCorner(canvas, size, Alignment.topLeft, breathe);
    _frostCorner(canvas, size, Alignment.topRight, breathe);
    _frostCorner(canvas, size, Alignment.bottomLeft, breathe * 0.7);

    // Cristais flutuando
    for (final s in specs) {
      final cycle = (t * s.speed + s.phase) % 1.0;
      final y = (s.y + cycle * 0.55) % 1.2 - 0.1;
      final x = (s.x + math.sin((t + s.phase) * math.pi * 2) * s.drift) % 1.0;
      final alpha = (0.25 + 0.55 * (1 - (cycle - 0.5).abs() * 2))
          .clamp(0.0, 0.85);
      final c = Color.lerp(
        AppColors.iceSoft,
        Colors.white,
        s.kind.isEven ? 0.55 : 0.2,
      )!;
      final paint = Paint()..color = c.withValues(alpha: alpha);
      final ox = x * size.width;
      final oy = y * size.height;
      canvas.save();
      canvas.translate(ox, oy);
      canvas.rotate(cycle * math.pi + s.phase * math.pi);
      if (s.kind == 0 || s.kind == 2) {
        _drawCrystal(canvas, s.size, paint);
      } else {
        canvas.drawCircle(Offset.zero, s.size * 0.35, paint);
      }
      canvas.restore();
    }

    // Brilho de borda interna
    final inset = Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inset, const Radius.circular(26)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.iceSoft.withValues(alpha: 0.55 + breathe * 0.25),
            AppColors.ice.withValues(alpha: 0.15),
            AppColors.iceSoft.withValues(alpha: 0.35),
          ],
        ).createShader(inset),
    );
  }

  void _frostCorner(
    Canvas canvas,
    Size size,
    Alignment align,
    double breathe,
  ) {
    final cx = align.x < 0 ? 0.0 : size.width;
    final cy = align.y < 0 ? 0.0 : size.height;
    final radius = size.shortestSide * (0.42 + breathe * 0.04);
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.iceSoft.withValues(alpha: 0.38),
            AppColors.ice.withValues(alpha: 0.12),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        ),
    );

    // Veios de gelo
    final vein = Paint()
      ..color = Colors.white.withValues(alpha: 0.18 + breathe * 0.08)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final dirX = align.x < 0 ? 1.0 : -1.0;
    final dirY = align.y < 0 ? 1.0 : -1.0;
    for (var i = 0; i < 5; i++) {
      final a = 0.18 + i * 0.12;
      final path = Path()
        ..moveTo(cx, cy)
        ..lineTo(cx + dirX * radius * a, cy + dirY * radius * a * 0.35)
        ..lineTo(
          cx + dirX * radius * a * 0.7,
          cy + dirY * radius * (a + 0.08),
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
  }

  void _paintDusty(Canvas canvas, Size size) {
    final flicker = 0.94 + 0.06 * math.sin(t * math.pi * 11);
    final breathe = 0.5 + 0.5 * math.sin(t * math.pi * 2);

    // Lavagem de terra / pergaminho velho
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF5C3D22).withValues(alpha: 0.55 * flicker),
            const Color(0xFF2A1A0E).withValues(alpha: 0.48),
            const Color(0xFF120A06).withValues(alpha: 0.72),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Manchas de umidade / pó acumulado
    for (final spot in const [
      Alignment(-0.85, -0.7),
      Alignment(0.9, -0.55),
      Alignment(-0.6, 0.75),
      Alignment(0.75, 0.85),
      Alignment(0.1, 0.2),
    ]) {
      final cx = (spot.x * 0.5 + 0.5) * size.width;
      final cy = (spot.y * 0.5 + 0.5) * size.height;
      final r = size.shortestSide * (0.28 + breathe * 0.03);
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF8A6840).withValues(alpha: 0.28),
              const Color(0xFF4A3218).withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
      );
    }

    // Vinheta gasta
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.05),
          radius: 1.2,
          colors: [
            Colors.transparent,
            const Color(0xFF1A1008).withValues(alpha: 0.4),
            Colors.black.withValues(alpha: 0.7),
          ],
          stops: const [0.3, 0.7, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Teias nos cantos superiores + aranha descendo
    _drawCornerWeb(
      canvas,
      origin: Offset(size.width - 6, 6),
      radius: size.shortestSide * 0.42,
      flipX: true,
      alpha: 0.42,
    );
    _drawCornerWeb(
      canvas,
      origin: const Offset(6, 8),
      radius: size.shortestSide * 0.3,
      flipX: false,
      alpha: 0.34,
    );
    _drawDescendingSpider(canvas, size, breathe);

    // Poeira leve flutuando (quase transparente)
    for (final s in specs) {
      final cycle = (t * s.speed * 0.45 + s.phase) % 1.0;
      final y = 1.08 - ((s.y + cycle) % 1.2);
      final x = (s.x +
              math.sin((t * 0.55 + s.phase) * math.pi * 2) * s.drift * 1.6) %
          1.0;
      final alpha = (0.06 + 0.12 * math.sin(cycle * math.pi)).clamp(0.0, 0.18);
      final dust = Color.lerp(
        const Color(0xFFB8956A),
        const Color(0xFFE8D4B0),
        s.kind / 3,
      )!;
      final pos = Offset(x * size.width, y * size.height);
      final r = s.size * (0.7 + 0.35 * breatheNoise(s.phase));
      canvas.drawCircle(
        pos,
        r,
        Paint()..color = dust.withValues(alpha: alpha * flicker),
      );
      if (s.kind == 0) {
        canvas.drawCircle(
          pos.translate(r * 0.6, -r * 0.3),
          r * 0.4,
          Paint()..color = dust.withValues(alpha: alpha * 0.5 * flicker),
        );
      }
    }

    // Riscos de filme / arranhões
    final scratch = Paint()
      ..color = const Color(0xFFD4B896).withValues(alpha: 0.07 + 0.04 * flicker)
      ..strokeWidth = 1.1;
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
        ..color = const Color(0xFFC4A070).withValues(alpha: 0.05),
    );

    // Borda de barro (sem rachadura)
    final inset = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inset, const Radius.circular(26)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFC4A070).withValues(alpha: 0.55 + breathe * 0.12),
            const Color(0xFF6B4A28).withValues(alpha: 0.45),
            const Color(0xFFA87840).withValues(alpha: 0.5),
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
  }) {
    final silk = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..strokeWidth = 1.25
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final silkSoft = Paint()
      ..color = Colors.white.withValues(alpha: alpha * 0.7)
      ..strokeWidth = 0.95
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    // Contorno suave atrás — teia mais legível no fundo escuro
    final halo = Paint()
      ..color = Colors.black.withValues(alpha: alpha * 0.25)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Raios do canto
    const rays = 8;
    for (var i = 0; i < rays; i++) {
      final a = (i / (rays - 1)) * (math.pi / 2);
      final dx = math.cos(a) * radius * (flipX ? -1 : 1);
      final dy = math.sin(a) * radius;
      final end = origin.translate(dx, dy);
      canvas.drawLine(origin, end, halo);
      canvas.drawLine(origin, end, silk);
    }

    // Arcos concêntricos
    for (var ring = 1; ring <= 5; ring++) {
      final r = radius * (ring / 5.1);
      final path = Path();
      var first = true;
      for (var i = 0; i <= 20; i++) {
        final a = (i / 20) * (math.pi / 2);
        final dx = math.cos(a) * r * (flipX ? -1 : 1);
        final dy = math.sin(a) * r;
        final p = origin.translate(dx, dy);
        if (first) {
          path.moveTo(p.dx, p.dy);
          first = false;
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, halo..strokeWidth = 2.0);
      canvas.drawPath(path, ring.isEven ? silk : silkSoft);
    }
  }

  void _drawDescendingSpider(Canvas canvas, Size size, double breathe) {
    // Âncora na teia do canto superior direito
    final anchor = Offset(size.width - 28, 18);
    // Desce e sobe lentamente pela linha
    final drop = 0.18 + 0.14 * (0.5 + 0.5 * math.sin(t * math.pi * 2 - 0.4));
    final sway = math.sin(t * math.pi * 2 * 0.7) * 4.5;
    final spider = Offset(
      anchor.dx + sway,
      anchor.dy + size.height * drop,
    );

    final thread = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    canvas.drawLine(anchor, spider, thread);

    // Corpo
    final body = Paint()..color = const Color(0xFF2A2218).withValues(alpha: 0.95);
    final bodySoft = Paint()..color = const Color(0xFF4A3A28).withValues(alpha: 0.9);
    canvas.drawOval(
      Rect.fromCenter(center: spider.translate(0, 2.2), width: 7.5, height: 9),
      body,
    );
    canvas.drawCircle(spider.translate(0, -2.8), 3.2, bodySoft);

    // Pernas — levemente animadas
    final legPaint = Paint()
      ..color = const Color(0xFF1A140E).withValues(alpha: 0.92)
      ..strokeWidth = 1.15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final kick = math.sin(t * math.pi * 2 * 1.4 + breathe) * 0.12;
    for (var side in [-1.0, 1.0]) {
      for (var i = 0; i < 4; i++) {
        final base = -0.55 + i * 0.35 + kick * side;
        final hip = spider.translate(side * 2.2, -1.5 + i * 1.6);
        final mid = hip.translate(
          side * (6.5 + i * 0.4) * math.cos(base),
          3.5 + i * 0.8,
        );
        final tip = mid.translate(
          side * (5.5 - i * 0.3) * math.cos(base + 0.4),
          4.2,
        );
        canvas.drawLine(hip, mid, legPaint);
        canvas.drawLine(mid, tip, legPaint);
      }
    }
  }

  double breatheNoise(double phase) =>
      0.5 + 0.5 * math.sin((t + phase) * math.pi * 2);

  void _paintAlive(Canvas canvas, Size size) {
    final breathe = 0.5 + 0.5 * math.sin(t * math.pi * 2);

    // Luz viva do alto
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.accent.withValues(alpha: 0.14 + breathe * 0.05),
            AppColors.primary.withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 0.75],
        ).createShader(Offset.zero & size),
    );

    // Aurora suave no canto
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      size.shortestSide * 0.55,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.accentBright.withValues(alpha: 0.18 + breathe * 0.06),
            AppColors.primaryLight.withValues(alpha: 0.06),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.85, size.height * 0.15),
            radius: size.shortestSide * 0.55,
          ),
        ),
    );

    // Faíscas subindo
    for (final s in specs) {
      final cycle = (t * s.speed + s.phase) % 1.0;
      final y = 1.1 - cycle * 1.25;
      final x = (s.x + math.sin((t + s.phase) * math.pi * 2) * s.drift) % 1.0;
      final alpha = (math.sin(cycle * math.pi) * 0.7).clamp(0.0, 0.75);
      final c = switch (s.kind) {
        0 => AppColors.accentBright,
        1 => Colors.white,
        2 => AppColors.primaryLight,
        _ => AppColors.sand,
      };
      final paint = Paint()..color = c.withValues(alpha: alpha);
      final ox = x * size.width;
      final oy = y * size.height;
      if (s.kind == 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(ox, oy),
              width: s.size * 0.4,
              height: s.size * 2.2,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      } else {
        canvas.drawCircle(Offset(ox, oy), s.size * 0.4, paint);
      }
    }

    // Borda dourada viva
    final inset = Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inset, const Radius.circular(26)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.35
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentBright.withValues(alpha: 0.55 + breathe * 0.2),
            AppColors.accent.withValues(alpha: 0.2),
            AppColors.primaryLight.withValues(alpha: 0.4),
          ],
        ).createShader(inset),
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
    if (mood == HeroCardMood.alive) return child;

    final matrix = switch (mood) {
      HeroCardMood.frozen => _freezeMatrix,
      HeroCardMood.dusty => _dustMatrix,
      HeroCardMood.alive => null,
    };
    if (matrix == null) return child;
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(matrix),
      child: child,
    );
  }

  /// Leve empurrão pro ciano / frio no backdrop (conteúdo fica por cima).
  static const _freezeMatrix = <double>[
    0.85, 0.05, 0.15, 0, 8,
    0.05, 0.90, 0.18, 0, 12,
    0.05, 0.12, 1.15, 0, 22,
    0, 0, 0, 1, 0,
  ];

  /// Sépia forte — pergaminho / terra, sem vermelho.
  static const _dustMatrix = <double>[
    0.48, 0.42, 0.12, 0, 18,
    0.32, 0.38, 0.10, 0, 8,
    0.12, 0.18, 0.16, 0, 0,
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
          border: AppColors.ice.withValues(alpha: 0.85),
          borderWidth: 1.85,
          glow: AppColors.ice.withValues(alpha: 0.28),
          label: AppColors.iceSoft,
          footer: AppColors.iceSoft.withValues(alpha: 0.92),
          stepLabel: 'Protegido pelo gelo',
        ),
      HeroCardMood.dusty => HeroCardMoodStyle(
          border: const Color(0xFFA87840).withValues(alpha: 0.85),
          borderWidth: 2.0,
          glow: const Color(0xFF6B4A28).withValues(alpha: 0.35),
          label: const Color(0xFFD4B896),
          footer: const Color(0xFFC4A070),
          stepLabel: 'Ficando para trás',
        ),
      HeroCardMood.alive => HeroCardMoodStyle(
          border: AppMetrics.accentBorder(alpha: 0.55, color: trailAccent),
          borderWidth: 1.25,
          glow: trailAccent.withValues(alpha: 0.12),
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
