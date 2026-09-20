import 'package:flutter/material.dart';

import 'cinematic_icon.dart';

/// Glifo gravado — sulco, aresta e preenchimento. Não flutua como ícone.
class EmbossedGlyph extends StatelessWidget {
  final CinematicGlyph glyph;
  final double size;
  final Color fill;
  final Color groove;
  final Color ridge;
  final double depth;
  final double opacity;

  const EmbossedGlyph({
    super.key,
    required this.glyph,
    required this.size,
    required this.fill,
    required this.groove,
    required this.ridge,
    this.depth = 1.1,
    this.opacity = 1,
  });

  @override
  Widget build(BuildContext context) {
    final d = depth.clamp(0.4, 2.2);
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: Offset(d, d * 1.1),
              child: CinematicIcon(
                glyph: glyph,
                size: size,
                accent: groove,
                framed: false,
                glowing: false,
              ),
            ),
            Transform.translate(
              offset: Offset(-d * 0.75, -d),
              child: CinematicIcon(
                glyph: glyph,
                size: size,
                accent: ridge,
                framed: false,
                glowing: false,
              ),
            ),
            CinematicIcon(
              glyph: glyph,
              size: size,
              accent: fill,
              framed: false,
              glowing: false,
            ),
          ],
        ),
      ),
    );
  }
}
