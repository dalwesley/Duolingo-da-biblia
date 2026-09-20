import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Retrato ilustrado estável — fallback quando o peregrino não tem foto.
///
/// Mesma semente (uid ou nome) sempre gera o mesmo capuz, manto e cor.
class PilgrimMark extends StatelessWidget {
  final String seed;
  final double size;

  const PilgrimMark({
    super.key,
    required this.seed,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final spec = PilgrimMarkSpec.fromSeed(seed);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PilgrimMarkPainter(spec),
      ),
    );
  }
}

class PilgrimMarkSpec {
  final Color sky;
  final Color skyDeep;
  final Color cloak;
  final Color cloakDeep;
  final Color skin;
  final Color hair;
  final Color accent;
  final int pose;

  const PilgrimMarkSpec({
    required this.sky,
    required this.skyDeep,
    required this.cloak,
    required this.cloakDeep,
    required this.skin,
    required this.hair,
    required this.accent,
    required this.pose,
  });

  static const paletteCount = 8;
  static const poseCount = 8;

  factory PilgrimMarkSpec.fromSeed(String seed) {
    final h = pilgrimMarkHash(seed);
    const palettes = <List<Color>>[
      [
        Color(0xFF16324A),
        Color(0xFF0B1C2C),
        AppColors.accent,
        AppColors.accentDark,
        Color(0xFFE2B48A),
        Color(0xFF2A1C12),
        AppColors.accent,
      ],
      [
        Color(0xFF12383A),
        Color(0xFF08201E),
        AppColors.cedar,
        AppColors.cedarDeep,
        Color(0xFFC48A62),
        Color(0xFF1A1410),
        AppColors.cedar,
      ],
      [
        Color(0xFF3A1E24),
        Color(0xFF1C0C12),
        AppColors.coral,
        AppColors.emberDeep,
        Color(0xFFF0C8A4),
        Color(0xFF4A2814),
        AppColors.coral,
      ],
      [
        Color(0xFF2A1838),
        Color(0xFF14081C),
        AppColors.orchid,
        Color(0xFF7A3A88),
        Color(0xFFD4A07A),
        Color(0xFF241820),
        AppColors.orchid,
      ],
      [
        Color(0xFF2C2218),
        Color(0xFF16100A),
        AppColors.sand,
        AppColors.sandDeep,
        Color(0xFF8D5A3A),
        Color(0xFF1A1008),
        AppColors.sand,
      ],
      [
        Color(0xFF1A2A40),
        Color(0xFF0C1624),
        AppColors.slate,
        AppColors.slateDeep,
        Color(0xFFB07858),
        Color(0xFF3A2418),
        AppColors.slate,
      ],
      [
        Color(0xFF3A2218),
        Color(0xFF1C100C),
        AppColors.clay,
        AppColors.clayDeep,
        Color(0xFFF2D0B0),
        Color(0xFF5C3818),
        AppColors.clay,
      ],
      [
        Color(0xFF10282E),
        Color(0xFF071418),
        AppColors.teal,
        Color(0xFF1A6A5C),
        Color(0xFF5C3A28),
        Color(0xFF120E0C),
        AppColors.teal,
      ],
    ];
    final p = palettes[h % palettes.length];
    return PilgrimMarkSpec(
      sky: p[0],
      skyDeep: p[1],
      cloak: p[2],
      cloakDeep: p[3],
      skin: p[4],
      hair: p[5],
      accent: p[6],
      pose: (h ~/ palettes.length) % poseCount,
    );
  }
}

int pilgrimMarkHash(String seed) {
  final units = seed.trim().toLowerCase().codeUnits;
  var hash = 2166136261;
  for (final u in units) {
    hash ^= u;
    hash = (hash * 16777619) & 0x7fffffff;
  }
  if (units.isEmpty) hash ^= 17;
  return hash;
}

class _PilgrimMarkPainter extends CustomPainter {
  final PilgrimMarkSpec spec;

