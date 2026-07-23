import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';

/// Lâmpadas = vidas da missão.
/// Cada erro apaga uma; zerar encerra a cena.
class LampsBar extends StatelessWidget {
  final int current;
  final int max;
  final Color accent;
  final bool labeled;

  /// Faixa larga (topo da pergunta) — ocupa a largura disponível.
  final bool fullWidth;

  const LampsBar({
    super.key,
    required this.current,
    this.max = 5,
    this.accent = AppColors.accent,
    this.labeled = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final icons = Row(
      mainAxisAlignment:
          fullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: List.generate(max, (i) {
        final on = i < current;
        return Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : (fullWidth ? 10 : 7)),
          child: AnimatedScale(
            scale: on ? 1 : 0.9,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: on ? 1 : 0.32,
              duration: const Duration(milliseconds: 220),
              child: CustomPaint(
                size: Size(fullWidth ? 22 : 20, fullWidth ? 30 : 28),
                painter: _LanternPainter(lit: on, color: accent),
              ),
            ),
          ),
        );
      }),
    );

    if (!labeled) return icons;

    final header = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        CinematicIcon(
          glyph: CinematicGlyph.lamp,
          size: 14,
          accent: accent.withValues(alpha: 0.9),
          framed: false,
        ),
        const SizedBox(width: 6),
        Text(
          'Lâmpadas',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$current/$max',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: accent,
          ),
        ),
      ],
    );

    return Semantics(
      label: '$current de $max lâmpadas. Cada erro apaga uma.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            fullWidth ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
        children: [
          header,
          SizedBox(height: fullWidth ? 10 : 8),
          icons,
          SizedBox(height: fullWidth ? 8 : 6),
          Text(
            'Erro apaga uma · zerar encerra',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.42),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lanterna clássica — silhueta vertical legível em tamanho pequeno.
class _LanternPainter extends CustomPainter {
  final bool lit;
  final Color color;

  const _LanternPainter({required this.lit, required this.color});

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

    // Anel superior
    canvas.drawCircle(
      Offset(cx, h * 0.1),
      w * 0.13,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = metalHi,
    );

    // Haste do anel → teto
    canvas.drawLine(
      Offset(cx, h * 0.16),
      Offset(cx, h * 0.24),
      Paint()
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = metalHi,
    );

    // Teto (trapézio)
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

    // Corpo / vidro
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

    // Moldura vertical do vidro
    canvas.drawLine(
      Offset(cx, h * 0.34),
      Offset(cx, h * 0.76),
      Paint()
        ..strokeWidth = 1
        ..color = metal.withValues(alpha: 0.55),
    );

    // Base
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

    // Chama dentro do vidro
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
          ).createShader(Rect.fromLTWH(cx - w * 0.14, h * 0.36, w * 0.28, h * 0.36)),
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
      // Pavio apagado
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
  bool shouldRepaint(covariant _LanternPainter old) =>
      old.lit != lit || old.color != color;
}
