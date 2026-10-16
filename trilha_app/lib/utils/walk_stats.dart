import '../models/difficulty.dart';
import '../models/exercise.dart';

/// Acertos de primeira sobre o total respondido.
class Accuracy {
  final int correct;
  final int total;

  const Accuracy(this.correct, this.total);

  /// 0–100, arredondado. 0 sem respostas.
  int get percent => total == 0 ? 0 : (correct * 100 / total).round();
}

/// Números de "Minha caminhada", derivados do progresso salvo.
class WalkStats {
  /// Respostas mínimas num gesto para ele virar ponto forte ou a reforçar.
  static const minGestureAnswers = 5;

  final Map<TrailDifficulty, Accuracy> byMode;

  /// Gestos com pelo menos uma resposta, do mais respondido ao menos.
  final List<(ExerciseType, Accuracy)> byGesture;

  /// Cenas novas por mês do ano (índice 0 = janeiro).
  final List<int> scenesPerMonth;
  final int daysWalkedThisYear;

  const WalkStats({
    required this.byMode,
    required this.byGesture,
    required this.scenesPerMonth,
    required this.daysWalkedThisYear,
  });

  int get scenesThisYear => scenesPerMonth.fold(0, (a, b) => a + b);

  int get answered => byMode.values.fold(0, (a, b) => a + b.total);

  List<(ExerciseType, Accuracy)> get _rankable => [
    for (final g in byGesture)
      if (g.$2.total >= minGestureAnswers) g,
  ];

  /// Gesto com maior acerto (entre os com respostas suficientes).
  (ExerciseType, Accuracy)? get strongest {
    final r = _rankable;
    if (r.length < 2) return null;
    return r.reduce((a, b) => b.$2.percent > a.$2.percent ? b : a);
  }

  /// Gesto com menor acerto — o que mais pede reforço.
  (ExerciseType, Accuracy)? get weakest {
    final r = _rankable;
    if (r.length < 2) return null;
    final low = r.reduce((a, b) => b.$2.percent < a.$2.percent ? b : a);
    return low.$1 == strongest?.$1 ? null : low;
  }

  /// [answerCorrect]/[answerTotal] usam chaves `modo.gesto` (ex.: `semente.tap`).
  factory WalkStats.from({
    required Map<String, int> answerCorrect,
    required Map<String, int> answerTotal,
    required Map<String, String> missionCompletedOn,
    required List<String> playDates,
    required int year,
  }) {
    final modeC = <TrailDifficulty, int>{};
    final modeT = <TrailDifficulty, int>{};
    final gestC = <ExerciseType, int>{};
    final gestT = <ExerciseType, int>{};
    for (final e in answerTotal.entries) {
      final dot = e.key.indexOf('.');
      if (dot <= 0) continue;
      final mode = TrailDifficulty.fromId(e.key.substring(0, dot));
      final type = ExerciseType.fromId(e.key.substring(dot + 1));
      final c = answerCorrect[e.key] ?? 0;
      if (mode != null) {
        modeT[mode] = (modeT[mode] ?? 0) + e.value;
        modeC[mode] = (modeC[mode] ?? 0) + c;
      }
      gestT[type] = (gestT[type] ?? 0) + e.value;
      gestC[type] = (gestC[type] ?? 0) + c;
    }

    final gestures = [
      for (final t in gestT.keys) (t, Accuracy(gestC[t] ?? 0, gestT[t]!)),
    ]..sort((a, b) => b.$2.total.compareTo(a.$2.total));

    final prefix = '${year.toString().padLeft(4, '0')}-';
    final months = List<int>.filled(12, 0);
    for (final day in missionCompletedOn.values) {
      if (!day.startsWith(prefix) || day.length < 7) continue;
      final m = int.tryParse(day.substring(5, 7));
      if (m != null && m >= 1 && m <= 12) months[m - 1]++;
    }

    return WalkStats(
      byMode: {
        for (final m in TrailDifficulty.values)
          m: Accuracy(modeC[m] ?? 0, modeT[m] ?? 0),
      },
      byGesture: gestures,
      scenesPerMonth: months,
      daysWalkedThisYear: playDates.where((d) => d.startsWith(prefix)).length,
    );
  }
}
