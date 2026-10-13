import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Onde o nó senta na curva. Positivo = direita.
///
/// Período de 8 nós, igual ao mapa do print: centro, direita, extremo,
/// volta, centro, esquerda. Vizinhos nunca dividem o mesmo x — senão o
/// traço entre eles vira um talo reto.
double windingShift(int index) => math.sin(index * math.pi / 4);

/// O balão fica do lado oposto ao rumo da curva, para o traço sair limpo
/// do círculo. No extremo da tela a curva desce quase reta, então o balão
/// entra para o centro.
bool windingBubbleOnLeft(int index) {
  final here = windingShift(index);
  if (here > 0.75) return true;
  if (here < -0.75) return false;
  return windingShift(index + 1) >= here;
}

/// Mapa de níveis: círculos numa curva larga, o traço liga o centro de cada um.
class WindingTrail extends MultiChildRenderObjectWidget {
  final Color walked;
  final Color track;
  final int waveOffset;

  const WindingTrail({
    super.key,
    required this.walked,
    required this.track,
    this.waveOffset = 0,
    required List<WindingStop> stops,
  }) : super(children: stops);

  @override
  RenderWindingTrail createRenderObject(BuildContext context) {
    return RenderWindingTrail(
      walked: walked,
      track: track,
      waveOffset: waveOffset,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderWindingTrail renderObject,
  ) {
    renderObject
      ..walked = walked
      ..track = track
      ..waveOffset = waveOffset;
  }
}

class WindingStop extends ParentDataWidget<WindingParentData> {
  final double nodeSize;
  final bool passed;

  /// O círculo é o primeiro widget do filho (à esquerda).
  final bool nodeLeading;

  /// O traço mira o centro do filho inteiro — usado quando o nó é um card.
  final bool centerAnchor;

