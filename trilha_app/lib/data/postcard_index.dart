import 'dart:math' as math;

import '../models/trail.dart';
import '../services/bible_service.dart';
import '../services/progress_service.dart';
import '../widgets/postcard.dart';
import 'trail_art.dart';
import 'trail_repository.dart';

/// Um postal marcado na Bíblia: os versículos da cena e o postal.
class BiblePostcardMark {
  final Postcard card;
  final int start;
  final int end;

  const BiblePostcardMark({
    required this.card,
    required this.start,
    required this.end,
  });

  bool covers(int verse) => verse >= start && verse <= end;
}

/// Onde os postais marcam a Bíblia: (livro, capítulo) → marcas, em ordem de
/// versículo. Ver docs/postais.md.
class PostcardIndex {
  PostcardIndex._();

  /// Postais revelados e cenas feitas antes dos postais (já reveladas). A
  /// referência vem do postal; sem ela, do versículo de entrada da cena.
  /// Referência só de capítulo ("Mateus 6") não marca versículo.
  static Future<Map<(int, int), List<BiblePostcardMark>>> build(
    ProgressService progress,
  ) async {
    final trails = await TrailRepository().getTrails();
    final out = <(int, int), List<BiblePostcardMark>>{};
    final seen = <String>{};
    for (final t in trails) {
      for (final m in [for (final mod in t.modules) ...mod.missions]) {
        if (!seen.add(m.slug)) continue;
        final day =
            progress.postcardsOn[m.slug] ?? progress.missionCompletedOn[m.slug];
        if (day == null) continue;
        final refText = refOf(progress, m);
        if (refText.isEmpty) continue;
        final ref = await BibleService.instance.resolve(
          refText,
          translationId: BibleService.palcoTranslationId,
        );
        final start = ref?.verseStart;
        if (ref == null || start == null) continue;
        final end = math.max(start, ref.verseEnd ?? start);
        (out[(ref.bookIndex, ref.chapter)] ??= []).add(
          BiblePostcardMark(
            card: Postcard(
              slug: m.slug,
              title: m.localizedTitle,
              ref: refText,
              insight: (m.localizedCentralInsight ?? '').trim(),
              art: TrailArt.ofScene(t.slug, m.slug),
              on: DateTime.tryParse(day) ?? DateTime.now(),
            ),
            start: start,
            end: end,
          ),
        );
      }
    }
    for (final marks in out.values) {
      marks.sort((a, b) => a.start.compareTo(b.start));
    }
    return out;
  }

  /// Referência do postal da cena [m]: a gravada na revelação ou, para cena
  /// feita antes dos postais, o versículo de entrada quando é referência.
  static String refOf(ProgressService progress, Mission m) {
    final saved = progress.postcardRefs[m.slug];
    if (saved != null) return saved;
    final hook = (m.hookRef ?? '').trim();
    return RegExp(r'\d').hasMatch(hook) ? hook : '';
  }
}
