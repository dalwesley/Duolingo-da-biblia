import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_language.dart';
import '../services/bible_service.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/bible_reading_theme.dart';
import '../widgets/act_feel.dart';
import '../widgets/app_sheet.dart';
import '../widgets/bible_passage_picker.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/relic_panel.dart';
import '../widgets/share_verse_sheet.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/verse_study_sheet.dart';

/// Leitor imersivo — tela cheia no papel da leitura, capítulo por deslize,
/// chrome que some ao rolar e áudio versículo a versículo.
class BibleReaderScreen extends StatefulWidget {
  final String reference;

  const BibleReaderScreen({super.key, required this.reference});

  /// Abre o leitor por cima da barra de abas, com entrada suave.
  static Future<void> open(BuildContext context, String reference) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (_, _, _) => BibleReaderScreen(reference: reference),
        transitionsBuilder: (_, anim, _, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  State<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends State<BibleReaderScreen> {
  List<BibleBook>? _books;
  int _bookIndex = 0;
  int _chapter = 1;
  PageController? _pages;
  bool _failed = false;
  String? _loadedTranslationId;
  bool _reloadScheduled = false;

  /// Versículos pedidos pela referência (só no capítulo de origem).
  ({int bookIndex, int chapter, int start, int end})? _highlight;

  /// Chrome (topo/dock) em notifier: esconder ao rolar não reconstrói o
  /// PageView nem os versículos.
  final _chrome = ValueNotifier<bool>(true);
  ProgressService? _progress;
  bool get _chromeVisible => _chrome.value;
  final _scrollProgress = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    _progress?.commitBibleSpot();
    _pages?.dispose();
    _scrollProgress.dispose();
    _chrome.dispose();
    super.dispose();
  }

  BibleBook get _book => _books![_bookIndex];
  String get _chapterKey =>
      ProgressService.bibleChapterKey(_book.abbrev, _chapter);

  Future<void> _resolve() async {
    final id = context.read<ProgressService>().settings.bibleTranslationId;
    await BibleService.instance.setTranslation(id);
    final ref = await BibleService.instance.resolve(widget.reference);
    if (!mounted) return;
    if (ref == null) {
      setState(() => _failed = true);
      return;
    }
    final books = await BibleService.instance.books();
    if (!mounted) return;
    setState(() {
      _books = books;
      _loadedTranslationId = id;
      if (ref.verseStart != null) {
        _highlight = (
          bookIndex: ref.bookIndex,
          chapter: ref.chapter,
          start: ref.verseStart!,
          end: ref.verseEnd ?? ref.verseStart!,
        );
      }
    });
    _goTo(ref.bookIndex, ref.chapter, animate: false);
  }

  Future<void> _reloadKeepingPlace() async {
    final id = context.read<ProgressService>().settings.bibleTranslationId;
    final keepAbbrev = _books == null ? null : _book.abbrev;
    await BibleService.instance.setTranslation(id);
    final books = await BibleService.instance.books();
    if (!mounted) return;
    var bookIndex = _bookIndex;
    if (keepAbbrev != null) {
      final i = books.indexWhere(
        (b) => b.abbrev.toLowerCase() == keepAbbrev.toLowerCase(),
      );
      if (i >= 0) bookIndex = i;
    }
    setState(() {
      _books = books;
      _loadedTranslationId = id;
      _reloadScheduled = false;
    });
    _goTo(bookIndex, _chapter, animate: false, force: true);
  }

  /// Leva o leitor a [bookIndex]:[chapter]. Mesmo livro com [animate] desliza
  /// a página; outro livro troca o PageView inteiro.
  void _goTo(
    int bookIndex,
    int chapter, {
    bool animate = true,
    bool force = false,
  }) {
    final books = _books;
    if (books == null) return;
    final c = chapter.clamp(1, books[bookIndex].chapters.length);
    final sameBook = bookIndex == _bookIndex && _pages != null && !force;
    if (sameBook) {
      final from = _pages!.page?.round() ?? _chapter - 1;
      final near = (from - (c - 1)).abs() == 1;
      if (animate && near && !MediaQuery.disableAnimationsOf(context)) {
        _pages!.animateToPage(
          c - 1,
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
        );
      } else {
        _pages!.jumpToPage(c - 1);
      }
      return;
    }
    final old = _pages;
    setState(() {
      _bookIndex = bookIndex;
      _chapter = c;
      _pages = PageController(initialPage: c - 1);
    });
    _chrome.value = true;
    _scrollProgress.value = 0;
    if (old != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
    _onChapterShown();
  }

  void _onChapterShown() {
    final progress = context.read<ProgressService>();
    _progress = progress;
    unawaited(
      progress.setLastBibleSpot(_book.abbrev, _chapter, notify: false),
    );
    final tts = TtsService.instance;
    if (tts.sequenceKey != null && tts.sequenceKey != _chapterKey) {
      unawaited(tts.stop());
    }
  }

  void _onPageChanged(int page) {
    ActHaptics.tick();
    setState(() => _chapter = page + 1);
    _chrome.value = true;
    _scrollProgress.value = 0;
    _onChapterShown();
  }

  ({int bookIndex, int chapter})? get _next => _nextAfter(_chapter);

  ({int bookIndex, int chapter})? _nextAfter(int chapter) {
    if (chapter < _book.chapters.length) {
      return (bookIndex: _bookIndex, chapter: chapter + 1);
    }
    if (_bookIndex + 1 < _books!.length) {
      return (bookIndex: _bookIndex + 1, chapter: 1);
    }
    return null;
  }

  ({int bookIndex, int chapter})? get _previous {
    if (_chapter > 1) return (bookIndex: _bookIndex, chapter: _chapter - 1);
    if (_bookIndex > 0) {
      final prev = _books![_bookIndex - 1];
      return (bookIndex: _bookIndex - 1, chapter: prev.chapters.length);
    }
    return null;
  }

  void _step(({int bookIndex, int chapter})? target) {
    if (target == null) return;
    ActHaptics.tap();
    _goTo(target.bookIndex, target.chapter);
  }

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final m = n.metrics;
    if (m.maxScrollExtent > 0) {
      _scrollProgress.value = (m.pixels / m.maxScrollExtent).clamp(0.0, 1.0);
    } else {
      _scrollProgress.value = 1;
    }
    if (n is ScrollUpdateNotification && n.dragDetails != null) {
      final dy = n.scrollDelta ?? 0;
      if (dy > 4 && m.pixels > 80 && _chromeVisible) {
        _chrome.value = false;
      } else if (dy < -4 && !_chromeVisible) {
        _chrome.value = true;
      }
    }
    if (m.pixels <= 0 && !_chromeVisible) {
      _chrome.value = true;
    }
    return false;
  }

  Future<void> _openPicker() async {
    final books = _books;
    if (books == null) return;
    ActHaptics.tap();
    final pick = await showBiblePassagePicker(
      context,
      books: books,
      bookIndex: _bookIndex,
      currentChapter: _chapter,
    );
    if (pick == null || !mounted) return;
    _goTo(pick.bookIndex, pick.chapter, animate: pick.bookIndex == _bookIndex);
  }

  void _toggleListen(List<String> verses) {
    final tts = TtsService.instance;
    if (tts.sequenceKey == _chapterKey || tts.isSpeaking) {
      unawaited(tts.stop());
      return;
    }
    ActHaptics.light();
    _chrome.value = true;
    unawaited(tts.speakSequence(verses, key: _chapterKey));
  }

  void _listenFrom(int verse) {
    final verses = _book.chapters[_chapter - 1];
    unawaited(
      TtsService.instance.speakSequence(
        verses,
        key: _chapterKey,
        start: verse - 1,
      ),
    );
  }

  Future<void> _completeChapter() async {
    final progress = context.read<ProgressService>();
    final book = _book;
    final chapter = _chapter;
    ActHaptics.success();
    await progress.recordBibleReading(book.abbrev, chapter);
    if (!mounted) return;
    final next = _next;
    showAppToastFor(
      context,
      message: context.l10n.bibleReaderChapterReadToast(book.name, chapter),
      glyph: CinematicGlyph.book,
    );
    if (next != null) {
      await Future<void>.delayed(const Duration(milliseconds: 420));
      if (mounted && _chapter == chapter) _goTo(next.bookIndex, next.chapter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationId = context.select(
      (ProgressService p) => p.settings.bibleTranslationId,
    );
    if (_loadedTranslationId != null &&
        _loadedTranslationId != translationId &&
        !_reloadScheduled) {
      _reloadScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reloadKeepingPlace();
      });
    }
    final mode = context.select(
      (ProgressService p) => p.settings.appearanceMode,
    );
    final night = context.select(
      (ProgressService p) => p.settings.bibleReadingNight,
    );
    final sepia = context.select((ProgressService p) => p.bibleSepia);
    final appearance = AppearanceStyle.resolve(mode);
    final reading = BibleReadingStyle.resolve(
      appearance,
      readingNight: night,
      sepia: sepia,
    );
    final motion = MediaQuery.disableAnimationsOf(context);
    final chromeDuration = motion
        ? Duration.zero
        : const Duration(milliseconds: 240);

    Widget body;
    if (_failed) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.bibleReaderOpenFailed(widget.reference),
                textAlign: TextAlign.center,
                style: AppTypography.body(color: reading.inkMuted),
              ),
              const SizedBox(height: AppSpace.lg),
              TextCta(
                label: context.l10n.commonClose,
                color: reading.ink,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
    } else if (_books == null || _pages == null) {
      body = AppSpinner(color: reading.verseNumber);
    } else {
      final book = _book;
      final verses = book.chapters[_chapter - 1];
      body = Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: PageView.builder(
              key: ValueKey('${book.abbrev}-$_loadedTranslationId'),
              controller: _pages,
              itemCount: book.chapters.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, i) {
                final chapter = i + 1;
                final hl = _highlight;
                final showHl =
                    hl != null &&
                    hl.bookIndex == _bookIndex &&
                    hl.chapter == chapter;
                return _ChapterPage(
                  key: ValueKey('${book.abbrev}:$chapter'),
                  books: _books!,
                  bookIndex: _bookIndex,
                  chapter: chapter,
                  reading: reading,
                  highlightStart: showHl ? hl.start : null,
                  highlightEnd: showHl ? hl.end : null,
                  next: _nextAfter(chapter),
                  onComplete: _completeChapter,
                  onNext: () => _step(_nextAfter(chapter)),
                  onListenFrom: _listenFrom,
                  onOpenRef: (bi, c, v) {
                    setState(() {
                      _highlight = (
                        bookIndex: bi,
                        chapter: c,
                        start: v,
                        end: v,
                      );
                    });
                    _goTo(bi, c, animate: bi == _bookIndex);
                  },
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _chrome,
              builder: (context, visible, child) => AnimatedSlide(
                offset: visible ? Offset.zero : const Offset(0, -1.1),
                duration: chromeDuration,
                curve: Curves.easeOutCubic,
                child: child,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpace.screen,
                  MediaQuery.paddingOf(context).top + AppSpace.sm,
                  AppSpace.screen,
                  0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TopBar(
                      inline: true,
                      immersive: true,
                      title: book.name,
                      subtitle: context.l10n.bibleReaderSubtitle(
                        _chapter,
                        BibleService.byId(translationId).shortName,
                      ),
                      onBack: () => Navigator.of(context).pop(),
                      showLeading: false,
                      chromeAccent: reading.ink,
                      surface: TopBarSurface(
                        fill: reading.chrome,
                        border: reading.chromeBorder,
                        ink: reading.ink,
                        inkMuted: reading.inkMuted,
                      ),
                      onTitleTap: _openPicker,
                      trailing: Semantics(
                        button: true,
                        label: context.l10n.bibleReaderSettings,
                        child: GestureDetector(
                          onTap: () => _showReadingSettings(context),
                          behavior: HitTestBehavior.opaque,
                          child: CinematicIcon(
                            glyph: CinematicGlyph.tune,
                            size: 36,
                            accent: reading.ink,
                            glowing: false,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    ValueListenableBuilder<double>(
                      valueListenable: _scrollProgress,
                      builder: (context, t, _) => AppProgressBar(
                        value: t,
                        height: 6,
                        color: reading.inkMuted,
                        trackColor: reading.chromeBorder,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _chrome,
              builder: (context, visible, child) => AnimatedSlide(
                offset: visible ? Offset.zero : const Offset(0, 1.4),
                duration: chromeDuration,
                curve: Curves.easeOutCubic,
                child: child,
              ),
              child: _ReaderDock(
                reading: reading,
                chapterKey: _chapterKey,
                onPrevious: _previous == null ? null : () => _step(_previous),
                onNext: _next == null ? null : () => _step(_next),
                onListen: () => _toggleListen(verses),
              ),
            ),
          ),
        ],
      );
    }

    return Appearance(
      mode: mode,
      style: appearance,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: reading.isDay
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        child: AnimatedContainer(
          duration: motion ? Duration.zero : const Duration(milliseconds: 320),
          color: reading.page,
          child: Scaffold(backgroundColor: Colors.transparent, body: body),
        ),
      ),
    );
  }
}

/// Um capítulo — título grande, versículos com número em linha, fim com
/// "concluir" e o próximo capítulo em vista.
class _ChapterPage extends StatefulWidget {
  final List<BibleBook> books;
  final int bookIndex;
  final int chapter;
  final BibleReadingStyle reading;
  final int? highlightStart;
  final int? highlightEnd;
  final ({int bookIndex, int chapter})? next;
  final Future<void> Function() onComplete;
  final VoidCallback onNext;
  final ValueChanged<int> onListenFrom;
  final void Function(int bookIndex, int chapter, int verse) onOpenRef;

  const _ChapterPage({
    super.key,
    required this.books,
    required this.bookIndex,
    required this.chapter,
    required this.reading,
    required this.highlightStart,
    required this.highlightEnd,
    required this.next,
    required this.onComplete,
    required this.onNext,
    required this.onListenFrom,
    required this.onOpenRef,
  });

  @override
  State<_ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<_ChapterPage> {
  late List<GlobalKey> _verseKeys;
  int? _selected;
  int? _speaking;
  bool _jumpedToHighlight = false;

  BibleBook get _book => widget.books[widget.bookIndex];
  List<String> get _verses => _book.chapters[widget.chapter - 1];
  String get _key =>
      ProgressService.bibleChapterKey(_book.abbrev, widget.chapter);

  @override
  void initState() {
    super.initState();
    _verseKeys = List.generate(_verses.length, (_) => GlobalKey());
    TtsService.instance.addListener(_onTts);
    _scheduleHighlightJump();
  }

  @override
  void didUpdateWidget(covariant _ChapterPage old) {
    super.didUpdateWidget(old);
    if (_verseKeys.length != _verses.length) {
      _verseKeys = List.generate(_verses.length, (_) => GlobalKey());
    }
    if (old.highlightStart != widget.highlightStart) {
      _jumpedToHighlight = false;
      _scheduleHighlightJump();
    }
  }

  @override
  void dispose() {
    TtsService.instance.removeListener(_onTts);
    super.dispose();
  }

  void _scheduleHighlightJump() {
    final start = widget.highlightStart;
    if (start == null || _jumpedToHighlight) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _jumpedToHighlight = true;
      _reveal(start, animate: false);
    });
  }

  void _reveal(int verse, {bool animate = true}) {
    if (verse < 1 || verse > _verseKeys.length) return;
    final ctx = _verseKeys[verse - 1].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.28,
      duration: animate && !MediaQuery.disableAnimationsOf(context)
          ? const Duration(milliseconds: 420)
          : Duration.zero,
      curve: Curves.easeInOutCubic,
    );
  }

  void _onTts() {
    final tts = TtsService.instance;
    final now = tts.sequenceKey == _key ? tts.sequenceIndex : null;
    final verse = now == null ? null : now + 1;
    if (verse == _speaking) return;
    setState(() => _speaking = verse);
    if (verse != null) _reveal(verse);
  }

  Future<void> _openVerse(int verse) async {
    ActHaptics.tap();
    setState(() => _selected = verse);
    await _showVerseActions(
      context,
      reading: widget.reading,
      book: _book,
      bookIndex: widget.bookIndex,
      chapter: widget.chapter,
      verse: verse,
      text: _verses[verse - 1],
      onListenFrom: () => widget.onListenFrom(verse),
      onOpenRef: widget.onOpenRef,
    );
    if (mounted) setState(() => _selected = null);
  }

  @override
  Widget build(BuildContext context) {
    final reading = widget.reading;
    final verses = _verses;
    final alreadyRead = context.select(
      (ProgressService p) =>
          p.hasReadBibleChapter(_book.abbrev, widget.chapter),
    );
    final bmSig = context.select((ProgressService p) {
      final prefix = '${_book.abbrev.toLowerCase()}:${widget.chapter}:';
      return p.bibleBookmarks.where((k) => k.startsWith(prefix)).join('|');
    });
    final saved = <int>{
      for (final k in bmSig.split('|'))
        if (k.isNotEmpty) int.tryParse(k.split(':').last) ?? -1,
    };
    final words = verses.fold<int>(0, (n, v) => n + v.split(' ').length);
    final minutes = (words / 200).ceil().clamp(1, 99);
    final pad = MediaQuery.paddingOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final side = width > 720 ? (width - 640) / 2 : AppSpace.xl + 4;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(side, pad.top + 96, side, pad.bottom + 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _book.name,
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 28, color: reading.ink),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            context.l10n.bibleChapterLabel(widget.chapter),
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 16, color: reading.verseNumber),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            [
              context.l10n.bibleVerseCount(verses.length),
              context.l10n.planMinutes(minutes),
              if (alreadyRead) context.l10n.bibleReaderReadTag,
            ].join(' · '),
            textAlign: TextAlign.center,
            style: reading.metaStyle,
          ),
          const SizedBox(height: AppSpace.lg),
          RelicHairline(accent: reading.verseNumber),
          const SizedBox(height: AppSpace.xl),
          for (var i = 0; i < verses.length; i++)
            _VerseBlock(
              key: _verseKeys[i],
              number: i + 1,
              text: verses[i],
              reading: reading,
              highlighted:
                  widget.highlightStart != null &&
                  i + 1 >= widget.highlightStart! &&
                  i + 1 <= (widget.highlightEnd ?? widget.highlightStart!),
              selected: _selected == i + 1,
              speaking: _speaking == i + 1,
              saved: saved.contains(i + 1),
              onTap: () => _openVerse(i + 1),
            ),
          const SizedBox(height: AppSpace.xxxl),
          _ChapterEnd(
            reading: reading,
            books: widget.books,
            bookName: _book.name,
            chapter: widget.chapter,
            alreadyRead: alreadyRead,
            next: widget.next,
            onComplete: widget.onComplete,
            onNext: widget.onNext,
          ),
        ],
      ),
    );
  }
}

