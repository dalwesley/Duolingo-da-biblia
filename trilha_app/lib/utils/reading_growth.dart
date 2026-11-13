import '../models/difficulty.dart';

/// Evolução da leitura: acerto de primeira por modo, semana a semana.
///
/// O app guarda `weekAnswerCorrect`/`weekAnswerTotal` com chave
/// "SEGUNDA.modo" (ex.: "2026-11-09.profundezas"). Aqui compara o começo
/// da caminhada com as semanas mais recentes do mesmo modo.
class ReadingGrowth {
  final TrailDifficulty mode;
  final int fromPct;
  final int toPct;

  const ReadingGrowth({
    required this.mode,
    required this.fromPct,
    required this.toPct,
  });

  int get delta => toPct - fromPct;

  /// Respostas mínimas em cada ponta (começo e agora) para comparar.
  static const minAnswers = 10;

  /// Ganho mínimo (pontos percentuais) para chamar de evolução.
  static const minDelta = 5;

  /// Semanas guardadas (as mais antigas saem).
  static const keepWeeks = 26;

  /// Segunda-feira (YYYY-MM-DD) da semana local de [d].
  static String weekKey(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    final monday = day.subtract(Duration(days: day.weekday - 1));
    final m = monday.month.toString().padLeft(2, '0');
    final dd = monday.day.toString().padLeft(2, '0');
    return '${monday.year}-$m-$dd';
  }

  static String key(String week, String mode) => '$week.$mode';

  /// Corta para as [keepWeeks] semanas mais recentes.
  static Map<String, int> prune(Map<String, int> map) {
    final weeks = {for (final k in map.keys) k.split('.').first}.toList()
      ..sort();
    if (weeks.length <= keepWeeks) return map;
    final keep = weeks.sublist(weeks.length - keepWeeks).toSet();
    return {
      for (final e in map.entries)
        if (keep.contains(e.key.split('.').first)) e.key: e.value,
    };
  }

  /// Respostas mínimas na semana para medir o crescimento dela.
  static const minWeekAnswers = 8;

  /// Semanas anteriores que formam a base de comparação.
  static const baselineWeeks = 4;

  /// Pontos de acerto da semana [week] acima da média das semanas
  /// anteriores (todas as profundidades juntas). `null` sem dados
  /// suficientes. É o único número que vai para o grupo ("quem mais
  /// cresceu") — o acerto em si fica com a pessoa.
  static int? weekDelta({
    required Map<String, int> correct,
    required Map<String, int> total,
    required String week,
  }) {
    final weekC = <String, int>{};
    final weekT = <String, int>{};
    for (final e in total.entries) {
      final w = e.key.split('.').first;
      weekT[w] = (weekT[w] ?? 0) + e.value;
      weekC[w] = (weekC[w] ?? 0) + (correct[e.key] ?? 0);
    }
    final nowT = weekT[week] ?? 0;
    if (nowT < minWeekAnswers) return null;
    final before = weekT.keys.where((w) => w.compareTo(week) < 0).toList()
      ..sort((a, b) => b.compareTo(a));
    var baseC = 0, baseT = 0;
    for (final w in before.take(baselineWeeks)) {
      baseC += weekC[w] ?? 0;
      baseT += weekT[w] ?? 0;
    }
    if (baseT < minAnswers) return null;
    final now = (weekC[week] ?? 0) * 100 / nowT;
    final base = baseC * 100 / baseT;
    return (now - base).round();
  }

  /// Maior evolução entre os modos, ou `null` quando ainda não dá para
  /// comparar (pouca resposta, uma semana só) ou não houve ganho.
  static ReadingGrowth? best({
    required Map<String, int> correct,
    required Map<String, int> total,
  }) {
    ReadingGrowth? top;
    for (final mode in TrailDifficulty.values) {
      final g = forMode(mode, correct: correct, total: total);
      if (g == null || g.delta < minDelta) continue;
      if (top == null || g.delta > top.delta) top = g;
    }
    return top;
  }

  /// Começo (semanas mais antigas até somar [minAnswers]) contra agora
  /// (semanas mais recentes até somar [minAnswers]), sem sobrepor.
  static ReadingGrowth? forMode(
    TrailDifficulty mode, {
    required Map<String, int> correct,
    required Map<String, int> total,
  }) {
    final suffix = '.${mode.id}';
    final weeks = [
      for (final k in total.keys)
        if (k.endsWith(suffix)) k.substring(0, k.length - suffix.length),
    ]..sort();
    if (weeks.length < 2) return null;

    int c(String w) => correct[key(w, mode.id)] ?? 0;
    int t(String w) => total[key(w, mode.id)] ?? 0;

    var i = 0, startC = 0, startT = 0;
    while (i < weeks.length && startT < minAnswers) {
      startC += c(weeks[i]);
      startT += t(weeks[i]);
      i++;
    }
    var j = weeks.length - 1, endC = 0, endT = 0;
    while (j >= i && endT < minAnswers) {
      endC += c(weeks[j]);
      endT += t(weeks[j]);
      j--;
    }
    if (startT < minAnswers || endT < minAnswers) return null;
    return ReadingGrowth(
      mode: mode,
      fromPct: (startC * 100 / startT).round(),
      toPct: (endC * 100 / endT).round(),
    );
  }
}
