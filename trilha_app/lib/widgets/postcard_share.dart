import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../data/trail_repository.dart';
import '../l10n/app_language.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'postcard.dart';
import 'stway_brand.dart';
import 'ui_primitives.dart';

/// O que o card mostra além do postal: trilha, posição da cena e remetente.
class PostcardShareInfo {
  final String trailTitle;
  final int index;
  final int total;

  /// Nome de quem envia; vazio = sem a linha "De:".
  final String from;

  const PostcardShareInfo({
    required this.trailTitle,
    required this.index,
    required this.total,
    required this.from,
  });
}

Future<PostcardShareInfo> postcardShareInfo(
  ProgressService progress,
  Postcard card,
) async {
  final name = progress.userName.trim();
  final from = name == 'Aprendiz' ? '' : name;
  for (final t in await TrailRepository().getTrails()) {
    final slugs = t.missionSlugs;
    final i = slugs.indexOf(card.slug);
    if (i < 0) continue;
    return PostcardShareInfo(
      trailTitle: t.localizedTitle,
      index: i + 1,
      total: slugs.length,
      from: from,
    );
  }
  return PostcardShareInfo(trailTitle: '', index: 0, total: 0, from: from);
}

const _paper = Color(0xFFF3EBDD);
const _paperBack = Color(0xFFF7F1E6);
const _ink = Color(0xFF3B2E1E);

/// Card de story do postal (9:16): a frente (a pintura em papel de foto) e,
/// por cima, o verso com a frase escrita, o selo, o carimbo e "Para / De".
/// O Anan espia pelo canto.
///
/// [t] anima a chegada (0 → 1): é o mesmo widget no vídeo do Peregrino+
/// (quadro a quadro) e na imagem (t = 1).
class PostcardShareCard extends StatelessWidget {
  final Postcard postcard;
  final PostcardShareInfo info;
  final double t;

  static const size = Size(360, 640);

  /// Imagens fixas do card, para o precache antes da captura.
  static final assets = [CloudFace.sucesso.body, 'assets/icon/app_icon.png'];

  /// Fundo (a pintura bem desfocada) já pronto, por pintura: no vídeo, o
  /// blur grande refeito a cada quadro era o desenho mais caro.
  static final _backdrops = <String, ui.Image>{};

  /// Prepara o fundo de [art] uma vez (decode pequeno: o blur esconde).
  static Future<void> warmBackdrop(String art) async {
    if (_backdrops.containsKey(art)) return;
    final data = await rootBundle.load(art);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 200,
    );
    final source = (await codec.getNextFrame()).image;
    const ratio = 2.0;
    final out = Size(size.width * ratio, size.height * ratio);
    final from =
        Offset.zero & Size(source.width.toDouble(), source.height.toDouble());
    final fitted = applyBoxFit(BoxFit.cover, from.size, out);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final to = Offset.zero & out;
    canvas.saveLayer(
      to,
      Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
    );
    canvas.drawImageRect(
      source,
      Alignment.center.inscribe(fitted.source, from),
      to,
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();
    final image = await recorder.endRecording().toImage(
      out.width.round(),
      out.height.round(),
    );
    source.dispose();
    for (final old in _backdrops.values) {
      old.dispose();
    }
    _backdrops
      ..clear()
      ..[art] = image;
  }

  const PostcardShareCard({
    super.key,
    required this.postcard,
    required this.info,
    this.t = 1,
  });

