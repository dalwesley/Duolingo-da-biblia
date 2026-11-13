import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/exercise.dart';
import 'package:trilha_app/models/scene_takeaway.dart';

Exercise ex(
  String id,
  String fb, {
  ExerciseType type = ExerciseType.choice,
  String? ref,
}) => Exercise(
  id: id,
  type: type,
  prompt: 'p',
  correctAnswer: 'a',
  feedbackCorrect: fb,
  reference: ref,
);

void main() {
  test(
    'acertos viram achados, erros viram "para rever", cópias e genéricos saem',
    () {
      final exercises = [
        ex(
          'a',
          'Habitar entre nós mostra que Deus se aproximou.',
          ref: 'João 1:14',
        ),
        ex('b', 'Correto.'),
        ex(
          'c',
          'Todas as coisas foram feitas por meio do Verbo.',
          ref: 'João 1:3',
        ),
        ex('d', 'A luz resplandece nas trevas e não é vencida.'),
        ex(
          'e',
          'Insight final do dia que não é pergunta.',
          type: ExerciseType.insight,
        ),
        ex('c2', 'Todas as coisas foram feitas por meio do Verbo.'),
      ];
      final out = SceneTakeaway.fromSession(
        exercises: exercises,
        results: {0: true, 1: true, 2: true, 3: false, 4: true, 5: true},
        requeued: {5},
      );
      expect(out.map((t) => t.text), [
        'Habitar entre nós mostra que Deus se aproximou.',
        'Todas as coisas foram feitas por meio do Verbo.',
        'A luz resplandece nas trevas e não é vencida.',
      ]);
      expect(out.first.reference, 'João 1:14');
      expect(out.last.missed, isTrue);
      expect(out.where((t) => !t.missed).length, 2);
    },
  );

  test('limita a 3 achados e 2 para rever', () {
    final exercises = [
      for (var i = 0; i < 8; i++)
        ex('$i', 'Frase longa o bastante número $i do texto.'),
    ];
    final out = SceneTakeaway.fromSession(
      exercises: exercises,
      results: {for (var i = 0; i < 8; i++) i: i.isEven},
      requeued: const {},
    );
    expect(out.where((t) => !t.missed).length, 3);
    expect(out.where((t) => t.missed).length, 2);
  });
}
