import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/pilgrim_medal_models.dart';
import '../models/pilgrim_medals.dart' show tierColor;
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';
import 'embossed_glyph.dart';

/// A medalha do app — uma só, em todo lugar: disco maciço de metal na cor
/// do nível, contorno escuro, aro de contas, face rebaixada com reflexo e,
/// no meio, a gravura (uma [ChestMark] do baú) ou o ícone da medalha em
/// relevo. Com [ribbons], duas fitas saem por baixo e a peça ocupa
/// [size] × [size] * 1.25; sem elas, um disco [size] × [size].
class MedalArt extends StatelessWidget {
  final Color metal;
  final double size;
  final ChestMark? mark;
  final CinematicGlyph? glyph;
  final bool ribbons;
  final Color ribbon;

  /// 0–1, em loop: o brilho que corre pela face.
  final double shine;

  /// Ainda não conquistada: metal apagado na noite, sem brilho.
  final bool locked;

  /// Transparência só do ícone (ex.: a faísca de "mistério" na trancada).
  final double glyphOpacity;

  const MedalArt({
    super.key,
    required this.metal,
    required this.size,
    this.mark,
    this.glyph,
    this.ribbons = false,
    this.ribbon = AppColors.primary,
    this.shine = 0,
    this.locked = false,
    this.glyphOpacity = 1,
  });

  /// Metal de cada nível: o token do nível, com o ferro mais escuro que a
  /// prata e o ouro no ouro da recompensa.
  static Color metalFor(PilgrimMedalTier tier) => switch (tier) {
    PilgrimMedalTier.iron => Color.lerp(
      AppColors.medalIron,
      Colors.black,
      0.2,
    )!,
    PilgrimMedalTier.gold => AppColors.accent,
    _ => tierColor(tier),
  };

  /// Metal apagado da medalha trancada.
  static final lockedMetal = Color.lerp(
    AppColors.medalIron,
    AppColors.night,
    0.55,
  )!;

  @override
  Widget build(BuildContext context) {
    final tone = locked ? lockedMetal : metal;
    final art = CustomPaint(
      size: Size(size, ribbons ? size * 1.25 : size),
      painter: _MedalPainter(
        metal: tone,
        mark: mark,
        shine: locked ? 0 : shine,
        ribbon: locked ? lockedMetal : ribbon,
        ribbons: ribbons,
        locked: locked,
      ),
    );
    final glyph = this.glyph;
    if (glyph == null || mark != null) return art;
    // Pequena, o ícone ocupa mais da face para continuar legível.
    final iconSize = size * (size < 60 ? 0.48 : 0.42);
    return Stack(
      children: [
        art,
        Positioned(
          left: (size - iconSize) / 2,
          top: (size - iconSize) / 2,
          child: EmbossedGlyph(
            glyph: glyph,
            size: iconSize,
            fill: locked
                ? AppColors.textOnDark.withValues(alpha: 0.35)
                : Color.lerp(tone, Colors.black, 0.68)!,
            groove: Color.lerp(
              tone,
              Colors.white,
              0.65,
            )!.withValues(alpha: locked ? 0 : 0.7),
            ridge: Color.lerp(
              tone,
              Colors.black,
              0.4,
            )!.withValues(alpha: locked ? 0 : 0.5),
            depth: (size / 70).clamp(0.5, 1.6),
            opacity: glyphOpacity,
          ),
        ),
      ],
    );
  }
}

/// Estrela de quatro pontas — faísca da medalha e do palco do baú.
void paintSparkle(
  Canvas canvas,
  Offset c,
  double r, [
  Color color = Colors.white,
]) {
  if (r <= 0) return;
  final p = Path()
    ..moveTo(c.dx, c.dy - r * 2)
    ..quadraticBezierTo(c.dx, c.dy, c.dx + r * 2, c.dy)
    ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r * 2)
    ..quadraticBezierTo(c.dx, c.dy, c.dx - r * 2, c.dy)
    ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r * 2)
    ..close();
  canvas.drawPath(p, Paint()..color = color);
}

/// Gravura no meio da medalha — uma por recompensa do baú, desenhada no
/// traço da medalha (os ícones do app foram feitos para placas, não para
/// metal).
enum ChestMark {
  wheat,
  steps,
  lamp,
  map,
  book,
  horn,
  star;