  const WindingStop({
    super.key,
    required this.nodeSize,
    required this.passed,
    this.nodeLeading = true,
    this.centerAnchor = false,
    required super.child,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    final data = renderObject.parentData! as WindingParentData;
    var changed = false;
    if (data.nodeSize != nodeSize) {
      data.nodeSize = nodeSize;
      changed = true;
    }
    if (data.passed != passed) {
      data.passed = passed;
      changed = true;
    }
    if (data.nodeLeading != nodeLeading) {
      data.nodeLeading = nodeLeading;
      changed = true;
    }
    if (data.centerAnchor != centerAnchor) {
      data.centerAnchor = centerAnchor;
      changed = true;
    }
    if (changed) {
      final parent = renderObject.parent;
      if (parent is RenderWindingTrail) parent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => WindingTrail;
}

class WindingParentData extends ContainerBoxParentData<RenderBox> {
  double nodeSize = 56;
  bool passed = false;
  bool nodeLeading = true;
  bool centerAnchor = false;
}

class RenderWindingTrail extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, WindingParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, WindingParentData> {
  RenderWindingTrail({
    required this._walked,
    required this._track,
    required this._waveOffset,
  });

  Color _walked;
  Color _track;
  int _waveOffset;
  final List<Offset> _anchors = [];
  final List<bool> _passed = [];
  final List<Rect> _covers = [];

  Color get walked => _walked;
  set walked(Color value) {
    if (value == _walked) return;
    _walked = value;
    markNeedsPaint();
  }

  Color get track => _track;
  set track(Color value) {
    if (value == _track) return;
    _track = value;
    markNeedsPaint();
  }

  int get waveOffset => _waveOffset;
  set waveOffset(int value) {
    if (value == _waveOffset) return;
    _waveOffset = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! WindingParentData) {
      child.parentData = WindingParentData();
    }
  }

  @override
  void performLayout() {
    final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 360.0;
    final loose = BoxConstraints(maxWidth: width);
    final boxes = <RenderBox>[];
    var maxNode = 56.0;
    var child = firstChild;
    while (child != null) {
      child.layout(loose, parentUsesSize: true);
      final data = child.parentData! as WindingParentData;
      boxes.add(child);
      maxNode = math.max(maxNode, data.nodeSize);
      child = data.nextSibling;
    }

    // A largura do balão não encolhe a curva: só o círculo limita a amplitude.
    final amp = math.max(
      0.0,
      math.min(width * 0.40, width / 2 - maxNode / 2 - 6),
    );

    _anchors.clear();
    _passed.clear();
    _covers.clear();

    // Um passo fixo entre centros. O print é uma serpente uniforme;
    // esticar um vão por causa do balão quebra o traço em pedaços.
    const pitch = 96.0;
    const clearance = 32.0;
    var centerY = boxes.isEmpty ? 0.0 : boxes.first.size.height / 2;

    for (var i = 0; i < boxes.length; i++) {
      final box = boxes[i];
      final data = box.parentData! as WindingParentData;
      final double left;
      final double nodeCx;
      if (data.centerAnchor) {
        // O card desliza de uma borda à outra. A amplitude antiga usava o
        // tamanho do círculo e, com o card largo, tudo caía no meio.
        final travel = math.max(0.0, width - box.size.width);
        final shift = _cardSpread(i + _waveOffset);
        left = travel * (shift + 1) / 2;
        nodeCx = box.size.width / 2;
      } else {
        final cx = width / 2 + windingShift(i + _waveOffset) * amp;
        nodeCx = data.nodeLeading
            ? data.nodeSize / 2
            : math.max(data.nodeSize / 2, box.size.width - data.nodeSize / 2);
        left = (cx - nodeCx)
            .clamp(0.0, math.max(0.0, width - box.size.width))
            .toDouble();
      }
      final top = centerY - box.size.height / 2;
      data.offset = Offset(left, top);
      _anchors.add(Offset(left + nodeCx, centerY));
      _passed.add(data.passed);
      if (data.centerAnchor) {
        _covers.add(Rect.fromLTWH(left, top, box.size.width, box.size.height));
      }

      if (i + 1 < boxes.length) {
        final nextHalf = boxes[i + 1].size.height / 2;
        final gap = data.centerAnchor ? 44.0 : clearance;
        final minCenter = data.offset.dy + box.size.height + gap + nextHalf;
        centerY = math.max(centerY + pitch, minCenter);
      }
    }

    final height = boxes.isEmpty
        ? 0.0
        : (boxes.last.parentData! as WindingParentData).offset.dy +
              boxes.last.size.height +
              8;
    size = constraints.constrain(
      Size(width, math.max(height, constraints.minHeight)),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_anchors.length > 1) {
      final canvas = context.canvas;
      final hideCards = _covers.isNotEmpty;
      if (hideCards) {
        canvas.save();
        // O tracejado para na borda do card. O miolo fica limpo.
        final clip = Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(offset & size);
        for (final rect in _covers) {
          clip.addRect(rect.inflate(2).shift(offset));
        }
        canvas.clipPath(clip);
      }
      final cards = _covers.length == _anchors.length && _covers.length > 1;
      if (cards) {
        _strokeCards(canvas, offset, track, onlyWalked: false);
        _strokeCards(canvas, offset, walked, onlyWalked: true);
      } else {
        _stroke(canvas, offset, track, onlyWalked: false);
        _stroke(canvas, offset, walked, onlyWalked: true);
      }
      if (hideCards) canvas.restore();
    }
    defaultPaint(context, offset);
  }

  /// Sai da base do card de cima e entra na lateral do de baixo — o lado
  /// que está virado para o card anterior.
  void _strokeCards(
    Canvas canvas,
    Offset offset,
    Color color, {
    required bool onlyWalked,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    for (var i = 0; i < _covers.length - 1; i++) {
      if (_passed[i] != onlyWalked) continue;
      final from = _covers[i];
      final to = _covers[i + 1];
      final start = Offset(from.center.dx, from.bottom) + offset;
      final end =
          Offset(
            from.center.dx <= to.center.dx ? to.left : to.right,
            to.center.dy,
          ) +
          offset;
      canvas.drawPath(_dashed(_baseToSide(start, end)), paint);
    }
  }

  /// Desce reto da base e chega deitado na lateral.
  Path _baseToSide(Offset a, Offset b) {
    final dy = b.dy - a.dy;
    final dx = b.dx - a.dx;
    return Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(a.dx, a.dy + dy * 0.62, b.dx - dx * 0.42, b.dy, b.dx, b.dy);
  }

  void _stroke(
    Canvas canvas,
    Offset offset,
    Color color, {
    required bool onlyWalked,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // Um Path só por trecho da mesma cor, depois picotado. A trilha é
    // tracejada e segue a curva, não uma sequência de retas.
    final run = <Offset>[];
    void flush() {
      if (run.length >= 2) {
        canvas.drawPath(_dashed(_flowing(run, offset)), paint);
      }
      run.clear();
    }

    for (var i = 0; i < _anchors.length - 1; i++) {
      if (_passed[i] != onlyWalked) {
        flush();
        continue;
      }
      if (run.isEmpty) run.add(_anchors[i]);
      run.add(_anchors[i + 1]);
    }
    flush();
  }

  /// Catmull-Rom pelos centros: a tangente segue a viagem, em vez de chegar
  /// em pé em cada nó e recomeçar. É isso que faz a linha parecer uma trilha.
  Path _flowing(List<Offset> pts, Offset offset) {
    final p = [for (final q in pts) q + offset];
    final path = Path()..moveTo(p.first.dx, p.first.dy);
    for (var i = 0; i < p.length - 1; i++) {
      final p0 = i == 0 ? p[i] : p[i - 1];
      final p1 = p[i];
      final p2 = p[i + 1];
      final p3 = i + 2 < p.length ? p[i + 2] : p[i + 1];
      var cp1 = _control(p0, p1, p2, p3, incoming: true);
      var cp2 = _control(p0, p1, p2, p3, incoming: false);
      final chord = p2 - p1;
      final span = chord.distance;
      if (span > 24) {
        // Empurra o meio do arco para o lado, para o tracejado serpentear
        // no vão entre os cards em vez de cortar reto.
        final normal = Offset(-chord.dy / span, chord.dx / span);
        final bow = normal * math.min(48.0, span * 0.2) * (i.isEven ? 1 : -1);
        cp1 += bow;
        cp2 += bow;
      }
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  /// Vizinhos em lados opostos, encostando na borda, com um respiro para a
  /// curva não repetir o mesmo arco.
  double _cardSpread(int index) {
    final side = index.isEven ? -1.0 : 1.0;
    final nudge = math.sin(index * 1.7) * 0.16;
    return (side * 0.94 + nudge).clamp(-1.0, 1.0).toDouble();
  }

  Path _dashed(Path source) {
    const dash = 11.0;
    const gap = 8.0;
    final out = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dash, metric.length);
        out.addPath(metric.extractPath(distance, end), Offset.zero);
        distance = end + gap;
      }
    }
    return out;
  }

  /// Conversão centrípeta (alpha 0.5) para Bézier. Não dá laço quando um
  /// vão fica um pouco maior por causa do balão.
  Offset _control(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3, {
    required bool incoming,
  }) {
    double gap(Offset a, Offset b) {
      final d = (b - a).distance;
      return d < 1 ? 1 : math.sqrt(d);
    }

    final dt0 = gap(p0, p1);
    final dt1 = gap(p1, p2);
    final dt2 = gap(p2, p3);
    final t1 = (p1 - p0) / dt0 - (p2 - p0) / (dt0 + dt1) + (p2 - p1) / dt1;
    final t2 = (p2 - p1) / dt1 - (p3 - p1) / (dt1 + dt2) + (p3 - p2) / dt2;
    if (incoming) return p1 + t1 * dt1 / 3;
    return p2 - t2 * dt1 / 3;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

/// Círculo de nível, com o lábio de baixo do botão.
class PathNode extends StatelessWidget {
  final double size;
  final Color fill;
  final Color? glow;
  final Widget child;

  const PathNode({
    super.key,
    required this.size,
    required this.fill,
    this.glow,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final lip = Color.lerp(fill, const Color(0xFF1A2433), 0.28)!;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 5,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, color: lip),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fill,
                boxShadow: glow == null
                    ? null
                    : [
                        BoxShadow(
                          color: glow!.withValues(alpha: 0.45),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
              ),
              child: Center(child: child),
            ),
          ),
        ],
      ),
    );
  }
}
