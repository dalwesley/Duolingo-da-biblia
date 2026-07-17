import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Símbolos da lição — ícones tipográficos, sem emoji.
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
      'memory' => CinematicGlyph.scroll,
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
      CinematicGlyph.tune => accent ?? AppColors.accent,
    };
  }
}

/// Ícone cinematográfico — relicário escuro com símbolo iluminado por dentro.
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
    final child = CustomPaint(
      size: Size.square(size * (framed ? 0.6 : 1)),
      painter: _GlyphPainter(glyph: glyph, color: color, backlit: framed),
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

    final rim = Color.lerp(color, Colors.white, 0.45)!;
    final deep = Color.lerp(color, const Color(0xFF0A0E0C), 0.8)!;
    final mid = Color.lerp(color, const Color(0xFF1A221E), 0.5)!;

    final medallion = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 1.15,
          colors: [mid, deep],
        ),
        border: Border.all(
          color: rim.withValues(alpha: 0.65),
          width: size * 0.032,
        ),
        boxShadow: glowing
            ? [
                BoxShadow(color: color.withValues(alpha: 0.22), blurRadius: size * 0.24, offset: Offset(0, size * 0.05)),
                BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: size * 0.16, offset: Offset(0, size * 0.06)),
              ]
            : [
                BoxShadow(color: Colors.black.withValues(alpha: 0.28), blurRadius: size * 0.12, offset: Offset(0, size * 0.04)),
              ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Luz interna suave
          Container(
            width: size * 0.8,
            height: size * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.34),
                  color.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // Anel orbital fino na cor do selo.
          CustomPaint(
            size: Size.square(size * 0.84),
            painter: _OrbitRingPainter(color: rim.withValues(alpha: 0.18)),
          ),
          child,
          // Reflexo de lente sutil no topo.
          Positioned(
            top: size * 0.07,
            left: size * 0.3,
            child: Container(
              width: size * 0.4,
              height: size * 0.1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withValues(alpha: 0.16), Colors.white.withValues(alpha: 0)],
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

/// Aura estática — o glow constante é suficiente e não custa um frame por vez.
class _BreathingAura extends StatelessWidget {
  final Widget child;
  final Color color;
  final double size;

  const _BreathingAura({required this.child, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.36),
            blurRadius: size * 0.4,
          ),
        ],
      ),
      child: child,
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

/// Glifos luminosos — traço com gradiente de luz na cor do selo.
class _GlyphPainter extends CustomPainter {
  final CinematicGlyph glyph;
  final Color color;
  final bool backlit;

  _GlyphPainter({required this.glyph, required this.color, this.backlit = false});

  late Rect _r;
  late bool _darkInk;
  late Color _lit;
  late Color _core;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = size.shortestSide;
    _r = Rect.fromCircle(center: c, radius: s * 0.5);

    // Cores escuras (ex.: ícone sobre botão dourado) permanecem gravadas;
    // cores claras viram luz — núcleo quase branco com borda na cor do tema.
    _darkInk = color.computeLuminance() < 0.22;
    _lit = _darkInk ? color : Color.lerp(color, Colors.white, 0.28)!;
    _core = _darkInk ? color : Color.lerp(color, Colors.white, 0.78)!;

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
      case CinematicGlyph.book:
        _paintBook(canvas, c, s);
      case CinematicGlyph.scroll:
        _paintScroll(canvas, c, s);
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
      case CinematicGlyph.echo:
        _paintEcho(canvas, c, s);
      case CinematicGlyph.target:
        _paintTarget(canvas, c, s);
      case CinematicGlyph.tune:
        _paintTune(canvas, c, s);
    }
  }

  /// Preenchimento luminoso — núcleo claro escorrendo para a cor do selo.
  Paint get _fill => Paint()
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [_core, _lit],
    ).createShader(_r);

  Paint get _soft => Paint()..color = _lit.withValues(alpha: 0.55);

  Paint get _glow => Paint()
    ..color = (_darkInk ? Colors.black : Colors.white).withValues(alpha: 0.4)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

  Color _ink([double alpha = 0.9]) => _lit.withValues(alpha: alpha);

  Paint _stroke(double width, [double alpha = 0.9]) => Paint()
    ..color = _ink(alpha)
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get _highlight => Paint()..color = Colors.white.withValues(alpha: 0.5);

  void _paintSun(Canvas canvas, Offset c, double s) {
    // Corona difusa.
    canvas.drawCircle(
      c,
      s * 0.44,
      Paint()
        ..shader = RadialGradient(
          colors: [_core.withValues(alpha: 0.5), _core.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: c, radius: s * 0.44)),
    );
    // Raios longos e curtos intercalados.
    for (var i = 0; i < 12; i++) {
      final a = (i / 12) * math.pi * 2 - math.pi / 2;
      final long = i.isEven;
      final inner = s * (long ? 0.24 : 0.22);
      final outer = s * (long ? 0.47 : 0.35);
      final p1 = c + Offset(math.cos(a) * inner, math.sin(a) * inner);
      final p2 = c + Offset(math.cos(a) * outer, math.sin(a) * outer);
      canvas.drawLine(p1, p2, _stroke(long ? s * 0.05 : s * 0.03, long ? 0.95 : 0.55));
    }
    // Disco solar com highlight.
    canvas.drawCircle(c, s * 0.19, _glow);
    canvas.drawCircle(c, s * 0.17, _fill);
    canvas.drawCircle(c + Offset(-s * 0.05, -s * 0.05), s * 0.05, _highlight);
  }

  void _paintCosmos(Canvas canvas, Offset c, double s) {
    canvas.drawCircle(c, s * 0.38, Paint()..color = _ink(0.12));
    for (final r in [0.38, 0.27, 0.16]) {
      canvas.drawCircle(c, s * r, _stroke(s * 0.022, 0.7));
    }
    // Estrelas orbitando.
    for (var i = 0; i < 5; i++) {
      final a = i * 1.35;
      final p = c + Offset(math.cos(a) * s * 0.32, math.sin(a) * s * 0.32);
      canvas.drawCircle(p, s * 0.04, _fill);
    }
    canvas.drawCircle(c, s * 0.09, _glow);
    canvas.drawCircle(c, s * 0.08, _fill);
  }

  void _paintHumanity(Canvas canvas, Offset c, double s) {
    // Silhueta estilizada — cabeça + ombros em arco.
    canvas.drawCircle(c + Offset(0, -s * 0.14), s * 0.13, _fill);
    final body = Path()
      ..moveTo(c.dx - s * 0.28, c.dy + s * 0.32)
      ..quadraticBezierTo(c.dx - s * 0.22, c.dy + s * 0.02, c.dx, c.dy - s * 0.02)
      ..quadraticBezierTo(c.dx + s * 0.22, c.dy + s * 0.02, c.dx + s * 0.28, c.dy + s * 0.32)
      ..close();
    canvas.drawPath(body, _fill);
    // Halo.
    canvas.drawArc(
      Rect.fromCircle(center: c + Offset(0, -s * 0.14), radius: s * 0.22),
      math.pi * 1.1,
      math.pi * 0.8,
      false,
      _stroke(s * 0.032, 0.65),
    );
  }

  void _paintDove(Canvas canvas, Offset c, double s) {
    // Corpo em mergulho suave.
    final body = Path()
      ..moveTo(c.dx - s * 0.18, c.dy + s * 0.14)
      ..quadraticBezierTo(c.dx - s * 0.02, c.dy - s * 0.06, c.dx + s * 0.2, c.dy - s * 0.06)
      ..quadraticBezierTo(c.dx + s * 0.32, c.dy - s * 0.06, c.dx + s * 0.36, c.dy - s * 0.12)
      ..quadraticBezierTo(c.dx + s * 0.3, c.dy + s * 0.06, c.dx + s * 0.1, c.dy + s * 0.1)
      ..quadraticBezierTo(c.dx - s * 0.06, c.dy + s * 0.16, c.dx - s * 0.18, c.dy + s * 0.14)
      ..close();
    canvas.drawPath(body, _fill);
    // Asa erguida.
    final wing = Path()
      ..moveTo(c.dx + s * 0.02, c.dy - s * 0.04)
      ..quadraticBezierTo(c.dx - s * 0.1, c.dy - s * 0.38, c.dx - s * 0.3, c.dy - s * 0.3)
      ..quadraticBezierTo(c.dx - s * 0.14, c.dy - s * 0.16, c.dx - s * 0.08, c.dy - s * 0.02)
      ..close();
    canvas.drawPath(wing, _soft);
    // Cauda.
    final tail = Path()
      ..moveTo(c.dx - s * 0.16, c.dy + s * 0.1)
      ..lineTo(c.dx - s * 0.34, c.dy + s * 0.24)
      ..lineTo(c.dx - s * 0.12, c.dy + s * 0.18)
      ..close();
    canvas.drawPath(tail, _soft);
    // Olho.
    canvas.drawCircle(c + Offset(s * 0.26, -s * 0.09), s * 0.022, Paint()..color = Colors.black.withValues(alpha: 0.55));
    // Ramo de oliveira no bico.
    canvas.drawLine(
      c + Offset(s * 0.36, -s * 0.12),
      c + Offset(s * 0.44, -s * 0.2),
      _stroke(s * 0.022, 0.75),
    );
    canvas.drawCircle(c + Offset(s * 0.44, -s * 0.22), s * 0.03, _soft);
  }

  void _paintTree(Canvas canvas, Offset c, double s) {
    // Copa orgânica — camadas de luz.
    canvas.drawCircle(c + Offset(0, -s * 0.1), s * 0.26, _soft);
    canvas.drawCircle(c + Offset(-s * 0.18, s * 0.0), s * 0.17, _soft);
    canvas.drawCircle(c + Offset(s * 0.18, s * 0.0), s * 0.17, _soft);
    canvas.drawCircle(c + Offset(0, -s * 0.08), s * 0.2, _fill);
    // Frutos.
    for (final o in [Offset(-0.12, -0.14), Offset(0.1, -0.02), Offset(0.02, -0.22)]) {
      canvas.drawCircle(c + Offset(o.dx * s, o.dy * s), s * 0.035, _highlight);
    }
    // Tronco com raiz.
    final trunk = Path()
      ..moveTo(c.dx - s * 0.045, c.dy + s * 0.08)
      ..lineTo(c.dx - s * 0.06, c.dy + s * 0.3)
      ..quadraticBezierTo(c.dx - s * 0.16, c.dy + s * 0.34, c.dx - s * 0.2, c.dy + s * 0.36)
      ..lineTo(c.dx + s * 0.2, c.dy + s * 0.36)
      ..quadraticBezierTo(c.dx + s * 0.16, c.dy + s * 0.34, c.dx + s * 0.06, c.dy + s * 0.3)
      ..lineTo(c.dx + s * 0.045, c.dy + s * 0.08)
      ..close();
    canvas.drawPath(trunk, _fill);
  }

  void _paintFall(Canvas canvas, Offset c, double s) {
    // Fruto com mordida — a queda.
    final fruit = Path()
      ..addOval(Rect.fromCenter(center: c + Offset(0, s * 0.06), width: s * 0.36, height: s * 0.42));
    final bite = Path()
      ..addOval(Rect.fromCircle(center: c + Offset(s * 0.18, -s * 0.04), radius: s * 0.1));
    canvas.drawPath(Path.combine(PathOperation.difference, fruit, bite), _fill);
    // Folha.
    final leaf = Path()
      ..moveTo(c.dx + s * 0.02, c.dy - s * 0.16)
      ..quadraticBezierTo(c.dx + s * 0.22, c.dy - s * 0.32, c.dx + s * 0.28, c.dy - s * 0.12)
      ..quadraticBezierTo(c.dx + s * 0.12, c.dy - s * 0.1, c.dx + s * 0.02, c.dy - s * 0.16)
      ..close();
    canvas.drawPath(leaf, _soft);
    // Cabo.
    canvas.drawLine(c + Offset(0, -s * 0.14), c + Offset(s * 0.02, -s * 0.28), _stroke(s * 0.035));
    // Brilho.
    canvas.drawCircle(c + Offset(-s * 0.08, -s * 0.02), s * 0.05, _highlight);
  }

  void _paintTears(Canvas canvas, Offset c, double s) {
    final drop = Path()
      ..moveTo(c.dx, c.dy - s * 0.32)
      ..quadraticBezierTo(c.dx + s * 0.22, c.dy - s * 0.02, c.dx, c.dy + s * 0.32)
      ..quadraticBezierTo(c.dx - s * 0.22, c.dy - s * 0.02, c.dx, c.dy - s * 0.32)
      ..close();
    canvas.drawPath(drop, _fill);
    canvas.drawCircle(c + Offset(-s * 0.05, -s * 0.02), s * 0.05, _highlight);
  }

  void _paintScales(Canvas canvas, Offset c, double s) {
    final stroke = _stroke(s * 0.04);
    canvas.drawLine(c + Offset(0, -s * 0.28), c + Offset(0, s * 0.28), stroke);
    canvas.drawLine(c + Offset(-s * 0.32, -s * 0.1), c + Offset(s * 0.32, -s * 0.1), stroke);
    canvas.drawCircle(c + Offset(-s * 0.28, s * 0.08), s * 0.12, stroke);
    canvas.drawCircle(c + Offset(s * 0.28, s * 0.08), s * 0.12, stroke);
    canvas.drawCircle(c + Offset(0, -s * 0.28), s * 0.05, _fill);
  }

  void _paintWaves(Canvas canvas, Offset c, double s) {
    for (var i = 0; i < 3; i++) {
      final y = c.dy - s * 0.16 + i * s * 0.16;
      final path = Path()..moveTo(c.dx - s * 0.38, y);
      for (var x = -0.38; x <= 0.38; x += 0.12) {
        final wave = math.sin((x + 0.4) * math.pi * 2.2 + i) * s * 0.05;
        path.lineTo(c.dx + s * x, y + wave);
      }
      canvas.drawPath(path, _stroke(s * 0.05, 0.9 - i * 0.2));
    }
  }

  void _paintTower(Canvas canvas, Offset c, double s) {
    final tiers = [
      Rect.fromCenter(center: c + Offset(0, s * 0.22), width: s * 0.52, height: s * 0.18),
      Rect.fromCenter(center: c + Offset(0, s * 0.02), width: s * 0.38, height: s * 0.18),
      Rect.fromCenter(center: c + Offset(0, -s * 0.18), width: s * 0.26, height: s * 0.18),
    ];
    for (var i = 0; i < tiers.length; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(tiers[i], Radius.circular(s * 0.03)),
        i == 1 ? _soft : _fill,
      );
    }
    canvas.drawCircle(c + Offset(0, -s * 0.32), s * 0.05, _fill);
  }

  void _paintStar(Canvas canvas, Offset c, double s) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 4 * math.pi / 5;
      final p = c + Offset(math.cos(a) * s * 0.38, math.sin(a) * s * 0.38);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, _glow);
    canvas.drawPath(path, _fill);
    canvas.drawCircle(c, s * 0.08, _highlight);
  }

  void _paintCrown(Canvas canvas, Offset c, double s) {
    final path = Path()
      ..moveTo(c.dx - s * 0.34, c.dy + s * 0.16)
      ..lineTo(c.dx - s * 0.3, c.dy - s * 0.2)
      ..lineTo(c.dx - s * 0.12, c.dy)
      ..lineTo(c.dx, c.dy - s * 0.3)
      ..lineTo(c.dx + s * 0.12, c.dy)
      ..lineTo(c.dx + s * 0.3, c.dy - s * 0.2)
      ..lineTo(c.dx + s * 0.34, c.dy + s * 0.16)
      ..close();
    canvas.drawPath(path, _fill);
    // Base da coroa.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c + Offset(0, s * 0.25), width: s * 0.72, height: s * 0.11),
        Radius.circular(s * 0.045),
      ),
      _fill,
    );
    // Joias nas pontas.
    for (final o in [Offset(-0.3, -0.24), Offset(0.0, -0.34), Offset(0.3, -0.24)]) {
      canvas.drawCircle(c + Offset(o.dx * s, o.dy * s), s * 0.045, _highlight);
    }
    // Joia central da base.
    canvas.drawCircle(c + Offset(0, s * 0.25), s * 0.035, Paint()..color = Colors.black.withValues(alpha: 0.3));
  }

  void _paintChain(Canvas canvas, Offset c, double s) {
    final stroke = _stroke(s * 0.055);
    // Corrente rompida — elos separados com faísca de liberdade.
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(-s * 0.17, -s * 0.12), width: s * 0.26, height: s * 0.36),
      stroke,
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(s * 0.17, s * 0.12), width: s * 0.26, height: s * 0.36),
      stroke,
    );
    // Faíscas do rompimento.
    for (final o in [Offset(0.02, -0.02), Offset(0.1, -0.12), Offset(-0.08, 0.1)]) {
      canvas.drawCircle(c + Offset(o.dx * s, o.dy * s), s * 0.026, _highlight);
    }
  }

  void _paintFlame(Canvas canvas, Offset c, double s) {
    final flame = Path()
      ..moveTo(c.dx, c.dy + s * 0.34)
      ..quadraticBezierTo(c.dx - s * 0.32, c.dy + s * 0.05, c.dx - s * 0.08, c.dy - s * 0.18)
      ..quadraticBezierTo(c.dx - s * 0.02, c.dy - s * 0.02, c.dx + s * 0.04, c.dy - s * 0.12)
      ..quadraticBezierTo(c.dx + s * 0.08, c.dy - s * 0.34, c.dx + s * 0.02, c.dy - s * 0.38)
      ..quadraticBezierTo(c.dx + s * 0.34, c.dy - s * 0.05, c.dx, c.dy + s * 0.34)
      ..close();
    canvas.drawPath(flame, _glow);
    canvas.drawPath(flame, _fill);
    // Chama interna.
    final inner = Path()
      ..moveTo(c.dx, c.dy + s * 0.26)
      ..quadraticBezierTo(c.dx - s * 0.12, c.dy + s * 0.06, c.dx - s * 0.01, c.dy - s * 0.06)
      ..quadraticBezierTo(c.dx + s * 0.12, c.dy + s * 0.06, c.dx, c.dy + s * 0.26)
      ..close();
    canvas.drawPath(inner, _highlight);
  }

  void _paintBook(Canvas canvas, Offset c, double s) {
    // Livro aberto — páginas em curva, sem raios.
    final leftPage = Path()
      ..moveTo(c.dx, c.dy - s * 0.2)
      ..quadraticBezierTo(c.dx - s * 0.2, c.dy - s * 0.32, c.dx - s * 0.38, c.dy - s * 0.24)
      ..lineTo(c.dx - s * 0.38, c.dy + s * 0.2)
      ..quadraticBezierTo(c.dx - s * 0.2, c.dy + s * 0.12, c.dx, c.dy + s * 0.24)
      ..close();
    final rightPage = Path()
      ..moveTo(c.dx, c.dy - s * 0.2)
      ..quadraticBezierTo(c.dx + s * 0.2, c.dy - s * 0.32, c.dx + s * 0.38, c.dy - s * 0.24)
      ..lineTo(c.dx + s * 0.38, c.dy + s * 0.2)
      ..quadraticBezierTo(c.dx + s * 0.2, c.dy + s * 0.12, c.dx, c.dy + s * 0.24)
      ..close();
    canvas.drawPath(leftPage, _fill);
    canvas.drawPath(rightPage, _soft);
    // Contorno fino das páginas
    final edge = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.018;
    canvas.drawPath(leftPage, edge);
    canvas.drawPath(rightPage, edge);
    // Lombada
    canvas.drawLine(
      c + Offset(0, -s * 0.2),
      c + Offset(0, s * 0.24),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..strokeWidth = s * 0.028
        ..strokeCap = StrokeCap.round,
    );
    // Linhas de texto discretas
    for (var i = 0; i < 3; i++) {
      final y = c.dy - s * 0.08 + i * s * 0.08;
      final ink = Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..strokeWidth = s * 0.018
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(c.dx - s * 0.3, y), Offset(c.dx - s * 0.08, y + s * 0.015), ink);
      canvas.drawLine(Offset(c.dx + s * 0.08, y + s * 0.015), Offset(c.dx + s * 0.3, y), ink);
    }
  }

  void _paintSeed(Canvas canvas, Offset c, double s) {
    // Solo em arco
    canvas.drawArc(
      Rect.fromCenter(center: c + Offset(0, s * 0.22), width: s * 0.62, height: s * 0.22),
      math.pi * 1.05,
      math.pi * 0.9,
      false,
      _stroke(s * 0.035, 0.55),
    );
    // Caule
    canvas.drawLine(
      c + Offset(0, s * 0.2),
      c + Offset(0, -s * 0.02),
      _stroke(s * 0.038),
    );
    // Folhas
    final left = Path()
      ..moveTo(c.dx, c.dy + s * 0.02)
      ..quadraticBezierTo(c.dx - s * 0.3, c.dy - s * 0.02, c.dx - s * 0.2, c.dy - s * 0.3)
      ..quadraticBezierTo(c.dx - s * 0.02, c.dy - s * 0.1, c.dx, c.dy + s * 0.02)
      ..close();
    final right = Path()
      ..moveTo(c.dx, c.dy + s * 0.02)
      ..quadraticBezierTo(c.dx + s * 0.3, c.dy - s * 0.02, c.dx + s * 0.2, c.dy - s * 0.3)
      ..quadraticBezierTo(c.dx + s * 0.02, c.dy - s * 0.1, c.dx, c.dy + s * 0.02)
      ..close();
    canvas.drawPath(left, _fill);
    canvas.drawPath(right, _soft);
    canvas.drawCircle(c + Offset(0, -s * 0.02), s * 0.04, _highlight);
  }

  void _paintPath(Canvas canvas, Offset c, double s) {
    final path = Path()
      ..moveTo(c.dx - s * 0.28, c.dy + s * 0.28)
      ..quadraticBezierTo(c.dx - s * 0.1, c.dy + s * 0.05, c.dx, c.dy - s * 0.05)
      ..quadraticBezierTo(c.dx + s * 0.12, c.dy - s * 0.18, c.dx + s * 0.08, c.dy - s * 0.32);
    canvas.drawPath(path, _stroke(s * 0.08));
    for (final o in [Offset(-0.18, 0.18), Offset(0.0, -0.02), Offset(0.1, -0.22)]) {
      canvas.drawCircle(c + Offset(o.dx * s, o.dy * s), s * 0.05, _highlight);
    }
  }

  void _paintDepths(Canvas canvas, Offset c, double s) {
    // Arcos de portal / arquitetura — não alvo concêntrico
    for (var i = 0; i < 3; i++) {
      final inset = i * s * 0.1;
      final rect = Rect.fromCenter(
        center: c + Offset(0, s * 0.08),
        width: s * 0.56 - inset,
        height: s * 0.62 - inset,
      );
      canvas.drawArc(
        rect,
        math.pi * 1.05,
        math.pi * 0.9,
        false,
        _stroke(s * 0.04, 0.75 - i * 0.18),
      );
    }
    canvas.drawLine(
      c + Offset(0, -s * 0.18),
      c + Offset(0, s * 0.28),
      _stroke(s * 0.03, 0.45),
    );
  }

  void _paintSpark(Canvas canvas, Offset c, double s) {
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final long = i.isEven;
      canvas.drawLine(
        c + Offset(math.cos(a) * s * 0.1, math.sin(a) * s * 0.1),
        c + Offset(math.cos(a) * s * (long ? 0.42 : 0.27), math.sin(a) * s * (long ? 0.42 : 0.27)),
        _stroke(long ? s * 0.05 : s * 0.03, long ? 0.95 : 0.55),
      );
    }
    canvas.drawCircle(c, s * 0.12, _glow);
    canvas.drawCircle(c, s * 0.1, _fill);
  }

  void _paintHeart(Canvas canvas, Offset c, double s) {
    final path = Path()
      ..moveTo(c.dx, c.dy + s * 0.32)
      ..cubicTo(
        c.dx - s * 0.44,
        c.dy + s * 0.04,
        c.dx - s * 0.4,
        c.dy - s * 0.3,
        c.dx,
        c.dy - s * 0.1,
      )
      ..cubicTo(
        c.dx + s * 0.4,
        c.dy - s * 0.3,
        c.dx + s * 0.44,
        c.dy + s * 0.04,
        c.dx,
        c.dy + s * 0.32,
      )
      ..close();
    canvas.drawPath(path, _fill);
    // Contorno e brilho interno (sem aura exagerada)
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.02,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: c + Offset(-s * 0.12, -s * 0.08),
        width: s * 0.14,
        height: s * 0.08,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
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
    canvas.drawPath(snow, Paint()..color = Colors.white.withValues(alpha: 0.55));
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
      canvas.drawCircle(c + Offset(s * x, -s * 0.22), s * 0.03, _highlight);
    }
    // Dia marcado.
    canvas.drawCircle(c + Offset(s * 0.08, s * 0.06), s * 0.05, Paint()..color = Colors.black.withValues(alpha: 0.3));
  }

  void _paintGem(Canvas canvas, Offset c, double s) {
    final path = Path()
      ..moveTo(c.dx, c.dy - s * 0.34)
      ..lineTo(c.dx + s * 0.28, c.dy - s * 0.08)
      ..lineTo(c.dx, c.dy + s * 0.34)
      ..lineTo(c.dx - s * 0.28, c.dy - s * 0.08)
      ..close();
    canvas.drawPath(path, _glow);
    canvas.drawPath(path, _fill);
    // Facetas.
    final facet = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = s * 0.025
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c + Offset(-s * 0.14, -s * 0.08), c + Offset(s * 0.14, -s * 0.08), facet);
    canvas.drawLine(c + Offset(-s * 0.14, -s * 0.08), c + Offset(0, s * 0.34), facet..strokeWidth = s * 0.018);
    canvas.drawLine(c + Offset(s * 0.14, -s * 0.08), c + Offset(0, s * 0.34), facet);
  }

  void _paintLamp(Canvas canvas, Offset c, double s) {
    // Lamparina de azeite — corpo baixo com bico.
    final bowl = Path()
      ..moveTo(c.dx - s * 0.3, c.dy + s * 0.06)
      ..quadraticBezierTo(c.dx - s * 0.28, c.dy + s * 0.26, c.dx, c.dy + s * 0.28)
      ..quadraticBezierTo(c.dx + s * 0.28, c.dy + s * 0.26, c.dx + s * 0.34, c.dy + s * 0.04)
      ..quadraticBezierTo(c.dx + s * 0.2, c.dy + s * 0.1, c.dx + s * 0.06, c.dy + s * 0.06)
      ..quadraticBezierTo(c.dx - s * 0.14, c.dy, c.dx - s * 0.3, c.dy + s * 0.06)
      ..close();
    canvas.drawPath(bowl, _fill);
    // Alça.
    canvas.drawArc(
      Rect.fromCircle(center: c + Offset(-s * 0.3, s * 0.12), radius: s * 0.09),
      math.pi * 0.4,
      math.pi * 1.2,
      false,
      _stroke(s * 0.03, 0.7),
    );
    // Chama no bico.
    final flame = Path()
      ..moveTo(c.dx + s * 0.3, c.dy + s * 0.02)
      ..quadraticBezierTo(c.dx + s * 0.2, c.dy - s * 0.18, c.dx + s * 0.28, c.dy - s * 0.3)
      ..quadraticBezierTo(c.dx + s * 0.36, c.dy - s * 0.16, c.dx + s * 0.3, c.dy + s * 0.02)
      ..close();
    canvas.drawPath(flame, _glow);
    canvas.drawPath(flame, _fill);
    canvas.drawCircle(c + Offset(s * 0.28, -s * 0.14), s * 0.035, _highlight);
  }

  void _paintCheck(Canvas canvas, Offset c, double s) {
    final path = Path()
      ..moveTo(c.dx - s * 0.22, c.dy)
      ..lineTo(c.dx - s * 0.05, c.dy + s * 0.18)
      ..lineTo(c.dx + s * 0.26, c.dy - s * 0.2);
    canvas.drawPath(path, _stroke(s * 0.09));
  }

  /// Pergaminho — rolo vertical com hastes enroladas em cima e embaixo.
  void _paintScroll(Canvas canvas, Offset c, double s) {
    // Folha central.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: s * 0.5, height: s * 0.56),
        Radius.circular(s * 0.03),
      ),
      _fill,
    );
    // Rolos (cilindros) no topo e na base.
    for (final y in [-0.3, 0.3]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: c + Offset(0, s * y), width: s * 0.64, height: s * 0.14),
          Radius.circular(s * 0.07),
        ),
        _soft,
      );
      // Miolo do rolo nas pontas.
      canvas.drawCircle(c + Offset(-s * 0.32, s * y), s * 0.045, _highlight);
      canvas.drawCircle(c + Offset(s * 0.32, s * y), s * 0.045, _highlight);
    }
    // Linhas de escrita.
    for (var i = 0; i < 3; i++) {
      final y = c.dy - s * 0.1 + i * s * 0.1;
      canvas.drawLine(
        Offset(c.dx - s * 0.16, y),
        Offset(c.dx + s * 0.16, y),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.3)
          ..strokeWidth = s * 0.025
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  /// Eco — setas circulares de retorno (revisão da memória).
  void _paintEcho(Canvas canvas, Offset c, double s) {
    final r = s * 0.3;
    // Dois arcos abertos formando o ciclo.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi * 0.42,
      math.pi * 0.78,
      false,
      _stroke(s * 0.065),
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      math.pi * 0.58,
      math.pi * 0.78,
      false,
      _stroke(s * 0.065),
    );
    // Pontas de seta.
    void arrowAt(double angle, bool clockwise) {
      final tip = c + Offset(math.cos(angle) * r, math.sin(angle) * r);
      final dir = angle + (clockwise ? math.pi / 2 : -math.pi / 2);
      final a1 = dir + math.pi * 0.78;
      final a2 = dir - math.pi * 0.78;
      final head = Path()
        ..moveTo(tip.dx + math.cos(dir) * s * 0.02, tip.dy + math.sin(dir) * s * 0.02)
        ..lineTo(tip.dx + math.cos(a1) * s * 0.12, tip.dy + math.sin(a1) * s * 0.12)
        ..lineTo(tip.dx + math.cos(a2) * s * 0.12, tip.dy + math.sin(a2) * s * 0.12)
        ..close();
      canvas.drawPath(head, _fill);
    }

    arrowAt(math.pi * 0.36, true);
    arrowAt(math.pi * 1.36, true);
    // Centelha da memória no centro.
    canvas.drawCircle(c, s * 0.09, _glow);
    canvas.drawCircle(c, s * 0.07, _fill);
  }

  /// Alvo — fidelidade ao texto.
  void _paintTarget(Canvas canvas, Offset c, double s) {
    canvas.drawCircle(c, s * 0.36, _stroke(s * 0.045, 0.55));
    canvas.drawCircle(c, s * 0.22, _stroke(s * 0.045, 0.8));
    canvas.drawCircle(c, s * 0.09, _glow);
    canvas.drawCircle(c, s * 0.08, _fill);
    canvas.drawCircle(c + Offset(-s * 0.025, -s * 0.025), s * 0.025, _highlight);
  }

  /// Preferências — três trilhos com botões de ajuste.
  void _paintTune(Canvas canvas, Offset c, double s) {
    final stroke = _stroke(s * 0.055);
    final rows = [-0.22, 0.0, 0.22];
    final knobs = [-0.18, 0.2, -0.06];
    for (var i = 0; i < 3; i++) {
      final y = c.dy + s * rows[i];
      canvas.drawLine(
        Offset(c.dx - s * 0.32, y),
        Offset(c.dx + s * 0.32, y),
        stroke,
      );
      final knob = c + Offset(s * knobs[i], s * rows[i]);
      canvas.drawCircle(knob, s * 0.09, _glow);
      canvas.drawCircle(knob, s * 0.08, _fill);
      canvas.drawCircle(
        knob + Offset(-s * 0.02, -s * 0.02),
        s * 0.025,
        _highlight,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter old) =>
      old.glyph != glyph || old.color != color || old.backlit != backlit;
}
