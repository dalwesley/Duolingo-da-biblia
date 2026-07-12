import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Símbolos cinematográficos — selos iluminados, sem emoji e sem ícone de sistema.
enum CinematicGlyph {
  cosmos,
  sun,
  humanity,
  dove,
  tree,
  fall,
  tears,
  scales,
  flood,
  tower,
  star,
  crown,
  chain,
  sea,
  flame,
  scroll,
  seed,
  path,
  depths,
  spark,
  heart,
  mountain,
  book,
  calendar,
  gem,
  lamp,
  check,
}

class CinematicGlyphResolver {
  static CinematicGlyph forMission(String title, {bool isBoss = false}) {
    if (isBoss) return CinematicGlyph.crown;
    final t = title.toLowerCase();
    if (t.contains('criou') || t.contains('mundo') || t.contains('princípio') || t.contains('principio')) {
      return CinematicGlyph.cosmos;
    }
    if (t.contains('dias') || t.contains('criação') || t.contains('criacao') || t.contains('luz')) {
      return CinematicGlyph.sun;
    }
    if (t.contains('imagem') || t.contains('homem') || t.contains('humano')) return CinematicGlyph.humanity;
    if (t.contains('descanso') || t.contains('sábado') || t.contains('sabado')) return CinematicGlyph.dove;
    if (t.contains('éden') || t.contains('eden') || t.contains('jardim')) return CinematicGlyph.tree;
    if (t.contains('desobediência') || t.contains('desobediencia') || t.contains('queda') || t.contains('tentação') || t.contains('tentacao')) {
      return CinematicGlyph.fall;
    }
    if (t.contains('consequência') || t.contains('consequencia')) return CinematicGlyph.tears;
    if (t.contains('caim') || t.contains('abel')) return CinematicGlyph.scales;
    if (t.contains('dilúvio') || t.contains('diluvio') || t.contains('noé') || t.contains('noe') || t.contains('arca')) {
      return CinematicGlyph.flood;
    }
    if (t.contains('babel')) return CinematicGlyph.tower;
    if (t.contains('abraão') || t.contains('abraao') || t.contains('promessa')) return CinematicGlyph.star;
    if (t.contains('páscoa') || t.contains('pascoa') || t.contains('cordeiro')) return CinematicGlyph.dove;
    if (t.contains('pragas')) return CinematicGlyph.flame;
    if (t.contains('mar vermelho') || t.contains('mar ')) return CinematicGlyph.sea;
    if (t.contains('moisés') || t.contains('moises') || t.contains('sarça') || t.contains('sarca')) {
      return CinematicGlyph.flame;
    }
    if (t.contains('opressão') || t.contains('opressao') || t.contains('egito') || t.contains('escrav')) {
      return CinematicGlyph.chain;
    }
    return CinematicGlyph.scroll;
  }

  static CinematicGlyph forModule(String title) {
    return switch (title) {
      'A Criação' => CinematicGlyph.sun,
      'O Jardim' => CinematicGlyph.tree,
      'Depois do Éden' => CinematicGlyph.mountain,
      'Opressão no Egito' => CinematicGlyph.chain,
      'A Libertação' => CinematicGlyph.sea,
      _ => CinematicGlyph.scroll,
    };
  }

  static CinematicGlyph forTrail(String slug) {
    return switch (slug) {
      'genesis-1-11' => CinematicGlyph.book,
      'exodo' => CinematicGlyph.mountain,
      'evangelhos' => CinematicGlyph.heart,
      'atos' => CinematicGlyph.flame,
      'apocalipse' => CinematicGlyph.crown,
      _ => CinematicGlyph.scroll,
    };
  }

  static CinematicGlyph forDifficulty(String id) {
    return switch (id) {
      'semente' => CinematicGlyph.seed,
      'caminhada' => CinematicGlyph.path,
      'profundezas' => CinematicGlyph.depths,
      _ => CinematicGlyph.seed,
    };
  }

  static CinematicGlyph forQuest(String id) {
    return switch (id) {
      'mission' => CinematicGlyph.book,
      'accuracy' => CinematicGlyph.spark,
      'perfect' => CinematicGlyph.crown,
      'w_missions' => CinematicGlyph.calendar,
      'w_days' => CinematicGlyph.flame,
      'w_perfect' => CinematicGlyph.gem,
      _ => CinematicGlyph.spark,
    };
  }

