import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/utils/palco_verse.dart';

void main() {
  test('overlays JFAAL and remaps Jeová on the tap palco', () {
    const ex = Exercise(
      id: 'pastor-tap',
      type: ExerciseType.tap,
      prompt: 'Em Salmo 23:1, toque a palavra que falta.',
      correctAnswer: 'a',
      reference: 'Salmo 23:1',
      passageText: 'Jeová é o meu pastor; nada me faltará.',
      options: [
        QuestionOption(id: 'a', text: 'Jeová'),
        QuestionOption(id: 'b', text: 'pastor'),
        QuestionOption(id: 'c', text: 'nada'),
      ],
      template: '___ é o meu pastor',
    );
    final out = PalcoVerse.apply(
      ex,
      live: 'O Senhor é o meu pastor; nada me faltará.',
    );
    expect(out.passageText, 'O Senhor é o meu pastor; nada me faltará.');
    expect(out.passageText, isNot(contains('Jeová')));
    expect(out.options.first.text, 'Senhor');
    expect(out.template, 'O ___ é o meu pastor; nada me faltará.');
    expect(out.template, isNot(contains('Jeová')));
  });

  test('V/F prompt loses Jeová even without live verse', () {
    const ex = Exercise(
      id: 'vf',
      type: ExerciseType.trueFalse,
      prompt: 'Jeová é o meu pastor; nada me faltará.',
      correctAnswer: 'true',
      passageText: 'Jeová é o meu pastor; nada me faltará.',
    );
    final out = PalcoVerse.apply(ex);
    expect(out.prompt, 'O Senhor é o meu pastor; nada me faltará.');
    expect(out.passageText, 'O Senhor é o meu pastor; nada me faltará.');
  });

  test('keeps a word already present in JFAAL', () {
    expect(
      PalcoVerse.fitPhrase('pastor', 'O Senhor é o meu pastor; nada me faltará.'),
      'pastor',
    );
  });

  test('connect keeps pedagogical snippets instead of the full range', () {
    const live =
        'No princípio, Deus criou os céus e a terra. A terra, porém, estava sem forma e vazia; havia trevas sobre a face do abismo, e o Espírito de Deus pairava sobre as águas.';
    const ex = Exercise(
      id: 'genesis-1-11-cam-gen-01-criador-06',
      type: ExerciseType.connect,
      prompt: 'O que une a criação e o Espírito sobre as águas?',
      correctAnswer: 'a',
      reference: 'Gênesis 1:1–2',
      passageText: live,
      options: [
        QuestionOption(id: 'a', text: 'Deus já está presente'),
        QuestionOption(id: 'b', text: 'e o Espírito já'),
        QuestionOption(id: 'c', text: 'depois o vazio'),
      ],
      passageA: ExercisePassage(
        ref: 'Gênesis 1:1',
        text: 'criou Deus o céu e a terra',
      ),
      passageB: ExercisePassage(
        ref: 'Gênesis 1:2',
        text: 'o Espírito de Deus pairava por cima das águas',
      ),
    );

    final out = PalcoVerse.applyCached(ex, {
      'Gênesis 1:1–2': live,
      'Gênesis 1:1': 'No princípio, Deus criou os céus e a terra.',
      'Gênesis 1:2':
          'A terra, porém, estava sem forma e vazia; havia trevas sobre a face do abismo, e o Espírito de Deus pairava sobre as águas.',
    });

    expect(out.passageA!.text.toLowerCase(), contains('criou'));
    expect(out.passageA!.text.toLowerCase(), contains('terra'));
    expect(out.passageA!.text.contains('sem forma'), isFalse);
    expect(out.passageB!.text.toLowerCase(), contains('espírito'));
    expect(out.passageB!.text.toLowerCase(), contains('águas'));
    expect(out.passageB!.text.contains('No princípio'), isFalse);
    expect(out.options.first.text, 'Deus já está presente');
  });

  test('fitSnippet maps a TB excerpt onto Almeida without swallowing the range', () {
    const live =
        'No princípio, Deus criou os céus e a terra. A terra, porém, estava sem forma e vazia; havia trevas sobre a face do abismo, e o Espírito de Deus pairava sobre as águas.';
    expect(
      PalcoVerse.fitSnippet('o Espírito de Deus pairava por cima das águas', live),
      'o Espírito de Deus pairava sobre as águas',
    );
    final a = PalcoVerse.fitSnippet('criou Deus o céu e a terra', live);
    expect(a.toLowerCase(), contains('criou'));
    expect(a.toLowerCase(), contains('terra'));
    expect(a.contains('sem forma'), isFalse);
  });
}
