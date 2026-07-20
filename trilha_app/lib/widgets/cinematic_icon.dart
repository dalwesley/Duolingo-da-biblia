import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'icon_well.dart';

/// Símbolos da marca — line art premium, sem emoji.
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
      'bookmark' => CinematicGlyph.heart,
      'seasonal' => CinematicGlyph.calendar,
      'memory' => CinematicGlyph.lamp,
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

/// Ícone premium — line art em poço circular limpo (sem selo dourado).
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
    final glyphSize = size * (framed ? 0.52 : 1);
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

/// Line art premium — traço fino, fill suave, proporção editorial.
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
  late Color _fill;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = size.shortestSide;

    final dark = color.computeLuminance() < 0.22;
    _ink = dark ? color : Color.lerp(color, Colors.white, 0.18)!;
    _fill = dark
        ? color.withValues(alpha: 0.22)
        : Color.lerp(color, Colors.white, 0.55)!.withValues(alpha: 0.28);

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

  Paint get _fillPaint => Paint()..color = _fill;

  Paint get _inkFill => Paint()..color = _ink.withValues(alpha: 0.92);

  // —— Glifos ——

  void _sun(Canvas canvas, Offset c, double s) {
    final w = s * 0.055;
    canvas.drawCircle(c, s * 0.16, _fillPaint);
    canvas.drawCircle(c, s * 0.16, _stroke(w));
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 2;
      final inner = s * 0.24;
      final outer = s * (i.isEven ? 0.42 : 0.36);
      canvas.drawLine(
        c + Offset(math.cos(a) * inner, math.sin(a) * inner),
        c + Offset(math.cos(a) * outer, math.sin(a) * outer),
        _stroke(i.isEven ? w : w * 0.75, i.isEven ? 1 : 0.7),
      );
    }
  }

  void _cosmos(Canvas canvas, Offset c, double s) {
    final w = s * 0.045;
    for (final r in [0.38, 0.26, 0.14]) {
      canvas.drawCircle(c, s * r, _stroke(w, 0.85 - (0.38 - r)));
    }
    canvas.drawCircle(c, s * 0.055, _inkFill);
    for (var i = 0; i < 4; i++) {
      final a = i * 1.4 + 0.3;
      canvas.drawCircle(
        c + Offset(math.cos(a) * s * 0.32, math.sin(a) * s * 0.32),
        s * 0.028,
        _inkFill,
      );
    }
  }

  void _humanity(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    canvas.drawCircle(c + Offset(0, -s * 0.16), s * 0.11, _stroke(w));
    final body = Path()
      ..moveTo(c.dx - s * 0.26, c.dy + s * 0.34)
      ..quadraticBezierTo(c.dx - s * 0.2, c.dy + s * 0.02, c.dx, c.dy - s * 0.02)
      ..quadraticBezierTo(c.dx + s * 0.2, c.dy + s * 0.02, c.dx + s * 0.26, c.dy + s * 0.34);
    canvas.drawPath(body, _stroke(w));
    canvas.drawArc(
      Rect.fromCircle(center: c + Offset(0, -s * 0.16), radius: s * 0.2),
      math.pi * 1.15,
      math.pi * 0.7,
      false,
      _stroke(w * 0.7, 0.55),
    );
  }

  void _dove(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    final body = Path()
      ..moveTo(c.dx - s * 0.2, c.dy + s * 0.12)
      ..quadraticBezierTo(c.dx, c.dy - s * 0.08, c.dx + s * 0.28, c.dy - s * 0.1)
      ..quadraticBezierTo(c.dx + s * 0.18, c.dy + s * 0.12, c.dx - s * 0.06, c.dy + s * 0.16)
      ..close();
    canvas.drawPath(body, _fillPaint);
    canvas.drawPath(body, _stroke(w));
    final wing = Path()
      ..moveTo(c.dx, c.dy - s * 0.02)
      ..quadraticBezierTo(c.dx - s * 0.12, c.dy - s * 0.34, c.dx - s * 0.3, c.dy - s * 0.22);
    canvas.drawPath(wing, _stroke(w));
    canvas.drawLine(
      c + Offset(s * 0.28, -s * 0.1),
      c + Offset(s * 0.38, -s * 0.2),
      _stroke(w * 0.8, 0.75),
    );
  }

  void _tree(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    canvas.drawLine(c + Offset(0, s * 0.08), c + Offset(0, s * 0.36), _stroke(w * 1.2));
    canvas.drawCircle(c + Offset(0, -s * 0.06), s * 0.22, _fillPaint);
    canvas.drawCircle(c + Offset(0, -s * 0.06), s * 0.22, _stroke(w));
    canvas.drawCircle(c + Offset(-s * 0.16, s * 0.04), s * 0.12, _stroke(w * 0.85, 0.7));
    canvas.drawCircle(c + Offset(s * 0.16, s * 0.04), s * 0.12, _stroke(w * 0.85, 0.7));
  }

  void _fall(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    final fruit = Path()
      ..addOval(Rect.fromCenter(center: c + Offset(0, s * 0.04), width: s * 0.34, height: s * 0.4));
    final bite = Path()
      ..addOval(Rect.fromCircle(center: c + Offset(s * 0.16, -s * 0.04), radius: s * 0.1));
    final cut = Path.combine(PathOperation.difference, fruit, bite);
    canvas.drawPath(cut, _fillPaint);
    canvas.drawPath(cut, _stroke(w));
    canvas.drawLine(c + Offset(0, -s * 0.16), c + Offset(s * 0.02, -s * 0.3), _stroke(w * 0.8));
  }

  void _tears(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    final drop = Path()
      ..moveTo(c.dx, c.dy - s * 0.32)
      ..quadraticBezierTo(c.dx + s * 0.2, c.dy, c.dx, c.dy + s * 0.32)
      ..quadraticBezierTo(c.dx - s * 0.2, c.dy, c.dx, c.dy - s * 0.32)
      ..close();
    canvas.drawPath(drop, _fillPaint);
    canvas.drawPath(drop, _stroke(w));
  }

  void _scales(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    canvas.drawLine(c + Offset(0, -s * 0.3), c + Offset(0, s * 0.3), _stroke(w));
    canvas.drawLine(c + Offset(-s * 0.3, -s * 0.1), c + Offset(s * 0.3, -s * 0.1), _stroke(w));
    canvas.drawCircle(c + Offset(-s * 0.26, s * 0.08), s * 0.11, _stroke(w));
    canvas.drawCircle(c + Offset(s * 0.26, s * 0.08), s * 0.11, _stroke(w));
    canvas.drawCircle(c + Offset(0, -s * 0.3), s * 0.04, _inkFill);
  }

  void _waves(Canvas canvas, Offset c, double s) {
    final w = s * 0.055;
    for (var i = 0; i < 3; i++) {
      final y = c.dy - s * 0.16 + i * s * 0.16;
      final path = Path()..moveTo(c.dx - s * 0.36, y);
      for (var x = -0.36; x <= 0.36; x += 0.12) {
        path.lineTo(c.dx + s * x, y + math.sin((x + 0.4) * math.pi * 2.2 + i) * s * 0.045);
      }
      canvas.drawPath(path, _stroke(w, 0.95 - i * 0.2));
    }
  }

  void _tower(Canvas canvas, Offset c, double s) {
    final w = s * 0.045;
    final tiers = [
      Rect.fromCenter(center: c + Offset(0, s * 0.2), width: s * 0.5, height: s * 0.16),
      Rect.fromCenter(center: c + Offset(0, s * 0.02), width: s * 0.36, height: s * 0.16),
      Rect.fromCenter(center: c + Offset(0, -s * 0.16), width: s * 0.24, height: s * 0.16),
    ];
    for (final r in tiers) {
      canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(s * 0.025)), _fillPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(s * 0.025)), _stroke(w));
    }
    canvas.drawCircle(c + Offset(0, -s * 0.3), s * 0.04, _inkFill);
  }

  void _star(Canvas canvas, Offset c, double s) {
    final w = s * 0.045;
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
    canvas.drawPath(path, _fillPaint);
    canvas.drawPath(path, _stroke(w));
  }

  void _crown(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    final path = Path()
      ..moveTo(c.dx - s * 0.32, c.dy + s * 0.14)
      ..lineTo(c.dx - s * 0.28, c.dy - s * 0.18)
      ..lineTo(c.dx - s * 0.1, c.dy)
      ..lineTo(c.dx, c.dy - s * 0.28)
      ..lineTo(c.dx + s * 0.1, c.dy)
      ..lineTo(c.dx + s * 0.28, c.dy - s * 0.18)
      ..lineTo(c.dx + s * 0.32, c.dy + s * 0.14)
      ..close();
    canvas.drawPath(path, _fillPaint);
    canvas.drawPath(path, _stroke(w));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, s * 0.22), width: s * 0.68, height: s * 0.1),
        Radius.circular(s * 0.04),
      ),
      _stroke(w),
    );
  }

  void _chain(Canvas canvas, Offset c, double s) {
    final w = s * 0.055;
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-s * 0.16, -s * 0.1), width: s * 0.24, height: s * 0.34),
      _stroke(w),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(s * 0.16, s * 0.1), width: s * 0.24, height: s * 0.34),
      _stroke(w),
    );
    canvas.drawCircle(c, s * 0.03, _inkFill);
  }

  void _flame(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    final flame = Path()
      ..moveTo(c.dx, c.dy + s * 0.32)
      ..quadraticBezierTo(c.dx - s * 0.3, c.dy + s * 0.05, c.dx - s * 0.06, c.dy - s * 0.16)
      ..quadraticBezierTo(c.dx, c.dy - s * 0.02, c.dx + s * 0.04, c.dy - s * 0.1)
      ..quadraticBezierTo(c.dx + s * 0.08, c.dy - s * 0.34, c.dx + s * 0.02, c.dy - s * 0.36)
      ..quadraticBezierTo(c.dx + s * 0.32, c.dy - s * 0.02, c.dx, c.dy + s * 0.32)
      ..close();
    canvas.drawPath(flame, _fillPaint);
    canvas.drawPath(flame, _stroke(w));
    final inner = Path()
      ..moveTo(c.dx, c.dy + s * 0.2)
      ..quadraticBezierTo(c.dx - s * 0.1, c.dy + s * 0.04, c.dx, c.dy - s * 0.08)
      ..quadraticBezierTo(c.dx + s * 0.1, c.dy + s * 0.04, c.dx, c.dy + s * 0.2)
      ..close();
    canvas.drawPath(inner, _stroke(w * 0.7, 0.55));
  }

  void _book(Canvas canvas, Offset c, double s) {
    final w = s * 0.045;
    final left = Path()
      ..moveTo(c.dx, c.dy - s * 0.22)
      ..quadraticBezierTo(c.dx - s * 0.18, c.dy - s * 0.3, c.dx - s * 0.36, c.dy - s * 0.22)
      ..lineTo(c.dx - s * 0.36, c.dy + s * 0.22)
      ..quadraticBezierTo(c.dx - s * 0.18, c.dy + s * 0.14, c.dx, c.dy + s * 0.26)
      ..close();
    final right = Path()
      ..moveTo(c.dx, c.dy - s * 0.22)
      ..quadraticBezierTo(c.dx + s * 0.18, c.dy - s * 0.3, c.dx + s * 0.36, c.dy - s * 0.22)
      ..lineTo(c.dx + s * 0.36, c.dy + s * 0.22)
      ..quadraticBezierTo(c.dx + s * 0.18, c.dy + s * 0.14, c.dx, c.dy + s * 0.26)
      ..close();
    canvas.drawPath(left, _fillPaint);
    canvas.drawPath(right, _fillPaint);
    canvas.drawPath(left, _stroke(w));
    canvas.drawPath(right, _stroke(w));
    canvas.drawLine(c + Offset(0, -s * 0.22), c + Offset(0, s * 0.26), _stroke(w * 0.9));
    for (var i = 0; i < 2; i++) {
      final y = c.dy - s * 0.06 + i * s * 0.1;
      canvas.drawLine(Offset(c.dx - s * 0.26, y), Offset(c.dx - s * 0.08, y), _stroke(w * 0.55, 0.4));
      canvas.drawLine(Offset(c.dx + s * 0.08, y), Offset(c.dx + s * 0.26, y), _stroke(w * 0.55, 0.4));
    }
  }

  void _scroll(Canvas canvas, Offset c, double s) {
    final w = s * 0.045;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: s * 0.46, height: s * 0.52),
        Radius.circular(s * 0.03),
      ),
      _fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: s * 0.46, height: s * 0.52),
        Radius.circular(s * 0.03),
      ),
      _stroke(w),
    );
    for (final y in [-0.28, 0.28]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c + Offset(0, s * y), width: s * 0.58, height: s * 0.12),
          Radius.circular(s * 0.06),
        ),
        _stroke(w),
      );
    }
    for (var i = 0; i < 3; i++) {
      final y = c.dy - s * 0.1 + i * s * 0.1;
      canvas.drawLine(Offset(c.dx - s * 0.14, y), Offset(c.dx + s * 0.14, y), _stroke(w * 0.55, 0.4));
    }
  }

  void _seed(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    canvas.drawArc(
      Rect.fromCenter(center: c + Offset(0, s * 0.22), width: s * 0.56, height: s * 0.2),
      math.pi * 1.05,
      math.pi * 0.9,
      false,
      _stroke(w * 0.8, 0.55),
    );
    canvas.drawLine(c + Offset(0, s * 0.18), c + Offset(0, -s * 0.02), _stroke(w));
    final left = Path()
      ..moveTo(c.dx, c.dy)
      ..quadraticBezierTo(c.dx - s * 0.28, c.dy - s * 0.04, c.dx - s * 0.18, c.dy - s * 0.28);
    final right = Path()
      ..moveTo(c.dx, c.dy)
      ..quadraticBezierTo(c.dx + s * 0.28, c.dy - s * 0.04, c.dx + s * 0.18, c.dy - s * 0.28);
    canvas.drawPath(left, _stroke(w));
    canvas.drawPath(right, _stroke(w));
  }

  void _path(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    // Poste de trilha — geometria clara em tamanho de menu
    final postTop = c + Offset(0, -s * 0.08);
    final postBottom = c + Offset(0, s * 0.34);
    canvas.drawLine(postTop, postBottom, _stroke(w * 1.25));

    // Placa esquerda
    final left = Path()
      ..moveTo(c.dx - s * 0.02, c.dy - s * 0.28)
      ..lineTo(c.dx - s * 0.34, c.dy - s * 0.28)
      ..lineTo(c.dx - s * 0.42, c.dy - s * 0.16)
      ..lineTo(c.dx - s * 0.34, c.dy - s * 0.04)
      ..lineTo(c.dx - s * 0.02, c.dy - s * 0.04)
      ..close();
    // Placa direita (um pouco mais baixa)
    final right = Path()
      ..moveTo(c.dx + s * 0.02, c.dy - s * 0.1)
      ..lineTo(c.dx + s * 0.32, c.dy - s * 0.1)
      ..lineTo(c.dx + s * 0.4, c.dy + s * 0.02)
      ..lineTo(c.dx + s * 0.32, c.dy + s * 0.14)
      ..lineTo(c.dx + s * 0.02, c.dy + s * 0.14)
      ..close();

    canvas.drawPath(left, _fillPaint);
    canvas.drawPath(right, _fillPaint);
    canvas.drawPath(left, _stroke(w));
    canvas.drawPath(right, _stroke(w));

    // Base do poste
    canvas.drawLine(
      c + Offset(-s * 0.12, s * 0.34),
      c + Offset(s * 0.12, s * 0.34),
      _stroke(w),
    );
  }

  void _people(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    void figure(Offset o, double scale) {
      final head = o + Offset(0, -s * 0.2 * scale);
      canvas.drawCircle(head, s * 0.09 * scale, _fillPaint);
      canvas.drawCircle(head, s * 0.09 * scale, _stroke(w));
      final body = Path()
        ..moveTo(o.dx - s * 0.2 * scale, o.dy + s * 0.32 * scale)
        ..quadraticBezierTo(
          o.dx - s * 0.16 * scale,
          o.dy + s * 0.02 * scale,
          o.dx,
          o.dy - s * 0.04 * scale,
        )
        ..quadraticBezierTo(
          o.dx + s * 0.16 * scale,
          o.dy + s * 0.02 * scale,
          o.dx + s * 0.2 * scale,
          o.dy + s * 0.32 * scale,
        );
      canvas.drawPath(body, _stroke(w));
    }

    // Dois caminhantes — companhia
    figure(c + Offset(-s * 0.16, s * 0.02), 0.88);
    figure(c + Offset(s * 0.18, 0), 1.0);
  }

  void _home(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    final house = Path()
      ..moveTo(c.dx, c.dy - s * 0.34)
      ..lineTo(c.dx + s * 0.36, c.dy - s * 0.06)
      ..lineTo(c.dx + s * 0.36, c.dy + s * 0.32)
      ..lineTo(c.dx - s * 0.36, c.dy + s * 0.32)
      ..lineTo(c.dx - s * 0.36, c.dy - s * 0.06)
      ..close();
    canvas.drawPath(house, _fillPaint);
    canvas.drawPath(house, _stroke(w));
    // Porta
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c + Offset(0, s * 0.18),
          width: s * 0.18,
          height: s * 0.28,
        ),
        Radius.circular(s * 0.02),
      ),
      _stroke(w * 0.9),
    );
  }

  void _depths(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    for (var i = 0; i < 3; i++) {
      final inset = i * s * 0.1;
      canvas.drawArc(
        Rect.fromCenter(
          center: c + Offset(0, s * 0.08),
          width: s * 0.52 - inset,
          height: s * 0.58 - inset,
        ),
        math.pi * 1.05,
        math.pi * 0.9,
        false,
        _stroke(w, 0.85 - i * 0.2),
      );
    }
  }

  void _spark(Canvas canvas, Offset c, double s) {
    final w = s * 0.055;
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final long = i.isEven;
      canvas.drawLine(
        c + Offset(math.cos(a) * s * 0.08, math.sin(a) * s * 0.08),
        c + Offset(math.cos(a) * s * (long ? 0.4 : 0.24), math.sin(a) * s * (long ? 0.4 : 0.24)),
        _stroke(long ? w : w * 0.7, long ? 1 : 0.6),
      );
    }
    canvas.drawCircle(c, s * 0.08, _fillPaint);
    canvas.drawCircle(c, s * 0.08, _stroke(w * 0.8));
  }

  void _heart(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    final path = Path()
      ..moveTo(c.dx, c.dy + s * 0.3)
      ..cubicTo(c.dx - s * 0.4, c.dy + s * 0.02, c.dx - s * 0.36, c.dy - s * 0.28, c.dx, c.dy - s * 0.08)
      ..cubicTo(c.dx + s * 0.36, c.dy - s * 0.28, c.dx + s * 0.4, c.dy + s * 0.02, c.dx, c.dy + s * 0.3)
      ..close();
    canvas.drawPath(path, _fillPaint);
    canvas.drawPath(path, _stroke(w));
  }

  void _mountain(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    final back = Path()
      ..moveTo(c.dx - s * 0.36, c.dy + s * 0.28)
      ..lineTo(c.dx - s * 0.08, c.dy - s * 0.14)
      ..lineTo(c.dx + s * 0.18, c.dy + s * 0.28)
      ..close();
    final front = Path()
      ..moveTo(c.dx - s * 0.16, c.dy + s * 0.28)
      ..lineTo(c.dx + s * 0.08, c.dy - s * 0.3)
      ..lineTo(c.dx + s * 0.36, c.dy + s * 0.28)
      ..close();
    canvas.drawPath(back, _stroke(w, 0.55));
    canvas.drawPath(front, _fillPaint);
    canvas.drawPath(front, _stroke(w));
  }

  void _calendar(Canvas canvas, Offset c, double s) {
    final w = s * 0.045;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, s * 0.04), width: s * 0.52, height: s * 0.46),
        Radius.circular(s * 0.06),
      ),
      _fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, s * 0.04), width: s * 0.52, height: s * 0.46),
        Radius.circular(s * 0.06),
      ),
      _stroke(w),
    );
    canvas.drawLine(
      c + Offset(-s * 0.26, -s * 0.1),
      c + Offset(s * 0.26, -s * 0.1),
      _stroke(w),
    );
    for (final x in [-0.12, 0.0, 0.12]) {
      canvas.drawLine(
        c + Offset(s * x, -s * 0.22),
        c + Offset(s * x, -s * 0.12),
        _stroke(w * 0.9),
      );
    }
    canvas.drawCircle(c + Offset(s * 0.08, s * 0.08), s * 0.04, _inkFill);
  }

  void _gem(Canvas canvas, Offset c, double s) {
    final w = s * 0.045;
    final path = Path()
      ..moveTo(c.dx, c.dy - s * 0.32)
      ..lineTo(c.dx + s * 0.26, c.dy - s * 0.06)
      ..lineTo(c.dx, c.dy + s * 0.32)
      ..lineTo(c.dx - s * 0.26, c.dy - s * 0.06)
      ..close();
    canvas.drawPath(path, _fillPaint);
    canvas.drawPath(path, _stroke(w));
    canvas.drawLine(c + Offset(-s * 0.14, -s * 0.06), c + Offset(s * 0.14, -s * 0.06), _stroke(w * 0.7, 0.55));
  }

  void _lamp(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    final bowl = Path()
      ..moveTo(c.dx - s * 0.28, c.dy + s * 0.06)
      ..quadraticBezierTo(c.dx - s * 0.26, c.dy + s * 0.26, c.dx, c.dy + s * 0.28)
      ..quadraticBezierTo(c.dx + s * 0.26, c.dy + s * 0.26, c.dx + s * 0.32, c.dy + s * 0.02)
      ..quadraticBezierTo(c.dx + s * 0.12, c.dy + s * 0.08, c.dx - s * 0.28, c.dy + s * 0.06)
      ..close();
    canvas.drawPath(bowl, _fillPaint);
    canvas.drawPath(bowl, _stroke(w));
    final flame = Path()
      ..moveTo(c.dx + s * 0.28, c.dy)
      ..quadraticBezierTo(c.dx + s * 0.2, c.dy - s * 0.18, c.dx + s * 0.28, c.dy - s * 0.3)
      ..quadraticBezierTo(c.dx + s * 0.34, c.dy - s * 0.14, c.dx + s * 0.28, c.dy)
      ..close();
    canvas.drawPath(flame, _stroke(w * 0.9));
  }

  void _check(Canvas canvas, Offset c, double s) {
    final path = Path()
      ..moveTo(c.dx - s * 0.22, c.dy)
      ..lineTo(c.dx - s * 0.04, c.dy + s * 0.18)
      ..lineTo(c.dx + s * 0.26, c.dy - s * 0.2);
    canvas.drawPath(path, _stroke(s * 0.08));
  }

  void _echo(Canvas canvas, Offset c, double s) {
    final w = s * 0.06;
    final r = s * 0.28;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi * 0.4, math.pi * 0.75, false, _stroke(w));
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), math.pi * 0.6, math.pi * 0.75, false, _stroke(w));
    canvas.drawCircle(c, s * 0.06, _inkFill);
  }

  void _target(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    canvas.drawCircle(c, s * 0.34, _stroke(w, 0.55));
    canvas.drawCircle(c, s * 0.2, _stroke(w, 0.85));
    canvas.drawCircle(c, s * 0.07, _inkFill);
  }

  void _tune(Canvas canvas, Offset c, double s) {
    final w = s * 0.055;
    final rows = [-0.2, 0.0, 0.2];
    final knobs = [-0.16, 0.18, -0.04];
    for (var i = 0; i < 3; i++) {
      final y = c.dy + s * rows[i];
      canvas.drawLine(Offset(c.dx - s * 0.3, y), Offset(c.dx + s * 0.3, y), _stroke(w));
      canvas.drawCircle(c + Offset(s * knobs[i], s * rows[i]), s * 0.075, _fillPaint);
      canvas.drawCircle(c + Offset(s * knobs[i], s * rows[i]), s * 0.075, _stroke(w * 0.9));
    }
  }

  void _lock(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, s * 0.1), width: s * 0.44, height: s * 0.34),
        Radius.circular(s * 0.05),
      ),
      _fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, s * 0.1), width: s * 0.44, height: s * 0.34),
        Radius.circular(s * 0.05),
      ),
      _stroke(w),
    );
    canvas.drawArc(
      Rect.fromCenter(center: c + Offset(0, -s * 0.04), width: s * 0.28, height: s * 0.32),
      math.pi,
      math.pi,
      false,
      _stroke(w),
    );
    canvas.drawCircle(c + Offset(0, s * 0.1), s * 0.04, _inkFill);
  }

  void _search(Canvas canvas, Offset c, double s) {
    final w = s * 0.055;
    canvas.drawCircle(c + Offset(-s * 0.06, -s * 0.06), s * 0.2, _stroke(w));
    canvas.drawLine(
      c + Offset(s * 0.1, s * 0.1),
      c + Offset(s * 0.3, s * 0.3),
      _stroke(w * 1.15),
    );
  }

  void _shield(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    final path = Path()
      ..moveTo(c.dx, c.dy - s * 0.34)
      ..quadraticBezierTo(c.dx + s * 0.32, c.dy - s * 0.26, c.dx + s * 0.3, c.dy)
      ..quadraticBezierTo(c.dx + s * 0.26, c.dy + s * 0.2, c.dx, c.dy + s * 0.34)
      ..quadraticBezierTo(c.dx - s * 0.26, c.dy + s * 0.2, c.dx - s * 0.3, c.dy)
      ..quadraticBezierTo(c.dx - s * 0.32, c.dy - s * 0.26, c.dx, c.dy - s * 0.34)
      ..close();
    canvas.drawPath(path, _fillPaint);
    canvas.drawPath(path, _stroke(w));
    canvas.drawLine(c + Offset(0, -s * 0.14), c + Offset(0, s * 0.16), _stroke(w * 0.8, 0.55));
  }

  void _mail(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: s * 0.6, height: s * 0.42),
      Radius.circular(s * 0.05),
    );
    canvas.drawRRect(r, _fillPaint);
    canvas.drawRRect(r, _stroke(w));
    final flap = Path()
      ..moveTo(c.dx - s * 0.28, c.dy - s * 0.12)
      ..lineTo(c.dx, c.dy + s * 0.06)
      ..lineTo(c.dx + s * 0.28, c.dy - s * 0.12);
    canvas.drawPath(flap, _stroke(w));
  }

  void _frost(Canvas canvas, Offset c, double s) {
    final w = s * 0.045;
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      canvas.drawLine(
        c,
        c + Offset(math.cos(a) * s * 0.34, math.sin(a) * s * 0.34),
        _stroke(w),
      );
      final mid = c + Offset(math.cos(a) * s * 0.18, math.sin(a) * s * 0.18);
      final p = a + math.pi / 2;
      canvas.drawLine(
        mid + Offset(math.cos(p) * s * 0.07, math.sin(p) * s * 0.07),
        mid - Offset(math.cos(p) * s * 0.07, math.sin(p) * s * 0.07),
        _stroke(w * 0.75, 0.7),
      );
    }
    canvas.drawCircle(c, s * 0.05, _inkFill);
  }

  void _share(Canvas canvas, Offset c, double s) {
    final w = s * 0.05;
    final nodes = [Offset(-0.18, -0.2), Offset(0.2, 0.0), Offset(-0.18, 0.2)];
    for (final n in nodes) {
      canvas.drawCircle(c + Offset(n.dx * s, n.dy * s), s * 0.065, _fillPaint);
      canvas.drawCircle(c + Offset(n.dx * s, n.dy * s), s * 0.065, _stroke(w));
    }
    canvas.drawLine(
      c + Offset(nodes[0].dx * s, nodes[0].dy * s),
      c + Offset(nodes[1].dx * s, nodes[1].dy * s),
      _stroke(w * 0.85, 0.75),
    );
    canvas.drawLine(
      c + Offset(nodes[2].dx * s, nodes[2].dy * s),
      c + Offset(nodes[1].dx * s, nodes[1].dy * s),
      _stroke(w * 0.85, 0.75),
    );
  }

  void _qr(Canvas canvas, Offset c, double s) {
    final w = s * 0.045;
    void corner(Offset o) {
      final r = Rect.fromCenter(center: c + o, width: s * 0.2, height: s * 0.2);
      canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(s * 0.025)), _stroke(w));
      canvas.drawRect(
        Rect.fromCenter(center: c + o, width: s * 0.07, height: s * 0.07),
        _inkFill,
      );
    }

    corner(Offset(-s * 0.15, -s * 0.15));
    corner(Offset(s * 0.15, -s * 0.15));
    corner(Offset(-s * 0.15, s * 0.15));
    for (final o in [Offset(0.08, 0.08), Offset(0.18, 0.08), Offset(0.08, 0.18), Offset(0.18, 0.18)]) {
      canvas.drawRect(
        Rect.fromCenter(center: c + Offset(o.dx * s, o.dy * s), width: s * 0.06, height: s * 0.06),
        _inkFill,
      );
    }
  }

  void _copy(Canvas canvas, Offset c, double s) {
    final w = s * 0.045;
    final back = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c + Offset(s * 0.06, s * 0.06), width: s * 0.34, height: s * 0.42),
      Radius.circular(s * 0.04),
    );
    final front = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c + Offset(-s * 0.06, -s * 0.06), width: s * 0.34, height: s * 0.42),
      Radius.circular(s * 0.04),
    );
    canvas.drawRRect(back, _stroke(w, 0.55));
    canvas.drawRRect(front, _fillPaint);
    canvas.drawRRect(front, _stroke(w));
  }

  void _podium(Canvas canvas, Offset c, double s) {
    final w = s * 0.045;
    final steps = [
      (Offset(-0.2, 0.12), 0.26, 0.34),
      (Offset(0.0, 0.0), 0.26, 0.5),
      (Offset(0.2, 0.16), 0.26, 0.28),
    ];
    for (var i = 0; i < steps.length; i++) {
      final (o, ww, h) = steps[i];
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(o.dx * s, o.dy * s), width: s * ww, height: s * h),
        Radius.circular(s * 0.025),
      );
      if (i == 1) canvas.drawRRect(r, _fillPaint);
      canvas.drawRRect(r, _stroke(w, i == 1 ? 1 : 0.7));
    }
  }

  void _arrow(Canvas canvas, Offset c, double s, {required bool up}) {
    final dir = up ? -1.0 : 1.0;
    final path = Path()
      ..moveTo(c.dx, c.dy + dir * s * 0.26)
      ..lineTo(c.dx - s * 0.16, c.dy + dir * s * 0.02)
      ..lineTo(c.dx - s * 0.05, c.dy + dir * s * 0.02)
      ..lineTo(c.dx - s * 0.05, c.dy - dir * s * 0.26)
      ..lineTo(c.dx + s * 0.05, c.dy - dir * s * 0.26)
      ..lineTo(c.dx + s * 0.05, c.dy + dir * s * 0.02)
      ..lineTo(c.dx + s * 0.16, c.dy + dir * s * 0.02)
      ..close();
    canvas.drawPath(path, _fillPaint);
    canvas.drawPath(path, _stroke(s * 0.045));
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter old) =>
      old.glyph != glyph || old.color != color || old.premium != premium;
}
