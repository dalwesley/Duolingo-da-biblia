import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/data/bible_book_intros.dart';
import 'package:trilha_app/data/bible_chronology.dart';

void main() {
  test('covers every canonical book in chronological order', () {
    final keys = BibleChronology.orderedBooks.map((e) => e.$1).toSet();
    expect(keys.length, 66);
    expect(BibleBookIntros.byAbbrev.keys.toSet(), keys);
  });

  test('lookup uses chronology abbrev, including Jó vs João', () {
    final genesis = BibleBookIntros.of('Gn', bookName: 'Gênesis');
    expect(genesis?.authorName, 'Moisés');
    expect(genesis?.byTradition, isTrue);
    expect(genesis?.title, 'Criação, queda e os patriarcas');
    expect(genesis?.summary, contains('Mesopotâmia'));
    expect(genesis?.summary, contains('escravidão'));
    expect(genesis?.summary, contains('Abraão'));

    final job = BibleBookIntros.of('Jó', bookName: 'Jó');
    expect(job?.title, contains('sofrimento'));

    final john = BibleBookIntros.of('Jo', bookName: 'João');
    expect(john?.author, 'João, o apóstolo');
    expect(john?.title, contains('Verbo'));
  });

  test('summaries read as prose, not slogans', () {
    for (final intro in BibleBookIntros.byAbbrev.values) {
      expect(intro.title, isNotEmpty);
      expect(intro.summary, isNotEmpty);
      expect(intro.author, isNotEmpty);
      expect(intro.when, isNotEmpty);
      expect(intro.audience, isNotEmpty);
      expect(intro.title.length, lessThanOrEqualTo(70));
      expect(intro.summary.length, greaterThanOrEqualTo(140));
      expect(intro.summary.length, lessThanOrEqualTo(520));
      expect(intro.when.length, lessThanOrEqualTo(32));
    }
  });
}
