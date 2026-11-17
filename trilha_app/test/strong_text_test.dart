import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/strong_text.dart';

void main() {
  test('glossNeedles drops particles and keeps senses', () {
    expect(glossNeedles('[Obj.]'), isEmpty);
    expect(glossNeedles('luz'), ['luz']);
    expect(
      glossNeedles('Deus, deuses, juízes'),
      containsAll(['Deus', 'deuses', 'juízes']),
    );
  });

  test('wordMatchesNeedle stems Portuguese verbs', () {
    expect(wordMatchesNeedle('separou', 'separar'), isTrue);
    expect(wordMatchesNeedle('criou', 'criar'), isTrue);
    expect(wordMatchesNeedle('céus', 'céu'), isTrue);
    expect(wordMatchesNeedle('luz', 'luz'), isTrue);
    expect(wordMatchesNeedle('trevas', 'luz'), isFalse);
    expect(wordMatchesNeedle('ti', 'ti'), isTrue);
  });

  test('wordMatchesNeedle covers irregular Bible verbs', () {
    expect(wordMatchesNeedle('Disse', 'dizer'), isTrue);
    expect(wordMatchesNeedle('Façamos', 'fazer'), isTrue);
    expect(wordMatchesNeedle('fez', 'fazer'), isTrue);
    expect(wordMatchesNeedle('viu', 'ver'), isTrue);
    expect(wordMatchesNeedle('domine', 'dominar'), isTrue);
    // Partículas não devem colidir com ser/dar.
    expect(wordMatchesNeedle('e', 'ser'), isFalse);
    expect(wordMatchesNeedle('da', 'dar'), isFalse);
    // Demonstrativos/conectivos não viram verbo (esta≠estar, como≠comer).
    expect(wordMatchesNeedle('estas', 'estar'), isFalse);
    expect(wordMatchesNeedle('esta', 'estar'), isFalse);
    expect(wordMatchesNeedle('como', 'comer'), isFalse);
    expect(wordMatchesNeedle('come', 'comer'), isTrue);
  });

  test('translationFormsInVerses collects TB forms', () {
    const verses = [
      'Disse também Deus: Façamos o homem.',
      'E disse Deus: Haja luz.',
      'Falou o Senhor a Moisés.',
    ];
    final forms = translationFormsInVerses(verses, ['dizer', 'falar']);
    final words = [for (final f in forms) f.word.toLowerCase()];
    expect(words, contains('disse'));
    expect(forms.first.count, greaterThanOrEqualTo(2));
  });

  test('Gn 1:26 links dizer→Disse and fazer→Façamos', () {
    const verse =
        'Disse também Deus: Façamos o homem à nossa imagem, conforme a nossa '
        'semelhança; domine ele sobre os peixes do mar, sobre as aves do céu, '
        'sobre os animais e sobre toda a terra, e sobre todos os répteis que '
        'se arrastam sobre a terra.';
    final links = linkVerseToTokens(verse, const [
      TokenNeedle(1, ['dizer']),
      TokenNeedle(2, ['Deus']),
      TokenNeedle(3, ['fazer']),
      TokenNeedle(4, ['homem']),
      TokenNeedle(5, ['imagem']),
      TokenNeedle(6, ['semelhança']),
      TokenNeedle(7, ['dominar']),
    ]);
    String word(VerseWordLink l) => verse.substring(l.start, l.end);
    final byPos = {for (final l in links) l.tokenPos: word(l)};
    expect(byPos[1], 'Disse');
    expect(byPos[2], 'Deus');
    expect(byPos[3], 'Façamos');
    expect(byPos[4], 'homem');
    expect(byPos[7], 'domine');
  });

  test('highlightRanges marks gloss in the verse', () {
    const text = 'E Deus viu que a luz era boa; e separou a luz das trevas.';
    final hits = highlightRanges(text, ['luz', 'Deus', 'separar']);
    final words = [for (final h in hits) text.substring(h.start, h.end)];
    expect(words, containsAll(['Deus', 'luz', 'separou']));
  });

  test('definitionSenses splits numbered and semicolon senses', () {
    expect(definitionSenses('1. Deus. 2. deuses. 3. juízes.'), [
      'Deus.',
      'deuses.',
      'juízes.',
    ]);
    expect(
      definitionSenses(
        'Luz física, o primeiro criado; luminosidade; a verdade que ilumina.',
      ),
      hasLength(greaterThanOrEqualTo(2)),
    );
    expect(definitionSenses(''), isEmpty);
    expect(
      definitionSenses(
        '1) lábio, linguagem, fala, margem, margem, borda, borda, lado, borda, borda, ligação\n'
        '1a) lábio (como parte do corpo)\n'
        '1b) linguagem',
      ),
      [
        'lábio, linguagem, fala, margem, borda, lado, ligação',
        'lábio (como parte do corpo)',
        'linguagem',
      ],
    );
  });

  test('wordMatchesNeedle maps language synonyms', () {
    expect(wordMatchesNeedle('língua', 'linguagem'), isTrue);
    expect(wordMatchesNeedle('língua', 'lábio'), isTrue);
    expect(wordMatchesNeedle('expressões', 'palavra'), isTrue);
    expect(wordMatchesNeedle('única', 'um'), isTrue);
    expect(wordMatchesNeedle('Toda', 'tudo'), isTrue);
  });

  test('rankDefinitionSenses puts the verse sense first', () {
    final ranked = rankDefinitionSenses(
      [
        'borda, margem (de mar ou rio)',
        'lábio (parte do corpo)',
        'linguagem, fala',
      ],
      ['língua', 'linguagem'],
    );
    expect(ranked.first, 'linguagem, fala');
  });
}
