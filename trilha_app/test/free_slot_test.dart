import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/utils/plus_access.dart';
import 'package:trilha_app/utils/trail_progress.dart';

Trail _trail(
  String slug, {
  String realm = 'antigo-testamento',
  String cat = 'pentateuco',
}) => Trail(
  slug: slug,
  title: slug,
  description: '',
  icon: '📖',
  order: 1,
  comingSoon: false,
  color: '#2F5D4A',
  realmId: realm,
  categoryId: cat,
  modules: [
    TrailModule(
      title: 'Mod',
      icon: '🌍',
      missions: [
        for (final n in [1, 2])
          Mission(
            slug: '$slug-$n',
            title: '$slug $n',
            intro: '',
            type: 'lesson',
            stepsReward: 50,
            questions: [],
          ),
      ],
    ),
  ],
);

void main() {
  final genesis = _trail('genesis');
  final mateus = _trail('mateus', realm: 'novo-testamento');
  final oracao = _trail('oracao', realm: 'vida-crista', cat: 'oracao');
  final ansiedade = _trail(
    'ansiedade',
    realm: 'vida-crista',
    cat: 'paz-no-dia',
  );
  final trails = [genesis, mateus, oracao, ansiedade];

  tearDown(() {
    TrailProgress.lastPlayedMissionSlug = null;
    PlusAccess.giftedTrails = const {};
  });

  const day1 = '2026-10-01T09:00:00';
  const day2 = '2026-10-05T09:00:00';

  test('nothing chosen: any trail can start', () {
    expect(TrailProgress.freeSlotBlocker(mateus, trails, const []), isNull);
  });

  test('the principal blocks starting another', () {
    expect(
      TrailProgress.freeSlotBlocker(
        mateus,
        trails,
        ['genesis-1'],
        chosenAt: {'genesis': day1},
      )?.slug,
      'genesis',
    );
  });

  test('the principal keeps going', () {
    expect(
      TrailProgress.freeSlotBlocker(
        genesis,
        trails,
        ['genesis-1'],
        chosenAt: {'genesis': day1},
      ),
      isNull,
    );
  });

  test('a finished principal frees the slot', () {
    expect(
      TrailProgress.freeSlotBlocker(
        mateus,
        trails,
        ['genesis-1', 'genesis-2'],
        chosenAt: {'genesis': day1},
      ),
      isNull,
    );
  });

  test('the principal is the first chosen, not the last played', () {
    TrailProgress.lastPlayedMissionSlug = 'genesis-1';
    final chosen = {'ansiedade': day1, 'genesis': day2};
    final done = ['ansiedade-1', 'genesis-1'];
    expect(
      TrailProgress.freeSlotBlocker(
        genesis,
        trails,
        done,
        chosenAt: chosen,
      )?.slug,
      'ansiedade',
    );
    expect(
      TrailProgress.freeSlotBlocker(ansiedade, trails, done, chosenAt: chosen),
      isNull,
    );
  });

  test('a gifted trail walks outside the slot', () {
    PlusAccess.giftedTrails = {'oracao'};
    final chosen = {'oracao': day1, 'genesis': day2};
    final done = ['oracao-1', 'genesis-1'];
    expect(
      TrailProgress.freeSlotBlocker(oracao, trails, done, chosenAt: chosen),
      isNull,
    );
    expect(
      TrailProgress.freeSlotBlocker(
        mateus,
        trails,
        done,
        chosenAt: chosen,
      )?.slug,
      'genesis',
    );
  });

  test('a Plus trail kept after Plus ends is not the principal', () {
    expect(
      TrailProgress.freeSlotBlocker(
        genesis,
        trails,
        ['oracao-1'],
        chosenAt: {'oracao': day1},
      ),
      isNull,
    );
  });

  test('a scene from another flow does not take the slot', () {
    expect(
      TrailProgress.freeSlotBlocker(mateus, trails, ['genesis-1']),
      isNull,
    );
  });

  test('before any choice, the old started trails seed the order', () {
    final done = ['genesis-1', 'ansiedade-1'];
    final on = {'genesis-1': '2026-10-05', 'ansiedade-1': '2026-10-01'};
    expect(TrailProgress.legacyChoices(trails, done, completedOn: on), [
      'ansiedade',
      'genesis',
    ]);
    expect(
      TrailProgress.freeSlotBlocker(
        genesis,
        trails,
        done,
        completedOn: on,
        seeded: false,
      )?.slug,
      'ansiedade',
    );
  });

  test('a choice made before the seed keeps the old trail as principal', () {
    final done = ['genesis-1', 'ansiedade-1'];
    final on = {'ansiedade-1': '2026-10-30'};
    expect(
      TrailProgress.freeOpenTrails(
        trails,
        done,
        chosenAt: {'ansiedade': '2026-10-30T11:00:00'},
        completedOn: on,
        seeded: false,
      ).map((t) => t.slug),
      ['genesis'],
    );
  });

  test('free open list: the principal and the gifts, not the catalog', () {
    TrailProgress.preferredTrailSlug = 'ansiedade';
    addTearDown(() => TrailProgress.preferredTrailSlug = null);

    expect(TrailProgress.freeOpenTrails(trails, const []).map((t) => t.slug), [
      'ansiedade',
    ]);
    PlusAccess.giftedTrails = {'oracao'};
    expect(
      TrailProgress.freeOpenTrails(
        trails,
        ['genesis-1'],
        chosenAt: {'genesis': day1},
      ).map((t) => t.slug),
      ['genesis', 'oracao'],
    );
  });
}
