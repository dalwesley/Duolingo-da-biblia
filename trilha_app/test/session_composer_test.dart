import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/models/difficulty.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/services/progress_service.dart';
import 'package:trilha_app/services/session_composer.dart';

void main() {
  group('SessionComposer adapters', () {
    test('fromBankQuestion maps to choice with all options', () {
      final bq = BankQuestion(
        id: 'g-test-01',
        trailSlug: 'genesis-1-11',
        difficulty: TrailDifficulty.semente,
        section: 'criacao',
        question: 'Quem criou?',
        options: const [
          QuestionOption(id: 'a', text: 'Deus'),
          QuestionOption(id: 'b', text: 'O acaso'),
          QuestionOption(id: 'c', text: 'Os anjos'),
        ],
        correctOptionId: 'a',
        feedbackCorrect: 'Sim.',
        feedbackWrong: const {'b': 'Não.', 'c': 'Não.'},
        verseRef: 'Gn 1:1',
      );

      final ex = SessionComposer.fromBankQuestion(bq, rng: Random(1));
      expect(ex.type, ExerciseType.choice);
      expect(ex.id, 'g-test-01');
      expect(ex.correctAnswer, 'a');
      expect(ex.options.map((o) => o.id).toSet(), {'a', 'b', 'c'});
      expect(ex.checkAnswer('a'), isTrue);
      expect(ex.checkAnswer('b'), isFalse);
    });

    test('fromBankQuestion respects true_false type', () {
      final bq = BankQuestion(
        id: 'g-vf-01',
        trailSlug: 'genesis-1-11',
        difficulty: TrailDifficulty.semente,
        section: 'criacao',
        question: 'O que Deus criou?',
        prompt: 'Deus criou somente os mares.',
        correctAnswer: 'false',
        type: ExerciseType.trueFalse,
        options: const [
          QuestionOption(id: 'a', text: 'Deus'),
          QuestionOption(id: 'b', text: 'O acaso'),
        ],
        correctOptionId: 'a',
        feedbackCorrect: 'Sim.',
        feedbackWrong: const {'b': 'Não.'},
      );
      final ex = SessionComposer.fromBankQuestion(bq);
      expect(ex.type, ExerciseType.trueFalse);
      expect(ex.prompt, 'Deus criou somente os mares.');
      expect(ex.checkAnswer('false'), isTrue);
      expect(ex.checkAnswer('true'), isFalse);
    });

    test('fromBankQuestion maps tap passage fields', () {
      final bq = BankQuestion(
        id: 'g-tap-01',
        trailSlug: 'genesis-1-11',
        difficulty: TrailDifficulty.semente,
        section: 'gen-03-imagem',
        question: 'Quem?',
        prompt: 'Quem recebe a imagem?',
        type: ExerciseType.tap,
        passageText: 'homem e mulher os criou',
        options: const [
          QuestionOption(id: 'a', text: 'homem e mulher'),
          QuestionOption(id: 'b', text: 'todo animal'),
        ],
        correctOptionId: 'a',
        correctAnswer: 'a',
        feedbackCorrect: 'Sim.',
        feedbackWrong: const {'b': 'Não.'},
        beat: 'observar',
      );
      final ex = SessionComposer.fromBankQuestion(bq);
      expect(ex.type, ExerciseType.tap);
      expect(ex.passageText, 'homem e mulher os criou');
      expect(ex.beat, 'observar');
      expect(ex.checkAnswer('a'), isTrue);
    });

    test('fromBankQuestion strips tap prompt that spoils the answer', () {
      final bq = BankQuestion(
        id: 'g-tap-spoil',
        trailSlug: 'genesis-1-11',
        difficulty: TrailDifficulty.semente,
        section: 'gen-01-criador',
        question: 'Como a terra é descrita antes das ordens criadoras?',
        prompt: 'Toque no texto: Sem forma e vazia',
        cue: 'Toque no texto: Sem forma e vazia',
        type: ExerciseType.tap,
        passageText:
            'A terra, porém, estava sem forma e vazia; havia trevas.',
        options: const [
          QuestionOption(id: 'a', text: 'Sem forma e vazia'),
          QuestionOption(id: 'b', text: 'trevas'),
        ],
        correctOptionId: 'a',
        correctAnswer: 'a',
        feedbackCorrect: 'Sim.',
        feedbackWrong: const {'b': 'Não.'},
      );
      final ex = SessionComposer.fromBankQuestion(bq);
      expect(ex.cue, 'Como a terra é descrita antes das ordens criadoras?');
      expect(ex.prompt, 'Como a terra é descrita antes das ordens criadoras?');
      expect(ex.displayCue.toLowerCase().contains('sem forma'), isFalse);
    });

    test('fromBankQuestion preserves tagged skill', () {
      final bq = BankQuestion(
        id: 'g-skill',
        trailSlug: 'genesis-1-11',
        difficulty: TrailDifficulty.semente,
        section: 'gen-03-imagem',
        question: 'O que Gênesis 1 não afirma?',
        type: ExerciseType.choice,
        skill: 'interpret',
        options: const [
          QuestionOption(id: 'a', text: 'A'),
          QuestionOption(id: 'b', text: 'B'),
        ],
        correctOptionId: 'a',
        feedbackCorrect: 'Sim.',
        feedbackWrong: const {'b': 'Não.'},
      );
      expect(SessionComposer.fromBankQuestion(bq).skill, 'interpret');
    });

    test('clipEntranceVerse keeps short verse and clips long passage', () {
      expect(
        SessionComposer.clipEntranceVerse('À imagem de Deus o criou; homem e mulher os criou.'),
        'À imagem de Deus o criou; homem e mulher os criou.',
      );
      final long = List.filled(50, 'palavra').join(' ');
      final clipped = SessionComposer.clipEntranceVerse(long);
      expect(clipped.endsWith('…'), isTrue);
      expect(clipped.split(' ').length, 40);
    });

    test('arrangeActs keeps contract order and allows a second choice', () {
      final acts = SessionComposer.arrangeActs([
        Exercise(
          id: 'c1',
          type: ExerciseType.choice,
          prompt: 'Escolha 1',
          correctAnswer: 'a',
          options: const [
            QuestionOption(id: 'a', text: 'A'),
            QuestionOption(id: 'b', text: 'B'),
          ],
        ),
        Exercise(
          id: 'c2',
          type: ExerciseType.choice,
          prompt: 'Escolha 2',
          correctAnswer: 'a',
          options: const [
            QuestionOption(id: 'a', text: 'A'),
            QuestionOption(id: 'b', text: 'B'),
          ],
        ),
        Exercise(
          id: 'v',
          type: ExerciseType.trueFalse,
          prompt: 'Afirmação.',
          correctAnswer: 'false',
        ),
        Exercise(
          id: 't',
          type: ExerciseType.tap,
          prompt: 'Toque',
          correctAnswer: 'a',
          passageText: 'homem e mulher os criou',
          options: const [
            QuestionOption(id: 'a', text: 'homem e mulher'),
            QuestionOption(id: 'b', text: 'os criou'),
          ],
        ),
        Exercise(
          id: 'o',
          type: ExerciseType.order,
          prompt: 'Ordene',
          correctAnswer: 'a,b,c',
          correctOrder: const ['a', 'b', 'c'],
          options: const [
            QuestionOption(id: 'a', text: '1'),
            QuestionOption(id: 'b', text: '2'),
            QuestionOption(id: 'c', text: '3'),
          ],
        ),
        Exercise(
          id: 'p',
          type: ExerciseType.complete,
          prompt: 'Complete',
          template: '___ e mulher',
          correctAnswer: 'a',
          options: const [
            QuestionOption(id: 'a', text: 'homem'),
            QuestionOption(id: 'b', text: 'anjo'),
          ],
        ),
        Exercise(
          id: 'n',
          type: ExerciseType.connect,
          prompt: 'Conecte',
          correctAnswer: 'a',
          passageA: const ExercisePassage(ref: 'A', text: 'imagem'),
          passageB: const ExercisePassage(ref: 'B', text: 'imagem de Deus'),
          options: const [
            QuestionOption(id: 'a', text: 'imagem'),
            QuestionOption(id: 'b', text: 'Deus'),
          ],
        ),
      ], max: 8);
      expect(acts.first.type, ExerciseType.trueFalse);
      expect(acts[1].type, ExerciseType.tap);
      expect(acts.where((e) => e.type == ExerciseType.choice).length, 2);
      expect(acts.map((e) => e.id).contains('c2'), isTrue);
      expect(acts.length, 7);
    });

    test('arrangeActs caps choice at 40% and VF at 2', () {
      final acts = SessionComposer.arrangeActs([
        Exercise(
          id: 'v1',
          type: ExerciseType.trueFalse,
          prompt: 'A.',
          correctAnswer: 'false',
        ),
        Exercise(
          id: 'v2',
          type: ExerciseType.trueFalse,
          prompt: 'B.',
          correctAnswer: 'true',
        ),
        Exercise(
          id: 'v3',
          type: ExerciseType.trueFalse,
          prompt: 'C.',
          correctAnswer: 'false',
        ),
        Exercise(
          id: 'c1',
          type: ExerciseType.choice,
          prompt: 'C1',
          correctAnswer: 'a',
          options: const [
            QuestionOption(id: 'a', text: 'A'),
            QuestionOption(id: 'b', text: 'B'),
          ],
        ),
        Exercise(
          id: 'c2',
          type: ExerciseType.choice,
          prompt: 'C2',
          correctAnswer: 'a',
          options: const [
            QuestionOption(id: 'a', text: 'A'),
            QuestionOption(id: 'b', text: 'B'),
          ],
        ),
        Exercise(
          id: 'c3',
          type: ExerciseType.choice,
          prompt: 'C3',
          correctAnswer: 'a',
          options: const [
            QuestionOption(id: 'a', text: 'A'),
            QuestionOption(id: 'b', text: 'B'),
          ],
        ),
        Exercise(
          id: 'c4',
          type: ExerciseType.choice,
          prompt: 'C4',
          correctAnswer: 'a',
          options: const [
            QuestionOption(id: 'a', text: 'A'),
            QuestionOption(id: 'b', text: 'B'),
          ],
        ),
      ], max: 7);
      expect(acts.where((e) => e.type == ExerciseType.trueFalse).length, lessThanOrEqualTo(2));
      expect(
        acts.where((e) => e.type == ExerciseType.choice).length,
        lessThanOrEqualTo(SessionComposer.maxChoiceActs(7)),
      );
    });

    test('pickDiverseBankQuestions takes one of each type', () {
      final pool = [
        BankQuestion(
          id: 'vf',
          trailSlug: 'genesis-1-11',
          difficulty: TrailDifficulty.semente,
          section: 'gen-01-criador',
          question: 'VF?',
          type: ExerciseType.trueFalse,
          prompt: 'Afirmação.',
          correctAnswer: 'false',
          options: const [],
          correctOptionId: 'false',
          feedbackCorrect: 'Ok',
          feedbackWrong: const {},
        ),
        BankQuestion(
          id: 'vf2',
          trailSlug: 'genesis-1-11',
          difficulty: TrailDifficulty.semente,
          section: 'gen-01-criador',
          question: 'VF2?',
          type: ExerciseType.trueFalse,
          prompt: 'Outra.',
          correctAnswer: 'true',
          options: const [],
          correctOptionId: 'true',
          feedbackCorrect: 'Ok',
          feedbackWrong: const {},
        ),
        BankQuestion(
          id: 'tap',
          trailSlug: 'genesis-1-11',
          difficulty: TrailDifficulty.semente,
          section: 'gen-01-criador',
          question: 'Toque?',
          type: ExerciseType.tap,
          prompt: 'Toque',
          passageText: 'sem forma e vazia',
          options: const [
            QuestionOption(id: 'a', text: 'sem forma e vazia'),
            QuestionOption(id: 'b', text: 'luz'),
          ],
          correctOptionId: 'a',
          correctAnswer: 'a',
          feedbackCorrect: 'Ok',
          feedbackWrong: const {},
        ),
        BankQuestion(
          id: 'ch',
          trailSlug: 'genesis-1-11',
          difficulty: TrailDifficulty.semente,
          section: 'gen-01-criador',
          question: 'Escolha?',
          type: ExerciseType.choice,
          options: const [
            QuestionOption(id: 'a', text: 'A'),
            QuestionOption(id: 'b', text: 'B'),
          ],
          correctOptionId: 'a',
          feedbackCorrect: 'Ok',
          feedbackWrong: const {},
        ),
      ];
      final picked = SessionComposer.pickDiverseBankQuestions(
        pool: pool,
        usedIds: {'vf'},
        max: 6,
        missionSlug: 'gen-01-criador',
      );
      expect(picked.any((q) => q.id == 'vf2'), isTrue); // unused VF preferred
      expect(picked.any((q) => q.id == 'tap'), isTrue);
      expect(picked.any((q) => q.id == 'ch'), isTrue);
      expect(picked.map((q) => q.type).toSet(), containsAll([
        ExerciseType.trueFalse,
        ExerciseType.tap,
        ExerciseType.choice,
      ]));
    });

    test('pickDiverseBankQuestions includes a second choice when filling to 8', () {
      BankQuestion choice(String id) => BankQuestion(
            id: id,
            trailSlug: 'genesis-1-11',
            difficulty: TrailDifficulty.semente,
            section: 'gen-03-imagem',
            question: id,
            type: ExerciseType.choice,
            options: const [
              QuestionOption(id: 'a', text: 'A'),
              QuestionOption(id: 'b', text: 'B'),
            ],
            correctOptionId: 'a',
            feedbackCorrect: 'Ok',
            feedbackWrong: const {},
          );
      final pool = [
        BankQuestion(
          id: 'vf',
          trailSlug: 'genesis-1-11',
          difficulty: TrailDifficulty.semente,
          section: 'gen-03-imagem',
          question: 'VF?',
          type: ExerciseType.trueFalse,
          prompt: 'Afirmação.',
          correctAnswer: 'false',
          options: const [],
          correctOptionId: 'false',
          feedbackCorrect: 'Ok',
          feedbackWrong: const {},
        ),
        BankQuestion(
          id: 'tap',
          trailSlug: 'genesis-1-11',
          difficulty: TrailDifficulty.semente,
          section: 'gen-03-imagem',
          question: 'Toque?',
          type: ExerciseType.tap,
          prompt: 'Toque',
          passageText: 'homem e mulher',
          options: const [
            QuestionOption(id: 'a', text: 'homem e mulher'),
            QuestionOption(id: 'b', text: 'luz'),
          ],
          correctOptionId: 'a',
          correctAnswer: 'a',
          feedbackCorrect: 'Ok',
          feedbackWrong: const {},
        ),
        choice('ch1'),
        choice('ch2'),
        BankQuestion(
          id: 'ord',
          trailSlug: 'genesis-1-11',
          difficulty: TrailDifficulty.semente,
          section: 'gen-03-imagem',
          question: 'Ordene',
          type: ExerciseType.order,
          options: const [
            QuestionOption(id: 'a', text: '1'),
            QuestionOption(id: 'b', text: '2'),
            QuestionOption(id: 'c', text: '3'),
          ],
          correctOptionId: 'a',
          correctOrder: const ['a', 'b', 'c'],
          feedbackCorrect: 'Ok',
          feedbackWrong: const {},
        ),
        BankQuestion(
          id: 'cmp',
          trailSlug: 'genesis-1-11',
          difficulty: TrailDifficulty.semente,
          section: 'gen-03-imagem',
          question: 'Complete',
          type: ExerciseType.complete,
          template: '___ e mulher',
          options: const [
            QuestionOption(id: 'a', text: 'homem'),
            QuestionOption(id: 'b', text: 'anjo'),
          ],
          correctOptionId: 'a',
          feedbackCorrect: 'Ok',
          feedbackWrong: const {},
        ),
        BankQuestion(
          id: 'con',
          trailSlug: 'genesis-1-11',
          difficulty: TrailDifficulty.semente,
          section: 'gen-03-imagem',
          question: 'Conecte',
          type: ExerciseType.connect,
          options: const [
            QuestionOption(id: 'a', text: 'imagem'),
            QuestionOption(id: 'b', text: 'Deus'),
          ],
          correctOptionId: 'a',
          feedbackCorrect: 'Ok',
          feedbackWrong: const {},
        ),
      ];
      final picked = SessionComposer.pickDiverseBankQuestions(
        pool: pool,
        usedIds: {},
        max: 8,
        missionSlug: 'gen-03-imagem',
        rng: Random(1),
      );
      expect(picked.where((q) => q.type == ExerciseType.choice).length, 2);
      expect(picked.length, inInclusiveRange(7, 8));
      expect(
        picked.where((q) => q.type == ExerciseType.trueFalse).length,
        lessThanOrEqualTo(2),
      );
    });

    test('reviewFromBank skips types already used in the session', () {
      // Sem cache de banco → null; o contrato é não devolver tipo bloqueado.
      // Smoke: com usedTypes cobrindo tudo, resultado deve ser null.
      final rev = SessionComposer.reviewFromBank(
        missionSlug: 'gen-01-criador',
        difficulty: TrailDifficulty.semente,
        trailSlug: 'genesis-1-11',
        usedInSession: const {'x'},
        usedTypes: {
          ExerciseType.trueFalse,
          ExerciseType.tap,
          ExerciseType.choice,
          ExerciseType.order,
          ExerciseType.complete,
          ExerciseType.connect,
        },
      );
      expect(rev, isNull);
    });

    test('pickDiverseBankQuestions synthesizes true VF when pool is all false', () {
      final pool = [
        BankQuestion(
          id: 'vf-only-false',
          trailSlug: 'genesis-1-11',
          difficulty: TrailDifficulty.semente,
          section: 'gen-01-criador',
          question: 'O que Deus criou no princípio?',
          type: ExerciseType.trueFalse,
          prompt: 'O que Deus criou no princípio: Somente os mares.',
          correctAnswer: 'false',
          options: const [
            QuestionOption(id: 'true', text: 'Verdadeiro'),
            QuestionOption(id: 'false', text: 'Falso'),
          ],
          correctOptionId: 'false',
          feedbackCorrect:
              'Correto. Gênesis 1:1 sustenta a resposta: “Os céus e a terra”.',
          feedbackWrong: const {},
        ),
      ];
      // Hash even → prefer true → must synthesize.
      final picked = SessionComposer.pickDiverseBankQuestions(
        pool: pool,
        usedIds: {},
        max: 6,
        missionSlug: 'aa', // choose slug that prefers true
        rng: Random(1),
      );
      final vf = picked.where((q) => q.type == ExerciseType.trueFalse).toList();
      expect(vf, isNotEmpty);
      // Force prefer-true path by trying both parities of usedIds length.
      final answers = <String>{};
      for (final slug in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']) {
        final p = SessionComposer.pickDiverseBankQuestions(
          pool: pool,
          usedIds: {},
          max: 1,
          missionSlug: slug,
        );
        if (p.isNotEmpty) {
          answers.add(
            SessionComposer.fromBankQuestion(p.first).correctAnswer,
          );
        }
      }
      expect(answers.contains('true'), isTrue);
    });

    test('pickDiverseBankQuestions does not repeat VF stem as true and false', () {
      final pool = [
        BankQuestion(
          id: 'vf-noe',
          trailSlug: 'genesis-1-11',
          difficulty: TrailDifficulty.semente,
          section: 'gen-06-noe',
          question: 'Quais eram os três filhos de Noé?',
          type: ExerciseType.trueFalse,
          prompt: 'Quais eram os três filhos de Noé: Caim, Abel e Sete.',
          correctAnswer: 'false',
          options: const [
            QuestionOption(id: 'true', text: 'Verdadeiro'),
            QuestionOption(id: 'false', text: 'Falso'),
          ],
          correctOptionId: 'false',
          feedbackCorrect:
              'Correto. Gênesis 6:10 sustenta a resposta: “Sem, Cam e Jafé”.',
          feedbackWrong: const {},
        ),
        BankQuestion(
          id: 'tap-1',
          trailSlug: 'genesis-1-11',
          difficulty: TrailDifficulty.semente,
          section: 'gen-06-noe',
          question: 'Toque?',
          type: ExerciseType.tap,
          prompt: 'Toque',
          passageText: 'arca',
          options: const [
            QuestionOption(id: 'a', text: 'arca'),
            QuestionOption(id: 'b', text: 'torre'),
          ],
          correctOptionId: 'a',
          correctAnswer: 'a',
          feedbackCorrect: 'Ok',
          feedbackWrong: const {},
        ),
        BankQuestion(
          id: 'ch-1',
          trailSlug: 'genesis-1-11',
          difficulty: TrailDifficulty.semente,
          section: 'gen-06-noe',
          question: 'Escolha?',
          type: ExerciseType.choice,
          options: const [
            QuestionOption(id: 'a', text: 'A'),
            QuestionOption(id: 'b', text: 'B'),
          ],
          correctOptionId: 'a',
          feedbackCorrect: 'Ok',
          feedbackWrong: const {},
        ),
      ];

      for (final slug in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'mission-x']) {
        final picked = SessionComposer.pickDiverseBankQuestions(
          pool: pool,
          usedIds: {},
          max: 6,
          missionSlug: slug,
        );
        final vf = picked.where((q) => q.type == ExerciseType.trueFalse).toList();
        expect(vf.length, lessThanOrEqualTo(1), reason: 'slug=$slug');
        final stems = vf.map((q) => q.question.trim().toLowerCase()).toSet();
        expect(stems.length, vf.length, reason: 'slug=$slug');
      }
    });

    test('fromBankQuestion normalizes VF answer to true/false ids', () {
      final bq = BankQuestion(
        id: 'vf-norm',
        trailSlug: 'genesis-1-11',
        difficulty: TrailDifficulty.semente,
        section: 'gen-01-criador',
        question: 'Q?',
        type: ExerciseType.trueFalse,
        prompt: 'Afirmação verdadeira.',
        correctAnswer: 'Verdadeiro',
        options: const [],
        correctOptionId: 'true',
        feedbackCorrect: 'Ok',
        feedbackWrong: const {},
      );
      final ex = SessionComposer.fromBankQuestion(bq);
      expect(ex.correctAnswer, 'true');
      expect(ex.checkAnswer('true'), isTrue);
      expect(ex.checkAnswer('false'), isFalse);
    });

    test('arrangeActs skips review ids', () {
      final acts = SessionComposer.arrangeActs([
        Exercise(
          id: 'genesis--sem-gen-03-imagem-review',
          type: ExerciseType.tap,
          prompt: 'Review',
          correctAnswer: 'a',
          options: const [QuestionOption(id: 'a', text: 'A')],
        ),
        Exercise(
          id: 'v',
          type: ExerciseType.trueFalse,
          prompt: 'Afirmação.',
          correctAnswer: 'false',
        ),
      ]);
      expect(acts.map((e) => e.id).toList(), ['v']);
    });

    test('fromQuestion keeps feedback and reference', () {
      const q = Question(
        question: 'O que Deus viu?',
        options: [
          QuestionOption(id: 'a', text: 'Que era bom'),
          QuestionOption(id: 'b', text: 'Que faltava luz'),
        ],
        correctOptionId: 'a',
        feedbackCorrect: 'Certo.',
        feedbackWrong: {'b': 'Leia de novo.'},
        verseRef: 'Gn 1:4',
      );
      final ex = SessionComposer.fromQuestion(q, id: 'm_q0', rng: Random(2));
      expect(ex.id, 'm_q0');
      expect(ex.reference, 'Gn 1:4');
      expect(ex.feedbackCorrect, 'Certo.');
      expect(ex.feedbackFor('b', correct: false), 'Leia de novo.');
    });
  });

  group('SessionComposer.compose', () {
    test('sem banco: questions embutidas viram choice', () async {
      SharedPreferences.setMockInitialValues({});
      final progress = ProgressService();
      await progress.load();

      const mission = Mission(
        slug: 'demo',
        title: 'Demo',
        intro: 'oi',
        type: 'lesson',
        stepsReward: 10,
        questions: [
          Question(
            question: 'P1',
            options: [
              QuestionOption(id: 'a', text: 'A'),
              QuestionOption(id: 'b', text: 'B'),
            ],
            correctOptionId: 'a',
            feedbackCorrect: 'ok',
            feedbackWrong: {'b': 'no'},
          ),
        ],
        centralInsight: 'Insight da missão',
      );

      final plan = await SessionComposer.compose(
        mission: mission,
        missionSlug: 'demo',
        usesBank: false,
        progress: progress,
        rng: Random(0),
      );

      expect(plan.fromAuthoredExercises, isFalse);
      expect(plan.acts, hasLength(1));
      expect(plan.acts.first.type, ExerciseType.choice);
      expect(plan.acts.first.prompt, 'P1');
      expect(plan.insight, 'Insight da missão');
      expect(plan.isEmpty, isFalse);
    });

    test('missão vazia → plan.isEmpty', () async {
      SharedPreferences.setMockInitialValues({});
      final progress = ProgressService();
      await progress.load();

      const mission = Mission(
        slug: 'empty',
        title: 'Vazio',
        intro: '',
        type: 'lesson',
        stepsReward: 10,
        questions: [],
      );

      final plan = await SessionComposer.compose(
        mission: mission,
        missionSlug: 'empty-unknown',
        usesBank: false,
        progress: progress,
      );

      expect(plan.isEmpty, isTrue);
    });

    test('mission.exercises embutidos são ignorados (só banco)', () async {
      SharedPreferences.setMockInitialValues({});
      final progress = ProgressService();
      await progress.load();

      const mission = Mission(
        slug: 'gen-03-imagem',
        title: 'Imagem',
        intro: '',
        type: 'lesson',
        stepsReward: 50,
        questions: [],
        centralInsight: 'Do banco / missão Firestore',
        exercises: [
          Exercise(
            id: 'local-ignored',
            type: ExerciseType.trueFalse,
            prompt: 'Não deve aparecer',
            correctAnswer: 'false',
          ),
        ],
      );

      final plan = await SessionComposer.compose(
        mission: mission,
        missionSlug: 'gen-03-imagem',
        trailSlug: 'genesis-1-11',
        usesBank: false,
        progress: progress,
      );

      expect(plan.acts.any((e) => e.id == 'local-ignored'), isFalse);
      expect(plan.isEmpty, isTrue);
      expect(plan.insight, 'Do banco / missão Firestore');
    });
  });
}
