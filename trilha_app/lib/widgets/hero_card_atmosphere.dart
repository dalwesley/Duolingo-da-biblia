import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'ui_primitives.dart';

/// Humor cinematográfico do card de continuar.
enum HeroCardMood {
  /// Gelo cobriu ontem — cristal, frio, fosco.
  frozen,

  /// Em risco, mas ainda dá tempo — pó, sépia, filme velho.
  dusty,

  /// Em dia — céu limpo, sem reflexo de vidro.
  alive,
}

/// Camada da atmosfera. O palco pinta [back] sob o texto e [front] por cima,
/// para a sujeira / geada envolver o conteúdo sem apagar a leitura.
enum HeroAtmosphereLayer { all, back, front }

/// Overlay animado por mood — partículas + grade de cor + borda viva.
class HeroCardAtmosphere extends StatefulWidget {
  final HeroCardMood mood;
  final HeroAtmosphereLayer layer;

  const HeroCardAtmosphere({
    super.key,
    required this.mood,
    this.layer = HeroAtmosphereLayer.all,
  });

  @override
  State<HeroCardAtmosphere> createState() => _HeroCardAtmosphereState();
}

class _HeroCardAtmosphereState extends State<HeroCardAtmosphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  /// 30 quadros no ciclo de 5,2 s. Pó e feixe não precisam do refresh da tela.
  late final _CoarseClock _coarse;
  final _grain = _GrainSheet();
  late List<_Spec> _specs;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    );
    _coarse = _CoarseClock(_pulse, steps: 156);
    _specs = _buildSpecs(widget.mood);
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant HeroCardAtmosphere oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) {
      _specs = _buildSpecs(widget.mood);
    }
    if (oldWidget.mood != widget.mood || oldWidget.layer != widget.layer) {
      _syncMotion();
    }
  }

  /// Fundo de pó / gelo é quadro parado: pinta uma vez e fica em cache.
  /// Só o que se move (partículas, pingentes, feixes) gasta frame.
  bool get _animated =>
      widget.layer != HeroAtmosphereLayer.back ||
      widget.mood == HeroCardMood.alive;

  void _syncMotion() {
    if (_animated) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else {
      _pulse.stop();
      _pulse.value = 0;
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
    _coarse.dispose();
    _pulse.dispose();
    _grain.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wash =
        widget.mood == HeroCardMood.alive &&
        widget.layer != HeroAtmosphereLayer.front;
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (wash)
            FadeTransition(
              opacity: _pulse.drive(const _WashBreath()),
              child: const RepaintBoundary(
                child: CustomPaint(
                  painter: _AliveWashPainter(),
                  size: Size.infinite,
                ),
              ),
            ),
          RepaintBoundary(
            child: CustomPaint(
              painter: _AtmospherePainter(
                mood: widget.mood,
                layer: widget.layer,
                clock: _coarse,
                specs: _specs,
                grain: _grain,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

/// Relógio do palco em ~30 fps. O ticker segue a tela; o paint, não.
class _CoarseClock extends ChangeNotifier {
  _CoarseClock(this._source, {required this.steps}) {
    _source.addListener(_onTick);
  }

  final Animation<double> _source;
  final int steps;
  int _bucket = -1;

  double get value => _source.value;

  void _onTick() {
    final bucket = (_source.value * steps).floor();
    if (bucket == _bucket) return;
    _bucket = bucket;
    notifyListeners();
  }

  @override
  void dispose() {
    _source.removeListener(_onTick);
    super.dispose();
  }
}

/// Véu e feixes pintados uma vez. A respiração é opacidade da camada.
class _WashBreath extends Animatable<double> {
  const _WashBreath();

  @override
  double transform(double t) {
    final breathe = 0.5 + 0.5 * math.sin(t * math.pi * 2);
    return 0.7 + breathe * 0.3;
  }
}

class _AliveWashPainter extends CustomPainter {
  const _AliveWashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _paintAliveWash(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _AliveWashPainter oldDelegate) => false;
}

/// Véu do dia no pico. A camada inteira respira por opacidade, sem
/// refazer os degradês a cada frame.
void _paintAliveWash(Canvas canvas, Size size) {
  const breathe = 1.0;
  const time = 0.22;
  final origin = Offset(size.width * 0.92, -size.height * 0.08);
  final reach = size.longestSide * 1.1;
  final sway = math.sin(time * math.pi * 2) * 0.03;
  const rays = <(double, double, double)>[
    (0.58, 0.05, 0.05),
    (0.68, 0.035, 0.035),
    (0.77, 0.06, 0.045),
    (0.88, 0.03, 0.03),
  ];
  for (var i = 0; i < rays.length; i++) {
    final (center, half, strength) = rays[i];
    final a = math.pi * (center + sway * (i.isEven ? 1 : -1));
    final spread = math.pi * half;
    final path = Path()
      ..moveTo(origin.dx, origin.dy)
      ..lineTo(
        origin.dx + math.cos(a - spread) * reach,
        origin.dy + math.sin(a - spread) * reach,
      )
      ..lineTo(
        origin.dx + math.cos(a + spread) * reach,
        origin.dy + math.sin(a + spread) * reach,
      )
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(
            origin.dx / size.width * 2 - 1,
            origin.dy / size.height * 2 - 1,
          ),
          radius: 1.3,
          colors: [
            AppColors.accentSoft.withValues(
              alpha: strength * (0.7 + breathe * 0.3),
            ),
            Colors.transparent,
          ],
        ).createShader(Offset.zero & size),
    );
  }

  canvas.drawRect(
    Offset.zero & size,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.03 + breathe * 0.01),
          Colors.transparent,
          AppColors.accent.withValues(alpha: 0.03),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Offset.zero & size),
  );

  canvas.drawCircle(
    Offset(size.width * 0.88, size.height * 0.12),
    size.shortestSide * 0.5,
    Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.accent.withValues(alpha: 0.1 + breathe * 0.04),
              AppColors.accent.withValues(alpha: 0.04),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.88, size.height * 0.12),
              radius: size.shortestSide * 0.5,
            ),
          ),
  );
}