  static ChestMark forReward(String id) => switch (id) {
    'chest:grao' => wheat,
    'chest:passo' => steps,
    'chest:lampada' => lamp,
    'chest:mapa' => map,
    'chest:guardada' => book,
    'chest:voz' => horn,
    'chest:bencao' => star,
    _ => star,
  };
}

class _MedalPainter extends CustomPainter {
  final Color metal;
  final ChestMark? mark;
  final double shine;
  final Color ribbon;
  final bool ribbons;
  final bool locked;

  const _MedalPainter({
    required this.metal,
    required this.mark,
    required this.shine,
    required this.ribbon,
    required this.ribbons,
    required this.locked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final d = size.width;
    final c = Offset(d / 2, d / 2);
    final r = d * 0.46;
    final light = Color.lerp(metal, Colors.white, 0.6)!;
    final dark = Color.lerp(metal, Colors.black, 0.4)!;
    final ink = Color.lerp(metal, Colors.black, 0.78)!;
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, d * 0.028)
      ..strokeJoin = StrokeJoin.round
      ..color = ink;

    // Fitas atrás do disco, com o corte em V na ponta.
    for (final side in ribbons ? const [-1.0, 1.0] : const <double>[]) {
      final x = c.dx + side * d * 0.2;
      final top = c.dy + r * 0.35;
      final bottom = size.height * 0.98;
      final half = d * 0.12;
      final tilt = side * d * 0.08;
      final strip = Path()
        ..moveTo(x - half, top)
        ..lineTo(x + half, top)
        ..lineTo(x + half + tilt, bottom)
        ..lineTo(x + tilt, bottom - d * 0.09)
        ..lineTo(x - half + tilt, bottom)
        ..close();
      canvas.drawPath(
        strip,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.lerp(ribbon, Colors.black, 0.4)!, ribbon],
          ).createShader(Rect.fromLTRB(x - half, top, x + half, bottom)),
      );
      canvas.drawLine(
        Offset(x - half * 0.35, top),
        Offset(x - half * 0.35 + tilt, bottom - d * 0.05),
        Paint()
          ..strokeWidth = half * 0.3
          ..color = Colors.white.withValues(alpha: 0.22),
      );
      canvas.drawPath(strip, outline);
    }

    // Sombra do disco.
    canvas.drawCircle(
      c.translate(0, d * 0.03),
      r,
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // Aro.
    final rim = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [light, metal, dark],
        ).createShader(rim),
    );
    // Contas no aro — só onde a medalha é grande o bastante para vê-las.
    final beads = d >= 56 ? 24 : 0;
    for (var i = 0; i < beads; i++) {
      final a = i * math.pi * 2 / beads;
      final p = c + Offset(math.cos(a), math.sin(a)) * (r * 0.89);
      canvas.drawCircle(p, d * 0.016, Paint()..color = dark);
      canvas.drawCircle(
        p.translate(-d * 0.004, -d * 0.004),
        d * 0.009,
        Paint()..color = light,
      );
    }

    // Face rebaixada.
    final faceR = r * 0.76;
    final face = Rect.fromCircle(center: c, radius: faceR);
    canvas.drawCircle(
      c,
      faceR,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 1.1,
          colors: [light, metal, dark],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(face),
    );
    canvas.drawCircle(
      c,
      faceR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = d * 0.018
        ..color = dark,
    );

    // Gravura: um fio claro logo abaixo dá o relevo.
    final mark = this.mark;
    final box = faceR * 1.42;
    if (mark != null) {
      canvas.save();
      canvas.translate(c.dx - box / 2, c.dy - box / 2);
      canvas.scale(box);
      canvas.save();
      canvas.translate(0, 2 / box);
      _drawMark(
        canvas,
        mark,
        Color.lerp(metal, Colors.white, 0.7)!.withValues(alpha: 0.7),
        Colors.transparent,
      );
      canvas.restore();
      _drawMark(canvas, mark, ink, light);
      canvas.restore();
    }

    // Brilho que corre pela face.
    if (shine > 0 && shine < 1) {
      canvas.save();
      canvas.clipPath(Path()..addOval(face));
      final x = face.left - face.width * 0.6 + face.width * 2.2 * shine;
      canvas.drawPath(
        Path()
          ..moveTo(x, face.top)
          ..lineTo(x + d * 0.12, face.top)
          ..lineTo(x - d * 0.06, face.bottom)
          ..lineTo(x - d * 0.18, face.bottom)
          ..close(),
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      );
      canvas.restore();
    }

    // Reflexo fixo no alto à esquerda (apagado na trancada).
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.9),
      math.pi * 1.05,
      math.pi * 0.45,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = d * 0.03
        ..color = Colors.white.withValues(alpha: locked ? 0.12 : 0.55),
    );

    canvas.drawCircle(c, r, outline);
    if (!locked && d >= 56) {
      paintSparkle(canvas, c + Offset(r * 0.62, -r * 0.7), d * 0.035);
    }
  }

  @override
  bool shouldRepaint(_MedalPainter old) =>
      old.metal != metal ||
      old.mark != mark ||
      old.shine != shine ||
      old.ribbon != ribbon ||
      old.ribbons != ribbons ||
      old.locked != locked;
}

