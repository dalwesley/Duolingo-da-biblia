import '../models/difficulty.dart';
import '../models/exercise.dart';

/// Pergunta candidata ao reforço (só o que a escolha precisa).
typedef ReinforceCandidate = ({
  String id,
  ExerciseType type,
  TrailDifficulty mode,
});

/// Reforço do ponto fraco: perguntas do gesto em que a pessoa mais erra,
/// tiradas das cenas que ela já fez.
class ReinforcePicker {
  static const maxQuestions = 5;

  /// Até [max] ids do [gesture]. Ordem: erradas antes, depois o [mode] mais
  /// fraco, depois as ainda não vistas. Sem repetir id.
  static List<String> pick({
    required List<ReinforceCandidate> pool,
    required ExerciseType gesture,
    TrailDifficulty? mode,
    required Set<String> mistakes,
    required Set<String> used,
    int max = maxQuestions,
  }) {
    int score(ReinforceCandidate q) =>
        (mistakes.contains(q.id) ? 4 : 0) +
        (mode != null && q.mode == mode ? 2 : 0) +
        (used.contains(q.id) ? 0 : 1);

    final seen = <String>{};
    final matches = [
      for (final q in pool)
        if (q.type == gesture && seen.add(q.id)) q,
    ];
    // Sort estável: empate mantém a ordem das cenas.
    final indexed = matches.asMap().entries.toList()
      ..sort((a, b) {
        final byScore = score(b.value).compareTo(score(a.value));
        return byScore != 0 ? byScore : a.key.compareTo(b.key);
      });
    return [for (final e in indexed.take(max)) e.value.id];
  }
}
