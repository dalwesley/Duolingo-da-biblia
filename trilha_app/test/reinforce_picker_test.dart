import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/difficulty.dart';
import 'package:trilha_app/models/exercise.dart';
import 'package:trilha_app/utils/reinforce_picker.dart';
import 'package:trilha_app/utils/walk_stats.dart';

void main() {
  ReinforceCandidate q(String id, ExerciseType t, TrailDifficulty m) =>
      (id: id, type: t, mode: m);
  const tap = ExerciseType.tap;
  const order = ExerciseType.order;
  const sem = TrailDifficulty.semente;
  const cam = TrailDifficulty.caminhada;

  test(
    'only the weak gesture, mistakes first, then weak mode, then unseen',
    () {
      final ids = ReinforcePicker.pick(
        pool: [
          q('a', order, sem),
          q('b', order, cam),
          q('c', tap, cam),
          q('d', order, sem),
          q('e', order, sem),
        ],
        gesture: order,
        mode: cam,
        mistakes: {'e'},
        used: {'a'},
      );
      expect(ids, ['e', 'b', 'd', 'a']);
    },
  );

  test('caps at max and drops duplicates', () {
    final ids = ReinforcePicker.pick(
      pool: [for (var i = 0; i < 9; i++) q('x${i % 7}', tap, sem)],
      gesture: tap,
      mistakes: const {},
      used: const {},
    );
    expect(ids, hasLength(ReinforcePicker.maxQuestions));
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('weakest mode needs two modes with enough answers', () {
    final one = WalkStats.from(
      answerCorrect: {'semente.tap': 2},
      answerTotal: {'semente.tap': 5},
    );
    expect(one.weakestMode, isNull);
    final two = WalkStats.from(
      answerCorrect: {'semente.tap': 5, 'caminhada.tap': 2},
      answerTotal: {'semente.tap': 5, 'caminhada.tap': 5},
    );
    expect(two.weakestMode, cam);
  });
}
