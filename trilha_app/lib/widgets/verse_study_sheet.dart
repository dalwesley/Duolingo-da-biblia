import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/bible_service.dart';
import '../services/bible_study_service.dart';
import '../theme/app_theme.dart';

Future<void> showVerseStudySheet(
  BuildContext context, {
  required int bookIndex,
  required String bookName,
  required int chapter,
  required int verse,
  required String text,
  void Function(int bookIndex, int chapter, int verse)? onOpenRef,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _VerseStudySheet(
      bookIndex: bookIndex,
      bookName: bookName,
      chapter: chapter,
      verse: verse,
      text: text,
      onOpenRef: onOpenRef,
    ),
  );
}

/// Abre o estudo Strong a partir de uma referência textual ("Êxodo 16:4").
Future<void> showVerseStudyFromReference(
  BuildContext context,
  String reference,
) async {
  final ref = await BibleService.instance.resolve(reference);
  if (ref == null || !context.mounted) return;

  final books = await BibleService.instance.books();
  if (!context.mounted) return;
  if (ref.bookIndex < 0 || ref.bookIndex >= books.length) return;

  final book = books[ref.bookIndex];
  final verse = ref.verseStart ?? 1;
  final text =
      await BibleService.instance.verseText(book.abbrev, ref.chapter, verse) ??
          '';
  if (!context.mounted) return;

  await showVerseStudySheet(
    context,
    bookIndex: ref.bookIndex,
    bookName: book.name,
    chapter: ref.chapter,
    verse: verse,
    text: text,
  );
}

