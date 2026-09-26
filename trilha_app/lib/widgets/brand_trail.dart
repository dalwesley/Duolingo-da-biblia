import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import 'film_layers.dart';

/// Enquadramento da arte STWAY (a trilha do ícone e da splash) num ato.
///
/// Todos os campos vão de 0 a 1, exceto [zoom].
class TrailShot {
  /// Brilho da arte: 0 = trevas, 1 = como na splash.
  final double exposure;

  /// Luz azul que nasce no horizonte, no fim da trilha.
  final double glow;

  /// Quanto do caminho está aceso, de baixo até o horizonte.
  final double lit;

  /// Lâmpadas douradas e o peregrino de luz sobre o trecho aceso.
  final double lamps;

  final double stars;

  /// Tinta noturna sobre a arte.
  final double night;

  /// Sol de luz baixa (tarde): brilho do horizonte puxa para o âmbar.
  final double warmth;

  /// Cor do céu acima dos morros (o céu escolhido). A arte não muda.
  final Color skyTop;
  final Color skyLow;

  /// Quanto do céu escolhido cobre o céu original da arte.
  final double skyAmount;

  /// Aproximação da câmera (1 = cobre a tela).
  final double zoom;

  /// Enquadramento vertical: 0 = topo da arte, 1 = base.
  final double focusY;

  /// Desce a arte (fração da altura da tela), abrindo mais céu em cima.
  final double drop;

  const TrailShot({
    this.exposure = 1,
    this.glow = 0,
    this.lit = 0,
    this.lamps = 0,
    this.stars = 0,
    this.night = 0,
    this.warmth = 0,
    this.skyTop = const Color(0x00000000),
    this.skyLow = const Color(0x00000000),
    this.skyAmount = 0,
    this.zoom = 1,
    this.focusY = 0.5,
    this.drop = 0,
  });

  /// Enquadramento fixo dos atos: arte assentada embaixo, céu aberto.
  static const rest = TrailShot(zoom: 1, focusY: 1, drop: 0.12);

  TrailShot copyWith({
    double? exposure,
    double? glow,
    double? lit,
    double? lamps,
    double? stars,
    double? night,
    double? warmth,
    Color? skyTop,
    Color? skyLow,
    double? skyAmount,
    double? zoom,
  }) => TrailShot(
    exposure: exposure ?? this.exposure,
    glow: glow ?? this.glow,
    lit: lit ?? this.lit,
    lamps: lamps ?? this.lamps,
    stars: stars ?? this.stars,
    night: night ?? this.night,
    warmth: warmth ?? this.warmth,
    skyTop: skyTop ?? this.skyTop,
    skyLow: skyLow ?? this.skyLow,
    skyAmount: skyAmount ?? this.skyAmount,
    zoom: zoom ?? this.zoom,
    focusY: focusY,
    drop: drop,
  );

  static double _mix(double a, double b, double t) => a + (b - a) * t;

  static TrailShot lerp(TrailShot a, TrailShot b, double t) => TrailShot(
    exposure: _mix(a.exposure, b.exposure, t),
    glow: _mix(a.glow, b.glow, t),
    lit: _mix(a.lit, b.lit, t),
    lamps: _mix(a.lamps, b.lamps, t),
    stars: _mix(a.stars, b.stars, t),
    night: _mix(a.night, b.night, t),
    warmth: _mix(a.warmth, b.warmth, t),
    // Sem céu de um lado, herda a cor do outro: só a cobertura anima.
    skyTop: Color.lerp(
      a.skyAmount > 0 ? a.skyTop : b.skyTop,
      b.skyAmount > 0 ? b.skyTop : a.skyTop,
      t,
    )!,
    skyLow: Color.lerp(
      a.skyAmount > 0 ? a.skyLow : b.skyLow,
      b.skyAmount > 0 ? b.skyLow : a.skyLow,
      t,
    )!,
    skyAmount: _mix(a.skyAmount, b.skyAmount, t),
    zoom: _mix(a.zoom, b.zoom, t),
    focusY: _mix(a.focusY, b.focusY, t),
    drop: _mix(a.drop, b.drop, t),
  );
}

