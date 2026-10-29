import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../screens/paywall_screen.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import 'act_feel.dart';
import 'anan_speech.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'postcard_share.dart';
import 'ui_primitives.dart';

/// Postal da caminhada: a pintura da cena, guardada ao concluir.
/// Ver docs/postais.md.
class Postcard {
  final String slug;
  final String title;

  /// Referência bíblica ("Rute 1:16"); vazia quando a cena não tem uma.
  final String ref;

  /// Frase "Hoje" da cena.
  final String insight;
  final String? art;
  final DateTime on;

  const Postcard({
    required this.slug,
    required this.title,
    required this.ref,
    required this.insight,
    required this.art,
    required this.on,
  });

  /// Livro da referência ("1 Samuel 3:10" → "1 Samuel"), para o carimbo.
  String get book {
    final m = RegExp(r'^(.+?)\s+\d').firstMatch(ref.trim());
    return m?.group(1) ?? ref.trim();
  }
}

// Papel e tinta do postal: cor de objeto pintado, não de interface.
const _paper = Color(0xFFF3EBDD);
const _paperInk = Color(0xFF3B2E1E);
const _postmarkInk = Color(0xFF9B2C2C);

/// Matriz de cor: [saturation] 0 = cinza, 1 = cor; [light] escurece.
ColorFilter _tone({required double saturation, double light = 1}) {
  const lr = 0.2126, lg = 0.7152, lb = 0.0722;
  final s = saturation.clamp(0.0, 1.0);
  final sr = (1 - s) * lr, sg = (1 - s) * lg, sb = (1 - s) * lb;
  final k = light.clamp(0.0, 1.0);
  return ColorFilter.matrix(<double>[
    (sr + s) * k, sg * k, sb * k, 0, 0, //
    sr * k, (sg + s) * k, sb * k, 0, 0, //
    sr * k, sg * k, (sb + s) * k, 0, 0, //
    0, 0, 0, 1, 0,
  ]);
}

/// Véu de cena sem [SceneArtImage] (quem precisa do próprio Image.asset):
/// decode com [sceneVeilDecodeWidth] e este filtro por cima.
const sceneVeilDecodeWidth = 36;
final sceneVeilFilter = _tone(saturation: 0.25, light: 0.8);

/// Pintura de cena com véu enquanto o postal não foi revelado.
///
/// O véu sai do decode em baixíssima resolução (a pintura vira mancha de
/// cor ao esticar), sem filtro de blur por frame: barato no mapa, que rola
/// com vários cards.
class SceneArtImage extends StatelessWidget {
  final String path;
  final bool veiled;
  final BoxFit fit;
  final Alignment alignment;
  final int? cacheWidth;
  final int? cacheHeight;
  final ImageErrorWidgetBuilder? errorBuilder;

  const SceneArtImage(
    this.path, {
    super.key,
    required this.veiled,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.cacheWidth,
    this.cacheHeight,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (!veiled) {
      return Image.asset(
        path,
        fit: fit,
        alignment: alignment,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        errorBuilder: errorBuilder,
      );
    }
    return ColorFiltered(
      colorFilter: sceneVeilFilter,
      child: Image.asset(
        path,
        fit: fit,
        alignment: alignment,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        cacheWidth: sceneVeilDecodeWidth,
        errorBuilder: errorBuilder,
      ),
    );
  }
}

/// O postal: selo picotado em papel, pintura 4:3 com filete, faixa com a
/// referência e, por cima, o carimbo do dia.
class PostcardView extends StatelessWidget {
  final Postcard postcard;
  final double width;

  /// 0 = velado (sem cor, desfocado, "?"), 1 = revelado.
  final double reveal;

  /// 0 = sem carimbo, 1 = carimbo pousado.
  final double postmark;

  /// Miniatura do álbum: papel e faixa proporcionais, sem carimbo, e o véu
  /// barato (decode em baixa) no lugar do blur.
  final bool mini;

  /// Decodifica a pintura inteira (a mesma chave do precache): o card de
  /// compartilhar é capturado logo depois de montar, sem esperar decode.
  final bool fullDecode;

  const PostcardView({
    super.key,
    required this.postcard,
    required this.width,
    this.reveal = 1,
    this.postmark = 1,
    this.mini = false,
    this.fullDecode = false,
  });

  /// Altura total do postal para [width] (papel + pintura + faixa).
  static double heightFor(double width, {bool mini = false}) {
    final pad = _pad(width, mini);
    return pad * 2 + (width - pad * 2) * 3 / 4 + _strip(width, mini);
  }

