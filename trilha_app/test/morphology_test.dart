import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/morphology.dart';

void main() {
  test('morphologyChips drops language and splits grammar', () {
    expect(
      morphologyChips('HNmsa'),
      ['substantivo', 'masc.', 'sing.', 'absoluto'],
    );
  });

  test('HNpm is proper masculine, not plural', () {
    expect(
      morphologyChips('HNpm'),
      ['substantivo', 'próprio', 'masc.'],
    );
  });

  test('HNpl is a place name', () {
    expect(
      morphologyChips('HNpl'),
      ['substantivo', 'próprio', 'lugar'],
    );
  });

  test('HNpt is the divine name', () {
    expect(
      morphologyChips('HNpt'),
      ['substantivo', 'próprio', 'nome divino'],
    );
  });

  test('HNcmpa keeps gender number state', () {
    expect(
      morphologyChips('HNcmpa'),
      ['substantivo', 'masc.', 'pl.', 'absoluto'],
    );
  });

  test('morphologyChips expands a Hebrew verb', () {
    final chips = morphologyChips('HVqp3ms');
    expect(chips.first, 'verbo');
    expect(chips, containsAll(['qal', 'perfeito', '3ª pessoa', 'masc.', 'sing.']));
    expect(chips, isNot(contains('hebraico')));
  });

  test('morphologyChips splits prefixed compounds', () {
    final chips = morphologyChips('HR/Ncmsc');
    expect(chips.first, 'preposição');
    expect(chips, isNot(contains('hebraico')));
    expect(chips, containsAll(['substantivo', 'masc.', 'sing.', 'construto']));
    expect(chips, isNot(contains('comum')));
  });

  test('HC/Npm keeps the proper name on the second segment', () {
    expect(
      morphologyChips('HC/Npm'),
      ['conjunção', 'substantivo', 'próprio', 'masc.'],
    );
  });

  test('morphologyChips handles Greek nominals', () {
    final chips = morphologyChips('N-NSF');
    expect(chips.first, 'substantivo');
    expect(chips, contains('nominativo sing. fem.'));
  });

  test('empty morph is empty chips', () {
    expect(morphologyChips(null), isEmpty);
    expect(morphologyChips(''), isEmpty);
  });

  test('HR/Sp2ms reads the pronominal suffix', () {
    final chips = morphologyChips('HR/Sp2ms');
    expect(chips.first, 'preposição');
    expect(chips, containsAll(['sufixo', 'pronominal', '2ª pessoa', 'masc.', 'sing.']));
    expect(suffixPronounPt('HR/Sp2ms'), 'ti');
  });

  test('morphologyPhrase is a Portuguese sentence', () {
    expect(
      morphologyPhrase('HR/Sp2ms', gloss: 'para ti'),
      'Preposição com sufixo — para ti.',
    );
    expect(
      morphologyPhrase('HNcmsa', gloss: 'bondade'),
      contains('Substantivo'),
    );
    expect(morphologyPhrase('HNcmsa', gloss: 'bondade'), contains('bondade'));
  });
}
