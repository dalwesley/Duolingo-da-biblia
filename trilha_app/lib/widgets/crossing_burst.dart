import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';

enum CrossingMode {
  /// Os dois caminham até a bandeira e ela se abre — convite ou aceite.
  start,

  /// Eu perco a cor e volto pelo caminho; a outra pessoa fica na bandeira.
  leave,
}

/// Quem aparece na animação.
class CrossingPerson {
  final String name;
  final String? photoUrl;
  final String? seed;

  const CrossingPerson({required this.name, this.photoUrl, this.seed});
}

/// Travessia por cima de tudo. Não bloqueia toques.
///
/// Completa quando a animação some — rede e rebuilds pesados vêm depois,
/// para não roubar frame da animação.
Future<void> showCrossingBurst(
  BuildContext context, {
  required CrossingPerson me,
  required CrossingPerson them,
  PortraitStyle portrait = PortraitStyle.photo,
  String? caption,
  String? kicker,
  CrossingMode mode = CrossingMode.start,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return Future.value();
  final done = Completer<void>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => RepaintBoundary(
      child: _CrossingBurst(
        me: me,
        them: them,
        portrait: portrait,
        caption: caption,
        kicker: kicker,
        mode: mode,
        onDone: () {
          entry.remove();
          if (!done.isCompleted) done.complete();
        },
      ),
    ),
  );
  overlay.insert(entry);
  return done.future;
}

double _span(double t, double a, double b) =>
    ((t - a) / (b - a)).clamp(0.0, 1.0);

/// Geometria da cena, relativa ao centro de uma caixa de 320×320.
class _Stage {
  static const box = 320.0;
  static const avatar = 30.0; // raio
  static const poleBase = Offset(0, 96);
  static const poleTop = Offset(0, -70);

  static Offset _bezier(Offset a, Offset b, Offset c, Offset d, double u) {
    final v = 1 - u;
    return a * (v * v * v) +
        b * (3 * v * v * u) +
        c * (3 * v * u * u) +
        d * (u * u * u);
  }

  /// Caminho de cada um: sobe do canto de baixo até o pé da bandeira.
  static Offset path(bool left, double u) {
    final s = left ? -1.0 : 1.0;
    return _bezier(
      Offset(150 * s, 250),
      Offset(185 * s, 120),
      Offset(120 * s, 40),
      Offset(52 * s, 62),
      u,
    );
  }
}

class _CrossingBurst extends StatefulWidget {
  final CrossingPerson me;
  final CrossingPerson them;
  final PortraitStyle portrait;
  final String? caption;
  final String? kicker;
  final CrossingMode mode;
  final VoidCallback onDone;

  const _CrossingBurst({
    required this.me,
    required this.them,
    required this.portrait,
    required this.caption,
    required this.kicker,
    required this.mode,
    required this.onDone,
  });

  @override
  State<_CrossingBurst> createState() => _CrossingBurstState();
}