/// Desenha [mark] num quadrado unitário (0–1). [ink] é o sulco; [detail]
/// risca por cima (dobras do mapa, linhas do livro) na cor do metal.
void _drawMark(Canvas canvas, ChestMark mark, Color ink, Color detail) {
  final fill = Paint()..color = ink;
  Paint line(double width, [Color? color]) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = width
    ..color = color ?? ink;
  void oval(Offset c, double w, double h, double angle) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: w, height: h),
      fill,
    );
    canvas.restore();
  }

  switch (mark) {
    case ChestMark.wheat:
      // Espiga: haste curva, grãos em pares e as barbas no alto.
      canvas.drawPath(
        Path()
          ..moveTo(0.5, 0.98)
          ..quadraticBezierTo(0.54, 0.6, 0.5, 0.22),
        line(0.05),
      );
      for (final y in const [0.32, 0.47, 0.62, 0.77]) {
        oval(Offset(0.41, y), 0.13, 0.24, -0.6);
        oval(Offset(0.59, y), 0.13, 0.24, 0.6);
      }
      oval(const Offset(0.5, 0.17), 0.13, 0.24, 0);
      for (final (x, angle) in const [
        (0.44, -0.35),
        (0.5, 0.0),
        (0.56, 0.35),
      ]) {
        canvas.drawLine(
          Offset(x, 0.08),
          Offset(x + math.sin(angle) * 0.12, 0.08 - math.cos(angle) * 0.12),
          line(0.022),
        );
      }
    case ChestMark.steps:
      // Duas pegadas, uma à frente da outra.
      void foot(Offset at, double angle, bool left) {
        canvas.save();
        canvas.translate(at.dx, at.dy);
        canvas.rotate(angle);
        canvas.scale(left ? -1.3 : 1.3, 1.3);
        oval(const Offset(0, -0.04), 0.19, 0.27, 0.08);
        oval(const Offset(0.012, 0.17), 0.14, 0.16, 0);
        for (final (x, y, r) in const [
          (-0.06, -0.235, 0.042),
          (0.01, -0.26, 0.034),
          (0.062, -0.24, 0.029),
          (0.098, -0.2, 0.024),
        ]) {
          canvas.drawCircle(Offset(x, y), r, fill);
        }
        canvas.restore();
      }
      foot(const Offset(0.3, 0.64), -0.18, true);
      foot(const Offset(0.7, 0.36), 0.18, false);
    case ChestMark.lamp:
      // Lamparina de barro de perfil, chama no bico.
      canvas.drawPath(
        Path()
          ..moveTo(0.14, 0.6)
          ..quadraticBezierTo(0.42, 0.95, 0.74, 0.66)
          ..lineTo(0.94, 0.56)
          ..lineTo(0.92, 0.5)
          ..lineTo(0.72, 0.55)
          ..quadraticBezierTo(0.44, 0.46, 0.14, 0.6)
          ..close(),
        fill,
      );
      canvas.drawCircle(const Offset(0.12, 0.6), 0.08, line(0.05));
      canvas.drawRect(const Rect.fromLTRB(0.36, 0.78, 0.56, 0.86), fill);
      canvas.drawPath(
        Path()
          ..moveTo(0.92, 0.16)
          ..quadraticBezierTo(1.02, 0.34, 0.93, 0.45)
          ..quadraticBezierTo(0.83, 0.36, 0.92, 0.16)
          ..close(),
        fill,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(0.42, 0.6),
          width: 0.14,
          height: 0.05,
        ),
        Paint()..color = detail,
      );
    case ChestMark.map:
      // Mapa dobrado em três, com a rota e o destino.
      const top = [
        Offset(0.08, 0.22),
        Offset(0.36, 0.14),
        Offset(0.64, 0.22),
        Offset(0.92, 0.14),
      ];
      const bottom = [
        Offset(0.08, 0.86),
        Offset(0.36, 0.78),
        Offset(0.64, 0.86),
        Offset(0.92, 0.78),
      ];
      canvas.drawPath(
        Path()..addPolygon([...top, ...bottom.reversed], true),
        fill,
      );
      for (var i = 1; i < 3; i++) {
        canvas.drawLine(top[i], bottom[i], line(0.025, detail));
      }
      final route = Path()
        ..moveTo(0.16, 0.72)
        ..quadraticBezierTo(0.34, 0.4, 0.5, 0.58)
        ..quadraticBezierTo(0.62, 0.7, 0.74, 0.38);
      for (final m in route.computeMetrics()) {
        for (var t = 0.0; t < m.length; t += 0.09) {
          canvas.drawPath(m.extractPath(t, t + 0.045), line(0.03, detail));
        }
      }
      canvas.drawLine(
        const Offset(0.72, 0.28),
        const Offset(0.84, 0.4),
        line(0.035, detail),
      );
      canvas.drawLine(
        const Offset(0.84, 0.28),
        const Offset(0.72, 0.4),
        line(0.035, detail),
      );
    case ChestMark.book:
      // Livro aberto com um coração em cima: a palavra guardada.
      for (final side in const [-1.0, 1.0]) {
        final edge = 0.5 + side * 0.42;
        final spine = 0.5 + side * 0.015;
        canvas.drawPath(
          Path()
            ..moveTo(spine, 0.4)
            ..quadraticBezierTo(0.5 + side * 0.22, 0.3, edge, 0.36)
            ..lineTo(edge, 0.86)
            ..quadraticBezierTo(0.5 + side * 0.22, 0.8, spine, 0.9)
            ..close(),
          fill,
        );
        for (final y in const [0.52, 0.62, 0.72]) {
          canvas.drawLine(
            Offset(0.5 + side * 0.1, y),
            Offset(0.5 + side * 0.32, y - 0.02),
            line(0.022, detail),
          );
        }
      }
      canvas.drawPath(
        Path()
          ..moveTo(0.5, 0.3)
          ..cubicTo(0.3, 0.18, 0.38, 0.0, 0.5, 0.1)
          ..cubicTo(0.62, 0.0, 0.7, 0.18, 0.5, 0.3)
          ..close(),
        fill,
      );
    case ChestMark.horn:
      // Shofar: o chifre que chama a caravana, com o som saindo.
      canvas.drawPath(
        Path()
          ..moveTo(0.06, 0.74)
          ..cubicTo(0.3, 0.8, 0.52, 0.64, 0.64, 0.24)
          ..lineTo(0.9, 0.36)
          ..cubicTo(0.72, 0.66, 0.42, 0.92, 0.08, 0.84)
          ..close(),
        fill,
      );
      for (final t in const [0.3, 0.5]) {
        canvas.drawLine(
          Offset(0.18 + t * 0.6, 0.8 - t * 0.5),
          Offset(0.24 + t * 0.62, 0.9 - t * 0.48),
          line(0.022, detail),
        );
      }
      for (final r in const [0.14, 0.24]) {
        canvas.drawArc(
          Rect.fromCircle(center: const Offset(0.77, 0.3), radius: r),
          -math.pi * 0.62,
          math.pi * 0.5,
          false,
          line(0.04),
        );
      }
    case ChestMark.star:
      // Estrela de cinco pontas e duas faíscas: a bênção rara.
      final star = Path();
      for (var i = 0; i < 10; i++) {
        final r = i.isEven ? 0.42 : 0.18;
        final a = -math.pi / 2 + i * math.pi / 5;
        final p = Offset(0.5 + math.cos(a) * r, 0.54 + math.sin(a) * r);
        i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(star..close(), fill);
      paintSparkle(canvas, const Offset(0.13, 0.17), 0.05, ink);
      paintSparkle(canvas, const Offset(0.88, 0.86), 0.04, ink);
  }
}
