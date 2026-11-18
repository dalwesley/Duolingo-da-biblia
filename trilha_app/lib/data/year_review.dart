import '../models/difficulty.dart';
import '../services/bible_service.dart';
import '../utils/reading_growth.dart';
import 'season_walk_catalog.dart';
import '../services/progress_service.dart';
import '../widgets/postcard.dart';
import 'postcard_index.dart';
import 'trail_art.dart';
import 'trail_repository.dart';

/// Quem a pessoa foi no ano: o título do card, calculado dos números.
enum YearPersona { group, advent, reader, explorer, constant, grower, pilgrim }

/// Hora do dia em que a pessoa mais caminhou.
enum YearDaypart { dawn, morning, afternoon, night }

/// Outros que caminharam junto (lido dos serviços ao abrir).
class YearTogether {
  final String? companionName;
  final int companionDays;
  final String? groupName;
  final int recognitions;

  const YearTogether({
    this.companionName,
    this.companionDays = 0,
    this.groupName,
    this.recognitions = 0,
  });
}

/// Retrospectiva do ano: tudo sai dos postais (e das cenas feitas antes
/// deles) e do acerto por modo. Ver docs/postais.md.
class YearReview {
  final int year;

  /// Postais do ano, do mais antigo ao mais recente.
  final List<Postcard> postcards;

  /// Dias diferentes em que a pessoa revelou postal.
  final int days;

  /// Livro com mais postais no ano e quantos.
  final String? topBook;
  final int topBookCount;

  /// Modo com mais acerto de primeira (com respostas suficientes).
  final TrailDifficulty? bestMode;
  final int bestModePct;

  /// Livros diferentes com postal no ano.
  final int books;

  /// Capítulos lidos no leitor da Bíblia no ano.
  final int chapters;

  /// Maior sequência de dias (de sempre: o contador não guarda por ano).
  final int bestStreak;

  /// Mês (1–12) com mais postais e quantos.
  final int? topMonth;
  final int topMonthCount;

  /// Frase "Hoje" que fica: a do postal mais recente do livro mais visitado.
  final Postcard? phrase;

  /// Selos "Fiel na semana" ganhos em grupo no ano.
  final int groupSeals;

  /// Dias do Advento do ano caminhados e o total da estação (0 = não houve).
  final int adventDays;
  final int adventLength;

  /// Abreviações dos 66 livros (ordem canônica). Vazio = Bíblia não carregou.
  final List<String> bookLabels;

  /// Livros acesos no ano: índice canônico → 2 com postal, 1 só com leitura.
  final Map<int, int> litBooks;

  /// Dias (YYYY-MM-DD) do ano com alguma caminhada (cena, leitura, Advento).
  final Set<String> walkedDays;

  /// Maior sequência de dias seguidos dentro do ano.
  final int yearStreak;

  /// Acerto de primeira: começo do ano contra agora, no modo que mais subiu.
  final ReadingGrowth? growth;

  /// Cenas do ano fechadas sem errar nenhuma.
  final int perfectScenes;

  /// Trilhas terminadas por inteiro no ano (títulos).
  final List<String> trailsDone;

  /// Versículos guardados de cor (até hoje).
  final int versesKept;

  /// Quando a pessoa mais caminhou (só com cenas suficientes no ano).
  final YearDaypart? daypart;

  final YearTogether together;

  final YearPersona persona;

  const YearReview({
    required this.year,
    required this.postcards,
    required this.days,
    required this.topBook,
    required this.topBookCount,
    required this.bestMode,
    required this.bestModePct,
    this.books = 0,
    this.chapters = 0,
    this.bestStreak = 0,
    this.topMonth,
    this.topMonthCount = 0,
    this.phrase,
    this.groupSeals = 0,
    this.adventDays = 0,
    this.adventLength = 0,
    this.bookLabels = const [],
    this.litBooks = const {},
    this.walkedDays = const {},
    this.yearStreak = 0,
    this.growth,
    this.perfectScenes = 0,
    this.trailsDone = const [],
    this.versesKept = 0,
    this.daypart,
    this.together = const YearTogether(),
    this.persona = YearPersona.pilgrim,
  });

  /// Há algo do caminhar junto para mostrar.
  bool get hasTogether =>
      groupSeals > 0 ||
      adventDays > 0 ||
      together.companionDays > 0 ||
      together.recognitions > 0;

  /// O mapa dos 66 livros dá para desenhar.
  bool get hasMap => bookLabels.length == 66 && litBooks.isNotEmpty;