/// Céu escolhido no app sobre a arte (a arte em si não muda).
extension TrailSky on TrailShot {
  /// Mesmas cores do céu da Home ([DayPhaseHelper]): manhã azul, tarde
  /// turquesa com sol de luz baixa, noite = céu escuro original + estrelas.
  TrailShot withSky(AppearanceStyle style) {
    final sky = DayPhaseHelper.backgroundGradient(style.phase).colors;
    return switch (style.look) {
      AppearanceLook.morning => copyWith(
        skyTop: sky[0],
        skyLow: sky[1],
        skyAmount: 1,
      ),
      AppearanceLook.afternoon => copyWith(
        skyTop: sky[0],
        skyLow: sky[2],
        skyAmount: 1,
        warmth: 1,
      ),
      AppearanceLook.night => copyWith(stars: 1),
    };
  }
}

/// Pintura da arte STWAY com luz viva por cima.
class BrandTrail {
  BrandTrail._();

  static const asset = 'assets/icon/splash_bg.png';

  static const _blue = AppColors.primary;
  static const _ice = Color(0xFFCFE6FF);
  static const _gold = AppColors.accent;
  static const _lampWarm = Color(0xFFFFE7A8);
  static const _dusk = Color(0xFFFFD29A);
  static const _ember = AppColors.ember;

  /// Brilho do horizonte na arte (coordenadas normalizadas).
  static const horizon = Offset(0.62, 0.385);

  /// Linha central do caminho na arte, da base ao horizonte.
  /// Medida nos pixels da splash_bg.png.
  static const _trace = [
    Offset(0.10, 1.02),
    Offset(0.22, 0.869),
    Offset(0.35, 0.82),
    Offset(0.52, 0.771),
    Offset(0.71, 0.723),
    Offset(0.80, 0.662),
    Offset(0.766, 0.625),
    Offset(0.659, 0.601),
    Offset(0.485, 0.576),
    Offset(0.347, 0.552),
    Offset(0.33, 0.527),
    Offset(0.421, 0.503),
    Offset(0.608, 0.479),
    Offset(0.687, 0.454),
    Offset(0.54, 0.43),
    Offset(0.53, 0.415),
    Offset(0.6, 0.395),
  ];

  static ui.Image? _image;
  static Future<ui.Image>? _loading;

  static ui.Image? get image => _image;

