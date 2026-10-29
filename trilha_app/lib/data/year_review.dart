import '../models/difficulty.dart';
import '../services/progress_service.dart';
import '../widgets/postcard.dart';
import 'postcard_index.dart';
import 'trail_art.dart';
import 'trail_repository.dart';

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

  const YearReview({
    required this.year,
    required this.postcards,
    required this.days,
    required this.topBook,
    required this.topBookCount,
    required this.bestMode,
    required this.bestModePct,
  });

  /// Retrospectiva só abre com pelo menos isto de postais no ano.
  static const minPostcards = 3;

  bool get worthShowing => postcards.length >= minPostcards;

  static Future<YearReview> build(ProgressService progress, int year) async {
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

    return YearReview(
      year: year,
      postcards: cards,
      days: {for (final c in cards) c.on}.length,
      topBook: top?.key,
      topBookCount: top?.value ?? 0,
      bestMode: bestMode,
      bestModePct: bestPct,
    );
  }
}