  /// Dias caminhados no ano (cena, leitura ou Advento).
  int get daysWalked => walkedDays.length;

  /// Há conquistas para o slide de marcos.
  bool get hasFeats =>
      perfectScenes > 0 || trailsDone.isNotEmpty || versesKept > 0;

  /// Retrospectiva só abre com pelo menos isto de postais no ano.
  static const minPostcards = 3;

  bool get worthShowing => postcards.length >= minPostcards;

  static Future<YearReview> build(
    ProgressService progress,
    int year, {
    YearTogether together = const YearTogether(),
    bool loadBible = true,
  }) async {
    final trails = await TrailRepository().getTrails();
    final prefix = '$year-';
    final cards = <Postcard>[];
    final seen = <String>{};
    for (final t in trails) {
      for (final m in [for (final mod in t.modules) ...mod.missions]) {
        if (!seen.add(m.slug)) continue;
        final day =
            progress.postcardsOn[m.slug] ?? progress.missionCompletedOn[m.slug];
        if (day == null || !day.startsWith(prefix)) continue;
        cards.add(
          Postcard(
            slug: m.slug,
            title: m.localizedTitle,
            ref: PostcardIndex.refOf(progress, m),
            insight: (m.localizedCentralInsight ?? '').trim(),
            art: TrailArt.ofScene(t.slug, m.slug),
            on: DateTime.tryParse(day) ?? DateTime(year),
          ),
        );
      }
    }
    cards.sort((a, b) => a.on.compareTo(b.on));

    final books = <String, int>{};
    for (final c in cards) {
      if (c.ref.trim().isEmpty) continue;
      books[c.book] = (books[c.book] ?? 0) + 1;
    }
    final top = books.entries.isEmpty
        ? null
        : books.entries.reduce((a, b) => b.value > a.value ? b : a);

    // Acerto de primeira por modo ("modo.gesto" → soma do modo).
    final right = <String, int>{};
    final total = <String, int>{};
    for (final e in progress.answerTotal.entries) {
      final mode = e.key.split('.').first;
      total[mode] = (total[mode] ?? 0) + e.value;
      right[mode] = (right[mode] ?? 0) + (progress.answerCorrect[e.key] ?? 0);
    }
    TrailDifficulty? bestMode;
    var bestPct = 0;
    for (final e in total.entries) {
      if (e.value < 10) continue;
      final mode = TrailDifficulty.fromId(e.key);
      if (mode == null) continue;
      final pct = ((right[e.key] ?? 0) * 100 / e.value).round();
      if (pct > bestPct) {
        bestPct = pct;
        bestMode = mode;
      }
    }

    final walked = walkedDaysIn(progress, year);
    final months = <int, int>{};
    for (final d in walked) {
      final m = int.tryParse(d.substring(5, 7));
      if (m != null) months[m] = (months[m] ?? 0) + 1;
    }
    final month = months.entries.isEmpty
        ? null
        : months.entries.reduce((a, b) => b.value > a.value ? b : a);

    Postcard? phrase;
    for (final c in cards.reversed) {
      if (c.insight.isEmpty) continue;
      if (top == null || c.book == top.key) {
        phrase = c;
        break;
      }
    }

    final adventId = 'advento-$year';
    final advent = SeasonWalkCatalog.all(
      DateTime(year, 1, 1),
    ).where((c) => c.id == adventId).firstOrNull;

    // Mapa da Bíblia: livros com postal (forte) ou com capítulo lido.
    final labels = <String>[];
    final lit = <int, int>{};
    if (loadBible) {
      try {
        final bible = BibleService.instance;
        final list = await bible.books();
        if (list.length == 66) {
          labels.addAll(list.map((b) => b.abbrev));
          final byAbbrev = {
            for (var i = 0; i < list.length; i++)
              list[i].abbrev.toLowerCase(): i,
          };
          for (final e in progress.bibleChapterReadOn.entries) {
            if (!e.value.startsWith(prefix)) continue;
            final i = byAbbrev[e.key.split(':').first.toLowerCase()];
            if (i != null) lit[i] = lit[i] ?? 1;
          }
          final byBook = <String, int?>{};
          for (final c in cards) {
            final ref = c.ref.trim();
            if (ref.isEmpty) continue;
            final idx = byBook.containsKey(c.book)
                ? byBook[c.book]
                : byBook[c.book] = (await bible.resolve(ref))?.bookIndex;
            if (idx != null && idx >= 0 && idx < 66) lit[idx] = 2;
          }
        }
      } catch (_) {
        labels.clear();
        lit.clear();
      }
    }

    // Crescimento só com as semanas do ano.
    bool inYear(String k) => k.startsWith(prefix);
    final growth = ReadingGrowth.best(
      correct: {
        for (final e in progress.weekAnswerCorrect.entries)
          if (inYear(e.key)) e.key: e.value,
      },
      total: {
        for (final e in progress.weekAnswerTotal.entries)
          if (inYear(e.key)) e.key: e.value,
      },
    );

    String? dayOf(String slug) =>
        progress.missionCompletedOn[slug] ?? progress.postcardsOn[slug];
    final perfect = progress.perfectMissions
        .where((s) => dayOf(s)?.startsWith(prefix) ?? false)
        .length;

    final trailsDone = <String>[];
    for (final t in trails) {
      if ((progress.clearedTrailModes[t.slug] ?? const []).isEmpty) continue;
      final slugs = [
        for (final m in t.modules) ...m.missions.map((x) => x.slug),
      ];
      if (slugs.isEmpty) continue;
      String? last;
      for (final s in slugs) {
        final d = progress.sceneLastDoneOn[s] ?? progress.missionCompletedOn[s];
        if (d != null && (last == null || d.compareTo(last) > 0)) last = d;
      }
      if (last != null && last.startsWith(prefix)) {
        trailsDone.add(t.localizedTitle);
      }
    }

    final daypart = daypartOf(progress.sceneHours, year);
    final groupSeals = progress.groupSealWeeks
        .where((k) => k.split('@').last.startsWith(prefix))
        .length;
    final adventDays = progress.walkDatesFor(adventId).length;
    final adventLength = advent?.length ?? 0;
    final streak = longestRun(walked);
    final chapters = progress.bibleChapterReadOn.values
        .where((d) => d.startsWith(prefix))
        .length;

    return YearReview(
      year: year,
      postcards: cards,
      days: {for (final c in cards) c.on}.length,
      topBook: top?.key,
      topBookCount: top?.value ?? 0,
      bestMode: bestMode,
      bestModePct: bestPct,
      books: lit.isNotEmpty ? lit.length : books.length,
      chapters: chapters,
      bestStreak: progress.bestStreak,
      topMonth: month?.key,
      topMonthCount: month?.value ?? 0,
      phrase: phrase,
      groupSeals: groupSeals,
      adventDays: adventDays,
      adventLength: adventLength,
      bookLabels: labels,
      litBooks: lit,
      walkedDays: walked,
      yearStreak: streak,
      growth: growth,
      perfectScenes: perfect,
      trailsDone: trailsDone,
      versesKept: progress.memoryMastered.length,
      daypart: daypart,
      together: together,
      persona: personaOf(
        groupSeals: groupSeals,
        adventDays: adventDays,
        adventLength: adventLength,
        chapters: chapters,
        litBooks: lit.length,
        yearStreak: streak,
        daysWalked: walked.length,
        growth: growth?.delta ?? 0,
      ),
    );
  }

