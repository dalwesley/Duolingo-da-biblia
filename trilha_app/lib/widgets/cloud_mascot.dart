import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// A nuvem que acompanhou o povo no deserto — a companheira da trilha.
///
/// O corpo é imagem (uma cor de borda por cara); o rosto é desenhado, para
/// poder piscar, sorrir e virar X. Ao aparecer, a nuvem parte do rosto
/// neutro e chega à cara pedida — a reação é o que dá vida.
enum CloudFace {
  feliz,
  triste,
  sucesso,
  erro,
  carregando;

  String get body => 'assets/mascot/cloud_body_$name.png';

  _Expression get _expression => switch (this) {
    CloudFace.feliz => _Expression.feliz,
    CloudFace.triste => _Expression.triste,
    CloudFace.sucesso => _Expression.sucesso,
    CloudFace.erro => _Expression.erro,
    CloudFace.carregando => _Expression.neutro,
  };

  /// Gesto ocasional parado: pulinho (feliz, sucesso), suspiro (triste).
  /// Erro fica quieto; carregando já flutua.
  bool get _fidgets =>
      this == CloudFace.feliz ||
      this == CloudFace.sucesso ||
      this == CloudFace.triste;

  /// Arco e olho caído não têm meio-termo bonito com a barra.
  bool get _squintsOnChange =>
      this == CloudFace.sucesso || this == CloudFace.triste;

  /// Olhos de barra (e os tristes) piscam; arco e X não.
  bool get _blinks =>
      this == CloudFace.feliz ||
      this == CloudFace.carregando ||
      this == CloudFace.triste;
}

class CloudMascot extends StatefulWidget {
  final CloudFace face;
  final double size;

  /// false = já aparece na cara final, sem partir do neutro.
  final bool react;

  /// Espera antes da reação — maior quando a nuvem entra com a tela.
  final Duration reactDelay;

  const CloudMascot({
    super.key,
    required this.face,
    this.size = 96,
    this.react = true,
    this.reactDelay = const Duration(milliseconds: 220),
  });

  /// Proporção do corpo (480×356).
  static const aspect = 356 / 480;

  /// Decodifica os corpos antes da primeira troca de cara.
  static Future<void> precache(BuildContext context) => Future.wait([
    for (final f in CloudFace.values)
      precacheImage(AssetImage(f.body), context),
  ]);

  @override
  State<CloudMascot> createState() => _CloudMascotState();
}

