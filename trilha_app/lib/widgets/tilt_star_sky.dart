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
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((e) => setState(() => _elapsed = e));
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calm = MediaQuery.of(context).disableAnimations;
    final fade = calm ? 1.0 : (_elapsed.inMilliseconds / 700).clamp(0.0, 1.0);
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _SkyPainter(
            alpha: widget.alpha * fade,
            tilt: calm ? Offset.zero : _tilt.value,
            calm: calm,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  final double alpha;
  final Offset tilt;
  final bool calm;

  _SkyPainter({required this.alpha, required this.tilt, required this.calm});

  @override
  void paint(Canvas canvas, Size size) {
    // Mesmo enquadramento do BoxFit.cover centralizado da splash.
    final frame = BrandTrail.frame(size, const TrailShot());
    final horizon = BrandTrail.at(frame, BrandTrail.horizon).dy;
    final clock = calm ? 0.0 : FilmLayers.clock;
    FilmLayers.stars(
      canvas,
      size,
      alpha: alpha,
      loop:
          (clock * 1000 % FilmLayers.loopMs) / FilmLayers.loopMs * math.pi * 2,
      floor: (horizon / size.height * 0.9).clamp(0.2, 0.8),
      pan: clock,
      tilt: tilt,
    );
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) => true;
}
