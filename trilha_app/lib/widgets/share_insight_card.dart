import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'cloud_mascot.dart';
import 'stway_brand.dart';
import 'today_stage.dart';
import 'ui_primitives.dart';

/// Carta do insight — "Hoje: …" para Stories / WhatsApp.
class ShareInsightCard extends StatelessWidget {
  final String insight;
  final String? verseRef;
  final String? verseText;

  /// Pintura da cena: com ela, o card é a placa Hoje ([TodayStage]) parada,
  /// com a marca; sem ela, o card de marca de sempre.
  final String? art;

  const ShareInsightCard({
    super.key,
    required this.insight,
    this.verseRef,
    this.verseText,
    this.art,
  });

  /// Tamanho do card com pintura: 4:5, o postal — cabe inteiro na conversa
  /// do WhatsApp e no feed.
  static const artSize = Size(360, 450);

  @override
  Widget build(BuildContext context) {
    if (art != null) {
      return TodayStage(
        insight: insight,
        art: art,
        reference: verseRef ?? '',
        on: DateTime.now(),
        accent: AppRoles.reward,
        still: true,
      );
    }
    // Imagem exportada: arte escura fixa (marca) — tinta clara em qualquer look.
    final a = AppearanceStyle.resolve(AppearanceMode.night);
    final line = insight.trim();
    final ref = (verseRef ?? '').trim();
    final verse = (verseText ?? '').trim();
    // Altura finita obrigatória: Spacers no Column quebram com h=∞
    // (ex.: Positioned off-screen só com width na celebration).
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: AspectRatio(
        aspectRatio: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 280, minWidth: 280),
          child: Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: AppColors.primaryDark),
              ),
              Positioned.fill(
                child: Opacity(
                  opacity: 0.32,
                  child: Image.asset(
                    'assets/icon/splash_bg.png',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.12),
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, _, _) =>
                        const ColoredBox(color: AppColors.primaryDark),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(
                      color: AppRoles.reward.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const StwayLogo(size: 26),
                        const SizedBox(width: 10),
                        StwayWordmark(
                          fontSize: 14,
                          letterSpacing: 2.2,
                          letterColor: a.text,
                          aColor: AppColors.accent,
                        ),
                      ],
                    ),
                    const Spacer(),
                    SectionLabel(
                      context.l10n.commonToday,
                      color: AppRoles.reward,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      line,
                      style: AppTypography.title(
                        size: 22,
                        height: 1.28,
                        color: a.text,
                      ),
                    ),
                    if (verse.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text(
                        '“$verse”',
                        style: AppTypography.verse(
                          size: 15,
                          height: 1.4,
                          color: a.textSecondary,
                        ),
                      ),
                    ],
                    if (ref.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        ref,
                        style: AppTypography.body(
                          size: 12,
                          weight: FontWeight.w700,
                          color: a.textFaint,
                        ),
                      ),
                    ],
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> shareInsightImage({
  required GlobalKey boundaryKey,
  required String insight,
  String? verseRef,
}) async {
  ActHaptics.light();
  await Future<void>.delayed(const Duration(milliseconds: 50));
  await WidgetsBinding.instance.endOfFrame;
  final text = _insightShareText(insight, verseRef);
  final boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    await SharePlus.instance.share(
      ShareParams(text: text, subject: 'Hoje — Stway'),
    );
    return;
  }
  final image = await boundary.toImage(pixelRatio: 3);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) return;
  final file = File('${Directory.systemTemp.path}/stway_hoje.png');
  await file.writeAsBytes(bytes.buffer.asUint8List());
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'image/png')],
      text: text,
      subject: 'Hoje — Stway',
    ),
  );
}

String _insightShareText(String insight, String? verseRef) {
  final line = insight.trim();
  final ref = (verseRef ?? '').trim();
  final buf = StringBuffer('Hoje: $line');
  if (ref.isNotEmpty) {
    buf.write('\n\n— $ref');
  }
  buf.write('\n\nCena curta no Stway · stway.com.br');
  return buf.toString();
}

/// Monta o card fora da tela, espera a pintura decodificar e compartilha.
/// Para telas que não têm o card montado (placa Hoje, revisão da semana).
Future<void> shareTodayCard(
  BuildContext context, {
  required String insight,
  String? verseRef,
  String? art,
}) async {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  // Tudo que o card desenha já decodificado: a captura sai logo depois de
  // montar (sem isso, Anan, logo e pintura saíam em branco).
  if (art != null) {
    final images = <ImageProvider>[
      AssetImage(art),
      ResizeImage(AssetImage(art), width: 24),
      AssetImage(CloudFace.sucesso.body),
      const AssetImage('assets/icon/app_icon.png'),
    ];
    for (final image in images) {
      if (!context.mounted) return;
      try {
        await precacheImage(image, context);
      } catch (_) {}
    }
  }
  final size = art != null ? ShareInsightCard.artSize : const Size(360, 360);
  final key = GlobalKey();
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -4000,
      top: 0,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: RepaintBoundary(
          key: key,
          child: ShareInsightCard(
            insight: insight,
            verseRef: verseRef,
            art: art,
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  try {
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
    await shareInsightImage(
      boundaryKey: key,
      insight: insight,
      verseRef: verseRef,
    );
  } finally {
    entry.remove();
  }
}
