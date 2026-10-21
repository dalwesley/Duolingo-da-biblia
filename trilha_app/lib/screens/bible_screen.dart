import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/bible_canonical_groups.dart';
import '../data/bible_chronology.dart';
import '../data/guided_reading_plans.dart';
import '../l10n/app_language.dart';
import '../models/bible_reading_plan.dart';
import '../services/analytics_service.dart';
import '../services/bible_reading_plan_service.dart';
import '../services/bible_service.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/liturgical_calendar.dart';
import '../widgets/act_feel.dart';
import '../widgets/app_sheet.dart';
import '../widgets/bible_passage_picker.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/juntos_chrome.dart';
import '../widgets/relic_panel.dart';
import '../widgets/shell_tab_scope.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import 'bible_reader_screen.dart';
import 'bible_reading_plan_screen.dart';

export 'bible_reader_screen.dart' show BibleReaderScreen;

/// Nome dobrado para A–Z em português ("Êxodo" → e, "1 João" → joao).
({int ordinal, String key}) _bookSortParts(String name) {
  final trimmed = name.trim();
  final numbered = RegExp(r'^([123])\s+(.+)$').firstMatch(trimmed);
  final ordinal = numbered != null ? int.parse(numbered.group(1)!) : 0;
  final core = numbered != null ? numbered.group(2)! : trimmed;
  return (ordinal: ordinal, key: _foldPt(core));
}

int _compareBookName(String a, String b) {
  final pa = _bookSortParts(a);
  final pb = _bookSortParts(b);
  final byName = pa.key.compareTo(pb.key);
  if (byName != 0) return byName;
  return pa.ordinal.compareTo(pb.ordinal);
}

String _bookLetter(String name) {
  final key = _bookSortParts(name).key;
  if (key.isEmpty) return '#';
  return key[0].toUpperCase();
}

String _foldPt(String input) {
  const map = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'ñ': 'n',
  };
  final out = StringBuffer();
  for (final ch in input.toLowerCase().split('')) {
    out.write(map[ch] ?? ch);
  }
  return out.toString();
}

/// Aba Bíblia — duas faces. Bíblia: busca e livros, na ordem escolhida.
/// Leitura: continuar, plano e tempo litúrgico.
/// A leitura abre em tela cheia ([BibleReaderScreen]), por cima da barra de abas.
class BibleScreen extends StatefulWidget {
  final Widget? topBar;
  final String? initialBookAbbrev;

