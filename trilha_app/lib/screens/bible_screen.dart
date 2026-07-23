import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/bible_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/bible_reading_theme.dart';
import '../utils/layout_utils.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/share_verse_sheet.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
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
  Timer? _searchDebounce;
  int _searchGen = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
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

  void _scheduleSearch(String q) {
    _searchDebounce?.cancel();
    final trimmed = q.trim();
    if (trimmed.length < 2) {
      setState(() {
        _hits = const [];
        _searchingBusy = false;
      });
      return;
    }
    setState(() => _searchingBusy = true);
    final gen = ++_searchGen;
    _searchDebounce = Timer(const Duration(milliseconds: 280), () async {
      final hits = await BibleService.instance.search(trimmed);
      if (!mounted || gen != _searchGen) return;
      setState(() {
        _hits = hits;
        _searchingBusy = false;
      });
    });
  }

  void _openHit(BibleSearchHit hit) {
    setState(() {
      _searching = false;
      _bookIndex = hit.bookIndex;
      // Livro → seletor de capítulos; versículo → leitura direta.
      _chapter = hit.isBook ? null : hit.chapter;
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

  /// Root da aba / rota empurrada — nunca fica sem chrome.
  Widget _rootTopBar() {
    if (widget.topBar != null) return widget.topBar!;
    final appearance = Appearance.of(context);
    final nav = Navigator.of(context);
    return TopBar(
      inline: true,
      immersive: true,
      dark: appearance.onDark,
      title: 'Bíblia',
      subtitle: 'A Palavra, offline',
      leadingGlyph: CinematicGlyph.book,
      onBack: nav.canPop() ? () => nav.pop() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final translationId = context
        .watch<ProgressService>()
        .settings
        .bibleTranslationId;
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
          subtitle: 'Livros e versículos',
          onBack: () => setState(() {
            _searching = false;
            _searchCtrl.clear();
            _hits = const [];
          }),
        ),
        controller: _searchCtrl,
        hits: _hits,
        busy: _searchingBusy,
        onChanged: _scheduleSearch,
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
        topBar: _rootTopBar(),
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
  final Widget topBar;
  final List<BibleBook> books;
  final ValueChanged<int> onPick;
  final VoidCallback onSearch;

  const _BookPicker({
    required this.topBar,
    required this.books,
    required this.onPick,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpace.screen,
        MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
        AppSpace.screen,
        scrollPaddingBelowNav(context),
      ),
      children: [
        topBar,
        const SizedBox(height: AppSpace.afterTopBar),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onSearch,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: Ink(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.md,
                vertical: AppSpace.md,
              ),
              decoration: BoxDecoration(
                color: Appearance.of(context).cardFillSoft,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: Appearance.of(context).cardBorder),
              ),
              child: Row(
                children: [
                  CinematicIcon(
                    glyph: CinematicGlyph.search,
                    size: 20,
                    accent: AppColors.accent.withValues(alpha: 0.9),
                    framed: false,
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: Text(
                      'Buscar livro ou versículo…',
                      style: AppTypography.body(
                        size: 14,
                        weight: FontWeight.w600,
                        color: Appearance.of(context).textMuted(0.55),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        const _TranslationPicker(),
        const SizedBox(height: AppSpace.section),
        _TestamentSection(
          title: 'ANTIGO TESTAMENTO',
          books: books.take(BibleService.oldTestamentCount).toList(),
          offset: 0,
          onPick: onPick,
        ),
        const SizedBox(height: AppSpace.section),
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
      backgroundColor: AppColors.sheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        final maxH = MediaQuery.sizeOf(ctx).height * 0.72;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.screen,
                AppSpace.lg,
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
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.lg),
                  Text(
                    'Tradução',
                    style: AppTypography.display(size: 26, color: Colors.white),
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    'Escolha a versão usada na leitura offline.',
                    style: AppTypography.body(
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: AppSpace.lg),
                  ...BibleService.catalog.map((t) {
                    final isSelected = t.id == selected;
                    final enabled = t.available;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.sm),
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
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.md,
                              vertical: AppSpace.md,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accent.withValues(alpha: 0.14)
                                  : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(AppRadii.md),
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
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.sm,
                                    ),
                                  ),
                                  child: Text(
                                    t.shortName,
                                    style: AppTypography.label(
                                      size: 12,
                                      color: enabled
                                          ? AppColors.accent
                                          : Colors.white.withValues(
                                              alpha: 0.35,
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpace.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.name,
                                        style: AppTypography.title(
                                          size: 14,
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
                                        style: AppTypography.body(
                                          size: 12,
                                          color: Colors.white.withValues(
                                            alpha: enabled ? 0.5 : 0.32,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const CinematicIcon(
                                    glyph: CinematicGlyph.check,
                                    size: 20,
                                    accent: AppColors.accent,
                                    framed: false,
                                  )
                                else if (!enabled)
                                  Text(
                                    'Em breve',
                                    style: AppTypography.label(
                                      size: 11,
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
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    BibleService.byId(selected).attribution ??
                        'Traduções offline disponíveis no dispositivo.',
                    style: AppTypography.body(
                      size: 11,
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
    final a = Appearance.of(context);
    final translation = BibleService.byId(progress.settings.bibleTranslationId);

    return GlassCard(
      onTap: () => _open(context),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.md,
      ),
      child: Row(
        children: [
          SoftBadge(text: translation.shortName, accent: AppColors.accent),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translation.name,
                  style: AppTypography.title(size: 14, color: a.text),
                ),
                const SizedBox(height: 2),
                Text(
                  translation.blurb,
                  style: AppTypography.body(size: 11, color: a.textMuted(0.55)),
                ),
              ],
            ),
          ),
          Icon(Icons.expand_more_rounded, color: a.textMuted(0.45), size: 22),
        ],
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
        AppSpace.screen,
        topBar == null
            ? AppSpace.sm
            : MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
        AppSpace.screen,
        scrollPaddingBelowNav(context),
      ),
      children: [
        if (topBar != null) ...[
          topBar!,
          const SizedBox(height: AppSpace.afterTopBar),
        ],
        TextField(
          controller: controller,
          autofocus: true,
          style: AppTypography.body(
            size: 14,
            weight: FontWeight.w600,
            color: Appearance.of(context).text,
          ),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: 'Ex.: Apocalipse, amor, fé…',
            hintStyle: AppTypography.body(
              color: Appearance.of(context).textMuted(0.4),
            ),
            filled: true,
            fillColor: Appearance.of(context).cardFillSoft,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(AppSpace.md),
              child: CinematicIcon(
                glyph: CinematicGlyph.search,
                size: 20,
                accent: Appearance.of(context).textMuted(0.55),
                framed: false,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              borderSide: BorderSide(color: Appearance.of(context).cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              borderSide: BorderSide(color: Appearance.of(context).cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: AppSpace.lg),
        if (busy)
          const Padding(
            padding: EdgeInsets.only(top: AppSpace.xxl),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          )
        else if (controller.text.trim().length >= 2 && hits.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.xxl),
            child: Text(
              'Nenhum resultado encontrado',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          )
        else
          ...hits.map((h) {
            final a = Appearance.of(context);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.sm),
              child: GlassCard(
                onTap: () => onOpen(h),
                padding: const EdgeInsets.all(AppSpace.md),
                radius: AppRadii.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h.isBook ? 'Livro' : h.citation,
                      style: AppTypography.label(
                        size: 12,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      h.isBook ? h.bookName : h.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.display(
                        size: 17,
                        height: 1.35,
                        weight: FontWeight.w600,
                        color: a.text.withValues(alpha: 0.9),
                      ),
                    ),
                    if (h.isBook) ...[
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        h.text,
                        style: AppTypography.body(
                          size: 13,
                          color: a.textMuted(0.55),
                        ),
                      ),
                    ],
                  ],
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
            const SizedBox(width: AppSpace.sm),
            Expanded(child: SectionLabel(title, color: a.sectionLabel)),
            Text(
              '${books.length}',
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w700,
                color: a.textMuted(0.45),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        GlassCard(
          padding: EdgeInsets.zero,
          radius: AppRadii.lg,
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
      top: isFirst ? const Radius.circular(AppRadii.lg) : Radius.zero,
      bottom: isLast ? const Radius.circular(AppRadii.lg) : Radius.zero,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.md,
                AppSpace.md,
                AppSpace.md,
                AppSpace.md,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(
                      abbrev,
                      maxLines: 1,
                      style: AppTypography.label(
                        size: abbrev.length > 3 ? 10 : 12,
                        letterSpacing: 0.3,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: Text(
                      book.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(
                        size: 15,
                        weight: FontWeight.w700,
                        height: 1.2,
                        color: a.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Text(
                    chapters == 1 ? '1 cap.' : '$chapters caps.',
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w600,
                      color: a.textMuted(0.55),
                    ),
                  ),
                  const SizedBox(width: AppSpace.xs),
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
        AppSpace.screen,
        topBar == null
            ? AppSpace.sm
            : MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
        AppSpace.screen,
        scrollPaddingBelowNav(context),
      ),
      children: [
        if (topBar != null) ...[
          topBar!,
          const SizedBox(height: AppSpace.afterTopBar),
        ],
        if (topBar == null) ...[
          Center(
            child: Text(
              book.name,
              style: AppTypography.display(size: 32, color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpace.xs),
        ],
        Center(
          child: Text(
            readCount > 0
                ? '$readCount de ${book.chapters.length} capítulos lidos'
                : '${book.chapters.length} capítulos',
            style: AppTypography.body(size: 12, color: a.textMuted(0.6)),
          ),
        ),
        if (readCount > 0) ...[
          const SizedBox(height: AppSpace.md),
          AppProgressBar(
            value: readCount / book.chapters.length,
            trackColor: Colors.white.withValues(alpha: 0.08),
          ),
        ],
        const SizedBox(height: AppSpace.section),
        Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          children: List.generate(book.chapters.length, (i) {
            final chapter = i + 1;
            final read = progress.hasReadBibleChapter(book.abbrev, chapter);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onPick(chapter),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: Ink(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: read ? AppGradients.gold : a.cardGradient,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
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
                      style: AppTypography.title(
                        size: 15,
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

/// Leitor de capítulo — página clara no sol, suave à noite.
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

  Future<void> _adjustFont(BuildContext context, double delta) async {
    final progress = context.read<ProgressService>();
    final next = (progress.settings.fontScale + delta).clamp(0.85, 1.35);
    if (next == progress.settings.fontScale) return;
    HapticFeedback.selectionClick();
    await progress.updateSettings(progress.settings.copyWith(fontScale: next));
  }

  Future<void> _verseActions(
    BuildContext context, {
    required ProgressService progress,
    required BibleReadingStyle reading,
    required BibleBook book,
    required int bookIndex,
    required int chapter,
    required int verse,
    required String text,
    void Function(int bookIndex, int chapter, int verse)? onOpenVerse,
  }) async {
    var saved = progress.isVerseBookmarked(book.abbrev, chapter, verse);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: reading.page,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.screen,
                  AppSpace.lg,
                  AppSpace.screen,
                  AppSpace.xl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${book.name} $chapter:$verse',
                      style: AppTypography.label(
                        size: 13,
                        color: reading.verseNumber,
                      ),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      text,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: reading.verseStyle.copyWith(
                        fontSize: 18,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CinematicIcon(
                        glyph: CinematicGlyph.star,
                        size: 24,
                        accent: reading.verseNumber.withValues(
                          alpha: saved ? 1 : 0.45,
                        ),
                        framed: false,
                      ),
                      title: Text(
                        saved ? 'Remover dos favoritos' : 'Salvar favorito',
                        style: AppTypography.title(
                          size: 14,
                          color: reading.ink,
                        ),
                      ),
                      onTap: () async {
                        final added = await progress.toggleBibleBookmark(
                          book.abbrev,
                          chapter,
                          verse,
                        );
                        setSheetState(() => saved = added);
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
                      leading: CinematicIcon(
                        glyph: CinematicGlyph.scroll,
                        size: 24,
                        accent: reading.verseNumber,
                        framed: false,
                      ),
                      title: Text(
                        'Estudar (Strong & originais)',
                        style: AppTypography.title(
                          size: 14,
                          color: reading.ink,
                        ),
                      ),
                      subtitle: Text(
                        'Léxico, morfologia, concordância e refs',
                        style: reading.metaStyle,
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
                      leading: CinematicIcon(
                        glyph: CinematicGlyph.share,
                        size: 24,
                        accent: reading.inkMuted,
                        framed: false,
                      ),
                      title: Text(
                        'Compartilhar',
                        style: AppTypography.title(
                          size: 14,
                          color: reading.ink,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final fontScale = context.select(
      (ProgressService p) => p.settings.fontScale,
    );
    final alreadyRead = context.select(
      (ProgressService p) => p.hasReadBibleChapter(book.abbrev, chapter),
    );
    final chapterBmSig = context.select((ProgressService p) {
      final prefix = '${book.abbrev.toLowerCase()}:$chapter:';
      return p.bibleBookmarks.where((k) => k.startsWith(prefix)).join('|');
    });
    final progress = context.read<ProgressService>();
    final reading = BibleReadingStyle.resolve(a);
    final verses = book.chapters[chapter - 1];

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpace.md,
        topBar == null
            ? AppSpace.sm
            : MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
        AppSpace.md,
        scrollPaddingBelowNav(context),
      ),
      children: [
        if (topBar != null) ...[
          topBar!,
          const SizedBox(height: AppSpace.afterTopBar),
        ],
        // Página de leitura — contraste adaptado ao horário.
        Container(
          decoration: BoxDecoration(
            color: reading.page,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: reading.pageBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: reading.isDay ? 0.12 : 0.35,
                ),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.xl,
                  AppSpace.xl,
                  AppSpace.xl,
                  AppSpace.md,
                ),
                child: Column(
                  children: [
                    Text(
                      '${book.name} $chapter',
                      textAlign: TextAlign.center,
                      style: reading.titleStyle,
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      BibleService.translationName,
                      textAlign: TextAlign.center,
                      style: reading.metaStyle.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),
                    // Conforto: tamanho do texto.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FontChip(
                          label: 'A−',
                          enabled: fontScale > 0.86,
                          reading: reading,
                          onTap: () => _adjustFont(context, -0.1),
                        ),
                        const SizedBox(width: AppSpace.sm),
                        _FontChip(
                          label: 'A+',
                          enabled: fontScale < 1.34,
                          reading: reading,
                          onTap: () => _adjustFont(context, 0.1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
                color: reading.pageBorder.withValues(alpha: 0.7),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.xl,
                  AppSpace.lg,
                  AppSpace.xl,
                  AppSpace.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(verses.length, (i) {
                    final n = i + 1;
                    final hl = _highlighted(n);
                    final bmKey = ProgressService.bibleBookmarkKey(
                      book.abbrev,
                      chapter,
                      n,
                    );
                    final saved = '|$chapterBmSig|'.contains('|$bmKey|');
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _verseActions(
                          context,
                          progress: progress,
                          reading: reading,
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
                          reading: reading,
                          book: book,
                          bookIndex: bookIndex,
                          chapter: chapter,
                          verse: n,
                          text: verses[i],
                          onOpenVerse: onOpenVerse,
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(
                            bottom: i == verses.length - 1 ? 0 : AppSpace.lg,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpace.sm,
                            vertical: AppSpace.sm,
                          ),
                          decoration: hl
                              ? BoxDecoration(
                                  color: reading.highlightFill,
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.sm,
                                  ),
                                  border: Border.all(
                                    color: reading.highlightBorder,
                                  ),
                                )
                              : saved
                              ? BoxDecoration(
                                  color: reading.savedFill,
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.sm,
                                  ),
                                )
                              : null,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 30,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text('$n', style: reading.numberStyle),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  verses[i],
                                  style: reading.verseStyle,
                                ),
                              ),
                              if (saved)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: AppSpace.xs,
                                    top: 4,
                                  ),
                                  child: CinematicIcon(
                                    glyph: CinematicGlyph.star,
                                    size: 14,
                                    accent: reading.verseNumber,
                                    framed: false,
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
            ],
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        Row(
          children: [
            if (chapter > 1 && onChangeChapter != null)
              Expanded(
                child: _NavChip(
                  label: '← Cap. ${chapter - 1}',
                  onTap: () => onChangeChapter!(chapter - 1),
                  reading: reading,
                ),
              ),
            if (chapter > 1 && onChangeChapter != null)
              const SizedBox(width: AppSpace.sm),
            if (chapter < book.chapters.length && onChangeChapter != null)
              Expanded(
                child: _NavChip(
                  label: 'Cap. ${chapter + 1} →',
                  onTap: () => onChangeChapter!(chapter + 1),
                  reading: reading,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpace.md),
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
            padding: const EdgeInsets.symmetric(vertical: AppSpace.lg),
            decoration: BoxDecoration(
              gradient: alreadyRead ? null : AppGradients.gold,
              color: alreadyRead ? reading.chipFill : null,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: alreadyRead
                  ? Border.all(color: reading.pageBorder)
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
                      ? reading.verseNumber
                      : AppColors.inkOnAccent,
                  glowing: false,
                  framed: false,
                ),
                const SizedBox(width: AppSpace.sm),
                Text(
                  alreadyRead ? 'CAPÍTULO LIDO' : 'AVANÇAR NA LEITURA',
                  style: AppTypography.cta(
                    size: 14,
                    color: alreadyRead
                        ? reading.verseNumber
                        : AppColors.inkOnAccent,
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

class _FontChip extends StatelessWidget {
  final String label;
  final bool enabled;
  final BibleReadingStyle reading;
  final VoidCallback onTap;

  const _FontChip({
    required this.label,
    required this.enabled,
    required this.reading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: reading.chipFill,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: reading.pageBorder),
        ),
        child: Text(
          label,
          style: AppTypography.title(
            size: 13,
            color: enabled
                ? reading.ink
                : reading.inkMuted.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final BibleReadingStyle? reading;

  const _NavChip({required this.label, required this.onTap, this.reading});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final fill = reading?.chipFill;
    final border = reading?.pageBorder ?? a.cardBorder;
    final ink = reading?.ink ?? a.text;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
        decoration: BoxDecoration(
          color: fill,
          gradient: fill == null ? a.cardGradient : null,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: border),
        ),
        child: Center(
          child: Text(label, style: AppTypography.title(size: 13, color: ink)),
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
