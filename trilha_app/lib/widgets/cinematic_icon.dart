import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'icon_well.dart';

/// Símbolos da marca — silhuetas sólidas, sem emoji.
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
  echo,
  target,
  tune,
  lock,
  search,
  shield,
  mail,
  frost,
  share,
  qr,
  copy,
  podium,
  rise,
  demote,
  people,
  home,
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
      'O Início' => CinematicGlyph.dove,
      'Ensino e Sinais' => CinematicGlyph.scroll,
      'Cruz e Ressurreição' => CinematicGlyph.heart,
      'A Igreja nasce' => CinematicGlyph.flame,
      'Esperança final' => CinematicGlyph.crown,
      _ => CinematicGlyph.scroll,
    };
  }

  static CinematicGlyph forTrail(String slug) {
    return switch (slug) {
      'genesis-1-11' || 'genesis-12-50' => CinematicGlyph.book,
      'exodo' => CinematicGlyph.mountain,
      'evangelhos' => CinematicGlyph.heart,
      'atos' => CinematicGlyph.flame,
      'apocalipse' => CinematicGlyph.crown,
      'salmos' || 'oracao' => CinematicGlyph.dove,
      'proverbios' => CinematicGlyph.gem,
      'profetas' => CinematicGlyph.spark,
      'cartas-paulo' => CinematicGlyph.scroll,
      'vida-crista' => CinematicGlyph.seed,
      'historia-igreja' => CinematicGlyph.tower,
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
      'accuracy' => CinematicGlyph.target,
      'perfect' => CinematicGlyph.crown,
      'read' => CinematicGlyph.scroll,
      'bookmark' => CinematicGlyph.star,
      'seasonal' => CinematicGlyph.calendar,
      'memory' => CinematicGlyph.heart,
      'w_missions' => CinematicGlyph.calendar,
      'w_days' => CinematicGlyph.flame,
      'w_perfect' => CinematicGlyph.gem,
      _ => CinematicGlyph.spark,
    };
  }

  static Color paletteFor(CinematicGlyph glyph, {Color? accent}) {
    return switch (glyph) {
      CinematicGlyph.sun || CinematicGlyph.spark || CinematicGlyph.star => AppColors.accent,
      CinematicGlyph.cosmos || CinematicGlyph.depths => AppColors.cedarDeep,
      CinematicGlyph.tree || CinematicGlyph.seed => AppColors.cedar,
      CinematicGlyph.flood || CinematicGlyph.sea || CinematicGlyph.tears => AppColors.sky,
      CinematicGlyph.flame || CinematicGlyph.fall => AppColors.ember,
      CinematicGlyph.heart || CinematicGlyph.dove => AppColors.clay,
      CinematicGlyph.crown || CinematicGlyph.gem || CinematicGlyph.lamp => AppColors.accent,
      CinematicGlyph.chain || CinematicGlyph.mountain || CinematicGlyph.tower => AppColors.sand,
      CinematicGlyph.scales || CinematicGlyph.path || CinematicGlyph.target => AppColors.accent,
      CinematicGlyph.humanity => AppColors.accentSoft,
      CinematicGlyph.echo => AppColors.clay,
      CinematicGlyph.book || CinematicGlyph.scroll || CinematicGlyph.calendar || CinematicGlyph.check =>
        accent ?? AppColors.primaryLight,
      CinematicGlyph.tune || CinematicGlyph.share => accent ?? AppColors.accent,
      CinematicGlyph.lock => AppColors.textMutedDark,
      CinematicGlyph.search => AppColors.slate,
      CinematicGlyph.shield => AppColors.cedar,
      CinematicGlyph.mail => AppColors.clay,
      CinematicGlyph.frost => AppColors.sky,
      CinematicGlyph.qr || CinematicGlyph.copy => accent ?? AppColors.primaryLight,
      CinematicGlyph.podium || CinematicGlyph.rise => AppColors.accent,
      CinematicGlyph.demote => AppColors.error,
      CinematicGlyph.people => AppColors.clay,
      CinematicGlyph.home => AppColors.accent,
    };
  }
}

/// Ícone premium — silhuetas sólidas em poço circular limpo (sem selo dourado).
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
    this.glowing = false,
    this.animate = false,
  });

  factory CinematicIcon.mission(
    String title, {
    Key? key,
    bool isBoss = false,
    double size = 48,
    Color? accent,
    bool framed = true,
    bool glowing = false,
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
    final glyphSize = size * (framed ? 0.58 : 1);
    final child = CustomPaint(
      size: Size.square(glyphSize),
      painter: _GlyphPainter(glyph: glyph, color: color, premium: true),
    );

    if (!framed) {
      if (!glowing) {
        return SizedBox(
          width: size,
          height: size,
          child: Center(child: child),
        );
      }
      return SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.28),
                blurRadius: size * 0.32,
              ),
            ],
          ),
          child: Center(child: child),
        ),
      );
    }

    final well = IconWell(
      size: size,
      accent: color,
      glowing: glowing,
      child: child,
    );

    if (!animate) return well;
    return _BreathingAura(color: color, size: size, child: well);
  }
}

class _BreathingAura extends StatelessWidget {
  final Widget child;
  final Color color;
  final double size;