/// Grão de filme gravado quando a semente muda (~7× por ciclo), não por frame.
class _GrainSheet {
  ui.Picture? _picture;
  int _seed = -1;
  Size _size = Size.zero;

  void paint(Canvas canvas, Size size, int seed) {
    if (_picture == null || _seed != seed || _size != size) {
      _picture?.dispose();
      _seed = seed;
      _size = size;
      final recorder = ui.PictureRecorder();
      final rec = Canvas(recorder);
      final rng = math.Random(seed);
      final paint = Paint();
      for (var i = 0; i < 72; i++) {
        final x = rng.nextDouble() * size.width;
        final y = rng.nextDouble() * size.height;
        paint.color =
            (rng.nextBool() ? const Color(0xFFE8D4B0) : const Color(0xFF2A1C10))
                .withValues(alpha: 0.035 + rng.nextDouble() * 0.08);
        rec.drawRect(
          Rect.fromLTWH(x, y, 1.1 + rng.nextDouble() * 1.6, 1.0),
          paint,
        );
      }
      _picture = recorder.endRecording();
    }
    canvas.drawPicture(_picture!);
  }

  void dispose() {
    _picture?.dispose();
    _picture = null;
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
  final HeroAtmosphereLayer layer;
  final _CoarseClock clock;
  final List<_Spec> specs;
  final _GrainSheet grain;
  final Paint _dot = Paint();

  /// Repinta direto pelo relógio — sem rebuild de widget a cada frame.
  _AtmospherePainter({
    required this.mood,
    required this.layer,
    required this.clock,
    required this.specs,
    required this.grain,
  }) : super(repaint: clock);

  double get t => clock.value;

  bool get _back => layer != HeroAtmosphereLayer.front;
  bool get _front => layer != HeroAtmosphereLayer.back;

  @override
  void paint(Canvas canvas, Size size) {
    switch (mood) {
      case HeroCardMood.frozen:
        if (_back) _paintFrozen(canvas, size);
        if (_front) _paintIcicles(canvas, size);
      case HeroCardMood.dusty:
        if (_back) _paintDustyBack(canvas, size);
        if (_front) _paintDustyFront(canvas, size);
      case HeroCardMood.alive:
        if (_back) _paintAlive(canvas, size);
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
            AppColors.iceSoft.withValues(alpha: 0.22 + breathe * 0.04),
            AppColors.ice.withValues(alpha: 0.18),
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
            Colors.white.withValues(alpha: 0.12 + breathe * 0.03),
            AppColors.iceSoft.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.22)),
    );

