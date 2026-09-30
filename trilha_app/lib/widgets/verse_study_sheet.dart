import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_language.dart';
import '../l10n/l10n_global.dart';

import '../services/bible_service.dart';
import '../services/bible_study_service.dart';
import '../theme/app_theme.dart';
import '../utils/answer_phrase.dart';
import '../utils/appearance.dart';
import '../utils/morphology.dart';
import '../utils/strong_id.dart';
import '../utils/strong_text.dart';
import '../utils/study_gloss.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

Future<void> showVerseStudySheet(
  BuildContext context, {
  required int bookIndex,
  required String bookName,
  required int chapter,
  required int verse,
  required String text,
  void Function(int bookIndex, int chapter, int verse)? onOpenRef,
}) {
  return showAppSheet<void>(
    context,
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
      : context.l10n.bibleBookFallback(bookIndex + 1);
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

  await showAppDialog<void>(
    context,
    builder: (ctx) {
      final a = Appearance.of(ctx);
      return AppDialog(
        title: refLabel,
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.5,
          ),
          child: SingleChildScrollView(
            child: verses.isEmpty
                ? Text(
                    ctx.l10n.verseStudyVerseUnavailable,
                    style: AppTypography.body(
                      color: a.textSecondary,
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
                              color: AppColors.accent.withValues(alpha: 0.8),
                            ),
                          ),
                        Text(
                          verses[i],
                          style: AppTypography.verse(
                            size: 20,
                            height: 1.45,
                            weight: FontWeight.w600,
                            color: a.text,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        BibleService.translationName,
                        style: AppTypography.body(size: 11, color: a.textFaint),
                      ),
                    ],
                  ),
          ),
        ),
        actions: [
          TextCta(label: ctx.l10n.commonClose, onTap: () => Navigator.pop(ctx)),
          CopperCta(
            label: ctx.l10n.verseStudyGoToText,
            onTap: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              onGoToText?.call(bookIndex, chapter, verse);
            },
            trailing: null,
            dense: true,
          ),
        ],
      );
    },
  );
}

class _StudyPayload {
  final VerseStudy study;
  final List<BibleBook> books;

  const _StudyPayload({required this.study, required this.books});
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
  late Future<_StudyPayload> _future;
  StudyToken? _selected;
  StrongStudy? _strong;
  bool _loadingStrong = false;
  int _tab = 0;
  int? _filterBook;
  List<ConcordanceHit> _filterHits = const [];
  bool _copied = false;
  final _tokenKeys = <int, GlobalKey>{};

  String get _ref => '${widget.bookName} ${widget.chapter}:${widget.verse}';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_StudyPayload> _load() async {
    final study = await BibleStudyService.instance.studyVerse(
      widget.bookIndex,
      widget.chapter,
      widget.verse,
    );
    final books = await BibleService.instance.books();
    final preferred = _firstContentToken(study.tokens);
    if (preferred != null) {
      _selected = preferred;
      _loadingStrong = true;
      unawaited(_fillStrong(preferred));
    }
    return _StudyPayload(study: study, books: books);
  }

  StudyToken? _firstContentToken(List<StudyToken> tokens) {
    final links = _verseLinks(tokens);
    if (links.isNotEmpty) {
      final pos = links.first.tokenPos;
      for (final t in tokens) {
        if (t.pos == pos) return t;
      }
    }
    final loc = L10n.current;
    final skip = {
      loc.morphPrep,
      loc.morphArticle,
      loc.morphConjunction,
      loc.morphConjConsecutive,
      loc.morphObjectMarker,
      loc.morphAdverb,
      loc.morphParticle,
      loc.morphRelativeParticle,
      loc.morphNegativeParticle,
      loc.morphDemonstrativeArticle,
      loc.morphInterjection,
    };
    for (final t in tokens) {
      if (t.strong.isEmpty || isPunctuationStrong(t.strong)) continue;
      if (isExtendedStrong(t.strong)) continue;
      final chips = morphologyChips(t.morph.isNotEmpty ? t.morph : null);
      if (chips.isEmpty || !skip.contains(chips.first)) return t;
    }
    return tokens.isEmpty ? null : tokens.first;
  }

