import 'package:flutter/material.dart';

import '../utils/appearance.dart';
import 'brand_trail.dart';
import 'film_layers.dart';

/// A mesma trilha STWAY do ícone, da splash e do onboarding, no céu
/// escolhido — parada e apagada. Lobby (Hoje / Juntos) e card herói
/// (ex.: perfil) podem levar a arte velada; cenário de tela cheia sem
/// véu fica em splash, onboarding e celebração.
///
/// Estático de propósito (pinta uma vez).
class HomeBrandBackdrop extends StatefulWidget {
  final AppearanceStyle style;

  const HomeBrandBackdrop({super.key, required this.style});

  @override
  State<HomeBrandBackdrop> createState() => _HomeBrandBackdropState();
}

class _HomeBrandBackdropState extends State<HomeBrandBackdrop> {
  @override
  void initState() {
    super.initState();
    if (BrandTrail.image == null) {
      BrandTrail.ensureLoaded().then((_) {
        if (mounted) setState(() {});
      }, onError: (_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final shot = TrailShot.rest
        .copyWith(exposure: 0.8, glow: 0.7, lit: 0.6, lamps: 0.6, stars: 0.7)
        .withSky(widget.style);
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _BackdropPainter(
            shot: shot,
            look: widget.style.look,
            loaded: BrandTrail.image != null,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  final TrailShot shot;
  final AppearanceLook look;
  final bool loaded;

  _BackdropPainter({
    required this.shot,
    required this.look,
    required this.loaded,
  });

  @override
  void paint(Canvas canvas, Size size) {
    BrandTrail.paint(canvas, size, shot, loop: 0, calm: true);
    // Véu: a arte fica como cenário, os cards na frente leem bem.
    final full = Offset.zero & size;
    canvas.drawRect(
      full,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.25),
            Colors.black.withValues(alpha: 0.42),
            Colors.black.withValues(alpha: 0.62),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(full),
    );
    FilmLayers.vignette(canvas, size, strength: 0.45);
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter old) =>
      old.look != look || old.loaded != loaded;
}
