import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/lexicon_pt_overrides.dart';
import 'package:trilha_app/utils/morphology.dart';
import 'package:trilha_app/utils/strong_id.dart';
import 'package:trilha_app/utils/strong_text.dart';
import 'package:trilha_app/utils/study_gloss.dart';

void main() {
  test('chesed is kindness, not shame', () {
    expect(overlayLexiconGloss('H2617', 'vergonha'), 'bondade, misericórdia');
    expect(overlayLexiconDefinition('H2617', 'uma reprovação'), contains('ḥesed'));
  });

  test('elohim is God, not Gibeath-elohim', () {
    expect(overlayLexiconGloss('H0430', '(Gibeate)-elohim'), 'Deus');
    expect(overlayLexiconDefinition('H0430', 'Combinado com giv.ah'), contains('Deus'));
  });

  test('tidyGloss keeps the head sense before the STEP colon', () {
    expect(tidyGloss('justiça: costume'), 'justiça');
    expect(tidyGloss('filho: idoso'), 'filho');
    expect(tidyGloss('para (alas)'), 'para');
    expect(tidyGloss('&'), 'e');
    expect(tidyGloss('[Obj.]'), 'objeto');
  });

  test('kaph prefix is "como", not "gosto"', () {
    expect(overlayLexiconGloss('H9004', 'gosto'), 'como');
  });

  test('HR/Sp2ms expands the suffix instead of dumping Sp2ms', () {
    final chips = morphologyChips('HR/Sp2ms');
    expect(chips.first, 'preposição');
    expect(chips, containsAll(['sufixo', 'pronominal', '2ª pessoa', 'masc.', 'sing.']));
    expect(chips, isNot(contains('Sp2ms')));
  });

  test('suffixPronounPt reads 2ms as ti', () {
    expect(suffixPronounPt('HR/Sp2ms'), 'ti');
    expect(attachSuffixGloss('para', 'HR/Sp2ms'), 'para ti');
  });

  test('alignGlossToVerse picks the sense the Portuguese verse uses', () {
    const verse = 'Cantarei sobre a bondade e a justiça; a ti, Senhor, cantarei.';
    expect(
      alignGlossToVerse(verse, 'bondade, misericórdia'),
      'bondade',
    );
    expect(alignGlossToVerse(verse, 'para ti'), 'para ti');
  });

  test('H1254 is create, not fatten', () {
    expect(overlayLexiconGloss('H1254', 'engordar'), 'criar');
    expect(overlayLexiconDefinition('H1254', 'ser gordo'), startsWith('1. Criar'));
    expect(overlayLexiconDefinition('H1254', 'ser gordo'), contains('1 Sm 2.29'));

    const verse = 'No princípio, Deus criou os céus e a terra.';
    final bara = buildTokenStudyView(
      strong: 'H1254',
      morph: 'HVqp3ms',
      tokenGloss: 'engordar',
      entryGloss: 'engordar',
      definition: '1) ser gordo\n1a) (Hiphil) engordar',
      verseText: verse,
      hebrew: true,
    );
    expect(bara.gloss, 'criar');
    expect(bara.needles, contains('criar'));
    final hits = highlightRanges(verse, bara.needles);
    expect(
      [for (final h in hits) verse.substring(h.start, h.end)],
      contains('criou'),
    );
  });

  test('H7225 is beginning, not the best', () {
    const verse = 'No princípio, Deus criou os céus e a terra.';
    final reshit = buildTokenStudyView(
      strong: 'H7225',
      morph: 'HR/Ncfsa',
      tokenGloss: 'primeiro: melhor',
      verseText: verse,
      hebrew: true,
    );
    expect(reshit.gloss, 'princípio');
    final hits = highlightRanges(verse, reshit.needles);
    expect(
      [for (final h in hits) verse.substring(h.start, h.end)],
      contains('princípio'),
    );
  });

  test('H9005 is extended prefix, H2617 is classic', () {
    expect(isExtendedStrong('H9005'), isTrue);
    expect(isExtendedStrong('H2617'), isFalse);
    expect(strongKind('H9005'), StrongKind.prefix);
    expect(isPunctuationStrong('H9016'), isTrue);
  });

  test('linkVerseToTokens maps the Portuguese verse onto originals', () {
    const verse =
        'Cantarei sobre a bondade e a justiça; a ti, Senhor, cantarei.';
    final links = linkVerseToTokens(verse, const [
      TokenNeedle(3, ['bondade']),
      TokenNeedle(4, ['justiça']),
      TokenNeedle(5, ['cantar']),
      TokenNeedle(6, ['ti']),
      TokenNeedle(7, ['Senhor']),
      TokenNeedle(8, ['cantar']),
    ]);
    final words = [for (final l in links) verse.substring(l.start, l.end)];
    expect(words, containsAll(['bondade', 'justiça', 'ti', 'Senhor']));
    expect(words.where((w) => w.toLowerCase() == 'cantarei').length, 2);
    expect(links.firstWhere((l) => verse.substring(l.start, l.end) == 'bondade').tokenPos, 3);
    expect(links.where((l) => l.tokenPos == 5 || l.tokenPos == 8).length, 2);
  });

  test('Ps 101:1 chips: chesed=bondade and leka=para ti', () {
    const verse = 'Cantarei sobre a bondade e a justiça; a ti, Senhor, cantarei.';
    final chesed = buildTokenStudyView(
      strong: 'H2617',
      morph: 'HNcmsa',
      tokenGloss: 'vergonha',
      verseText: verse,
      hebrew: true,
    );
    expect(chesed.gloss, 'bondade');
    expect(chesed.needles, contains('bondade'));
    expect(chesed.extended, isFalse);

    final leka = buildTokenStudyView(
      strong: 'H9005',
      morph: 'HR/Sp2ms',
      tokenGloss: 'para',
      verseText: verse,
      hebrew: true,
    );
    expect(leka.gloss, 'para ti');
    expect(leka.kind, StrongKind.prefix);
    expect(leka.needles, contains('ti'));
  });
}