class _VerseBlock extends StatelessWidget {
  final int number;
  final String text;
  final BibleReadingStyle reading;
  final bool highlighted;
  final bool selected;
  final bool speaking;
  final bool saved;
  final VoidCallback onTap;

  const _VerseBlock({
    super.key,
    required this.number,
    required this.text,
    required this.reading,
    required this.highlighted,
    required this.selected,
    required this.speaking,
    required this.saved,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lit = selected || speaking || highlighted;
    final fill = lit
        ? reading.highlightFill
        : saved
        ? reading.savedFill
        : reading.page.withValues(alpha: 0);
    final motion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      button: true,
      label: context.l10n.bibleVerseSemantics(number, text),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPress: onTap,
        child: AnimatedContainer(
          duration: motion ? Duration.zero : const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border(
              left: BorderSide(
                width: 2,
                color: saved
                    ? reading.verseNumber
                    : reading.verseNumber.withValues(alpha: 0),
              ),
            ),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$number  ',
                  style: reading.numberStyle.copyWith(
                    fontSize: 12,
                    height: 1,
                    color: speaking ? reading.ink : reading.verseNumber,
                  ),
                ),
                TextSpan(text: text, style: reading.verseStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChapterEnd extends StatelessWidget {
  final BibleReadingStyle reading;
  final List<BibleBook> books;
  final String bookName;
  final int chapter;
  final bool alreadyRead;
  final ({int bookIndex, int chapter})? next;
  final Future<void> Function() onComplete;
  final VoidCallback onNext;

  const _ChapterEnd({
    required this.reading,
    required this.books,
    required this.bookName,
    required this.chapter,
    required this.alreadyRead,
    required this.next,
    required this.onComplete,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final n = next;
    final nextBook = n == null ? null : books[n.bookIndex];
    final nextPreview = nextBook?.chapters[n!.chapter - 1].first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            context.l10n.bibleReaderChapterEnd(bookName, chapter),
            style: reading.metaStyle.copyWith(fontStyle: FontStyle.italic),
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        alreadyRead
            ? OutlineCta(
                label: context.l10n.bibleReaderChapterDone,
                onTap: null,
                leading: CinematicGlyph.check,
                color: reading.verseNumber,
              )
            : CopperCta(
                label: context.l10n.bibleReaderCompleteChapter,
                leading: CinematicGlyph.check,
                trailing: null,
                expanded: true,
                onTap: onComplete,
              ),
        if (n != null && nextBook != null) ...[
          const SizedBox(height: AppSpace.md),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onNext,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              child: Ink(
                padding: const EdgeInsets.all(AppSpace.lg),
                decoration: BoxDecoration(
                  color: reading.chipFill.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: reading.pageBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionLabel(
                            context.l10n.bibleReaderUpNext,
                            color: reading.verseNumber,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${nextBook.name} ${n.chapter}',
                            style: AppTypography.title(
                              size: 16,
                              color: reading.ink,
                            ),
                          ),
                          if (nextPreview != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              nextPreview,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.verse(
                                size: 16,
                                height: 1.35,
                                weight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                                color: reading.inkMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpace.md),
                    CinematicIcon(
                      glyph: CinematicGlyph.forward,
                      size: 20,
                      accent: reading.ink,
                      framed: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final String tooltip;
  final BibleReadingStyle reading;
  final VoidCallback? onTap;
  final Widget child;

  const _RoundButton({
    required this.tooltip,
    required this.reading,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: tooltip,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 26,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Opacity(opacity: enabled ? 1 : 0.3, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Doca flutuante — capítulo anterior, ouvir/parar, próximo.
class _ReaderDock extends StatelessWidget {
  final BibleReadingStyle reading;
  final String chapterKey;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onListen;

  const _ReaderDock({
    required this.reading,
    required this.chapterKey,
    required this.onPrevious,
    required this.onNext,
    required this.onListen,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom + AppSpace.md),
      child: Center(
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: reading.chrome,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: reading.chromeBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: reading.isDay ? 0.12 : 0.4,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ListenableBuilder(
              listenable: TtsService.instance,
              builder: (context, _) {
                final tts = TtsService.instance;
                final playing = tts.sequenceKey == chapterKey || tts.isSpeaking;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RoundButton(
                      tooltip: context.l10n.bibleReaderPrevChapter,
                      reading: reading,
                      onTap: onPrevious,
                      child: CinematicIcon(
                        glyph: CinematicGlyph.back,
                        size: 20,
                        accent: reading.ink,
                        framed: false,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onListen,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpace.lg,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: playing
                                ? reading.ink
                                : reading.ink.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CinematicIcon(
                                glyph: playing
                                    ? CinematicGlyph.stop
                                    : CinematicGlyph.echo,
                                size: AppMetrics.iconMd,
                                accent: playing ? reading.page : reading.ink,
                                framed: false,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                playing
                                    ? context.l10n.bibleReaderStop
                                    : context.l10n.bibleReaderListen,
                                style: AppTypography.title(
                                  size: 14,
                                  color: playing ? reading.page : reading.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _RoundButton(
                      tooltip: context.l10n.bibleReaderNextChapter,
                      reading: reading,
                      onTap: onNext,
                      child: CinematicIcon(
                        glyph: CinematicGlyph.forward,
                        size: 20,
                        accent: reading.ink,
                        framed: false,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sheets ──────────────────────────────────────────────────────────────

/// Painel no papel da leitura — a tinta clara some sobre o AppSheetPanel.
Widget _paperSheet(BibleReadingStyle reading, Widget child) {
  return DecoratedBox(
    decoration: BoxDecoration(
      color: reading.page,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadii.sheet),
      ),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.screen,
          AppSpace.sm,
          AppSpace.screen,
          AppSpace.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpace.lg),
                decoration: BoxDecoration(
                  color: reading.pageBorder,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    ),
  );
}

Future<void> _showVerseActions(
  BuildContext context, {
  required BibleReadingStyle reading,
  required BibleBook book,
  required int bookIndex,
  required int chapter,
  required int verse,
  required String text,
  required VoidCallback onListenFrom,
  required void Function(int bookIndex, int chapter, int verse) onOpenRef,
}) async {
  final progress = context.read<ProgressService>();
  final citation = '${book.name} $chapter:$verse';
  var saved = progress.isVerseBookmarked(book.abbrev, chapter, verse);

  Widget action({
    required CinematicGlyph glyph,
    required String label,
    String? detail,
    Color? accent,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              CinematicIcon(
                glyph: glyph,
                size: AppMetrics.leadingIcon,
                accent: accent ?? reading.inkMuted,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.title(size: 14, color: reading.ink),
                    ),
                    if (detail != null) Text(detail, style: reading.metaStyle),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  await showAppSheet<void>(
    context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => _paperSheet(
        reading,
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionLabel(citation, color: reading.verseNumber),
            const SizedBox(height: AppSpace.sm),
            Text(
              text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.verse(
                size: 18,
                height: 1.4,
                weight: FontWeight.w500,
                color: reading.ink,
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            Row(
              children: [
                for (final q in [
                  (
                    glyph: CinematicGlyph.bookmark,
                    label: saved
                        ? context.l10n.bibleVerseSaved
                        : context.l10n.bibleVerseSave,
                    lit: saved,
                    onTap: () async {
                      final added = await progress.toggleBibleBookmark(
                        book.abbrev,
                        chapter,
                        verse,
                      );
                      ActHaptics.light();
                      setSheetState(() => saved = added);
                    },
                  ),
                  (
                    glyph: CinematicGlyph.copy,
                    label: context.l10n.bibleVerseCopy,
                    lit: false,
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(text: '“$text” — $citation'),
                      );
                      ActHaptics.light();
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        showAppToastFor(
                          context,
                          message: context.l10n.bibleVerseCopied,
                          glyph: CinematicGlyph.copy,
                        );
                      }
                    },
                  ),
                  (
                    glyph: CinematicGlyph.share,
                    label: context.l10n.commonShare,
                    lit: false,
                    onTap: () async {
                      Navigator.pop(ctx);
                      await showShareVerseSheet(
                        context,
                        bookName: book.name,
                        chapter: chapter,
                        verse: verse,
                        text: text,
                      );
                    },
                  ),
                ]) ...[
                  if (q.glyph != CinematicGlyph.bookmark)
                    const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: q.onTap,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: q.lit
                                ? reading.highlightFill
                                : reading.chipFill.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            border: Border.all(
                              color: q.lit
                                  ? reading.highlightBorder
                                  : reading.pageBorder,
                            ),
                          ),
                          child: Column(
                            children: [
                              CinematicIcon(
                                glyph: q.glyph,
                                size: AppMetrics.iconLg,
                                accent: reading.ink,
                                framed: false,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                q.label,
                                style: AppTypography.label(
                                  size: 12,
                                  color: reading.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpace.md),
            action(
              glyph: CinematicGlyph.echo,
              label: context.l10n.bibleVerseListenFromHere,
              detail: context.l10n.bibleVerseListenFromHereDetail,
              accent: reading.verseNumber,
              onTap: () {
                Navigator.pop(ctx);
                onListenFrom();
              },
            ),
            action(
              glyph: CinematicGlyph.scroll,
              label: context.l10n.bibleVerseStudy,
              detail: context.l10n.bibleVerseStudyDetail,
              accent: reading.verseNumber,
              onTap: () {
                Navigator.pop(ctx);
                showVerseStudySheet(
                  context,
                  bookIndex: bookIndex,
                  bookName: book.name,
                  chapter: chapter,
                  verse: verse,
                  text: text,
                  onOpenRef: onOpenRef,
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// "Aa" — tamanho do texto, papel e versão, com prévia ao vivo.
Future<void> _showReadingSettings(BuildContext context) {
  return showAppSheet<void>(
    context,
    barrierColor: Colors.transparent,
    builder: (ctx) => Consumer<ProgressService>(
      builder: (ctx, progress, _) {
        final settings = progress.settings;
        final appearance = AppearanceStyle.resolve(settings.appearanceMode);
        final reading = BibleReadingStyle.resolve(
          appearance,
          readingNight: settings.bibleReadingNight,
          sepia: progress.bibleSepia,
        );
        final paper = !reading.isDay
            ? BiblePaper.night
            : progress.bibleSepia
            ? BiblePaper.sepia
            : BiblePaper.light;
        final scale = settings.fontScale;

        Future<void> setScale(double delta) async {
          final next = (scale + delta).clamp(0.85, 1.35);
          if (next == scale) return;
          ActHaptics.tap();
          await progress.updateSettings(settings.copyWith(fontScale: next));
        }

        Future<void> setPaper(BiblePaper p) async {
          if (p == paper) return;
          ActHaptics.tap();
          await progress.setBibleSepia(p == BiblePaper.sepia);
          await progress.updateSettings(
            settings.copyWith(bibleReadingNight: p == BiblePaper.night),
          );
        }

        final a = Appearance.of(ctx);
        return AppSheetPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Lâmpada para os meus pés é a tua palavra.',
                textAlign: TextAlign.center,
                style: AppTypography.verse(
                  size: 18,
                  height: 1.4,
                  weight: FontWeight.w500,
                  color: a.text,
                ),
              ),
              const SizedBox(height: AppSpace.xl),
              SectionLabel(
                context.l10n.bibleReaderTextSize,
                color: a.sectionLabel,
              ),
              const SizedBox(height: AppSpace.sm),
              Row(
                children: [
                  _SettingButton(
                    label: 'A−',
                    enabled: scale > 0.86,
                    onTap: () => setScale(-0.1),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.md,
                      ),
                      child: AppProgressBar(
                        value: (scale - 0.85) / 0.5,
                        height: 6,
                        color: AppRoles.chrome,
                      ),
                    ),
                  ),
                  _SettingButton(
                    label: 'A+',
                    enabled: scale < 1.34,
                    onTap: () => setScale(0.1),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.xl),
              SectionLabel(context.l10n.bibleReaderPaper, color: a.sectionLabel),
              const SizedBox(height: AppSpace.sm),
              Row(
                children: [
                  for (final p in const [
                    BiblePaper.light,
                    BiblePaper.sepia,
                    BiblePaper.night,
                  ]) ...[
                    if (p != BiblePaper.light)
                      const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: _PaperSwatch(
                        paper: p,
                        appearance: appearance,
                        selected: p == paper,
                        onTap: () => setPaper(p),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpace.xl),
              SectionLabel(
                context.l10n.bibleReaderVersion,
                color: a.sectionLabel,
              ),
              const SizedBox(height: AppSpace.sm),
              Row(
                children: [
                  for (final t in BibleService.catalog) ...[
                    if (t != BibleService.catalog.first)
                      const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: AppSelectChip(
                        label: t.shortName,
                        selected: t.id == settings.bibleTranslationId,
                        fontSize: 12,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(AppRadii.md),
                        ),
                        onTap: () => _applyTranslation(ctx, t),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                BibleService.byId(settings.bibleTranslationId).attribution ??
                    BibleService.byId(settings.bibleTranslationId).name,
                style: AppTypography.body(
                  size: 11,
                  height: 1.35,
                  color: a.textFaint,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

/// Doação abre no navegador. O pagamento fica nessa página, fora do app.
const _donatePage = 'https://stway.com.br/doar';

Future<void> _openDonatePage() async {
  await launchUrl(Uri.parse(_donatePage), mode: LaunchMode.externalApplication);
}

Future<void> _applyTranslation(
  BuildContext context,
  BibleTranslation translation,
) async {
  final progress = context.read<ProgressService>();
  if (!translation.available) {
    ActHaptics.tap();
    await showAppDialog<void>(
      context,
      builder: (ctx) => AppDialog(
        title: context.l10n.bibleTranslationSoonTitle,
        content: Text(
          context.l10n.bibleTranslationSoonBody(translation.name),
        ),
        actions: [
          GhostCta(
            label: context.l10n.bibleDonate,
            onTap: () {
              Navigator.pop(ctx);
              _openDonatePage();
            },
          ),
          CopperCta(
            label: context.l10n.commonGotIt,
            dense: true,
            trailing: null,
            onTap: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
    return;
  }
  if (translation.id == progress.settings.bibleTranslationId) return;
  ActHaptics.tap();
  await progress.updateSettings(
    progress.settings.copyWith(bibleTranslationId: translation.id),
  );
}

class _SettingButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _SettingButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Ink(
          width: 56,
          height: 44,
          decoration: BoxDecoration(
            color: a.cardFillSoft,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: a.cardBorder),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.title(
                size: label == 'A+' ? 18 : 14,
                color: enabled ? a.text : a.textFaint,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaperSwatch extends StatelessWidget {
  final BiblePaper paper;
  final AppearanceStyle appearance;
  final bool selected;
  final VoidCallback onTap;

  const _PaperSwatch({
    required this.paper,
    required this.appearance,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final look = BibleReadingStyle.resolve(
      appearance,
      readingNight: paper == BiblePaper.night,
      sepia: paper == BiblePaper.sepia,
    );
    return Semantics(
      button: true,
      selected: selected,
      label: context.l10n.biblePaperSemantics(paper.label),
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Ink(
            height: 64,
            decoration: BoxDecoration(
              color: look.page,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: selected ? AppRoles.selected : look.pageBorder,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Aa',
                  style: AppTypography.verse(
                    size: 21,
                    height: 1,
                    weight: FontWeight.w700,
                    color: look.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  paper.label,
                  style: AppTypography.label(size: 11, color: look.inkMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
