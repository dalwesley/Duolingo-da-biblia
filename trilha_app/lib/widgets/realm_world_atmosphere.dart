import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/trail_catalog.dart';
import '../theme/app_theme.dart';

/// Mundo pintado de cada reino — céu, horizonte, astro e poeira viva.
class RealmWorldAtmosphere extends StatefulWidget {
  final TrailRealm realm;
  final bool animate;
  final bool locked;
  final bool featured;

  const RealmWorldAtmosphere({
    super.key,
    required this.realm,
    this.animate = true,
    this.locked = false,
    this.featured = false,
  });

  @override
  State<RealmWorldAtmosphere> createState() => _RealmWorldAtmosphereState();
}

class _RealmWorldAtmosphereState extends State<RealmWorldAtmosphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift;
  late List<_Mote> _motes;

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 14000),
    );
    if (widget.animate) _drift.repeat();
    _motes = _buildMotes();
  }

  @override
  void didUpdateWidget(covariant RealmWorldAtmosphere oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.realm != widget.realm ||
        oldWidget.locked != widget.locked) {
      _motes = _buildMotes();
    }
    if (widget.animate && !_drift.isAnimating) {
      _drift.repeat();
    } else if (!widget.animate && _drift.isAnimating) {
      _drift.stop();
    }
  }

  List<_Mote> _buildMotes() {
    final seed = widget.realm.index * 131 + (widget.locked ? 7 : 3);
    final rng = math.Random(seed);
    final count = widget.locked
        ? 10
        : widget.featured
            ? 42
            : 28;
    return List.generate(count, (i) {
      return _Mote(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: 1.1 + rng.nextDouble() * 2.6,
        speed: 0.18 + rng.nextDouble() * 0.55,
        phase: rng.nextDouble(),
        drift: (rng.nextDouble() - 0.5) * 0.18,
      );
    });
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _drift,
        builder: (context, _) {
          return CustomPaint(
            painter: _RealmWorldPainter(
              realm: widget.realm,
              locked: widget.locked,
              featured: widget.featured,
              t: widget.animate ? _drift.value : 0.12,
              motes: _motes,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Mote {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;
  final double drift;

  const _Mote({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.drift,
  });
}

class _RealmWorldPainter extends CustomPainter {
  final TrailRealm realm;
  final bool locked;
  final bool featured;
  final double t;
  final List<_Mote> motes;

  _RealmWorldPainter({
    required this.realm,
    required this.locked,
    required this.featured,
    required this.t,
    required this.motes,
  });

  _Sky _sky() {
    return switch (realm) {
      TrailRealm.antigoTestamento => const _Sky(
          zenith: Color(0xFF0A1220),
          mid: Color(0xFF1A2A3C),
          fire: Color(0xFFC47A28),
          earth: Color(0xFF0E0A08),
          star: Color(0xFFFFE08A),
          sun: Color(0xFFF7BB01),
        ),
      TrailRealm.novoTestamento => const _Sky(
          zenith: Color(0xFF140818),
          mid: Color(0xFF3A1A28),
          fire: Color(0xFFFF8A6A),
          earth: Color(0xFF12080C),
          star: Color(0xFFFFC4B0),
          sun: Color(0xFFFF9468),
        ),
      TrailRealm.vidaCrista => const _Sky(
          zenith: Color(0xFF061418),
          mid: Color(0xFF0E2E34),
          fire: Color(0xFF2EE6C5),
          earth: Color(0xFF07120E),
          star: Color(0xFFB8EAF8),
          sun: Color(0xFF3DCFBE),
        ),
      TrailRealm.teologia => const _Sky(
          zenith: Color(0xFF0A1018),
          mid: Color(0xFF1A2838),
          fire: Color(0xFF7EB0D8),
          earth: Color(0xFF080C12),
          star: Color(0xFFC8D4E0),
          sun: Color(0xFF7EB0D8),
        ),
    };
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sky = _sky();
    final rect = Offset.zero & size;
    final sat = locked ? 0.45 : 1.0;
    Color c(Color x) => Color.lerp(const Color(0xFF1A1E24), x, sat)!;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            c(sky.zenith),
            c(sky.mid),
            Color.lerp(c(sky.fire), c(sky.earth), 0.35)!,
            c(sky.earth),
          ],
          stops: const [0.0, 0.38, 0.68, 1.0],
        ).createShader(rect),
    );

    _paintAstro(canvas, size, sky, c);
    _paintTerrain(canvas, size, sky, c);
    if (realm == TrailRealm.teologia) {
      _paintPillars(canvas, size, sky, c);
    }
    _paintMotes(canvas, size, sky, c);
    _paintVignette(canvas, size);
    if (locked) {
      canvas.drawRect(
        rect,
        Paint()..color = Colors.black.withValues(alpha: 0.28),
      );
    }
  }

  void _paintAstro(Canvas canvas, Size size, _Sky sky, Color Function(Color) c) {
    final featuredBoost = featured ? 1.12 : 1.0;
    final breath = 0.92 + math.sin(t * math.pi * 2) * 0.08;
    final cx = switch (realm) {
      TrailRealm.antigoTestamento => size.width * 0.82,
      TrailRealm.novoTestamento => size.width * 0.18,
      TrailRealm.vidaCrista => size.width * 0.5,
      TrailRealm.teologia => size.width * 0.78,
    };
    final cy = switch (realm) {
      TrailRealm.antigoTestamento => size.height * 0.28,
      TrailRealm.novoTestamento => size.height * 0.32,
      TrailRealm.vidaCrista => size.height * 0.22,
      TrailRealm.teologia => size.height * 0.24,
    };
    final r = size.shortestSide * (featured ? 0.22 : 0.16) * breath * featuredBoost;

    final halo = Paint()
      ..shader = ui.Gradient.radial(
        Offset(cx, cy),
        r * 2.4,
        [
          c(sky.sun).withValues(alpha: locked ? 0.12 : 0.38),
          c(sky.fire).withValues(alpha: 0.12),
          Colors.transparent,
        ],
        const [0.0, 0.45, 1.0],
      );
    canvas.drawCircle(Offset(cx, cy), r * 2.4, halo);

    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.42,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx - r * 0.12, cy - r * 0.12),
          r * 0.5,
          [
            Color.lerp(Colors.white, c(sky.sun), 0.35)!,
            c(sky.sun),
            c(sky.fire),
          ],
        ),
    );
  }

  void _paintTerrain(
    Canvas canvas,
    Size size,
    _Sky sky,
    Color Function(Color) c,
  ) {
    final h = size.height;
    final w = size.width;
    final far = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.62);
    _ridge(far, w, h, 0.62, 0.08, t * 0.4, 2.1);
    far.lineTo(w, h);
    far.close();
    canvas.drawPath(
      far,
      Paint()..color = c(sky.mid).withValues(alpha: 0.55),
    );

    final near = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.72);
    _ridge(near, w, h, 0.72, 0.11, t * 0.7 + 1.3, 1.4);
    near.lineTo(w, h);
    near.close();
    canvas.drawPath(
      near,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            c(sky.earth).withValues(alpha: 0.55),
            c(sky.earth),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.55, w, h * 0.45)),
    );
  }

  void _ridge(
    Path path,
    double w,
    double h,
    double base,
    double amp,
    double phase,
    double freq,
  ) {
    const steps = 8;
    for (var i = 1; i <= steps; i++) {
      final x = w * (i / steps);
      final wave = math.sin((i / steps) * math.pi * freq + phase) * amp;
      path.lineTo(x, h * (base + wave));
    }
  }

  void _paintPillars(
    Canvas canvas,
    Size size,
    _Sky sky,
    Color Function(Color) c,
  ) {
    final paint = Paint()..color = c(sky.star).withValues(alpha: 0.08);
    final h = size.height;
    final w = size.width;
    for (final x in [w * 0.22, w * 0.38, w * 0.62]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, h * 0.42, w * 0.055, h * 0.48),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  void _paintMotes(
    Canvas canvas,
    Size size,
    _Sky sky,
    Color Function(Color) c,
  ) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final m in motes) {
      final py = (m.y - t * m.speed * 0.35) % 1.0;
      final px = (m.x + math.sin((t + m.phase) * math.pi * 2) * m.drift) % 1.0;
      final twinkle =
          0.25 + 0.75 * (0.5 + 0.5 * math.sin((t + m.phase) * math.pi * 2));
      paint.color = c(sky.star).withValues(
        alpha: (locked ? 0.12 : 0.22 + twinkle * 0.35) * (featured ? 1.15 : 1),
      );
      canvas.drawCircle(
        Offset(px * size.width, py * size.height),
        m.size,
        paint,
      );
    }
  }

  void _paintVignette(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.18),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.22),
            Colors.black.withValues(alpha: 0.78),
          ],
          stops: const [0.0, 0.28, 0.52, 1.0],
        ).createShader(Offset.zero & size),
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.05,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.28),
          ],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _RealmWorldPainter old) =>
      old.t != t ||
      old.realm != realm ||
      old.locked != locked ||
      old.featured != featured;
}

class _Sky {
  final Color zenith;
  final Color mid;
  final Color fire;
  final Color earth;
  final Color star;
  final Color sun;

  const _Sky({
    required this.zenith,
    required this.mid,
    required this.fire,
    required this.earth,
    required this.star,
    required this.sun,
  });
}

/// Filete dourado de cartaz — linha → título → linha.
class FilmEyebrow extends StatelessWidget {
  final String text;
  final Color accent;

  const FilmEyebrow({super.key, required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, accent.withValues(alpha: 0.7)],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: AppTypography.label(
              size: 11,
              letterSpacing: 2.2,
              color: accent,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent.withValues(alpha: 0.7), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
