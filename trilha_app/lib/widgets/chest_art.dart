import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'medal_art.dart';

/// O baú do dia desenhado: madeira quente com contorno escuro, cintas e
/// fechadura de ouro, tesouro aceso por dentro. Proporção [aspect].
///
/// [lid] 0 = fechado; até ~0.35 a tampa só se solta, depois tomba para trás
/// e mostra o lado de dentro. Aceita passar de 1 (curva com quique).
class ChestPainter extends CustomPainter {
  final double lid;
  final Color glow;

  /// 0–1: brilho que corre pela fechadura (o baú "chamando").
  final double glint;

  const ChestPainter({required this.lid, required this.glow, this.glint = 0});

  static const aspect = 0.84;

  static const _outline = Color(0xFF3A1E0C);
  static const _woodLight = Color(0xFFDB8C4A);
  static const _wood = Color(0xFFC0702F);
  static const _woodDark = Color(0xFF8A461C);
  static const _inside = Color(0xFF4A2410);
  static const _goldLight = Color(0xFFFFDC72);
  static const _gold = AppColors.accent;
  static const _goldDark = Color(0xFFB06A05);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = w * 0.022;
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeJoin = StrokeJoin.round
      ..color = _outline;
    final hingeY = h * 0.47;
    final open = ((lid - 0.35) / 0.65).clamp(0.0, 1.2);

