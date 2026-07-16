import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Lâmpadas = vidas (Sl 119:105).
class LampsBar extends StatelessWidget {
  final int current;
  final int max;
  final Color accent;

  const LampsBar({
    super.key,
    required this.current,
    this.max = 5,
    this.accent = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        final on = i < current;
        return Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
          child: AnimatedScale(
            scale: on ? 1 : 0.86,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: on ? 1 : 0.35,
              duration: const Duration(milliseconds: 220),
              child: CustomPaint(
                size: const Size(18, 22),
                painter: _LampPainter(lit: on, color: accent),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _LampPainter extends CustomPainter {
  final bool lit;
  final Color color;

  const _LampPainter({required this.lit, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.42);
    final body = Path()
      ..moveTo(c.dx - size.width * 0.28, c.dy + size.height * 0.08)
      ..quadraticBezierTo(c.dx - size.width * 0.34, c.dy - size.height * 0.2, c.dx, c.dy - size.height * 0.32)
      ..quadraticBezierTo(c.dx + size.width * 0.34, c.dy - size.height * 0.2, c.dx + size.width * 0.28, c.dy + size.height * 0.08)
      ..quadraticBezierTo(c.dx, c.dy + size.height * 0.18, c.dx - size.width * 0.28, c.dy + size.height * 0.08)
      ..close();

    if (lit) {
      canvas.drawCircle(
        c,
        size.width * 0.55,
        Paint()
          ..shader = RadialGradient(
            colors: [color.withValues(alpha: 0.45), color.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: c, radius: size.width * 0.55)),
      );
      canvas.drawPath(
        body,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.lerp(color, Colors.white, 0.35)!, color, Color.lerp(color, const Color(0xFF8B5A00), 0.35)!],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
      );
      canvas.drawCircle(
        c + Offset(-size.width * 0.08, -size.height * 0.08),
        size.width * 0.1,
        Paint()..color = Colors.white.withValues(alpha: 0.45),
      );
    } else {
      canvas.drawPath(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.white.withValues(alpha: 0.35),
      );
    }

    // Base da lâmpada
    final baseY = size.height * 0.78;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(c.dx, baseY), width: size.width * 0.42, height: size.height * 0.12),
        const Radius.circular(2),
      ),
      Paint()..color = lit ? Color.lerp(color, const Color(0xFF5C3A00), 0.4)! : Colors.white.withValues(alpha: 0.28),
    );
    canvas.drawLine(
      Offset(c.dx, size.height * 0.68),
      Offset(c.dx, baseY - size.height * 0.04),
      Paint()
        ..color = lit ? Color.lerp(color, const Color(0xFF5C3A00), 0.35)! : Colors.white.withValues(alpha: 0.28)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    if (lit) {
      // Fagulha
      final spark = Offset(c.dx + size.width * 0.18, c.dy - size.height * 0.28);
      canvas.drawCircle(spark, 1.1, Paint()..color = Colors.white.withValues(alpha: 0.7 + 0.2 * math.sin(c.dx)));
    }
  }

  @override
  bool shouldRepaint(covariant _LampPainter old) => old.lit != lit || old.color != color;
}