class _CrossingBurstState extends State<_CrossingBurst>
    with SingleTickerProviderStateMixin {
  static const _arriveAt = 0.44;
  static const _leaveAt = 0.3;

  late final AnimationController _c;
  final _motes = <_Mote>[];
  bool _beat = false;

  bool get _start => widget.mode == CrossingMode.start;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    for (var i = 0; i < 22; i++) {
      _motes.add(
        _Mote(
          angle: rnd.nextDouble() * math.pi * 2,
          reach: 40 + rnd.nextDouble() * 90,
          rise: 60 + rnd.nextDouble() * 110,
          size: 1.4 + rnd.nextDouble() * 2.2,
          delay: rnd.nextDouble() * 0.3,
          phase: rnd.nextDouble() * math.pi * 2,
          warm: rnd.nextBool(),
        ),
      );
    }
    _c =
        AnimationController(
            vsync: this,
            duration: Duration(milliseconds: _start ? 2600 : 1900),
          )
          ..addListener(_onTick)
          ..addStatusListener((s) {
            if (s == AnimationStatus.completed) widget.onDone();
          });
    // Primeiro frame (layout, fotos, shaders) fica fora do relógio.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ActHaptics.light();
      _c.forward();
    });
  }

  void _onTick() {
    if (_beat) return;
    if (_start && _c.value >= _arriveAt) {
      _beat = true;
      // Chegada: um batido forte e dois leves, como passos que param juntos.
      ActHaptics.success();
      Future.delayed(const Duration(milliseconds: 110), ActHaptics.confirm);
      Future.delayed(const Duration(milliseconds: 240), ActHaptics.light);
    } else if (!_start && _c.value >= _leaveAt) {
      _beat = true;
      ActHaptics.confirm();
      Future.delayed(const Duration(milliseconds: 220), ActHaptics.light);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) =>
            _start ? _buildStart(_c.value) : _buildLeave(_c.value),
      ),
    );
  }

  Widget _buildStart(double t) {
    final alpha = _span(t, 0, 0.08) * (1 - _span(t, 0.84, 1));
    final walk = Curves.easeInOutCubic.transform(_span(t, 0.06, _arriveAt));
    final arrived = t >= _arriveAt;
    final pop = Curves.easeOutBack.transform(_span(t, 0, 0.12));
    // Pulinho ao chegar.
    final bump = arrived
        ? math.sin(_span(t, _arriveAt, _arriveAt + 0.14) * math.pi) * 0.14
        : 0.0;
    // Balanço de passada enquanto caminham.
    final stride = arrived
        ? 0.0
        : math.sin(walk * math.pi * 7) * 4 * (1 - walk);
    final flash = arrived ? 1 - _span(t, _arriveAt, _arriveAt + 0.1) : 0.0;
    final captionIn = Curves.easeOutBack.transform(
      _span(t, _arriveAt + 0.08, 0.6),
    );
    // Aproxima devagar enquanto caminham — dá profundidade sem custo.
    final zoom = 0.9 + 0.1 * Curves.easeOut.transform(_span(t, 0, _arriveAt));
    final names = Curves.easeOut.transform(
      _span(t, _arriveAt + 0.04, _arriveAt + 0.2),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        _Backdrop(alpha: alpha, glow: arrived ? 0.6 : 0.2),
        Center(
          child: Transform.scale(
            scale: zoom,
            child: SizedBox(
              width: _Stage.box,
              height: _Stage.box,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    size: const Size.square(_Stage.box),
                    painter: _StagePainter(
                      t: t,
                      walk: walk,
                      arriveAt: _arriveAt,
                      alpha: alpha,
                      motes: _motes,
                      leave: false,
                      fall: 0,
                    ),
                  ),
                  _walker(
                    left: true,
                    person: widget.me,
                    u: walk,
                    lift: stride,
                    scale: pop * (1 + bump),
                    ring: AppColors.accent,
                    alpha: alpha,
                    lit: arrived ? 1 : 0.5,
                  ),
                  _walker(
                    left: false,
                    person: widget.them,
                    u: walk,
                    lift: -stride,
                    scale: pop * (1 + bump),
                    ring: AppColors.teal,
                    alpha: alpha,
                    lit: arrived ? 1 : 0.5,
                  ),
                  _name(left: true, person: widget.me, alpha: alpha * names),
                  _name(left: false, person: widget.them, alpha: alpha * names),
                ],
              ),
            ),
          ),
        ),
        if (widget.caption != null)
          _Caption(
            caption: widget.caption!,
            kicker: widget.kicker,
            progress: captionIn,
            alpha: alpha,
            dim: false,
          ),
        if (flash > 0)
          ColoredBox(
            color: Colors.white.withValues(alpha: 0.3 * flash * flash * alpha),
          ),
      ],
    );
  }

  Widget _buildLeave(double t) {
    final alpha = _span(t, 0, 0.1) * (1 - _span(t, 0.82, 1));
    final fall = Curves.easeInCubic.transform(_span(t, _leaveAt, 0.85));
    final tremble = t < _leaveAt
        ? math.sin(_span(t, 0.1, _leaveAt) * math.pi * 9) *
              3 *
              _span(t, 0.1, _leaveAt)
        : 0.0;
    final pulse = 0.5 + 0.5 * math.sin(t * math.pi * 6);
    final captionIn = Curves.easeOut.transform(_span(t, _leaveAt, 0.55));

    return Stack(
      fit: StackFit.expand,
      children: [
        _Backdrop(alpha: alpha, glow: 0.3),
        Center(
          child: SizedBox(
            width: _Stage.box,
            height: _Stage.box,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CustomPaint(
                  size: const Size.square(_Stage.box),
                  painter: _StagePainter(
                    t: t,
                    walk: 1,
                    arriveAt: 0,
                    alpha: alpha,
                    motes: const [],
                    leave: true,
                    fall: fall,
                  ),
                ),
                _walker(
                  left: false,
                  person: widget.them,
                  u: 1,
                  lift: 0,
                  scale: 1 + 0.04 * pulse,
                  ring: AppColors.teal,
                  alpha: alpha,
                  lit: 0.7 + 0.3 * pulse,
                ),
                _walker(
                  left: true,
                  person: widget.me,
                  u: 1 - 0.55 * fall,
                  lift: 0,
                  shake: tremble,
                  scale: 1 - 0.2 * fall,
                  ring: AppColors.accent,
                  alpha: alpha * (1 - 0.75 * fall),
                  lit: 1 - fall,
                  grey: fall,
                ),
                _name(left: false, person: widget.them, alpha: alpha),
                _name(
                  left: true,
                  person: widget.me,
                  alpha: alpha * (1 - _span(t, _leaveAt, _leaveAt + 0.2)),
                ),
              ],
            ),
          ),
        ),
        if (widget.caption != null)
          _Caption(
            caption: widget.caption!,
            kicker: widget.kicker,
            progress: captionIn,
            alpha: alpha,
            dim: true,
          ),
      ],
    );
  }

  /// Avatar com anel colorido na posição [u] do caminho.
  Widget _walker({
    required bool left,
    required CrossingPerson person,
    required double u,
    required double lift,
    required double scale,
    required Color ring,
    required double alpha,
    required double lit,
    double shake = 0,
    double grey = 0,
  }) {
    const r = _Stage.avatar;
    final p = _Stage.path(left, u);
    Widget face = UserAvatar(
      name: person.name,
      photoUrl: person.photoUrl,
      seed: person.seed ?? person.name,
      radius: r,
      style: widget.portrait,
      borderColor: ring,
    );
    if (grey > 0) {
      face = ColorFiltered(
        colorFilter: ColorFilter.matrix(_greyMatrix(grey)),
        child: face,
      );
    }
    return Positioned(
      left: _Stage.box / 2 + p.dx - r + shake,
      top: _Stage.box / 2 + p.dy - r + lift,
      width: r * 2,
      height: r * 2,
      child: Opacity(
        opacity: alpha.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ring.withValues(alpha: 0.55 * lit),
                  blurRadius: 18 * lit + 4,
                  spreadRadius: 2 * lit,
                ),
              ],
            ),
            child: face,
          ),
        ),
      ),
    );
  }

  /// Primeiro nome embaixo do avatar, já no pé da bandeira.
  Widget _name({
    required bool left,
    required CrossingPerson person,
    required double alpha,
  }) {
    if (alpha <= 0) return const SizedBox.shrink();
    final p = _Stage.path(left, 1);
    final first = person.name.trim().split(RegExp(r'\s+')).first;
    return Positioned(
      left: _Stage.box / 2 + p.dx - 50,
      top: _Stage.box / 2 + p.dy + _Stage.avatar + 8,
      width: 100,
      child: Opacity(
        opacity: alpha.clamp(0.0, 1.0),
        child: Text(
          first,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTypography.label(
            size: 12,
            letterSpacing: 0.3,
            weight: FontWeight.w700,
            color: left ? AppColors.accent : AppColors.teal,
          ).copyWith(decoration: TextDecoration.none),
        ),
      ),
    );
  }

  static List<double> _greyMatrix(double amount) {
    final a = amount.clamp(0.0, 1.0);
    final r = 0.2126 * a, g = 0.7152 * a, b = 0.0722 * a;
    final k = 1 - a;
    return [
      r + k, g, b, 0, 0, //
      r, g + k, b, 0, 0, //
      r, g, b + k, 0, 0, //
      0, 0, 0, 1, 0,
    ];
  }
}

