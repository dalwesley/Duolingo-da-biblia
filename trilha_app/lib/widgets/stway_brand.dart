import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Marca STWAY — ícone da trilha + wordmark com o “A” em chevron.
class StwayLogo extends StatelessWidget {
  final double size;
  final double? pulse;

  const StwayLogo({super.key, this.size = 96, this.pulse});

  @override
  Widget build(BuildContext context) {
    final p = pulse ?? 0.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.22 + 0.14 * p),
            blurRadius: 28 + 12 * p,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.1 + 0.08 * p),
            blurRadius: 36 + 16 * p,
            spreadRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/icon/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

/// Wordmark STWAY — letras creme, “A” em chevron sálvia (sem travessão).
class StwayWordmark extends StatelessWidget {
  final double fontSize;
  final double letterSpacing;
  final Color? letterColor;
  final Color? aColor;
  final FontWeight weight;

  const StwayWordmark({
    super.key,
    this.fontSize = 42,
    this.letterSpacing = 8,
    this.letterColor,
    this.aColor,
    this.weight = FontWeight.w900,
  });

  @override
  Widget build(BuildContext context) {
    final letters = letterColor ?? AppColors.textOnDark;
    final chevron = aColor ?? AppColors.primaryLight;
    final style = AppTypography.display(
      size: fontSize,
      weight: weight,
      color: letters,
      height: 1,
    ).copyWith(letterSpacing: letterSpacing);

    final aSize = fontSize * 0.72;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('ST', style: style),
        SizedBox(width: letterSpacing * 0.35),
        CustomPaint(
          size: Size(aSize * 0.95, aSize),
          painter: _ChevronAPainter(color: chevron),
        ),
        SizedBox(width: letterSpacing * 0.35),
        Text('W', style: style),
        SizedBox(width: letterSpacing * 0.55),
        Text('Y', style: style),
      ],
    );
  }
}

class _ChevronAPainter extends CustomPainter {
  final Color color;

  _ChevronAPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.92)
      ..lineTo(size.width * 0.5, size.height * 0.12)
      ..lineTo(size.width * 0.92, size.height * 0.92);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronAPainter oldDelegate) =>
      oldDelegate.color != color;
}

class StwayTagline extends StatelessWidget {
  final Color? color;
  final double size;

  const StwayTagline({super.key, this.color, this.size = 10});

  @override
  Widget build(BuildContext context) {
    return Text(
      'UM PASSO. UMA JORNADA. UMA COMUNIDADE.',
      textAlign: TextAlign.center,
      style: AppTypography.label(
        size: size,
        letterSpacing: 1.6,
        color: color ?? AppColors.primaryLight.withValues(alpha: 0.9),
      ),
    );
  }
}
