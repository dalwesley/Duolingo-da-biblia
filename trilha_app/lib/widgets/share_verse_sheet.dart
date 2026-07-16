import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../services/bible_service.dart';
import '../theme/app_theme.dart';

/// Abre sheet para compartilhar um versículo (imagem com marca Trilha, ou texto).
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
          text: '$_ref — via Trilha',
          subject: '$_ref — Trilha',
        ),
      );
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

Via Trilha
'''
        .trim();
    await SharePlus.instance.share(
      ShareParams(text: body, subject: '$_ref — Trilha'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(18, 14, 18, 14 + bottom),
      decoration: BoxDecoration(
        color: const Color(0xFF1A221E),
        borderRadius: BorderRadius.circular(24),
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
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
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
                  borderRadius: BorderRadius.circular(16),
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
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _busy ? null : _shareText,
            child: Text(
              'Compartilhar como texto',
              style: TextStyle(
                fontWeight: FontWeight.w700,
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
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF121816), Color(0xFF1E3D32), Color(0xFF1A221E)],
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
                'TRILHA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                  color: AppColors.accent.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '“$text”',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '$bookName $chapter:$verse',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.accent.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            BibleService.translationName,
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}
