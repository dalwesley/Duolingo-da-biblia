import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/trail_catalog.dart';

void main() {
  tearDown(() {
    ExploreCards.set(const []);
    ExploreShelves.set(const []);
  });

  Map<String, dynamic> card(String id, {Object? shelf = 'tematicos'}) => {
    'id': id,
    'shelf': shelf,
    'realm': 'vida-crista',
    'title': {'pt': 'Família', 'en': 'Family'},
    'blurb': {'pt': 'Casa à luz da Bíblia'},
    'glyph': 'home',
    'plus': false,
    'order': 2,
  };

  void load(List<Map<String, dynamic>> raw) =>
      ExploreCards.set([for (final r in raw) ?ExploreCard.fromJson(r)]);

  test('card do painel vira categoria e card no fim da linha', () {
    load([card('familia')]);
    final shelf = TrailJourney.forShelf(TrailShelf.tematicos);
    expect(shelf.last.name, 'familia');
    expect(shelf.last.isExtra, isTrue);
    expect(shelf.last.label, 'Família');
    expect(shelf.last.description, 'Casa à luz da Bíblia');
    expect(shelf.last.requiresPlus, isFalse);
    expect(shelf.last.art, isNull);
    expect(TrailCategory.tryFromId('familia')?.isExtra, isTrue);
  });

  test('trilha com a categoria do card cai nele, qualquer área', () {
    load([card('familia')]);
    final j = TrailJourney.forTrail(
      realmId: 'antigo-testamento',
      categoryId: 'familia',
    );
    expect(j.name, 'familia');
  });

  test('sem o card (app antigo ou cache vazio), cai no card da área', () {
    expect(
      TrailJourney.forTrail(realmId: 'vida-crista', categoryId: 'familia'),
      TrailJourney.discipulado,
    );
  });

  test(
    'doc inválido não entra: Bíblia, sem título, id de card fixo, inativo',
    () {
      load([
        card('a', shelf: 'biblia'),
        {
          ...card('b'),
          'title': {'pt': ''},
        },
        card('oracao'),
        {...card('c'), 'active': false},
      ]);
      expect(ExploreCards.cards, isEmpty);
      expect(TrailJourney.forShelf(TrailShelf.vidaCrista).length, 3);
    },
  );

  test('fixos continuam iguais por identidade e por id', () {
    expect(TrailCategory.fromId('oracao'), TrailCategory.oracao);
    expect(TrailJourney.values.first, TrailJourney.antigoTestamento);
  });

  test('linha do painel: card aponta para ela e vira porta própria', () {
    ExploreShelves.set([
      ?ExploreShelf.fromJson({
        'id': 'familia-e-lar',
        'title': {'pt': 'Família e lar'},
        'subtitle': {'pt': 'Casa à luz da Bíblia'},
        'sky': 'teologia',
        'plus': false,
        'order': 1,
      }),
    ]);
    load([card('casamento', shelf: 'familia-e-lar')]);
    final shelf = TrailShelf.tryFromName('familia-e-lar');
    expect(shelf?.isExtra, isTrue);
    expect(shelf?.label, 'Família e lar');
    expect(TrailShelf.values.last, shelf);
    expect(TrailJourney.forShelf(shelf!).single.name, 'casamento');
  });

  test('card que aponta para linha desconhecida não entra', () {
    load([card('solto', shelf: 'nao-existe')]);
    expect(ExploreCards.cards, isEmpty);
  });

  test('linha com id de linha fixa ou sem título não entra', () {
    expect(
      ExploreShelf.fromJson({
        'id': 'biblia',
        'title': {'pt': 'X'},
      }),
      isNull,
    );
    expect(
      ExploreShelf.fromJson({
        'id': 'x',
        'title': {'pt': ' '},
      }),
      isNull,
    );
  });
}
