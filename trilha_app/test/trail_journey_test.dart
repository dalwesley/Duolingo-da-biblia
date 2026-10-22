import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/trail_catalog.dart';

void main() {
  TrailJourney of(String realm, String category) =>
      TrailJourney.forTrail(realmId: realm, categoryId: category);

  test('AT and NT gather their canon categories into one card', () {
    expect(
      of('antigo-testamento', 'pentateuco'),
      TrailJourney.antigoTestamento,
    );
    expect(
      of('antigo-testamento', 'profetas-menores'),
      TrailJourney.antigoTestamento,
    );
    expect(of('novo-testamento', 'epistolas'), TrailJourney.novoTestamento);
  });

  test('Vida cristã and Teologia get one card per category', () {
    expect(of('vida-crista', 'oracao'), TrailJourney.oracao);
    expect(of('vida-crista', 'historia-igreja'), TrailJourney.historiaIgreja);
    expect(of('teologia', 'linguas'), TrailJourney.linguas);
  });

  test('poetic books get their own Sabedoria card', () {
    expect(of('antigo-testamento', 'poeticos'), TrailJourney.sabedoria);
    expect(
      TrailJourney.antigoTestamento.categories,
      isNot(contains(TrailCategory.poeticos)),
    );
  });

  test('free bible shelf is the two testaments side by side', () {
    expect(TrailJourney.forShelf(TrailShelf.biblia), [
      TrailJourney.antigoTestamento,
      TrailJourney.novoTestamento,
    ]);
    expect(TrailJourney.antigoTestamento.requiresPlus, isFalse);
    expect(TrailJourney.novoTestamento.requiresPlus, isFalse);
  });

  test('themes and the other plus shelves keep their card order', () {
    expect(TrailJourney.forShelf(TrailShelf.tematicos), [
      TrailJourney.sabedoria,
      TrailJourney.panorama,
      TrailJourney.personagens,
      TrailJourney.promessaCumprimento,
      TrailJourney.temasBiblicos,
      TrailJourney.parabolasMilagres,
    ]);
    expect(TrailJourney.forShelf(TrailShelf.vidaCrista), [
      TrailJourney.discipulado,
      TrailJourney.oracao,
      TrailJourney.historiaIgreja,
    ]);
    expect(TrailJourney.forShelf(TrailShelf.teologia), [
      TrailJourney.hermeneutica,
      TrailJourney.linguas,
      TrailJourney.sistematica,
      TrailJourney.cristologia,
    ]);
    for (final journey in [
      ...TrailJourney.forShelf(TrailShelf.tematicos),
      ...TrailJourney.forShelf(TrailShelf.vidaCrista),
      ...TrailJourney.forShelf(TrailShelf.teologia),
    ]) {
      expect(journey.requiresPlus, isTrue, reason: journey.name);
    }
  });

  test('whole-Bible cards accept either testament', () {
    expect(
      of('novo-testamento', 'promessa-cumprimento'),
      TrailJourney.promessaCumprimento,
    );
    expect(
      of('antigo-testamento', 'parabolas-milagres'),
      TrailJourney.parabolasMilagres,
    );
    expect(of('antigo-testamento', 'personagens'), TrailJourney.personagens);
    expect(of('novo-testamento', 'panorama'), TrailJourney.panorama);
  });

  test(
    'category that does not match the realm falls back to the realm card',
    () {
      expect(of('novo-testamento', 'pentateuco'), TrailJourney.novoTestamento);
      expect(of('vida-crista', 'unknown'), TrailJourney.discipulado);
      expect(of('teologia', 'evangelhos'), TrailJourney.sistematica);
    },
  );

  test('closed cards explain what the trail will be', () {
    const closed = [
      TrailJourney.panorama,
      TrailJourney.personagens,
      TrailJourney.promessaCumprimento,
      TrailJourney.temasBiblicos,
      TrailJourney.parabolasMilagres,
      TrailJourney.hermeneutica,
      TrailJourney.linguas,
      TrailJourney.sistematica,
      TrailJourney.cristologia,
    ];
    for (final journey in closed) {
      expect(journey.description.trim(), isNotEmpty, reason: journey.name);
    }
  });

  test('every category belongs to exactly one card', () {
    for (final c in TrailCategory.values) {
      final owners = TrailJourney.values.where((j) => j.categories.contains(c));
      expect(owners.length, 1, reason: c.id);
    }
  });
}
