import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_language.dart';
import '../services/bible_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'app_sheet.dart';
import 'stway_brand.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Abre sheet para compartilhar um versículo (imagem com marca Stway, ou texto).
Future<void> showShareVerseSheet(
  BuildContext context, {
  required String bookName,
  required int chapter,
  required int verse,
  required String text,
}) {
  return showAppSheet<void>(
    context,
    builder: (_) => _ShareVerseSheet(
      bookName: bookName,
      chapter: chapter,
      verse: verse,
      text: text,
    ),
  );
}

class _ShareVerseSheet extends StatefulWidget {
  final String bookName;
  final int chapter;
  final int verse;
  final String text;

  const _ShareVerseSheet({
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  @override
  State<_ShareVerseSheet> createState() => _ShareVerseSheetState();
}

class _ShareVerseSheetState extends State<_ShareVerseSheet> {
  final _boundaryKey = GlobalKey();
  bool _busy = false;

  String get _ref => '${widget.bookName} ${widget.chapter}:${widget.verse}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(const AssetImage('assets/icon/splash_bg.png'), context);
      precacheImage(const AssetImage('assets/icon/app_icon.png'), context);
    });
  }

  Future<void> _rememberShare() async {
    if (!mounted) return;
    await context.read<ProgressService>().recordSharedVerse(_ref);
  }

  Future<void> _shareImage() async {
    if (_busy) return;
    final shareText = context.l10n.bibleShareVia(_ref);
    setState(() => _busy = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      final file = File(
        '${Directory.systemTemp.path}/trilha_${widget.bookName}_${widget.chapter}_${widget.verse}.png'
            .replaceAll(' ', '_'),
      );
      await file.writeAsBytes(bytes.buffer.asUint8List());
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: shareText,
          subject: '$_ref — Stway',
        ),
      );
      await _rememberShare();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareText() async {
    final body =
        '''
“${widget.text}”

— $_ref
${BibleService.translationName}

${context.l10n.bibleShareTextFooter}
'''
            .trim();
    await SharePlus.instance.share(
      ShareParams(text: body, subject: '$_ref — Stway'),
    );
    await _rememberShare();
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSheetHeader(title: context.l10n.bibleShareTitle, center: true),
          const SizedBox(height: 14),
          RepaintBoundary(
            key: _boundaryKey,
            child: ShareVerseCard(
              bookName: widget.bookName,
              chapter: widget.chapter,
              verse: widget.verse,
              text: widget.text,
            ),
          ),
          const SizedBox(height: 16),
          CopperCta(
            label: _busy
                ? context.l10n.bibleSharePreparing
                : context.l10n.bibleShareImage,
            onTap: _busy ? null : _shareImage,
            leading: CinematicGlyph.share,
            trailing: null,
            dense: true,
            busy: _busy,
          ),
          const SizedBox(height: AppSpace.sm),
          TextCta(
            label: context.l10n.bibleShareAsText,
            onTap: _busy ? null : _shareText,
          ),
        ],
      ),
    );
  }
}

/// Card visual usado na imagem compartilhada.
class ShareVerseCard extends StatelessWidget {
  final String bookName;
  final int chapter;
  final int verse;
  final String text;

  const ShareVerseCard({
    super.key,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 300),
        child: Stack(
          children: [
            // Fundo fixo da imagem exportada (marca), igual em qualquer fase.
            const Positioned.fill(
              child: ColoredBox(color: AppColors.primaryDark),
            ),
            // Trilha da splash só como detalhe — bem suave.
            Positioned.fill(
              child: Opacity(
                opacity: 0.38,
                child: Image.asset(
                  'assets/icon/splash_bg.png',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.12),
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.22),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.32),
                    ],
                    stops: const [0, 0.45, 1],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: a.cardBorder),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const StwayLogo(size: 30),
                      const SizedBox(width: 10),
                      StwayWordmark(
                        fontSize: 15,
                        letterSpacing: 2.4,
                        letterColor: a.text,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    '“$text”',
                    style:
                        AppTypography.display(
                          size: 20,
                          height: 1.35,
                          weight: FontWeight.w600,
                          color: a.text,
                        ).copyWith(
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.55),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    '$bookName $chapter:$verse',
                    style:
                        AppTypography.title(
                          size: 12,
                          color: a.textSecondary,
                        ).copyWith(
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    BibleService.translationName,
                    style: AppTypography.body(
                      size: 11,
                      color: a.textFaint,
                    ).copyWith(fontStyle: FontStyle.italic),
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
