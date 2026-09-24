import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'brand_trail.dart';
import 'film_layers.dart';

/// Abertura cinematográfica do onboarding — "Haja luz" sobre a arte STWAY.
///
/// Tudo começa em trevas, só com o versículo. Em "e houve luz" um clarão
/// toma a tela inteira; quando ele se abre, a trilha STWAY já está lá,
/// parada, com o sol brilhando no horizonte e o céu estrelado correndo.
///
/// Linha do tempo em [progress] (0 → 1):
/// - 0.00–[flashAt] trevas (o versículo entra por cima, no onboarding)
/// - [flashAt]      clarão branco em tela cheia
/// - [flashAt]–0.78 o clarão se desfaz revelando arte, sol e estrelas
/// - 0.62–0.92      o caminho acende; lâmpadas surgem no fim
///
/// [time] é um loop 0 → 1 contínuo (brilho, raios, grão).
class GenesisHero extends StatelessWidget {
  final double progress;
  final double time;

  /// Inclinação do celular (-1 a 1) para o parallax do céu.
  final Offset tilt;

  /// Momento de "e houve luz" — clarão e vibração.
  static const flashAt = 0.54;

  /// Enquadramento final da abertura (o mesmo, fixo, dos outros atos).
  static final endShot = TrailShot.rest.copyWith(
    exposure: 0.9,
    glow: 1,
    lit: 1,
    lamps: 1,
    stars: 0.8,
  );

  const GenesisHero({
    super.key,
    required this.progress,
    required this.time,
    this.tilt = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    final calm = MediaQuery.of(context).disableAnimations;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _GenesisPainter(
          t: calm ? 1 : progress,
          time: calm ? 0 : time,
          calm: calm,
          tilt: calm ? Offset.zero : tilt,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _GenesisPainter extends CustomPainter {
  final double t;
  final double time;
  final bool calm;
  final Offset tilt;

  _GenesisPainter({
    required this.t,
    required this.time,
    required this.calm,
    required this.tilt,
  });

  static const _blue = AppColors.primary;
  static const _ice = Color(0xFFCFE6FF);

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;
    final loop = time * math.pi * 2;
    const at = GenesisHero.flashAt;

    // Trevas: nada além do preto até a Palavra.
    if (t < at) {
      canvas.drawRect(full, Paint()..color = Colors.black);
      return;
    }

    final light = FilmLayers.seg(t, at, 0.72, Curves.easeOutCubic);
    final flash = calm
        ? 0.0
        : t < at + 0.025
        ? FilmLayers.seg(t, at, at + 0.025, Curves.easeOut)
        : 1 - FilmLayers.seg(t, at + 0.025, 0.78, Curves.easeInOutQuad);

    final end = GenesisHero.endShot;
    final shot = end.copyWith(
      // A arte já está inteira quando o clarão começa a abrir.
      exposure: end.exposure * FilmLayers.seg(t, at, at + 0.03),
      glow: light,
      lit: FilmLayers.seg(t, 0.62, 0.92, Curves.easeInOutCubic),
      lamps: FilmLayers.seg(t, 0.8, 0.96),
      stars: end.stars * FilmLayers.seg(t, 0.6, 0.8),
    );
    final frame = BrandTrail.paint(
      canvas,
      size,
      shot,
      loop: loop,
      calm: calm,
      tilt: tilt,
    );
    final source = BrandTrail.sunAt(frame, tilt);

    _paintLight(canvas, size, source, light, loop);

    // Base mais escura para o botão.
    final low = Rect.fromLTRB(0, size.height * 0.62, size.width, size.height);
    canvas.drawRect(
      low,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00040910), Color(0xB3040910)],
        ).createShader(low),
    );

    FilmLayers.vignette(canvas, size, strength: 0.5);
    if (!calm) FilmLayers.grain(canvas, size, time);

    // Clarão: a luz toma a tela inteira e se abre a partir do sol.
    if (flash > 0) {
      canvas.drawRect(
        full,
        Paint()..color = Colors.white.withValues(alpha: 0.9 * flash),
      );
      canvas.drawRect(
        full,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = RadialGradient(
            center: Alignment(
              (source.dx / size.width) * 2 - 1,
              (source.dy / size.height) * 2 - 1,
            ),
            radius: 1.2,
            colors: [
              Colors.white.withValues(alpha: flash),
              _ice.withValues(alpha: 0.5 * flash),
              _blue.withValues(alpha: 0.15 * flash),
            ],
            stops: const [0.0, 0.4, 1.0],
          ).createShader(full),
      );
    }
  }

  void _paintLight(
    Canvas canvas,
    Size size,
    Offset source,
    double light,
    double loop,
  ) {
    final w = size.width;
    final pulse = 0.94 + 0.06 * math.sin(loop * 2);

    // Raios.
    final reach = size.height * 0.9;
    final rays = Paint()
      ..blendMode = BlendMode.plus
      ..shader = ui.Gradient.radial(
        source,
        reach,
        [
          _ice.withValues(alpha: 0.09 * light),
          _blue.withValues(alpha: 0.03 * light),
          Colors.transparent,
        ],
        [0.0, 0.45, 1.0],
      );
    const count = 14;
    for (var i = 0; i < count; i++) {
      final base = math.pi + (i + 0.5) / count * math.pi;
      final sway = math.sin(loop + i * 1.3) * 0.03;
      final angle = base + sway;
      final width = 0.035 + 0.03 * ((i * 7) % 3) / 2;
      final path = Path()
        ..moveTo(source.dx, source.dy)
        ..lineTo(
          source.dx + math.cos(angle - width) * reach,
          source.dy + math.sin(angle - width) * reach,
        )
        ..lineTo(
          source.dx + math.cos(angle + width) * reach,
          source.dy + math.sin(angle + width) * reach,
        )
        ..close();
      canvas.drawPath(path, rays);
    }

    // Halo e núcleo.
    final halo = w * (0.25 + 0.75 * light) * pulse;
    canvas.drawCircle(
      source,
      halo,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = ui.Gradient.radial(
          source,
          halo,
          [
            _ice.withValues(alpha: 0.5 * light),
            _blue.withValues(alpha: 0.2 * light),
            Colors.transparent,
          ],
          [0.0, 0.3, 1.0],
        ),
    );
    final core = 14 + 18 * light;
    canvas.drawCircle(
      source,
      core,
      Paint()
        ..shader = ui.Gradient.radial(
          source,
          core,
          [
            Colors.white.withValues(alpha: 0.98 * light),
            _ice.withValues(alpha: 0.7 * light),
            Colors.transparent,
          ],
          [0.0, 0.45, 1.0],
        ),
    );

    // Flare anamórfico.
    final flareW = w * (0.4 + 1.1 * light);
    final flare = Rect.fromCenter(center: source, width: flareW, height: 2.4);
    canvas.drawRect(
      flare,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF9FD4FF).withValues(alpha: 0.35 * light),
            Colors.white.withValues(alpha: 0.85 * light),
            const Color(0xFF9FD4FF).withValues(alpha: 0.35 * light),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ).createShader(flare),
    );
  }

  @override
  bool shouldRepaint(covariant _GenesisPainter old) =>
      old.t != t || old.time != time || old.calm != calm || old.tilt != tilt;
}
