import 'dart:async';
import 'dart:math' as math;

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
import '../widgets/app_nav_row.dart';
import '../widgets/app_sheet.dart';
import '../widgets/bible_passage_picker.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/juntos_chrome.dart';
import '../widgets/profile_section.dart';
import '../widgets/relic_panel.dart';
import '../widgets/shell_tab_scope.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import 'bible_reader_screen.dart';
import 'bible_reading_plan_screen.dart';
import 'coming_soon_screen.dart';

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
  /// Barra de quem abriu a Bíblia (aba do shell, Hoje). Recebe a lupa para
  /// pôr à direita; sem ele, a tela monta a própria barra.
  final Widget Function(Widget searchAction)? topBarBuilder;
  final String? initialBookAbbrev;

  const BibleScreen({super.key, this.topBarBuilder, this.initialBookAbbrev});

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
      _loadedTranslationId = BibleService.instance.translationId;
      _reloadScheduled = false;
      _loadFailed = false;
    });
    // Quem já tinha lido livros inteiros ganha o selo (sem festa).
    unawaited(
      context.read<ProgressService>().backfillFinishedBooks([
        for (final b in books) (abbrev: b.abbrev, chapters: b.chapters.length),
      ]),
    );
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
      _searchGen++;
      setState(() {
        _hits = const [];
        _searchingBusy = false;
      });
      return;
    }
    setState(() => _searchingBusy = true);
    final gen = ++_searchGen;
    _searchDebounce = Timer(const Duration(milliseconds: 280), () async {
      List<BibleSearchHit> hits;
      try {
        hits = await BibleService.instance.search(trimmed);
      } catch (e) {
        // Sem isto o spinner da busca girava para sempre.
        debugPrint('[STWAY:Bible] search failed: $e');
        hits = const [];
      }
      if (!mounted || gen != _searchGen) return;
      setState(() {
        _hits = hits;
        _searchingBusy = false;
      });
    });
  }

  void _closeSearch() {
    // Busca pendente não pode repovoar a lista depois de fechar.
    _searchDebounce?.cancel();
    _searchGen++;
    setState(() {
      _searching = false;
      _searchCtrl.clear();
      _hits = const [];
      _searchingBusy = false;
    });
  }

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
    final search = _searchAction();
    if (widget.topBarBuilder != null) return widget.topBarBuilder!(search);
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
      trailing: search,
    );
  }

  /// Lupa da barra do topo: abre a busca da Bíblia.
  Widget _searchAction() {
    final a = Appearance.of(context);
    return IconButton(
      tooltip: context.l10n.bibleSearchButtonSemantics,
      onPressed: () {
        ActHaptics.tap();
        setState(() => _searching = true);
      },
      icon: CinematicIcon(
        glyph: CinematicGlyph.search,
        size: AppMetrics.iconMd,
        accent: a.textSecondary,
        framed: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return freezeTab(() => _buildBible(context));
  }

  Widget _buildBible(BuildContext context) {
    // Escolha salva + idioma do app (EN abre BSB, ES abre BES).
    final translationId = BibleService.effectiveId(
      context.select((ProgressService p) => p.settings.bibleTranslationId),
      context.l10n.localeName,
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

            // Navegação livre: retoma de onde parou no leitor.
            _ContinueHero(books: books, onOpenReference: onOpenReference),
            const SizedBox(height: AppSpace.md),
            // Atlas em uma linha só; a estante mora em cada testamento.
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
              child: const _ExploreSoonRow(),
            ),
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
    bool first = false,
  }) {
    return [
      // Mesmo respiro curto entre cards de todas as ordens.
      if (!first) const SizedBox(height: AppSpace.sm),
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
    // AT quente, NT frio — a mesma família das cores de gênero abaixo.
    final look = Appearance.of(context);
    final hue = nt ? AppColors.cedar : AppColors.sand;
    final accent = look.onDark ? hue : look.ink(hue);
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
    final start = nt ? otEnd : 0;
    final end = nt ? books.length : math.min(otEnd, books.length);
    final progress = context.watch<ProgressService>();
    var chapters = 0;
    var read = 0;
    for (var i = start; i < end; i++) {
      final n = books[i].chapters.length;
      chapters += n;
      read += progress.readChaptersInBook(books[i].abbrev).clamp(0, n).toInt();
    }
    return Padding(
      // Mesmo respiro entre todos os blocos da aba (AppSpace.md).
      padding: EdgeInsets.only(top: nt ? AppSpace.sm : 0),
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
                whisper: context.l10n.bibleShelfChapters(read, chapters),
                expanded: open,
                onToggle: () => onToggleSection(id),
              ),
              // Estante do testamento: fica visível mesmo fechado.
              _BibleShelf(books: books, start: start, end: end),
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
            first:
                era.id ==
                BibleChronology.eras
                    .firstWhere((e) => byEra[e.id]?.isNotEmpty ?? false)
                    .id,
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
    return [
      for (final l in letters)
        ..._group('letra:$l', l, byLetter[l]!, first: l == letters.first),
    ];
  }
}

/// Cabeçalho de testamento — fecha o bloco inteiro, sem rolar livro a livro.
class _FoldHeader extends StatelessWidget {
  final String title;
  final Color accent;
  final int count;
  final String? whisper;
  final bool expanded;
  final VoidCallback onToggle;

  const _FoldHeader({
    required this.title,
    required this.accent,
    required this.count,
    this.whisper,
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
            padding: const EdgeInsets.fromLTRB(
              AppSpace.lg,
              AppSpace.md,
              AppSpace.lg,
              AppSpace.sm,
            ),
            // Contagem colada ao título; selo e seta centrados no bloco.
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RelicChapter(
                        title: title,
                        accent: accent,
                        divided: false,
                      ),
                      if (whisper != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 13),
                          child: Text(
                            whisper!,
                            style: AppTypography.body(
                              size: 12,
                              height: 1.2,
                              color: a.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                CountBadge('$count', color: accent, filled: false),
                AnimatedRotation(
                  turns: expanded ? 0.25 : 0,
                  duration: motion
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  curve: AppMotion.enter,
                  child: ListChevron(color: a.textFaint),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Linha do tempo, mapas e personagens ainda não existem: a linha abre o
/// aviso e mede qual ferramenta interessa.
class _ExploreSoonRow extends StatelessWidget {
  const _ExploreSoonRow();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    // Rodapé da estante: uma linha só, sem card próprio.
    return InkWell(
      onTap: () {
        ActHaptics.tap();
        openComingSoon(context, ComingSoonFeature.explore, source: 'bible');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
        child: Row(
          children: [
            CinematicIcon(
              glyph: CinematicGlyph.hourglass,
              size: AppMetrics.iconSm,
              accent: a.place,
              framed: false,
            ),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: Text(
                context.l10n.exploreSoonEntryTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body(size: 13, color: a.textSecondary),
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            Text(
              context.l10n.exploreSoonEntryBadge.toUpperCase(),
              style: AppTypography.body(
                size: 10,
                weight: FontWeight.w800,
                color: AppRoles.reward,
              ),
            ),
            const SizedBox(width: 2),
            ListChevron(color: a.textFaint, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Herói — onde a leitura parou.
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
    final total = book.chapters.length;
    final read = context.select(
      (ProgressService p) => p.readChaptersInBook(book.abbrev),
    );
    final reference = '${book.name} $chapter';
    final verses = book.chapters.isEmpty
        ? const <String>[]
        : book.chapters[chapter - 1];
    final opening = verses.isEmpty ? '' : verses.first.trim();

    // Lâmpada acesa: o card inteiro é o convite — sem botão dentro.
    const tone = AppRoles.lamp;
    return GlassCard(
      radius: AppMetrics.heroRadius,
      glow: 1,
      tint: tone,
      color: Color.lerp(a.cardFill, tone, a.onDark ? 0.2 : 0.14),
      onTap: () => onOpenReference(reference),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardHeader(
                label: fresh
                    ? context.l10n.bibleHeroStartHere
                    : context.l10n.bibleHeroContinueReading,
                accent: tone,
                trailing: !fresh && read > 0
                    ? Text(
                        context.l10n.bibleReadOf(read, total),
                        style: AppTypography.body(size: 12, color: a.textFaint),
                      )
                    : null,
              ),
              const SizedBox(height: AppSpace.xs),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      reference,
                      style: AppTypography.display(size: 24, color: a.text),
                    ),
                  ),
                  const ListChevron(color: tone, size: 22),
                ],
              ),
              if (fresh) ...[
                const SizedBox(height: 4),
                Text(
                  context.l10n.bibleHeroFreshBlurb,
                  style: AppTypography.body(size: 13, color: a.textSecondary),
                ),
              ] else if (opening.isNotEmpty) ...[
                // Primeiro versículo do capítulo: a página já entreaberta.
                const SizedBox(height: 6),
                Text(
                  '“$opening”',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.verse(
                    size: 16,
                    height: 1.4,
                    weight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: a.textSecondary,
                  ),
                ),
              ],
              if (!fresh && read > 0) ...[
                const SizedBox(height: AppSpace.md),
                AppProgressBar(value: read / total, height: 4, color: tone),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Estante de um testamento: uma lombada por livro, na cor do gênero, altura
/// pelo tamanho do livro. O que já foi lido acende de baixo para cima.
class _BibleShelf extends StatelessWidget {
  final List<BibleBook> books;

  /// Livros [start, end) do cânon.
  final int start;
  final int end;

  const _BibleShelf({
    required this.books,
    required this.start,
    required this.end,
  });

  static const _minSpine = 10.0;
  static const _maxSpine = 30.0;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final progress = context.watch<ProgressService>();
    final maxChapters = books.fold<int>(
      1,
      (m, b) => math.max(m, b.chapters.length),
    );
    var total = 0;
    var read = 0;
    final spines = <Widget>[];
    for (var i = start; i < end; i++) {
      final b = books[i];
      final count = b.chapters.length;
      final done = progress
          .readChaptersInBook(b.abbrev)
          .clamp(0, count)
          .toInt();
      total += count;
      read += done;
      final hue = BibleCanonicalGroups.toneOf(i) ?? a.place;
      final tone = a.onDark ? hue : a.ink(hue);
      // Raiz: Salmos (150) não engole Obadias (1).
      final height =
          _minSpine + (_maxSpine - _minSpine) * math.sqrt(count / maxChapters);
      spines.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.6),
            child: Container(
              height: height,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: a.onDark ? 0.42 : 0.36),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(2),
                ),
              ),
              child: done == 0
                  ? null
                  : FractionallySizedBox(
                      heightFactor: count == 0 ? 0 : done / count,
                      widthFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: tone,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: tone.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.lg,
        0,
        AppSpace.lg,
        AppSpace.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            label: context.l10n.bibleShelfSemantics(read, total),
            excludeSemantics: true,
            child: SizedBox(
              height: _maxSpine,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: spines,
              ),
            ),
          ),
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: a.divider,
              borderRadius: BorderRadius.circular(AppRadii.hair),
            ),
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
              accent: a.place,
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
    // Tocar só mostra o plano; começar é uma escolha explícita na prévia.
    final start = await showAppSheet<bool>(
      context,
      builder: (_) => _GuidedPlanPreview(
        def: def,
        tone: _planTone(def.id),
        minutes: _minutes[def.id],
        freeNote: !sub.plusFeaturesOpen,
      ),
    );
    if (start != true || !mounted) return;
    // Sem Plus, começa igual: os primeiros dias do guiado são grátis
    // (BibleReadingPlan.guidedFreeDays). A trava aparece no dia seguinte
    // ao fim da amostra, dentro do plano — não na porta. A troca de plano
    // já foi avisada na prévia.
    await progress.startGuidedReadingPlan(def.id);
    if (mounted) await _openPlan();
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final plan = context.select((ProgressService p) => p.bibleReadingPlan);
    final sub = context.watch<SubscriptionService>();

    Widget badge(bool active, bool locked, Color tone) {
      if (active) {
        return SoftBadge(
          text: l10n.commonActive,
          accent: a.onDark ? tone : a.ink(tone),
        );
      }
      if (locked) {
        return CinematicIcon(
          glyph: CinematicGlyph.lock,
          size: AppMetrics.iconMd,
          accent: a.textFaint,
          framed: false,
        );
      }
      return ListChevron(color: a.textFaint);
    }

    // Mesmo quadro dos Ajustes ("Sobre o Stway"): ícone, título, linhas.
    return ProfileSection(
      accent: a.place,
      glyph: CinematicGlyph.calendar,
      title: l10n.plansCatalogHeader,
      trailing: sub.showsPlus
          ? SoftBadge(
              text: l10n.paywallTitle,
              glyph: CinematicGlyph.plus,
              accent: AppRoles.reward,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          const SizedBox(height: AppSpace.md),
          AppNavRow(
            title: l10n.plansWholeBibleTitle,
            subtitle: l10n.planCardIdle,
            glyph: _planGlyph(null),
            accent: _planTone(null),
            trailing: badge(
              plan.active && !plan.isGuided,
              false,
              _planTone(null),
            ),
            onTap: () => _tapWholeBible(plan),
          ),
          for (final def in GuidedReadingPlan.all) ...[
            const AppNavDivider(),
            AppNavRow(
              title: def.title(l10n),
              subtitle: _minutes[def.id] == null
                  ? def.subtitle(l10n)
                  : l10n.guidedPlanMeta(
                      def.subtitle(l10n),
                      _minutes[def.id]!.round().clamp(1, 120),
                    ),
              glyph: _planGlyph(def.id),
              accent: _planTone(def.id),
              trailing: badge(
                plan.active && plan.guidedId == def.id,
                // Cadeado só no plano ativo com a amostra já usada.
                !sub.plusFeaturesOpen &&
                    plan.active &&
                    plan.guidedId == def.id &&
                    plan.lockedToday(plusOpen: sub.plusFeaturesOpen),
                _planTone(def.id),
              ),
              onTap: () => _tapGuided(plan, def),
            ),
          ],
        ],
      ),
    );
  }
}

/// Ícone de cada plano, no poço redondo da linha.
CinematicGlyph _planGlyph(String? id) => switch (id) {
  'evangelhos-30' => CinematicGlyph.dove,
  'salmos-proverbios-31' => CinematicGlyph.heart,
  'atos-28' => CinematicGlyph.flame,
  'genesis-25' => CinematicGlyph.seed,
  'nt-90' => CinematicGlyph.path,
  _ => CinematicGlyph.book,
};

/// Cor de cada plano: a do gênero que ele percorre (Evangelhos cedro,
/// Salmos rosa…). Bíblia inteira = cor da aba.
Color _planTone(String? id) => switch (id) {
  'evangelhos-30' => BibleCanonicalGroups.toneOf(39)!,
  'salmos-proverbios-31' => BibleCanonicalGroups.toneOf(18)!,
  'atos-28' => BibleCanonicalGroups.toneOf(43)!,
  'genesis-25' => BibleCanonicalGroups.toneOf(0)!,
  'nt-90' => BibleCanonicalGroups.toneOf(44)!,
  _ => AppRoles.navBible,
};

/// "Mateus 1–3 · Marcos 1": capítulos seguidos do mesmo livro viram faixa.
String _dayLabel(List<PlanChapterRef> day) {
  final parts = <String>[];
  var i = 0;
  while (i < day.length) {
    var j = i;
    while (j + 1 < day.length &&
        day[j + 1].bookIndex == day[i].bookIndex &&
        day[j + 1].chapter == day[j].chapter + 1) {
      j++;
    }
    parts.add(
      j == i
          ? day[i].label
          : '${day[i].bookName} ${day[i].chapter}–${day[j].chapter}',
    );
    i = j + 1;
  }
  return parts.join(' · ');
}

/// Prévia de um plano guiado: o que é, quanto leva e os primeiros dias.
/// Só "Começar plano" ativa (devolve true).
class _GuidedPlanPreview extends StatefulWidget {
  final GuidedReadingPlan def;
  final Color tone;
  final double? minutes;
  final bool freeNote;

  const _GuidedPlanPreview({
    required this.def,
    required this.tone,
    required this.minutes,
    required this.freeNote,
  });

  @override
  State<_GuidedPlanPreview> createState() => _GuidedPlanPreviewState();
}

class _GuidedPlanPreviewState extends State<_GuidedPlanPreview> {
  late final Future<List<List<PlanChapterRef>>> _days = BibleReadingPlanService
      .instance
      .guidedDays(widget.def);

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final tone = a.onDark ? widget.tone : a.ink(widget.tone);
    final switching = context.select(
      (ProgressService p) => p.bibleReadingPlan.active,
    );

    Widget pill(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: tone.withValues(alpha: 0.6)),
      ),
      child: Text(
        text,
        style: AppTypography.body(
          size: 12,
          weight: FontWeight.w800,
          color: tone,
        ),
      ),
    );

    // Folha alta: cabeçalho e botão fixos, o plano inteiro rola no meio.
    final height = MediaQuery.sizeOf(context).height * 0.86;
    return AppSheetPanel(
      tint: widget.tone,
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetHeader(
              eyebrow: l10n.plansCatalogHeader,
              eyebrowColor: tone,
              title: widget.def.title(l10n),
              subtitle: widget.def.subtitle(l10n),
            ),
            const SizedBox(height: AppSpace.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                pill(l10n.guidedPlanDaysCount(widget.def.days)),
                if (widget.minutes != null)
                  pill(
                    l10n.guidedPlanMinutesPerDay(
                      widget.minutes!.round().clamp(1, 120),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.lg),
            SectionLabel(l10n.guidedPlanAllDays),
            const SizedBox(height: AppSpace.xs),
            Expanded(
              child: FutureBuilder<List<List<PlanChapterRef>>>(
                future: _days,
                builder: (context, snap) {
                  final days = snap.data;
                  if (days == null) {
                    return const Center(child: AppSpinner(inline: true));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
                    itemCount: days.length,
                    separatorBuilder: (_, _) => const ListDivider(),
                    itemBuilder: (context, d) => _GuidedDayRow(
                      day: d + 1,
                      chapters: days[d],
                      tone: tone,
                      // Sem Plus: depois da amostra grátis, cadeado discreto.
                      locked:
                          widget.freeNote &&
                          d >= BibleReadingPlan.guidedFreeDays,
                    ),
                  );
                },
              ),
            ),
            if (widget.freeNote || switching) ...[
              const SizedBox(height: AppSpace.sm),
              Text(
                [
                  if (widget.freeNote)
                    l10n.guidedPlanFreeNote(BibleReadingPlan.guidedFreeDays),
                  if (switching) l10n.planSwitchBody,
                ].join(' '),
                style: AppTypography.body(
                  size: 12,
                  height: 1.4,
                  color: a.textFaint,
                ),
              ),
            ],
            const SizedBox(height: AppSpace.md),
            CopperCta(
              label: l10n.guidedPlanStart,
              onTap: () => Navigator.pop(context, true),
              trailing: null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Uma linha do plano: número do dia no poço da cor do plano, os
/// capítulos e o tempo estimado.
class _GuidedDayRow extends StatelessWidget {
  final int day;
  final List<PlanChapterRef> chapters;
  final Color tone;
  final bool locked;

  const _GuidedDayRow({
    required this.day,
    required this.chapters,
    required this.tone,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final minutes = chapters.fold<double>(0, (m, c) => m + c.estimatedMinutes);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tone.withValues(alpha: 0.16),
              border: Border.all(color: tone.withValues(alpha: 0.55)),
            ),
            child: Text(
              '$day',
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w800,
                color: tone,
              ),
            ),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Text(
              _dayLabel(chapters),
              style: AppTypography.body(size: 14, color: a.text),
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          if (locked)
            CinematicIcon(
              glyph: CinematicGlyph.lock,
              size: AppMetrics.iconSm,
              accent: a.textFaint,
              framed: false,
            )
          else
            Text(
              context.l10n.planMinutes(math.max(1, minutes.round())),
              style: AppTypography.body(size: 12, color: a.textFaint),
            ),
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