  static Color paletteFor(CinematicGlyph glyph, {Color? accent}) {
    return switch (glyph) {
      CinematicGlyph.sun || CinematicGlyph.spark || CinematicGlyph.star => const Color(0xFFFFD56A),
      CinematicGlyph.cosmos || CinematicGlyph.depths => const Color(0xFF9B8CFF),
      CinematicGlyph.tree || CinematicGlyph.seed => const Color(0xFF7DCEA0),
      CinematicGlyph.flood || CinematicGlyph.sea || CinematicGlyph.tears => const Color(0xFF74B9FF),
      CinematicGlyph.flame || CinematicGlyph.fall => const Color(0xFFFF8C42),
      CinematicGlyph.heart || CinematicGlyph.dove => const Color(0xFFFFAB91),
      CinematicGlyph.crown || CinematicGlyph.gem || CinematicGlyph.lamp => AppColors.accent,
      CinematicGlyph.chain || CinematicGlyph.mountain || CinematicGlyph.tower => const Color(0xFFD4C4A8),
      CinematicGlyph.scales || CinematicGlyph.path => const Color(0xFFE8B84B),
      CinematicGlyph.humanity => const Color(0xFFF5D78E),
      CinematicGlyph.book || CinematicGlyph.scroll || CinematicGlyph.calendar || CinematicGlyph.check =>
        accent ?? AppColors.primaryLight,
    };
  }
}

/// Ícone cinematográfico com aura, profundidade e personalidade.
class CinematicIcon extends StatelessWidget {
  final CinematicGlyph glyph;
  final double size;
  final Color? accent;
  final bool framed;
  final bool glowing;
  final bool animate;

  const CinematicIcon({
    super.key,
    required this.glyph,
    this.size = 48,
    this.accent,
    this.framed = true,
    this.glowing = true,
    this.animate = false,
  });

  factory CinematicIcon.mission(
    String title, {
    Key? key,
    bool isBoss = false,
    double size = 48,
    Color? accent,
    bool framed = true,
    bool glowing = true,
    bool animate = false,
  }) {
    return CinematicIcon(
      key: key,
      glyph: CinematicGlyphResolver.forMission(title, isBoss: isBoss),
      size: size,
      accent: accent,
      framed: framed,
      glowing: glowing,
      animate: animate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = accent ?? CinematicGlyphResolver.paletteFor(glyph);
    final child = CustomPaint(
      size: Size.square(size * (framed ? 0.58 : 1)),
      painter: _GlyphPainter(glyph: glyph, color: color),
    );

    if (!framed) {
      if (!glowing) return SizedBox(width: size, height: size, child: child);
      return SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: size * 0.35),
            ],
          ),
          child: child,
        ),
      );
    }

    final medallion = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, 0.18)!,
            color,
            Color.lerp(color, const Color(0xFF1A1035), 0.55)!,
          ],
          stops: const [0.0, 0.42, 1.0],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28), width: size * 0.028),
        boxShadow: glowing
            ? [
                BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: size * 0.32, offset: Offset(0, size * 0.06)),
                BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: size * 0.55),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vinheta interna — profundidade de medalhão.
          Container(
            width: size * 0.86,
            height: size * 0.86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.16),
                  Colors.black.withValues(alpha: 0.22),
                ],
                stops: const [0.35, 1],
              ),
            ),
          ),
          // Anel orbital sutil.
          CustomPaint(
            size: Size.square(size * 0.82),
            painter: _OrbitRingPainter(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child,
          // Highlight de lente.
          Positioned(
            top: size * 0.14,
            left: size * 0.2,
            child: Container(
              width: size * 0.28,
              height: size * 0.14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [Colors.white.withValues(alpha: 0.35), Colors.white.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!animate) return medallion;
    return _BreathingAura(color: color, size: size, child: medallion);
  }
}

class _BreathingAura extends StatefulWidget {
  final Widget child;
  final Color color;
  final double size;

  const _BreathingAura({required this.child, required this.color, required this.size});

  @override
  State<_BreathingAura> createState() => _BreathingAuraState();
}

class _BreathingAuraState extends State<_BreathingAura> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_pulse.value);
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.22 + 0.28 * t),
                blurRadius: widget.size * (0.28 + 0.22 * t),
                spreadRadius: widget.size * 0.02 * t,
              ),
            ],
          ),
          child: Transform.scale(scale: 1 + 0.03 * t, child: child),
        );
      },
      child: widget.child,
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  final Color color;
  const _OrbitRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.018
      ..color = color;
    canvas.drawCircle(c, size.width * 0.46, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter old) => old.color != color;
}

