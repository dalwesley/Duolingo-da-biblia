import 'package:flutter/material.dart';

/// Geometria compartilhada da lanterna clássica (vidas da missão).
/// Usada no HUD (`CinematicGlyph.lamp`) e na barra de perguntas (`LampsBar`).
class LanternGlyph {
  LanternGlyph._();

  /// Silhueta sólida — legível em 12–32px, alinhada aos outros glifos.
  static void paintSolid(Canvas canvas, Size size, Color color) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final ink = Paint()..color = color;
    final soft = Paint()..color = color.withValues(alpha: 0.55);
    final hot = Paint()..color = Color.lerp(color, Colors.white, 0.4)!;

    // Anel superior (fill donut)
    final ringOuter = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, h * 0.1), radius: w * 0.14));
    final ringInner = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, h * 0.1), radius: w * 0.07));
    canvas.drawPath(
      Path.combine(PathOperation.difference, ringOuter, ringInner),
      ink,
    );

    // Haste
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * 0.2),
          width: w * 0.1,
          height: h * 0.08,
        ),
        Radius.circular(w * 0.04),
      ),
      ink,
    );

    // Teto
    final roof = Path()
      ..moveTo(w * 0.16, h * 0.34)
      ..lineTo(w * 0.26, h * 0.24)
      ..lineTo(w * 0.74, h * 0.24)
      ..lineTo(w * 0.84, h * 0.34)
      ..close();
    canvas.drawPath(roof, ink);

    // Corpo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.2, h * 0.34, w * 0.8, h * 0.76),
        Radius.circular(w * 0.08),
      ),
      ink,
    );

    // Divisor vertical (vidro)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * 0.55),
          width: w * 0.07,
          height: h * 0.28,
        ),
        Radius.circular(w * 0.02),
      ),
      soft,
    );

    // Chama
    final flame = Path()
      ..moveTo(cx, h * 0.68)
      ..quadraticBezierTo(cx - w * 0.1, h * 0.54, cx, h * 0.42)
      ..quadraticBezierTo(cx + w * 0.1, h * 0.54, cx, h * 0.68)
      ..close();
    canvas.drawPath(flame, hot);

    // Base
    final base = Path()
      ..moveTo(w * 0.18, h * 0.76)
      ..lineTo(w * 0.82, h * 0.76)
      ..lineTo(w * 0.72, h * 0.9)
      ..lineTo(w * 0.28, h * 0.9)
      ..close();
    canvas.drawPath(base, ink);
  }
}

/// Lanterna detalhada (acesa / apagada) para a barra de vidas.
class LanternPainter extends CustomPainter {
  final bool lit;
  final Color color;

  const LanternPainter({required this.lit, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final metal = lit
        ? Color.lerp(color, const Color(0xFF8A5A28), 0.25)!
        : Colors.white.withValues(alpha: 0.42);
    final metalHi = lit
        ? Color.lerp(color, Colors.white, 0.4)!
        : Colors.white.withValues(alpha: 0.55);
    final metalLo = lit
        ? Color.lerp(color, const Color(0xFF3D2208), 0.5)!
        : Colors.white.withValues(alpha: 0.22);

    if (lit) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, h * 0.52),
          width: w * 0.95,
          height: h * 0.55,
        ),
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: 0.45),
              color.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(center: Offset(cx, h * 0.52), radius: w * 0.55),
          ),
      );
    }

    canvas.drawCircle(
      Offset(cx, h * 0.1),
      w * 0.13,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = metalHi,
    );

    canvas.drawLine(
      Offset(cx, h * 0.16),
      Offset(cx, h * 0.24),
      Paint()
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = metalHi,
    );

    final roof = Path()
      ..moveTo(w * 0.18, h * 0.32)
      ..lineTo(w * 0.28, h * 0.24)
      ..lineTo(w * 0.72, h * 0.24)
      ..lineTo(w * 0.82, h * 0.32)
      ..close();
    canvas.drawPath(
      roof,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [metalHi, metal],
        ).createShader(Rect.fromLTWH(0, h * 0.22, w, h * 0.12)),
    );

    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.22, h * 0.32, w * 0.78, h * 0.78),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..color = lit
            ? color.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.06),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = metal,
    );

    canvas.drawLine(
      Offset(cx, h * 0.34),
      Offset(cx, h * 0.76),
      Paint()
        ..strokeWidth = 1
        ..color = metal.withValues(alpha: 0.55),
    );

    final base = Path()
      ..moveTo(w * 0.2, h * 0.78)
      ..lineTo(w * 0.8, h * 0.78)
      ..lineTo(w * 0.72, h * 0.9)
      ..lineTo(w * 0.28, h * 0.9)
      ..close();
    canvas.drawPath(
      base,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [metal, metalLo],
        ).createShader(Rect.fromLTWH(0, h * 0.76, w, h * 0.16)),
    );

    if (lit) {
      final flame = Path()
        ..moveTo(cx, h * 0.7)
        ..quadraticBezierTo(cx - w * 0.12, h * 0.55, cx, h * 0.38)
        ..quadraticBezierTo(cx + w * 0.12, h * 0.55, cx, h * 0.7)
        ..close();

      canvas.drawPath(
        flame,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8)
          ..color = color.withValues(alpha: 0.7),
      );
      canvas.drawPath(
        flame,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              color,
              Color.lerp(color, const Color(0xFFFFE9A8), 0.55)!,
              Colors.white,
            ],
            stops: const [0, 0.55, 1],
          ).createShader(
            Rect.fromLTWH(cx - w * 0.14, h * 0.36, w * 0.28, h * 0.36),
          ),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, h * 0.58),
          width: w * 0.08,
          height: h * 0.12,
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    } else {
      canvas.drawLine(
        Offset(cx, h * 0.62),
        Offset(cx, h * 0.48),
        Paint()
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant LanternPainter old) =>
      old.lit != lit || old.color != color;
}
