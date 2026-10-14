import 'dart:math' as math;

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

/// O balão fica do lado oposto ao rumo da curva, para o traço sair limpo
/// do círculo. No extremo da tela a curva desce quase reta, então o balão
/// entra para o centro.
bool windingBubbleOnLeft(int index) {
  final here = windingShift(index);
  if (here > 0.75) return true;
  if (here < -0.75) return false;
  return windingShift(index + 1) >= here;
}

/// Curva com tracejado que corre no trecho andado — o mapa “vive”.
/// Anima só a pintura; os cards não rebuildam.
class FlowingWindingTrail extends StatefulWidget {
  final Color walked;
  final Color track;
  final int waveOffset;
  final List<WindingStop> stops;

  const FlowingWindingTrail({
    super.key,
    required this.walked,
    required this.track,
    this.waveOffset = 0,
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
      flow: _flow,
      stops: widget.stops,
    );
  }
}

/// Mapa de níveis: círculos numa curva larga, o traço liga o centro de cada um.
class WindingTrail extends MultiChildRenderObjectWidget {
  final Color walked;
  final Color track;
  final int waveOffset;

  /// Quando ligado, o picote do trecho andado corre com o ticker.
  final Animation<double>? flow;

  const WindingTrail({
    super.key,
    required this.walked,
    required this.track,
    this.waveOffset = 0,
    this.flow,
    required List<WindingStop> stops,
  }) : super(children: stops);

  @override
  RenderWindingTrail createRenderObject(BuildContext context) {
    return RenderWindingTrail(
      walked: walked,
      track: track,
      waveOffset: waveOffset,
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
  bool gate = false;
  bool beacon = false;
}

class RenderWindingTrail extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, WindingParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, WindingParentData> {
  RenderWindingTrail({
    required this._walked,
    required this._track,
    required this._waveOffset,
    this._flow,
  });

  Color _walked;
  Color _track;
  int _waveOffset;
  Animation<double>? _flow;
  final List<Offset> _anchors = [];
  final List<bool> _passed = [];
  final List<bool> _beacon = [];
  final List<Rect> _bounds = [];
  final List<bool> _isStop = [];
  final List<Rect?> _openings = [];
  final List<Path> _covers = [];
  bool _linkEdges = false;

  double get _dashPhase => (_flow?.value ?? 0) * 13;

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
    _beacon.clear();
    _bounds.clear();
    _isStop.clear();
    _openings.clear();
    _covers.clear();
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
        for (final cover in _covers) {
          clip.addPath(cover.shift(offset), Offset.zero);
        }
        canvas.clipPath(clip);
      }
      final cards = _linkEdges && _bounds.length > 1;
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
      ..strokeWidth = onlyWalked ? 4.0 : 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final glowPaint = onlyWalked
        ? (Paint()
            ..color = color.withValues(alpha: 0.38)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7)
            ..isAntiAlias = true)
        : null;

    for (var i = 0; i < _bounds.length - 1; i++) {
      if (_passed[i] != onlyWalked) continue;
      final start = _leave(i) + offset;
      final end = _approach(i + 1) + offset;
      final path = _isStop[i + 1]
          ? _intoStop(start, end)
          : _baseToSide(start, end);
      final shaft = _openings[i + 1];
      if (shaft != null) {
        path.lineTo(shaft.center.dx + offset.dx, shaft.bottom + offset.dy);
      }
      if (glowPaint != null) {
        canvas.drawPath(path, glowPaint);
      }
      canvas.drawPath(
        _dashed(path, phase: onlyWalked ? _dashPhase : 0),
        paint,
      );
      final intoBeacon =
          i + 1 < _beacon.length && _beacon[i + 1] && onlyWalked;
      _paintWaypoints(
        canvas,
        start,
        end,
        color,
        lit: onlyWalked,
        beacon: intoBeacon,
      );
    }
  }

  /// Pedra no vão — mesmo lábio do [PathNode], em pintura.
  void _paintWaypoints(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color, {
    required bool lit,
    bool beacon = false,
  }) {
    final mid = Offset(
      (start.dx + end.dx) / 2,
      (start.dy + end.dy) / 2,
    );
    final r = beacon ? 9.0 : (lit ? 6.5 : 5.0);
    final lip = Color.lerp(color, const Color(0xFF1A2433), 0.32)!;
    final fill = lit || beacon
        ? color
        : Color.lerp(color, const Color(0xFF1A2433), 0.45)!;

    // Lábio de baixo (profundidade de botão).
    canvas.drawCircle(
      mid.translate(0, beacon ? 2.4 : 1.8),
      r,
      Paint()..color = lip.withValues(alpha: lit || beacon ? 0.95 : 0.7),
    );
    if (lit || beacon) {
      canvas.drawCircle(
        mid,
        r + (beacon ? 7 : 3),
        Paint()
          ..color = color.withValues(alpha: beacon ? 0.38 : 0.22)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            beacon ? 6 : 3.5,
          ),
      );
    }
    canvas.drawCircle(mid, r, Paint()..color = fill);
    canvas.drawCircle(
      mid.translate(0, -0.6),
      r * (beacon ? 0.42 : 0.38),
      Paint()
        ..color = AppColors.textOnDark.withValues(
          alpha: lit || beacon ? 0.6 : 0.28,
        ),
    );
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
    final radius = math.min(40.0, math.min(dy, adx) * 0.92);
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

  void _stroke(
    Canvas canvas,
    Offset offset,
    Color color, {
    required bool onlyWalked,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = onlyWalked ? 4.0 : 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final glowPaint = onlyWalked
        ? (Paint()
            ..color = color.withValues(alpha: 0.34)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 9
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
            ..isAntiAlias = true)
        : null;

    // Um Path só por trecho da mesma cor, depois picotado. A trilha é
    // tracejada e segue a curva, não uma sequência de retas.
    final run = <Offset>[];
    void flush() {
      if (run.length >= 2) {
        final flowing = _flowing(run, offset);
        if (glowPaint != null) canvas.drawPath(flowing, glowPaint);
        canvas.drawPath(
          _dashed(flowing, phase: onlyWalked ? _dashPhase : 0),
          paint,
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

  Path _dashed(Path source, {double phase = 0}) {
    const dash = 8.0;
    const gap = 5.0;
    final period = dash + gap;
    final out = Path();
    for (final metric in source.computeMetrics()) {
      var distance = -((phase % period) + period) % period;
      while (distance < metric.length) {
        final start = math.max(0.0, distance);
        final end = math.min(distance + dash, metric.length);
        if (end > start) {
          out.addPath(metric.extractPath(start, end), Offset.zero);
        }
        distance += period;
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
