import 'package:flutter_test/flutter_test.dart';

import 'package:trilha_app/data/question_bank.dart';
import 'package:trilha_app/models/difficulty.dart';
import 'package:trilha_app/models/trail.dart';

BankQuestion _q({
  required String id,
  required String section,
  TrailDifficulty difficulty = TrailDifficulty.semente,
  String trail = 'genesis-1-11',
}) {
  return BankQuestion(
    id: id,
    trailSlug: trail,
    difficulty: difficulty,
    section: section,
    question: 'Q $id',
    options: const [
      QuestionOption(id: 'a', text: 'A'),
      QuestionOption(id: 'b', text: 'B'),
    ],
    correctOptionId: 'a',
    feedbackCorrect: 'ok',
    feedbackWrong: const {'b': 'no'},
  );
}

void main() {
  group('QuestionBank.matchesMissionSection', () {
    test('matches exact section', () {
      final q = _q(id: 'x', section: 'gen-01-criador');
      expect(QuestionBank.matchesMissionSection(q, 'gen-01-criador'), isTrue);
      expect(QuestionBank.matchesMissionSection(q, 'gen-02-dias'), isFalse);
    });

    test('matches section embedded in id when section field is legacy', () {
      final q = _q(
        id: 'genesis--sem-gen-01-criador-01',
        section: 'criacao',
      );
      expect(QuestionBank.matchesMissionSection(q, 'gen-01-criador'), isTrue);
      expect(QuestionBank.matchesMissionSection(q, 'gen-02-dias'), isFalse);
    });
  });
}