  /// Ano de exemplo cheio (laboratório e testes): todos os slides aparecem.
  static YearReview sample({List<Postcard> postcards = const []}) {
    const labels = [
      'Gn',
      'Êx',
      'Lv',
      'Nm',
      'Dt',
      'Js',
      'Jz',
      'Rt',
      '1Sm',
      '2Sm',
      '1Rs',
      '2Rs',
      '1Cr',
      '2Cr',
      'Ed',
      'Ne',
      'Et',
      'Jó',
      'Sl',
      'Pv',
      'Ec',
      'Ct',
      'Is',
      'Jr',
      'Lm',
      'Ez',
      'Dn',
      'Os',
      'Jl',
      'Am',
      'Ob',
      'Jn',
      'Mq',
      'Na',
      'Hc',
      'Sf',
      'Ag',
      'Zc',
      'Ml',
      'Mt',
      'Mc',
      'Lc',
      'Jo',
      'At',
      'Rm',
      '1Co',
      '2Co',
      'Gl',
      'Ef',
      'Fp',
      'Cl',
      '1Ts',
      '2Ts',
      '1Tm',
      '2Tm',
      'Tt',
      'Fm',
      'Hb',
      'Tg',
      '1Pe',
      '2Pe',
      '1Jo',
      '2Jo',
      '3Jo',
      'Jd',
      'Ap',
    ];
    final days = <String>{};
    var d = DateTime(2026, 3, 2);
    var i = 0;
    while (d.year == 2026) {
      if (i % 7 != 3 && (i < 40 || i % 3 != 0)) {
        days.add(d.toIso8601String().substring(0, 10));
      }
      d = d.add(const Duration(days: 1));
      i++;
    }
    return YearReview(
      year: 2026,
      postcards: postcards,
      days: postcards.length,
      topBook: postcards.isEmpty ? null : 'Êxodo',
      topBookCount: 3,
      bestMode: TrailDifficulty.semente,
      bestModePct: 82,
      books: 14,
      chapters: 31,
      bestStreak: 21,
      topMonth: 12,
      topMonthCount: 22,
      phrase: postcards.isEmpty ? null : postcards.last,
      groupSeals: 4,
      adventDays: 18,
      adventLength: 26,
      bookLabels: labels,
      litBooks: const {
        0: 2,
        1: 2,
        7: 2,
        8: 1,
        18: 1,
        19: 1,
        22: 1,
        32: 2,
        39: 1,
        40: 2,
        41: 1,
        42: 2,
        43: 1,
        44: 1,
      },
      walkedDays: days,
      yearStreak: longestRun(days),
      growth: const ReadingGrowth(
        mode: TrailDifficulty.caminhada,
        fromPct: 58,
        toPct: 81,
      ),
      perfectScenes: 9,
      trailsDone: const ['Êxodo', 'Rute', 'A Promessa'],
      versesKept: 5,
      daypart: YearDaypart.morning,
      together: const YearTogether(
        companionName: 'Ana Clara',
        companionDays: 34,
        groupName: 'Célula Esperança',
        recognitions: 12,
      ),
      persona: YearPersona.group,
    );
  }

