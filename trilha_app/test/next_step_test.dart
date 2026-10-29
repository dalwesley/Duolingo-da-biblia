import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/difficulty.dart';
import 'package:trilha_app/models/exercise.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/utils/next_step.dart';
import 'package:trilha_app/utils/trail_progress.dart';

Mission _m(String slug) => Mission(
  slug: slug,
  title: slug,
  intro: '',
  type: 'lesson',
  stepsReward: 10,
  questions: const [],
);

Trail _trail(String slug, List<String> scenes, {int order = 1}) => Trail(
  slug: slug,
  title: slug,
  description: '',
  icon: '',
  order: order,
  comingSoon: false,
  color: '#000000',
  realmId: 'antigo-testamento',
  categoryId: 'pentateuco',
  modules: [
    TrailModule(
      title: 'm',
      icon: '',
      trailSlug: slug,
      index: 0,
      missions: [for (final s in scenes) _m(s)],
    ),
  ],
);

void main() {
  final gen = _trail('gen', ['g1', 'g2', 'g3']);
  final ex = _trail('ex', ['e1', 'e2'], order: 2);
  final trails = [gen, ex];

  NextStep? pick({
    List<String> completed = const ['g1', 'g2', 'g3'],
    Map<String, List<String>> cleared = const {
      'gen': ['semente'],
    },
    Map<String, String> modes = const {'gen': 'semente'},
    int correct = 9,
    int total = 10,
    Map<String, int> answerCorrect = const {},
    Map<String, int> answerTotal = const {},
    Map<String, String> snoozed = const {},
  }) => NextStepPicker.pick(
    trails: trails,
    completed: completed,
    clearedTrailModes: cleared,
    trailModes: modes,
    trailAnswerCorrect: {'gen': correct},
    trailAnswerTotal: {'gen': total},
    answerCorrect: answerCorrect,
    answerTotal: answerTotal,
    lastMissionSlug: 'g3',
    snoozedUntil: snoozed,
    today: '2026-10-29',
  );

  group('Aprofundar', () {
    test('trilha firme recém-selada sugere o modo seguinte', () {
      final step = pick();
      expect(step, isA<DeepenStep>());
      step as DeepenStep;
      expect(step.trail.slug, 'gen');
      expect(step.mode, TrailDifficulty.caminhada);
      expect(step.percent, 90);
    });

    test('abaixo de 80% ou com poucas respostas não sugere', () {
      expect(pick(correct: 7), isNull);
      expect(pick(correct: 5, total: 5), isNull);
    });

    test('já aprofundando (cena feita no modo novo) não sugere', () {
      expect(
        pick(
          completed: const ['g1', 'x', 'y'],
          modes: const {'gen': 'caminhada'},
        ),
        isNull,
      );
    });

    test('"Agora não" esconde até o dia marcado', () {
      expect(
        pick(snoozed: const {'deepen:gen:caminhada': '2026-11-05'}),
        isNull,
      );
      expect(
        pick(snoozed: const {'deepen:gen:caminhada': '2026-10-29'}),
        isA<DeepenStep>(),
      );
    });

    test('menos de 3 cenas: nada', () {
      expect(pick(completed: const ['g1', 'g2']), isNull);
    });
  });

  group('Reforçar', () {
    test('gesto com 10+ respostas abaixo de 60% vira sugestão', () {
      final step = pick(
        correct: 5,
        answerCorrect: const {'semente.order': 4, 'semente.tap': 9},
        answerTotal: const {'semente.order': 10, 'semente.tap': 10},
      );
      expect(step, isA<ReinforceStep>());
      step as ReinforceStep;
      expect(step.gesture, ExerciseType.order);
      expect(step.accuracy.percent, 40);
    });

    test('poucas respostas ou acerto bom: nada', () {
      expect(
        pick(
          correct: 5,
          answerCorrect: const {'semente.order': 2},
          answerTotal: const {'semente.order': 5},
        ),
        isNull,
      );
      expect(
        pick(
          correct: 5,
          answerCorrect: const {'semente.order': 7},
          answerTotal: const {'semente.order': 10},
        ),
        isNull,
      );
    });
  });

  group('Carrossel do herói', () {
    test('trilha selada sai; a aprofundada (modo fixado) volta', () {
      final done = const ['g1', 'g2', 'g3'];
      final cleared = const {
        'gen': ['semente'],
      };
      expect(
        TrailProgress.availableTrails(
          trails,
          done,
          clearedTrailModes: cleared,
        ).map((t) => t.slug),
        ['ex'],
      );
      // Escolheu Compreensão: as cenas zeraram e o modo ficou fixado.
      expect(
        TrailProgress.availableTrails(
          trails,
          const [],
          clearedTrailModes: cleared,
          trailModes: const {'gen': 'caminhada'},
          pinnedModes: const {'gen': 'caminhada'},
        ).map((t) => t.slug).toSet(),
        {'gen', 'ex'},
      );
    });
  });
}