class _CloudMascotState extends State<CloudMascot>
    with TickerProviderStateMixin {
  final _random = math.Random();

  /// Entrada: a nuvem cresce de leve e aparece (pop), em vez de surgir.
  late final AnimationController _appear = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 340),
  );

  /// 0→1: rosto e corpo vão de [_from] para a cara pedida; o gesto do
  /// corpo (pulo, balanço, afundar) vem no fim.
  late final AnimationController _react = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 170),
  );

  /// Gesto ocasional parado (pulinho, suspiro) e a resposta ao toque.
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  );
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
    value: 0.5,
  );

  static const _morph = Interval(0, 0.5, curve: Curves.easeOutBack);
  static const _fade = Interval(0, 0.4, curve: Curves.easeOut);
  static const _gesture = Interval(0.3, 1);

  CloudFace? _fromFace;
  _Expression _from = _Expression.neutro;
  Timer? _delay;
  Timer? _nextBlink;
  Timer? _nextIdle;
  bool _still = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    if (widget.react && widget.face != CloudFace.carregando) {
      _fromFace = CloudFace.carregando;
    } else {
      _react.value = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_still) {
      _delay?.cancel();
      _appear.value = 1;
      _react.value = 1;
      _float.stop();
      _nextBlink?.cancel();
      _nextIdle?.cancel();
      return;
    }
    precacheImage(AssetImage(widget.face.body), context);
    if (!_started) {
      _started = true;
      _appear.forward();
      if (_react.value < 1) {
        _delay = Timer(widget.reactDelay, () {
          if (mounted) _react.forward(from: 0);
        });
      }
    }
    _syncIdle();
  }

  @override
  void didUpdateWidget(CloudMascot old) {
    super.didUpdateWidget(old);
    if (old.face == widget.face) return;
    _delay?.cancel();
    _from = _current(old.face);
    _fromFace = old.face;
    if (_still) {
      _react.value = 1;
    } else {
      _react.forward(from: 0);
      _syncIdle();
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _nextBlink?.cancel();
    _nextIdle?.cancel();
    _appear.dispose();
    _react.dispose();
    _blink.dispose();
    _idle.dispose();
    _float.dispose();
    super.dispose();
  }

  /// Rosto neste instante — ponto de partida se a cara mudar no meio.
  /// Fora da troca devolve a própria cara (mesma instância): o pintor não
  /// repinta enquanto a nuvem só respira ou pula.
  _Expression _current(CloudFace target) {
    final t = _react.value;
    if (t >= 1) return target._expression;
    if (t <= 0) return _from;
    return _Expression.lerp(_from, target._expression, _morph.transform(t));
  }

  void _syncIdle() {
    if (widget.face == CloudFace.carregando) {
      if (!_float.isAnimating) _float.repeat(reverse: true);
    } else if (_float.isAnimating || _float.value != 0.5) {
      _float.animateTo(0.5, duration: const Duration(milliseconds: 300));
    }
    _nextBlink?.cancel();
    if (widget.face._blinks) _scheduleBlink();
    _nextIdle?.cancel();
    if (widget.face._fidgets) _scheduleIdle();
  }

  void _scheduleBlink() {
    final wait = 2600 + _random.nextInt(2600);
    _nextBlink = Timer(Duration(milliseconds: wait), () async {
      if (!mounted || !widget.face._blinks) return;
      await _blink.forward(from: 0);
      // Às vezes pisca duas vezes, como gente.
      if (mounted && _random.nextDouble() < 0.22) {
        await _blink.forward(from: 0);
      }
      if (mounted && widget.face._blinks) _scheduleBlink();
    });
  }

  void _scheduleIdle() {
    final wait = 4200 + _random.nextInt(4200);
    _nextIdle = Timer(Duration(milliseconds: wait), () {
      if (!mounted || !widget.face._fidgets) return;
      if (!_react.isAnimating) _idle.forward(from: 0);
      _scheduleIdle();
    });
  }

  /// Cutucar o Anan: ele pisca e faz o gesto da cara. Listener (e não
  /// GestureDetector) para não roubar o toque do botão ou card por baixo.
  void _poke(PointerDownEvent _) {
    if (_still || _react.isAnimating) return;
    if (widget.face._blinks) _blink.forward(from: 0);
    _idle.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final height = size * CloudMascot.aspect;
    return ExcludeSemantics(
      child: Listener(
        onPointerDown: _poke,
        child: SizedBox.square(
          dimension: size,
          child: Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _appear,
                _react,
                _blink,
                _idle,
                _float,
              ]),
              builder: (context, _) {
                final t = _react.value;
                final fade = _fade.transform(t);
                // Na troca para arco ou olho caído, o olho fecha de leve no
                // meio do caminho — esconde a forma intermediária.
                final squint = widget.face._squintsOnChange && _fromFace != null
                    ? math.sin(const Interval(0, 0.5).transform(t) * math.pi) *
                          0.7
                    : 0.0;
                final blink =
                    (1 - math.sin(_blink.value * math.pi) * 0.88) *
                    (1 - squint);
                final appear = _appear.value;
                final cloud = SizedBox(
                  width: size,
                  height: height,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_fromFace case final from?
                          when fade < 1 && from != widget.face)
                        _body(from),
                      Opacity(
                        opacity: _fromFace == null || _fromFace == widget.face
                            ? 1
                            : fade,
                        child: _body(widget.face),
                      ),
                      CustomPaint(
                        painter: _FacePainter(
                          expression: _current(widget.face),
                          blink: blink,
                        ),
                      ),
                    ],
                  ),
                );
                return Opacity(
                  opacity: Curves.easeOut.transform(appear.clamp(0.0, 1.0)),
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: _motion(t, size),
                    // Só o transform muda no gesto: o corpo e o rosto ficam
                    // na própria camada e não repintam.
                    child: RepaintBoundary(child: cloud),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(CloudFace face) => Image.asset(
    face.body,
    fit: BoxFit.contain,
    gaplessPlayback: true,
    filterQuality: FilterQuality.medium,
    excludeFromSemantics: true,
  );

  /// Movimento do corpo: entrada (pop), reação à troca de cara, gesto
  /// ocasional e, na espera, a flutuação.
  Matrix4 _motion(double t, double size) {
    final m = Matrix4.identity();
    final pop = Curves.easeOutBack.transform(_appear.value.clamp(0.0, 1.0));
    final grow = 0.82 + 0.18 * pop;
    final float = (_float.value - 0.5) * size * 0.0625;
    m.translateByDouble(0, float, 0, 1);

    final g = _gesture.transform(t);
    if (_fromFace != null && g > 0 && g < 1) {
      _applyGesture(m, widget.face, g, size, strength: 1);
    } else if (_idle.value > 0 && _idle.value < 1) {
      _applyGesture(m, widget.face, _idle.value, size, strength: 0.6);
    }
    if (grow != 1) m.scaleByDouble(grow, grow, 1, 1);
    return m;
  }

  /// Pulo no sucesso, sorriso que sobe no feliz, "não" com a cabeça no
  /// erro, suspiro (afunda e achata) na tristeza.
  static void _applyGesture(
    Matrix4 m,
    CloudFace face,
    double g,
    double size, {
    required double strength,
  }) {
    final arc = math.sin(g * math.pi);
    switch (face) {
      case CloudFace.sucesso:
        final squash = 1 + 0.06 * strength * math.sin(g * math.pi * 2);
        m
          ..translateByDouble(0, -size * 0.12 * strength * arc, 0, 1)
          ..scaleByDouble(1 / squash, squash, 1, 1);
      case CloudFace.feliz:
        final squash = 1 + 0.035 * strength * math.sin(g * math.pi * 2);
        m
          ..translateByDouble(0, -size * 0.06 * strength * arc, 0, 1)
          ..scaleByDouble(1 / squash, squash, 1, 1);
      case CloudFace.erro:
        final shake = math.sin(g * math.pi * 4) * (1 - g);
        m.translateByDouble(size * 0.045 * strength * shake, 0, 0, 1);
      case CloudFace.triste:
        final sigh = 1 - 0.04 * strength * arc;
        m
          ..translateByDouble(0, size * 0.035 * strength * arc, 0, 1)
          ..scaleByDouble(1 + 0.02 * strength * arc, sigh, 1, 1);
      case CloudFace.carregando:
        break;
    }
  }
}

/// O Anan ao lado de uma peça (medalha, selo, baú) — encostado embaixo, à
/// direita, comemorando junto. Não muda o tamanho da peça no layout.
class AnanBeside extends StatelessWidget {
  final Widget child;
  final CloudFace face;
  final double size;

  const AnanBeside({
    super.key,
    required this.child,
    this.face = CloudFace.sucesso,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: -size * 0.8,
          bottom: -size * 0.12,
          child: CloudMascot(face: face, size: size),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Rosto
// ---------------------------------------------------------------------------
//
// Coordenadas em frações da largura do corpo (480 px), medidas nas artes
// originais. Só o olho esquerdo é descrito; o direito é o espelho dele em
// torno de [_Expression.axis].

/// Curva quadrática p0 → c → p1.
class _Curve {
  final Offset p0;
  final Offset c;
  final Offset p1;

  const _Curve(this.p0, this.c, this.p1);

  static _Curve lerp(_Curve a, _Curve b, double t) => _Curve(
    Offset.lerp(a.p0, b.p0, t)!,
    Offset.lerp(a.c, b.c, t)!,
    Offset.lerp(a.p1, b.p1, t)!,
  );
}

/// Olho = dois traços. Fora o X, os dois coincidem — por isso a barra
/// pode se abrir em X sem trocar de desenho.
class _Eye {
  final _Curve a;
  final _Curve b;
  final double stroke;

  const _Eye(this.a, this.b, this.stroke);

  const _Eye.single(_Curve curve, this.stroke) : a = curve, b = curve;

  static _Eye lerp(_Eye x, _Eye y, double t) => _Eye(
    _Curve.lerp(x.a, y.a, t),
    _Curve.lerp(x.b, y.b, t),
    lerpDouble(x.stroke, y.stroke, t)!,
  );
}

/// Boca = forma fechada entre a curva de cima e a de baixo. Iguais, vira
/// um traço (reta, sorriso, boca triste); afastadas, a boca abre.
class _Mouth {
  final double cx;
  final double halfWidth;
  final double endY;
  final double topC;
  final double bottomC;
  final double stroke;

  const _Mouth({
    required this.cx,
    required this.halfWidth,
    required this.endY,
    required this.topC,
    required this.bottomC,
    required this.stroke,
  });

  static _Mouth lerp(_Mouth a, _Mouth b, double t) => _Mouth(
    cx: lerpDouble(a.cx, b.cx, t)!,
    halfWidth: lerpDouble(a.halfWidth, b.halfWidth, t)!,
    endY: lerpDouble(a.endY, b.endY, t)!,
    topC: lerpDouble(a.topC, b.topC, t)!,
    bottomC: lerpDouble(a.bottomC, b.bottomC, t)!,
    stroke: lerpDouble(a.stroke, b.stroke, t)!,
  );
}

class _Expression {
  final double axis;
  final _Eye eye;
  final _Mouth mouth;

  const _Expression({
    required this.axis,
    required this.eye,
    required this.mouth,
  });

  static _Expression lerp(_Expression a, _Expression b, double t) =>
      _Expression(
        axis: lerpDouble(a.axis, b.axis, t)!,
        eye: _Eye.lerp(a.eye, b.eye, t),
        mouth: _Mouth.lerp(a.mouth, b.mouth, t),
      );

  /// Barras em pé, boca reta — a espera.
  static const neutro = _Expression(
    axis: 0.488,
    eye: _Eye(
      _Curve(Offset(0.405, 0.355), Offset(0.405, 0.392), Offset(0.405, 0.429)),
      _Curve(Offset(0.405, 0.355), Offset(0.405, 0.392), Offset(0.405, 0.429)),
      0.074,
    ),
    mouth: _Mouth(
      cx: 0.486,
      halfWidth: 0.034,
      endY: 0.513,
      topC: 0.513,
      bottomC: 0.513,
      stroke: 0.035,
    ),
  );

  /// Barras em pé, sorriso em U.
  static const feliz = _Expression(
    axis: 0.492,
    eye: _Eye(
      _Curve(Offset(0.415, 0.349), Offset(0.415, 0.382), Offset(0.415, 0.415)),
      _Curve(Offset(0.415, 0.349), Offset(0.415, 0.382), Offset(0.415, 0.415)),
      0.075,
    ),
    mouth: _Mouth(
      cx: 0.492,
      halfWidth: 0.055,
      endY: 0.487,
      topC: 0.563,
      bottomC: 0.563,
      stroke: 0.05,
    ),
  );

  /// Olhos em arco (sorrindo de olhos fechados), boca aberta.
  static const sucesso = _Expression(
    axis: 0.496,
    eye: _Eye.single(
      _Curve(Offset(0.337, 0.407), Offset(0.389, 0.333), Offset(0.441, 0.407)),
      0.05,
    ),
    mouth: _Mouth(
      cx: 0.494,
      halfWidth: 0.079,
      endY: 0.466,
      topC: 0.466,
      bottomC: 0.642,
      stroke: 0.036,
    ),
  );

  /// Olhos em X, boca triste.
  static const erro = _Expression(
    axis: 0.496,
    eye: _Eye(
      _Curve(Offset(0.354, 0.368), Offset(0.3975, 0.411), Offset(0.441, 0.454)),
      _Curve(Offset(0.354, 0.454), Offset(0.3975, 0.411), Offset(0.441, 0.368)),
      0.057,
    ),
    mouth: _Mouth(
      cx: 0.496,
      halfWidth: 0.06,
      endY: 0.543,
      topC: 0.475,
      bottomC: 0.475,
      stroke: 0.052,
    ),
  );

  /// Olhos caídos para fora, boca pequena para baixo.
  static const triste = _Expression(
    axis: 0.49,
    eye: _Eye.single(
      _Curve(Offset(0.354, 0.421), Offset(0.3845, 0.4), Offset(0.415, 0.379)),
      0.066,
    ),
    mouth: _Mouth(
      cx: 0.49,
      halfWidth: 0.045,
      endY: 0.494,
      topC: 0.456,
      bottomC: 0.456,
      stroke: 0.042,
    ),
  );
}

class _FacePainter extends CustomPainter {
  final _Expression expression;

  /// 1 = aberto, perto de 0 = fechado.
  final double blink;

  _FacePainter({required this.expression, required this.blink});

  static const _ink = Color(0xFF1E1D1C);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    Offset at(Offset p) => Offset(p.dx * w, p.dy * w);
    final paint = Paint()
      ..color = _ink
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final eye = expression.eye;
    final eyePath = Path();
    for (final c in [eye.a, eye.b]) {
      final p0 = at(c.p0), ctrl = at(c.c), p1 = at(c.p1);
      eyePath
        ..moveTo(p0.dx, p0.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, p1.dx, p1.dy);
    }
    final center = at(
      Offset(
        (eye.a.p0.dx + eye.a.p1.dx + eye.b.p0.dx + eye.b.p1.dx) / 4,
        (eye.a.p0.dy + eye.a.p1.dy + eye.b.p0.dy + eye.b.p1.dy) / 4,
      ),
    );
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = eye.stroke * w;
    final axis = expression.axis * w;
    for (final mirror in [false, true]) {
      canvas.save();
      if (mirror) {
        canvas
          ..translate(axis * 2, 0)
          ..scale(-1, 1);
      }
      // Piscar achata o olho no próprio centro: a barra vira um traço.
      canvas
        ..translate(center.dx, center.dy)
        ..scale(1 + 0.18 * (1 - blink), blink)
        ..translate(-center.dx, -center.dy)
        ..drawPath(eyePath, paint);
      canvas.restore();
    }

    final m = expression.mouth;
    final left = Offset((m.cx - m.halfWidth) * w, m.endY * w);
    final right = Offset((m.cx + m.halfWidth) * w, m.endY * w);
    final mouth = Path()
      ..moveTo(left.dx, left.dy)
      ..quadraticBezierTo(m.cx * w, m.topC * w, right.dx, right.dy)
      ..quadraticBezierTo(m.cx * w, m.bottomC * w, left.dx, left.dy)
      ..close();
    canvas
      ..drawPath(mouth, paint..style = PaintingStyle.fill)
      ..drawPath(
        mouth,
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = m.stroke * w,
      );
  }

  @override
  bool shouldRepaint(_FacePainter old) =>
      old.expression != expression || old.blink != blink;
}
