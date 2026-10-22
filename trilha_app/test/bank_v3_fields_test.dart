import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/data/mission_study.dart';
import 'package:trilha_app/models/difficulty.dart';
import 'package:trilha_app/models/exercise.dart';

void main() {
  group('Banco V3: dica, trecho e fatos', () {
    test('BankQuestion lê e grava a dica', () {
      final bq = BankQuestion.fromJson({
        'id': 'genesis-1-11-sem-gen-01-criador-01',
        'difficulty': 'semente',
        'section': 'gen-01-criador',
        'question':
            'Em Gênesis 1:2, o Espírito de Deus pairava sobre as águas.',
        'type': 'true_false',
        'correctOptionId': 'true',
        'feedbackCorrect': 'O texto diz.',
        'evidenceSpan': 'o Espírito de Deus pairava sobre as águas',
        'hint': 'Olhe o fim do versículo.',
      });
      expect(bq.hint, 'Olhe o fim do versículo.');
      expect(bq.toJson()['hint'], 'Olhe o fim do versículo.');
      expect(bq.withOverlay().hint, 'Olhe o fim do versículo.');
    });

    test('dica em texto liga o botão Dica até em ordenar', () {
      const withHint = Exercise(
        id: 'x',
        type: ExerciseType.order,
        prompt: 'Monte',
        correctAnswer: 'a,b,c',
        retryHint: 'O versículo começa pela terra.',
      );
      const without = Exercise(
        id: 'y',
        type: ExerciseType.order,
        prompt: 'Monte',
        correctAnswer: 'a,b,c',
      );
      expect(withHint.textHint, 'O versículo começa pela terra.');
      expect(withHint.supportsHint, isTrue);
      expect(without.textHint, isNull);
      expect(without.supportsHint, isFalse);
    });

    test('MissionStudy lê os fatos com o trecho que prova', () {
      final study = MissionStudy.fromMap({
        'passageRef': 'Gênesis 1:1–3',
        'passageText': 'No princípio, Deus criou os céus e a terra.',
        'context': '',
        'keyword': '',
        'keywordGloss': '',
        'focusQuestion': '',
        'facts': [
          {
            'text': 'Deus é quem cria os céus e a terra.',
            'evidenceRef': 'Gênesis 1:1',
            'evidenceSpan': 'Deus criou os céus e a terra',
          },
          {'text': ''},
        ],
      });
      expect(study.facts, hasLength(1));
      expect(study.facts.first.evidenceSpan, 'Deus criou os céus e a terra');
      expect(study.localizedFacts.first.text, study.facts.first.text);
    });

    test('estudo sem fatos segue vazio', () {
      final study = MissionStudy.fromMap({'passageRef': 'Gênesis 1:1'});
      expect(study.facts, isEmpty);
    });
  });
}
