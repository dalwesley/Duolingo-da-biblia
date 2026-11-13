import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/models/trail_catalog.dart';

Trail trail({String? collection}) => Trail.fromJson({
  'slug': 'marcos',
  'title': 'Marcos',
  'description': '',
  'icon': '',
  'order': 42,
  'comingSoon': false,
  'color': '#000000',
  'realm': 'novo-testamento',
  'category': 'evangelhos',
  'collection': ?collection,
  'modules': const [],
});

void main() {
  test('sem coleção, a trilha mora no NT', () {
    expect(trail().journey, TrailJourney.novoTestamento);
  });

  test('coleção panorama leva a trilha para o Panorama da Bíblia', () {
    final j = trail(collection: 'panorama').journey;
    expect(j, TrailJourney.panorama);
    expect(j.shelf, TrailShelf.biblia);
    expect(j.requiresPlus, isFalse);
  });

  test('o Panorama aparece na linha da Bíblia, depois de AT e NT', () {
    final bible = TrailJourney.forShelf(TrailShelf.biblia);
    expect(bible.take(3), [
      TrailJourney.antigoTestamento,
      TrailJourney.novoTestamento,
      TrailJourney.panorama,
    ]);
    expect(
      TrailJourney.forShelf(TrailShelf.tematicos),
      isNot(contains(TrailJourney.panorama)),
    );
  });
}
