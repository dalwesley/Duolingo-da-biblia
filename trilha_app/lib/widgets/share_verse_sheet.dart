import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_language.dart';
import '../models/bible_note.dart';
import '../services/bible_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'app_sheet.dart';
import 'bible_note_tag.dart';
import 'stway_brand.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Abre sheet para compartilhar um versículo (imagem com marca Stway, ou texto).
///
/// Com [note], a anotação vai junto (o peregrino pode tirar antes de enviar).
Future<void> showShareVerseSheet(
  BuildContext context, {
  required String bookName,
  required int chapter,
  required int verse,
  required String text,
  BibleNote? note,
}) {
  return showAppSheet<void>(
    context,
    builder: (_) => _ShareVerseSheet(
      bookName: bookName,
      chapter: chapter,
      verse: verse,
      text: text,
      note: note?.tag == null ? null : note,
    ),
  );
}

class _ShareVerseSheet extends StatefulWidget {
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final BibleNote? note;

  const _ShareVerseSheet({
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    this.note,
  });

  @override
  State<_ShareVerseSheet> createState() => _ShareVerseSheetState();
}

class _ShareVerseSheetState extends State<_ShareVerseSheet> {
  final _boundaryKey = GlobalKey();
  bool _busy = false;
  bool _withNote = true;

  String get _ref => '${widget.bookName} ${widget.chapter}:${widget.verse}';

  BibleNote? get _note => _withNote ? widget.note : null;

  /// "Anotação de Ana" — sem nome real, "Minha anotação".
  String _noteAuthor() {
    final name = context.read<ProgressService>().userName;
    return ProgressService.isPlaceholderUserName(name)
        ? context.l10n.bibleShareNoteMine
        : context.l10n.bibleShareNoteBy(name.trim());
  }

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
    final note = _note;
    final noteBlock = note == null
        ? ''
        : [
            '',
            '${_noteAuthor()} · ${bibleNoteTagLabel(context, note.tag!)}',
            if (note.text.isNotEmpty) note.text,
            '',
          ].join('\n');
    final body =
        '''
“${widget.text}”

— $_ref
${BibleService.translationName}
$noteBlock
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
              note: _note,
              noteAuthor: _note == null ? null : _noteAuthor(),
            ),
          ),
          if (widget.note != null) ...[
            const SizedBox(height: AppSpace.sm),
            _IncludeNoteRow(
              value: _withNote,
              onChanged: _busy ? null : (v) => setState(() => _withNote = v),
            ),
          ],
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

class _IncludeNoteRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _IncludeNoteRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.bibleShareIncludeNote,
            style: AppTypography.body(
              size: 14,
              weight: FontWeight.w600,
              color: a.text,
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppRoles.selected,
          activeTrackColor: AppRoles.success,
          inactiveThumbColor: a.textSecondary,
          inactiveTrackColor: a.insetFill,
          trackOutlineColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppRoles.success
                : a.cardBorder,
          ),
        ),
      ],
    );
  }
}

/// Card visual usado na imagem compartilhada.
class ShareVerseCard extends StatelessWidget {
  final String bookName;
  final int chapter;
  final int verse;
  final String text;

  /// Anotação do peregrino, abaixo da referência, no fio da cor do tema.
  final BibleNote? note;
  final String? noteAuthor;

  const ShareVerseCard({
    super.key,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    this.note,
    this.noteAuthor,
  });

  @override
  Widget build(BuildContext context) {
    // Imagem exportada: arte escura fixa (marca) — tinta clara em qualquer look.
    final a = AppearanceStyle.resolve(AppearanceMode.night);
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
                    style: AppTypography.title(size: 12, color: a.textSecondary)
                        .copyWith(
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
                  if (note?.tag case final tag?) ...[
                    const SizedBox(height: 18),
                    _CardNote(tag: tag, text: note!.text, author: noteAuthor),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardNote extends StatelessWidget {
  final BibleNoteTag tag;
  final String text;
  final String? author;

  const _CardNote({required this.tag, required this.text, this.author});

  @override
  Widget build(BuildContext context) {
    final a = AppearanceStyle.resolve(AppearanceMode.night);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border(left: BorderSide(color: tag.color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: tag.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  [bibleNoteTagLabel(context, tag), ?author].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label(
                    size: 11,
                    letterSpacing: 0.4,
                    color: a.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              text,
              style: AppTypography.body(size: 14, height: 1.4, color: a.text),
            ),
          ],
        ],
      ),
    );
  }
}
