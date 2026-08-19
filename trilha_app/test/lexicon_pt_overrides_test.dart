import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/lexicon_pt_overrides.dart';

void main() {
  test('Ham is Cam, not cured meat', () {
    expect(overlayLexiconGloss('H2526', 'Presunto'), 'Cam');
    expect(overlayLexiconDefinition('H2526', '§ Presunto = "quente"'), contains('Cam = "quente"'));
    expect(overlayLexiconDefinition('H2526', 'x'), isNot(contains('Presunto')));
  });

  test('Ham place and Hammon stay names', () {
    expect(overlayLexiconGloss('H1990', 'Presunto'), 'Hã');
    expect(overlayLexiconGloss('H2540', 'presunto'), 'Hamom');
  });

  test('other EN false-friend names', () {
    expect(overlayLexiconGloss('H0347', 'Trabalho'), 'Jó');
    expect(overlayLexiconGloss('H3876', 'Lote'), 'Ló');
    expect(overlayLexiconGloss('G3138', 'Marca'), 'Marcos');
  });

  test('unlisted strongs pass through', () {
    expect(overlayLexiconGloss('H0430', 'Deus'), 'Deus');
    expect(overlayLexiconDefinition('H0430', 'Deus, deuses'), 'Deus, deuses');
  });
}
