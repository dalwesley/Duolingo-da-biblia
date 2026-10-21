import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../theme/app_theme.dart';
import 'journey_phase_card.dart';

/// Onde o nó senta na curva. Positivo = direita.
///
/// Período de 8 nós, igual ao mapa do print: centro, direita, extremo,
/// volta, centro, esquerda. Vizinhos nunca dividem o mesmo x — senão o
/// traço entre eles vira um talo reto.
double windingShift(int index) => math.sin(index * math.pi / 4);

/// Quanto o Anan entra no card. O resto fica na trilha, fora do título.
const _walkerTuck = 10.0;

/// Curva de pegadas; as andadas avançam no trecho percorrido.
/// Anima só a pintura; os cards não rebuildam.
class FlowingWindingTrail extends StatefulWidget {
  final Color walked;
  final Color track;
  final int waveOffset;
  final List<WindingStop> stops;

  /// false: as pegadas param onde a pessoa já chegou. O trilho segue.
  final bool showAhead;

  /// O Anan, fora da curva. Senta onde as pegadas chegam — na lateral do
  /// card, ou na base quando o trilho nasce nele.
  final Widget? walker;

  const FlowingWindingTrail({
    super.key,
    required this.walked,
    required this.track,
    this.waveOffset = 0,
    this.showAhead = true,
    this.walker,
    required this.stops,
  });

  @override
  State<FlowingWindingTrail> createState() => _FlowingWindingTrailState();
}

class _FlowingWindingTrailState extends State<FlowingWindingTrail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flow;

  @override
  void initState() {
    super.initState();
    _flow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _flow.stop();
      _flow.value = 0;
    } else if (!_flow.isAnimating) {
      _flow.repeat();
    }
  }

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WindingTrail(
      walked: widget.walked,
      track: widget.track,
      waveOffset: widget.waveOffset,
      showAhead: widget.showAhead,
      flow: _flow,
      stops: [...widget.stops, if (widget.walker != null) widget.walker!],
    );
  }
}

/// Mapa de níveis: círculos numa curva larga, o traço liga o centro de cada um.
class WindingTrail extends MultiChildRenderObjectWidget {
  final Color walked;
  final Color track;
  final int waveOffset;
  final bool showAhead;

  /// Quando ligado, o picote do trecho andado corre com o ticker.
  final Animation<double>? flow;

  const WindingTrail({
    super.key,
    required this.walked,
    required this.track,
    this.waveOffset = 0,
    this.showAhead = true,
    this.flow,
    required List<Widget> stops,
  }) : super(children: stops);

  @override
  RenderWindingTrail createRenderObject(BuildContext context) {
    return RenderWindingTrail(
      walked: walked,
      track: track,
      waveOffset: waveOffset,
      showAhead: showAhead,
      flow: flow,
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
      ..waveOffset = waveOffset
      ..showAhead = showAhead
      ..flow = flow;
  }
}

class WindingStop extends ParentDataWidget<WindingParentData> {
  final double nodeSize;
  final bool passed;

  /// O círculo é o primeiro widget do filho (à esquerda).
  final bool nodeLeading;

  /// O traço mira o centro do filho inteiro — usado quando o nó é um card.
  final bool centerAnchor;

  /// Marco de fase. O traço chega no topo e sai pela base, por baixo do card.
  final bool gate;

  /// Estação atual — a pedra no vão que chega aqui vira farol.
  final bool beacon;

