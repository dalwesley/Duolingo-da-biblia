import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/difficulty.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/services/session_composer.dart';
import 'package:trilha_app/utils/answer_phrase.dart';

void main() {
  test('grows e a terra into o céu e a terra', () {
    const passage = 'No princípio, criou Deus o céu e a terra.';
    expect(growInPassage(passage, 'e a terra'), 'o céu e a terra');
    expect(isIncompletePhrase('e a terra'), isTrue);
    expect(isIncompletePhrase('o céu e a terra'), isFalse);
  });

  test('repairActOptions completes Genesis 1:1 choice', () {
    final repaired = repairActOptions(
      options: const [
        QuestionOption(id: 'a', text: 'e a terra'),
        QuestionOption(id: 'b', text: 'princípio'),
        QuestionOption(id: 'c', text: 'criou'),
      ],
      correctId: 'a',
      passage: 'No princípio, criou Deus o céu e a terra.',
      quote: 'Os céus e a terra',
      question: 'O que Deus criou no princípio?',
    );
    final correct = repaired.options.firstWhere((o) => o.id == 'a');
    expect(correct.text, 'o céu e a terra');
    expect(repaired.options.every((o) => !isIncompletePhrase(o.text)), isTrue);
    expect(
      repaired.options.where((o) => o.id != 'a').every((o) => !isWeakDistractor(o.text)),
      isTrue,
    );
  });

  test('fromBankQuestion surfaces the full object of creation', () {
    final ex = SessionComposer.fromBankQuestion(
      BankQuestion(
        id: 'genesis--sem-gen-01-criador-01',
        difficulty: TrailDifficulty.semente,
        section: 'gen-01-criador',
        question: 'O que Deus criou no princípio?',
        type: ExerciseType.choice,
        options: const [
          QuestionOption(id: 'a', text: 'e a terra'),
          QuestionOption(id: 'b', text: 'princípio'),
          QuestionOption(id: 'c', text: 'criou'),
        ],
        correctOptionId: 'a',
        correctAnswer: 'a',
        feedbackCorrect:
            'Correto. Gênesis 1:1 sustenta a resposta: “Os céus e a terra”.',
        feedbackWrong: const {},
        verseRef: 'Gênesis 1:1',
        passageText: 'No princípio, criou Deus o céu e a terra.',
      ),
      rng: Random(1),
    );
    final correct = ex.options.firstWhere((o) => o.id == 'a');
    expect(correct.text, 'o céu e a terra');
  });

  test('grown answer keeps the option capital so it does not stand out', () {
    final repaired = repairActOptions(
      options: const [
        QuestionOption(id: 'a', text: 'Setenta e cinco anos'),
        QuestionOption(id: 'b', text: 'Setenta anos'),
        QuestionOption(id: 'c', text: 'Sessenta e cinco anos'),
        QuestionOption(id: 'd', text: 'Oitenta anos'),
      ],
      correctId: 'a',
      passage:
          'Partiu, portanto, Abrão conforme o que o SENHOR lhe ordenara, e Ló o acompanhou. Abrão contava setenta e cinco anos ao deixar Harã.',
      question: 'Segundo Gênesis 12:4, quantos anos Abrão tinha ao deixar Harã?',
    );
    final correct = repaired.options.firstWhere((o) => o.id == 'a');
    expect(correct.text, 'Setenta e cinco anos');
  });

  test('matchLeadCase never lowers a proper name', () {
    expect(matchLeadCase('Deus criou', 'criou'), 'Deus criou');
    expect(matchLeadCase('o céu e a terra', 'e a terra'), 'o céu e a terra');
  });

  test('naming choice keeps Ismael and drops the verse lead-in', () {
    const passage =
        'Ora, Sarai, mulher de Abrão, não lhe dava filhos; mas tinha uma serva egípcia, que se chamava Agar.';
    expect(isNamingAsk('Como se chama o filho de Agar?'), isTrue);
    expect(isPassagePrefix('Ora, Sarai, mulher de Abrão, não lhe dava', passage),
        isTrue);
    expect(
      preferredAnswer(
        option: 'Ismael',
        passage: passage,
        question: 'Como se chama o filho de Agar?',
      ),
      'Ismael',
    );

    final repaired = repairActOptions(
      options: const [
        QuestionOption(id: 'a', text: 'el-Roi'),
        QuestionOption(id: 'b', text: 'serva egípcia'),
        QuestionOption(id: 'c', text: 'Ora, Sarai, mulher de Abrão, não lhe dava'),
        QuestionOption(id: 'd', text: 'Isaque'),
      ],
      correctId: 'a',
      passage: passage,
      question: 'Como se chama o filho de Agar?',
    );
    expect(
      repaired.options.any((o) => isPassagePrefix(o.text, passage)),
      isFalse,
    );
  });

  test('fromBankQuestion does not grow a proper name into the verse', () {
    final ex = SessionComposer.fromBankQuestion(
      BankQuestion(
        id: 'genesis-12-50-sem-gen12-05-agar-ismael-02',
        difficulty: TrailDifficulty.semente,
        section: 'gen12-05-agar-ismael',
        question: 'Como se chama o filho de Agar?',
        type: ExerciseType.choice,
        options: const [
          QuestionOption(id: 'a', text: 'Ismael'),
          QuestionOption(id: 'b', text: 'Isaque'),
          QuestionOption(id: 'c', text: 'Esaú'),
        ],
        correctOptionId: 'a',
        correctAnswer: 'a',
        feedbackCorrect: 'Correto. Gênesis 16: “Ismael”.',
        feedbackWrong: const {},
        verseRef: 'Gênesis 16',
        passageText:
            'Ora, Sarai, mulher de Abrão, não lhe dava filhos; mas tinha uma serva egípcia, que se chamava Agar.',
      ),
      rng: Random(1),
    );
    expect(ex.options.map((o) => o.text), contains('Ismael'));
    expect(
      ex.options.any(
        (o) => o.text.startsWith('Ora, Sarai'),
      ),
      isFalse,
    );
  });

  test('choiceServeable drops naming MCQ whose options start the verse', () {
    const passage =
        'Ora, Sarai, mulher de Abrão, não lhe dava filhos; mas tinha uma serva egípcia, que se chamava Agar.';
    final bad = BankQuestion(
      id: 'bad-agar',
      difficulty: TrailDifficulty.semente,
      section: 'gen12-05-agar-ismael',
      question: 'Como se chama o filho de Agar?',
      type: ExerciseType.choice,
      options: const [
        QuestionOption(id: 'a', text: 'el-Roi'),
        QuestionOption(id: 'b', text: 'mulher de Abrão'),
        QuestionOption(id: 'c', text: 'Ora, Sarai, mulher de Abrão, não lhe dava'),
      ],
      correctOptionId: 'a',
      correctAnswer: 'a',
      feedbackCorrect: '',
      feedbackWrong: const {},
      passageText: passage,
    );
    final good = BankQuestion(
      id: 'good-agar',
      difficulty: TrailDifficulty.semente,
      section: 'gen12-05-agar-ismael',
      question: 'Como se chama o filho de Agar?',
      type: ExerciseType.choice,
      options: const [
        QuestionOption(id: 'a', text: 'Ismael'),
        QuestionOption(id: 'b', text: 'Isaque'),
        QuestionOption(id: 'c', text: 'Esaú'),
      ],
      correctOptionId: 'a',
      correctAnswer: 'a',
      feedbackCorrect: '',
      feedbackWrong: const {},
      passageText: passage,
    );
    expect(SessionComposer.choiceServeable(bad), isFalse);
    expect(SessionComposer.choiceServeable(good), isTrue);
  });

  test('repair filler never reuses the correct id', () {
    final repaired = repairActOptions(
      options: const [
        QuestionOption(id: 'a', text: 'e'),
        QuestionOption(id: 'b', text: 'Deus é o centro de tudo'),
        QuestionOption(id: 'c', text: 'de'),
      ],
      correctId: 'b',
      question: 'O que o trecho afirma?',
    );
    final ids = repaired.options.map((o) => o.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(repaired.options.where((o) => o.id == 'b').length, 1);
    expect(
      repaired.options.firstWhere((o) => o.id == 'b').text,
      'Deus é o centro de tudo',
    );
  });

  test('fromBankQuestion repairs on the same id it grades', () {
    final ex = SessionComposer.fromBankQuestion(
      BankQuestion(
        id: 'genesis-1-11-cam-gen-01-criador-03',
        difficulty: TrailDifficulty.caminhada,
        section: 'gen-01-criador',
        question: 'O que o trecho afirma sobre a criação?',
        type: ExerciseType.choice,
        options: const [
          QuestionOption(id: 'a', text: 'e'),
          QuestionOption(id: 'b', text: 'Deus é o autor de tudo'),
          QuestionOption(id: 'c', text: 'de'),
        ],
        // `correctOptionId` no default 'a'; quem vale é `correctAnswer`.
        correctOptionId: 'a',
        correctAnswer: 'b',
        feedbackCorrect: 'Correto.',
        feedbackWrong: const {},
        verseRef: 'Gênesis 1:1',
      ),
      rng: Random(1),
    );
    final ids = ex.options.map((o) => o.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(ex.correctAnswer, 'b');
    expect(
      ex.options.firstWhere((o) => o.id == 'b').text,
      'Deus é o autor de tudo',
    );
    expect(ex.options.any((o) => isWeakDistractor(o.text)), isFalse);
  });
}