  const BibleScreen({super.key, this.topBar, this.initialBookAbbrev});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> with ShellTabFreezeMixin {
  List<BibleBook>? _books;
  bool _searching = false;
  final _searchCtrl = TextEditingController();
  List<BibleSearchHit> _hits = const [];
  bool _searchingBusy = false;
  String? _loadedTranslationId;
  bool _reloadScheduled = false;
  bool _loadFailed = false;
  bool _openedInitialBook = false;
  Timer? _searchDebounce;
  int _searchGen = 0;

  /// 0 = livros. 1 = plano e tempo litúrgico.
  int _pane = 0;

  /// Seções fechadas: ot, nt, era:…, letra:…
  final Set<String> _closedSections = {};

  @override
  void initState() {
    super.initState();
    debugPrint('[STWAY:Bible] screen init');
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
    debugPrint('[STWAY:Bible] screen load start id=$id');
    final List<BibleBook> books;
    try {
      await BibleService.instance.setTranslation(id);
      books = await BibleService.instance.books();
    } catch (e, st) {
      // Sem isto a falha some e a aba fica no spinner para sempre.
      debugPrint('[STWAY:Bible] screen load failed: $e\n$st');
      if (!mounted) return;
      setState(() {
        _loadFailed = true;
        _reloadScheduled = false;
      });
      return;
    }
    debugPrint(
      '[STWAY:Bible] screen load ok ${books.length} books mounted=$mounted',
    );
    if (!mounted) return;
    setState(() {
      _books = books;
      _loadedTranslationId = id;
      _reloadScheduled = false;
      _loadFailed = false;
    });
    if (_searching && _searchCtrl.text.trim().length >= 2) {
      _scheduleSearch(_searchCtrl.text);
    }
    final needle = widget.initialBookAbbrev?.toLowerCase();
    if (!_openedInitialBook && needle != null && needle.isNotEmpty) {
      _openedInitialBook = true;
      final i = books.indexWhere((b) => b.abbrev.toLowerCase() == needle);
      if (i >= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openBook(i);
        });
      }
    }
  }

  void _retryLoad() {
    setState(() => _loadFailed = false);
    _load();
  }

  void _ensureTranslation(String id) {
    if (_loadedTranslationId == id || _reloadScheduled || _loadFailed) return;
    _reloadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
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

  void _closeSearch() => setState(() {
    _searching = false;
    _searchCtrl.clear();
    _hits = const [];
  });

  void _openReference(String reference) =>
      BibleReaderScreen.open(context, reference);

  /// Livro → sheet de capítulos (com o resumo) → leitor.
  Future<void> _openBook(int bookIndex) async {
    final books = _books;
    if (books == null) return;
    final pick = await showBiblePassagePicker(
      context,
      books: books,
      bookIndex: bookIndex,
      showIntro: true,
    );
    if (pick == null || !mounted) return;
    _openReference('${books[pick.bookIndex].name} ${pick.chapter}');
  }

  void _openHit(BibleSearchHit hit) {
    FocusScope.of(context).unfocus();
    if (hit.isBook) {
      _openBook(hit.bookIndex);
    } else {
      _openReference('${hit.bookName} ${hit.chapter}:${hit.verse}');
    }
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
      title: context.l10n.bibleTitle,
      subtitle: LiturgicalCalendar.momentFor().subtitle,
      leadingGlyph: CinematicGlyph.book,
      onBack: nav.canPop() ? () => nav.pop() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return freezeTab(() => _buildBible(context));
  }

  Widget _buildBible(BuildContext context) {
    final translationId = context.select(
      (ProgressService p) => p.settings.bibleTranslationId,
    );
    _ensureTranslation(translationId);

    final books = _books;
    if (books == null) {
      if (!_loadFailed) return const AppSpinner();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpace.screen,
              MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
              AppSpace.screen,
              0,
            ),
            child: _rootTopBar(),
          ),
          Expanded(
            child: Center(
              child: EmptyState(
                mark: const CloudMascot(face: CloudFace.erro, size: 120),
                title: context.l10n.bibleLoadError,
                action: TextCta(
                  label: context.l10n.commonTryAgain,
                  onTap: _retryLoad,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_searching) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _closeSearch();
        },
        child: _SearchPane(
          topBar: TopBar(
            inline: true,
            immersive: true,
            dark: Appearance.of(context).onDark,
            title: context.l10n.bibleSearchTitle,
            subtitle: context.l10n.bibleSearchSubtitle,
            onBack: _closeSearch,
            leadingGlyph: CinematicGlyph.book,
          ),
          controller: _searchCtrl,
          hits: _hits,
          busy: _searchingBusy,
          onChanged: _scheduleSearch,
          onClose: _closeSearch,
          onOpen: _openHit,
        ),
      );
    }

    return _BibleLibrary(
      topBar: _rootTopBar(),
      books: books,
      pane: _pane,
      onPane: (i) => setState(() => _pane = i),
      onSearch: () => setState(() => _searching = true),
      onOpenReference: _openReference,
      onOpenBook: _openBook,
      onOpenPlan: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const BibleReadingPlanScreen()),
      ),
      closedSections: _closedSections,
      onToggleSection: (id) {
        ActHaptics.tap();
        setState(() {
          if (!_closedSections.add(id)) _closedSections.remove(id);
        });
      },
    );
  }
}

class _BibleLibrary extends StatelessWidget {
  final Widget topBar;
  final List<BibleBook> books;
  final int pane;
  final ValueChanged<int> onPane;
  final VoidCallback onSearch;
  final ValueChanged<String> onOpenReference;
  final ValueChanged<int> onOpenBook;
  final VoidCallback onOpenPlan;
  final Set<String> closedSections;
  final ValueChanged<String> onToggleSection;

  const _BibleLibrary({
    required this.topBar,
    required this.books,
    required this.pane,
    required this.onPane,
    required this.onSearch,
    required this.onOpenReference,
    required this.onOpenBook,
    required this.onOpenPlan,
    required this.closedSections,
    required this.onToggleSection,
  });