  static double _pad(double width, bool mini) =>
      mini ? width * 0.06 : (width * 0.05).clamp(9.0, 16.0);
  static double _strip(double width, bool mini) =>
      mini ? width * 0.15 : (width * 0.27).clamp(56.0, 100.0);

  @override
  Widget build(BuildContext context) {
    final r = reveal.clamp(0.0, 1.0);
    final pad = _pad(width, mini);
    final strip = _strip(width, mini);
    final inner = width - pad * 2;
    final art = postcard.art;
    final cheapVeil = mini && r == 0 && art != null;
    Widget painting = art == null
        ? const ColoredBox(color: AppColors.night)
        : cheapVeil
        ? SceneArtImage(art, veiled: true)
        : Image.asset(
            art,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.medium,
            cacheWidth: fullDecode
                ? null
                : (width * MediaQuery.devicePixelRatioOf(context)).round(),
          );
    if (r < 1 && !cheapVeil) {
      painting = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: 14 * (1 - r),
          sigmaY: 14 * (1 - r),
        ),
        child: ColorFiltered(
          colorFilter: _tone(saturation: r, light: 0.8 + 0.2 * r),
          child: painting,
        ),
      );
    }

    final card = ClipPath(
      clipper: _PerforatedClipper(pitch: (width / 20).clamp(10.0, 16.0)),
      child: ColoredBox(
        color: _paper,
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filete fino em volta da pintura, como no selo impresso.
              DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _paperInk.withValues(alpha: 0.45),
                    width: 1,
                  ),
                ),
                child: SizedBox(
                  width: inner,
                  height: inner * 3 / 4,
                  child: ClipRect(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        painting,
                        if (r < 1)
                          Center(
                            child: Opacity(
                              opacity: 1 - r,
                              child: Text(
                                '?',
                                style: AppTypography.display(
                                  size: width * 0.18,
                                  exact: true,
                                  color: _paper.withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: strip + pad,
                child: Padding(
                  padding: EdgeInsets.only(bottom: pad * 0.4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    // A referência fica à esquerda do carimbo; longa, encolhe.
                    child: SizedBox(
                      width: mini
                          ? inner
                          : width * 0.64 - (strip + pad) * 0.36 - pad * 1.4,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          postcard.ref.toUpperCase(),
                          maxLines: 1,
                          style: AppTypography.label(
                            size: (width * 0.042).clamp(10.0, 14.0),
                            color: _paperInk,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final m = postmark.clamp(0.0, 1.0);
    // Carimbo inteiro na faixa branca, onde a tinta aparece; a referência
    // fica à esquerda e as ondas correm para a direita.
    final band = strip + pad;
    final markR = band * 0.36;
    final cx = width * 0.64;
    final cy = pad + inner * 3 / 4 + band / 2;
    return Semantics(
      label: '${postcard.title}. ${postcard.ref}',
      child: SizedBox(
        width: width,
        height: heightFor(width, mini: mini),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(pad * 0.6),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x59000000),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            card,
            if (m > 0 && !mini)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: (m * 1.6).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 1.5 - 0.5 * Curves.easeOutBack.transform(m),
                      origin: Offset(cx - width / 2, cy - heightFor(width) / 2),
                      child: CustomPaint(
                        painter: _PostmarkPainter(
                          center: Offset(cx, cy),
                          radius: markR,
                          waveEnd: width - pad * 0.6,
                          top: postcard.book.toUpperCase(),
                          bottom: 'STWAY',
                          day: DateFormat('d MMM', context.l10n.localeName)
                              .format(postcard.on)
                              .replaceAll('.', '')
                              .toUpperCase(),
                          year: '${postcard.on.year}',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Selinho do postal na margem do versículo: papel picotado e a pintura.
class PostcardPin extends StatelessWidget {
  final Postcard postcard;
  final double width;

  /// Ver [PostcardView.fullDecode].
  final bool fullDecode;

  const PostcardPin({
    super.key,
    required this.postcard,
    this.width = 30,
    this.fullDecode = false,
  });

  @override
  Widget build(BuildContext context) {
    final art = postcard.art;
    final pad = width * 0.1;
    return ClipPath(
      clipper: _PerforatedClipper(pitch: width / 6),
      child: ColoredBox(
        color: _paper,
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: SizedBox(
            width: width - pad * 2,
            height: (width - pad * 2) * 3 / 4,
            child: art == null
                ? const ColoredBox(color: AppColors.night)
                : Image.asset(
                    art,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    cacheWidth: fullDecode
                        ? null
                        : (width * 2 * MediaQuery.devicePixelRatioOf(context))
                              .round(),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Recorte de selo: dentes redondos ao longo das quatro bordas.
class _PerforatedClipper extends CustomClipper<Path> {
  final double pitch;

  const _PerforatedClipper({required this.pitch});

  @override
  Path getClip(Size size) {
    final r = pitch * 0.32;
    final holes = Path();
    void row(double y) {
      final n = (size.width / pitch).round();
      final step = size.width / n;
      for (var i = 0; i <= n; i++) {
        holes.addOval(Rect.fromCircle(center: Offset(i * step, y), radius: r));
      }
    }

    void column(double x) {
      final n = (size.height / pitch).round();
      final step = size.height / n;
      for (var i = 0; i <= n; i++) {
        holes.addOval(Rect.fromCircle(center: Offset(x, i * step), radius: r));
      }
    }

    row(0);
    row(size.height);
    column(0);
    column(size.width);
    return Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      holes,
    );
  }

  @override
  bool shouldReclip(_PerforatedClipper old) => old.pitch != pitch;
}

/// Carimbo solto (fora do postal): cards de compartilhar, passaporte.
class PostmarkStamp extends StatelessWidget {
  final double radius;
  final String top;
  final DateTime on;

  /// Ondas de cancelamento à direita do carimbo.
  final bool waves;

  const PostmarkStamp({
    super.key,
    required this.radius,
    required this.top,
    required this.on,
    this.waves = true,
  });

  @override
  Widget build(BuildContext context) {
    final width = radius * 2.3 + (waves ? radius * 1.8 : 0);
    return CustomPaint(
      size: Size(width, radius * 2.3),
      painter: _PostmarkPainter(
        center: Offset(radius * 1.15, radius * 1.15),
        radius: radius,
        waveEnd: width,
        drawWaves: waves,
        top: top.toUpperCase(),
        bottom: 'STWAY',
        day: DateFormat(
          'd MMM',
          context.l10n.localeName,
        ).format(on).replaceAll('.', '').toUpperCase(),
        year: '${on.year}',
      ),
    );
  }
}

/// Carimbo do correio: dois aros, livro no arco de cima, "STWAY" no de
/// baixo, dia e ano no centro e as ondas de cancelamento ao lado.
class _PostmarkPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final double waveEnd;
  final String top;
  final String bottom;
  final String day;
  final String year;
  final bool drawWaves;

  _PostmarkPainter({
    this.drawWaves = true,
    required this.center,
    required this.radius,
    required this.waveEnd,
    required this.top,
    required this.bottom,
    required this.day,
    required this.year,
  });

  static final _ink = _postmarkInk.withValues(alpha: 0.85);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Carimbo batido à mão: levemente torto.
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.16);
    canvas.translate(-center.dx, -center.dy);

    final stroke = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.07;
    canvas.drawCircle(center, radius, stroke);
    canvas.drawCircle(
      center,
      radius * 0.66,
      stroke..strokeWidth = radius * 0.035,
    );

    final arcStyle = TextStyle(
      color: _ink,
      fontSize: radius * 0.2,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
      fontFamily: AppTypography.label().fontFamily,
    );
    _arcText(canvas, top, arcStyle, radius * 0.83, upper: true);
    _arcText(canvas, bottom, arcStyle, radius * 0.83, upper: false);

    _centered(
      canvas,
      day,
      AppTypography.display(
        size: radius * 0.3,
        exact: true,
        weight: FontWeight.w700,
        color: _ink,
        height: 1,
      ),
      center.translate(0, -radius * 0.08),
      maxWidth: radius * 1.1,
    );
    _centered(
      canvas,
      year,
      arcStyle.copyWith(fontSize: radius * 0.19, letterSpacing: radius * 0.03),
      center.translate(0, radius * 0.27),
    );

    // Ondas de cancelamento, da borda do carimbo até a borda do postal.
    if (!drawWaves) {
      canvas.restore();
      return;
    }
    final wave = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.06
      ..strokeCap = StrokeCap.round;
    final x0 = center.dx + radius * 1.12;
    final x1 = math.max(x0 + radius * 0.6, waveEnd);
    final amp = radius * 0.08;
    final len = radius * 0.5;
    for (var i = -1; i <= 1; i++) {
      final y = center.dy + i * radius * 0.32;
      final path = Path()..moveTo(x0, y);
      for (var x = x0; x <= x1; x += 2) {
        path.lineTo(x, y + amp * math.sin((x - x0) / len * math.pi * 2));
      }
      canvas.drawPath(path, wave);
    }
    canvas.restore();
  }

  /// Texto ao longo do arco: em cima, da esquerda para a direita; embaixo,
  /// também legível (as letras não ficam de cabeça para baixo).
  void _arcText(
    Canvas canvas,
    String text,
    TextStyle style,
    double r, {
    required bool upper,
  }) {
    if (text.isEmpty) return;
    final glyphs = [
      for (final ch in text.characters)
        TextPainter(
          text: TextSpan(text: ch, style: style),
          textDirection: TextDirection.ltr,
        )..layout(),
    ];
    final gap = r * 0.05;
    final total =
        glyphs.fold<double>(0, (s, g) => s + g.width) +
        gap * (glyphs.length - 1);
    // Não dá a volta: texto longo encolhe para caber em ~150°.
    final maxArc = math.pi * 0.85 * r;
    final k = total > maxArc ? maxArc / total : 1.0;
    var a =
        (upper ? -math.pi / 2 : math.pi / 2) +
        (upper ? -1 : 1) * total * k / (2 * r);
    for (final g in glyphs) {
      final w = (g.width + gap) * k;
      final mid = a + (upper ? 1 : -1) * (g.width * k / 2) / r;
      canvas.save();
      canvas.translate(
        center.dx + r * math.cos(mid),
        center.dy + r * math.sin(mid),
      );
      canvas.rotate(mid + (upper ? math.pi / 2 : -math.pi / 2));
      canvas.scale(k, k);
      g.paint(canvas, Offset(-g.width / 2, -g.height / 2));
      canvas.restore();
      a += (upper ? 1 : -1) * w / r;
    }
  }

  /// Texto centrado em [at]; mais largo que [maxWidth], encolhe.
  void _centered(
    Canvas canvas,
    String text,
    TextStyle style,
    Offset at, {
    double? maxWidth,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final k = maxWidth != null && tp.width > maxWidth
        ? maxWidth / tp.width
        : 1.0;
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.scale(k, k);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PostmarkPainter old) =>
      old.center != center ||
      old.radius != radius ||
      old.top != top ||
      old.day != day;
}

/// Revela [postcard] por cima de tudo: o Anan no topo, o postal chega
/// velado, a pessoa toca e a pintura aparece com o carimbo do dia. A frase
/// "Hoje" da cena vem no balão do Anan.
Future<void> showPostcardReveal(BuildContext context, Postcard postcard) =>
    _pushStage(context, _RevealStage(postcard: postcard));

/// Rever um postal (álbum, Bíblia): o mesmo palco, já revelado e
/// carimbado, com "Refazer a cena" no botão. [eyebrow] vai acima do título
/// ("Você esteve aqui", vindo da Bíblia).
Future<void> showPostcardDetail(
  BuildContext context,
  Postcard postcard, {
  VoidCallback? onRedo,
  String? eyebrow,
}) => _pushStage(
  context,
  _RevealStage(
    postcard: postcard,
    revisit: true,
    onRedo: onRedo,
    eyebrow: eyebrow,
  ),
);

Future<void> _pushStage(BuildContext context, Widget stage) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    PageRouteBuilder<void>(
      opaque: false,
      transitionDuration: AppMotion.gentle,
      reverseTransitionDuration: AppMotion.standard,
      pageBuilder: (_, _, _) => stage,
      transitionsBuilder: (_, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: AppMotion.enter,
          reverseCurve: AppMotion.exit,
        ),
        child: child,
      ),
    ),
  );
}

class _RevealStage extends StatefulWidget {
  final Postcard postcard;
  final bool revisit;
  final VoidCallback? onRedo;
  final String? eyebrow;

  const _RevealStage({
    required this.postcard,
    this.revisit = false,
    this.onRedo,
    this.eyebrow,
  });

  @override
  State<_RevealStage> createState() => _RevealStageState();
}

class _RevealStageState extends State<_RevealStage>
    with SingleTickerProviderStateMixin {
  /// 0–1: a pintura clareia (0–0.55), o carimbo pousa (0.5–0.7), a frase
  /// entra no balão (0.7–1).
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );
  bool _started = false;

  /// Card de story montado fora da tela só enquanto compartilha.
  final _shareKey = GlobalKey();
  ({PostcardShareInfo info, ValueNotifier<double> t})? _sharing;

  /// Progresso do vídeo (0–1) enquanto ele é gerado.
  double? _videoProgress;
  bool _stamped = false;

  @override
  void initState() {
    super.initState();
    if (widget.revisit) {
      _t.value = 1;
      _started = true;
      _stamped = true;
    }
    _t.addListener(_beat);
  }

  @override
  void dispose() {
    _t
      ..removeListener(_beat)
      ..dispose();
    super.dispose();
  }

  void _reveal() {
    if (_started) return;
    setState(() => _started = true);
    ActHaptics.tap();
    if (AppMotion.reduced(context)) {
      _t.value = 1;
      _stamp();
    } else {
      _t.forward();
    }
  }

  void _beat() {
    if (!_stamped && _t.value >= 0.55) _stamp();
  }

  void _stamp() {
    setState(() => _stamped = true);
    ActHaptics.success();
    SoundService.instance.playComplete();
  }

  static double _span(double t, double a, double b) =>
      ((t - a) / (b - a)).clamp(0.0, 1.0);

  void _close() => Navigator.of(context).pop();

  /// Imagem para todos; o postal animado (vídeo) é do Peregrino+.
  Future<void> _share() async {
    if (_sharing != null) return;
    final p = widget.postcard;
    final plus = context.read<SubscriptionService>().plusFeaturesOpen;
    final kind = await showPostcardShareSheet(context, plus: plus);
    if (kind == null || !mounted) return;
    if (kind == PostcardShareKind.video && !plus) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const PaywallScreen(source: 'postcard_video'),
        ),
      );
      return;
    }
    final info = await postcardShareInfo(context.read<ProgressService>(), p);
    // Tudo que o card desenha já decodificado: a captura sai logo depois
    // de montar (sem isso, logo e selo saíam em branco).
    for (final asset in [?p.art, ...PostcardShareCard.assets]) {
      if (!mounted) return;
      await precacheImage(AssetImage(asset), context);
    }
    if (!mounted) return;
    final video = kind == PostcardShareKind.video;
    final t = ValueNotifier<double>(video ? 0 : 1);
    setState(() {
      _sharing = (info: info, t: t);
      _videoProgress = video ? 0 : null;
    });
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    try {
      if (video) {
        final path = await PostcardVideo.render(
          boundaryKey: _shareKey,
          t: t,
          art: p.art,
          onProgress: (v) {
            if (mounted) setState(() => _videoProgress = v);
          },
        );
        if (mounted) setState(() => _videoProgress = null);
        if (path != null && mounted) {
          await PostcardVideo.share(context, path, p);
        }
      } else {
        await sharePostcardImage(
          context: context,
          boundaryKey: _shareKey,
          postcard: p,
        );
      }
    } catch (_) {
      // Vídeo falhou (encoder do aparelho): manda a imagem.
      if (!mounted) return;
      setState(() => _videoProgress = null);
      t.value = 1;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      await showAppToastFor(
        context,
        message: context.l10n.postcardShareVideoFailed,
        tone: AppToastTone.warn,
      );
      if (!mounted) return;
      await sharePostcardImage(
        context: context,
        boundaryKey: _shareKey,
        postcard: p,
      );
    } finally {
      if (mounted) {
        setState(() {
          _sharing = null;
          _videoProgress = null;
        });
      }
      t.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = widget.postcard;
    const ink = AppColors.textOnDark;
    const clean = TextStyle(
      decoration: TextDecoration.none,
      decorationColor: Color(0x00000000),
      decorationThickness: 0,
    );
    return Material(
      color: AppColors.night,
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, _) {
          final t = _t.value;
          final reveal = AppMotion.enter.transform(_span(t, 0, 0.55));
          final mark = _span(t, 0.5, 0.7);
          final done = t >= 1;
          final said = _stamped;
          return Stack(
            fit: StackFit.expand,
            children: [
              // Luz atrás do postal: acende com a revelação.
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, 0.2),
                      radius: 0.75,
                      colors: [
                        AppRoles.reward.withValues(alpha: 0.06 + 0.16 * reveal),
                        AppColors.night.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: DefaultTextStyle.merge(
                  style: clean,
                  child: LayoutBuilder(
                    builder: (context, box) {
                      // Anan + balão, título e botão no tamanho deles; o
                      // postal fica com o espaço que sobra, sem rolar.
                      final byWidth = math.min(
                        box.maxWidth - AppSpace.screen * 2 - 16,
                        360.0,
                      );
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.screen,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: AppSpace.md),
                            if (said && p.insight.isEmpty)
                              const CloudMascot(
                                face: CloudFace.sucesso,
                                size: 96,
                              )
                            else
                              AnanSpeech(
                                face: said
                                    ? CloudFace.sucesso
                                    : CloudFace.feliz,
                                ananSize: 96,
                                child: AnimatedSwitcher(
                                  duration: AppMotion.standard,
                                  child: said
                                      ? Text(
                                          p.insight,
                                          key: const ValueKey('today'),
                                          textAlign: TextAlign.center,
                                          style: AppTypography.display(
                                            size: 26,
                                            color: AnanSpeechBubble.ink,
                                            height: 1.15,
                                          ).merge(clean),
                                        )
                                      : Text(
                                          l10n.postcardTapHint,
                                          key: const ValueKey('hint'),
                                          textAlign: TextAlign.center,
                                          style: AppTypography.body(
                                            size: 16,
                                            color: AnanSpeechBubble.ink,
                                          ).merge(clean),
                                        ),
                                ),
                              ),
                            // Título e postal num bloco só, no meio do espaço
                            // livre: a folga fica igual acima e abaixo.
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, room) {
                                  // Rótulo + título em até 2 linhas + vãos.
                                  final head =
                                      widget.revisit && widget.eyebrow == null
                                      ? 96.0
                                      : 118.0;
                                  final byHeight =
                                      (room.maxHeight - head - AppSpace.lg) /
                                      (PostcardView.heightFor(100) / 100);
                                  final width = math.max(
                                    math.min(byWidth, byHeight),
                                    120.0,
                                  );
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (!widget.revisit ||
                                          widget.eyebrow != null) ...[
                                        SectionLabel(
                                          widget.eyebrow ??
                                              l10n.postcardEyebrow,
                                          color: AppRoles.reward,
                                        ),
                                        const SizedBox(height: AppSpace.xs),
                                      ],
                                      Text(
                                        p.title,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: AppTypography.display(
                                          size: 30,
                                          color: ink,
                                          height: 1.15,
                                        ).merge(clean),
                                      ),
                                      const SizedBox(height: AppSpace.lg),
                                      GestureDetector(
                                        onTap: _reveal,
                                        child: Transform.rotate(
                                          angle: -0.035 + 0.02 * reveal,
                                          child: PostcardView(
                                            postcard: p,
                                            width: width,
                                            reveal: reveal,
                                            postmark: mark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            IgnorePointer(
                              ignoring: _started && !done,
                              child: Opacity(
                                opacity: _started && !done ? 0.4 : 1,
                                child: widget.revisit
                                    ? CopperCta(
                                        label: l10n.postcardRedo,
                                        onTap: () {
                                          _close();
                                          widget.onRedo?.call();
                                        },
                                      )
                                    : CopperCta(
                                        label: _started
                                            ? l10n.commonContinue
                                            : l10n.postcardReveal,
                                        onTap: _started ? _close : _reveal,
                                      ),
                              ),
                            ),
                            if (done) ...[
                              const SizedBox(height: AppSpace.sm),
                              GhostCta(
                                label: l10n.commonShare,
                                leading: CinematicGlyph.share,
                                expanded: true,
                                onTap: _sharing == null ? _share : null,
                              ),
                            ],
                            const SizedBox(height: AppSpace.lg),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (_sharing case final share?)
                Positioned(
                  left: -4000,
                  top: 0,
                  child: RepaintBoundary(
                    key: _shareKey,
                    child: ValueListenableBuilder<double>(
                      valueListenable: share.t,
                      builder: (_, t, _) => PostcardShareCard(
                        postcard: p,
                        info: share.info,
                        t: t,
                      ),
                    ),
                  ),
                ),
              if (_videoProgress case final progress?)
                Positioned.fill(
                  child: ColoredBox(
                    color: AppColors.night.withValues(alpha: 0.92),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.screen * 2,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CloudMascot(
                              face: CloudFace.carregando,
                              size: 96,
                            ),
                            const SizedBox(height: AppSpace.lg),
                            Text(
                              l10n.postcardShareRendering,
                              style: AppTypography.title(size: 17, color: ink),
                            ),
                            const SizedBox(height: AppSpace.md),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                color: AppRoles.reward,
                                backgroundColor: ink.withValues(alpha: 0.15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              // Fechar fica solto no canto: não empurra o Anan para baixo.
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppSpace.sm),
                    child: IconButton(
                      onPressed: _close,
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      icon: CinematicIcon(
                        glyph: CinematicGlyph.back,
                        size: 36,
                        accent: ink.withValues(alpha: 0.85),
                        glowing: false,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