  const WindingStop({
    super.key,
    required this.nodeSize,
    required this.passed,
    this.nodeLeading = true,
    this.centerAnchor = false,
    this.gate = false,
    this.beacon = false,
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
    if (data.gate != gate) {
      data.gate = gate;
      changed = true;
    }
    if (data.beacon != beacon) {
      data.beacon = beacon;
      changed = true;
    }
    if (data.walker) {
      data.walker = false;
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

/// Companheiro da curva. Não é parada: senta na chegada das pegadas.
class WindingWalker extends ParentDataWidget<WindingParentData> {
  const WindingWalker({super.key, required super.child});

  @override
  void applyParentData(RenderObject renderObject) {
    final data = renderObject.parentData! as WindingParentData;
    if (data.walker) return;
    data.walker = true;
    final parent = renderObject.parent;
    if (parent is RenderWindingTrail) parent.markNeedsLayout();
  }

  @override
  Type get debugTypicalAncestorWidgetClass => WindingTrail;
}

class WindingParentData extends ContainerBoxParentData<RenderBox> {
  double nodeSize = 56;
  bool passed = false;
  bool nodeLeading = true;
  bool centerAnchor = false;
  bool gate = false;
  bool beacon = false;
  bool walker = false;
}

/// Trecho já medido. O ticker só desloca as pegadas; a curva não se refaz.
class _TrailStroke {
  _TrailStroke({required this.path, required this.lit, required this.width})
    : metrics = path.computeMetrics().toList(growable: false);

  final Path path;
  final bool lit;
  final double width;
  final List<ui.PathMetric> metrics;
}

class RenderWindingTrail extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, WindingParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, WindingParentData> {
  RenderWindingTrail({
    required this._walked,
    required this._track,
    required this._waveOffset,
    required this._showAhead,
    this._flow,
  });

  Color _walked;
  Color _track;
  int _waveOffset;
  bool _showAhead;
  Animation<double>? _flow;
  bool _walkerVisible = false;
  final List<Offset> _anchors = [];
  final List<bool> _passed = [];
  final List<bool> _beacon = [];
  final List<Rect> _bounds = [];
  final List<bool> _isStop = [];
  final List<Rect?> _openings = [];
  final List<Path> _covers = [];
  final List<_TrailStroke> _strokes = [];
  Path? _clip;
  bool _linkEdges = false;

  final Paint _foot = Paint()..isAntiAlias = true;

  double get _dashPhase => -(_flow?.value ?? 0) * 13;

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

  bool get showAhead => _showAhead;
  set showAhead(bool value) {
    if (value == _showAhead) return;
    _showAhead = value;
    markNeedsPaint();
  }

  Animation<double>? get flow => _flow;
  set flow(Animation<double>? value) {
    if (identical(value, _flow)) return;
    if (attached) _flow?.removeListener(_onFlow);
    _flow = value;
    if (attached) _flow?.addListener(_onFlow);
    markNeedsPaint();
  }

  void _onFlow() => markNeedsPaint();

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _flow?.addListener(_onFlow);
  }

  @override
  void detach() {
    _flow?.removeListener(_onFlow);
    super.detach();
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
    RenderBox? walker;
    var maxNode = 56.0;
    var child = firstChild;
    while (child != null) {
      child.layout(loose, parentUsesSize: true);
      final data = child.parentData! as WindingParentData;
      if (data.walker) {
        walker = child;
      } else {
        boxes.add(child);
        maxNode = math.max(maxNode, data.nodeSize);
      }
      child = data.nextSibling;
    }

    // A largura do balão não encolhe a curva: só o círculo limita a amplitude.
    final amp = math.max(
      0.0,
      math.min(width * 0.40, width / 2 - maxNode / 2 - 6),
    );

    _anchors.clear();
    _passed.clear();
    _beacon.clear();
    _bounds.clear();
    _isStop.clear();
    _openings.clear();
    _covers.clear();
    _strokes.clear();
    _clip = null;
    _linkEdges = false;

    // Um passo fixo entre centros. O print é uma serpente uniforme;
    // esticar um vão por causa do balão quebra o traço em pedaços.
    const pitch = 96.0;
    const clearance = 32.0;
    var centerY = boxes.isEmpty ? 0.0 : boxes.first.size.height / 2;
    var spread = _waveOffset;

    for (var i = 0; i < boxes.length; i++) {
      final box = boxes[i];
      final data = box.parentData! as WindingParentData;
      final double left;
      final double nodeCx;
      if (data.gate) {
        left = math.max(0.0, (width - box.size.width) / 2);
        nodeCx = box.size.width / 2;
        _linkEdges = true;
      } else if (data.centerAnchor) {
        // O card desliza de uma borda à outra. A amplitude antiga usava o
        // tamanho do círculo e, com o card largo, tudo caía no meio.
        // Respiro lateral — o marco de fase (gate) ocupa a largura toda.
        const inset = 12.0;
        final travel = math.max(0.0, width - box.size.width - inset * 2);
        final shift = _cardSpread(spread);
        left = inset + travel * (shift + 1) / 2;
        nodeCx = box.size.width / 2;
        spread++;
        _linkEdges = true;
      } else {
        final cx = width / 2 + windingShift(i + _waveOffset) * amp;
        nodeCx = data.nodeLeading
            ? data.nodeSize / 2
            : math.max(data.nodeSize / 2, box.size.width - data.nodeSize / 2);
        left = (cx - nodeCx)
            .clamp(0.0, math.max(0.0, width - box.size.width))
            .toDouble();
        spread++;
      }
      final top = centerY - box.size.height / 2;
      data.offset = Offset(left, top);
      final bounds = Rect.fromLTWH(left, top, box.size.width, box.size.height);
      _bounds.add(bounds);
      _anchors.add(Offset(left + nodeCx, centerY));
      _passed.add(data.passed);
      _beacon.add(data.beacon);
      _isStop.add(data.gate);
      if (data.gate) {
        _openings.add(bounds);
        _covers.add(journeyPhaseTicketPath(bounds));
      } else {
        _openings.add(null);
        if (data.centerAnchor) {
          _covers.add(Path()..addRect(bounds.inflate(2)));
        }
      }

      if (i + 1 < boxes.length) {
        final next = boxes[i + 1];
        final nextData = next.parentData! as WindingParentData;
        final nextHalf = next.size.height / 2;
        final betweenPhases = data.gate || nextData.gate;
        final gap = data.centerAnchor || data.gate
            ? (betweenPhases ? 48.0 : 22.0)
            : clearance;
        // O Anan senta na base do primeiro card. O próximo precisa caber
        // abaixo dele, senão a nuvem cobre o título de quem vem depois.
        final ananBelow =
            walker != null &&
            i == 0 &&
            !data.gate &&
            !data.passed &&
            data.beacon;
        final room = ananBelow ? walker.size.height - _walkerTuck + 8 : 0.0;
        final minCenter =
            data.offset.dy + box.size.height + math.max(gap, room) + nextHalf;
        centerY = math.max(centerY + pitch, minCenter);
      }
    }

    var height = boxes.isEmpty
        ? 0.0
        : (boxes.last.parentData! as WindingParentData).offset.dy +
              boxes.last.size.height +
              8;
    _walkerVisible = false;
    if (walker != null) {
      final placed = _placeWalker(walker, width);
      if (placed) {
        _walkerVisible = true;
        final data = walker.parentData! as WindingParentData;
        height = math.max(height, data.offset.dy + walker.size.height + 8);
      }
    }
    size = constraints.constrain(
      Size(width, math.max(height, constraints.minHeight)),
    );
    _cacheStrokes();
    _cacheClip();
  }

  /// O Anan na entrada do card onde o trecho andado termina.
  /// Concluir a trilha marca o card como passado e o traço segue até o próximo.
  /// Sem marco acima, o trilho nasce na base do primeiro card — é ali que ele senta.
  bool _placeWalker(RenderBox walker, double width) {
    final arrival = _arrivalIndex();
    if (arrival == null) return false;
    final bounds = _bounds[arrival];
    final data = walker.parentData! as WindingParentData;
    final w = walker.size.width;
    final h = walker.size.height;
    // Encosta na borda, quase todo para fora, para não cobrir o título.
    const tuck = _walkerTuck;
    final double left;
    final double top;
    if (arrival == 0 && !_isStop[arrival]) {
      final at = _leave(arrival);
      left = at.dx - w / 2;
      top = at.dy - tuck;
    } else {
      final at = _arrivalPoint(arrival);
      if (_isStop[arrival]) {
        left = at.dx - w / 2;
        top = at.dy - h + tuck;
      } else {
        final onLeft = at.dx <= bounds.center.dx;
        left = onLeft ? at.dx - w + tuck : at.dx - tuck;
        top = at.dy - h / 2;
      }
    }
    data.offset = Offset(
      left.clamp(0.0, math.max(0.0, width - w)).toDouble(),
      math.max(0.0, top),
    );
    return true;
  }

  /// Último card alcançado pelas pegadas. Sem trecho andado, a estação atual.
  int? _arrivalIndex() {
    int? arrival;
    for (var i = 0; i < _passed.length - 1; i++) {
      if (_passed[i]) arrival = i + 1;
    }
    if (arrival != null) return arrival;
    for (var i = 0; i < _beacon.length; i++) {
      if (_beacon[i]) return i;
    }
    return null;
  }

  Offset _arrivalPoint(int i) {
    final bounds = _bounds[i];
    if (i <= 0 || _isStop[i]) return Offset(bounds.center.dx, bounds.top);
    return _approach(i);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_strokes.isNotEmpty) {
      final canvas = context.canvas;
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      final clip = _clip;
      if (clip != null) canvas.clipPath(clip);
      _paintStrokes(canvas);
      canvas.restore();
    }
    if (_walkerVisible) {
      defaultPaint(context, offset);
      return;
    }
    var child = firstChild;
    while (child != null) {
      final data = child.parentData! as WindingParentData;
      if (!data.walker) {
        context.paintChild(child, offset + data.offset);
      }
      child = data.nextSibling;
    }
  }

  /// A curva e o recorte dos cards nascem no layout. O frame só carimba.
  void _cacheStrokes() {
    _strokes.clear();
    if (_anchors.length < 2) return;
    if (_linkEdges && _bounds.length > 1) {
      for (var i = 0; i < _bounds.length - 1; i++) {
        final start = _leave(i);
        final end = _approach(i + 1);
        final path = _isStop[i + 1]
            ? _intoStop(start, end)
            : _baseToSide(start, end);
        final shaft = _openings[i + 1];
        if (shaft != null) {
          path.lineTo(shaft.center.dx, shaft.bottom);
        }
        _strokes.add(_TrailStroke(path: path, lit: _passed[i], width: 10));
      }
      return;
    }
    _appendRun(onlyWalked: false);
    _appendRun(onlyWalked: true);
  }

  void _appendRun({required bool onlyWalked}) {
    final run = <Offset>[];
    void flush() {
      if (run.length >= 2) {
        _strokes.add(
          _TrailStroke(
            path: _flowing(run, Offset.zero),
            lit: onlyWalked,
            width: 9,
          ),
        );
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

  void _cacheClip() {
    if (_covers.isEmpty) {
      _clip = null;
      return;
    }
    // O tracejado para na borda do card. O miolo fica limpo.
    final clip = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);
    for (final cover in _covers) {
      clip.addPath(cover, Offset.zero);
    }
    _clip = clip;
  }

  void _paintStrokes(Canvas canvas) {
    final phase = _dashPhase;
    for (final stroke in _strokes) {
      if (!stroke.lit && !_showAhead) {
        _paintOpenPath(canvas, stroke);
        continue;
      }
      final color = stroke.lit ? _walked : _track;
      _foot.color = color.withValues(alpha: stroke.lit ? 0.95 : 0.55);
      _stampFeet(
        canvas,
        stroke.metrics,
        phase: stroke.lit ? phase : 0,
        lit: stroke.lit,
      );
    }
  }

  /// Tracejado fino na mesma curva das pegadas. As pegadas ficam no trecho concluído.
  void _paintOpenPath(Canvas canvas, _TrailStroke stroke) {
    const dash = 4.5;
    const gap = 3.5;
    const thick = 1.2;
    final mark = Paint()
      ..color = _walked.withValues(alpha: 0.82)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    for (final metric in stroke.metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dash, metric.length);
        final span = end - distance;
        if (span > 1.2) {
          final tangent = metric.getTangentForOffset((distance + end) / 2);
          if (tangent != null) {
            canvas.save();
            canvas.translate(tangent.position.dx, tangent.position.dy);
            canvas.rotate(tangent.angle);
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromCenter(
                  center: Offset.zero,
                  width: span,
                  height: thick,
                ),
                const Radius.circular(0.6),
              ),
              mark,
            );
            canvas.restore();
          }
        }
        distance = end + gap;
      }
    }
  }

