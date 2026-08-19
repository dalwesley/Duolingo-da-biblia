import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/trail.dart';

void main() {
  group('buildTapSpans', () {
    test('marks the full answer phrase as one tap target', () {
      const passage =
          'Viu Deus a luz que era boa e fez separação entre a luz e as trevas.';
      final spans = buildTapSpans(passage, const [
        QuestionOption(
          id: 'a',
          text: 'separação entre a luz e as trevas',
        ),
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

      expect(
        spans.where((s) => s.optionId != null).map((s) => s.text),
        ['tarde'],
      );
    });
  });

  test('tap gesture uses Toque as the action verb', () {
    const ex = Exercise(
      id: 't',
      type: ExerciseType.tap,
      prompt: 'O que Deus separou no primeiro dia?',
      correctAnswer: 'a',
      passageText: 'Viu Deus a luz que era boa e fez separação entre a luz e as trevas.',
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

    const order = Exercise(
      id: 'o',
      type: ExerciseType.order,
      prompt: 'Monte a sequência do trecho.',
      cue: 'Monte a sequência do trecho.',
      correctAnswer: 'a,b,c',
    );
    expect(order.instructionVerb, 'Ordene');
    expect(order.displayCue, 'Monte a sequência do trecho.');
  });
}