class _GlyphPainter extends CustomPainter {
  final CinematicGlyph glyph;
  final Color color;

  const _GlyphPainter({required this.glyph, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = size.shortestSide;
    switch (glyph) {
      case CinematicGlyph.sun:
        _paintSun(canvas, c, s);
      case CinematicGlyph.cosmos:
        _paintCosmos(canvas, c, s);
      case CinematicGlyph.humanity:
        _paintHumanity(canvas, c, s);
      case CinematicGlyph.dove:
        _paintDove(canvas, c, s);
      case CinematicGlyph.tree:
        _paintTree(canvas, c, s);
      case CinematicGlyph.fall:
        _paintFall(canvas, c, s);
      case CinematicGlyph.tears:
        _paintTears(canvas, c, s);
      case CinematicGlyph.scales:
        _paintScales(canvas, c, s);
      case CinematicGlyph.flood:
      case CinematicGlyph.sea:
        _paintWaves(canvas, c, s);
      case CinematicGlyph.tower:
        _paintTower(canvas, c, s);
      case CinematicGlyph.star:
        _paintStar(canvas, c, s);
      case CinematicGlyph.crown:
        _paintCrown(canvas, c, s);
      case CinematicGlyph.chain:
        _paintChain(canvas, c, s);
      case CinematicGlyph.flame:
        _paintFlame(canvas, c, s);
      case CinematicGlyph.scroll:
      case CinematicGlyph.book:
        _paintBook(canvas, c, s);
      case CinematicGlyph.seed:
        _paintSeed(canvas, c, s);
      case CinematicGlyph.path:
        _paintPath(canvas, c, s);
      case CinematicGlyph.depths:
        _paintDepths(canvas, c, s);
      case CinematicGlyph.spark:
        _paintSpark(canvas, c, s);
      case CinematicGlyph.heart:
        _paintHeart(canvas, c, s);
      case CinematicGlyph.mountain:
        _paintMountain(canvas, c, s);
      case CinematicGlyph.calendar:
        _paintCalendar(canvas, c, s);
      case CinematicGlyph.gem:
        _paintGem(canvas, c, s);
      case CinematicGlyph.lamp:
        _paintLamp(canvas, c, s);
      case CinematicGlyph.check:
        _paintCheck(canvas, c, s);
    }
  }

  Paint get _fill => Paint()..color = const Color(0xFF2A2100).withValues(alpha: 0.92);
  Paint get _soft => Paint()..color = const Color(0xFF2A2100).withValues(alpha: 0.55);
  Paint get _glow => Paint()
    ..color = Colors.white.withValues(alpha: 0.55)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

  void _paintSun(Canvas canvas, Offset c, double s) {
    // Corona difusa.
    canvas.drawCircle(
      c,
      s * 0.42,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withValues(alpha: 0.55), Colors.white.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: c, radius: s * 0.42)),
    );
    // Raios longos e curtos intercalados.
    for (var i = 0; i < 12; i++) {
      final a = (i / 12) * math.pi * 2 - math.pi / 2;
      final long = i.isEven;
      final inner = s * (long ? 0.22 : 0.2);
      final outer = s * (long ? 0.46 : 0.34);
      final p1 = c + Offset(math.cos(a) * inner, math.sin(a) * inner);
      final p2 = c + Offset(math.cos(a) * outer, math.sin(a) * outer);
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = const Color(0xFF2A2100).withValues(alpha: long ? 0.9 : 0.55)
          ..strokeWidth = long ? s * 0.045 : s * 0.028
          ..strokeCap = StrokeCap.round,
      );
    }
    // Disco solar com highlight.
    canvas.drawCircle(c, s * 0.18, _glow);
    canvas.drawCircle(c, s * 0.16, _fill);
    canvas.drawCircle(
      c + Offset(-s * 0.04, -s * 0.05),
      s * 0.045,
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  void _paintCosmos(Canvas canvas, Offset c, double s) {
    canvas.drawCircle(c, s * 0.38, Paint()..color = const Color(0xFF2A2100).withValues(alpha: 0.18));
    for (final r in [0.36, 0.26, 0.16]) {
      canvas.drawCircle(
        c,
        s * r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.02
          ..color = const Color(0xFF2A2100).withValues(alpha: 0.75),
      );
    }
    // Estrelas orbitando.
    for (var i = 0; i < 5; i++) {
      final a = i * 1.35;
      final p = c + Offset(math.cos(a) * s * 0.31, math.sin(a) * s * 0.31);
      canvas.drawCircle(p, s * 0.035, _fill);
    }
    canvas.drawCircle(c, s * 0.07, _fill);
  }

  void _paintHumanity(Canvas canvas, Offset c, double s) {
    // Silhueta estilizada — cabeça + ombros em arco.
    canvas.drawCircle(c + Offset(0, -s * 0.14), s * 0.12, _fill);
    final body = Path()
      ..moveTo(c.dx - s * 0.28, c.dy + s * 0.32)
      ..quadraticBezierTo(c.dx - s * 0.22, c.dy + s * 0.02, c.dx, c.dy - s * 0.02)
      ..quadraticBezierTo(c.dx + s * 0.22, c.dy + s * 0.02, c.dx + s * 0.28, c.dy + s * 0.32)
      ..close();
    canvas.drawPath(body, _fill);
    // Halo.
    canvas.drawArc(
      Rect.fromCircle(center: c + Offset(0, -s * 0.14), radius: s * 0.2),
      math.pi * 1.15,
      math.pi * 0.7,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.03
        ..color = const Color(0xFF2A2100).withValues(alpha: 0.55)
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintDove(Canvas canvas, Offset c, double s) {
    final body = Path()
      ..moveTo(c.dx - s * 0.08, c.dy + s * 0.05)
      ..quadraticBezierTo(c.dx + s * 0.05, c.dy - s * 0.22, c.dx + s * 0.28, c.dy - s * 0.08)
      ..quadraticBezierTo(c.dx + s * 0.12, c.dy + s * 0.08, c.dx - s * 0.02, c.dy + s * 0.18)
      ..close();
    canvas.drawPath(body, _fill);
    final wing = Path()
      ..moveTo(c.dx - s * 0.02, c.dy)
      ..quadraticBezierTo(c.dx - s * 0.28, c.dy - s * 0.28, c.dx - s * 0.32, c.dy + s * 0.02)
      ..quadraticBezierTo(c.dx - s * 0.1, c.dy + s * 0.05, c.dx - s * 0.02, c.dy)
      ..close();
    canvas.drawPath(wing, _soft);
    canvas.drawCircle(c + Offset(s * 0.18, -s * 0.08), s * 0.025, Paint()..color = Colors.white.withValues(alpha: 0.5));
  }

  void _paintTree(Canvas canvas, Offset c, double s) {
    // Copa em três discos.
    canvas.drawCircle(c + Offset(0, -s * 0.08), s * 0.22, _fill);
    canvas.drawCircle(c + Offset(-s * 0.16, s * 0.02), s * 0.16, _fill);
    canvas.drawCircle(c + Offset(s * 0.16, s * 0.02), s * 0.16, _fill);
    // Tronco.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, s * 0.28), width: s * 0.1, height: s * 0.28),
        Radius.circular(s * 0.04),
      ),
      _fill,
    );
  }

  void _paintFall(Canvas canvas, Offset c, double s) {
    // Fruto.
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(0, s * 0.04), width: s * 0.34, height: s * 0.4),
      _fill,
    );
    // Folha.
    final leaf = Path()
      ..moveTo(c.dx + s * 0.02, c.dy - s * 0.18)
      ..quadraticBezierTo(c.dx + s * 0.22, c.dy - s * 0.32, c.dx + s * 0.28, c.dy - s * 0.12)
      ..quadraticBezierTo(c.dx + s * 0.12, c.dy - s * 0.1, c.dx + s * 0.02, c.dy - s * 0.18)
      ..close();
    canvas.drawPath(leaf, _soft);
    // Cabo.
    canvas.drawLine(
      c + Offset(0, -s * 0.16),
      c + Offset(s * 0.02, -s * 0.28),
      Paint()
        ..color = const Color(0xFF2A2100).withValues(alpha: 0.9)
        ..strokeWidth = s * 0.035
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintTears(Canvas canvas, Offset c, double s) {
    final drop = Path()
      ..moveTo(c.dx, c.dy - s * 0.32)
      ..quadraticBezierTo(c.dx + s * 0.22, c.dy - s * 0.02, c.dx, c.dy + s * 0.32)
      ..quadraticBezierTo(c.dx - s * 0.22, c.dy - s * 0.02, c.dx, c.dy - s * 0.32)
      ..close();
    canvas.drawPath(drop, _fill);
    canvas.drawCircle(c + Offset(-s * 0.05, -s * 0.05), s * 0.05, Paint()..color = Colors.white.withValues(alpha: 0.35));
  }

  void _paintScales(Canvas canvas, Offset c, double s) {
    final stroke = Paint()
      ..color = const Color(0xFF2A2100).withValues(alpha: 0.9)
      ..strokeWidth = s * 0.04
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(c + Offset(0, -s * 0.28), c + Offset(0, s * 0.28), stroke);
    canvas.drawLine(c + Offset(-s * 0.32, -s * 0.1), c + Offset(s * 0.32, -s * 0.1), stroke);
    canvas.drawCircle(c + Offset(-s * 0.28, s * 0.08), s * 0.12, stroke);
    canvas.drawCircle(c + Offset(s * 0.28, s * 0.08), s * 0.12, stroke);
    canvas.drawCircle(c + Offset(0, -s * 0.28), s * 0.045, _fill);
  }

  void _paintWaves(Canvas canvas, Offset c, double s) {
    for (var i = 0; i < 3; i++) {
      final y = c.dy - s * 0.16 + i * s * 0.16;
      final path = Path()..moveTo(c.dx - s * 0.38, y);
      for (var x = -0.38; x <= 0.38; x += 0.12) {
        final wave = math.sin((x + 0.4) * math.pi * 2.2 + i) * s * 0.05;
        path.lineTo(c.dx + s * x, y + wave);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF2A2100).withValues(alpha: 0.85 - i * 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.05
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _paintTower(Canvas canvas, Offset c, double s) {
    final tiers = [
      Rect.fromCenter(center: c + Offset(0, s * 0.22), width: s * 0.5, height: s * 0.18),
      Rect.fromCenter(center: c + Offset(0, s * 0.02), width: s * 0.38, height: s * 0.18),
      Rect.fromCenter(center: c + Offset(0, -s * 0.18), width: s * 0.26, height: s * 0.18),
    ];
    for (final r in tiers) {
      canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(s * 0.03)), _fill);
    }
    canvas.drawCircle(c + Offset(0, -s * 0.32), s * 0.05, _fill);
  }

  void _paintStar(Canvas canvas, Offset c, double s) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 4 * math.pi / 5;
      final p = c + Offset(math.cos(a) * s * 0.36, math.sin(a) * s * 0.36);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, _fill);
    canvas.drawCircle(c, s * 0.08, Paint()..color = Colors.white.withValues(alpha: 0.35));
  }

  void _paintCrown(Canvas canvas, Offset c, double s) {
    final path = Path()
      ..moveTo(c.dx - s * 0.34, c.dy + s * 0.18)
      ..lineTo(c.dx - s * 0.28, c.dy - s * 0.18)
      ..lineTo(c.dx - s * 0.1, c.dy + s * 0.02)
      ..lineTo(c.dx, c.dy - s * 0.28)
      ..lineTo(c.dx + s * 0.1, c.dy + s * 0.02)
      ..lineTo(c.dx + s * 0.28, c.dy - s * 0.18)
      ..lineTo(c.dx + s * 0.34, c.dy + s * 0.18)
      ..close();
    canvas.drawPath(path, _fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, s * 0.26), width: s * 0.72, height: s * 0.1),
        Radius.circular(s * 0.04),
      ),
      _fill,
    );
  }

  void _paintChain(Canvas canvas, Offset c, double s) {
    final stroke = Paint()
      ..color = const Color(0xFF2A2100).withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.055;
    canvas.drawOval(Rect.fromCenter(center: c + Offset(-s * 0.12, -s * 0.08), width: s * 0.28, height: s * 0.38), stroke);
    canvas.drawOval(Rect.fromCenter(center: c + Offset(s * 0.12, s * 0.08), width: s * 0.28, height: s * 0.38), stroke);
  }

  void _paintFlame(Canvas canvas, Offset c, double s) {
    final flame = Path()
      ..moveTo(c.dx, c.dy + s * 0.34)
      ..quadraticBezierTo(c.dx - s * 0.32, c.dy + s * 0.05, c.dx - s * 0.08, c.dy - s * 0.18)
      ..quadraticBezierTo(c.dx - s * 0.02, c.dy - s * 0.02, c.dx + s * 0.04, c.dy - s * 0.12)
      ..quadraticBezierTo(c.dx + s * 0.08, c.dy - s * 0.34, c.dx + s * 0.02, c.dy - s * 0.38)
      ..quadraticBezierTo(c.dx + s * 0.34, c.dy - s * 0.05, c.dx, c.dy + s * 0.34)
      ..close();
    canvas.drawPath(flame, _fill);
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(0, s * 0.12), width: s * 0.14, height: s * 0.22),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
  }

  void _paintBook(Canvas canvas, Offset c, double s) {
    final left = RRect.fromRectAndRadius(
      Rect.fromLTWH(c.dx - s * 0.32, c.dy - s * 0.28, s * 0.3, s * 0.56),
      Radius.circular(s * 0.04),
    );
    final right = RRect.fromRectAndRadius(
      Rect.fromLTWH(c.dx + s * 0.02, c.dy - s * 0.28, s * 0.3, s * 0.56),
      Radius.circular(s * 0.04),
    );
    canvas.drawRRect(left, _fill);
    canvas.drawRRect(right, _soft);
    canvas.drawLine(
      c + Offset(0, -s * 0.28),
      c + Offset(0, s * 0.28),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = s * 0.03,
    );
  }

  void _paintSeed(Canvas canvas, Offset c, double s) {
    // Solo.
    canvas.drawLine(
      c + Offset(-s * 0.28, s * 0.22),
      c + Offset(s * 0.28, s * 0.22),
      Paint()
        ..color = const Color(0xFF2A2100).withValues(alpha: 0.7)
        ..strokeWidth = s * 0.04
        ..strokeCap = StrokeCap.round,
    );
    // Caule.
    canvas.drawLine(
      c + Offset(0, s * 0.22),
      c + Offset(0, -s * 0.05),
      Paint()
        ..color = const Color(0xFF2A2100).withValues(alpha: 0.9)
        ..strokeWidth = s * 0.04
        ..strokeCap = StrokeCap.round,
    );
    // Folhas.
    final left = Path()
      ..moveTo(c.dx, c.dy)
      ..quadraticBezierTo(c.dx - s * 0.28, c.dy - s * 0.05, c.dx - s * 0.18, c.dy - s * 0.28)
      ..quadraticBezierTo(c.dx - s * 0.02, c.dy - s * 0.12, c.dx, c.dy)
      ..close();
    final right = Path()
      ..moveTo(c.dx, c.dy)
      ..quadraticBezierTo(c.dx + s * 0.28, c.dy - s * 0.05, c.dx + s * 0.18, c.dy - s * 0.28)
      ..quadraticBezierTo(c.dx + s * 0.02, c.dy - s * 0.12, c.dx, c.dy)
      ..close();
    canvas.drawPath(left, _fill);
    canvas.drawPath(right, _soft);
  }

  void _paintPath(Canvas canvas, Offset c, double s) {
    final path = Path()
      ..moveTo(c.dx - s * 0.28, c.dy + s * 0.28)
      ..quadraticBezierTo(c.dx - s * 0.1, c.dy + s * 0.05, c.dx, c.dy - s * 0.05)
      ..quadraticBezierTo(c.dx + s * 0.12, c.dy - s * 0.18, c.dx + s * 0.08, c.dy - s * 0.32);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2A2100).withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.08
        ..strokeCap = StrokeCap.round,
    );
    // Marcos no caminho.
    for (final o in [Offset(-0.18, 0.18), Offset(0.0, -0.02), Offset(0.1, -0.22)]) {
      canvas.drawCircle(c + Offset(o.dx * s, o.dy * s), s * 0.05, _fill);
    }
  }

  void _paintDepths(Canvas canvas, Offset c, double s) {
    for (var i = 3; i >= 1; i--) {
      canvas.drawCircle(
        c,
        s * (0.12 * i),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.045
          ..color = const Color(0xFF2A2100).withValues(alpha: 0.35 + i * 0.15),
      );
    }
    canvas.drawCircle(c, s * 0.07, _fill);
    // Ondas profundas.
    canvas.drawArc(
      Rect.fromCircle(center: c + Offset(0, s * 0.08), radius: s * 0.32),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.035
        ..color = const Color(0xFF2A2100).withValues(alpha: 0.55),
    );
  }

  void _paintSpark(Canvas canvas, Offset c, double s) {
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final long = i.isEven;
      canvas.drawLine(
        c + Offset(math.cos(a) * s * 0.08, math.sin(a) * s * 0.08),
        c + Offset(math.cos(a) * s * (long ? 0.4 : 0.26), math.sin(a) * s * (long ? 0.4 : 0.26)),
        Paint()
          ..color = const Color(0xFF2A2100).withValues(alpha: long ? 0.9 : 0.55)
          ..strokeWidth = long ? s * 0.05 : s * 0.03
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(c, s * 0.1, _fill);
  }

  void _paintHeart(Canvas canvas, Offset c, double s) {
    final path = Path()
      ..moveTo(c.dx, c.dy + s * 0.3)
      ..cubicTo(c.dx - s * 0.42, c.dy + s * 0.02, c.dx - s * 0.38, c.dy - s * 0.28, c.dx, c.dy - s * 0.12)
      ..cubicTo(c.dx + s * 0.38, c.dy - s * 0.28, c.dx + s * 0.42, c.dy + s * 0.02, c.dx, c.dy + s * 0.3)
      ..close();
    canvas.drawPath(path, _fill);
  }

  void _paintMountain(Canvas canvas, Offset c, double s) {
    final back = Path()
      ..moveTo(c.dx - s * 0.38, c.dy + s * 0.28)
      ..lineTo(c.dx - s * 0.08, c.dy - s * 0.18)
      ..lineTo(c.dx + s * 0.2, c.dy + s * 0.28)
      ..close();
    final front = Path()
      ..moveTo(c.dx - s * 0.18, c.dy + s * 0.28)
      ..lineTo(c.dx + s * 0.08, c.dy - s * 0.32)
      ..lineTo(c.dx + s * 0.38, c.dy + s * 0.28)
      ..close();
    canvas.drawPath(back, _soft);
    canvas.drawPath(front, _fill);
    // Neve no pico.
    final snow = Path()
      ..moveTo(c.dx + s * 0.02, c.dy - s * 0.18)
      ..lineTo(c.dx + s * 0.08, c.dy - s * 0.32)
      ..lineTo(c.dx + s * 0.16, c.dy - s * 0.12)
      ..close();
    canvas.drawPath(snow, Paint()..color = Colors.white.withValues(alpha: 0.4));
  }

  void _paintCalendar(Canvas canvas, Offset c, double s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, s * 0.04), width: s * 0.56, height: s * 0.48),
        Radius.circular(s * 0.06),
      ),
      _fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, -s * 0.14), width: s * 0.56, height: s * 0.14),
        Radius.circular(s * 0.04),
      ),
      _soft,
    );
    for (final x in [-0.14, 0.0, 0.14]) {
      canvas.drawCircle(c + Offset(s * x, -s * 0.22), s * 0.03, Paint()..color = Colors.white.withValues(alpha: 0.55));
    }
  }

  void _paintGem(Canvas canvas, Offset c, double s) {
    final path = Path()
      ..moveTo(c.dx, c.dy - s * 0.34)
      ..lineTo(c.dx + s * 0.28, c.dy - s * 0.08)
      ..lineTo(c.dx, c.dy + s * 0.34)
      ..lineTo(c.dx - s * 0.28, c.dy - s * 0.08)
      ..close();
    canvas.drawPath(path, _fill);
    canvas.drawLine(
      c + Offset(-s * 0.14, -s * 0.08),
      c + Offset(s * 0.14, -s * 0.08),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..strokeWidth = s * 0.03,
    );
  }

  void _paintLamp(Canvas canvas, Offset c, double s) {
    canvas.drawOval(Rect.fromCenter(center: c + Offset(0, -s * 0.05), width: s * 0.36, height: s * 0.42), _fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, s * 0.28), width: s * 0.18, height: s * 0.14),
        Radius.circular(s * 0.04),
      ),
      _soft,
    );
    canvas.drawCircle(c + Offset(0, -s * 0.08), s * 0.08, Paint()..color = Colors.white.withValues(alpha: 0.35));
  }

  void _paintCheck(Canvas canvas, Offset c, double s) {
    final path = Path()
      ..moveTo(c.dx - s * 0.22, c.dy)
      ..lineTo(c.dx - s * 0.05, c.dy + s * 0.18)
      ..lineTo(c.dx + s * 0.26, c.dy - s * 0.2);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2A2100).withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.08
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter old) => old.glyph != glyph || old.color != color;
}