  /// Dias do ano com caminhada: cena (1ª vez ou refeita), postal, leitura,
  /// Caminhada da estação e os dias de uso guardados.
  static Set<String> walkedDaysIn(ProgressService p, int year) {
    final prefix = '$year-';
    final all = <String>{
      ...p.missionCompletedOn.values,
      ...p.sceneLastDoneOn.values,
      ...p.postcardsOn.values,
      ...p.bibleChapterReadOn.values,
      for (final days in p.seasonWalkDays.values) ...days,
      ...p.playDates,
    };
    return {
      for (final d in all)
        if (d.length >= 10 && d.startsWith(prefix)) d.substring(0, 10),
    };
  }

  /// Maior sequência de dias seguidos em [days] (YYYY-MM-DD).
  static int longestRun(Set<String> days) {
    final sorted = [
      for (final d in days) DateTime.tryParse(d),
    ].whereType<DateTime>().toList()..sort();
    var best = 0, run = 0;
    DateTime? prev;
    for (final d in sorted) {
      run = prev != null && d.difference(prev).inHours.abs() <= 25
          ? run + 1
          : 1;
      if (run > best) best = run;
      prev = d;
    }
    return best;
  }

  /// Hora com mais cenas no ano, agrupada em parte do dia. Precisa de
  /// [minHourScenes] cenas com hora (o campo existe desde nov/2026).
  static YearDaypart? daypartOf(Map<String, int> hours, int year) {
    final parts = <YearDaypart, int>{};
    var total = 0;
    for (final e in hours.entries) {
      final bits = e.key.split('.');
      if (bits.length != 2 || bits.first != '$year') continue;
      final h = int.tryParse(bits.last);
      if (h == null) continue;
      final part = h < 5
          ? YearDaypart.dawn
          : h < 12
          ? YearDaypart.morning
          : h < 18
          ? YearDaypart.afternoon
          : YearDaypart.night;
      parts[part] = (parts[part] ?? 0) + e.value;
      total += e.value;
    }
    if (total < minHourScenes) return null;
    return parts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }

  static const minHourScenes = 8;

  /// O título do ano: o traço mais forte, na ordem do que mais pesa.
  static YearPersona personaOf({
    required int groupSeals,
    required int adventDays,
    required int adventLength,
    required int chapters,
    required int litBooks,
    required int yearStreak,
    required int daysWalked,
    required int growth,
  }) {
    if (groupSeals >= 3) return YearPersona.group;
    if (adventLength > 0 && adventDays * 4 >= adventLength * 3) {
      return YearPersona.advent;
    }
    if (chapters >= 30) return YearPersona.reader;
    if (litBooks >= 10) return YearPersona.explorer;
    if (yearStreak >= 14 || daysWalked >= 60) return YearPersona.constant;
    if (growth >= 10) return YearPersona.grower;
    return YearPersona.pilgrim;
  }
}