  Future<void> _selectToken(StudyToken token) async {
    if (_selected?.pos == token.pos && !_loadingStrong) return;
    ActHaptics.tap();
    setState(() {
      _selected = token;
      _loadingStrong = true;
      _strong = null;
      _filterBook = null;
      _filterHits = const [];
      _copied = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tokenCtx = _tokenKeys[token.pos]?.currentContext;
      if (tokenCtx != null) {
        Scrollable.ensureVisible(
          tokenCtx,
          alignment: 0.45,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      }
    });
    await _fillStrong(token);
  }

  Future<void> _fillStrong(StudyToken token) async {
    final study = await BibleStudyService.instance.studyStrong(
      token.strong,
      bookIndex: widget.bookIndex,
      chapter: widget.chapter,
      verse: widget.verse,
    );
    if (!mounted || _selected?.pos != token.pos) return;
    setState(() {
      _strong = study;
      _loadingStrong = false;
    });
  }

  Future<void> _filterConcordBook(int bookIndex) async {
    ActHaptics.tap();
    if (bookIndex == widget.bookIndex) {
      setState(() {
        _filterBook = bookIndex;
        _filterHits = _strong?.nearby ?? const [];
      });
      return;
    }
    setState(() => _filterBook = bookIndex);
    final token = _selected;
    if (token == null) return;
    final hits = await BibleStudyService.instance.concordanceInBook(
      token.strong,
      bookIndex,
      limit: 40,
    );
    if (!mounted || _selected?.pos != token.pos) return;
    setState(() => _filterHits = hits);
  }

  void _openRef(int bookIndex, int chapter, int verse, {int? verseEnd}) {
    showVersePreviewDialog(
      context,
      bookIndex: bookIndex,
      chapter: chapter,
      verse: verse,
      verseEnd: verseEnd,
      onGoToText: widget.onOpenRef,
    );
  }

  Future<void> _copyStrong(String id) async {
    await Clipboard.setData(ClipboardData(text: id));
    ActHaptics.light();
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => _copied = false);
  }

