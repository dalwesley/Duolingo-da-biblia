import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/bible_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

/// Abre sheet para compartilhar um versículo (imagem com marca Steway, ou texto).
Future<void> showShareVerseSheet(
  BuildContext context, {
  required String bookName,
  required int chapter,
  required int verse,
  required String text,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
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

  Future<void> _rememberShare() async {
    if (!mounted) return;
    await context.read<ProgressService>().recordSharedVerse(_ref);
  }

  Future<void> _shareImage() async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.lightImpact();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
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
          text: '$_ref — via Steway',
          subject: '$_ref — Steway',
        ),
      );
      await _rememberShare();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareText() async {
    HapticFeedback.lightImpact();
    final body = '''
“${widget.text}”

— $_ref
${BibleService.translationName}

Via Steway
'''
        .trim();
    await SharePlus.instance.share(
      ShareParams(text: body, subject: '$_ref — Steway'),
    );
    await _rememberShare();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(18, 14, 18, 14 + bottom),
      decoration: BoxDecoration(
        color: const Color(0xFF1A221E),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Compartilhar versículo',
            style: AppTypography.label(
              size: 13,
              weight: FontWeight.w900,
              letterSpacing: 0.6,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
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
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _busy ? null : _shareImage,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.inkOnAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
              ),
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.inkOnAccent,
                      ),
                    )
                  : const Icon(Icons.image_rounded, size: 20),
              label: Text(
                _busy ? 'Preparando…' : 'Compartilhar imagem',
                style: AppTypography.cta(),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          TextButton(
            onPressed: _busy ? null : _shareText,
            child: Text(
              'Compartilhar como texto',
              style: AppTypography.title(
                weight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E1210), Color(0xFF152820), Color(0xFF161C19)],
        ),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'STEWAY',
                style: AppTypography.label(
                  size: 12,
                  weight: FontWeight.w900,
                  letterSpacing: 2.2,
                  color: AppColors.accent.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '“$text”',
            style: AppTypography.display(
              size: 22,
              height: 1.35,
              weight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '$bookName $chapter:$verse',
            style: AppTypography.title(
              size: 13,
              weight: FontWeight.w800,
              color: AppColors.accent.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            BibleService.translationName,
            style: AppTypography.body(
              size: 11,
              color: Colors.white.withValues(alpha: 0.45),
            ).copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