  const _BreathingAura({
    required this.child,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: size * 0.36,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Silhuetas sólidas — fill denso, legível em fundos escuros.
class _GlyphPainter extends CustomPainter {
  final CinematicGlyph glyph;
  final Color color;
  final bool premium;

  _GlyphPainter({
    required this.glyph,
    required this.color,
    this.premium = true,
  });

  late Color _ink;
  late Paint _solid;
  late Paint _soft;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = size.shortestSide;

    _ink = Color.lerp(color, Colors.white, color.computeLuminance() < 0.35 ? 0.45 : 0.15)!;
    _solid = Paint()..color = _ink;
    _soft = Paint()..color = _ink.withValues(alpha: 0.55);

    switch (glyph) {
      case CinematicGlyph.sun:
        _sun(canvas, c, s);
      case CinematicGlyph.cosmos:
        _cosmos(canvas, c, s);
      case CinematicGlyph.humanity:
        _humanity(canvas, c, s);
      case CinematicGlyph.dove:
        _dove(canvas, c, s);
      case CinematicGlyph.tree:
        _tree(canvas, c, s);
      case CinematicGlyph.fall:
        _fall(canvas, c, s);
      case CinematicGlyph.tears:
        _tears(canvas, c, s);
      case CinematicGlyph.scales:
        _scales(canvas, c, s);
      case CinematicGlyph.flood:
      case CinematicGlyph.sea:
        _waves(canvas, c, s);
      case CinematicGlyph.tower:
        _tower(canvas, c, s);
      case CinematicGlyph.star:
        _star(canvas, c, s);
      case CinematicGlyph.crown:
        _crown(canvas, c, s);
      case CinematicGlyph.chain:
        _chain(canvas, c, s);
      case CinematicGlyph.flame:
        _flame(canvas, c, s);
      case CinematicGlyph.book:
        _book(canvas, c, s);
      case CinematicGlyph.scroll:
        _scroll(canvas, c, s);
      case CinematicGlyph.seed:
        _seed(canvas, c, s);
      case CinematicGlyph.path:
        _path(canvas, c, s);
      case CinematicGlyph.depths:
        _depths(canvas, c, s);
      case CinematicGlyph.spark:
        _spark(canvas, c, s);
      case CinematicGlyph.heart:
        _heart(canvas, c, s);
      case CinematicGlyph.mountain:
        _mountain(canvas, c, s);
      case CinematicGlyph.calendar:
        _calendar(canvas, c, s);
      case CinematicGlyph.gem:
        _gem(canvas, c, s);
      case CinematicGlyph.lamp:
        _lamp(canvas, c, s);
      case CinematicGlyph.check:
        _check(canvas, c, s);
      case CinematicGlyph.echo:
        _echo(canvas, c, s);
      case CinematicGlyph.target:
        _target(canvas, c, s);
      case CinematicGlyph.tune:
        _tune(canvas, c, s);
      case CinematicGlyph.lock:
        _lock(canvas, c, s);
      case CinematicGlyph.search:
        _search(canvas, c, s);
      case CinematicGlyph.shield:
        _shield(canvas, c, s);
      case CinematicGlyph.mail:
        _mail(canvas, c, s);
      case CinematicGlyph.frost:
        _frost(canvas, c, s);
      case CinematicGlyph.share:
        _share(canvas, c, s);
      case CinematicGlyph.qr:
        _qr(canvas, c, s);
      case CinematicGlyph.copy:
        _copy(canvas, c, s);
      case CinematicGlyph.podium:
        _podium(canvas, c, s);
      case CinematicGlyph.rise:
        _arrow(canvas, c, s, up: true);
      case CinematicGlyph.demote:
        _arrow(canvas, c, s, up: false);
      case CinematicGlyph.people:
        _people(canvas, c, s);
      case CinematicGlyph.home:
        _home(canvas, c, s);
    }
  }

  Paint _stroke(double w, [double a = 1]) => Paint()
    ..color = _ink.withValues(alpha: a)
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _ring(Canvas canvas, Offset c, double outer, double inner) {
    final path = Path()
      ..addOval(Rect.fromCircle(center: c, radius: outer))
      ..addOval(Rect.fromCircle(center: c, radius: inner))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, _solid);
  }

  void _rect(Canvas canvas, Rect r, [double radius = 0]) {
    if (radius > 0) {
      canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(radius)), _solid);
    } else {
      canvas.drawRect(r, _solid);
    }
  }

  // —— Glifos ——

  void _sun(Canvas canvas, Offset c, double s) {
    canvas.drawCircle(c, s * 0.17, _solid);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 2;
      final len = s * (i.isEven ? 0.14 : 0.1);
      final inner = s * 0.22;
      final outer = inner + len;
      final p1 = c + Offset(math.cos(a) * inner, math.sin(a) * inner);
      final p2 = c + Offset(math.cos(a) * outer, math.sin(a) * outer);
      final perp = Offset(-math.sin(a), math.cos(a)) * s * 0.045;
      final ray = Path()
        ..moveTo(p1.dx + perp.dx, p1.dy + perp.dy)
        ..lineTo(p2.dx + perp.dx, p2.dy + perp.dy)
        ..lineTo(p2.dx - perp.dx, p2.dy - perp.dy)
        ..lineTo(p1.dx - perp.dx, p1.dy - perp.dy)
        ..close();
      canvas.drawPath(ray, _solid);
    }
  }

  void _cosmos(Canvas canvas, Offset c, double s) {
    for (final r in [0.38, 0.26, 0.14]) {
      _ring(canvas, c, s * r, s * (r - 0.04));
    }
    canvas.drawCircle(c, s * 0.06, _solid);
    for (var i = 0; i < 4; i++) {
      final a = i * 1.4 + 0.3;
      canvas.drawCircle(
        c + Offset(math.cos(a) * s * 0.32, math.sin(a) * s * 0.32),
        s * 0.035,
        _solid,
      );
    }
  }

  void _humanity(Canvas canvas, Offset c, double s) {
    canvas.drawCircle(c + Offset(0, -s * 0.18), s * 0.12, _solid);
    final body = Path()
      ..moveTo(c.dx - s * 0.28, c.dy + s * 0.34)
      ..quadraticBezierTo(c.dx - s * 0.22, c.dy + s * 0.04, c.dx, c.dy - s * 0.04)
      ..quadraticBezierTo(c.dx + s * 0.22, c.dy + s * 0.04, c.dx + s * 0.28, c.dy + s * 0.34)
      ..close();
    canvas.drawPath(body, _solid);
    final halo = Path()
      ..addArc(
        Rect.fromCircle(center: c + Offset(0, -s * 0.18), radius: s * 0.22),
        math.pi * 1.1,
        math.pi * 0.8,
      );
    canvas.drawPath(halo, _stroke(s * 0.07, 0.6));
  }

  void _dove(Canvas canvas, Offset c, double s) {
    final body = Path()
      ..moveTo(c.dx - s * 0.22, c.dy + s * 0.14)
      ..quadraticBezierTo(c.dx, c.dy - s * 0.1, c.dx + s * 0.3, c.dy - s * 0.12)
      ..quadraticBezierTo(c.dx + s * 0.2, c.dy + s * 0.14, c.dx - s * 0.08, c.dy + s * 0.18)
      ..close();
    canvas.drawPath(body, _solid);
    final wing = Path()
      ..moveTo(c.dx - s * 0.02, c.dy - s * 0.04)
      ..quadraticBezierTo(c.dx - s * 0.14, c.dy - s * 0.36, c.dx - s * 0.32, c.dy - s * 0.24)
      ..quadraticBezierTo(c.dx - s * 0.18, c.dy - s * 0.08, c.dx - s * 0.02, c.dy - s * 0.04)
      ..close();
    canvas.drawPath(wing, _soft);
    final beak = Path()
      ..moveTo(c.dx + s * 0.28, c.dy - s * 0.12)
      ..lineTo(c.dx + s * 0.4, c.dy - s * 0.2)
      ..lineTo(c.dx + s * 0.28, c.dy - s * 0.06)
      ..close();
    canvas.drawPath(beak, _solid);
  }

  void _tree(Canvas canvas, Offset c, double s) {
    _rect(
      canvas,
      Rect.fromCenter(center: c + Offset(0, s * 0.26), width: s * 0.12, height: s * 0.22),
      s * 0.03,
    );
    canvas.drawCircle(c + Offset(0, -s * 0.08), s * 0.24, _solid);
    canvas.drawCircle(c + Offset(-s * 0.18, s * 0.02), s * 0.14, _soft);
    canvas.drawCircle(c + Offset(s * 0.18, s * 0.02), s * 0.14, _soft);
  }

  void _fall(Canvas canvas, Offset c, double s) {
    final fruit = Path()
      ..addOval(Rect.fromCenter(center: c + Offset(0, s * 0.04), width: s * 0.36, height: s * 0.42));
    final bite = Path()
      ..addOval(Rect.fromCircle(center: c + Offset(s * 0.16, -s * 0.04), radius: s * 0.11));
    canvas.drawPath(Path.combine(PathOperation.difference, fruit, bite), _solid);
    _rect(
      canvas,
      Rect.fromCenter(center: c + Offset(s * 0.01, -s * 0.24), width: s * 0.05, height: s * 0.1),
      s * 0.02,
    );
  }

  void _tears(Canvas canvas, Offset c, double s) {
    final drop = Path()
      ..moveTo(c.dx, c.dy - s * 0.32)
      ..quadraticBezierTo(c.dx + s * 0.22, c.dy, c.dx, c.dy + s * 0.32)
      ..quadraticBezierTo(c.dx - s * 0.22, c.dy, c.dx, c.dy - s * 0.32)
      ..close();
    canvas.drawPath(drop, _solid);
  }

  void _scales(Canvas canvas, Offset c, double s) {
    _rect(
      canvas,
      Rect.fromCenter(center: c + Offset(0, -s * 0.1), width: s * 0.62, height: s * 0.08),
      s * 0.03,
    );
    _rect(
      canvas,
      Rect.fromCenter(center: c, width: s * 0.08, height: s * 0.58),
      s * 0.03,
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-s * 0.26, s * 0.12), width: s * 0.26, height: s * 0.2),
      _solid,
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(s * 0.26, s * 0.12), width: s * 0.26, height: s * 0.2),
      _solid,
    );
    canvas.drawCircle(c + Offset(0, -s * 0.3), s * 0.05, _solid);
  }

  void _waves(Canvas canvas, Offset c, double s) {
    for (var i = 0; i < 3; i++) {
      final y = c.dy - s * 0.14 + i * s * 0.14;
      final path = Path()..moveTo(c.dx - s * 0.38, y + s * 0.06);
      for (var x = -0.38; x <= 0.38; x += 0.08) {
        path.lineTo(c.dx + s * x, y + math.sin((x + 0.4) * math.pi * 2.2 + i) * s * 0.05);
      }
      path
        ..lineTo(c.dx + s * 0.38, y + s * 0.14)
        ..lineTo(c.dx - s * 0.38, y + s * 0.14)
        ..close();
      canvas.drawPath(path, i == 1 ? _solid : _soft);
    }
  }

  void _tower(Canvas canvas, Offset c, double s) {
    final tiers = [
      Rect.fromCenter(center: c + Offset(0, s * 0.2), width: s * 0.52, height: s * 0.18),
      Rect.fromCenter(center: c + Offset(0, s * 0.02), width: s * 0.38, height: s * 0.18),
      Rect.fromCenter(center: c + Offset(0, -s * 0.16), width: s * 0.26, height: s * 0.18),
    ];
    for (final r in tiers) {
      canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(s * 0.03)), _solid);
    }
    canvas.drawCircle(c + Offset(0, -s * 0.32), s * 0.05, _solid);
  }

  void _star(Canvas canvas, Offset c, double s) {
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
    canvas.drawPath(path, _solid);
  }

  void _crown(Canvas canvas, Offset c, double s) {
    final path = Path()
      ..moveTo(c.dx - s * 0.34, c.dy + s * 0.16)
      ..lineTo(c.dx - s * 0.3, c.dy - s * 0.2)
      ..lineTo(c.dx - s * 0.12, c.dy - s * 0.02)
      ..lineTo(c.dx, c.dy - s * 0.3)
      ..lineTo(c.dx + s * 0.12, c.dy - s * 0.02)
      ..lineTo(c.dx + s * 0.3, c.dy - s * 0.2)
      ..lineTo(c.dx + s * 0.34, c.dy + s * 0.16)
      ..close();
    canvas.drawPath(path, _solid);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, s * 0.24), width: s * 0.72, height: s * 0.12),
        Radius.circular(s * 0.04),
      ),
      _solid,
    );
    for (final x in [-0.3, 0.0, 0.3]) {
      canvas.drawCircle(c + Offset(s * x, -s * 0.2), s * 0.045, _soft);
    }
  }

  void _chain(Canvas canvas, Offset c, double s) {
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-s * 0.16, -s * 0.1), width: s * 0.28, height: s * 0.38),
      _stroke(s * 0.1),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(s * 0.16, s * 0.1), width: s * 0.28, height: s * 0.38),
      _stroke(s * 0.1),
    );
    canvas.drawCircle(c, s * 0.05, _solid);
  }

  void _flame(Canvas canvas, Offset c, double s) {
    final flame = Path()
      ..moveTo(c.dx, c.dy + s * 0.34)
      ..quadraticBezierTo(c.dx - s * 0.32, c.dy + s * 0.06, c.dx - s * 0.08, c.dy - s * 0.18)
      ..quadraticBezierTo(c.dx, c.dy - s * 0.04, c.dx + s * 0.06, c.dy - s * 0.12)
      ..quadraticBezierTo(c.dx + s * 0.1, c.dy - s * 0.38, c.dx + s * 0.02, c.dy - s * 0.4)
      ..quadraticBezierTo(c.dx + s * 0.34, c.dy - s * 0.04, c.dx, c.dy + s * 0.34)
      ..close();
    canvas.drawPath(flame, _solid);
    final inner = Path()
      ..moveTo(c.dx, c.dy + s * 0.22)
      ..quadraticBezierTo(c.dx - s * 0.12, c.dy + s * 0.04, c.dx, c.dy - s * 0.1)
      ..quadraticBezierTo(c.dx + s * 0.12, c.dy + s * 0.04, c.dx, c.dy + s * 0.22)
      ..close();
    canvas.drawPath(inner, _soft);
  }

  void _book(Canvas canvas, Offset c, double s) {
    final left = Path()
      ..moveTo(c.dx, c.dy - s * 0.24)
      ..quadraticBezierTo(c.dx - s * 0.2, c.dy - s * 0.32, c.dx - s * 0.38, c.dy - s * 0.24)
      ..lineTo(c.dx - s * 0.38, c.dy + s * 0.24)
      ..quadraticBezierTo(c.dx - s * 0.2, c.dy + s * 0.16, c.dx, c.dy + s * 0.28)
      ..close();
    final right = Path()
      ..moveTo(c.dx, c.dy - s * 0.24)
      ..quadraticBezierTo(c.dx + s * 0.2, c.dy - s * 0.32, c.dx + s * 0.38, c.dy - s * 0.24)
      ..lineTo(c.dx + s * 0.38, c.dy + s * 0.24)
      ..quadraticBezierTo(c.dx + s * 0.2, c.dy + s * 0.16, c.dx, c.dy + s * 0.28)
      ..close();
    canvas.drawPath(left, _solid);
    canvas.drawPath(right, _solid);
    _rect(
      canvas,
      Rect.fromCenter(center: c, width: s * 0.06, height: s * 0.54),
      s * 0.02,
    );
    for (var i = 0; i < 2; i++) {
      final y = c.dy - s * 0.06 + i * s * 0.12;
      _rect(
        canvas,
        Rect.fromCenter(center: Offset(c.dx - s * 0.18, y), width: s * 0.18, height: s * 0.04),
        s * 0.02,
      );
      _rect(
        canvas,
        Rect.fromCenter(center: Offset(c.dx + s * 0.18, y), width: s * 0.18, height: s * 0.04),
        s * 0.02,
      );
    }
  }

  void _scroll(Canvas canvas, Offset c, double s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: s * 0.48, height: s * 0.54),
        Radius.circular(s * 0.04),
      ),
      _solid,
    );
    for (final y in [-0.3, 0.3]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c + Offset(0, s * y), width: s * 0.6, height: s * 0.14),
          Radius.circular(s * 0.07),
        ),
        _solid,
      );
    }
    for (var i = 0; i < 3; i++) {
      final y = c.dy - s * 0.1 + i * s * 0.1;
      _rect(
        canvas,
        Rect.fromCenter(center: Offset(c.dx, y), width: s * 0.28, height: s * 0.04),
        s * 0.02,
      );
    }
  }

  void _seed(Canvas canvas, Offset c, double s) {
    final seed = Path()
      ..moveTo(c.dx, c.dy + s * 0.22)
      ..quadraticBezierTo(c.dx - s * 0.14, c.dy + s * 0.08, c.dx, c.dy - s * 0.08)
      ..quadraticBezierTo(c.dx + s * 0.14, c.dy + s * 0.08, c.dx, c.dy + s * 0.22)
      ..close();
    canvas.drawPath(seed, _solid);
    _rect(
      canvas,
      Rect.fromCenter(center: c + Offset(0, s * 0.24), width: s * 0.06, height: s * 0.12),
      s * 0.02,
    );
    final left = Path()
      ..moveTo(c.dx, c.dy - s * 0.02)
      ..quadraticBezierTo(c.dx - s * 0.3, c.dy - s * 0.06, c.dx - s * 0.2, c.dy - s * 0.3)
      ..quadraticBezierTo(c.dx - s * 0.1, c.dy - s * 0.14, c.dx, c.dy - s * 0.02)
      ..close();
    final right = Path()
      ..moveTo(c.dx, c.dy - s * 0.02)
      ..quadraticBezierTo(c.dx + s * 0.3, c.dy - s * 0.06, c.dx + s * 0.2, c.dy - s * 0.3)
      ..quadraticBezierTo(c.dx + s * 0.1, c.dy - s * 0.14, c.dx, c.dy - s * 0.02)
      ..close();
    canvas.drawPath(left, _solid);
    canvas.drawPath(right, _soft);
  }

  /// Caminho em S com marcos — lê como trilha, não como `/`.
  void _path(Canvas canvas, Offset c, double s) {
    final trail = Path()
      ..moveTo(c.dx - s * 0.3, c.dy + s * 0.3)
      ..quadraticBezierTo(
        c.dx - s * 0.34,
        c.dy + s * 0.02,
        c.dx - s * 0.02,
        c.dy - s * 0.02,
      )
      ..quadraticBezierTo(
        c.dx + s * 0.32,
        c.dy - s * 0.06,
        c.dx + s * 0.22,
        c.dy - s * 0.32,
      );
    canvas.drawPath(trail, _stroke(s * 0.1));
    // Marcos no caminho (início → meio → destino).
    for (final o in [
      Offset(-0.26, 0.26),
      Offset(-0.02, -0.02),
      Offset(0.2, -0.28),
    ]) {
      canvas.drawCircle(c + Offset(o.dx * s, o.dy * s), s * 0.065, _solid);
    }
  }

  void _people(Canvas canvas, Offset c, double s) {
    void figure(Offset o, double scale) {
      canvas.drawCircle(o + Offset(0, -s * 0.22 * scale), s * 0.1 * scale, _solid);
      final body = Path()
        ..moveTo(o.dx - s * 0.22 * scale, o.dy + s * 0.34 * scale)
        ..quadraticBezierTo(
          o.dx - s * 0.18 * scale,
          o.dy + s * 0.04 * scale,
          o.dx,
          o.dy - s * 0.06 * scale,
        )
        ..quadraticBezierTo(
          o.dx + s * 0.18 * scale,
          o.dy + s * 0.04 * scale,
          o.dx + s * 0.22 * scale,
          o.dy + s * 0.34 * scale,
        )
        ..close();
      canvas.drawPath(body, _solid);
    }

    figure(c + Offset(-s * 0.16, s * 0.02), 0.88);
    figure(c + Offset(s * 0.18, 0), 1.0);
  }

  void _home(Canvas canvas, Offset c, double s) {
    final roof = Path()
      ..moveTo(c.dx, c.dy - s * 0.36)
      ..lineTo(c.dx + s * 0.38, c.dy - s * 0.04)
      ..lineTo(c.dx - s * 0.38, c.dy - s * 0.04)
      ..close();
    canvas.drawPath(roof, _solid);
    _rect(
      canvas,
      Rect.fromCenter(center: c + Offset(0, s * 0.16), width: s * 0.72, height: s * 0.36),
      s * 0.04,
    );
    final door = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c + Offset(0, s * 0.2), width: s * 0.2, height: s * 0.28),
          Radius.circular(s * 0.03),
        ),
      );
    final wall = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c + Offset(0, s * 0.16), width: s * 0.72, height: s * 0.36),
          Radius.circular(s * 0.04),
        ),
      );
    canvas.drawPath(Path.combine(PathOperation.difference, wall, door), _soft);
  }

  void _depths(Canvas canvas, Offset c, double s) {
    for (var i = 0; i < 3; i++) {
      final inset = i * s * 0.1;
      final outer = s * 0.54 - inset;
      final inner = outer - s * 0.08;
      final rect = Rect.fromCenter(center: c + Offset(0, s * 0.1), width: outer, height: outer * 1.1);
      final path = Path()
        ..addArc(rect, math.pi * 1.05, math.pi * 0.9)
        ..arcTo(rect, math.pi * 1.95, -math.pi * 0.9, false)
        ..close();
      final hole = Path()..addOval(Rect.fromCenter(center: c + Offset(0, s * 0.1), width: inner, height: inner * 1.1));
      canvas.drawPath(Path.combine(PathOperation.difference, path, hole), i == 1 ? _solid : _soft);
    }
  }

  void _spark(Canvas canvas, Offset c, double s) {
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2 - math.pi / 4;
      final inner = s * 0.06;
      final outer = s * 0.38;
      final p1 = c + Offset(math.cos(a) * inner, math.sin(a) * inner);
      final p2 = c + Offset(math.cos(a) * outer, math.sin(a) * outer);
      final perp = Offset(-math.sin(a), math.cos(a)) * s * 0.08;
      final ray = Path()
        ..moveTo(p1.dx + perp.dx, p1.dy + perp.dy)
        ..lineTo(p2.dx + perp.dx, p2.dy + perp.dy)
        ..lineTo(p2.dx - perp.dx, p2.dy - perp.dy)
        ..lineTo(p1.dx - perp.dx, p1.dy - perp.dy)
        ..close();
      canvas.drawPath(ray, _solid);
    }
    canvas.drawCircle(c, s * 0.1, _solid);
  }

  void _heart(Canvas canvas, Offset c, double s) {
    final path = Path()
      ..moveTo(c.dx, c.dy + s * 0.32)
      ..cubicTo(c.dx - s * 0.42, c.dy + s * 0.04, c.dx - s * 0.38, c.dy - s * 0.3, c.dx, c.dy - s * 0.1)
      ..cubicTo(c.dx + s * 0.38, c.dy - s * 0.3, c.dx + s * 0.42, c.dy + s * 0.04, c.dx, c.dy + s * 0.32)
      ..close();
    canvas.drawPath(path, _solid);
  }

  void _mountain(Canvas canvas, Offset c, double s) {
    final back = Path()
      ..moveTo(c.dx - s * 0.38, c.dy + s * 0.3)
      ..lineTo(c.dx - s * 0.1, c.dy - s * 0.16)
      ..lineTo(c.dx + s * 0.2, c.dy + s * 0.3)
      ..close();
    final front = Path()
      ..moveTo(c.dx - s * 0.18, c.dy + s * 0.3)
      ..lineTo(c.dx + s * 0.1, c.dy - s * 0.32)
      ..lineTo(c.dx + s * 0.38, c.dy + s * 0.3)
      ..close();
    canvas.drawPath(back, _soft);
    canvas.drawPath(front, _solid);
  }

  void _calendar(Canvas canvas, Offset c, double s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, s * 0.04), width: s * 0.54, height: s * 0.48),
        Radius.circular(s * 0.06),
      ),
      _solid,
    );
    _rect(
      canvas,
      Rect.fromCenter(center: c + Offset(0, -s * 0.12), width: s * 0.54, height: s * 0.12),
      s * 0.03,
    );
    for (final x in [-0.14, 0.0, 0.14]) {
      _rect(
        canvas,
        Rect.fromCenter(center: c + Offset(s * x, -s * 0.24), width: s * 0.06, height: s * 0.1),
        s * 0.02,
      );
    }
    canvas.drawCircle(c + Offset(s * 0.1, s * 0.1), s * 0.05, _soft);
  }

  void _gem(Canvas canvas, Offset c, double s) {
    final path = Path()
      ..moveTo(c.dx, c.dy - s * 0.34)
      ..lineTo(c.dx + s * 0.28, c.dy - s * 0.06)
      ..lineTo(c.dx, c.dy + s * 0.34)
      ..lineTo(c.dx - s * 0.28, c.dy - s * 0.06)
      ..close();
    canvas.drawPath(path, _solid);
    final facet = Path()
      ..moveTo(c.dx - s * 0.16, c.dy - s * 0.06)
      ..lineTo(c.dx, c.dy - s * 0.22)
      ..lineTo(c.dx + s * 0.16, c.dy - s * 0.06)
      ..close();
    canvas.drawPath(facet, _soft);
  }

  void _lamp(Canvas canvas, Offset c, double s) {
    final bowl = Path()
      ..moveTo(c.dx - s * 0.3, c.dy + s * 0.08)
      ..quadraticBezierTo(c.dx - s * 0.28, c.dy + s * 0.28, c.dx, c.dy + s * 0.3)
      ..quadraticBezierTo(c.dx + s * 0.28, c.dy + s * 0.28, c.dx + s * 0.34, c.dy + s * 0.04)
      ..quadraticBezierTo(c.dx + s * 0.14, c.dy + s * 0.1, c.dx - s * 0.3, c.dy + s * 0.08)
      ..close();
    canvas.drawPath(bowl, _solid);
    final flame = Path()
      ..moveTo(c.dx + s * 0.3, c.dy + s * 0.02)
      ..quadraticBezierTo(c.dx + s * 0.22, c.dy - s * 0.2, c.dx + s * 0.3, c.dy - s * 0.32)
      ..quadraticBezierTo(c.dx + s * 0.36, c.dy - s * 0.16, c.dx + s * 0.3, c.dy + s * 0.02)
      ..close();
    canvas.drawPath(flame, _solid);
    _rect(
      canvas,
      Rect.fromCenter(center: c + Offset(-s * 0.08, s * 0.3), width: s * 0.16, height: s * 0.06),
      s * 0.02,
    );
  }

  void _check(Canvas canvas, Offset c, double s) {
    final path = Path()
      ..moveTo(c.dx - s * 0.24, c.dy)
      ..lineTo(c.dx - s * 0.04, c.dy + s * 0.2)
      ..lineTo(c.dx + s * 0.28, c.dy - s * 0.22);
    canvas.drawPath(path, _stroke(s * 0.1));
  }

  void _echo(Canvas canvas, Offset c, double s) {
    for (final r in [0.14, 0.24, 0.34]) {
      _ring(canvas, c, s * r, s * (r - 0.05));
    }
    canvas.drawCircle(c, s * 0.07, _solid);
  }

  void _target(Canvas canvas, Offset c, double s) {
    _ring(canvas, c, s * 0.34, s * 0.24);
    _ring(canvas, c, s * 0.2, s * 0.1);
    canvas.drawCircle(c, s * 0.08, _solid);
  }

  void _tune(Canvas canvas, Offset c, double s) {
    final rows = [-0.2, 0.0, 0.2];
    final knobs = [-0.16, 0.18, -0.04];
    for (var i = 0; i < 3; i++) {
      final y = c.dy + s * rows[i];
      _rect(
        canvas,
        Rect.fromCenter(center: Offset(c.dx, y), width: s * 0.62, height: s * 0.08),
        s * 0.03,
      );
      canvas.drawCircle(c + Offset(s * knobs[i], s * rows[i]), s * 0.09, _solid);
    }
  }

  void _lock(Canvas canvas, Offset c, double s) {
    final shackle = Path()
      ..addArc(
        Rect.fromCenter(center: c + Offset(0, -s * 0.04), width: s * 0.32, height: s * 0.36),
        math.pi,
        math.pi,
      );
    canvas.drawPath(shackle, _stroke(s * 0.09));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, s * 0.12), width: s * 0.48, height: s * 0.36),
        Radius.circular(s * 0.06),
      ),
      _solid,
    );
    canvas.drawCircle(c + Offset(0, s * 0.12), s * 0.05, _soft);
  }

  void _search(Canvas canvas, Offset c, double s) {
    _ring(canvas, c + Offset(-s * 0.06, -s * 0.06), s * 0.22, s * 0.1);
    final handle = Path()
      ..moveTo(c.dx + s * 0.1, c.dy + s * 0.1)
      ..lineTo(c.dx + s * 0.32, c.dy + s * 0.32)
      ..lineTo(c.dx + s * 0.24, c.dy + s * 0.4)
      ..lineTo(c.dx + s * 0.02, c.dy + s * 0.18)
      ..close();
    canvas.drawPath(handle, _solid);
  }

  void _shield(Canvas canvas, Offset c, double s) {
    final path = Path()
      ..moveTo(c.dx, c.dy - s * 0.36)
      ..quadraticBezierTo(c.dx + s * 0.34, c.dy - s * 0.28, c.dx + s * 0.32, c.dy)
      ..quadraticBezierTo(c.dx + s * 0.28, c.dy + s * 0.22, c.dx, c.dy + s * 0.36)
      ..quadraticBezierTo(c.dx - s * 0.28, c.dy + s * 0.22, c.dx - s * 0.32, c.dy)
      ..quadraticBezierTo(c.dx - s * 0.34, c.dy - s * 0.28, c.dx, c.dy - s * 0.36)
      ..close();
    canvas.drawPath(path, _solid);
    final cross = Path()
      ..moveTo(c.dx, c.dy - s * 0.16)
      ..lineTo(c.dx, c.dy + s * 0.18)
      ..moveTo(c.dx - s * 0.12, c.dy - s * 0.02)
      ..lineTo(c.dx + s * 0.12, c.dy - s * 0.02);
    canvas.drawPath(cross, _stroke(s * 0.07, 0.55));
  }

  void _mail(Canvas canvas, Offset c, double s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: s * 0.62, height: s * 0.44),
        Radius.circular(s * 0.06),
      ),
      _solid,
    );
    final flap = Path()
      ..moveTo(c.dx - s * 0.3, c.dy - s * 0.14)
      ..lineTo(c.dx, c.dy + s * 0.08)
      ..lineTo(c.dx + s * 0.3, c.dy - s * 0.14)
      ..close();
    canvas.drawPath(flap, _soft);
  }

  void _frost(Canvas canvas, Offset c, double s) {
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      final end = c + Offset(math.cos(a) * s * 0.36, math.sin(a) * s * 0.36);
      _rect(
        canvas,
        Rect.fromCenter(
          center: c + Offset(math.cos(a) * s * 0.18, math.sin(a) * s * 0.18),
          width: s * 0.08,
          height: s * 0.36,
        ),
        s * 0.02,
      );
      final mid = c + Offset(math.cos(a) * s * 0.18, math.sin(a) * s * 0.18);
      final p = a + math.pi / 2;
      final branch = Path()
        ..moveTo(mid.dx + math.cos(p) * s * 0.08, mid.dy + math.sin(p) * s * 0.08)
        ..lineTo(end.dx, end.dy)
        ..lineTo(mid.dx - math.cos(p) * s * 0.08, mid.dy - math.sin(p) * s * 0.08)
        ..close();
      canvas.drawPath(branch, _solid);
    }
    canvas.drawCircle(c, s * 0.06, _solid);
  }

  void _share(Canvas canvas, Offset c, double s) {
    final nodes = [Offset(-0.18, -0.2), Offset(0.2, 0.0), Offset(-0.18, 0.2)];
    _rect(
      canvas,
      Rect.fromCenter(
        center: c + Offset(nodes[0].dx * s, nodes[0].dy * s),
        width: s * 0.14,
        height: s * 0.14,
      ),
      s * 0.03,
    );
    _rect(
      canvas,
      Rect.fromCenter(
        center: c + Offset(nodes[1].dx * s, nodes[1].dy * s),
        width: s * 0.14,
        height: s * 0.14,
      ),
      s * 0.03,
    );
    _rect(
      canvas,
      Rect.fromCenter(
        center: c + Offset(nodes[2].dx * s, nodes[2].dy * s),
        width: s * 0.14,
        height: s * 0.14,
      ),
      s * 0.03,
    );
    canvas.drawLine(
      c + Offset(nodes[0].dx * s, nodes[0].dy * s),
      c + Offset(nodes[1].dx * s, nodes[1].dy * s),
      _stroke(s * 0.07),
    );
    canvas.drawLine(
      c + Offset(nodes[2].dx * s, nodes[2].dy * s),
      c + Offset(nodes[1].dx * s, nodes[1].dy * s),
      _stroke(s * 0.07),
    );
  }

  void _qr(Canvas canvas, Offset c, double s) {
    void corner(Offset o) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c + o, width: s * 0.22, height: s * 0.22),
          Radius.circular(s * 0.03),
        ),
        _solid,
      );
      _rect(
        canvas,
        Rect.fromCenter(center: c + o, width: s * 0.1, height: s * 0.1),
        s * 0.02,
      );
    }

    corner(Offset(-s * 0.15, -s * 0.15));
    corner(Offset(s * 0.15, -s * 0.15));
    corner(Offset(-s * 0.15, s * 0.15));
    for (final o in [Offset(0.08, 0.08), Offset(0.18, 0.08), Offset(0.08, 0.18), Offset(0.18, 0.18)]) {
      _rect(
        canvas,
        Rect.fromCenter(center: c + Offset(o.dx * s, o.dy * s), width: s * 0.07, height: s * 0.07),
        s * 0.015,
      );
    }
  }

  void _copy(Canvas canvas, Offset c, double s) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(s * 0.06, s * 0.06), width: s * 0.36, height: s * 0.44),
        Radius.circular(s * 0.05),
      ),
      _soft,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(-s * 0.06, -s * 0.06), width: s * 0.36, height: s * 0.44),
        Radius.circular(s * 0.05),
      ),
      _solid,
    );
  }

  void _podium(Canvas canvas, Offset c, double s) {
    final steps = [
      (Offset(-0.2, 0.12), 0.28, 0.34),
      (Offset(0.0, 0.0), 0.28, 0.52),
      (Offset(0.2, 0.16), 0.28, 0.3),
    ];
    for (var i = 0; i < steps.length; i++) {
      final (o, ww, h) = steps[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c + Offset(o.dx * s, o.dy * s), width: s * ww, height: s * h),
          Radius.circular(s * 0.03),
        ),
        i == 1 ? _solid : _soft,
      );
    }
  }

  void _arrow(Canvas canvas, Offset c, double s, {required bool up}) {
    final dir = up ? -1.0 : 1.0;
    final path = Path()
      ..moveTo(c.dx, c.dy + dir * s * 0.28)
      ..lineTo(c.dx - s * 0.18, c.dy + dir * s * 0.04)
      ..lineTo(c.dx - s * 0.06, c.dy + dir * s * 0.04)
      ..lineTo(c.dx - s * 0.06, c.dy - dir * s * 0.28)
      ..lineTo(c.dx + s * 0.06, c.dy - dir * s * 0.28)
      ..lineTo(c.dx + s * 0.06, c.dy + dir * s * 0.04)
      ..lineTo(c.dx + s * 0.18, c.dy + dir * s * 0.04)
      ..close();
    canvas.drawPath(path, _solid);
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter old) =>
      old.glyph != glyph || old.color != color || old.premium != premium;
}
