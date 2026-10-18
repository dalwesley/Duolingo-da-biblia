import '../l10n/gen/app_localizations.dart';

/// Capítulo de um plano guiado: livro pelo índice canônico (0 = Gênesis,
/// 65 = Apocalipse) — vale para qualquer tradução.
typedef GuidedChapter = ({int book, int chapter});

/// Plano guiado (Peregrino+): capítulos fixos por dia. Sem data: o dia só
/// avança quando a pessoa marca a leitura, então não existe "atraso".
///
/// A Bíblia inteira no seu ritmo continua sendo o plano grátis.
class GuidedReadingPlan {
  final String id;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) subtitle;
  final int days;
  final List<List<GuidedChapter>> Function(List<int> chapterCounts) _build;

  // ignore: prefer_initializing_formals
  const GuidedReadingPlan._({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.days,
    required List<List<GuidedChapter>> Function(List<int>) build,
  }) : _build = build;

  /// Capítulos de cada dia. [chapterCounts]: capítulos por livro, na ordem
  /// canônica (66 itens).
  List<List<GuidedChapter>> build(List<int> chapterCounts) =>
      _build(chapterCounts);

  static const _gn = 0;
  static const _sl = 18;
  static const _pv = 19;
  static const _mt = 39;
  static const _jo = 42;
  static const _at = 43;
  static const _ap = 65;

  static final all = <GuidedReadingPlan>[
    GuidedReadingPlan._(
      id: 'evangelhos-30',
      title: (l) => l.guidedPlanGospelsTitle,
      subtitle: (l) => l.guidedPlanGospelsSubtitle,
      days: 30,
      build: (c) => spread(chaptersOf(c, _mt, _jo), 30),
    ),
    GuidedReadingPlan._(
      id: 'salmos-proverbios-31',
      title: (l) => l.guidedPlanPsalmsTitle,
      subtitle: (l) => l.guidedPlanPsalmsSubtitle,
      days: 31,
      build: (c) {
        final psalms = spread(chaptersOf(c, _sl, _sl), 31);
        return [
          for (var d = 0; d < 31; d++)
            [...psalms[d], if (d < c[_pv]) (book: _pv, chapter: d + 1)],
        ];
      },
    ),
    GuidedReadingPlan._(
      id: 'atos-28',
      title: (l) => l.guidedPlanActsTitle,
      subtitle: (l) => l.guidedPlanActsSubtitle,
      days: 28,
      build: (c) => spread(chaptersOf(c, _at, _at), 28),
    ),
    GuidedReadingPlan._(
      id: 'genesis-25',
      title: (l) => l.guidedPlanGenesisTitle,
      subtitle: (l) => l.guidedPlanGenesisSubtitle,
      days: 25,
      build: (c) => spread(chaptersOf(c, _gn, _gn), 25),
    ),
    GuidedReadingPlan._(
      id: 'nt-90',
      title: (l) => l.guidedPlanNewTestamentTitle,
      subtitle: (l) => l.guidedPlanNewTestamentSubtitle,
      days: 90,
      build: (c) => spread(chaptersOf(c, _mt, _ap), 90),
    ),
  ];

  static GuidedReadingPlan? byId(String? id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Todos os capítulos dos livros [from]..[to] (inclusive), em ordem.
  static List<GuidedChapter> chaptersOf(List<int> counts, int from, int to) => [
    for (var b = from; b <= to && b < counts.length; b++)
      for (var ch = 1; ch <= counts[b]; ch++) (book: b, chapter: ch),
  ];

  /// Reparte [chapters] em [days] dias, em ordem, o mais igual possível.
  static List<List<GuidedChapter>> spread(
    List<GuidedChapter> chapters,
    int days,
  ) {
    final n = chapters.length;
    return [
      for (var d = 0; d < days; d++)
        chapters.sublist(n * d ~/ days, n * (d + 1) ~/ days),
    ];
  }
}
