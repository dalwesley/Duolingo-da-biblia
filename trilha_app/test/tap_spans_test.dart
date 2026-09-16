import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/trail.dart';

void main() {
  group('buildTapSpans', () {
    test('marks the full answer phrase as one tap target', () {
      const passage =
          'Viu Deus a luz que era boa e fez separação entre a luz e as trevas.';
      final spans = buildTapSpans(passage, const [
        QuestionOption(id: 'a', text: 'separação entre a luz e as trevas'),
        QuestionOption(id: 'b', text: 'a luz que era boa'),
        QuestionOption(id: 'c', text: 'Viu Deus'),
      ]);

      final taps = spans.where((s) => s.optionId != null).toList();
      expect(taps.map((s) => s.optionId), ['c', 'b', 'a']);
      expect(taps.map((s) => s.text), [
        'Viu Deus',
        'a luz que era boa',
        'separação entre a luz e as trevas',
      ]);
    });

    test('keeps adjacent short options as distinct targets', () {
      const passage =
          'Viu Deus a luz que era boa e fez separação entre a luz e as trevas.';
      final spans = buildTapSpans(passage, const [
        QuestionOption(id: 'a', text: 'trevas'),
        QuestionOption(id: 'b', text: 'separação'),
        QuestionOption(id: 'c', text: 'entre'),
      ]);

      final taps = spans.where((s) => s.optionId != null).toList();
      expect(taps.map((s) => '${s.optionId}:${s.text}'), [
        'b:separação',
        'c:entre',
        'a:trevas',
      ]);
    });

    test('does not match a word inside another word', () {
      const passage = 'Houve tarde e houve manhã, dia primeiro.';
      final spans = buildTapSpans(passage, const [
        QuestionOption(id: 'a', text: 'tarde'),
        QuestionOption(id: 'b', text: 'de'),
      ]);

      expect(spans.where((s) => s.optionId != null).map((s) => s.text), [
        'tarde',
      ]);
    });
  });

  test('tap gesture uses Toque as the action verb', () {
    const ex = Exercise(
      id: 't',
      type: ExerciseType.tap,
      prompt: 'O que Deus separou no primeiro dia?',
      correctAnswer: 'a',
      passageText:
          'Viu Deus a luz que era boa e fez separação entre a luz e as trevas.',
    );
    expect(ex.instructionVerb, 'Toque');
  });

  test('true/false cue is the statement, not hidden for the palco', () {
    const ex = Exercise(
      id: 'vf',
      type: ExerciseType.trueFalse,
      prompt: 'Qual foi a primeira ordem criadora registrada: Haja firmamento.',
      correctAnswer: 'false',
    );
    expect(ex.instructionVerb, 'Julgue');
    expect(
      ex.displayCue,
      'A primeira ordem criadora registrada foi “Haja firmamento”.',
    );
    expect(ex.hasFieldHero, isFalse);
  });

  test('single-word tap options stay distinct marks in the verse', () {
    final spans =
        buildTapSpans('No princípio, Deus criou os céus e a terra.', const [
          QuestionOption(id: 'a', text: 'criou'),
          QuestionOption(id: 'b', text: 'princípio'),
          QuestionOption(id: 'c', text: 'céus'),
        ]);
    expect(
      spans
          .where((s) => s.optionId != null)
          .map((s) => '${s.optionId}:${s.text}'),
      ['b:princípio', 'a:criou', 'c:céus'],
    );
  });

  test('tap with word options uses a blank and buttons, not verse-tap', () {
    const ex = Exercise(
      id: 't',
      type: ExerciseType.tap,
      prompt:
          'Em Gênesis 1:1–2, toque a palavra que falta em “No ___, Deus criou os céus”?',
      correctAnswer: 'a',
      passageText:
          'No princípio, Deus criou os céus e a terra. A terra, porém, estava sem forma e vazia.',
      options: [
        QuestionOption(id: 'a', text: 'princípio'),
        QuestionOption(id: 'b', text: 'terra'),
        QuestionOption(id: 'c', text: 'estava'),
      ],
    );
    expect(ex.prefersVerseTap, isFalse);
    expect(ex.usesCompletePalco, isTrue);
    expect(ex.palcoTemplate, contains('___'));
    expect(ex.palcoTemplate, isNot(contains('princípio')));
    expect(ex.showActVerb, isFalse);
    expect(ex.needsConfirm, isTrue);
    expect(ex.displayCue, 'Em Gênesis 1:1–2, toque a palavra que falta');
  });

  test('complete hides generic cue and order has a sequence prompt', () {
    const fill = Exercise(
      id: 'c',
      type: ExerciseType.complete,
      prompt: 'Complete a lacuna.',
      correctAnswer: 'a',
      template: 'A terra, porém, era ___.',
    );
    expect(fill.instructionVerb, 'Complete');
    expect(fill.displayCue, isEmpty);
    expect(fill.usesCompletePalco, isTrue);
    expect(fill.needsConfirm, isTrue);
    expect(fill.showActVerb, isFalse);

    const order = Exercise(
      id: 'o',
      type: ExerciseType.order,
      prompt: 'Monte a sequência do trecho.',
      cue: 'Monte a sequência do trecho.',
      correctAnswer: 'a,b,c',
    );
    expect(order.instructionVerb, 'Ordene');
    expect(order.displayCue, 'Monte a sequência do trecho.');
    expect(order.needsConfirm, isTrue);
    expect(order.showActVerb, isFalse);
  });

  test('playable acts wait for Continuar to check the answer', () {
    const choice = Exercise(
      id: 'q',
      type: ExerciseType.choice,
      prompt: 'O que o texto afirma?',
      correctAnswer: 'a',
    );
    expect(choice.needsConfirm, isTrue);
    expect(choice.showActVerb, isFalse);

    const vf = Exercise(
      id: 'vf2',
      type: ExerciseType.trueFalse,
      prompt: 'Deus criou os céus e a terra.',
      correctAnswer: 'true',
    );
    expect(vf.needsConfirm, isTrue);
    expect(vf.showActVerb, isFalse);

    const tap = Exercise(
      id: 't3',
      type: ExerciseType.tap,
      prompt: 'Toque.',
      correctAnswer: 'a',
    );
    expect(tap.needsConfirm, isTrue);
  });

  test('connect palco is the question, no extra cue', () {
    const ex = Exercise(
      id: 'k',
      type: ExerciseType.connect,
      prompt: 'O que une Gênesis 1:1 e 1:2?',
      correctAnswer: 'a',
      passageA: ExercisePassage(
        ref: 'Gênesis 1:1',
        text: 'No princípio, criou Deus o céu e a terra',
      ),
      passageB: ExercisePassage(
        ref: 'Gênesis 1:2',
        text: 'o Espírito de Deus pairava por cima das águas',
      ),
    );
    expect(ex.showActVerb, isFalse);
    expect(ex.displayCue, isEmpty);
    expect(ex.needsConfirm, isTrue);
  });

  test('true/false and choice keep a verse witness on the palco', () {
    const verse = 'No princípio, Deus criou os céus e a terra.';
    const vf = Exercise(
      id: 'vf3',
      type: ExerciseType.trueFalse,
      prompt: 'Deus criou os céus e a terra.',
      correctAnswer: 'true',
      passageText: verse,
      reference: 'Gênesis 1:1',
    );
    expect(vf.hasFieldHero, isTrue);
    expect(vf.stageWitness(), verse);
    expect(vf.stageWitness(fallback: 'outro'), verse);

    const vfNoPassage = Exercise(
      id: 'vf4',
      type: ExerciseType.trueFalse,
      prompt: 'Deus criou os céus e a terra.',
      correctAnswer: 'true',
    );
    expect(vfNoPassage.hasFieldHero, isFalse);
    expect(vfNoPassage.stageWitness(fallback: verse), verse);

    const tap = Exercise(
      id: 't2',
      type: ExerciseType.tap,
      prompt: 'Toque.',
      correctAnswer: 'a',
      passageText: verse,
    );
    expect(tap.stageWitness(fallback: 'board'), isNull);
  });

  test('complete palco uses the full verse and hides the cloze cue', () {
    const passage =
        'No princípio, criou Deus o céu e a terra. A terra, porém, era sem forma e vazia; havia trevas sobre a face do abismo, mas o Espírito de Deus pairava por cima das águas.';
    const fill = Exercise(
      id: 'c-full',
      type: ExerciseType.complete,
      prompt: 'Complete Gênesis 1:1–2: "havia ___ sobre a face do abismo".',
      cue: 'Complete Gênesis 1:1–2: "havia ___ sobre a face do abismo".',
      correctAnswer: 'a',
      template: 'havia ___ sobre a face do abismo',
      passageText: passage,
      options: [
        QuestionOption(id: 'a', text: 'trevas'),
        QuestionOption(id: 'b', text: 'águas'),
        QuestionOption(id: 'c', text: 'Espírito'),
      ],
    );
    expect(fill.displayCue, isEmpty);
    final stage = fill.clozeStageText();
    expect(stage, isNotNull);
    expect(stage, contains('No princípio'));
    expect(stage, contains('havia ___ sobre a face do abismo'));
    expect(stage!.contains('havia trevas sobre a face do abismo'), isFalse);
  });

  test('witness-first titles and stage prompts by gesture', () {
    const verse = 'No princípio, criou Deus o céu e a terra.';
    const vf = Exercise(
      id: 'vf-ui',
      type: ExerciseType.trueFalse,
      prompt: 'Deus criou o céu e a terra no fim.',
      correctAnswer: 'false',
      passageText: verse,
      reference: 'Gênesis 1:1',
    );
    expect(vf.instructionTitle, 'Julgue o versículo');
    expect(vf.showsStagePrompt, isTrue);
    expect(vf.taskPromptLabel, 'Afirmação');
    expect(vf.displayCue, 'Deus criou o céu e a terra no fim.');

    const tap = Exercise(
      id: 't-ui',
      type: ExerciseType.tap,
      prompt:
          'Em Gênesis 1:1–2, toque a palavra que falta em “No ___, criou Deus”?',
      correctAnswer: 'a',
      passageText: verse,
      options: [QuestionOption(id: 'a', text: 'princípio')],
    );
    expect(tap.instructionTitle, 'Toque a palavra');
    expect(tap.showsStagePrompt, isFalse);

    const choice = Exercise(
      id: 'q-ui',
      type: ExerciseType.choice,
      prompt: 'O que o texto afirma sobre o começo?',
      correctAnswer: 'a',
      passageText: verse,
    );
    expect(choice.instructionTitle, 'Escolha a resposta');
    expect(choice.showsStagePrompt, isTrue);
    expect(choice.taskPromptLabel, 'Pergunta');

    const order = Exercise(
      id: 'o-ui',
      type: ExerciseType.order,
      prompt: 'Monte a sequência do trecho.',
      cue: 'Monte a sequência do trecho.',
      correctAnswer: 'a,b,c',
      passageText: verse,
    );
    expect(order.instructionTitle, 'Ordene os fatos');
    expect(order.showsStagePrompt, isFalse);

    const fill = Exercise(
      id: 'c-ui',
      type: ExerciseType.complete,
      prompt: 'Complete a lacuna.',
      correctAnswer: 'a',
      template: 'No princípio, ___ Deus o céu e a terra.',
      passageText: verse,
    );
    expect(fill.instructionTitle, 'Complete o versículo');
    expect(fill.showsStagePrompt, isFalse);

    const connect = Exercise(
      id: 'k-ui',
      type: ExerciseType.connect,
      prompt: 'O que une Gênesis 1:1 e 1:2?',
      correctAnswer: 'a',
      passageA: ExercisePassage(ref: 'Gênesis 1:1', text: 'criou Deus o céu'),
      passageB: ExercisePassage(ref: 'Gênesis 1:2', text: 'a terra era vazia'),
    );
    expect(connect.instructionTitle, 'Conecte os trechos');
    expect(connect.showsStagePrompt, isFalse);
  });
}
