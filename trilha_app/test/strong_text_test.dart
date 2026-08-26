import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/strong_text.dart';

void main() {
  test('glossNeedles drops particles and keeps senses', () {
    expect(glossNeedles('[Obj.]'), isEmpty);
    expect(glossNeedles('luz'), ['luz']);
    expect(
      glossNeedles('Deus, deuses, juízes'),
      ['Deus', 'deuses', 'juízes'],
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

  test('highlightRanges marks gloss in the verse', () {
    const text = 'E Deus viu que a luz era boa; e separou a luz das trevas.';
    final hits = highlightRanges(text, ['luz', 'Deus', 'separar']);
    final words = [for (final h in hits) text.substring(h.start, h.end)];
    expect(words, containsAll(['Deus', 'luz', 'separou']));
  });

  test('definitionSenses splits numbered and semicolon senses', () {
    expect(
      definitionSenses('1. Deus. 2. deuses. 3. juízes.'),
      ['Deus.', 'deuses.', 'juízes.'],
    );
    expect(
      definitionSenses(
        'Luz física, o primeiro criado; luminosidade; a verdade que ilumina.',
      ),
      hasLength(greaterThanOrEqualTo(2)),
    );
    expect(definitionSenses(''), isEmpty);
  });
}
