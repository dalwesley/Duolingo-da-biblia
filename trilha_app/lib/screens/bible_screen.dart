import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/bible_canonical_groups.dart';
import '../data/bible_chronology.dart';
import '../models/bible_reading_plan.dart';
import '../services/bible_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/liturgical_calendar.dart';
import '../widgets/act_feel.dart';
import '../widgets/bible_passage_picker.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/juntos_chrome.dart';
import '../widgets/relic_panel.dart';
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
/// Leitura: continuar, plano, tempo litúrgico e versículos guardados.
/// A leitura abre em tela cheia ([BibleReaderScreen]), por cima da barra de abas.
class BibleScreen extends StatefulWidget {
  final Widget? topBar;
  final String? initialBookAbbrev;

  const BibleScreen({super.key, this.topBar, this.initialBookAbbrev});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  List<BibleBook>? _books;
  bool _searching = false;
  final _searchCtrl = TextEditingController();
  List<BibleSearchHit> _hits = const [];
  bool _searchingBusy = false;
  String? _loadedTranslationId;
  bool _reloadScheduled = false;
  bool _openedInitialBook = false;
  Timer? _searchDebounce;
  int _searchGen = 0;

  /// 0 = livros. 1 = plano, tempo litúrgico e guardados.
  int _pane = 0;

  /// Seções fechadas: ot, nt, era:…, letra:…
  final Set<String> _closedSections = {};

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