  static Future<ui.Image> ensureLoaded() {
    if (_image != null) return Future.value(_image);
    return _loading ??= () {
      final done = Completer<ui.Image>();
      final stream = const AssetImage(asset).resolve(ImageConfiguration.empty);
      late final ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, _) {
          _image = info.image;
          stream.removeListener(listener);
          done.complete(info.image);
        },
        onError: (e, st) {
          stream.removeListener(listener);
          _loading = null;
          done.completeError(e, st);
        },
      );
      stream.addListener(listener);
      return done.future;
    }();
  }

  /// Céu escolhido sobre o céu da arte.
  ///
  /// `lighten` fica com o canal mais claro: o céu escuro da arte assume a
  /// cor, e os morros (já claros) quase não mudam. O degradê some antes do
  /// horizonte, então nada abaixo dele é tocado.
  static void _paintSky(Canvas canvas, Size size, Rect rect, TrailShot shot) {
    final a = shot.skyAmount.clamp(0.0, 1.0);
    final full = at(rect, const Offset(0, 0.24)).dy;
    final gone = at(rect, const Offset(0, 0.4)).dy;
    if (gone <= 0) return;
    final area = Rect.fromLTRB(0, 0, size.width, gone);
    final f = (full / gone).clamp(0.0, 0.9);
    canvas.drawRect(
      area,
      Paint()
        ..blendMode = BlendMode.lighten
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, gone),
          [
            shot.skyTop.withValues(alpha: a),
            shot.skyLow.withValues(alpha: a),
            shot.skyLow.withValues(alpha: 0.45 * a),
            shot.skyLow.withValues(alpha: 0),
          ],
          [0.0, f, f + (1 - f) * 0.45, 1.0],
        ),
    );
  }

  /// Retângulo onde a arte é desenhada na tela para [shot].
  static Rect frame(Size size, TrailShot shot) {
    final img = _image;
    final iw = img?.width.toDouble() ?? 455;
    final ih = img?.height.toDouble() ?? 1024;
    final scale = math.max(size.width / iw, size.height / ih) * shot.zoom;
    final dw = iw * scale;
    final dh = ih * scale;
    return Rect.fromLTWH(
      (size.width - dw) / 2,
      (size.height - dh) * shot.focusY.clamp(0.0, 1.0) +
          shot.drop * size.height,
      dw,
      dh,
    );
  }

  /// Quanto o sol acompanha a inclinação (px): quase nada, a arte é fixa.
  static const sunTilt = 4.0;

  /// Sol no horizonte da arte, com o leve parallax da inclinação.
  static Offset sunAt(Rect frame, Offset tilt) =>
      at(frame, horizon) + tilt * sunTilt;

  static Offset at(Rect frame, Offset p) =>
      Offset(frame.left + p.dx * frame.width, frame.top + p.dy * frame.height);

  /// Pinta a arte e a luz; devolve o retângulo da arte na tela.
  static Rect paint(
    Canvas canvas,
    Size size,
    TrailShot shot, {
    required double loop,
    bool calm = false,
    Offset tilt = Offset.zero,
  }) {
    final full = Offset.zero & size;
    canvas.drawRect(full, Paint()..color = AppColors.primaryDark);

    final rect = frame(size, shot);
    final img = _image;
    if (img != null && shot.exposure > 0.01) {
      final e = shot.exposure.clamp(0.0, 1.2);
      final n = shot.night;
      final paint = Paint()
        ..filterQuality = FilterQuality.medium
        ..colorFilter = ColorFilter.matrix([
          e * (1 - 0.55 * n), 0, 0, 0, 0, //
          0, e * (1 - 0.35 * n), 0, 0, 0, //
          0, 0, e * (1 - 0.1 * n), 0, 0, //
          0, 0, 0, 1, 0,
        ]);
      final iw = img.width.toDouble();
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, iw, img.height.toDouble()),
        rect,
        paint,
      );
      // Arte descida: estica a primeira faixa do céu até o topo da tela.
      if (rect.top > 0) {
        canvas.drawImageRect(
          img,
          Rect.fromLTWH(0, 0, iw, 2),
          Rect.fromLTRB(rect.left, 0, rect.right, rect.top + 1),
          paint,
        );
      }
    }

    if (shot.skyAmount > 0.01) _paintSky(canvas, size, rect, shot);

    final sun = sunAt(rect, tilt);
    FilmLayers.stars(
      canvas,
      size,
      alpha: shot.stars,
      loop: loop,
      floor: (sun.dy / size.height * 0.92).clamp(0.2, 0.8),
      pan: calm ? 0 : FilmLayers.clock,
      tilt: tilt,
    );

    if (shot.glow > 0.01) {
      _paintGlow(canvas, size, sun, shot.glow, shot.warmth, loop);
    }
    if (shot.lit > 0.01) _paintPath(canvas, rect, shot, loop, calm);
    return rect;
  }

  static void _paintGlow(
    Canvas canvas,
    Size size,
    Offset c,
    double a,
    double warmth,
    double loop,
  ) {
    final pulse = 0.94 + 0.06 * math.sin(loop * 2);
    final ice = Color.lerp(_ice, _dusk, warmth)!;
    final blue = Color.lerp(_blue, _ember, warmth)!;
    final halo = size.width * (0.3 + 0.45 * a) * pulse;
    canvas.drawCircle(
      c,
      halo,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = ui.Gradient.radial(
          c,
          halo,
          [
            ice.withValues(alpha: 0.42 * a),
            blue.withValues(alpha: 0.28 * a),
            Colors.transparent,
          ],
          [0.0, 0.3, 1.0],
        ),
    );
    final core = 8 + 10 * a;
    canvas.drawCircle(
      c,
      core,
      Paint()
        ..shader = ui.Gradient.radial(
          c,
          core,
          [
            Colors.white.withValues(alpha: 0.9 * a),
            ice.withValues(alpha: 0.5 * a),
            ice.withValues(alpha: 0),
          ],
          [0.0, 0.5, 1.0],
        ),
    );
  }

  static Path _trailPath(Rect rect) {
    final pts = [for (final p in _trace) at(rect, p)];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    // Catmull-Rom → Bézier, para o traço seguir as curvas da arte.
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = pts[math.max(i - 1, 0)];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = pts[math.min(i + 2, pts.length - 1)];
      final c1 = p1 + (p2 - p0) / 6;
      final c2 = p2 - (p3 - p1) / 6;
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  static void _paintPath(
    Canvas canvas,
    Rect rect,
    TrailShot shot,
    double loop,
    bool calm,
  ) {
    final metric = _trailPath(rect).computeMetrics().first;
    final len = metric.length;
    final lit = shot.lit.clamp(0.0, 1.0);
    final seg = metric.extractPath(0, len * lit);
    final w = rect.width;

    // Luz correndo pelo caminho.
    canvas.drawPath(
      seg,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w * 0.05
        ..blendMode = BlendMode.plus
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
        ..color = _blue.withValues(alpha: 0.3 * lit),
    );
    canvas.drawPath(
      seg,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2
        ..blendMode = BlendMode.plus
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
        ..color = _ice.withValues(alpha: 0.55 * lit),
    );

    // Frente da luz.
    final head = metric.getTangentForOffset(len * lit)?.position;
    if (head != null && lit < 0.995) {
      final r = 18.0;
      canvas.drawCircle(
        head,
        r,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = ui.Gradient.radial(
            head,
            r,
            [
              Colors.white.withValues(alpha: 0.9),
              _ice.withValues(alpha: 0.3),
              Colors.transparent,
            ],
            [0.0, 0.25, 1.0],
          ),
      );
    }

    if (shot.lamps <= 0.01) return;
    final lampPaint = Paint()..blendMode = BlendMode.plus;

    // Lâmpadas: maiores perto do espectador (perspectiva da arte).
    const stops = [0.1, 0.26, 0.42, 0.57, 0.71, 0.84];
    for (var i = 0; i < stops.length; i++) {
      final f = stops[i];
      if (f > lit) break;
      final p = metric.getTangentForOffset(len * f)!.position;
      final pulse = calm ? 1.0 : 0.65 + 0.35 * math.sin(loop * 2 - i * 0.9);
      final r = (10 + 26 * (1 - f)) * (0.85 + 0.15 * pulse);
      final a = shot.lamps * pulse;
      lampPaint.shader = ui.Gradient.radial(
        p,
        r,
        [
          _lampWarm.withValues(alpha: 0.9 * a),
          _gold.withValues(alpha: 0.3 * a),
          Colors.transparent,
        ],
        [0.0, 0.22, 1.0],
      );
      canvas.drawCircle(p, r, lampPaint);
    }

    // Peregrino de luz subindo a trilha, em loop.
    if (calm) return;
    final walk = (loop / (math.pi * 2)) % 1 * lit;
    final p = metric.getTangentForOffset(len * walk)!.position;
    final r = 10 + 8 * (1 - walk);
    lampPaint.shader = ui.Gradient.radial(
      p,
      r,
      [
        Colors.white.withValues(alpha: 0.85 * shot.lamps),
        _lampWarm.withValues(alpha: 0.35 * shot.lamps),
        Colors.transparent,
      ],
      [0.0, 0.25, 1.0],
    );
    canvas.drawCircle(p, r, lampPaint);
  }
}

