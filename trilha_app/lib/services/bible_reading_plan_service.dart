import '../data/bible_chronology.dart';
import '../models/bible_reading_plan.dart';
import 'bible_service.dart';
import 'progress_service.dart';

/// Monta sequência de capítulos e fatia a leitura do dia pelo tempo disponível.
class BibleReadingPlanService {
  BibleReadingPlanService._();
  static final instance = BibleReadingPlanService._();

  /// Caracteres/minuto contemplativo (leitura bíblica, não romance).
  static const charsPerMinute = 900.0;

  Future<List<PlanChapterRef>> buildSequence(BibleReadingOrder order) async {
    final books = await BibleService.instance.books();
    final indices = switch (order) {
      BibleReadingOrder.canonical => [
          for (var i = 0; i < books.length; i++) i,
        ],
      BibleReadingOrder.chronological => [
          for (final e in BibleChronology.chronologicalIndices([
            for (final b in books) (abbrev: b.abbrev, name: b.name),
          ]))
            e.bookIndex,
        ],
    };

    final out = <PlanChapterRef>[];
    for (final bi in indices) {
      final book = books[bi];
      for (var c = 0; c < book.chapters.length; c++) {
        final verses = book.chapters[c];
        var chars = 0;
        for (final v in verses) {
          chars += v.length;
        }
        out.add(
          PlanChapterRef(
            bookIndex: bi,
            bookName: book.name,
            abbrev: book.abbrev,
            chapter: c + 1,
            verseCount: verses.length,
            charCount: chars,
          ),
        );
      }
    }
    return out;
  }

  bool _isRead(PlanChapterRef ch, Set<String> readKeys) =>
      readKeys.contains(ProgressService.bibleChapterKey(ch.abbrev, ch.chapter));

  /// Índice do primeiro capítulo ainda não lido a partir de [from].
  int firstUnreadCursor(
    List<PlanChapterRef> sequence,
    Set<String> readKeys, {
    int from = 0,
  }) {
    var i = from.clamp(0, sequence.length);
    while (i < sequence.length && _isRead(sequence[i], readKeys)) {
      i++;
    }
    return i;
  }

  Future<DailyReadingPortion> portionFor({
    required BibleReadingPlan plan,
    required Set<String> readKeys,
    List<PlanChapterRef>? sequence,
  }) async {
    final seq = sequence ?? await buildSequence(plan.order);
    // Pula o que já foi lido na Bíblia (fora do plano ou em dias anteriores).
    final start = firstUnreadCursor(seq, readKeys, from: plan.cursor);

    if (!plan.active || start >= seq.length) {
      return DailyReadingPortion(
        chapters: const [],
        estimatedMinutes: 0,
        fromCursor: start,
        toCursor: start,
        finished: true,
        skippedAlreadyRead: start - plan.cursor,
      );
    }

    final budget = plan.minutesPerDay.toDouble();
    final chapters = <PlanChapterRef>[];
    var minutes = 0.0;
    var i = start;

    // Empacota só capítulos pendentes até caber no tempo.
    while (i < seq.length) {
      final ch = seq[i];
      if (_isRead(ch, readKeys)) {
        i++;
        continue;
      }
      final next = minutes + ch.estimatedMinutes;
      if (chapters.isNotEmpty && next > budget * 1.15) break;
      chapters.add(ch);
      minutes = next;
      i++;
      if (minutes >= budget) break;
    }

    // Avança o cursor até depois do último capítulo incluído,
    // também passando por lidos intercalados já consumidos no loop.
    return DailyReadingPortion(
      chapters: chapters,
      estimatedMinutes: minutes,
      fromCursor: start,
      toCursor: i,
      finished: chapters.isEmpty,
      skippedAlreadyRead: start - plan.cursor,
    );
  }

  /// Dias restantes estimados (só capítulos ainda não lidos).
  Future<int> estimatedDaysRemaining({
    required BibleReadingPlan plan,
    required Set<String> readKeys,
  }) async {
    if (!plan.active) return 0;
    final seq = await buildSequence(plan.order);
    var i = firstUnreadCursor(seq, readKeys, from: plan.cursor);
    if (i >= seq.length) return 0;
    var days = 0;
    final budget = plan.minutesPerDay.toDouble();
    while (i < seq.length) {
      var minutes = 0.0;
      var packed = false;
      while (i < seq.length) {
        final ch = seq[i];
        if (_isRead(ch, readKeys)) {
          i++;
          continue;
        }
        final m = ch.estimatedMinutes;
        if (packed && minutes + m > budget * 1.15) break;
        minutes += m;
        i++;
        packed = true;
        if (minutes >= budget) break;
      }
      if (!packed) break;
      days++;
      if (days > 2000) break;
    }
    return days;
  }

  Future<
      ({
        int totalChapters,
        int remainingChapters,
        double totalMinutes,
        double remainingMinutes,
        int estimatedDays,
      })> previewStats({
    required BibleReadingOrder order,
    required int minutesPerDay,
    required Set<String> readKeys,
  }) async {
    final seq = await buildSequence(order);
    var totalMinutes = 0.0;
    var remainingMinutes = 0.0;
    var remainingChapters = 0;
    for (final c in seq) {
      totalMinutes += c.estimatedMinutes;
      if (!_isRead(c, readKeys)) {
        remainingMinutes += c.estimatedMinutes;
        remainingChapters++;
      }
    }
    final days = remainingChapters == 0
        ? 0
        : (remainingMinutes / minutesPerDay).ceil().clamp(1, 5000);
    return (
      totalChapters: seq.length,
      remainingChapters: remainingChapters,
      totalMinutes: totalMinutes,
      remainingMinutes: remainingMinutes,
      estimatedDays: days,
    );
  }
}