/// Prévia de referência: lê o versículo sem sair do estudo.
Future<void> showVersePreviewDialog(
  BuildContext context, {
  required int bookIndex,
  required int chapter,
  required int verse,
  int? verseEnd,
  void Function(int bookIndex, int chapter, int verse)? onGoToText,
}) async {
  final books = await BibleService.instance.books();
  if (!context.mounted) return;

  final name = (bookIndex >= 0 && bookIndex < books.length)
      ? books[bookIndex].name
      : 'Livro ${bookIndex + 1}';
  final end = verseEnd != null && verseEnd != verse ? verseEnd : verse;

  final verses = <String>[];
  if (bookIndex >= 0 && bookIndex < books.length) {
    final chapters = books[bookIndex].chapters;
    if (chapter >= 1 && chapter <= chapters.length) {
      final list = chapters[chapter - 1];
      for (var v = verse; v <= end && v <= list.length; v++) {
        verses.add(list[v - 1]);
      }
    }
  }

  final refLabel = end != verse
      ? '$name $chapter:$verse–$end'
      : '$name $chapter:$verse';

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1A221C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
        title: Text(
          refLabel,
          style: AppTypography.title(
            color: AppColors.accent,
            weight: FontWeight.w800,
            size: 16,
          ),
        ),
        content: SingleChildScrollView(
          child: verses.isEmpty
              ? Text(
                  'Versículo indisponível nesta tradução.',
                  style: AppTypography.body(
                    color: Colors.white.withValues(alpha: 0.65),
                    height: 1.35,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < verses.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      if (verses.length > 1)
                        Text(
                          '${verse + i}',
                          style: AppTypography.label(
                            size: 11,
                            weight: FontWeight.w800,
                            color: AppColors.accent.withValues(alpha: 0.8),
                          ),
                        ),
                      Text(
                        verses[i],
                        style: AppTypography.display(
                          size: 18,
                          height: 1.4,
                          weight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      BibleService.translationName,
                      style: AppTypography.body(
                        size: 11,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Fechar',
              style: AppTypography.title(
                weight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Fecha o sheet de estudo e navega.
              Navigator.pop(context);
              onGoToText?.call(bookIndex, chapter, verse);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: const Color(0xFF1A221C),
            ),
            child: Text(
              'Ir para o texto',
              style: AppTypography.title(weight: FontWeight.w800),
            ),
          ),
        ],
      );
    },
  );
}

class _VerseStudySheet extends StatefulWidget {
  final int bookIndex;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final void Function(int bookIndex, int chapter, int verse)? onOpenRef;

  const _VerseStudySheet({
    required this.bookIndex,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    this.onOpenRef,
  });

  @override
  State<_VerseStudySheet> createState() => _VerseStudySheetState();
}

class _VerseStudySheetState extends State<_VerseStudySheet> {
  late Future<VerseStudy> _future;
  StudyToken? _selected;
  StrongEntry? _entry;
  List<ConcordanceHit> _hits = const [];
  int _occ = 0;
  bool _loadingStrong = false;

  String get _ref =>
      '${widget.bookName} ${widget.chapter}:${widget.verse}';

  @override
  void initState() {
    super.initState();
    _future = BibleStudyService.instance.studyVerse(
      widget.bookIndex,
      widget.chapter,
      widget.verse,
    );
  }

  Future<void> _selectToken(StudyToken token) async {
    HapticFeedback.selectionClick();
    setState(() {
      _selected = token;
      _loadingStrong = true;
      _entry = null;
      _hits = const [];
    });
    final svc = BibleStudyService.instance;
    final entry = await svc.strong(token.strong);
    final count = await svc.occurrenceCount(token.strong);
    final hits = await svc.concordance(token.strong, limit: 24);
    if (!mounted) return;
    setState(() {
      _entry = entry;
      _occ = count;
      _hits = hits;
      _loadingStrong = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final height = MediaQuery.sizeOf(context).height * 0.88;

    return Container(
      height: height,
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141C18),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 10, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estudar',
                        style: AppTypography.display(
                          size: 26,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _ref,
                        style: AppTypography.title(
                          size: 13,
                          weight: FontWeight.w800,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
            child: Text(
              widget.text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.display(
                size: 18,
                height: 1.35,
                weight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.88),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<VerseStudy>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  );
                }
                if (snap.hasError) {
                  final err = snap.error.toString();
                  final needsRestart = err.contains('MissingPluginException');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        needsRestart
                            ? 'O estudo precisa de um reinício completo do app.\n\nPare o app e rode flutter run de novo (hot reload não basta).'
                            : 'Não foi possível carregar o estudo.',
                        textAlign: TextAlign.center,
                        style: AppTypography.body(
                          color: Colors.white.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                }
                final study = snap.data!;
                if (study.tokens.isEmpty && study.crossRefs.isEmpty) {
                  return Center(
                    child: Text(
                      'Sem dados de originais para este versículo.',
                      style: AppTypography.body(
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 16 + bottom),
                  children: [
                    if (study.tokens.isNotEmpty) ...[
                      _sectionTitle('Palavras originais'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final t in study.tokens)
                            _TokenChip(
                              token: t,
                              selected: _selected?.pos == t.pos,
                              onTap: () => _selectToken(t),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (_selected != null) ...[
                      _StrongPanel(
                        token: _selected!,
                        entry: _entry,
                        loading: _loadingStrong,
                        occurrences: _occ,
                        hits: _hits,
                        onOpenHit: (h) {
                          showVersePreviewDialog(
                            context,
                            bookIndex: h.bookIndex,
                            chapter: h.chapter,
                            verse: h.verse,
                            onGoToText: widget.onOpenRef,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ] else if (study.tokens.isNotEmpty) ...[
                      Text(
                        'Toque numa palavra para ver Strong, morfologia e concordância.',
                        style: AppTypography.body(
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (study.crossRefs.isNotEmpty) ...[
                      _sectionTitle('Referências cruzadas'),
                      const SizedBox(height: 8),
                      ...study.crossRefs.map((r) {
                        final books = BibleService.instance;
                        return FutureBuilder(
                          future: books.books(),
                          builder: (context, bookSnap) {
                            final list = bookSnap.data;
                            final name = (list != null &&
                                    r.bookIndex >= 0 &&
                                    r.bookIndex < list.length)
                                ? list[r.bookIndex].name
                                : 'Livro ${r.bookIndex + 1}';
                            final end = r.verseEnd != null &&
                                    r.verseEnd != r.verse
                                ? '–${r.verseEnd}'
                                : '';
                            final label = '$name ${r.chapter}:${r.verse}$end';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(AppRadii.sm),
                                  onTap: () {
                                    showVersePreviewDialog(
                                      context,
                                      bookIndex: r.bookIndex,
                                      chapter: r.chapter,
                                      verse: r.verse,
                                      verseEnd: r.verseEnd,
                                      onGoToText: widget.onOpenRef,
                                    );
                                  },
                                  child: Ink(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(AppRadii.sm),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.08,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            label,
                                            style: AppTypography.title(
                                              color: Colors.white,
                                              weight: FontWeight.w700,
                                              size: 13,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${r.votes}',
                                          style: AppTypography.body(
                                            size: 11,
                                            color: Colors.white.withValues(
                                              alpha: 0.35,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          size: 18,
                                          color: Colors.white.withValues(
                                            alpha: 0.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      BibleStudyService.attribution,
                      style: AppTypography.body(
                        size: 10,
                        height: 1.35,
                        color: Colors.white.withValues(alpha: 0.32),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Text(
      t,
      style: AppTypography.label(
        size: 12,
        weight: FontWeight.w900,
        letterSpacing: 0.4,
        color: Colors.white.withValues(alpha: 0.55),
      ),
    );
  }
}

class _TokenChip extends StatelessWidget {
  final StudyToken token;
  final bool selected;
  final VoidCallback onTap;

  const _TokenChip({
    required this.token,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rtl = token.strong.startsWith('H');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(
              color: selected
                  ? AppColors.accent.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                token.surface,
                textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                style: AppTypography.title(
                  size: rtl ? 18 : 15,
                  weight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                token.gloss.isEmpty ? token.strong : token.gloss,
                style: AppTypography.label(
                  size: 10,
                  weight: FontWeight.w700,
                  color: selected
                      ? AppColors.accent
                      : Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StrongPanel extends StatelessWidget {
  final StudyToken token;
  final StrongEntry? entry;
  final bool loading;
  final int occurrences;
  final List<ConcordanceHit> hits;
  final void Function(ConcordanceHit hit) onOpenHit;

  const _StrongPanel({
    required this.token,
    required this.entry,
    required this.loading,
    required this.occurrences,
    required this.hits,
    required this.onOpenHit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        token.strong,
                        style: AppTypography.label(
                          size: 12,
                          weight: FontWeight.w900,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry?.gloss.isNotEmpty == true
                            ? entry!.gloss
                            : token.gloss,
                        style: AppTypography.title(
                          size: 15,
                          weight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (entry != null) ...[
                  _kv('Lema', entry!.lemma),
                  _kv('Transliteração', entry!.translit),
                ] else ...[
                  _kv('Forma', token.surface),
                  _kv('Transliteração', token.translit),
                ],
                if (token.morphLabel.isNotEmpty)
                  _kv('Morfologia', token.morphLabel),
                if (token.morph.isNotEmpty)
                  _kv('Código', token.morph),
                if (entry?.definition.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Definição',
                    style: AppTypography.label(
                      size: 11,
                      weight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry!.definition,
                    style: AppTypography.body(
                      size: 13,
                      height: 1.4,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Concordância · $occurrences ocorrências',
                  style: AppTypography.label(
                    size: 12,
                    weight: FontWeight.w900,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 8),
                ...hits.map((h) {
                  return FutureBuilder(
                    future: BibleService.instance.books(),
                    builder: (context, snap) {
                      final books = snap.data;
                      final name = (books != null &&
                              h.bookIndex >= 0 &&
                              h.bookIndex < books.length)
                          ? books[h.bookIndex].name
                          : 'Livro ${h.bookIndex + 1}';
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '$name ${h.chapter}:${h.verse}',
                          style: AppTypography.title(
                            color: Colors.white,
                            weight: FontWeight.w700,
                            size: 13,
                          ),
                        ),
                        subtitle: Text(
                          h.gloss.isNotEmpty ? h.gloss : h.surface,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            color: Colors.white.withValues(alpha: 0.45),
                            size: 12,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        onTap: () => onOpenHit(h),
                      );
                    },
                  );
                }),
              ],
            ),
    );
  }

  Widget _kv(String k, String v) {
    if (v.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$k · ',
              style: AppTypography.title(
                size: 12,
                weight: FontWeight.w800,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            TextSpan(
              text: v,
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