    // Rachaduras de gelo (padrão cristalino)
    _drawIceCracks(canvas, size, breathe);

    // Borda interna de geada
    final rim = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(1.5),
      const Radius.circular(AppMetrics.heroRadius - 2),
    );
    canvas.drawRRect(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = Colors.white.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  void _drawIceCracks(Canvas canvas, Size size, double breathe) {
    final crack = Paint()
      ..color = Colors.white.withValues(alpha: 0.08 + breathe * 0.03)
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
    final radius =
        size.shortestSide * (0.48 + breathe * 0.04) * strength * 1.35;
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.16 * strength),
            AppColors.iceSoft.withValues(alpha: 0.14 * strength),
            AppColors.ice.withValues(alpha: 0.1 * strength),
            Colors.transparent,
          ],
          stops: const [0.0, 0.28, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius)),
    );

    // Veios de gelo densos
    final vein = Paint()
      ..color = Colors.white.withValues(alpha: 0.1 + breathe * 0.04)
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

  /// Por cima: cristais no ar + pingentes na borda de cima.
  void _paintIcicles(Canvas canvas, Size size) {
    // Cristais flutuando
    for (final s in specs) {
      final cycle = (t * s.speed + s.phase) % 1.0;
      final y = (s.y + cycle * 0.55) % 1.2 - 0.1;
      final x = (s.x + math.sin((t + s.phase) * math.pi * 2) * s.drift) % 1.0;
      final alpha = (0.3 + 0.55 * (1 - (cycle - 0.5).abs() * 2)).clamp(
        0.0,
        0.9,
      );
      final c = Color.lerp(
        AppColors.iceSoft,
        AppColors.ice,
        s.kind.isEven ? 0.35 : 0.15,
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

    const seeds = <(double, double)>[
      (0.06, 0.5),
      (0.14, 0.9),
      (0.2, 0.35),
      (0.31, 0.7),
      (0.43, 0.45),
      (0.52, 1.0),
      (0.61, 0.4),
      (0.7, 0.8),
      (0.79, 0.3),
      (0.87, 0.95),
      (0.95, 0.55),
    ];
    final maxLen = (size.height * 0.05).clamp(10.0, 22.0);
    final body = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.55),
          AppColors.iceSoft.withValues(alpha: 0.32),
          AppColors.ice.withValues(alpha: 0.08),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, maxLen));
    final shine = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Crosta de geada que segura os pingentes
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 3),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );

    for (var i = 0; i < seeds.length; i++) {
      final (fx, fl) = seeds[i];
      final x = fx * size.width;
      final len = maxLen * (0.4 + fl * 0.6);
      final w = 3.0 + fl * 3.2;
      final path = Path()
        ..moveTo(x - w, 0)
        ..quadraticBezierTo(x - w * 0.3, len * 0.55, x, len)
        ..quadraticBezierTo(x + w * 0.3, len * 0.55, x + w, 0)
        ..close();
      canvas.drawPath(path, body);
      canvas.drawLine(
        Offset(x - w * 0.35, 1.5),
        Offset(x - w * 0.08, len * 0.7),
        shine,
      );
    }

    // Gota: nasce na ponta do pingente mais longo, incha e cai
    for (final (idx, phase) in const [(5, 0.0), (9, 0.5)]) {
      final (fx, fl) = seeds[idx];
      final x = fx * size.width;
      final tip = maxLen * (0.4 + fl * 0.6);
      final c = (t + phase) % 1.0;
      final drop = Paint()..color = AppColors.iceSoft.withValues(alpha: 0.75);
      if (c < 0.6) {
        final swell = c / 0.6;
        canvas.drawCircle(
          Offset(x, tip + 1.2 * swell),
          1.0 + 1.1 * swell,
          drop,
        );
      } else {
        final fall = (c - 0.6) / 0.4;
        final y = tip + 2 + fall * fall * size.height * 0.5;
        final alpha = (1 - fall).clamp(0.0, 1.0) * 0.7;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 2.6, height: 4.2),
          Paint()..color = AppColors.iceSoft.withValues(alpha: alpha),
        );
      }
    }
  }

  // ─── POEIRA / TEIA ────────────────────────────────────────────────────

  /// Sob o texto: véu, manchas, marcas e vinheta — pesam sem apagar a leitura.
  void _paintDustyBack(Canvas canvas, Size size) {
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
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                const Color(0xFF8A6840).withValues(alpha: 0.16),
                const Color(0xFF3A2410).withValues(alpha: 0.36),
              ],
            ).createShader(
              Rect.fromLTWH(
                0,
                size.height * 0.7,
                size.width,
                size.height * 0.3,
              ),
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
  }

  /// Sobre o texto: teia, aranha, pó flutuando e grão de filme.
  void _paintDustyFront(Canvas canvas, Size size) {
    final flicker = 0.9 + 0.1 * math.sin(t * math.pi * 9);
    final breathe = 0.5 + 0.5 * math.sin(t * math.pi * 2);

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
      final x =
          (s.x + math.sin((t * 0.5 + s.phase) * math.pi * 2) * s.drift * 1.7) %
          1.0;
      final alpha = (0.04 + 0.1 * math.sin(cycle * math.pi)).clamp(0.0, 0.14);
      final dust = Color.lerp(
        const Color(0xFFA88858),
        const Color(0xFFE0C898),
        s.kind / 3,
      )!;
      final pos = Offset(x * size.width, y * size.height);
      final r = s.size * (1.0 + 0.45 * breatheNoise(s.phase));
      _dot.color = dust.withValues(alpha: alpha * flicker);
      canvas.drawCircle(pos, r, _dot);
      if (s.kind == 0 || s.kind == 2) {
        _dot.color = dust.withValues(alpha: alpha * 0.4 * flicker);
        canvas.drawCircle(pos.translate(r * 0.65, -r * 0.3), r * 0.48, _dot);
      }
    }

    grain.paint(canvas, size, (t * 36).floor() + 17);
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
          ..color = const Color(
            0xFF3A2814,
          ).withValues(alpha: 0.2 + breathe * 0.05 + (i % 2) * 0.04)
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
      ..color = const Color(0xFFE8E0D0).withValues(alpha: alpha * 0.12)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

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
          ..color = const Color(0xFFE8E0D0).withValues(alpha: alpha * 0.1)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true,
      );
      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        Paint()
          ..color = const Color(
            0xFFE4DCC8,
          ).withValues(alpha: alpha * (ring.isOdd ? 0.7 : 0.9))
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
    final spider = Offset(anchor.dx + sway, anchor.dy + size.height * drop);

    final thread = Paint()
      ..color = const Color(0xFFE4DCC8).withValues(alpha: 0.32)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    canvas.drawLine(anchor, spider, thread);

    final body = Paint()
      ..color = const Color(0xFF1A140E).withValues(alpha: 0.85);
    final bodySoft = Paint()
      ..color = const Color(0xFF3A2E20).withValues(alpha: 0.8);
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

  // ─── EM DIA ────────────────────────────────────────────────────────────

  void _paintAlive(Canvas canvas, Size size) {
    for (final s in specs) {
      final cycle = (t * s.speed + s.phase) % 1.0;
      final y = 1.1 - cycle * 1.25;
      final x = (s.x + math.sin((t + s.phase) * math.pi * 2) * s.drift) % 1.0;
      final alpha = (math.sin(cycle * math.pi) * 0.28).clamp(0.0, 0.32);
      final c = switch (s.kind) {
        0 => AppColors.accent,
        1 => AppColors.accentSoft,
        2 => AppColors.primaryLight,
        _ => AppColors.accentSoft,
      };
      _dot.color = c.withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        s.size * 0.35,
        _dot,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter old) =>
      old.mood != mood ||
      old.layer != layer ||
      old.clock != clock ||
      old.specs != specs;
}

