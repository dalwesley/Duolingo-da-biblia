import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/difficulty.dart';
import 'package:trilha_app/models/exercise.dart';
import 'package:trilha_app/utils/walk_stats.dart';

void main() {
  WalkStats build({
    Map<String, int> correct = const {},
    Map<String, int> total = const {},
  }) => WalkStats.from(answerCorrect: correct, answerTotal: total);

  test('sums accuracy by mode and by gesture', () {
    final s = build(
      correct: {'semente.tap': 4, 'semente.choice': 1, 'caminhada.tap': 2},
      total: {'semente.tap': 5, 'semente.choice': 5, 'caminhada.tap': 2},
    );
    expect(s.byMode[TrailDifficulty.semente]!.percent, 50);
    expect(s.byMode[TrailDifficulty.caminhada]!.percent, 100);
    expect(s.byMode[TrailDifficulty.profundezas]!.total, 0);
    final tap = s.byGesture.firstWhere((g) => g.$1 == ExerciseType.tap).$2;
    expect((tap.correct, tap.total), (6, 7));
    expect(s.byGesture.first.$1, ExerciseType.tap);
  });

  test('strong and weak need enough answers in two gestures', () {
    final few = build(correct: {'semente.tap': 4}, total: {'semente.tap': 5});
    expect(few.strongest, isNull);
    expect(few.weakest, isNull);

    final s = build(
      correct: {'semente.tap': 5, 'semente.order': 1, 'semente.choice': 1},
      total: {'semente.tap': 5, 'semente.order': 5, 'semente.choice': 2},
    );
    expect(s.strongest!.$1, ExerciseType.tap);
    expect(s.weakest!.$1, ExerciseType.order);
  });
}