  const _PilgrimMarkPainter(this.spec);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = Offset(s / 2, s / 2);
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: s / 2)));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, s, s),
      Paint()
        ..shader = ui.Gradient.radial(
          c + Offset(0, -s * 0.18),
          s * 0.92,
          [spec.sky, spec.skyDeep],
        ),
    );

    canvas.drawCircle(
      c + Offset(-s * 0.18, -s * 0.28),
      s * 0.42,
      Paint()..color = spec.accent.withValues(alpha: 0.16),
    );

    _cloak(canvas, c, s);
    _head(canvas, c, s);
    _hairOrHood(canvas, c, s);
    if (s >= 28) _token(canvas, c, s);

    canvas.restore();
  }

  void _cloak(Canvas canvas, Offset c, double s) {
    final cloak = Path()
      ..moveTo(c.dx - s * 0.46, s)
      ..quadraticBezierTo(
        c.dx - s * 0.42,
        c.dy + s * 0.04,
        c.dx - s * 0.18,
        c.dy + s * 0.08,
      )
      ..quadraticBezierTo(
        c.dx,
        c.dy + s * 0.02,
        c.dx + s * 0.18,
        c.dy + s * 0.08,
      )
      ..quadraticBezierTo(
        c.dx + s * 0.42,
        c.dy + s * 0.04,
        c.dx + s * 0.46,
        s,
      )
      ..close();
    canvas.drawPath(
      cloak,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(c.dx, c.dy),
          Offset(c.dx, s),
          [spec.cloak, spec.cloakDeep],
        ),
    );

    final fold = Path()
      ..moveTo(c.dx - s * 0.04, c.dy + s * 0.1)
      ..quadraticBezierTo(
        c.dx + s * 0.02,
        c.dy + s * 0.28,
        c.dx - s * 0.06,
        s,
      )
      ..lineTo(c.dx + s * 0.08, s)
      ..quadraticBezierTo(
        c.dx + s * 0.1,
        c.dy + s * 0.26,
        c.dx + s * 0.04,
        c.dy + s * 0.1,
      )
      ..close();
    canvas.drawPath(
      fold,
      Paint()..color = spec.cloakDeep.withValues(alpha: 0.35),
    );
  }

  void _head(Canvas canvas, Offset c, double s) {
    final head = Offset(c.dx, c.dy - s * 0.08);
    canvas.drawOval(
      Rect.fromCenter(center: head, width: s * 0.42, height: s * 0.48),
      Paint()..color = spec.skin,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: head + Offset(-s * 0.08, s * 0.04),
        width: s * 0.14,
        height: s * 0.1,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );
  }

  void _hairOrHood(Canvas canvas, Offset c, double s) {
    final head = Offset(c.dx, c.dy - s * 0.08);
    switch (spec.pose) {
      case 0:
        _hood(canvas, c, s, head);
      case 1:
        canvas.drawArc(
          Rect.fromCenter(center: head, width: s * 0.46, height: s * 0.42),
          math.pi * 1.05,
          math.pi * 0.9,
          true,
          Paint()..color = spec.hair,
        );
      case 2:
        canvas.drawOval(
          Rect.fromCenter(
            center: head + Offset(-s * 0.16, s * 0.02),
            width: s * 0.22,
            height: s * 0.4,
          ),
          Paint()..color = spec.hair,
        );
        canvas.drawArc(
          Rect.fromCenter(center: head, width: s * 0.46, height: s * 0.4),
          math.pi * 1.08,
          math.pi * 0.84,
          true,
          Paint()..color = spec.hair,
        );
      case 3:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: head + Offset(0, -s * 0.08),
              width: s * 0.5,
              height: s * 0.12,
            ),
            Radius.circular(s * 0.06),
          ),
          Paint()..color = spec.cloakDeep,
        );
        canvas.drawArc(
          Rect.fromCenter(center: head, width: s * 0.44, height: s * 0.36),
          math.pi * 1.12,
          math.pi * 0.76,
          true,
          Paint()..color = spec.hair,
        );
      case 4:
        final collar = Path()
          ..moveTo(c.dx - s * 0.28, c.dy + s * 0.12)
          ..quadraticBezierTo(
            c.dx,
            c.dy - s * 0.02,
            c.dx + s * 0.28,
            c.dy + s * 0.12,
          )
          ..lineTo(c.dx + s * 0.22, c.dy + s * 0.2)
          ..quadraticBezierTo(
            c.dx,
            c.dy + s * 0.08,
            c.dx - s * 0.22,
            c.dy + s * 0.2,
          )
          ..close();
        canvas.drawPath(collar, Paint()..color = spec.cloakDeep);
        canvas.drawArc(
          Rect.fromCenter(center: head, width: s * 0.42, height: s * 0.34),
          math.pi * 1.12,
          math.pi * 0.76,
          true,
          Paint()..color = spec.hair,
        );
      case 5:
        canvas.drawArc(
          Rect.fromCenter(
            center: head + Offset(0, -s * 0.02),
            width: s * 0.58,
            height: s * 0.5,
          ),
          math.pi * 1.12,
          math.pi * 0.76,
          false,
          Paint()
            ..color = spec.accent.withValues(alpha: 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.045
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawArc(
          Rect.fromCenter(center: head, width: s * 0.44, height: s * 0.36),
          math.pi * 1.1,
          math.pi * 0.8,
          true,
          Paint()..color = spec.hair,
        );
      case 6:
        canvas.drawCircle(
          head + Offset(0, -s * 0.22),
          s * 0.09,
          Paint()..color = spec.hair,
        );
        canvas.drawArc(
          Rect.fromCenter(center: head, width: s * 0.44, height: s * 0.36),
          math.pi * 1.08,
          math.pi * 0.84,
          true,
          Paint()..color = spec.hair,
        );
      default:
        canvas.drawOval(
          Rect.fromCenter(
            center: head + Offset(0, -s * 0.16),
            width: s * 0.52,
            height: s * 0.18,
          ),
          Paint()..color = spec.cloakDeep,
        );
        canvas.drawArc(
          Rect.fromCenter(center: head, width: s * 0.42, height: s * 0.34),
          math.pi * 1.12,
          math.pi * 0.76,
          true,
          Paint()..color = spec.hair,
        );
    }
  }

  void _hood(Canvas canvas, Offset c, double s, Offset head) {
    final hood = Path()
      ..moveTo(c.dx - s * 0.28, c.dy + s * 0.1)
      ..quadraticBezierTo(
        c.dx - s * 0.38,
        c.dy - s * 0.08,
        c.dx - s * 0.18,
        head.dy - s * 0.26,
      )
      ..quadraticBezierTo(
        c.dx,
        head.dy - s * 0.36,
        c.dx + s * 0.18,
        head.dy - s * 0.26,
      )
      ..quadraticBezierTo(
        c.dx + s * 0.38,
        c.dy - s * 0.08,
        c.dx + s * 0.28,
        c.dy + s * 0.1,
      )
      ..quadraticBezierTo(
        c.dx + s * 0.16,
        c.dy - s * 0.02,
        c.dx,
        c.dy + s * 0.04,
      )
      ..quadraticBezierTo(
        c.dx - s * 0.16,
        c.dy - s * 0.02,
        c.dx - s * 0.28,
        c.dy + s * 0.1,
      )
      ..close();
    canvas.drawPath(hood, Paint()..color = spec.cloak);
    canvas.drawPath(
      hood,
      Paint()
        ..color = spec.cloakDeep.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.03,
    );
  }

  void _token(Canvas canvas, Offset c, double s) {
    final p = Offset(c.dx + s * 0.22, c.dy + s * 0.22);
    final paint = Paint()..color = spec.accent;
    switch (spec.pose % 4) {
      case 0:
        canvas.drawCircle(p, s * 0.055, paint);
        canvas.drawCircle(
          p,
          s * 0.09,
          Paint()
            ..color = spec.accent.withValues(alpha: 0.28)
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.02,
        );
      case 1:
        final seed = Path()
          ..moveTo(p.dx, p.dy - s * 0.07)
          ..quadraticBezierTo(
            p.dx + s * 0.06,
            p.dy,
            p.dx,
            p.dy + s * 0.07,
          )
          ..quadraticBezierTo(
            p.dx - s * 0.06,
            p.dy,
            p.dx,
            p.dy - s * 0.07,
          )
          ..close();
        canvas.drawPath(seed, paint);
      case 2:
        _star(canvas, p, s * 0.08, paint);
      default:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: p, width: s * 0.09, height: s * 0.12),
            Radius.circular(s * 0.02),
          ),
          paint,
        );
    }
  }

  void _star(Canvas canvas, Offset p, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 4 * math.pi / 5;
      final o = Offset(p.dx + math.cos(a) * r, p.dy + math.sin(a) * r);
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PilgrimMarkPainter oldDelegate) =>
      oldDelegate.spec.pose != spec.pose ||
      oldDelegate.spec.cloak != spec.cloak ||
      oldDelegate.spec.skin != spec.skin;
}