/// Gesto de entrada — o toque sopra o pó, trinca o gelo ou abre ondas de luz.
///
/// [progress] vai de 0 a 1; [origin] é o ponto do toque no palco.
class HeroTapBurstPainter extends CustomPainter {
  final HeroCardMood mood;
  final double progress;
  final Offset origin;

  HeroTapBurstPainter({
    required this.mood,
    required this.progress,
    required this.origin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final ease = Curves.easeOutCubic.transform(progress);
    final fade = (1 - progress).clamp(0.0, 1.0);
    final reach = size.longestSide * 0.75;
    final rng = math.Random(mood.index * 31 + 5);

    switch (mood) {
      case HeroCardMood.dusty:
        // Clareira: o pó abre em volta do dedo
        final clearR = reach * ease;
        canvas.drawCircle(
          origin,
          clearR,
          Paint()
            ..shader = RadialGradient(
              colors: [
                const Color(0xFFFFE0A0).withValues(alpha: 0.2 * fade),
                const Color(0xFFD4AE62).withValues(alpha: 0.08 * fade),
                Colors.transparent,
              ],
              stops: const [0.0, 0.6, 1.0],
            ).createShader(Rect.fromCircle(center: origin, radius: clearR)),
        );
        for (var i = 0; i < 42; i++) {
          final angle = rng.nextDouble() * math.pi * 2;
          final dist = reach * (0.25 + rng.nextDouble() * 0.75) * ease;
          final lift = -size.height * 0.08 * ease * rng.nextDouble();
          final pos = origin.translate(
            math.cos(angle) * dist,
            math.sin(angle) * dist + lift,
          );
          final r = (1.2 + rng.nextDouble() * 3.4) * (1 + progress * 0.8);
          canvas.drawCircle(
            pos,
            r,
            Paint()
              ..color = Color.lerp(
                const Color(0xFFA88858),
                const Color(0xFFE8D4B0),
                rng.nextDouble(),
              )!.withValues(alpha: 0.55 * fade),
          );
        }
      case HeroCardMood.frozen:
        // Clarão + estilhaços de gelo
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..color = Colors.white.withValues(
              alpha: 0.22 * (1 - Curves.easeOut.transform(progress)),
            ),
        );
        canvas.drawCircle(
          origin,
          reach * 0.6 * ease,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4 * fade + 0.4
            ..color = AppColors.iceSoft.withValues(alpha: 0.7 * fade),
        );
        for (var i = 0; i < 18; i++) {
          final angle = (i / 18) * math.pi * 2 + rng.nextDouble() * 0.3;
          final dist = reach * (0.3 + rng.nextDouble() * 0.6) * ease;
          final fall = size.height * 0.12 * progress * progress;
          final pos = origin.translate(
            math.cos(angle) * dist,
            math.sin(angle) * dist + fall,
          );
          final s = 3.0 + rng.nextDouble() * 5.0;
          canvas.save();
          canvas.translate(pos.dx, pos.dy);
          canvas.rotate(angle + progress * math.pi * (rng.nextBool() ? 2 : -2));
          final shard = Path()
            ..moveTo(0, -s)
            ..lineTo(s * 0.45, s * 0.6)
            ..lineTo(-s * 0.4, s * 0.3)
            ..close();
          canvas.drawPath(
            shard,
            Paint()
              ..color = Color.lerp(
                Colors.white,
                AppColors.iceSoft,
                rng.nextDouble(),
              )!.withValues(alpha: 0.85 * fade),
          );
          canvas.restore();
        }
      case HeroCardMood.alive:
        // Ondas de ouro + faíscas subindo
        for (var ring = 0; ring < 3; ring++) {
          final local = ((progress - ring * 0.12) / 0.76).clamp(0.0, 1.0);
          if (local <= 0) continue;
          final r = reach * Curves.easeOutCubic.transform(local);
          canvas.drawCircle(
            origin,
            r,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.2 * (1 - local) + 0.4
              ..color = AppColors.accent.withValues(alpha: 0.6 * (1 - local)),
          );
        }
        for (var i = 0; i < 20; i++) {
          final angle = -math.pi / 2 + (rng.nextDouble() - 0.5) * math.pi * 1.4;
          final dist = reach * (0.2 + rng.nextDouble() * 0.5) * ease;
          final pos = origin.translate(
            math.cos(angle) * dist,
            math.sin(angle) * dist,
          );
          canvas.drawCircle(
            pos,
            1.2 + rng.nextDouble() * 2.0,
            Paint()
              ..color = (i.isEven ? AppColors.accent : AppColors.accentSoft)
                  .withValues(alpha: 0.9 * fade),
          );
        }
    }
  }