  static double _span(double t, double a, double b) =>
      ((t - a) / (b - a)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final art = postcard.art;
    // Linha do tempo da chegada.
    final intro = Curves.easeOut.transform(_span(t, 0, 0.1));
    final drop = Curves.easeOutCubic.transform(_span(t, 0.05, 0.22));
    final reveal = Curves.easeInOut.transform(_span(t, 0.22, 0.45));
    final slide = Curves.easeOutBack.transform(_span(t, 0.45, 0.6));
    final write = Curves.easeOut.transform(_span(t, 0.56, 0.7));
    final stamp = _span(t, 0.68, 0.78);
    final anan = Curves.easeOutBack.transform(_span(t, 0.76, 0.88));
    final outro = Curves.easeOut.transform(_span(t, 0.82, 0.94));

    Widget painting = art == null
        ? const ColoredBox(color: AppColors.night)
        : Image.asset(art, fit: BoxFit.cover);
    if (reveal < 1) {
      painting = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: 14 * (1 - reveal),
          sigmaY: 14 * (1 - reveal),
        ),
        child: Opacity(opacity: 0.35 + 0.65 * reveal, child: painting),
      );
    }

    final chip = info.total > 0
        ? l10n.postcardShareChip(info.index, info.total, info.trailTitle)
        : null;

    return MediaQuery(
      // Imagem parada: o Anan sem a animação própria (quem anima é [t]).
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: SizedBox.fromSize(
        size: size,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            const Positioned.fill(child: ColoredBox(color: Color(0xFF0B1626))),
            if (art != null)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.6 * intro,
                  child: switch (_backdrops[art]) {
                    final ui.Image ready => RawImage(
                      image: ready,
                      fit: BoxFit.cover,
                    ),
                    null => ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: Image.asset(art, fit: BoxFit.cover),
                    ),
                  },
                ),
              ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00081018), Color(0xE6081018)],
                    stops: [0.35, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              top: 24,
              child: Opacity(
                opacity: intro,
                child: Row(
                  children: [
                    const StwayLogo(size: 24),
                    const SizedBox(width: 8),
                    const StwayWordmark(
                      fontSize: 13,
                      letterSpacing: 2.2,
                      letterColor: AppColors.textOnDark,
                      aColor: AppColors.accent,
                    ),
                    const Spacer(),
                    if (chip != null) _Chip(chip),
                  ],
                ),
              ),
            ),
            // Frente: a pintura em papel de foto, chegando de cima.
            Positioned(
              left: 20,
              top: 78 - 60 * (1 - drop),
              child: Opacity(
                opacity: drop,
                child: Transform.rotate(
                  angle: -0.06,
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.all(9),
                    decoration: const BoxDecoration(
                      color: _paper,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x8C000000),
                          blurRadius: 22,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: AspectRatio(
                      aspectRatio: 3 / 2,
                      child: ClipRect(child: painting),
                    ),
                  ),
                ),
              ),
            ),
            // Verso: sobe por cima da frente.
            Positioned(
              left: 36,
              // Começa fora do card (abaixo dos 640): só aparece ao subir.
              top: 262 + 420 * (1 - slide),
              child: Transform.rotate(
                angle: 0.04 + 0.08 * (1 - slide),
                child: _Back(
                  postcard: postcard,
                  info: info,
                  write: write,
                  stamp: stamp,
                ),
              ),
            ),
            // O Anan espia por cima do canto do verso.
            Positioned(
              left: 4,
              top: 448,
              child: Transform.scale(
                scale: anan,
                child: const CloudMascot(
                  face: CloudFace.sucesso,
                  size: 96,
                  react: false,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 26,
              child: Opacity(
                opacity: outro,
                child: Column(
                  children: [
                    Text(
                      l10n.postcardShareTagline,
                      style: AppTypography.display(
                        size: 19,
                        exact: true,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textOnDark.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'stway.com.br',
                      style: AppTypography.label(
                        size: 9.5,
                        color: AppColors.textOnDark.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;

  const _Chip(this.text);

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0x33000000),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: AppRoles.reward.withValues(alpha: 0.6)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.label(
          size: 9.5,
          color: AppRoles.reward,
          letterSpacing: 1.4,
        ),
      ),
    ),
  );
}

/// Verso do postal: a frase escrita à esquerda; selo, carimbo e "Para /
/// De" à direita.
class _Back extends StatelessWidget {
  final Postcard postcard;
  final PostcardShareInfo info;
  final double write;
  final double stamp;

  const _Back({
    required this.postcard,
    required this.info,
    required this.write,
    required this.stamp,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lines = [
      l10n.postcardShareTo,
      if (info.from.isNotEmpty) l10n.postcardShareFrom(info.from),
      '',
    ];
    return Container(
      width: 304,
      height: 232,
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 16),
      decoration: const BoxDecoration(
        color: _paperBack,
        boxShadow: [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 11,
            child: Opacity(
              opacity: write,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 160,
                        child: Text(
                          postcard.insight,
                          style: AppTypography.display(
                            size: 25,
                            exact: true,
                            fontStyle: FontStyle.italic,
                            weight: FontWeight.w600,
                            color: _ink,
                            height: 1.12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (postcard.ref.isNotEmpty)
                    Text(
                      '— ${postcard.ref.toUpperCase()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(
                        size: 9.5,
                        color: _ink.withValues(alpha: 0.75),
                        letterSpacing: 1.4,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: _ink.withValues(alpha: 0.25),
          ),
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    width: 96,
                    height: 82,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Transform.rotate(
                            angle: 0.05,
                            child: PostcardPin(
                              postcard: postcard,
                              width: 62,
                              fullDecode: true,
                            ),
                          ),
                        ),
                        if (stamp > 0)
                          Positioned(
                            left: -10,
                            top: 22,
                            child: Opacity(
                              opacity: (stamp * 2).clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale:
                                    1.6 -
                                    0.6 * Curves.easeOutBack.transform(stamp),
                                child: PostmarkStamp(
                                  radius: 24,
                                  top: postcard.book,
                                  on: postcard.on,
                                  waves: false,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                for (final line in lines)
                  Container(
                    height: 26,
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: _ink.withValues(alpha: 0.3)),
                      ),
                    ),
                    child: Opacity(
                      opacity: write,
                      child: Text(
                        line,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.display(
                          size: 15,
                          exact: true,
                          fontStyle: FontStyle.italic,
                          color: _ink.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum PostcardShareKind { image, video }

/// Vídeo ou imagem: a escolha antes de compartilhar. O vídeo é do
/// Peregrino+; sem ele, a opção leva o cadeado.
Future<PostcardShareKind?> showPostcardShareSheet(
  BuildContext context, {
  required bool plus,
}) {
  final l10n = context.l10n;
  return showAppSheet<PostcardShareKind>(
    context,
    builder: (sheet) => AppSheetPanel(
      tint: AppRoles.reward,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(
            leading: const CloudMascot(face: CloudFace.feliz, size: 72),
            title: l10n.postcardShareSheetTitle,
            center: true,
          ),
          const SizedBox(height: AppSpace.xl),
          CopperCta(
            label: l10n.postcardShareVideo,
            leading: plus ? CinematicGlyph.spark : CinematicGlyph.lock,
            subtitle: plus ? null : l10n.postcardShareVideoPlus,
            expanded: true,
            onTap: () => Navigator.pop(sheet, PostcardShareKind.video),
          ),
          const SizedBox(height: AppSpace.sm),
          GhostCta(
            label: l10n.postcardShareImage,
            leading: CinematicGlyph.share,
            expanded: true,
            onTap: () => Navigator.pop(sheet, PostcardShareKind.image),
          ),
        ],
      ),
    ),
  );
}

/// Captura o card em [boundaryKey] (já montado, imagens em cache) e abre o
/// compartilhar do sistema.
Future<void> sharePostcardImage({
  required BuildContext context,
  required GlobalKey boundaryKey,
  required Postcard postcard,
}) async {
  final text = _shareText(context, postcard);
  ActHaptics.light();
  await WidgetsBinding.instance.endOfFrame;
  final boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    await SharePlus.instance.share(ShareParams(text: text));
    return;
  }
  final image = await boundary.toImage(pixelRatio: 3);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) return;
  final file = File('${Directory.systemTemp.path}/stway_postal.png');
  await file.writeAsBytes(bytes.buffer.asUint8List());
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'image/png')],
      text: text,
    ),
  );
}

String _shareText(BuildContext context, Postcard postcard) {
  final ref = postcard.ref.trim();
  return context.l10n.postcardShareText(
    postcard.insight,
    ref.isEmpty ? '' : '— $ref',
  );
}

/// Vídeo do postal (Peregrino+): anda [t] de 0 a 1, captura cada quadro do
/// card em [boundaryKey] e manda para o encoder nativo (canal
/// `stway/video`: MediaCodec no Android, AVAssetWriter no iOS).
class PostcardVideo {
  PostcardVideo._();

  static const _channel = MethodChannel('stway/video');
  static const fps = 24;
  static const seconds = 6;

  /// Pixel ratio do quadro: 360×640 → 720×1280.
  static const _ratio = 2.0;

  /// Devolve o caminho do MP4.
  static Future<String?> render({
    required GlobalKey boundaryKey,
    required ValueNotifier<double> t,
    String? art,
    ValueChanged<double>? onProgress,
  }) async {
    if (art != null) await PostcardShareCard.warmBackdrop(art);
    final path = '${Directory.systemTemp.path}/stway_postal.mp4';
    final w = (PostcardShareCard.size.width * _ratio).round();
    final h = (PostcardShareCard.size.height * _ratio).round();
    const frames = fps * seconds;
    await _channel.invokeMethod<void>('start', {
      'path': path,
      'width': w,
      'height': h,
      'fps': fps,
      'bitrate': 6000000,
    });
    try {
      final draw = Stopwatch();
      final send = Stopwatch();
      // Um quadro no encoder enquanto o próximo é desenhado.
      Future<void>? pending;
      Uint8List? last;
      var lastT = -1.0;
      for (var i = 0; i < frames; i++) {
        // A chegada dura 5 s; o último segundo segura o quadro final, que
        // vai de novo sem redesenhar.
        final at = (i / (fps * 5)).clamp(0.0, 1.0);
        var bytes = last;
        if (bytes == null || at != lastT) {
          t.value = at;
          draw.start();
          await WidgetsBinding.instance.endOfFrame;
          final boundary =
              boundaryKey.currentContext?.findRenderObject()
                  as RenderRepaintBoundary?;
          if (boundary == null) throw StateError('card fora da árvore');
          final image = await boundary.toImage(pixelRatio: _ratio);
          final rgba = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          image.dispose();
          draw.stop();
          if (rgba == null) throw StateError('quadro vazio');
          bytes = last = rgba.buffer.asUint8List();
          lastT = at;
        }
        send.start();
        await pending;
        send.stop();
        pending = _channel.invokeMethod<void>('frame', bytes);
        onProgress?.call((i + 1) / frames);
      }
      send.start();
      await pending;
      send.stop();
      debugPrint(
        'PostcardVideo: desenho ${draw.elapsedMilliseconds} ms, '
        'espera do encoder ${send.elapsedMilliseconds} ms ($frames quadros)',
      );
      return await _channel.invokeMethod<String>('finish');
    } catch (_) {
      await _channel.invokeMethod<void>('cancel');
      rethrow;
    }
  }

  static Future<void> share(BuildContext context, String path, Postcard card) =>
      SharePlus.instance.share(
        ShareParams(
          files: [XFile(path, mimeType: 'video/mp4')],
          text: _shareText(context, card),
        ),
      );
}
