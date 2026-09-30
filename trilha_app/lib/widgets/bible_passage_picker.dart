import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/bible_canonical_groups.dart';
import '../l10n/app_language.dart';
import '../services/bible_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'bible_book_intro_card.dart';
import 'bible_chapter_grid.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'relic_panel.dart';
import 'ui_primitives.dart';

/// Livro + capítulo escolhidos no seletor.
typedef BiblePassagePick = ({int bookIndex, int chapter});

/// Sheet de salto: livros (AT/NT) → capítulos. Com [bookIndex], abre direto
/// nos capítulos daquele livro; [showIntro] mostra o resumo histórico.
Future<BiblePassagePick?> showBiblePassagePicker(
  BuildContext context, {
  required List<BibleBook> books,
  int? bookIndex,
  int? currentChapter,
  bool showIntro = false,
}) {
  return showAppSheet<BiblePassagePick>(
    context,
    useRootNavigator: true,
    builder: (_) => _PassagePickerSheet(
      books: books,
      initialBook: bookIndex,
      currentChapter: currentChapter,
      showIntro: showIntro,
    ),
  );
}

class _PassagePickerSheet extends StatefulWidget {
  final List<BibleBook> books;
  final int? initialBook;
  final int? currentChapter;
  final bool showIntro;

  const _PassagePickerSheet({
    required this.books,
    required this.initialBook,
    required this.currentChapter,
    required this.showIntro,
  });

  @override
  State<_PassagePickerSheet> createState() => _PassagePickerSheetState();
}

class _PassagePickerSheetState extends State<_PassagePickerSheet> {
  int? _book;
  late bool _newTestament;