  bool _sectionOpen(String id) => !closedSections.contains(id);

  @override
  Widget build(BuildContext context) {
    final order = context.select((ProgressService p) => p.bibleBrowseOrder);
    final planDue = context.select((ProgressService p) {
      final plan = p.bibleReadingPlan;
      return plan.active && !plan.doneToday;
    });
    final topPad = MediaQuery.viewPaddingOf(context).top + AppSpace.sm;
    final booksPane = pane == 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = AppSpace.screen + contentGutterOf(constraints.maxWidth);
        final a = Appearance.of(context);
        final fixed = topBarStaysFixed(topBar);
        final library = <Widget>[
          AppSegmentedTabs(
            index: pane,
            accent: AppRoles.presence,
            fill: a.cardFill,
            onChanged: (i) {
              if (i == pane) return;
              ActHaptics.tap();
              onPane(i);
            },
            items: [
              (
                label: context.l10n.bibleTitle,
                glyph: CinematicGlyph.book,
                mark: null,
                alert: false,
              ),
              (
                label: context.l10n.bibleTabReading,
                glyph: CinematicGlyph.calendar,
                mark: null,
                alert: planDue,
              ),
            ],
          ),
          if (booksPane) ...[
            const SizedBox(height: AppSpace.md),
            _SearchButton(onTap: onSearch),
            const SizedBox(height: AppSpace.md),
            // Navegação livre: retoma de onde parou no leitor.
            _ContinueHero(books: books, onOpenReference: onOpenReference),
            const SizedBox(height: AppSpace.md),
            _OrderChips(order: order),
          ],
          const SizedBox(height: AppSpace.md),
          ...booksPane ? _bookList(context, order) : _readingList(),
        ];
        // Voltar (Bíblia aberta por cima) fica preso. Na aba, a barra sobe.
        if (fixed) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpace.screen,
                  topPad,
                  AppSpace.screen,
                  0,
                ),
                child: topBar,
              ),
              Expanded(
                child: ListView(
                  key: ValueKey(pane),
                  padding: EdgeInsets.fromLTRB(
                    side,
                    AppSpace.afterTopBar,
                    side,
                    scrollPaddingBelowNav(context),
                  ),
                  children: library,
                ),
              ),
            ],
          );
        }
        return ListView(
          key: ValueKey(pane),
          padding: EdgeInsets.fromLTRB(
            0,
            topPad,
            0,
            scrollPaddingBelowNav(context),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
              child: topBar,
            ),
            const SizedBox(height: AppSpace.afterTopBar),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: side),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: library,
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _bookList(BuildContext context, BibleReadingOrder order) {
    return switch (order) {
      BibleReadingOrder.canonical => _canonical(context),
      BibleReadingOrder.chronological => _chronological(),
      BibleReadingOrder.alphabetical => _alphabetical(),
    };
  }

  /// Planos (Peregrino+, com dias grátis): o plano ativo e o catálogo.
  List<Widget> _readingList() {
    return [_PlanCard(onOpen: onOpenPlan), const _PlansCatalog()];
  }

  List<Widget> _group(
    String id,
    String title,
    List<int> indices, {
    String? blurb,
    Color? accent,
  }) {
    return [
      const SizedBox(height: AppSpace.lg),
      BibleBookList(
        title: title,
        blurb: blurb,
        accent: accent,
        books: books,
        indices: indices,
        onPick: onOpenBook,
        expanded: _sectionOpen(id),
        onToggle: () => onToggleSection(id),
      ),
    ];
  }

  List<Widget> _canonical(BuildContext context) {
    return [
      for (final nt in const [false, true]) _testament(context, nt),
    ];
  }

  Widget _testament(BuildContext context, bool nt) {
    const otEnd = BibleService.oldTestamentCount;
    final accent = Appearance.of(context).chrome;
    final id = nt ? 'nt' : 'ot';
    final open = _sectionOpen(id);
    final groups = [
      for (final g in BibleCanonicalGroups.groups)
        if ((g.startIndex >= otEnd) == nt && g.startIndex < books.length) g,
    ];
    final count = groups.fold<int>(0, (n, g) {
      final end = g.endIndex.clamp(0, books.length - 1);
      return n + (end - g.startIndex + 1);
    });
    final motion = MediaQuery.disableAnimationsOf(context);
    return Padding(
      padding: EdgeInsets.only(top: nt ? AppSpace.xxl : AppSpace.sm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppMetrics.cardRadius),
        child: GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FoldHeader(
                title: nt
                    ? context.l10n.bibleNewTestament
                    : context.l10n.bibleOldTestament,
                accent: accent,
                count: count,
                expanded: open,
                onToggle: () => onToggleSection(id),
              ),
              AnimatedSize(
                duration: motion
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                curve: AppMotion.enter,
                alignment: Alignment.topCenter,
                child: open
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const ListDivider(),
                          for (var n = 0; n < groups.length; n++) ...[
                            if (n > 0) ...[
                              const SizedBox(height: AppSpace.sm),
                              const ListDivider(),
                            ],
                            BibleBookList(
                              framed: false,
                              title: groups[n].title,
                              blurb: groups[n].blurb,
                              accent: accent,
                              books: books,
                              indices: [
                                for (
                                  var i = groups[n].startIndex;
                                  i <=
                                      groups[n].endIndex.clamp(
                                        0,
                                        books.length - 1,
                                      );
                                  i++
                                )
                                  i,
                              ],
                              onPick: onOpenBook,
                            ),
                          ],
                        ],
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _chronological() {
    final ordered = BibleChronology.chronologicalIndices([
      for (final b in books) (abbrev: b.abbrev, name: b.name),
    ]);
    final byEra = <String, List<int>>{};
    for (final e in ordered) {
      byEra.putIfAbsent(e.eraId, () => []).add(e.bookIndex);
    }
    return [
      for (final era in BibleChronology.eras)
        if (byEra[era.id]?.isNotEmpty ?? false)
          ..._group(
            'era:${era.id}',
            era.title,
            byEra[era.id]!,
            blurb: era.blurb,
          ),
    ];
  }

  List<Widget> _alphabetical() {
    final sorted = [for (var i = 0; i < books.length; i++) i]
      ..sort((a, b) => _compareBookName(books[a].name, books[b].name));
    final byLetter = <String, List<int>>{};
    for (final i in sorted) {
      byLetter.putIfAbsent(_bookLetter(books[i].name), () => []).add(i);
    }
    final letters = byLetter.keys.toList()..sort();
    return [for (final l in letters) ..._group('letra:$l', l, byLetter[l]!)];
  }
}

/// Cabeçalho de testamento — fecha o bloco inteiro, sem rolar livro a livro.
class _FoldHeader extends StatelessWidget {
  final String title;
  final Color accent;
  final int count;
  final bool expanded;
  final VoidCallback onToggle;

  const _FoldHeader({
    required this.title,
    required this.accent,
    required this.count,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final motion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      expanded: expanded,
      label: context.l10n.bibleSectionBooksSemantics(title, count),
      hint: expanded
          ? context.l10n.bibleTapToClose
          : context.l10n.bibleTapToOpen,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpace.lg,
              AppSpace.lg,
              AppSpace.lg,
              expanded ? AppSpace.md : AppSpace.lg,
            ),
            child: RelicChapter(
              title: title,
              accent: accent,
              divided: false,
              trailing: CountBadge('$count', color: accent, filled: false),
              action: AnimatedRotation(
                turns: expanded ? 0.25 : 0,
                duration: motion
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                curve: AppMotion.enter,
                child: ListChevron(color: a.textFaint),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Semantics(
      button: true,
      label: context.l10n.bibleSearchButtonSemantics,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: Ink(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.lg,
              vertical: AppSpace.md,
            ),
            decoration: BoxDecoration(
              color: a.cardFillSoft,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: a.cardBorder),
            ),
            child: Row(
              children: [
                CinematicIcon(
                  glyph: CinematicGlyph.search,
                  size: AppMetrics.iconMd,
                  accent: a.textSecondary,
                  framed: false,
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text(
                    context.l10n.bibleSearchButtonHint,
                    style: AppTypography.body(size: 14, color: a.textFaint),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Herói — onde a leitura parou, com o primeiro versículo à vista.
/// Sem histórico, convida a começar pelo Evangelho de João.
class _ContinueHero extends StatelessWidget {
  final List<BibleBook> books;
  final ValueChanged<String> onOpenReference;

  const _ContinueHero({required this.books, required this.onOpenReference});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final spot = context.select((ProgressService p) => p.lastBibleSpotParts);
    var bookIndex = -1;
    var chapter = 1;
    if (spot != null) {
      bookIndex = books.indexWhere(
        (b) => b.abbrev.toLowerCase() == spot.abbrev,
      );
      chapter = spot.chapter;
    }
    final fresh = bookIndex < 0;
    if (fresh) {
      bookIndex = books.indexWhere((b) => b.abbrev.toLowerCase() == 'jo');
      if (bookIndex < 0) bookIndex = 0;
      chapter = 1;
    }
    final book = books[bookIndex];
    chapter = chapter.clamp(1, book.chapters.length);
    final preview = book.chapters[chapter - 1].first;
    final total = book.chapters.length;
    final read = context.select(
      (ProgressService p) => p.readChaptersInBook(book.abbrev),
    );
    final reference = '${book.name} $chapter';

    return GlassCard(
      radius: AppMetrics.heroRadius,
      onTap: () => onOpenReference(reference),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SectionLabel(
                  fresh
                      ? context.l10n.bibleHeroStartHere
                      : context.l10n.bibleHeroContinueReading,
                  color: a.sectionLabel,
                ),
              ),
              if (!fresh && read > 0)
                Text(
                  context.l10n.bibleReadOf(read, total),
                  style: AppTypography.body(size: 12, color: a.textFaint),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            reference,
            style: AppTypography.display(size: 24, color: a.text),
          ),
          if (fresh) ...[
            const SizedBox(height: 4),
            Text(
              context.l10n.bibleHeroFreshBlurb,
              style: AppTypography.body(size: 13, color: a.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpace.sm),
          Container(
            padding: const EdgeInsets.only(left: AppSpace.md),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: a.chrome, width: 2)),
            ),
            child: Text(
              preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.verse(
                size: 16,
                height: 1.4,
                weight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: a.text,
              ),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          if (!fresh && read > 0) ...[
            AppProgressBar(
              value: read / total,
              height: 4,
              color: AppRoles.success,
            ),
            const SizedBox(height: AppSpace.md),
          ],
          CopperCta(
            label: fresh
                ? context.l10n.bibleHeroStartReading
                : context.l10n.commonContinue,
            leading: CinematicGlyph.book,
            trailing: null,
            expanded: true,
            dense: true,
            onTap: () => onOpenReference(reference),
          ),
        ],
      ),
    );
  }
}

/// Canônica, cronológica ou alfabética — fica fixo acima da lista.
class _OrderChips extends StatelessWidget {
  final BibleReadingOrder order;

  const _OrderChips({required this.order});

  @override
  Widget build(BuildContext context) {
    final index = BibleReadingOrder.values.indexOf(order);
    final a = Appearance.of(context);
    return AppSegmentedTabs(
      index: index,
      accent: AppRoles.presence,
      // Na arte da trilha o poço translúcido deixa a onda atravessar o texto.
      fill: a.cardFill,
      onChanged: (i) {
        if (i == index) return;
        ActHaptics.tap();
        context.read<ProgressService>().setBibleBrowseOrder(
          BibleReadingOrder.values[i],
        );
      },
      items: [
        (
          label: context.l10n.planOrderCanonicalShort,
          glyph: CinematicGlyph.book,
          mark: null,
          alert: false,
        ),
        (
          label: context.l10n.planOrderChronologicalShort,
          glyph: CinematicGlyph.calendar,
          mark: null,
          alert: false,
        ),
        (
          label: context.l10n.planOrderAlphabeticalShort,
          glyph: CinematicGlyph.stack,
          mark: null,
          alert: false,
        ),
      ],
    );
  }
}

/// Plano de leitura — card inteiro, na aba Leitura.
class _PlanCard extends StatelessWidget {
  final VoidCallback onOpen;

  const _PlanCard({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final plan = context.select((ProgressService p) => p.bibleReadingPlan);
    final plusOpen = context.select(
      (SubscriptionService s) => s.plusFeaturesOpen,
    );
    if (!plan.active) return const SizedBox.shrink();
    final guided = GuidedReadingPlan.byId(plan.guidedId);
    final done = plan.doneToday;
    final locked = plan.lockedToday(plusOpen: plusOpen);
    final detail = done
        ? l10n.planCardDoneToday
        : locked
        ? l10n.paywallTitle
        : guided != null
        ? l10n.guidedPlanDayOf(
            (plan.cursor + 1).clamp(1, guided.days),
            guided.days,
          )
        : l10n.planCardToday(plan.minutesPerDay, plan.order.shortLabel);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.md),
      child: GlassCard(
        onTap: onOpen,
        child: Row(
          children: [
            CinematicIcon(
              glyph: CinematicGlyph.calendar,
              size: AppMetrics.leadingIcon,
              accent: a.chrome,
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionLabel(l10n.commonToday),
                  const SizedBox(height: 2),
                  Text(
                    guided?.title(l10n) ?? l10n.plansWholeBibleTitle,
                    style: AppTypography.title(size: 16, color: a.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: AppTypography.body(size: 13, color: a.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            if (done)
              const CinematicIcon(
                glyph: CinematicGlyph.check,
                size: AppMetrics.iconMd,
                accent: AppRoles.success,
                framed: false,
              )
            else if (locked)
              const CinematicIcon(
                glyph: CinematicGlyph.lock,
                size: AppMetrics.iconMd,
                accent: AppRoles.reward,
                framed: false,
              )
            else
              ListChevron(color: a.textFaint),
          ],
        ),
      ),
    );
  }
}

/// Catálogo de planos: a Bíblia inteira (grátis, sempre) e os guiados
/// (3 dias grátis, depois Peregrino+). O plano em andamento leva "Ativo".
class _PlansCatalog extends StatefulWidget {
  const _PlansCatalog();

  @override
  State<_PlansCatalog> createState() => _PlansCatalogState();
}

class _PlansCatalogState extends State<_PlansCatalog> {
  Map<String, double> _minutes = const {};

  @override
  void initState() {
    super.initState();
    _loadMinutes();
  }

  Future<void> _loadMinutes() async {
    final out = <String, double>{
      for (final def in GuidedReadingPlan.all)
        def.id: await BibleReadingPlanService.instance.guidedMinutesPerDay(def),
    };
    if (mounted) setState(() => _minutes = out);
  }

  Future<void> _openPlan({bool setup = false}) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BibleReadingPlanScreen(setup: setup),
    ),
  );

  Future<void> _tapWholeBible(BibleReadingPlan plan) async {
    if (plan.active && !plan.isGuided) return _openPlan();
    // Troca é confirmada na própria tela, ao começar.
    await _openPlan(setup: plan.active);
  }

  Future<void> _tapGuided(BibleReadingPlan plan, GuidedReadingPlan def) async {
    if (plan.active && plan.guidedId == def.id) return _openPlan();
    final progress = context.read<ProgressService>();
    final sub = context.read<SubscriptionService>();
    AnalyticsService.instance.logPlusFeatureOpen(
      feature: 'guided_plan',
      hasPlus: sub.hasPlus,
    );
    // Sem Plus, começa igual: os primeiros dias do guiado são grátis
    // (BibleReadingPlan.guidedFreeDays). A trava aparece no dia seguinte
    // ao fim da amostra, dentro do plano — não na porta.
    if (plan.active) {
      final ok = await showAppConfirm(
        context,
        title: context.l10n.planSwitchTitle,
        body: context.l10n.planSwitchBody,
        confirmLabel: context.l10n.modeSwitch,
      );
      if (!ok || !mounted) return;
    }
    await progress.startGuidedReadingPlan(def.id);
    if (mounted) await _openPlan();
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final plan = context.select((ProgressService p) => p.bibleReadingPlan);
    final sub = context.watch<SubscriptionService>();

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.md,
        AppSpace.md,
        AppSpace.md,
        AppSpace.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            label: l10n.plansCatalogHeader,
            glyph: CinematicGlyph.calendar,
            trailing: sub.showsPlus
                ? SoftBadge(
                    text: l10n.paywallTitle,
                    glyph: CinematicGlyph.plus,
                    accent: AppRoles.reward,
                  )
                : null,
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            sub.plusFeaturesOpen
                ? l10n.plansCatalogBody
                : l10n.plansGuidedPlusNote,
            style: AppTypography.body(
              size: 13,
              height: 1.4,
              color: a.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          _CatalogRow(
            title: l10n.plansWholeBibleTitle,
            subtitle: l10n.planCardIdle,
            active: plan.active && !plan.isGuided,
            onTap: () => _tapWholeBible(plan),
          ),
          for (final def in GuidedReadingPlan.all) ...[
            const ListDivider(),
            _CatalogRow(
              title: def.title(l10n),
              subtitle: _minutes[def.id] == null
                  ? def.subtitle(l10n)
                  : l10n.guidedPlanMeta(
                      def.subtitle(l10n),
                      _minutes[def.id]!.round().clamp(1, 120),
                    ),
              active: plan.active && plan.guidedId == def.id,
              // Cadeado só no plano ativo com a amostra já usada: os
              // demais começam grátis, então a seta é o convite certo.
              locked:
                  !sub.plusFeaturesOpen &&
                  plan.active &&
                  plan.guidedId == def.id &&
                  plan.lockedToday(plusOpen: sub.plusFeaturesOpen),
              onTap: () => _tapGuided(plan, def),
            ),
          ],
        ],
      ),
    );
  }
}

class _CatalogRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool active;

  /// Guiado sem Peregrino+: cadeado no lugar da seta.
  final bool locked;
  final VoidCallback onTap;

  const _CatalogRow({
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onTap,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.title(size: 15, color: a.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.body(size: 12, color: a.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            if (active)
              SoftBadge(
                text: context.l10n.commonActive,
                accent: AppRoles.success,
              )
            else if (locked)
              CinematicIcon(
                glyph: CinematicGlyph.lock,
                size: AppMetrics.iconMd,
                accent: a.textFaint,
                framed: false,
              )
            else
              ListChevron(color: a.textFaint),
          ],
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
    final a = Appearance.of(context);
    final topPad = topBar == null
        ? AppSpace.sm
        : MediaQuery.viewPaddingOf(context).top + AppSpace.sm;

    final searchField = TextField(
      controller: controller,
      autofocus: true,
      style: AppTypography.body(
        size: 14,
        weight: FontWeight.w600,
        color: a.text,
      ),
      cursorColor: a.text,
      decoration: InputDecoration(
        hintText: context.l10n.bibleSearchFieldHint,
        hintStyle: AppTypography.body(color: a.textFaint),
        filled: true,
        fillColor: a.cardFillSoft,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(AppSpace.md),
          child: CinematicIcon(
            glyph: CinematicGlyph.search,
            size: AppMetrics.iconLg,
            accent: a.textSecondary,
            framed: false,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: a.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: a.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: a.selected),
        ),
      ),
      onChanged: onChanged,
    );

    final results = ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpace.screen + contentGutterOf(MediaQuery.sizeOf(context).width),
        AppSpace.lg,
        AppSpace.screen + contentGutterOf(MediaQuery.sizeOf(context).width),
        scrollPaddingBelowNav(context),
      ),
      children: [
        if (busy)
          const Padding(
            padding: EdgeInsets.only(top: AppSpace.xxl),
            child: AppSpinner(),
          )
        else if (controller.text.trim().length >= 2 && hits.isEmpty)
          EmptyState(title: context.l10n.bibleSearchEmpty)
        else
          ...hits.map((h) {
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
                      h.isBook ? context.l10n.bibleSearchBookHit : h.citation,
                      style: AppTypography.label(
                        size: 12,
                        color: a.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      h.isBook ? h.bookName : h.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.display(
                        size: 18,
                        height: 1.35,
                        weight: FontWeight.w600,
                        color: a.text,
                      ),
                    ),
                    if (h.isBook) ...[
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        h.text,
                        style: AppTypography.body(
                          size: 13,
                          color: a.textSecondary,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (topBar != null) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpace.screen,
              topPad,
              AppSpace.screen,
              0,
            ),
            child: topBar!,
          ),
          const SizedBox(height: AppSpace.afterTopBar),
        ] else
          SizedBox(height: topPad),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal:
                AppSpace.screen +
                contentGutterOf(MediaQuery.sizeOf(context).width),
          ),
          child: searchField,
        ),
        Expanded(child: results),
      ],
    );
  }
}
