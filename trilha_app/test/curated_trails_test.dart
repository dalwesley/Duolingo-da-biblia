import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/data/curated_trails.dart';
import 'package:trilha_app/data/trail_art.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/models/trail_catalog.dart';
import 'package:trilha_app/utils/plus_access.dart';

/// A Promessa como vem do Firestore (content_trails/a-promessa), resumida.
Trail _promiseFixture() {
  Map<String, dynamic> scene(String slug, String trail, String origin) => {
    'slug': slug,
    'title': slug,
    'type': 'lesson',
    'hookRef': 'Gênesis 12:1–3',
    'bankTrailSlug': trail,
    'bankSection': origin,
  };
  return Trail.fromJson({
    'slug': CuratedTrails.promiseSlug,
    'title': 'A Promessa',
    'description': '',
    'icon': '✨',
    'realm': 'antigo-testamento',
    'category': 'promessa-cumprimento',
    'modules': [
      {
        'title': 'A promessa feita',
        'icon': '⭐',
        'missions': [
          scene('promessa-01', 'genesis-12-50', 'gen12-01-chamado'),
          scene('promessa-02', 'genesis-12-50', 'gen12-04-alianca-estrelas'),
          scene('promessa-03', 'genesis-12-50', 'gen12-09-moria'),
        ],
      },
      {
        'title': 'A promessa cumprida',
        'icon': '✝️',
        'missions': [
          scene('promessa-12', 'galatas', 'gl-02-fe'),
          {
            'slug': CuratedTrails.synthesisSlug,
            'title': 'Travessia',
            'type': 'boss',
            'bankTrailSlug': CuratedTrails.promiseSlug,
            'bankSection': CuratedTrails.synthesisSlug,
          },
        ],
      },
    ],
  });
}

void main() {
  final promise = _promiseFixture();
  setUp(() => CuratedTrails.attach([promise]));

  test('origens vêm das cenas emprestadas do catálogo', () {
    expect(CuratedTrails.origins, {
      'promessa-01': 'gen12-01-chamado',
      'promessa-02': 'gen12-04-alianca-estrelas',
      'promessa-03': 'gen12-09-moria',
      'promessa-12': 'gl-02-fe',
    });
    // A travessia usa o banco da própria trilha: não é cena emprestada.
    expect(CuratedTrails.originOf(CuratedTrails.synthesisSlug), isNull);
    expect(CuratedTrails.promiseBlocks.map((b) => b.scenes.length), [3, 1]);
  });

  test('sem a trilha no catálogo, nada de origem nem mapa', () {
    CuratedTrails.attach(const []);
    expect(CuratedTrails.origins, isEmpty);
    expect(CuratedTrails.promiseBlocks, isEmpty);
  });

  test('fica no card Promessa e cumprimento, do Plus desde a 1ª cena', () {
    expect(promise.journey, TrailJourney.promessaCumprimento);
    expect(PlusAccess.trailIsPlus(promise), isTrue);
    expect(PlusAccess.missionNeedsPlus(promise, 'promessa-01'), isTrue);
    expect(PlusAccess.missionNeedsPlus(promise, 'promessa-02'), isTrue);
  });

  test('a cena curada e a de origem contam uma pela outra', () {
    expect(CuratedTrails.linkedScenes('promessa-03'), {'gen12-09-moria'});
    expect(CuratedTrails.linkedScenes('gen12-09-moria'), {'promessa-03'});
    expect(CuratedTrails.linkedScenes('gen12-02-egito-e-lot'), isEmpty);
  });

  test('a cena mostra a pintura da origem', () {
    expect(
      TrailArt.ofScene(CuratedTrails.promiseSlug, 'promessa-01'),
      'assets/art/scene_gen12-01-chamado.jpg',
    );
  });

  test('mapa: erros do bloco pela seção de origem, não de outra cena', () {
    const mistakes = [
      'genesis-12-50-sem-gen12-09-moria-03',
      'genesis-12-50-cam-gen12-02-egito-e-lot-01',
      'exodo-pro-exo-07-sinai-05',
    ];
    final first = CuratedTrails.promiseBlocks.first.scenes.map(
      (m) => m.resolvedBankSection,
    );
    expect(CuratedTrails.mistakesFor(mistakes, first), [
      'genesis-12-50-sem-gen12-09-moria-03',
    ]);
  });
}