  /// Base do card — no marco de fase, o centro da base.
  Offset _leave(int i) {
    final shaft = _openings[i];
    if (shaft != null) return Offset(shaft.center.dx, shaft.bottom);
    final bounds = _bounds[i];
    return Offset(bounds.center.dx, bounds.bottom);
  }

  /// Lateral do próximo card — no marco de fase, o centro do topo.
  Offset _approach(int i) {
    final shaft = _openings[i];
    if (shaft != null) return Offset(shaft.center.dx, shaft.top);
    final bounds = _bounds[i];
    final fromX = _leave(i - 1).dx;
    final onLeft = fromX <= bounds.center.dx;
    return Offset(onLeft ? bounds.left : bounds.right, bounds.center.dy);
  }

  /// Desce da base e entra na lateral numa dobra só, sempre do mesmo raio.
  /// A quina fica no vão, fora dos cards, para o tracejado não partir.
  Path _baseToSide(Offset a, Offset b) {
    final path = Path()..moveTo(a.dx, a.dy);
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    if (dy < 6) {
      path.lineTo(b.dx, b.dy);
      return path;
    }
    final dir = dx >= 0 ? 1.0 : -1.0;
    final adx = dx.abs();
    // Curva larga: o cotovelo de 40 px lia como ângulo reto no tracejado.
    final radius = math.min(72.0, math.min(dy, adx) * 0.92);
    if (radius < 12) {
      path.cubicTo(a.dx, a.dy + dy * 0.55, b.dx - dx * 0.2, b.dy, b.dx, b.dy);
      return path;
    }
    final corner = Offset(a.dx, b.dy);
    path
      ..lineTo(a.dx, corner.dy - radius)
      ..quadraticBezierTo(corner.dx, corner.dy, a.dx + dir * radius, b.dy)
      ..lineTo(b.dx, b.dy);
    return path;
  }

