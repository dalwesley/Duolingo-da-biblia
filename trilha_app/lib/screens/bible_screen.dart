import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/bible_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/share_verse_sheet.dart';
import 'memory_screen.dart';

/// Aba Bíblia — navegação livro → capítulo → leitura, tudo offline.
class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  List<BibleBook>? _books;
  int? _bookIndex;
  int? _chapter;
  bool _searching = false;
  final _searchCtrl = TextEditingController();
  List<BibleSearchHit> _hits = const [];
  bool _searchingBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final books = await BibleService.instance.books();
    if (mounted) setState(() => _books = books);
  }

  Future<void> _runSearch(String q) async {
    setState(() => _searchingBusy = true);
    final hits = await BibleService.instance.search(q);
    if (!mounted) return;
    setState(() {
      _hits = hits;
      _searchingBusy = false;
    });
  }

  void _openHit(BibleSearchHit hit) {
    setState(() {
      _searching = false;
      _bookIndex = hit.bookIndex;
      _chapter = hit.chapter;
      _searchCtrl.clear();
      _hits = const [];
    });
  }

  void _openBookmark(String abbrev, int chapter, int verse) {
    final books = _books;
    if (books == null) return;
    final i = books.indexWhere((b) => b.abbrev.toLowerCase() == abbrev.toLowerCase());
    if (i < 0) return;
    setState(() {
      _bookIndex = i;
      _chapter = chapter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final books = _books;
    if (books == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_searching) {
      return _SearchPane(
        controller: _searchCtrl,
        hits: _hits,
        busy: _searchingBusy,
        onChanged: _runSearch,
        onClose: () => setState(() {
          _searching = false;
          _searchCtrl.clear();
          _hits = const [];
        }),
        onOpen: _openHit,
      );
    }

    if (_bookIndex == null) {
      return _BookPicker(
        books: books,
        onPick: (i) => setState(() => _bookIndex = i),
        onSearch: () => setState(() => _searching = true),
        onOpenBookmark: _openBookmark,
      );
    }

    if (_chapter == null) {
      return _ChapterPicker(
        book: books[_bookIndex!],
        onBack: () => setState(() => _bookIndex = null),
        onPick: (c) => setState(() => _chapter = c),
      );
    }

    return BibleReaderView(
      book: books[_bookIndex!],
      chapter: _chapter!,
      onBack: () => setState(() => _chapter = null),
      onChangeChapter: (c) => setState(() => _chapter = c),
    );
  }
}

class _BookPicker extends StatelessWidget {
  final List<BibleBook> books;
  final ValueChanged<int> onPick;
  final VoidCallback onSearch;
  final void Function(String abbrev, int chapter, int verse) onOpenBookmark;

  const _BookPicker({
    required this.books,
    required this.onPick,
    required this.onSearch,
    required this.onOpenBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final bookmarks = progress.parseBookmarks().take(8).toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        AppSpace.xl,
        20,
        scrollPaddingBelowNav(context),
      ),
      children: [
        Column(
          children: [
            Text(
              'BÍBLIA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: AppColors.accent.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bíblia Sagrada',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              BibleService.translationName,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: onSearch,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.55), size: 22),
                const SizedBox(width: 10),
                Text(
                  'Buscar na Palavra…',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (bookmarks.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            'FAVORITOS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 10),
          ...bookmarks.map((b) {
            BibleBook? book;
            for (final x in books) {
              if (x.abbrev.toLowerCase() == b.abbrev.toLowerCase()) {
                book = x;
                break;
              }
            }
            final label = book == null
                ? '${b.abbrev.toUpperCase()} ${b.chapter}:${b.verse}'
                : '${book.name} ${b.chapter}:${b.verse}';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onOpenBookmark(b.abbrev, b.chapter, b.verse),
                  borderRadius: BorderRadius.circular(14),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.28)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.accent, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.35)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MemoryScreen()),
            ),
            child: Text(
              'Treinar memorização →',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.accent.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        _TestamentSection(
          title: 'ANTIGO TESTAMENTO',
          books: books.take(BibleService.oldTestamentCount).toList(),
          offset: 0,
          onPick: onPick,
        ),
        const SizedBox(height: 24),
        _TestamentSection(
          title: 'NOVO TESTAMENTO',
          books: books.skip(BibleService.oldTestamentCount).toList(),
          offset: BibleService.oldTestamentCount,
          onPick: onPick,
        ),
      ],
    );
  }
}

class _SearchPane extends StatelessWidget {
  final TextEditingController controller;
  final List<BibleSearchHit> hits;
  final bool busy;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;
  final ValueChanged<BibleSearchHit> onOpen;

  const _SearchPane({
    required this.controller,
    required this.hits,
    required this.busy,
    required this.onChanged,
    required this.onClose,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        AppSpace.xl,
        20,
        scrollPaddingBelowNav(context),
      ),
      children: [
        _InlineBack(label: 'Livros', onTap: onClose),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: 'Ex.: lâmpada, amor, fe…',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
        if (busy)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
          )
        else if (controller.text.trim().length >= 2 && hits.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(
              'Nenhum versículo encontrado',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
          )
        else
          ...hits.map((h) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onOpen(h),
                  borderRadius: BorderRadius.circular(16),
                  child: Ink(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.citation,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          h.text,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 17,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _TestamentSection extends StatelessWidget {
  final String title;
  final List<BibleBook> books;
  final int offset;
  final ValueChanged<int> onPick;

  const _TestamentSection({
    required this.title,
    required this.books,
    required this.offset,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 16,
              height: 1.5,
              color: AppColors.accent.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const Spacer(),
            Text(
              '${books.length}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 10.0;
            final tileW = (constraints.maxWidth - gap) / 2;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: List.generate(books.length, (i) {
                return SizedBox(
                  width: tileW,
                  child: _BookTile(
                    book: books[i],
                    onTap: () => onPick(offset + i),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

class _BookTile extends StatelessWidget {
  final BibleBook book;
  final VoidCallback onTap;

  const _BookTile({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final chapters = book.chapters.length;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
            gradient: a.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: a.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.28),
                  ),
                ),
                child: Text(
                  book.abbrev.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: book.abbrev.length > 3 ? 9 : 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      book.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: a.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      chapters == 1 ? '1 capítulo' : '$chapters capítulos',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: a.textMuted(0.5),
                      ),
                    ),
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

class _ChapterPicker extends StatelessWidget {
  final BibleBook book;
  final VoidCallback onBack;
  final ValueChanged<int> onPick;

  const _ChapterPicker({
    required this.book,
    required this.onBack,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final progress = context.watch<ProgressService>();
    final readCount = progress.readChaptersInBook(book.abbrev);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        AppSpace.xl,
        20,
        scrollPaddingBelowNav(context),
      ),
      children: [
        _InlineBack(label: 'Livros', onTap: onBack),
        const SizedBox(height: 12),
        Center(
          child: Text(
            book.name,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            readCount > 0
                ? '$readCount de ${book.chapters.length} capítulos lidos'
                : '${book.chapters.length} capítulos',
            style: TextStyle(fontSize: 12, color: a.textMuted(0.6)),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(book.chapters.length, (i) {
            final chapter = i + 1;
            final read = progress.hasReadBibleChapter(book.abbrev, chapter);
            return GestureDetector(
              onTap: () => onPick(chapter),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: read ? AppGradients.gold : a.cardGradient,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: read
                        ? AppColors.accent.withValues(alpha: 0.7)
                        : a.cardBorder,
                  ),
                  boxShadow: read
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.35),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$chapter',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: read ? AppColors.inkOnAccent : a.text,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Leitor de capítulo — usado na aba e na rota vinda das lições.
class BibleReaderView extends StatelessWidget {
  final BibleBook book;
  final int chapter;
  final VoidCallback onBack;
  final ValueChanged<int>? onChangeChapter;
  final int? highlightStart;
  final int? highlightEnd;

  const BibleReaderView({
    super.key,
    required this.book,
    required this.chapter,
    required this.onBack,
    this.onChangeChapter,
    this.highlightStart,
    this.highlightEnd,
  });

  bool _highlighted(int verseNumber) {
    if (highlightStart == null) return false;
    final end = highlightEnd ?? highlightStart!;
    return verseNumber >= highlightStart! && verseNumber <= end;
  }

  Future<void> _verseActions(
    BuildContext context, {
    required ProgressService progress,
    required BibleBook book,
    required int chapter,
    required int verse,
    required String text,
  }) async {
    final saved = progress.isVerseBookmarked(book.abbrev, chapter, verse);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A221C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${book.name} $chapter:$verse',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    saved ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: AppColors.accent,
                  ),
                  title: Text(
                    saved ? 'Remover dos favoritos' : 'Guardar no coração',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final added = await progress.toggleBibleBookmark(book.abbrev, chapter, verse);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(added ? 'Versículo favoritado' : 'Removido dos favoritos'),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.ios_share_rounded, color: Colors.white70),
                  title: const Text(
                    'Compartilhar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    showShareVerseSheet(
                      context,
                      bookName: book.name,
                      chapter: chapter,
                      verse: verse,
                      text: text,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final verses = book.chapters[chapter - 1];
    final progress = context.watch<ProgressService>();
    final alreadyRead = progress.hasReadBibleChapter(book.abbrev, chapter);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        AppSpace.xl,
        20,
        scrollPaddingBelowNav(context),
      ),
      children: [
        _InlineBack(label: book.name, onTap: onBack),
        const SizedBox(height: 12),
        Center(
          child: Text(
            '${book.name} $chapter',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            BibleService.translationName,
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: a.textMuted(0.55),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: a.cardGradient,
            border: Border.all(color: a.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(verses.length, (i) {
              final n = i + 1;
              final hl = _highlighted(n);
              final saved = progress.isVerseBookmarked(book.abbrev, chapter, n);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _verseActions(
                    context,
                    progress: progress,
                    book: book,
                    chapter: chapter,
                    verse: n,
                    text: verses[i],
                  ),
                  onLongPress: () => _verseActions(
                    context,
                    progress: progress,
                    book: book,
                    chapter: chapter,
                    verse: n,
                    text: verses[i],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: hl
                        ? BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.4),
                            ),
                          )
                        : saved
                            ? BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(12),
                              )
                            : null,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$n  ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.accent.withValues(alpha: 0.85),
                                  ),
                                ),
                                TextSpan(
                                  text: verses[i],
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 19,
                                    height: 1.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(
                                      alpha: hl ? 0.98 : 0.88,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 6, top: 2),
                          child: Icon(
                            saved ? Icons.star_rounded : Icons.more_horiz_rounded,
                            size: 15,
                            color: saved
                                ? AppColors.accent
                                : Colors.white.withValues(alpha: 0.28),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            if (chapter > 1 && onChangeChapter != null)
              Expanded(
                child: _NavChip(
                  label: '← Cap. ${chapter - 1}',
                  onTap: () => onChangeChapter!(chapter - 1),
                ),
              ),
            if (chapter > 1 && onChangeChapter != null) const SizedBox(width: 10),
            if (chapter < book.chapters.length && onChangeChapter != null)
              Expanded(
                child: _NavChip(
                  label: 'Cap. ${chapter + 1} →',
                  onTap: () => onChangeChapter!(chapter + 1),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: alreadyRead
              ? null
              : () async {
                  await progress.recordBibleReading(book.abbrev, chapter);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Capítulo marcado como lido!'),
                      ),
                    );
                  }
                },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: alreadyRead ? null : AppGradients.gold,
              color: alreadyRead ? Colors.white.withValues(alpha: 0.08) : null,
              borderRadius: BorderRadius.circular(18),
              border: alreadyRead
                  ? Border.all(color: AppColors.accent.withValues(alpha: 0.45))
                  : null,
              boxShadow: alreadyRead
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CinematicIcon(
                  glyph: alreadyRead ? CinematicGlyph.check : CinematicGlyph.book,
                  size: 20,
                  accent: alreadyRead
                      ? AppColors.accent
                      : AppColors.inkOnAccent,
                  glowing: false,
                  framed: false,
                ),
                const SizedBox(width: 8),
                Text(
                  alreadyRead ? 'CAPÍTULO LIDO' : 'AVANÇAR NA LEITURA',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: alreadyRead
                        ? AppColors.accent
                        : AppColors.inkOnAccent,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NavChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: a.cardGradient,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: a.cardBorder),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: a.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineBack extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _InlineBack({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(
            Icons.arrow_back_rounded,
            size: 18,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rota independente aberta a partir das lições ("Ler no app").
class BibleReaderScreen extends StatefulWidget {
  final String reference;

  const BibleReaderScreen({super.key, required this.reference});

  @override
  State<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends State<BibleReaderScreen> {
  BibleBook? _book;
  BibleRef? _ref;
  int? _chapter;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final ref = await BibleService.instance.resolve(widget.reference);
    if (!mounted) return;
    if (ref == null) {
      setState(() => _failed = true);
      return;
    }
    final books = await BibleService.instance.books();
    if (!mounted) return;
    setState(() {
      _ref = ref;
      _book = books[ref.bookIndex];
      _chapter = ref.chapter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.cosmic),
        child: SafeArea(
          top: false,
          bottom: false,
          child: _failed
              ? Center(
                  child: Text(
                    'Não foi possível abrir ${widget.reference}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
              : (_book == null
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    )
                  : BibleReaderView(
                      book: _book!,
                      chapter: _chapter!,
                      onBack: () => Navigator.of(context).pop(),
                      onChangeChapter: (c) => setState(() => _chapter = c),
                      highlightStart:
                          _chapter == _ref!.chapter ? _ref!.verseStart : null,
                      highlightEnd:
                          _chapter == _ref!.chapter ? _ref!.verseEnd : null,
                    )),
        ),
      ),
    );
  }
}