  Future<void> _shareStrong(StudyToken token, StrongEntry? entry) async {
    final view = _viewFor(token, entry);
    final lemma = (entry?.lemma.isNotEmpty == true)
        ? entry!.lemma
        : token.surface;
    final translit = (entry?.translit.isNotEmpty == true)
        ? entry!.translit
        : token.translit;
    final gloss = view.gloss.isNotEmpty ? view.gloss : token.gloss;
    final body = [
      lemma,
      if (translit.isNotEmpty) translit,
      '${token.strong}${gloss.isNotEmpty ? ' · $gloss' : ''}',
      '',
      context.l10n.bibleShareVia(_ref),
    ].join('\n');
    await SharePlus.instance.share(
      ShareParams(text: body, subject: '${token.strong} — $_ref'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    // Mesma altura total de antes: alça, margens e área segura do painel
    // saem da conta do conteúdo.
    final height = MediaQuery.sizeOf(context).height * 0.92 - bottom - 40;
    final a = Appearance.of(context);

    return AppSheetPanel(
      padding: const EdgeInsets.only(top: AppSpace.sm),
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 6, 4),
              child: Row(
                children: [
                  Expanded(
                    child: AppSheetHeader(
                      eyebrow: context.l10n.verseStudyEyebrow,
                      eyebrowColor: AppColors.accent,
                      title: _ref,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CinematicIcon(
                      glyph: CinematicGlyph.close,
                      size: 22,
                      accent: a.textSecondary,
                      framed: false,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<_StudyPayload>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const _StudyLoading();
                  }
                  if (snap.hasError) {
                    final err = snap.error.toString();
                    final needsRestart = err.contains('MissingPluginException');
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          needsRestart
                              ? context.l10n.verseStudyNeedsRestart
                              : context.l10n.verseStudyLoadFailed,
                          textAlign: TextAlign.center,
                          style: AppTypography.body(
                            color: a.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  }
                  final payload = snap.data!;
                  final study = payload.study;
                  final books = payload.books;
                  if (study.tokens.isEmpty && study.crossRefs.isEmpty) {
                    return Center(
                      child: Text(
                        context.l10n.verseStudyNoData,
                        style: AppTypography.body(color: a.textFaint),
                      ),
                    );
                  }

                  final links = _verseLinks(study.tokens);
                  final verseWordByPos = <int, String>{
                    for (final l in links)
                      l.tokenPos: widget.text.substring(l.start, l.end),
                  };
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
                        child: _VerseQuote(
                          text: widget.text,
                          links: links,
                          selectedPos: _selected?.pos,
                          accent: _langAccent(),
                          onSelectPos: (pos) {
                            for (final t in study.tokens) {
                              if (t.pos == pos) {
                                _selectToken(t);
                                break;
                              }
                            }
                          },
                        ),
                      ),
                      if (study.tokens.isNotEmpty)
                        _WordRibbon(
                          tokens: study.tokens,
                          verseText: widget.text,
                          verseWordByPos: verseWordByPos,
                          selectedPos: _selected?.pos,
                          tokenKeys: _tokenKeys,
                          onSelect: _selectToken,
                        ),
                      if (_selected != null)
                        _StudyTabs(
                          index: _tab,
                          accent: _langAccent(),
                          xrefCount: study.crossRefs.length,
                          occ: _strong?.occurrences,
                          onChanged: (i) => setState(() => _tab = i),
                        ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_selected != null)
                                _tabBody(
                                  study,
                                  books,
                                  verseWord: verseWordByPos[_selected!.pos],
                                )
                              else if (study.tokens.isNotEmpty)
                                const _EmptyStudyHint(),
                              if (_selected == null &&
                                  study.crossRefs.isNotEmpty) ...[
                                const SizedBox(height: 18),
                                _SectionEyebrow(
                                  context.l10n.verseStudyCrossRefs,
                                  count: study.crossRefs.length,
                                ),
                                const SizedBox(height: 10),
                                ..._crossRefTiles(study.crossRefs, books),
                              ],
                              const SizedBox(height: 18),
                              Text(
                                BibleStudyService.attribution,
                                style: AppTypography.body(
                                  size: 11,
                                  height: 1.4,
                                  color: a.textFaint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _langAccent() {
    final t = _selected;
    if (t == null) return AppColors.accent;
    return _isHebrew(t, _strong?.entry) ? AppColors.accent : AppColors.cedar;
  }

  TokenStudyView _viewFor(StudyToken token, StrongEntry? entry) {
    return buildTokenStudyView(
      strong: token.strong,
      morph: token.morph,
      tokenGloss: token.gloss,
      entryGloss: entry?.gloss ?? '',
      definition: entry?.definition ?? '',
      verseText: widget.text,
      hebrew: _isHebrew(token, entry),
    );
  }

  List<VerseWordLink> _verseLinks(List<StudyToken> tokens) {
    return linkVerseToTokens(widget.text, [
      for (final t in tokens)
        if (!isPunctuationStrong(t.strong))
          TokenNeedle(t.pos, _viewFor(t, null).needles),
    ]);
  }

  Widget _tabBody(
    VerseStudy study,
    List<BibleBook> books, {
    String? verseWord,
  }) {
    final token = _selected!;
    final entry = _strong?.entry;
    final loading = _loadingStrong;
    final accent = _langAccent();
    switch (_tab) {
      case 1:
        return _ConcordancePane(
          token: token,
          study: _strong,
          view: _viewFor(token, entry),
          loading: loading,
          books: books,
          currentBook: widget.bookIndex,
          currentChapter: widget.chapter,
          currentVerse: widget.verse,
          currentRef: _ref,
          filterBook: _filterBook,
          filterHits: _filterHits,
          accent: accent,
          onFilterBook: _filterConcordBook,
          onClearFilter: () => setState(() {
            _filterBook = null;
            _filterHits = const [];
          }),
          onOpenHit: (h) => _openRef(h.bookIndex, h.chapter, h.verse),
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionEyebrow(
              context.l10n.verseStudyCrossRefs,
              count: study.crossRefs.length,
            ),
            const SizedBox(height: 10),
            if (study.crossRefs.isEmpty)
              Text(
                context.l10n.verseStudyNoCrossRefs,
                style: AppTypography.body(
                  size: 13,
                  color: Appearance.of(context).textFaint,
                ),
              )
            else
              ..._crossRefTiles(study.crossRefs, books),
          ],
        );
      default:
        return _WordPane(
          token: token,
          entry: entry,
          loading: loading,
          study: _strong,
          view: _viewFor(token, entry),
          verseWord: verseWord,
          books: books,
          copied: _copied,
          accent: accent,
          onCopy: () => _copyStrong(token.strong),
          onShare: () => _shareStrong(token, entry),
          onOpenHit: (h) => _openRef(h.bookIndex, h.chapter, h.verse),
        );
    }
  }

  List<Widget> _crossRefTiles(List<CrossRef> refs, List<BibleBook> books) {
    final maxVotes = refs.fold<int>(0, (m, r) => r.votes > m ? r.votes : m);
    return [
      for (final r in refs)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _CrossRefTile(
            label: _cite(books, r.bookIndex, r.chapter, r.verse, r.verseEnd),
            snippet: _verseSnippet(books, r.bookIndex, r.chapter, r.verse),
            strength: maxVotes <= 0 ? 0 : r.votes / maxVotes,
            onTap: () =>
                _openRef(r.bookIndex, r.chapter, r.verse, verseEnd: r.verseEnd),
          ),
        ),
    ];
  }
}

class _StudyLoading extends StatelessWidget {
  const _StudyLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppSpinner(),
          const SizedBox(height: 14),
          Text(
            context.l10n.verseStudyLoading,
            style: AppTypography.body(
              size: 13,
              color: Appearance.of(context).textFaint,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerseQuote extends StatefulWidget {
  final String text;
  final List<VerseWordLink> links;
  final int? selectedPos;
  final Color accent;
  final ValueChanged<int> onSelectPos;

  const _VerseQuote({
    required this.text,
    required this.links,
    required this.selectedPos,
    required this.accent,
    required this.onSelectPos,
  });

  @override
  State<_VerseQuote> createState() => _VerseQuoteState();
}

class _VerseQuoteState extends State<_VerseQuote> {
  final _taps = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final r in _taps) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final base = AppTypography.verse(
      size: 20,
      height: 1.42,
      weight: FontWeight.w600,
      color: a.text,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3,
          height: 48,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: widget.accent,
            borderRadius: BorderRadius.circular(AppRadii.hair),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            _spans(base),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  TextSpan _spans(TextStyle base) {
    final a = Appearance.of(context);
    for (final r in _taps) {
      r.dispose();
    }
    _taps.clear();
    if (widget.links.isEmpty) {
      return TextSpan(text: widget.text, style: base);
    }
    final children = <InlineSpan>[];
    var cursor = 0;
    for (final link in widget.links) {
      if (link.start > cursor) {
        children.add(
          TextSpan(
            text: widget.text.substring(cursor, link.start),
            style: base,
          ),
        );
      }
      final on = link.tokenPos == widget.selectedPos;
      final tap = TapGestureRecognizer()
        ..onTap = () => widget.onSelectPos(link.tokenPos);
      _taps.add(tap);
      children.add(
        TextSpan(
          text: widget.text.substring(link.start, link.end),
          recognizer: tap,
          style: base.copyWith(
            color: on ? widget.accent : a.text,
            fontWeight: on ? FontWeight.w800 : FontWeight.w600,
            backgroundColor: on
                ? widget.accent.withValues(alpha: 0.22)
                : Colors.transparent,
            decoration: on ? TextDecoration.underline : TextDecoration.none,
            decorationColor: widget.accent.withValues(alpha: 0.85),
            decorationThickness: 1.6,
          ),
        ),
      );
      cursor = link.end;
    }
    if (cursor < widget.text.length) {
      children.add(TextSpan(text: widget.text.substring(cursor), style: base));
    }
    return TextSpan(children: children);
  }
}

class _WordRibbon extends StatelessWidget {
  final List<StudyToken> tokens;
  final String verseText;
  final Map<int, String> verseWordByPos;
  final int? selectedPos;
  final Map<int, GlobalKey> tokenKeys;
  final void Function(StudyToken token) onSelect;

  const _WordRibbon({
    required this.tokens,
    required this.verseText,
    required this.verseWordByPos,
    required this.selectedPos,
    required this.tokenKeys,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final visible = [
      for (final t in tokens)
        if (!isPunctuationStrong(t.strong)) t,
    ];
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
        itemCount: visible.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, i) {
          final t = visible[i];
          final view = buildTokenStudyView(
            strong: t.strong,
            morph: t.morph,
            tokenGloss: t.gloss,
            verseText: verseText,
            hebrew: t.strong.toUpperCase().startsWith('H'),
          );
          final verseWord = verseWordByPos[t.pos];
          return KeyedSubtree(
            key: tokenKeys.putIfAbsent(t.pos, GlobalKey.new),
            child: _TokenChip(
              token: t,
              gloss: verseWord ?? view.gloss,
              inVerse: verseWord != null,
              selected: selectedPos == t.pos,
              dimmed: selectedPos != null && selectedPos != t.pos,
              onTap: () => onSelect(t),
            ),
          );
        },
      ),
    );
  }
}

class _StudyTabs extends StatelessWidget {
  final int index;
  final Color accent;
  final int xrefCount;
  final int? occ;
  final ValueChanged<int> onChanged;

  const _StudyTabs({
    required this.index,
    required this.accent,
    required this.xrefCount,
    required this.occ,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: a.cardFillSoft,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: a.cardBorder),
        ),
        child: Row(
          children: [
            _seg(a, context.l10n.verseStudyTabWord, 0),
            _seg(
              a,
              occ != null && occ! > 0
                  ? context.l10n.verseStudyTabUsesCount(occ!)
                  : context.l10n.verseStudyTabUses,
              1,
            ),
            _seg(
              a,
              xrefCount > 0
                  ? context.l10n.verseStudyTabLinksCount(xrefCount)
                  : context.l10n.verseStudyTabLinks,
              2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _seg(AppearanceStyle a, String label, int i) {
    final on = index == i;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(i),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: on ? accent.withValues(alpha: 0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(
                size: 11,
                letterSpacing: 0.4,
                color: on ? accent : a.textFaint,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TokenChip extends StatelessWidget {
  final StudyToken token;
  final String gloss;
  final bool inVerse;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  const _TokenChip({
    required this.token,
    required this.gloss,
    required this.inVerse,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hebrew = token.strong.toUpperCase().startsWith('H');
    final accent = hebrew ? AppColors.accent : AppColors.cedar;
    final label = gloss.isEmpty ? token.strong : gloss;
    final a = Appearance.of(context);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: dimmed ? 0.42 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 76),
            child: Ink(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              decoration: BoxDecoration(
                color: selected
                    ? accent.withValues(alpha: 0.16)
                    : Colors.white.withValues(alpha: inVerse ? 0.05 : 0.03),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: selected
                      ? accent.withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: inVerse ? 0.1 : 0.06),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    token.surface,
                    textDirection: hebrew
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: AppTypography.original(
                      hebrew: hebrew,
                      size: hebrew ? 22 : 18,
                      weight: FontWeight.w600,
                      color: a.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(
                      size: 10,
                      letterSpacing: 0.3,
                      color: selected
                          ? accent
                          : (inVerse ? a.textFaint : a.textMuted(0.38)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyStudyHint extends StatelessWidget {
  const _EmptyStudyHint();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return InsetPanel(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
      child: Column(
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.scroll,
            size: 36,
            accent: AppColors.accent,
            framed: false,
            glowing: false,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.verseStudyEmptyTitle,
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 16, color: a.text),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.verseStudyEmptyBody,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              height: 1.4,
              color: a.textFaint,
            ),
          ),
        ],
      ),
    );
  }
}

class _WordPane extends StatelessWidget {
  final StudyToken token;
  final StrongEntry? entry;
  final bool loading;
  final StrongStudy? study;
  final TokenStudyView view;
  final String? verseWord;
  final List<BibleBook> books;
  final bool copied;
  final Color accent;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final void Function(ConcordanceHit hit) onOpenHit;

  const _WordPane({
    required this.token,
    required this.entry,
    required this.loading,
    required this.study,
    required this.view,
    required this.verseWord,
    required this.books,
    required this.copied,
    required this.accent,
    required this.onCopy,
    required this.onShare,
    required this.onOpenHit,
  });

  @override
  Widget build(BuildContext context) {
    final hebrew = _isHebrew(token, entry);
    final lemma = (entry?.lemma.isNotEmpty == true)
        ? entry!.lemma
        : token.surface;
    final translit = view.isAffix
        ? token.translit
        : ((entry?.translit.isNotEmpty == true)
              ? entry!.translit
              : token.translit);
    final gloss = verseWord ?? view.gloss;
    final chips = morphologyChips(token.morph.isNotEmpty ? token.morph : null);
    final headline = view.isAffix ? token.surface : lemma;
    final sameForm = _normScript(lemma) == _normScript(token.surface);
    final senses = rankDefinitionSenses(
      definitionSenses(entry?.definition ?? ''),
      view.needles,
    );
    final occ = study?.occurrences ?? 0;
    final strongLabel = copied
        ? context.l10n.verseStudyCopied
        : [
            token.strong,
            if (view.extended) 'STEP',
            if (!view.isAffix && occ > 0) '$occ×',
          ].join(' · ');
    final phrase = morphologyPhrase(
      token.morph.isNotEmpty ? token.morph : null,
      gloss: gloss,
    );
    final inVerse = verseWord != null && verseWord!.isNotEmpty;
    final a = Appearance.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SoftBadge(
              text: view.kindLabel,
              accent: accent,
              textColor: accent,
              bordered: false,
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: a.insetFill,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(color: a.insetBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      strongLabel,
                      style: AppTypography.label(
                        size: 11,
                        letterSpacing: 0.4,
                        color: copied ? accent : a.text,
                      ),
                    ),
                    const SizedBox(width: 4),
                    CinematicIcon(
                      glyph: copied
                          ? CinematicGlyph.check
                          : CinematicGlyph.copy,
                      size: 12,
                      accent: a.textFaint,
                      framed: false,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onShare,
              tooltip: context.l10n.commonShare,
              icon: CinematicIcon(
                glyph: CinematicGlyph.share,
                size: 18,
                accent: a.textFaint,
                framed: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (inVerse) ...[
          Center(
            child: SectionLabel(
              context.l10n.verseStudyInThisVerse,
              color: accent.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            verseWord!,
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 20,
              weight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 10),
        ] else if (gloss.isNotEmpty) ...[
          Text(
            gloss,
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 20,
              weight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.verseStudyNotLiteral,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 12,
              height: 1.35,
              color: a.textFaint,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          headline,
          textAlign: TextAlign.center,
          textDirection: hebrew ? TextDirection.rtl : TextDirection.ltr,
          style: AppTypography.original(
            hebrew: hebrew,
            size: hebrew ? 30 : 28,
            weight: FontWeight.w700,
            height: 1.2,
            color: a.text,
          ),
        ),
        if (translit.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            translit,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              color: a.textFaint,
            ).copyWith(fontStyle: FontStyle.italic),
          ),
        ],
        if (inVerse &&
            view.gloss.isNotEmpty &&
            foldKey(view.gloss) != foldKey(verseWord!)) ...[
          const SizedBox(height: 6),
          Text(
            view.gloss,
            textAlign: TextAlign.center,
            style: AppTypography.body(size: 13, color: a.textFaint),
          ),
        ],
        if (phrase.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            phrase,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              height: 1.35,
              color: a.textSecondary,
            ),
          ),
        ],
        if (view.grammarNote != null) ...[
          const SizedBox(height: 10),
          Text(
            view.grammarNote!,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 12,
              height: 1.35,
              color: a.textFaint,
            ),
          ),
        ],
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              for (final c in chips) _MorphChip(label: c, accent: accent),
            ],
          ),
        ],
        if (!sameForm && entry != null && !view.isAffix) ...[
          const SizedBox(height: 14),
          _FormVsLemma(
            hebrew: hebrew,
            accent: accent,
            form: token.surface,
            formTranslit: token.translit,
            lemma: entry!.lemma,
            lemmaTranslit: entry!.translit,
          ),
        ],
        if (loading) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.hair),
            child: LinearProgressIndicator(
              minHeight: 2,
              color: accent,
              backgroundColor: accent.withValues(alpha: 0.15),
            ),
          ),
        ] else ...[
          if (senses.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionEyebrow(context.l10n.verseStudyDefinition),
            const SizedBox(height: 8),
            for (var i = 0; i < senses.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (senses.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 3, right: 8),
                      child: Text(
                        '${i + 1}',
                        style: AppTypography.label(
                          size: 11,
                          color: i == 0 ? accent : a.textFaint,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      senses[i],
                      style: AppTypography.verse(
                        size: 16,
                        height: 1.45,
                        weight: FontWeight.w500,
                        color: i == 0 ? a.text : a.textFaint,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
          if (study?.first != null && study?.last != null) ...[
            const SizedBox(height: 16),
            if (view.isAffix && study!.occurrences > 200)
              Text(
                context.l10n.verseStudyParticleNote(study!.occurrences),
                style: AppTypography.body(
                  size: 12,
                  height: 1.35,
                  color: a.textFaint,
                ),
              )
            else
              _SpanLine(
                first: study!.first!,
                last: study!.last!,
                books: books,
                accent: accent,
                occurrences: study!.occurrences,
                onOpenHit: onOpenHit,
              ),
          ],
        ],
      ],
    );
  }
}

class _SpanLine extends StatelessWidget {
  final ConcordanceHit first;
  final ConcordanceHit last;
  final List<BibleBook> books;
  final Color accent;
  final int occurrences;
  final void Function(ConcordanceHit hit) onOpenHit;

  const _SpanLine({
    required this.first,
    required this.last,
    required this.books,
    required this.accent,
    required this.occurrences,
    required this.onOpenHit,
  });

  @override
  Widget build(BuildContext context) {
    final a = _cite(books, first.bookIndex, first.chapter, first.verse, null);
    final b = _cite(books, last.bookIndex, last.chapter, last.verse, null);
    final same = a == b;
    final look = Appearance.of(context);
    return InsetPanel(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            occurrences <= 1
                ? context.l10n.verseStudyOnlyHere
                : context.l10n.verseStudySpan(occurrences, a, b),
            style: AppTypography.body(size: 12, color: look.textFaint),
          ),
          if (!same) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _miniRef(
                  look,
                  context.l10n.verseStudyFirst,
                  a,
                  () => onOpenHit(first),
                  accent,
                ),
                const SizedBox(width: 8),
                _miniRef(
                  look,
                  context.l10n.verseStudyLast,
                  b,
                  () => onOpenHit(last),
                  accent,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniRef(
    AppearanceStyle look,
    String label,
    String cite,
    VoidCallback onTap,
    Color accent,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.xs),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(label, color: accent.withValues(alpha: 0.8)),
              Text(
                cite,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.title(size: 12, color: look.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConcordancePane extends StatelessWidget {
  final StudyToken token;
  final StrongStudy? study;
  final TokenStudyView view;
  final bool loading;
  final List<BibleBook> books;
  final int currentBook;
  final int currentChapter;
  final int currentVerse;
  final String currentRef;
  final int? filterBook;
  final List<ConcordanceHit> filterHits;
  final Color accent;
  final ValueChanged<int> onFilterBook;
  final VoidCallback onClearFilter;
  final void Function(ConcordanceHit hit) onOpenHit;

  const _ConcordancePane({
    required this.token,
    required this.study,
    required this.view,
    required this.loading,
    required this.books,
    required this.currentBook,
    required this.currentChapter,
    required this.currentVerse,
    required this.currentRef,
    required this.filterBook,
    required this.filterHits,
    required this.accent,
    required this.onFilterBook,
    required this.onClearFilter,
    required this.onOpenHit,
  });

  @override
  Widget build(BuildContext context) {
    if (loading && study == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: AppSpinner(color: accent),
      );
    }
    final hebrew = token.strong.toUpperCase().startsWith('H');
    final byBook = study?.byBook ?? const <BookOccurrence>[];
    final nearby = study?.nearby ?? const <ConcordanceHit>[];
    final spread = study?.spread ?? const <ConcordanceHit>[];
    final filtered = filterBook != null;
    final rawHits = filtered
        ? (filterBook == currentBook ? nearby : filterHits)
        : nearby;
    final hits = filtered
        ? rawHits
        : _aroundHits(rawHits, currentChapter, currentVerse, 12);
    final grouped = _groupHits(hits);
    final scriptureHits = spread;
    final a = Appearance.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          filtered
              ? context.l10n.verseStudyOccurrencesIn(
                  _bookName(books, filterBook!),
                )
              : view.isAffix
              ? context.l10n.verseStudyParticleNearby
              : context.l10n.verseStudyInThisBook,
          style: AppTypography.body(size: 13, height: 1.35, color: a.textFaint),
        ),
        if (byBook.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: byBook.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final b = byBook[i];
                final on = filterBook == b.bookIndex;
                return AppSelectChip(
                  label: '${_bookName(books, b.bookIndex)} ${b.count}',
                  selected: on,
                  accent: accent,
                  unselectedColor: a.textSecondary,
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  onTap: () {
                    if (on) {
                      onClearFilter();
                    } else {
                      onFilterBook(b.bookIndex);
                    }
                  },
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (hits.isEmpty)
          Text(
            context.l10n.verseStudyNoOtherHits,
            style: AppTypography.body(size: 13, color: a.textFaint),
          )
        else
          for (final group in grouped) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 4),
              child: SectionLabel(
                _bookName(books, group.$1),
                color: accent.withValues(alpha: 0.85),
              ),
            ),
            for (final h in group.$2)
              _ConcordanceRow(
                citation: '${h.chapter}:${h.verse}',
                snippet: _verseSnippet(books, h.bookIndex, h.chapter, h.verse),
                original: h.surface,
                hebrew: hebrew,
                current:
                    _cite(books, h.bookIndex, h.chapter, h.verse, null) ==
                    currentRef,
                needles: view.needles,
                accent: accent,
                onTap: () => onOpenHit(h),
              ),
          ],
        if (!filtered && scriptureHits.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionEyebrow(context.l10n.verseStudyOtherBooks),
          const SizedBox(height: 8),
          Text(
            context.l10n.verseStudyOtherBooksBody,
            style: AppTypography.body(size: 12, color: a.textFaint),
          ),
          const SizedBox(height: 8),
          for (final h in scriptureHits)
            _ConcordanceRow(
              citation: _cite(books, h.bookIndex, h.chapter, h.verse, null),
              snippet: _verseSnippet(books, h.bookIndex, h.chapter, h.verse),
              original: h.surface,
              hebrew: hebrew,
              current: false,
              needles: view.needles,
              accent: accent,
              onTap: () => onOpenHit(h),
            ),
        ],
      ],
    );
  }
}

class _MorphChip extends StatelessWidget {
  final String label;
  final Color accent;

  const _MorphChip({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return SoftBadge(text: label, accent: accent);
  }
}

class _FormVsLemma extends StatelessWidget {
  final bool hebrew;
  final Color accent;
  final String form;
  final String formTranslit;
  final String lemma;
  final String lemmaTranslit;

  const _FormVsLemma({
    required this.hebrew,
    required this.accent,
    required this.form,
    required this.formTranslit,
    required this.lemma,
    required this.lemmaTranslit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ScriptCell(
            eyebrow: context.l10n.verseStudyThisForm,
            script: form,
            translit: formTranslit,
            hebrew: hebrew,
            accent: accent,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CinematicIcon(
            glyph: CinematicGlyph.forward,
            size: 16,
            accent: accent.withValues(alpha: 0.7),
            framed: false,
          ),
        ),
        Expanded(
          child: _ScriptCell(
            eyebrow: context.l10n.verseStudyLemma,
            script: lemma,
            translit: lemmaTranslit,
            hebrew: hebrew,
            accent: accent,
          ),
        ),
      ],
    );
  }
}

class _ScriptCell extends StatelessWidget {
  final String eyebrow;
  final String script;
  final String translit;
  final bool hebrew;
  final Color accent;

  const _ScriptCell({
    required this.eyebrow,
    required this.script,
    required this.translit,
    required this.hebrew,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return InsetPanel(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        children: [
          SectionLabel(eyebrow, color: accent.withValues(alpha: 0.8)),
          const SizedBox(height: 4),
          Text(
            script,
            textAlign: TextAlign.center,
            textDirection: hebrew ? TextDirection.rtl : TextDirection.ltr,
            style: AppTypography.original(
              hebrew: hebrew,
              size: hebrew ? 20 : 18,
              color: a.text,
            ),
          ),
          if (translit.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              translit,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(size: 11, color: a.textFaint),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConcordanceRow extends StatelessWidget {
  final String citation;
  final String? snippet;
  final String original;
  final bool hebrew;
  final bool current;
  final List<String> needles;
  final Color accent;
  final VoidCallback onTap;

  const _ConcordanceRow({
    required this.citation,
    required this.snippet,
    required this.original,
    required this.hebrew,
    required this.current,
    required this.needles,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final base = AppTypography.body(
      size: 13,
      height: 1.3,
      color: a.textSecondary,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
            decoration: BoxDecoration(
              color: current ? accent.withValues(alpha: 0.1) : a.insetFill,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(
                color: current ? accent.withValues(alpha: 0.45) : a.insetBorder,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: citation.length > 6 ? 96 : 44,
                  child: Text(
                    citation,
                    style: AppTypography.title(size: 12, color: accent),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (snippet != null && snippet!.isNotEmpty)
                        Text.rich(
                          _snippetSpan(snippet!, needles, base, accent),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (original.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          original,
                          textDirection: hebrew
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          style: AppTypography.original(
                            hebrew: hebrew,
                            size: 13,
                            color: a.textFaint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ListChevron(color: a.textFaint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CrossRefTile extends StatelessWidget {
  final String label;
  final String? snippet;
  final double strength;
  final VoidCallback onTap;

  const _CrossRefTile({
    required this.label,
    required this.snippet,
    required this.strength,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dots = strength >= 0.7 ? 3 : (strength >= 0.35 ? 2 : 1);
    final a = Appearance.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onTap,
        child: InsetPanel(
          padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.title(size: 14, color: a.text),
                    ),
                    if (snippet != null && snippet!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        snippet!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(
                          size: 12,
                          height: 1.3,
                          color: a.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 3; i++)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(right: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < dots ? AppColors.accent : a.textMuted(0.18),
                      ),
                    ),
                ],
              ),
              ListChevron(color: a.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  final String text;
  final int? count;

  const _SectionEyebrow(this.text, {this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SectionLabel(text),
        if (count != null) ...[
          const SizedBox(width: 8),
          CountBadge('$count', filled: false),
        ],
      ],
    );
  }
}

bool _isHebrew(StudyToken token, StrongEntry? entry) {
  if (entry != null) return entry.isHebrew;
  return token.strong.toUpperCase().startsWith('H');
}

String _normScript(String s) => s.replaceAll(RegExp(r'[\u0591-\u05C7\s]'), '');

TextSpan _snippetSpan(
  String text,
  List<String> needles,
  TextStyle base,
  Color accent,
) {
  final ranges = highlightRanges(text, needles);
  if (ranges.isEmpty) return TextSpan(text: text, style: base);
  final children = <InlineSpan>[];
  var cursor = 0;
  for (final r in ranges) {
    if (r.start > cursor) {
      children.add(
        TextSpan(text: text.substring(cursor, r.start), style: base),
      );
    }
    children.add(
      TextSpan(
        text: text.substring(r.start, r.end),
        style: base.copyWith(color: accent, fontWeight: FontWeight.w800),
      ),
    );
    cursor = r.end;
  }
  if (cursor < text.length) {
    children.add(TextSpan(text: text.substring(cursor), style: base));
  }
  return TextSpan(children: children);
}

List<ConcordanceHit> _aroundHits(
  List<ConcordanceHit> hits,
  int chapter,
  int verse,
  int window,
) {
  if (hits.length <= window) return hits;
  var i = hits.indexWhere((h) => h.chapter == chapter && h.verse == verse);
  if (i < 0) {
    i = hits.indexWhere(
      (h) => h.chapter > chapter || (h.chapter == chapter && h.verse >= verse),
    );
  }
  if (i < 0) i = 0;
  final start = (i - window ~/ 3).clamp(0, hits.length - window);
  return hits.sublist(start, start + window);
}

String _bookName(List<BibleBook> books, int index) {
  if (index >= 0 && index < books.length) return books[index].name;
  return L10n.current.bibleBookFallback(index + 1);
}

String _cite(
  List<BibleBook> books,
  int bookIndex,
  int chapter,
  int verse,
  int? verseEnd,
) {
  final name = _bookName(books, bookIndex);
  final end = verseEnd != null && verseEnd != verse ? '–$verseEnd' : '';
  return '$name $chapter:$verse$end';
}

String? _verseSnippet(
  List<BibleBook> books,
  int bookIndex,
  int chapter,
  int verse,
) {
  if (bookIndex < 0 || bookIndex >= books.length) return null;
  final chapters = books[bookIndex].chapters;
  if (chapter < 1 || chapter > chapters.length) return null;
  final list = chapters[chapter - 1];
  if (verse < 1 || verse > list.length) return null;
  return list[verse - 1];
}

List<(int, List<ConcordanceHit>)> _groupHits(List<ConcordanceHit> hits) {
  final map = <int, List<ConcordanceHit>>{};
  final order = <int>[];
  for (final h in hits) {
    final list = map.putIfAbsent(h.bookIndex, () {
      order.add(h.bookIndex);
      return <ConcordanceHit>[];
    });
    list.add(h);
  }
  return [for (final i in order) (i, map[i]!)];
}