    // Sombra no chão.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.97),
        width: w * 1.02,
        height: h * 0.1,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.32),
    );

    if (open > 0) {
      _innerLid(canvas, w, h, hingeY, open, outline);
      _treasure(canvas, w, h, hingeY, open.clamp(0.0, 1.0), outline);
    }

    _body(canvas, w, h, outline);

    if (open <= 0) {
      // A tampa se solta: sobe um pouco e achata, ainda de frente.
      final lift = (lid / 0.35).clamp(0.0, 1.0);
      canvas.save();
      canvas.translate(0, hingeY);
      canvas.scale(1, 1 - 0.18 * lift);
      canvas.translate(0, -hingeY - h * 0.07 * lift);
      if (lift > 0) {
        // Fresta de luz por baixo da tampa.
        canvas.drawRect(
          Rect.fromLTRB(
            w * 0.08,
            hingeY - h * 0.02,
            w * 0.92,
            hingeY + h * 0.07 * lift,
          ),
          Paint()..color = _goldLight.withValues(alpha: 0.9 * lift),
        );
      }
      _lid(canvas, w, h, outline);
      canvas.restore();
    } else {
      _rim(canvas, w, h, hingeY - h * 0.02, h * 0.06, outline);
    }

    _lock(canvas, w, h, outline);
  }

  void _body(Canvas canvas, double w, double h, Paint outline) {
    final body = RRect.fromLTRBAndCorners(
      w * 0.06,
      h * 0.45,
      w * 0.94,
      h * 0.95,
      bottomLeft: Radius.circular(w * 0.05),
      bottomRight: Radius.circular(w * 0.05),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_wood, _woodDark],
        ).createShader(body.outerRect),
    );
    canvas.save();
    canvas.clipRRect(body);
    // Tábuas e veios.
    final seam = Paint()
      ..color = _outline.withValues(alpha: 0.45)
      ..strokeWidth = w * 0.012;
    canvas.drawLine(Offset(0, h * 0.71), Offset(w, h * 0.71), seam);
    final grain = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.008
      ..color = _woodDark.withValues(alpha: 0.7);
    for (final (x, y, len) in const [
      (0.36, 0.6, 0.1),
      (0.58, 0.64, 0.08),
      (0.4, 0.82, 0.12),
      (0.62, 0.86, 0.07),
    ]) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(w * x, h * y),
          width: w * len,
          height: h * 0.04,
        ),
        math.pi * 1.1,
        math.pi * 0.8,
        false,
        grain,
      );
    }
    _volume(canvas, body.outerRect);
    canvas.restore();
    // Faixa de ouro na base.
    final base = RRect.fromLTRBAndCorners(
      w * 0.06,
      h * 0.87,
      w * 0.94,
      h * 0.95,
      bottomLeft: Radius.circular(w * 0.05),
      bottomRight: Radius.circular(w * 0.05),
    );
    canvas.drawRRect(base, _goldPaint(base.outerRect));
    canvas.drawRRect(base, outline);
    for (final x in const [0.22, 0.78]) {
      _strap(
        canvas,
        Rect.fromLTRB(w * (x - 0.055), h * 0.47, w * (x + 0.055), h * 0.95),
        outline,
      );
      _rivet(canvas, Offset(w * x, h * 0.62), w);
      _rivet(canvas, Offset(w * x, h * 0.8), w);
    }
    canvas.drawRRect(body, outline);
  }

  void _lid(Canvas canvas, double w, double h, Paint outline) {
    final rect = Rect.fromLTRB(w * 0.03, h * 0.08, w * 0.97, h * 0.5);
    final dome = Path()
      ..moveTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top + rect.height * 0.5)
      ..cubicTo(
        rect.left,
        rect.top - rect.height * 0.08,
        rect.right,
        rect.top - rect.height * 0.08,
        rect.right,
        rect.top + rect.height * 0.5,
      )
      ..lineTo(rect.right, rect.bottom)
      ..close();
    canvas.drawPath(
      dome,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_woodLight, _wood],
        ).createShader(rect),
    );
    canvas.save();
    canvas.clipPath(dome);
    for (final x in const [0.22, 0.78]) {
      _strap(
        canvas,
        Rect.fromLTRB(w * (x - 0.055), 0, w * (x + 0.055), rect.bottom),
        null,
      );
    }
    // Brilho curvo no alto da tampa.
    canvas.drawArc(
      Rect.fromLTRB(w * 0.16, h * 0.12, w * 0.84, h * 0.42),
      math.pi * 1.18,
      math.pi * 0.64,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * 0.03
        ..color = Colors.white.withValues(alpha: 0.28),
    );
    _volume(canvas, rect);
    canvas.restore();
    for (final x in const [0.22, 0.78]) {
      final strapOutline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = outline.strokeWidth * 0.7
        ..color = _outline;
      canvas.save();
      canvas.clipPath(dome);
      canvas.drawRect(
        Rect.fromLTRB(w * (x - 0.055), -h, w * (x + 0.055), rect.bottom),
        strapOutline,
      );
      canvas.restore();
      _rivet(canvas, Offset(w * x, h * 0.3), w);
    }
    canvas.drawPath(dome, outline);
    _rim(canvas, w, h, h * 0.42, h * 0.09, outline);
  }

  /// Lado de dentro da tampa, tombada para trás atrás do corpo.
  void _innerLid(
    Canvas canvas,
    double w,
    double h,
    double hingeY,
    double open,
    Paint outline,
  ) {
    final rise = h * 0.4 * open;
    final spread = w * 0.04 * open;
    final path = Path()
      ..moveTo(w * 0.05, hingeY)
      ..lineTo(w * 0.05 - spread, hingeY - rise)
      ..lineTo(w * 0.95 + spread, hingeY - rise)
      ..lineTo(w * 0.95, hingeY)
      ..close();
    final bounds = Rect.fromLTRB(0, hingeY - rise, w, hingeY);
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_woodDark, _inside],
        ).createShader(bounds),
    );
    canvas.drawPath(path, outline);
    if (rise > h * 0.06) {
      _rim(
        canvas,
        w,
        h,
        hingeY - rise - h * 0.02,
        h * 0.06,
        outline,
        left: w * 0.03 - spread,
        right: w * 0.97 + spread,
      );
    }
  }

  /// Monte de moedas e gemas aceso dentro do baú.
  void _treasure(
    Canvas canvas,
    double w,
    double h,
    double hingeY,
    double open,
    Paint outline,
  ) {
    final center = Offset(w / 2, hingeY);
    canvas.drawCircle(
      center,
      w * 0.75,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _goldLight.withValues(alpha: 0.55 * open),
            glow.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: w * 0.75)),
    );
    final top = hingeY - h * 0.13 * open;
    final mound = Path()..moveTo(w * 0.08, hingeY + h * 0.02);
    const bumps = 6;
    for (var i = 0; i < bumps; i++) {
      final x0 = w * (0.08 + 0.84 * i / bumps);
      final x1 = w * (0.08 + 0.84 * (i + 1) / bumps);
      final peak = top + h * 0.035 * ((i * 7) % 3);
      mound.quadraticBezierTo(
        (x0 + x1) / 2,
        peak - h * 0.03,
        x1,
        peak + h * 0.025,
      );
    }
    mound
      ..lineTo(w * 0.92, hingeY + h * 0.02)
      ..close();
    canvas.drawPath(
      mound,
      _goldPaint(Rect.fromLTRB(0, top - h * 0.05, w, hingeY)),
    );
    canvas.drawPath(
      mound,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = outline.strokeWidth * 0.7
        ..strokeJoin = StrokeJoin.round
        ..color = _outline,
    );
    final coin = Paint()..color = _goldLight;
    for (final (x, dy) in const [
      (0.3, 0.0),
      (0.47, -0.02),
      (0.66, 0.01),
      (0.8, 0.03),
    ]) {
      final c = Offset(w * x, top + h * (0.05 + dy));
      final r = Rect.fromCenter(center: c, width: w * 0.08, height: h * 0.045);
      canvas.drawOval(r, coin);
      canvas.drawOval(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.01
          ..color = _goldDark,
      );
    }
    for (final (x, dy, color) in const [
      (0.38, 0.02, AppColors.glow),
      (0.58, 0.0, AppColors.error),
      (0.73, 0.045, AppColors.sprout),
    ]) {
      _gem(canvas, Offset(w * x, top + h * dy), w * 0.035, color);
    }
  }

  void _rim(
    Canvas canvas,
    double w,
    double h,
    double top,
    double height,
    Paint outline, {
    double? left,
    double? right,
  }) {
    final rim = RRect.fromLTRBR(
      left ?? w * 0.02,
      top,
      right ?? w * 0.98,
      top + height,
      Radius.circular(height * 0.35),
    );
    canvas.drawRRect(rim, _goldPaint(rim.outerRect));
    canvas.drawLine(
      Offset(rim.left + w * 0.04, top + height * 0.3),
      Offset(rim.right - w * 0.04, top + height * 0.3),
      Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = height * 0.22
        ..color = Colors.white.withValues(alpha: 0.4),
    );
    canvas.drawRRect(rim, outline);
  }

  void _strap(Canvas canvas, Rect r, Paint? outline) {
    canvas.drawRect(r, _goldPaint(r));
    canvas.drawRect(
      Rect.fromLTWH(r.left + r.width * 0.18, r.top, r.width * 0.2, r.height),
      Paint()..color = Colors.white.withValues(alpha: 0.32),
    );
    if (outline != null) {
      canvas.drawRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = outline.strokeWidth * 0.7
          ..color = _outline,
      );
    }
  }

  void _lock(Canvas canvas, double w, double h, Paint outline) {
    final cx = w / 2;
    final top = h * 0.4;
    final bottom = h * 0.7;
    final half = w * 0.1;
    final shield = Path()
      ..moveTo(cx - half, top + h * 0.04)
      ..quadraticBezierTo(cx - half, top, cx - half + w * 0.04, top)
      ..lineTo(cx + half - w * 0.04, top)
      ..quadraticBezierTo(cx + half, top, cx + half, top + h * 0.04)
      ..lineTo(cx + half, bottom - h * 0.1)
      ..quadraticBezierTo(cx + half, bottom - h * 0.03, cx, bottom)
      ..quadraticBezierTo(
        cx - half,
        bottom - h * 0.03,
        cx - half,
        bottom - h * 0.1,
      )
      ..close();
    final bounds = Rect.fromLTRB(cx - half, top, cx + half, bottom);
    canvas.drawPath(shield, _goldPaint(bounds));
    canvas.drawPath(
      Path()
        ..moveTo(cx - half * 0.62, top + h * 0.035)
        ..lineTo(cx - half * 0.62, bottom - h * 0.11),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * 0.02
        ..color = Colors.white.withValues(alpha: 0.45),
    );
    canvas.drawPath(shield, outline);
    final hole = Paint()..color = _outline;
    final key = Offset(cx, top + (bottom - top) * 0.4);
    canvas.drawCircle(key, w * 0.026, hole);
    canvas.drawPath(
      Path()
        ..moveTo(key.dx - w * 0.016, key.dy)
        ..lineTo(key.dx + w * 0.016, key.dy)
        ..lineTo(key.dx + w * 0.024, key.dy + h * 0.09)
        ..lineTo(key.dx - w * 0.024, key.dy + h * 0.09)
        ..close(),
      hole,
    );
    if (glint > 0 && glint < 1) {
      canvas.save();
      canvas.clipPath(shield);
      final x = bounds.left - bounds.width + bounds.width * 3 * glint;
      canvas.drawPath(
        Path()
          ..moveTo(x, bounds.top)
          ..lineTo(x + w * 0.05, bounds.top)
          ..lineTo(x - w * 0.02, bounds.bottom)
          ..lineTo(x - w * 0.07, bounds.bottom)
          ..close(),
        Paint()..color = Colors.white.withValues(alpha: 0.7),
      );
      canvas.restore();
      paintSparkle(
        canvas,
        Offset(cx + half * 0.9, top + h * 0.02),
        w * 0.05 * math.sin(glint * math.pi),
      );
    }
  }

  void _rivet(Canvas canvas, Offset c, double w) {
    canvas.drawCircle(c, w * 0.018, Paint()..color = _goldDark);
    canvas.drawCircle(
      c.translate(-w * 0.004, -w * 0.004),
      w * 0.01,
      Paint()..color = _goldLight,
    );
  }

  /// Sombra dos lados — a peça ganha volume de caixa.
  void _volume(Canvas canvas, Rect r) {
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.18),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.26),
          ],
          stops: const [0.0, 0.2, 0.72, 1.0],
        ).createShader(r),
    );
  }

  static void _gem(Canvas canvas, Offset c, double r, Color color) {
    final gem = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r * 0.85, c.dy)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r * 0.85, c.dy)
      ..close();
    canvas.drawPath(gem, Paint()..color = color);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - r)
        ..lineTo(c.dx + r * 0.85, c.dy)
        ..lineTo(c.dx, c.dy)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );
    canvas.drawPath(
      gem,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.22
        ..color = _outline.withValues(alpha: 0.7),
    );
  }

  static Paint _goldPaint(Rect r) => Paint()
    ..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_goldLight, _gold, _goldDark],
      stops: [0.0, 0.5, 1.0],
    ).createShader(r);

  @override
  bool shouldRepaint(ChestPainter old) =>
      old.lid != lid || old.glow != glow || old.glint != glint;
}

