import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// Camadas de película compartilhadas pelas cenas do onboarding.
class FilmLayers {
  FilmLayers._();

  static const starCold = Color(0xFFBFD8FF);
  static const starWarm = Color(0xFFFFE7A8);

  /// Duração do loop de [time] das cenas (o "breath" do onboarding).
  static const loopMs = 7600;

  static final List<_Star> _stars = () {
    final rnd = math.Random(7);
    return List.generate(170, (_) {
      final depth = rnd.nextDouble();
      return _Star(
        rnd.nextDouble(),
        math.pow(rnd.nextDouble(), 1.35).toDouble(),
        0.35 + depth * 1.25,
        rnd.nextDouble() * math.pi * 2,
        1 + rnd.nextInt(3),
        depth,
      );
    });
  }();

  /// Fração de [t] dentro de [a, b], com curva.
  static double seg(
    double t,
    double a,
    double b, [
    Curve curve = Curves.linear,
  ]) {
    if (t <= a) return 0;
    if (t >= b) return 1;
    return curve.transform((t - a) / (b - a));
  }

  /// Relógio contínuo (segundos) para o céu girar sem emenda de loop.
  static double get clock => DateTime.now().millisecondsSinceEpoch / 1000;

  /// Céu estrelado até [floor] (fração da altura), cintilando com [loop].
  ///
  /// [pan] (segundos) faz o céu correr devagar para a direita, em
  /// paralaxe: estrelas próximas andam mais. Também solta uma estrela
  /// cadente de tempos em tempos.
  ///
  /// [tilt] (-1 a 1, do [TiltParallax]) desloca o céu com o movimento do
  /// celular: estrelas próximas até [tiltReach] px, distantes bem menos.
  static const tiltReach = 72.0;

  static void stars(
    Canvas canvas,
    Size size, {
    required double alpha,
    required double loop,
    double floor = 0.62,
    double pan = 0,
    Offset tilt = Offset.zero,
  }) {
    if (alpha <= 0.01) return;
    final paint = Paint();
    // Com o celular inclinado o céu desce; não deixa estrela cair na arte.
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, floor * size.height + 6));
    for (final s in _stars) {
      final twinkle = 0.55 + 0.45 * math.sin(loop * s.speed + s.phase);
      final a = (alpha * twinkle * (0.35 + 0.65 * s.depth)).clamp(0.0, 1.0);
      final x = (s.x + pan * (0.002 + 0.009 * s.depth)) % 1.0;
      final shift = tilt * (tiltReach * (0.3 + 0.7 * s.depth));
      final pos = Offset(
        (x * size.width + shift.dx) % size.width,
        s.y * floor * size.height + shift.dy * 0.7,
      );
      paint.color = Color.lerp(
        starCold,
        starWarm,
        s.depth * 0.5,
      )!.withValues(alpha: a);
      canvas.drawCircle(pos, s.r, paint);
    }
    if (pan > 0 && alpha > 0.3) {
      canvas.save();
      canvas.translate(tilt.dx * tiltReach * 0.6, tilt.dy * tiltReach * 0.4);
      _shootingStar(canvas, size, alpha, floor, pan);
      canvas.restore();
    }
    canvas.restore();
  }

  static void _shootingStar(
    Canvas canvas,
    Size size,
    double alpha,
    double floor,
    double pan,
  ) {
    const period = 7.0;
    const life = 0.9;
    final phase = pan % period;
    if (phase > life) return;
    final p = phase / life;
    final rnd = math.Random((pan / period).floor());
    final start = Offset(
      size.width * (0.1 + 0.6 * rnd.nextDouble()),
      size.height * floor * (0.1 + 0.5 * rnd.nextDouble()),
    );
    const dir = Offset(0.9, 0.42);
    final travel = size.width * 0.38;
    final head = start + dir * (travel * p);
    final tail = head - dir * (70 * (0.4 + 0.6 * math.sin(math.pi * p)));
    final a = alpha * math.sin(math.pi * p);
    canvas.drawLine(
      tail,
      head,
      Paint()
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(tail, head, [
          const Color(0x00FFFFFF),
          const Color(0xFFFFFFFF).withValues(alpha: 0.9 * a),
        ]),
    );
  }

  static void vignette(Canvas canvas, Size size, {double strength = 0.62}) {
    final full = Offset.zero & size;
    canvas.drawRect(
      full,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.3),
          radius: 1.1,
          colors: [
            const Color(0x00000000),
            const Color(0xFF000000).withValues(alpha: strength),
          ],
          stops: const [0.55, 1.0],
        ).createShader(full),
    );
  }

  /// Grão a ~24 quadros/s, como película.
  static void grain(Canvas canvas, Size size, double time) {
    final frame = (time * loopMs / 42).floor();
    final rnd = math.Random(frame);
    const n = 700;
    final points = Float32List(n * 2);
    for (var i = 0; i < n; i++) {
      points[i * 2] = rnd.nextDouble() * size.width;
      points[i * 2 + 1] = rnd.nextDouble() * size.height;
    }
    canvas.drawRawPoints(
      ui.PointMode.points,
      points,
      Paint()
        ..color = const Color(0x0DFFFFFF)
        ..strokeWidth = 1.2,
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double r;
  final double phase;
  final int speed;
  final double depth;

  const _Star(this.x, this.y, this.r, this.phase, this.speed, this.depth);
}
