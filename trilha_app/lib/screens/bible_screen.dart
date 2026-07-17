import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/bible_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/share_verse_sheet.dart';
import '../widgets/top_bar.dart';
import '../widgets/verse_study_sheet.dart';

/// Aba Bíblia — navegação livro → capítulo → leitura, tudo offline.
class BibleScreen extends StatefulWidget {
  final Widget? topBar;

  const BibleScreen({super.key, this.topBar});

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
  String? _loadedTranslationId;
  bool _reloadScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = context.read<ProgressService>().settings.bibleTranslationId;
    await BibleService.instance.setTranslation(id);
    final books = await BibleService.instance.books();
    if (!mounted) return;
    setState(() {
      _books = books;
      _loadedTranslationId = id;
      _reloadScheduled = false;
    });
  }

  void _ensureTranslation(String id) {
    if (_loadedTranslationId == id || _reloadScheduled) return;
    _reloadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _bookIndex = null;
        _chapter = null;
        _searching = false;
        _hits = const [];
        _books = null;
      });
      _load();
    });
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

  Widget _navTopBar({
    required String title,
    required String subtitle,
    required VoidCallback onBack,
  }) {
    final appearance = Appearance.of(context);
    return TopBar(
      inline: true,
      immersive: true,
      dark: appearance.onDark,
      title: title,
      subtitle: subtitle,
      onBack: onBack,
      leadingGlyph: CinematicGlyph.book,
    );
  }

  @override
  Widget build(BuildContext context) {
    final translationId =
        context.watch<ProgressService>().settings.bibleTranslationId;
    _ensureTranslation(translationId);

    final books = _books;
    if (books == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_searching) {
      return _SearchPane(
        topBar: _navTopBar(
          title: 'Buscar',
          subtitle: 'Na Palavra',
          onBack: () => setState(() {
            _searching = false;
            _searchCtrl.clear();
            _hits = const [];
          }),
        ),
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
        topBar: widget.topBar,
        books: books,
        onPick: (i) => setState(() => _bookIndex = i),
        onSearch: () => setState(() => _searching = true),
      );
    }

    if (_chapter == null) {
      final book = books[_bookIndex!];
      return _ChapterPicker(
        topBar: _navTopBar(
          title: book.name,
          subtitle: 'Escolha o capítulo',
          onBack: () => setState(() => _bookIndex = null),
        ),
        book: book,
        onBack: () => setState(() => _bookIndex = null),
        onPick: (c) => setState(() => _chapter = c),
      );
    }

    final book = books[_bookIndex!];
    return BibleReaderView(
      topBar: _navTopBar(
        title: '${book.name} $_chapter',
        subtitle: BibleService.translationName,
        onBack: () => setState(() => _chapter = null),
      ),
      book: book,
      bookIndex: _bookIndex!,
      chapter: _chapter!,
      onBack: () => setState(() => _chapter = null),
      onChangeChapter: (c) => setState(() => _chapter = c),
      onOpenVerse: (bi, c, v) => setState(() {
        _bookIndex = bi;
        _chapter = c;
        _searching = false;
      }),
    );
  }
}

class _BookPicker extends StatelessWidget {
  final Widget? topBar;
  final List<BibleBook> books;
  final ValueChanged<int> onPick;
  final VoidCallback onSearch;

