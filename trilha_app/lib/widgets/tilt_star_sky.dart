import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../services/tilt_parallax.dart';
import 'brand_trail.dart';
import 'film_layers.dart';

/// Céu estrelado por cima da arte STWAY em tela cheia (splash).
///
/// Mesmo céu do onboarding: corre devagar, cintila e acompanha a
/// inclinação do celular. A arte embaixo fica parada.
///
/// Pinta só o CustomPaint (repaint listenable) — sem setState a cada
/// frame, que reconstruía a splash inteira durante o boot.
class TiltStarSky extends StatefulWidget {
  final double alpha;

  const TiltStarSky({super.key, this.alpha = 0.75});

  @override
  State<TiltStarSky> createState() => _TiltStarSkyState();
}

class _TiltStarSkyState extends State<TiltStarSky>
    with SingleTickerProviderStateMixin {
  final _tilt = TiltParallax();
  late final Ticker _ticker;
  final _tick = ValueNotifier<int>(0);
  int _elapsedMs = 0;

  /// ~20 fps: estrelas não precisam do refresh nativo.
  static const _minMs = 50;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((e) {
      final ms = e.inMilliseconds;
      if (ms - _elapsedMs < _minMs) return;
      _elapsedMs = ms;
      _tick.value = ms;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final calm = MediaQuery.of(context).disableAnimations;
    if (calm) {
      _ticker.stop();
      _tilt.stop();
    } else if (!_ticker.isActive) {
      _ticker.start();
      _tilt.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _tilt.dispose();
    _tick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calm = MediaQuery.of(context).disableAnimations;
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _SkyPainter(
            alpha: widget.alpha,
            tilt: _tilt,
            calm: calm,
            tick: _tick,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  final double alpha;
  final TiltParallax tilt;
  final bool calm;
  final ValueNotifier<int> tick;

  _SkyPainter({
    required this.alpha,
    required this.tilt,
    required this.calm,
    required this.tick,
  }) : super(repaint: tick);

  @override
  void paint(Canvas canvas, Size size) {
    final fade = calm ? 1.0 : (tick.value / 700).clamp(0.0, 1.0);
    // Mesmo enquadramento do BoxFit.cover centralizado da splash.
    final frame = BrandTrail.frame(size, const TrailShot());
    final horizon = BrandTrail.at(frame, BrandTrail.horizon).dy;
    final clock = calm ? 0.0 : FilmLayers.clock;
    FilmLayers.stars(
      canvas,
      size,
      alpha: alpha * fade,
      loop:
          (clock * 1000 % FilmLayers.loopMs) / FilmLayers.loopMs * math.pi * 2,
      floor: (horizon / size.height * 0.9).clamp(0.2, 0.8),
      pan: clock,
      tilt: calm ? Offset.zero : tilt.value,
    );
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) =>
      old.alpha != alpha || old.calm != calm || old.tilt != tilt;
}