  @override
  bool shouldRepaint(covariant HeroTapBurstPainter old) =>
      old.progress != progress || old.origin != origin || old.mood != mood;
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
      // Clareza leve — sem empurrão de vidro
      HeroCardMood.alive => _matteMatrix,
    };
    return ColorFiltered(colorFilter: ColorFilter.matrix(matrix), child: child);
  }

  /// Leve empurrão pro ciano / frio no backdrop.
  static const _freezeMatrix = <double>[
    0.78,
    0.05,
    0.2,
    0,
    12,
    0.05,
    0.88,
    0.22,
    0,
    16,
    0.05,
    0.15,
    1.22,
    0,
    28,
    0,
    0,
    0,
    1,
    0,
  ];

  /// Sépia escura — abandono / terra.
  static const _dustMatrix = <double>[
    0.4,
    0.36,
    0.08,
    0,
    10,
    0.26,
    0.3,
    0.06,
    0,
    4,
    0.08,
    0.12,
    0.12,
    0,
    -4,
    0,
    0,
    0,
    1,
    0,
  ];

  /// Contraste leve, sem saturação extra.
  static const _matteMatrix = <double>[
    1.02,
    0,
    0,
    0,
    0,
    0,
    1.02,
    0,
    0,
    0,
    0,
    0,
    1.03,
    0,
    2,
    0,
    0,
    0,
    1,
    0,
  ];
}