  const _BookPicker({
    this.topBar,
    required this.books,
    required this.onPick,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        topBar == null
            ? AppSpace.sm
            : MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
        20,
        scrollPaddingBelowNav(context),
      ),
      children: [
        if (topBar != null) ...[
          topBar!,
          const SizedBox(height: 14),
        ] else ...[
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
        ],
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onSearch,
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: AppColors.accent.withValues(alpha: 0.9),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Buscar na Palavra…',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.48),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const _TranslationPicker(),
        const SizedBox(height: 20),
        _TestamentSection(
          title: 'ANTIGO TESTAMENTO',
          books: books.take(BibleService.oldTestamentCount).toList(),
          offset: 0,
          onPick: onPick,
        ),
        const SizedBox(height: 20),
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

class _TranslationPicker extends StatelessWidget {
  const _TranslationPicker();

  Future<void> _open(BuildContext context) async {
    final progress = context.read<ProgressService>();
    final selected = progress.settings.bibleTranslationId;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A221C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        final maxH = MediaQuery.sizeOf(ctx).height * 0.72;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tradução',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Escolha a versão usada na leitura offline.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...BibleService.catalog.map((t) {
                    final isSelected = t.id == selected;
                    final enabled = t.available;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: !enabled
                              ? null
                              : () async {
                                  Navigator.pop(ctx);
                                  if (t.id == selected) return;
                                  await progress.updateSettings(
                                    progress.settings.copyWith(
                                      bibleTranslationId: t.id,
                                    ),
                                  );
                                },
                          borderRadius: BorderRadius.circular(14),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accent.withValues(alpha: 0.14)
                                  : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accent.withValues(alpha: 0.45)
                                    : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: enabled
                                        ? AppColors.accent.withValues(
                                            alpha: 0.16,
                                          )
                                        : Colors.white.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    t.shortName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: enabled
                                          ? AppColors.accent
                                          : Colors.white.withValues(
                                              alpha: 0.35,
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: enabled
                                              ? Colors.white
                                              : Colors.white.withValues(
                                                  alpha: 0.45,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        t.blurb,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withValues(
                                            alpha: enabled ? 0.5 : 0.32,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.accent,
                                    size: 20,
                                  )
                                else if (!enabled)
                                  Text(
                                    'Em breve',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Text(
                    BibleService.byId(selected).attribution ??
                        'Traduções offline disponíveis no dispositivo.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final translation = BibleService.byId(
      progress.settings.bibleTranslationId,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  translation.shortName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translation.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      translation.blurb,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.expand_more_rounded,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchPane extends StatelessWidget {
  final Widget? topBar;
  final TextEditingController controller;
  final List<BibleSearchHit> hits;
  final bool busy;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;
  final ValueChanged<BibleSearchHit> onOpen;

  const _SearchPane({
    this.topBar,
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
        topBar == null
            ? AppSpace.sm
            : MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
        20,
        scrollPaddingBelowNav(context),
      ),
      children: [
        if (topBar != null) ...[topBar!, const SizedBox(height: 18)],
        TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: 'Ex.: lâmpada, amor, fe…',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
              ),
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
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
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
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
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
    final a = Appearance.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: AppTypography.label(
                  size: 12,
                  color: Colors.white.withValues(alpha: 0.88),
                  letterSpacing: 1.6,
                ),
              ),
            ),
            Text(
              '${books.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: a.cardBorder),
          ),
          child: Column(
            children: List.generate(books.length, (i) {
              final isLast = i == books.length - 1;
              return _BookRow(
                book: books[i],
                onTap: () => onPick(offset + i),
                showDivider: !isLast,
                isFirst: i == 0,
                isLast: isLast,
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _BookRow extends StatelessWidget {
  final BibleBook book;
  final VoidCallback onTap;
  final bool showDivider;
  final bool isFirst;
  final bool isLast;

  const _BookRow({
    required this.book,
    required this.onTap,
    required this.showDivider,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final chapters = book.chapters.length;
    final abbrev = book.abbrev.toUpperCase();
    final radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(AppRadii.md) : Radius.zero,
      bottom: isLast ? const Radius.circular(AppRadii.md) : Radius.zero,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(
                      abbrev,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: abbrev.length > 3 ? 10 : 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      book.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: -0.2,
                        color: a.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    chapters == 1 ? '1 cap.' : '$chapters caps.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: a.textMuted(0.55),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ],
              ),
            ),
            if (showDivider)
              Padding(
                padding: const EdgeInsets.only(left: 58),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChapterPicker extends StatelessWidget {
  final Widget? topBar;
  final BibleBook book;
  final VoidCallback onBack;
  final ValueChanged<int> onPick;

  const _ChapterPicker({
    this.topBar,
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
        topBar == null
            ? AppSpace.sm
            : MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
        20,
        scrollPaddingBelowNav(context),
      ),
      children: [
        if (topBar != null) ...[topBar!, const SizedBox(height: 14)],
        if (topBar == null) ...[
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
        ],
        Center(
          child: Text(
            readCount > 0
                ? '$readCount de ${book.chapters.length} capítulos lidos'
                : '${book.chapters.length} capítulos',
            style: TextStyle(fontSize: 12, color: a.textMuted(0.6)),
          ),
        ),
        if (readCount > 0) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: readCount / book.chapters.length,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              color: AppColors.accent,
            ),
          ),
        ],
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(book.chapters.length, (i) {
            final chapter = i + 1;
            final read = progress.hasReadBibleChapter(book.abbrev, chapter);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onPick(chapter),
                borderRadius: BorderRadius.circular(14),
                child: Ink(
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
                              color: AppColors.accent.withValues(alpha: 0.28),
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
  final Widget? topBar;
  final BibleBook book;
  final int bookIndex;
  final int chapter;
  final VoidCallback onBack;
  final ValueChanged<int>? onChangeChapter;
  final int? highlightStart;
  final int? highlightEnd;
  final void Function(int bookIndex, int chapter, int verse)? onOpenVerse;

  const BibleReaderView({
    super.key,
    this.topBar,
    required this.book,
    required this.bookIndex,
    required this.chapter,
    required this.onBack,
    this.onChangeChapter,
    this.highlightStart,
    this.highlightEnd,
    this.onOpenVerse,
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
    required int bookIndex,
    required int chapter,
    required int verse,
    required String text,
    void Function(int bookIndex, int chapter, int verse)? onOpenVerse,
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final added = await progress.toggleBibleBookmark(
                      book.abbrev,
                      chapter,
                      verse,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            added
                                ? 'Versículo favoritado'
                                : 'Removido dos favoritos',
                          ),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.accent,
                  ),
                  title: const Text(
                    'Estudar (Strong & originais)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    'Léxico, morfologia, concordância e refs',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    showVerseStudySheet(
                      context,
                      bookIndex: bookIndex,
                      bookName: book.name,
                      chapter: chapter,
                      verse: verse,
                      text: text,
                      onOpenRef: onOpenVerse,
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.ios_share_rounded,
                    color: Colors.white70,
                  ),
                  title: const Text(
                    'Compartilhar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
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
        topBar == null
            ? AppSpace.sm
            : MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
        20,
        scrollPaddingBelowNav(context),
      ),
      children: [
        if (topBar != null) ...[topBar!, const SizedBox(height: 14)],
        if (topBar == null) ...[
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
        ],
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
                    bookIndex: bookIndex,
                    chapter: chapter,
                    verse: n,
                    text: verses[i],
                    onOpenVerse: onOpenVerse,
                  ),
                  onLongPress: () => _verseActions(
                    context,
                    progress: progress,
                    book: book,
                    bookIndex: bookIndex,
                    chapter: chapter,
                    verse: n,
                    text: verses[i],
                    onOpenVerse: onOpenVerse,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
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
                                    color: AppColors.accent.withValues(
                                      alpha: 0.85,
                                    ),
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
                            saved
                                ? Icons.star_rounded
                                : Icons.more_horiz_rounded,
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
            if (chapter > 1 && onChangeChapter != null)
              const SizedBox(width: 10),
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
                  glyph: alreadyRead
                      ? CinematicGlyph.check
                      : CinematicGlyph.book,
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
    final mode = context.watch<ProgressService>().settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);
    return Appearance(
      mode: mode,
      style: appearance,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ImmersiveBackground(
          appearance: appearance,
          child: _failed
              ? Center(
                  child: Text(
                    'Não foi possível abrir ${widget.reference}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
              : (_book == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      )
                    : BibleReaderView(
                        topBar: TopBar(
                          inline: true,
                          immersive: true,
                          dark: true,
                          title: _book!.name,
                          subtitle: 'Capítulo $_chapter',
                          onBack: () => Navigator.of(context).pop(),
                          leadingGlyph: CinematicGlyph.book,
                        ),
                        book: _book!,
                        bookIndex: _ref!.bookIndex,
                        chapter: _chapter!,
                        onBack: () => Navigator.of(context).pop(),
                        onChangeChapter: (c) => setState(() => _chapter = c),
                        highlightStart: _chapter == _ref!.chapter
                            ? _ref!.verseStart
                            : null,
                        highlightEnd: _chapter == _ref!.chapter
                            ? _ref!.verseEnd
                            : null,
                        onOpenVerse: (bi, c, v) async {
                          final books = await BibleService.instance.books();
                          if (!mounted) return;
                          setState(() {
                            _book = books[bi];
                            _ref = BibleRef(
                              bookIndex: bi,
                              chapter: c,
                              verseStart: v,
                              verseEnd: v,
                            );
                            _chapter = c;
                          });
                        },
                      )),
        ),
      ),
    );
  }
}