/// Céu noturno do baú: degradê da noite do app, luz no centro, moedas no
/// chão e faíscas piscando. Sempre escuro — é cena.
class ChestSkyPainter extends CustomPainter {
  final Color accent;

  /// 0–1, gira em loop: faz as faíscas piscarem.
  final double pulse;

  /// Força da luz central (0–1+).
  final double shine;

  /// Onde fica o baú, em fração da área — a luz nasce dali.
  final Offset focus;

  /// Raios girando atrás do baú (0 = sem raios).
  final double rays;

  /// Moedas no chão (o palco da folha).
  final bool floor;

  const ChestSkyPainter({
    required this.accent,
    required this.pulse,
    this.shine = 0.5,
    this.focus = const Offset(0.5, 0.6),
    this.rays = 0,
    this.floor = true,
  });

  static const _coins = <(double, double)>[
    (0.07, 0.94),
    (0.15, 0.88),
    (0.22, 0.96),
    (0.33, 0.97),
    (0.66, 0.97),
    (0.77, 0.93),
    (0.86, 0.88),
    (0.93, 0.96),
  ];
  static const _sparks = <(double, double, double, double)>[
    (0.12, 0.18, 6, 0.0),
    (0.86, 0.14, 5, 0.35),
    (0.22, 0.46, 4, 0.6),
    (0.8, 0.4, 4, 0.15),
    (0.5, 0.08, 3, 0.8),
    (0.66, 0.24, 3, 0.45),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.nightElevated,
            AppColors.nightMid,
            AppColors.night,
          ],
          stops: [0.0, 0.6, 1.0],
        ).createShader(rect),
    );
    final breath = (math.sin(pulse * math.pi * 2) + 1) / 2;
    final center = Offset(size.width * focus.dx, size.height * focus.dy);
    final reach = math.max(size.width, size.height) * 0.7;

    if (rays > 0) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(pulse * math.pi * 2 / 6);
      const count = 12;
      final ray = Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(alpha: 0.32 * rays),
            accent.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: reach));
      for (var i = 0; i < count; i++) {
        final a = i * math.pi * 2 / count;
        canvas.drawPath(
          Path()
            ..moveTo(0, 0)
            ..lineTo(math.cos(a - 0.11) * reach, math.sin(a - 0.11) * reach)
            ..lineTo(math.cos(a + 0.11) * reach, math.sin(a + 0.11) * reach)
            ..close(),
          ray,
        );
      }
      canvas.restore();
    }

    final glowR = size.height * 0.7;
    canvas.drawCircle(
      center,
      glowR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(
              alpha: ((0.2 + 0.08 * breath) * shine).clamp(0.0, 1.0),
            ),
            accent.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: glowR)),
    );

    if (floor) {
      final ground = Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.92),
        width: size.width * 0.9,
        height: size.height * 0.2,
      );
      canvas.drawOval(
        ground,
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.35),
              AppColors.primary.withValues(alpha: 0),
            ],
          ).createShader(ground),
      );
      for (final (x, y) in _coins) {
        final c = Offset(size.width * x, size.height * y);
        final coin = Rect.fromCenter(center: c, width: 16, height: 8);
        canvas.drawOval(coin, Paint()..color = const Color(0xFFB06A05));
        canvas.drawOval(
          coin.translate(0, -2),
          Paint()..color = const Color(0xFFFFD45C),
        );
      }
    }

    for (final (x, y, r, phase) in _sparks) {
      final t = (math.sin((pulse + phase) * math.pi * 2) + 1) / 2;
      paintSparkle(
        canvas,
        Offset(size.width * x, size.height * y),
        r * (0.6 + 0.4 * t),
        AppColors.accentBright.withValues(alpha: 0.3 + 0.6 * t),
      );
    }
  }

  @override
  bool shouldRepaint(ChestSkyPainter old) =>
      old.accent != accent ||
      old.pulse != pulse ||
      old.shine != shine ||
      old.focus != focus ||
      old.rays != rays ||
      old.floor != floor;
}