/// Fundo dos atos: a arte STWAY trocando de enquadramento e de luz.
class TrailScene extends StatefulWidget {
  final TrailShot from;
  final TrailShot to;
  final double reveal;
  final double time;

  /// Inclinação do celular (-1 a 1) para o parallax do céu.
  final Offset tilt;

  const TrailScene({
    super.key,
    required this.from,
    required this.to,
    required this.reveal,
    required this.time,
    this.tilt = Offset.zero,
  });

  @override
  State<TrailScene> createState() => _TrailSceneState();
}

class _TrailSceneState extends State<TrailScene> {
  @override
  void initState() {
    super.initState();
    if (BrandTrail.image == null) {
      BrandTrail.ensureLoaded().then((_) {
        if (mounted) setState(() {});
      }, onError: (_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final calm = MediaQuery.of(context).disableAnimations;
    final t = calm ? 1.0 : Curves.easeInOutCubic.transform(widget.reveal);
    return RepaintBoundary(
      child: CustomPaint(
        painter: _TrailScenePainter(
          shot: TrailShot.lerp(widget.from, widget.to, t),
          time: calm ? 0 : widget.time,
          calm: calm,
          tilt: calm ? Offset.zero : widget.tilt,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _TrailScenePainter extends CustomPainter {
  final TrailShot shot;
  final double time;
  final bool calm;
  final Offset tilt;

  _TrailScenePainter({
    required this.shot,
    required this.time,
    required this.calm,
    required this.tilt,
  });

  @override
  void paint(Canvas canvas, Size size) {
    BrandTrail.paint(
      canvas,
      size,
      shot,
      loop: time * math.pi * 2,
      calm: calm,
      tilt: tilt,
    );
    FilmLayers.vignette(canvas, size, strength: 0.5);
    if (!calm) FilmLayers.grain(canvas, size, time);
  }

  @override
  bool shouldRepaint(covariant _TrailScenePainter old) => true;
}