  @override
  void initState() {
    super.initState();
    _book = widget.initialBook;
    _newTestament = (widget.initialBook ?? 0) >= BibleService.oldTestamentCount;
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.86;
    return AppSheetPanel(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        AppSpace.md,
        AppSpace.screen,
        0,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 220),
          child: _book == null ? _booksStep() : _chaptersStep(_book!),
        ),
      ),
    );
  }

  Widget _booksStep() {
    const otEnd = BibleService.oldTestamentCount;
    final groups = BibleCanonicalGroups.groups
        .where(
          (g) => _newTestament ? g.startIndex >= otEnd : g.endIndex < otEnd,
        )
        .toList();

    return Column(
      key: const ValueKey('books'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSheetHeader(title: context.l10n.biblePickerTitle),
        const SizedBox(height: AppSpace.md),
        Row(
          children: [
            for (final nt in const [false, true]) ...[
              if (nt) const SizedBox(width: AppSpace.sm),
              Expanded(
                child: AppSelectChip(
                  label: nt
                      ? context.l10n.bibleNewTestament
                      : context.l10n.bibleOldTestament,
                  selected: _newTestament == nt,
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  onTap: () => setState(() => _newTestament = nt),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpace.md),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + AppSpace.xl,
            ),
            children: [
              for (var n = 0; n < groups.length; n++) ...[
                if (n > 0) const SizedBox(height: AppSpace.lg),
                BibleBookList(
                  title: groups[n].title,
                  blurb: groups[n].blurb,
                  books: widget.books,
                  indices: [
                    for (
                      var i = groups[n].startIndex;
                      i <= groups[n].endIndex && i < widget.books.length;
                      i++
                    )
                      i,
                  ],
                  selectedIndex: widget.initialBook,
                  onPick: (i) => setState(() => _book = i),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _chaptersStep(int bookIndex) {
    final a = Appearance.of(context);
    final book = widget.books[bookIndex];
    final progress = context.watch<ProgressService>();
    final read = progress.readChaptersInBook(book.abbrev);
    final total = book.chapters.length;

    return Column(
      key: ValueKey('chapters-$bookIndex'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Semantics(
              button: true,
              label: context.l10n.biblePickerBackToBooks,
              child: InkResponse(
                onTap: () {
                  ActHaptics.tap();
                  setState(() {
                    _newTestament = bookIndex >= BibleService.oldTestamentCount;
                    _book = null;
                  });
                },
                radius: 24,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpace.xs),
                  child: CinematicIcon(
                    glyph: CinematicGlyph.back,
                    size: AppMetrics.iconLg,
                    accent: a.textSecondary,
                    framed: false,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: AppSheetHeader(
                title: book.name,
                subtitle: read == 0
                    ? context.l10n.bibleChapterCount(total)
                    : context.l10n.bibleChaptersReadOf(read, total),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        if (read > 0) ...[
          AppProgressBar(
            value: read / total,
            height: 6,
            color: AppRoles.success,
          ),
          const SizedBox(height: AppSpace.md),
        ],
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + AppSpace.xl,
            ),
            children: [
              if (widget.showIntro) ...[
                BibleBookIntroCard(book: book),
                const SizedBox(height: AppSpace.lg),
              ],
              BibleChapterGrid(
                count: total,
                isRead: (c) => progress.hasReadBibleChapter(book.abbrev, c),
                onPick: (c) => Navigator.of(
                  context,
                ).pop((bookIndex: bookIndex, chapter: c)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Lista de livros — título do grupo dentro do card, depois as linhas.
class BibleBookList extends StatelessWidget {
  final List<BibleBook> books;
  final List<int> indices;
  final ValueChanged<int> onPick;
  final int? selectedIndex;
  final String? title;
  final String? blurb;
  final Color accent;
  final bool expanded;
  final VoidCallback? onToggle;

  /// Sem card próprio — divisão dentro de outro card (testamento).
  final bool framed;

  const BibleBookList({
    super.key,
    required this.books,
    required this.indices,
    required this.onPick,
    this.selectedIndex,
    this.title,
    this.blurb,
    this.accent = AppRoles.chrome,
    this.expanded = true,
    this.onToggle,
    this.framed = true,
  });

  static const _abbrevWidth = 42.0;
  static const _dividerIndent = AppSpace.lg + _abbrevWidth + AppSpace.sm;

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final motion = MediaQuery.disableAnimationsOf(context);
    final showBooks = onToggle == null || expanded;
    final rows = Column(
      children: [
        for (var n = 0; n < indices.length; n++) ...[
          if (n > 0) const ListDivider(indent: _dividerIndent),
          _BookRow(
            book: books[indices[n]],
            read: progress.readChaptersInBook(books[indices[n]].abbrev),
            selected: indices[n] == selectedIndex,
            onTap: () {
              ActHaptics.tap();
              onPick(indices[n]);
            },
          ),
        ],
      ],
    );
    if (!framed) {
      final a = Appearance.of(context);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.lg,
                AppSpace.lg,
                AppSpace.lg,
                AppSpace.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: AppTypography.title(size: 16, color: a.text),
                  ),
                  if (blurb != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      blurb!,
                      style: AppTypography.body(
                        size: 12,
                        color: a.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          rows,
        ],
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppMetrics.cardRadius),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            if (title != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpace.lg,
                  AppSpace.lg,
                  AppSpace.lg,
                  showBooks ? AppSpace.md : AppSpace.lg,
                ),
                child: Semantics(
                  button: onToggle != null,
                  expanded: onToggle != null ? expanded : null,
                  header: true,
                  label: title,
                  hint: onToggle == null
                      ? null
                      : expanded
                      ? context.l10n.bibleTapToClose
                      : context.l10n.bibleTapToOpen,
                  child: GestureDetector(
                    onTap: onToggle,
                    behavior: HitTestBehavior.opaque,
                    child: RelicChapter(
                      title: title!,
                      whisper: blurb,
                      accent: accent,
                      divided: false,
                      trailing: CountBadge(
                        '${indices.length}',
                        color: accent,
                        filled: false,
                      ),
                      action: onToggle == null
                          ? null
                          : AnimatedRotation(
                              turns: expanded ? 0.25 : 0,
                              duration: motion
                                  ? Duration.zero
                                  : const Duration(milliseconds: 220),
                              curve: AppMotion.enter,
                              child: ListChevron(
                                color: Appearance.of(context).textFaint,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            AnimatedSize(
              duration: motion
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              curve: AppMotion.enter,
              alignment: Alignment.topCenter,
              child: showBooks
                  ? Column(
                      children: [if (title != null) const ListDivider(), rows],
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  final BibleBook book;
  final int read;
  final bool selected;
  final VoidCallback onTap;

  const _BookRow({
    required this.book,
    required this.read,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final total = book.chapters.length;
    final done = total > 0 && read >= total;
    final detail = read == 0
        ? context.l10n.bibleChapterCountShort(total)
        : context.l10n.bibleReadOf(read, total);
    final abbrev = book.abbrev.toUpperCase();

    return Semantics(
      button: true,
      selected: selected,
      label: read == 0
          ? book.name
          : context.l10n.bibleBookReadSemantics(book.name, read, total),
      excludeSemantics: true,
      child: Material(
        color: selected
            ? AppRoles.selected.withValues(alpha: 0.08)
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.lg,
              vertical: AppSpace.md,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: BibleBookList._abbrevWidth,
                  child: Text(
                    abbrev,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label(
                      size: abbrev.length > 3 ? 10 : 11,
                      letterSpacing: 0.4,
                      color: a.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text(
                    book.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title(size: 14, color: a.text),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                if (done) ...[
                  const CinematicIcon(
                    glyph: CinematicGlyph.check,
                    size: AppMetrics.chipIcon,
                    accent: AppRoles.success,
                    framed: false,
                  ),
                  const SizedBox(width: AppSpace.xs),
                ],
                Text(
                  detail,
                  style: AppTypography.body(
                    size: 12,
                    color: read == 0 ? a.textFaint : a.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpace.xs),
                ListChevron(color: a.textFaint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