class _Mote {
  final double angle;
  final double reach;
  final double rise;
  final double size;
  final double delay;
  final double phase;
  final bool warm;

  const _Mote({
    required this.angle,
    required this.reach,
    required this.rise,
    required this.size,
    required this.delay,
    required this.phase,
    required this.warm,
  });
}

class _Backdrop extends StatelessWidget {
  final double alpha;
  final double glow;

  const _Backdrop({required this.alpha, required this.glow});

  @override
  Widget build(BuildContext context) {
    // Fundo quase opaco: o card de trás não compete com a cena.
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 0.95,
          colors: [
            Color.lerp(
              AppColors.night,
              AppColors.accent,
              0.12 * glow,
            )!.withValues(alpha: 0.93 * alpha),
            AppColors.night.withValues(alpha: 0.97 * alpha),
          ],
        ),
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  final String caption;
  final String? kicker;
  final double progress;
  final double alpha;
  final bool dim;

  const _Caption({
    required this.caption,
    required this.kicker,
    required this.progress,
    required this.alpha,
    required this.dim,
  });

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    return Align(
      alignment: const Alignment(0, 0.52),
      child: Opacity(
        opacity: p * alpha,
        child: Transform.scale(
          scale: 1.2 - 0.2 * progress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (kicker != null && kicker!.isNotEmpty) ...[
                  Text(
                    kicker!,
                    textAlign: TextAlign.center,
                    style: AppTypography.label(
                      size: 11,
                      letterSpacing: 2.4,
                      weight: FontWeight.w800,
                      color: AppColors.accent,
                    ).copyWith(decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  caption,
                  textAlign: TextAlign.center,
                  style:
                      AppTypography.display(
                        size: 28,
                        weight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: dim ? 0.86 : 1),
                      ).copyWith(
                        decoration: TextDecoration.none,
                        shadows: [
                          Shadow(
                            color: AppColors.accent.withValues(alpha: 0.45),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Trilhas, bandeira e brilho da chegada — os avatares vão por cima.
class _StagePainter extends CustomPainter {
  final double t;
  final double walk;
  final double arriveAt;
  final double alpha;
  final List<_Mote> motes;
  final bool leave;
  final double fall;

  const _StagePainter({
    required this.t,
    required this.walk,
    required this.arriveAt,
    required this.alpha,
    required this.motes,
    required this.leave,
    required this.fall,
  });

  static const _mine = AppColors.accent;
  static const _theirs = AppColors.teal;

  Color _a(Color c, [double k = 1]) =>
      c.withValues(alpha: (c.a * k * alpha).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    if (alpha <= 0) return;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final arrived = !leave && t >= arriveAt;
    final after = arrived ? _span(t, arriveAt, 1) : 0.0;
    final breathe = arrived ? math.sin(after * math.pi) : 0.0;

    // Trilha percorrida (cheia) e a que falta (pontilhada).
    _trail(
      canvas,
      left: true,
      upTo: leave ? 1 - 0.55 * fall : walk,
      color: _mine,
      fade: leave ? 1 - fall : 1,
    );
    _trail(canvas, left: false, upTo: walk, color: _theirs, fade: 1);

    // Halo atrás da bandeira.
    final haloK = leave ? 0.25 : (arrived ? 0.12 + 0.4 * breathe : 0.0);
    if (haloK > 0) {
      const c = _Stage.poleTop;
      final r = 70 + 40 * breathe;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [_a(AppColors.accent, haloK), _a(AppColors.accent, 0)],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    final hoist = leave
        ? 1.0
        : arrived
        ? Curves.easeOutCubic.transform(_span(t, arriveAt, arriveAt + 0.22))
        : 0.0;
    _flag(canvas, lit: leave ? 0.75 : (arrived ? 1 : 0.35), hoist: hoist);
    _thread(
      canvas,
      grow: leave ? 1 : (arrived ? _span(t, arriveAt, arriveAt + 0.1) : 0),
      mineK: leave ? 1 - fall : 1,
    );

    if (arrived) _arrival(canvas, _span(t, arriveAt, arriveAt + 0.34), after);
    canvas.restore();
  }

  /// Pegadas alternadas atrás de quem caminha; o que falta fica pontilhado.
  void _trail(
    Canvas canvas, {
    required bool left,
    required double upTo,
    required Color color,
    required double fade,
  }) {
    final dot = Paint()..color = _a(color, 0.16);
    for (var i = 0; i <= 22; i++) {
      final u = i / 22;
      if (u <= upTo) continue;
      canvas.drawCircle(_Stage.path(left, u), 1.4, dot);
    }
    if (upTo <= 0.04 || fade <= 0) return;
    const gap = 0.055;
    final mark = Paint();
    var i = 0;
    for (var u = 0.02; u < upTo - 0.05; u += gap, i++) {
      final p = _Stage.path(left, u);
      final ahead = _Stage.path(left, math.min(1, u + 0.01));
      final dir = ahead - p;
      final angle = math.atan2(dir.dy, dir.dx);
      final side = i.isEven ? 1.0 : -1.0;
      final normal = Offset(-math.sin(angle), math.cos(angle));
      final at = p + normal * (5 * side);
      // Mais recentes mais fortes.
      final age = ((upTo - u) / 0.6).clamp(0.0, 1.0);
      mark.color = _a(color, (0.85 - 0.55 * age) * fade);
      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.rotate(angle + math.pi / 2);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 5, height: 8),
        mark,
      );
      canvas.drawCircle(const Offset(0, -6.5), 1.6, mark);
      canvas.restore();
    }
  }

  void _flag(Canvas canvas, {required double lit, required double hoist}) {
    canvas.drawLine(
      _Stage.poleBase,
      _Stage.poleTop,
      Paint()
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..color = _a(const Color(0xFFE9DFC4), 0.35 + 0.65 * lit),
    );
    canvas.drawCircle(
      _Stage.poleTop,
      4.5,
      Paint()..color = _a(AppColors.accent, 0.4 + 0.6 * lit),
    );

    // Hasteada: sobe do pé do mastro e abre enquanto sobe.
    final unfurl = 0.25 + 0.75 * Curves.easeOutBack.transform(hoist);
    final w = 72 * unfurl;
    const h = 44.0;
    final low = _Stage.poleBase + const Offset(0, -h - 6);
    final top = Offset.lerp(low, _Stage.poleTop + const Offset(0, 4), hoist)!;
    final wave = t * math.pi * 5;
    final amp = 1.5 + 2.5 * hoist;
    final cloth = Path()..moveTo(top.dx, top.dy);
    const seg = 12;
    for (var i = 1; i <= seg; i++) {
      final x = w * i / seg;
      cloth.lineTo(
        top.dx + x,
        top.dy + math.sin(x / 15 - wave) * amp * (i / seg),
      );
    }
    for (var i = seg; i >= 0; i--) {
      final x = w * i / seg;
      final y = math.sin(x / 15 - wave + 0.6) * amp * (i / seg);
      cloth.lineTo(top.dx + x, top.dy + h + y - 7 * (i / seg));
    }
    cloth.close();
    final rect = Rect.fromLTWH(top.dx, top.dy, w, h);
    canvas.drawPath(
      cloth,
      Paint()
        ..shader = LinearGradient(
          colors: [
            _a(const Color(0xFFFFE9A8), 0.3 + 0.7 * lit),
            _a(AppColors.accent, 0.3 + 0.7 * lit),
            _a(const Color(0xFFB0822A), 0.3 + 0.7 * lit),
          ],
        ).createShader(rect),
    );
  }

  /// Fio entre os dois: cresce de cada lado até se encontrar no mastro.
  void _thread(Canvas canvas, {required double grow, required double mineK}) {
    if (grow <= 0) return;
    const y = 62.0;
    const edge = 52.0 - _Stage.avatar;
    final reach = edge * grow;
    void half(double sign, Color color, double k) {
      if (k <= 0) return;
      final a = Offset(sign * edge, y);
      final b = Offset(sign * (edge - reach), y);
      canvas.drawLine(
        a,
        b,
        Paint()
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..color = _a(color, 0.22 * k),
      );
      canvas.drawLine(
        a,
        b,
        Paint()
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..color = _a(Color.lerp(color, Colors.white, 0.35)!, 0.95 * k),
      );
    }

    half(-1, _mine, mineK);
    half(1, _theirs, 1);
    if (grow >= 1 && mineK > 0.5) {
      final x = math.sin(t * math.pi * 4) * edge * 0.9;
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()..color = _a(Colors.white, 0.9 * mineK),
      );
    }
  }

  void _arrival(Canvas canvas, double hit, double after) {
    final ease = Curves.easeOutCubic.transform(hit);
    // Encontro entre os dois avatares.
    const meet = Offset(0, 62);

    final flash = (1 - hit / 0.3).clamp(0.0, 1.0);
    if (flash > 0) {
      final r = 26 + 50 * ease;
      canvas.drawCircle(
        meet,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              _a(Colors.white, 0.8 * flash),
              _a(AppColors.accent, 0.45 * flash),
              _a(AppColors.accent, 0),
            ],
          ).createShader(Rect.fromCircle(center: meet, radius: r)),
      );
    }

    for (final (delay, color) in const [(0.0, _mine), (0.16, _theirs)]) {
      final w = ((hit - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (w <= 0 || w >= 1) continue;
      final e = Curves.easeOutCubic.transform(w);
      canvas.drawCircle(
        meet,
        40 + 130 * e,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6 * (1 - e) + 0.4
          ..color = _a(color, 0.75 * (1 - e)),
      );
    }

    final dot = Paint();
    for (final m in motes) {
      final u = ((after - m.delay) / (1 - m.delay)).clamp(0.0, 1.0);
      if (u <= 0 || u >= 1) continue;
      final spread = Curves.easeOutCubic.transform((u * 3).clamp(0.0, 1.0));
      final p =
          _Stage.poleTop +
          Offset(
            math.cos(m.angle) * m.reach * spread +
                math.sin(m.phase + u * 6) * 8,
            math.sin(m.angle) * m.reach * spread * 0.6 - m.rise * u,
          );
      dot.color = _a(m.warm ? _mine : _theirs, 0.9 * math.sin(u * math.pi));
      canvas.drawCircle(p, m.size, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _StagePainter old) =>
      old.t != t || old.alpha != alpha || old.fall != fall || old.walk != walk;
}

/// Botão de segurar: enche, treme e vibra cada vez mais forte até disparar.
///
/// Soltar antes do fim desfaz. Leitor de tela confirma com um toque.
class HoldToConfirmCta extends StatefulWidget {
  final String label;
  final VoidCallback? onConfirm;
  final CinematicGlyph leading;
  final Duration holdFor;

  const HoldToConfirmCta({
    super.key,
    required this.label,
    required this.onConfirm,
    this.leading = CinematicGlyph.flag,
    this.holdFor = const Duration(milliseconds: 1400),
  });

  @override
  State<HoldToConfirmCta> createState() => _HoldToConfirmCtaState();
}

class _HoldToConfirmCtaState extends State<HoldToConfirmCta>
    with TickerProviderStateMixin {
  late final AnimationController _fill;

  /// Estalo do botão ao completar — só depois dele a animação entra.
  late final AnimationController _pop;
  Timer? _buzz;
  bool _fired = false;

  bool get _enabled => widget.onConfirm != null;

  @override
  void initState() {
    super.initState();
    _fill = AnimationController(vsync: this, duration: widget.holdFor)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _confirm();
      });
    _pop =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 260),
        )..addStatusListener((s) {
          if (s == AnimationStatus.completed) _handOff();
        });
  }

  @override
  void dispose() {
    _buzz?.cancel();
    _fill.dispose();
    _pop.dispose();
    super.dispose();
  }

  void _start() {
    if (!_enabled || _fired) return;
    ActHaptics.tap();
    _fill.forward();
    _scheduleBuzz();
  }

  void _release() {
    _buzz?.cancel();
    if (_fired) return;
    if (_fill.value > 0) {
      _fill.animateBack(
        0,
        duration: Duration(milliseconds: (260 * _fill.value).round() + 60),
        curve: Curves.easeOut,
      );
    }
  }

  /// Pulsos cada vez mais curtos e pesados conforme o botão enche.
  void _scheduleBuzz() {
    _buzz?.cancel();
    final p = _fill.value;
    final gap = (190 - 150 * p).round();
    _buzz = Timer(Duration(milliseconds: gap), () {
      if (!mounted || _fired || !_fill.isAnimating) return;
      final now = _fill.value;
      if (now < 0.35) {
        ActHaptics.tap();
      } else if (now < 0.6) {
        ActHaptics.light();
      } else if (now < 0.85) {
        ActHaptics.confirm();
      } else {
        ActHaptics.success();
      }
      _scheduleBuzz();
    });
  }

  void _confirm() {
    if (_fired) return;
    _fired = true;
    _buzz?.cancel();
    _fill.stop();
    ActHaptics.success();
    _pop.forward(from: 0);
  }

  /// Botão terminou: volta ao repouso e, no frame seguinte, entrega a vez.
  void _handOff() {
    if (!mounted) return;
    _fill.value = 0;
    _pop.value = 0;
    setState(() => _fired = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onConfirm?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _enabled;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      onTap: enabled ? _confirm : null,
      excludeSemantics: true,
      child: GestureDetector(
        onLongPressDown: enabled ? (_) => _start() : null,
        onLongPressUp: enabled ? _release : null,
        onLongPressCancel: enabled ? _release : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: enabled ? 1 : 0.45,
          child: AnimatedBuilder(
            animation: Listenable.merge([_fill, _pop]),
            builder: (context, child) {
              final p = _fill.value;
              final phase = p * widget.holdFor.inMilliseconds / 22;
              final amp = p <= 0 || _fired ? 0.0 : 0.6 + 3.4 * p * p;
              final dx = math.sin(phase * 2.1) * amp;
              final dy = math.cos(phase * 2.9) * amp * 0.45;
              // Estalo: sai de 0.97, passa de 1 e assenta.
              final pop = math.sin(_pop.value * math.pi);
              final scale = _fired
                  ? 0.97 + 0.03 * _pop.value + 0.06 * pop
                  : 1 - 0.03 * p;
              return Transform.translate(
                offset: Offset(dx, dy),
                child: Transform.scale(scale: scale, child: _body(p)),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _body(double p) {
    return Container(
      constraints: const BoxConstraints(minHeight: CopperCta.denseHeight),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: _enabled
            ? AppMetrics.accentGlow(
                blur: 20 + 16 * p,
                alpha: 0.2 + 0.35 * p,
                offset: const Offset(0, 6),
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Stack(
          children: [
            Positioned.fill(
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: p,
                child: ColoredBox(
                  color: AppColors.inkOnAccent.withValues(alpha: 0.16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.lg,
                vertical: 13,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CinematicIcon(
                    glyph: widget.leading,
                    size: 16,
                    accent: AppColors.inkOnAccent,
                    framed: false,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: CopperCta.labelStyle(size: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