  void _ensureTranslation(String id) {
    if (_loadedTranslationId == id || _reloadScheduled) return;
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
      title: 'Bíblia',
      subtitle: 'A Palavra, offline',
      leadingGlyph: CinematicGlyph.book,
      chromeAccent: AppColors.cedar,
      onBack: nav.canPop() ? () => nav.pop() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final translationId = context.select(
      (ProgressService p) => p.settings.bibleTranslationId,
    );
    _ensureTranslation(translationId);

    final books = _books;
    if (books == null) {
      return const AppSpinner(color: AppColors.cedar);
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
            title: 'Buscar',
            subtitle: 'Livros e versículos',
            onBack: _closeSearch,
            leadingGlyph: CinematicGlyph.book,
            chromeAccent: AppColors.cedar,
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
        const SizedBox(height: AppSpace.afterTopBar),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
          child: JuntosSegmentTabs(
            index: pane,
            onChanged: (i) {
              if (i == pane) return;
              ActHaptics.tap();
              onPane(i);
            },
            items: [
              (label: 'Bíblia', glyph: CinematicGlyph.book, alert: false),
              (label: 'Leitura', glyph: CinematicGlyph.path, alert: planDue),
            ],
          ),
        ),
        if (booksPane) ...[
          const SizedBox(height: AppSpace.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
            child: _SearchButton(onTap: onSearch),
          ),
          const SizedBox(height: AppSpace.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
            child: _OrderChips(order: order),
          ),
        ],
        const SizedBox(height: AppSpace.md),
        Expanded(
          child: ListView(
            key: ValueKey(pane),
            padding: EdgeInsets.fromLTRB(
              AppSpace.screen,
              0,
              AppSpace.screen,
              scrollPaddingBelowNav(context),
            ),
            children: booksPane ? _bookList(context, order) : _readingList(),
          ),
        ),
      ],
    );
  }

  List<Widget> _bookList(BuildContext context, BibleReadingOrder order) {
    return switch (order) {
      BibleReadingOrder.canonical => _canonical(context),
      BibleReadingOrder.chronological => _chronological(),
      BibleReadingOrder.alphabetical => _alphabetical(),
    };
  }

  List<Widget> _readingList() {
    return [
      _ContinueHero(books: books, onOpenReference: onOpenReference),
      const SizedBox(height: AppSpace.md),
      _SeasonVerseCard(onOpenReference: onOpenReference),
      const SizedBox(height: AppSpace.md),
      _PlanCard(onOpen: onOpenPlan),
      const SizedBox(height: AppSpace.xxl),
      const _SavedChapter(),
      const SizedBox(height: AppSpace.md),
      _SavedVerses(books: books, onOpenReference: onOpenReference),
    ];
  }

  List<Widget> _group(
    String id,
    String title,
    List<int> indices, {
    String? blurb,
    Color accent = AppColors.cedar,
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
    final accent = nt ? AppColors.accent : AppColors.sand;
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
                title: nt ? 'Novo Testamento' : 'Antigo Testamento',
                accent: accent,
                count: count,
                expanded: open,
                onToggle: () => onToggleSection(id),
              ),
              AnimatedSize(
                duration: motion
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
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
    final booksLabel = count == 1 ? '1 livro' : '$count livros';
    return Semantics(
      button: true,
      expanded: expanded,
      label: '$title, $booksLabel',
      hint: expanded ? 'Toque para fechar' : 'Toque para abrir',
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
                curve: Curves.easeOutCubic,
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
      label: 'Buscar livro ou versículo',
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
                const CinematicIcon(
                  glyph: CinematicGlyph.search,
                  size: 20,
                  accent: AppColors.sand,
                  framed: false,
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text(
                    'Buscar livro, versículo ou palavra…',
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
      tint: AppColors.cedar,
      radius: AppMetrics.heroRadius,
      onTap: () => onOpenReference(reference),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SectionLabel(
                  fresh ? 'Comece por aqui' : 'Continuar leitura',
                  color: AppColors.cedar,
                ),
              ),
              if (!fresh && read > 0)
                Text(
                  '$read de $total',
                  style: AppTypography.body(size: 12, color: a.textFaint),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            reference,
            style: AppTypography.display(size: 28, color: a.text),
          ),
          if (fresh) ...[
            const SizedBox(height: 4),
            Text(
              'Jesus, a Palavra que se fez carne — um bom primeiro passo.',
              style: AppTypography.body(size: 13, color: a.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpace.md),
          Container(
            padding: const EdgeInsets.only(left: AppSpace.md),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.cedar, width: 2),
              ),
            ),
            child: Text(
              preview,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.verse(
                size: 18,
                height: 1.4,
                weight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: a.text,
              ),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          if (!fresh && read > 0) ...[
            AppProgressBar(value: read / total, height: 6),
            const SizedBox(height: AppSpace.md),
          ],
          CopperCta(
            label: fresh ? 'Começar a ler' : 'Continuar',
            leading: CinematicGlyph.book,
            trailing: null,
            expanded: true,
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
    return JuntosSegmentTabs(
      index: index,
      onChanged: (i) {
        if (i == index) return;
        ActHaptics.tap();
        context
            .read<ProgressService>()
            .setBibleBrowseOrder(BibleReadingOrder.values[i]);
      },
      items: const [
        (label: 'Canônica', glyph: CinematicGlyph.book, alert: false),
        (label: 'Cronológica', glyph: CinematicGlyph.calendar, alert: false),
        (label: 'Alfabética', glyph: CinematicGlyph.stack, alert: false),
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
    final plan = context.select((ProgressService p) => p.bibleReadingPlan);
    final done = plan.active && plan.doneToday;
    final detail = !plan.active
        ? 'Canônico ou cronológico, no seu tempo'
        : done
        ? 'Leitura de hoje feita'
        : '${plan.minutesPerDay} min hoje · ${plan.order.shortLabel}';

    return GlassCard(
      tint: AppColors.cedar,
      onTap: onOpen,
      child: Row(
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.calendar,
            size: AppMetrics.leadingIcon,
            accent: AppColors.cedar,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.active ? 'Plano de leitura' : 'Criar um plano',
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
              size: 18,
              accent: AppColors.accent,
              framed: false,
            )
          else
            ListChevron(color: a.textFaint),
        ],
      ),
    );
  }
}

/// Palavra do tempo litúrgico — o texto em si, não só a referência.
class _SeasonVerseCard extends StatefulWidget {
  final ValueChanged<String> onOpenReference;

  const _SeasonVerseCard({required this.onOpenReference});

  @override
  State<_SeasonVerseCard> createState() => _SeasonVerseCardState();
}

class _SeasonVerseCardState extends State<_SeasonVerseCard> {
  Future<String?>? _text;
  String? _key;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final translationId = context.select(
      (ProgressService p) => p.settings.bibleTranslationId,
    );
    final moment = LiturgicalCalendar.momentFor();
    final accent = moment.season == LiturgicalSeason.ordinary
        ? AppColors.sand
        : LiturgicalCalendar.accentOf(moment.season);
    final key = '${moment.focusRef}|$translationId';
    if (_key != key) {
      _key = key;
      _text = BibleService.instance.passageText(moment.focusRef);
    }

    return GlassCard(
      tint: accent,
      onTap: () => widget.onOpenReference(moment.focusRef),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(moment.title, color: accent),
          const SizedBox(height: 2),
          Text(
            moment.subtitle,
            style: AppTypography.title(size: 14, color: a.textSecondary),
          ),
          const SizedBox(height: AppSpace.md),
          FutureBuilder<String?>(
            future: _text,
            builder: (context, snap) {
              final text = snap.data;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: Text(
                  text == null ? ' ' : '“${text.trim()}”',
                  key: ValueKey(text == null),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.verse(
                    size: 21,
                    height: 1.35,
                    weight: FontWeight.w600,
                    color: a.text,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpace.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  moment.focusRef,
                  style: AppTypography.label(size: 12, color: accent),
                ),
              ),
              Text(
                'Ler o capítulo',
                style: AppTypography.body(size: 12, color: a.textSecondary),
              ),
              const SizedBox(width: 2),
              ListChevron(color: a.textFaint, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavedChapter extends StatelessWidget {
  const _SavedChapter();

  @override
  Widget build(BuildContext context) {
    final count = context.select(
      (ProgressService p) => p.bibleBookmarks.length,
    );
    return RelicChapter(
      title: 'Guardados',
      accent: AppColors.accent,
      divided: false,
      trailing: count == 0
          ? null
          : CountBadge('$count', color: AppColors.accent, filled: false),
    );
  }
}

/// Versículos guardados, com o texto — toque abre no leitor.
class _SavedVerses extends StatelessWidget {
  final List<BibleBook> books;
  final ValueChanged<String> onOpenReference;

  const _SavedVerses({required this.books, required this.onOpenReference});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final marks = context.watch<ProgressService>().parseBookmarks();
    if (marks.isEmpty) {
      return const EmptyState(
        glyph: CinematicGlyph.bookmark,
        title: 'Nenhum versículo guardado',
        body:
            'Na leitura, toque num versículo e escolha Guardar '
            'para voltar a ele depois.',
        accent: AppColors.accent,
      );
    }

    final byAbbrev = {for (final b in books) b.abbrev.toLowerCase(): b};
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
      child: Column(
        children: [
          for (var i = 0; i < marks.length; i++) ...[
            if (i > 0) const ListDivider(),
            _SavedRow(
              mark: marks[i],
              book: byAbbrev[marks[i].abbrev],
              ink: a.text,
              chevron: a.textFaint,
              onOpen: onOpenReference,
            ),
          ],
        ],
      ),
    );
  }
}

class _SavedRow extends StatelessWidget {
  final ({String abbrev, int chapter, int verse}) mark;
  final BibleBook? book;
  final Color ink;
  final Color chevron;
  final ValueChanged<String> onOpen;

  const _SavedRow({
    required this.mark,
    required this.book,
    required this.ink,
    required this.chevron,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final name = book?.name ?? mark.abbrev.toUpperCase();
    String? text;
    final chapters = book?.chapters;
    if (chapters != null &&
        mark.chapter <= chapters.length &&
        mark.verse <= chapters[mark.chapter - 1].length) {
      text = chapters[mark.chapter - 1][mark.verse - 1];
    }
    final ref = '$name ${mark.chapter}:${mark.verse}';
    return InkWell(
      onTap: () => onOpen(ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref,
                    style: AppTypography.label(
                      size: 12,
                      color: AppColors.cedar,
                    ),
                  ),
                  if (text != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.verse(
                        size: 18,
                        height: 1.35,
                        weight: FontWeight.w500,
                        color: ink,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            ListChevron(color: chevron),
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
      cursorColor: AppColors.cedar,
      decoration: InputDecoration(
        hintText: 'Ex.: Apocalipse, amor, fé…',
        hintStyle: AppTypography.body(color: a.textFaint),
        filled: true,
        fillColor: a.cardFillSoft,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(AppSpace.md),
          child: CinematicIcon(
            glyph: CinematicGlyph.search,
            size: 22,
            accent: AppColors.sand,
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
          borderSide: const BorderSide(color: AppColors.cedar),
        ),
      ),
      onChanged: onChanged,
    );

    final results = ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpace.screen,
        AppSpace.lg,
        AppSpace.screen,
        scrollPaddingBelowNav(context),
      ),
      children: [
        if (busy)
          const Padding(
            padding: EdgeInsets.only(top: AppSpace.xxl),
            child: AppSpinner(color: AppColors.cedar),
          )
        else if (controller.text.trim().length >= 2 && hits.isEmpty)
          const EmptyState(
            glyph: CinematicGlyph.search,
            title: 'Nenhum resultado encontrado',
            accent: AppColors.cedar,
          )
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
                      h.isBook ? 'Livro' : h.citation,
                      style: AppTypography.label(
                        size: 12,
                        color: AppColors.cedar,
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
          child: searchField,
        ),
        Expanded(child: results),
      ],
    );
  }
}