/// Contorno compartilhado dos cards da Home.
///
/// Empoeirada = vermelho do card de perfil.
/// Congelada = gelo/azul.
/// Em dia = ouro da marca.
Color homeTrailOutline(HeroCardMood mood) => switch (mood) {
  HeroCardMood.dusty => AppColors.error.withValues(alpha: 0.55),
  HeroCardMood.frozen => AppColors.iceSoft.withValues(alpha: 0.85),
  HeroCardMood.alive => AppColors.accent.withValues(alpha: 0.7),
};

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

  static HeroCardMoodStyle of(HeroCardMood mood, {required Color trailAccent}) {
    final outline = homeTrailOutline(mood);
    return switch (mood) {
      HeroCardMood.frozen => HeroCardMoodStyle(
        border: outline,
        borderWidth: AppMetrics.cardBorderWidth,
        glow: AppColors.ice.withValues(alpha: 0.12),
        label: AppColors.iceSoft,
        footer: AppColors.iceSoft.withValues(alpha: 0.95),
        stepLabel: 'Protegido pelo gelo',
      ),
      HeroCardMood.dusty => HeroCardMoodStyle(
        border: outline,
        borderWidth: AppMetrics.cardBorderWidth,
        glow: const Color(0xFF1A1008).withValues(alpha: 0.5),
        label: const Color(0xFFB89868),
        footer: const Color(0xFF9A7850),
        stepLabel: 'Ficando para trás',
      ),
      HeroCardMood.alive => HeroCardMoodStyle(
        border: outline,
        borderWidth: AppMetrics.cardBorderWidth,
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
/// Dia já caminhado → vivo (o gelo fica no orbe da semana, não no CTA).
/// Em risco hoje, ou buraco sem cobertura → empoeirado.
/// Congelado só se o gelo cobriu ontem e hoje ainda não foi caminhado.
/// Gelo usado mais cedo na semana NÃO congela um buraco novo.
HeroCardMood resolveHeroCardMood({
  required bool atRisk,
  required bool yesterdayFrozen,
  required bool walkedToday,
  bool returningAfterGap = false,
}) {
  if (walkedToday) return HeroCardMood.alive;
  if (yesterdayFrozen) return HeroCardMood.frozen;
  if (atRisk || returningAfterGap) return HeroCardMood.dusty;
  return HeroCardMood.alive;
}