  /// Chega no topo do marco de fase. A curva fica acima do card.
  Path _intoStop(Offset a, Offset b) {
    final path = Path()..moveTo(a.dx, a.dy);
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    if (dy < 8 || dx.abs() < 8) {
      path.lineTo(b.dx, b.dy);
      return path;
    }
    final dir = dx >= 0 ? 1.0 : -1.0;
    final radius = math.min(16.0, math.min(dy * 0.42, dx.abs() * 0.45));
    if (dx.abs() < radius * 2 + 4) {
      path.cubicTo(a.dx, a.dy + dy * 0.55, b.dx, b.dy - dy * 0.45, b.dx, b.dy);
      return path;
    }
    final railY = a.dy + dy * 0.5;
    path
      ..lineTo(a.dx, railY - radius)
      ..quadraticBezierTo(a.dx, railY, a.dx + dir * radius, railY)
      ..lineTo(b.dx - dir * radius, railY)
      ..quadraticBezierTo(b.dx, railY, b.dx, railY + radius)
      ..lineTo(b.dx, b.dy);
    return path;
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

  /// Pegadas ao longo da curva — esquerda/direita, alinhadas à tangente.
  void _stampFeet(
    Canvas canvas,
    List<ui.PathMetric> metrics, {
    double phase = 0,
    required bool lit,
  }) {
    const step = 20.0;
    for (final metric in metrics) {
      var distance = -((phase % step) + step) % step;
      var leftFoot = true;
      while (distance < metric.length) {
        if (distance >= 0) {
          final tangent = metric.getTangentForOffset(distance);
          if (tangent != null) {
            _drawFootprint(
              canvas,
              tangent.position,
              tangent.angle,
              left: leftFoot,
              paint: _foot,
              lit: lit,
            );
          }
        }
        leftFoot = !leftFoot;
        distance += step;
      }
    }
  }

  void _drawFootprint(
    Canvas canvas,
    Offset at,
    double angle, {
    required bool left,
    required Paint paint,
    required bool lit,
  }) {
    final scale = lit ? 1.05 : 0.9;
    final side = left ? -1.0 : 1.0;
    final normal = Offset(-math.sin(angle), math.cos(angle));
    final center = at + normal * (3.4 * side * scale);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    // Tangente 0 = +X; a sola aponta “para frente” no caminho.
    canvas.rotate(angle - math.pi / 2);

    // Planta
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, -1.2 * scale),
        width: 5.2 * scale,
        height: 8.2 * scale,
      ),
      paint,
    );
    // Calcanhar
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, 4.0 * scale),
        width: 4.0 * scale,
        height: 3.6 * scale,
      ),
      paint,
    );
    // Dedos
    for (var i = 0; i < 5; i++) {
      final tx = (i - 2) * 1.2 * scale;
      final ty = (-6.0 - (i == 2 ? 1.0 : 0.35)) * scale;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(tx, ty),
          width: 1.35 * scale,
          height: 1.85 * scale,
        ),
        paint,
      );
    }
    canvas.restore();
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
    if (_walkerVisible) {
      return defaultHitTestChildren(result, position: position);
    }
    var child = lastChild;
    while (child != null) {
      final data = child.parentData! as WindingParentData;
      final box = child;
      if (!data.walker) {
        final hit = result.addWithPaintOffset(
          offset: data.offset,
          position: position,
          hitTest: (result, transformed) {
            return box.hitTest(result, position: transformed);
          },
        );
        if (hit) return true;
      }
      child = data.previousSibling;
    }
    return false;
  }
}
