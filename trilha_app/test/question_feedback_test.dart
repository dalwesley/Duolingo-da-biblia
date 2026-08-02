import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/utils/question_feedback.dart';

Question _q({
  required String correct,
  Map<String, String> feedbackWrong = const {},
  String? verseRef,
}) {
  return Question(
    question: 'Pergunta?',
    options: const [
      QuestionOption(id: 'a', text: 'Céus e terra'),
      QuestionOption(id: 'b', text: 'Só os mares'),
      QuestionOption(id: 'c', text: 'O Éden'),
      QuestionOption(id: 'd', text: 'A arca'),
    ],
    correctOptionId: correct,
    feedbackCorrect: 'Certo.',
    feedbackWrong: feedbackWrong,
    verseRef: verseRef,
  );
}

void main() {
  group('QuestionFeedback', () {
    test('uses specific per-option wrong feedback', () {
      final q = _q(
        correct: 'a',
        feedbackWrong: const {'b': 'Os mares vêm depois — Gênesis 1:1.'},
      );
      expect(
        QuestionFeedback.wrongMessage(q, 'b'),
        'Os mares vêm depois — Gênesis 1:1.',
      );
    });

    test('ignores generic admin stub and teaches the correct answer', () {
      final q = _q(
        correct: 'a',
        feedbackWrong: const {
          'b': 'Resposta incorreta. Revise o texto.',
        },
        verseRef: 'Gênesis 1:1',
      );
      expect(
        QuestionFeedback.wrongMessage(q, 'b'),
        'A resposta certa é “Céus e terra”. Relê Gênesis 1:1.',
      );
    });

    test('falls back without verse ref', () {
      final q = _q(correct: 'a');
      expect(
        QuestionFeedback.wrongMessage(q, 'c'),
        'A resposta certa é “Céus e terra”. Volte ao texto e compare.',
      );
    });
  });
}
