import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/utils/catalog_access.dart';
import 'package:trilha_app/utils/trail_progress.dart';

void main() {
  final trail = Trail(
    slug: 'test',
    title: 'Test',
    description: 'Test trail',
    icon: '📖',
    order: 1,
    comingSoon: false,
    color: '#2F5D4A',
    modules: [
      TrailModule(
        title: 'Mod 1',
        icon: '🌍',
        missions: [
          Mission(
            slug: 'm1',
            title: 'M1',
            intro: '',
            type: 'lesson',
            stepsReward: 50,
            questions: [],
          ),
          Mission(
            slug: 'm2',
            title: 'M2',
            intro: '',
            type: 'lesson',
            stepsReward: 50,
            questions: [],
          ),
        ],
      ),
    ],
  );

  test('first mission is always unlocked', () {
    expect(
      TrailProgress.isMissionUnlocked('m1', trail.missionSlugs, []),
      isTrue,
    );
  });

  test('mission unlock respects sequence when catalog gated', () {
    final unlocked = TrailProgress.isMissionUnlocked(
      'm2',
      trail.missionSlugs,
      [],
    );
    if (CatalogAccess.openAllForTesting) {
      expect(unlocked, isTrue);
    } else {
      expect(unlocked, isFalse);
    }
  });

  test('progress calculates correctly', () {
    final prog = TrailProgress.getProgress(trail, ['m1']);
    expect(prog.done, 1);
    expect(prog.total, 2);
    expect(prog.pct, 50);
  });

  test('cleared mode keeps trail complete after mission wipe', () {
    const cleared = {
      'test': ['semente'],
    };
    expect(
      TrailProgress.isTrailCompleted(trail, [], clearedTrailModes: cleared),
      isTrue,
    );
    final prog = TrailProgress.getProgress(
      trail,
      [],
      clearedTrailModes: cleared,
    );
    expect(prog.done, 2);
    expect(prog.total, 2);
    expect(prog.pct, 100);
    expect(TrailProgress.getLiveProgress(trail, []).done, 0);
    expect(
      TrailProgress.clearedModeStatusLabel(['semente']),
      'Observação concluída',
    );
    expect(
      TrailProgress.activeModeProgressLabel(
        clearedModes: ['semente'],
        activeDifficultyId: 'semente',
        liveDone: 2,
        total: 2,
      ),
      'Observação concluída',
    );
    expect(
      TrailProgress.modeSealedHint(
        clearedModes: ['semente'],
        activeDifficultyId: 'semente',
      ),
      'Observação concluída · o próximo modo é Compreensão',
    );
    expect(
      TrailProgress.openDifficultyId(
        activeDifficultyId: 'semente',
        clearedModes: const ['semente'],
      ),
      'caminhada',
    );
    expect(
      TrailProgress.openDifficultyId(
        activeDifficultyId: 'semente',
        clearedModes: const [],
      ),
      'semente',
    );
    expect(
      TrailProgress.openDifficultyId(
        activeDifficultyId: 'caminhada',
        clearedModes: const ['semente'],
      ),
      'caminhada',
    );
    expect(
      TrailProgress.openDifficultyId(
        activeDifficultyId: 'semente',
        clearedModes: const ['semente', 'caminhada'],
      ),
      'profundezas',
    );
    expect(
      TrailProgress.resolvedDifficultyId('genesis-12-50', 'caminhada'),
      'caminhada',
    );
    expect(
      TrailProgress.modeChipLabel(
        difficultyId: 'semente',
        clearedModes: const [],
      ),
      'Modo Observação',
    );
    expect(
      TrailProgress.activeModeProgressLabel(
        clearedModes: const [],
        activeDifficultyId: 'semente',
        liveDone: 7,
        total: 23,
      ),
      'Observação · 7 de 23 cenas',
    );
    expect(
      TrailProgress.isReplayingUnclearedMode(
        clearedModes: ['semente'],
        activeDifficultyId: 'caminhada',
        liveDone: 0,
        total: 2,
      ),
      isTrue,
    );
    expect(
      TrailProgress.modeReplayHint(
        clearedModes: ['semente'],
        activeDifficultyId: 'caminhada',
      ),
      'Observação concluída · progresso abaixo é do modo Compreensão',
    );
  });

  test('findActiveTrail skips cleared trail after mode switch wipe', () {
    final trails = [
      trail,
      Trail(
        slug: 't2',
        title: 'T2',
        description: '',
        icon: '📖',
        order: 2,
        unlockAfter: 'test',
        comingSoon: false,
        color: '#2F5D4A',
        modules: [
          TrailModule(
            title: 'Mod',
            icon: '🌍',
            missions: [
              Mission(
                slug: 'n1',
                title: 'N1',
                intro: '',
                type: 'lesson',
                stepsReward: 50,
                questions: [],
              ),
            ],
          ),
        ],
      ),
    ];
    const cleared = {
      'test': ['semente'],
    };
    final active = TrailProgress.findActiveTrail(
      trails,
      [],
      clearedTrailModes: cleared,
    );
    expect(active?.slug, 't2');
  });

  test('Sermão and NT trails are open without OT prerequisite', () {
    final nt = Trail(
      slug: 'evangelhos',
      title: 'Evangelhos',
      description: '',
      icon: '📖',
      order: 40,
      unlockAfter: 'exodo',
      comingSoon: false,
      color: '#E17055',
      realmId: 'novo-testamento',
      categoryId: 'evangelhos',
      modules: [],
    );
    final sermao = Trail(
      slug: 'sermao-do-monte',
      title: 'Sermão',
      description: '',
      icon: '⛰️',
      order: 199,
      unlockAfter: 'evangelhos',
      comingSoon: false,
      color: '#3F6E45',
      realmId: 'vida-crista',
      categoryId: 'discipulado',
      modules: [],
    );
    expect(TrailProgress.isTrailUnlocked(nt, [trail, nt], []), isTrue);
    expect(TrailProgress.isTrailUnlocked(sermao, [trail, sermao], []), isTrue);
  });

  Trail contentTrail({
    required String slug,
    required String mission,
    int order = 1,
    String? unlockAfter,
    String realmId = 'antigo-testamento',
    String categoryId = 'pentateuco',
  }) {
    return Trail(
      slug: slug,
      title: slug,
      description: '',
      icon: '📖',
      order: order,
      unlockAfter: unlockAfter,
      comingSoon: false,
      color: '#2F5D4A',
      realmId: realmId,
      categoryId: categoryId,
      modules: [
        TrailModule(
          title: 'Mod',
          icon: '🌍',
          missions: [
            Mission(
              slug: mission,
              title: mission,
              intro: '',
              type: 'lesson',
              stepsReward: 50,
              questions: [],
            ),
          ],
        ),
      ],
    );
  }

  test('same journey opens one trail at a time', () {
    final anxiety = contentTrail(
      slug: 'ansiedade',
      mission: 'a1',
      order: 0,
      realmId: 'vida-crista',
      categoryId: 'discipulado',
    );
    final restart = contentTrail(
      slug: 'recomeco',
      mission: 'r1',
      order: 1,
      realmId: 'vida-crista',
      categoryId: 'discipulado',
    );
    final sermon = contentTrail(
      slug: 'sermao-do-monte',
      mission: 's1',
      order: 199,
      realmId: 'vida-crista',
      categoryId: 'discipulado',
    );
    final path = [anxiety, restart, sermon];

    expect(TrailProgress.isTrailUnlocked(anxiety, path, []), isTrue);
    expect(TrailProgress.isTrailUnlocked(restart, path, []), isFalse);
    expect(TrailProgress.isTrailUnlocked(sermon, path, []), isFalse);

    expect(TrailProgress.isTrailUnlocked(restart, path, ['a1']), isTrue);
    expect(TrailProgress.isTrailUnlocked(sermon, path, ['a1']), isFalse);
    expect(TrailProgress.isTrailUnlocked(sermon, path, ['a1', 'r1']), isTrue);
  });

  test('a trail already started stays open behind an unfinished one', () {
    final anxiety = contentTrail(
      slug: 'ansiedade',
      mission: 'a1',
      order: 0,
      realmId: 'vida-crista',
      categoryId: 'discipulado',
    );
    final sermon = contentTrail(
      slug: 'sermao-do-monte',
      mission: 's1',
      order: 199,
      realmId: 'vida-crista',
      categoryId: 'discipulado',
    );
    expect(
      TrailProgress.isTrailUnlocked(sermon, [anxiety, sermon], ['s1']),
      isTrue,
    );
  });

  test('NT chains inside the journey and does not wait for the OT', () {
    final exodus = contentTrail(slug: 'exodo', mission: 'e1', order: 3);
    final gospels = contentTrail(
      slug: 'evangelhos',
      mission: 'g1',
      order: 40,
      unlockAfter: 'exodo',
      realmId: 'novo-testamento',
      categoryId: 'evangelhos',
    );
    final matthew = contentTrail(
      slug: 'mateus',
      mission: 'm1',
      order: 41,
      realmId: 'novo-testamento',
      categoryId: 'evangelhos',
    );
    final path = [exodus, gospels, matthew];

    expect(TrailProgress.isTrailUnlocked(gospels, path, []), isTrue);
    expect(TrailProgress.isTrailUnlocked(matthew, path, []), isFalse);
    expect(TrailProgress.isTrailUnlocked(matthew, path, ['g1']), isTrue);
  });

  test(
    'uma trilha Peregrino+ não espera o pré-requisito de outra área',
    () {
      final psalms = contentTrail(
        slug: 'salmos',
        mission: 'p1',
        order: 21,
        categoryId: 'poeticos',
      );
      final prayer = contentTrail(
        slug: 'oracao',
        mission: 'o1',
        order: 210,
        unlockAfter: 'salmos',
        realmId: 'vida-crista',
        categoryId: 'oracao',
      );
      // Oração é tema (Plus): quem assina não precisa terminar Salmos.
      expect(
        TrailProgress.isTrailUnlocked(prayer, [psalms, prayer], []),
        isTrue,
      );
    },
  );

  test('trail unlock requires prerequisite when catalog gated', () {
    final trails = [
      trail,
      Trail(
        slug: 't2',
        title: 'T2',
        description: '',
        icon: '📖',
        order: 2,
        unlockAfter: 'test',
        comingSoon: false,
        color: '#2F5D4A',
        modules: [],
      ),
    ];
    final locked = TrailProgress.isTrailUnlocked(trails[1], trails, []);
    final afterDone = TrailProgress.isTrailUnlocked(trails[1], trails, [
      'm1',
      'm2',
    ]);
    if (CatalogAccess.openAllForTesting) {
      expect(locked, isTrue);
      expect(afterDone, isTrue);
    } else {
      expect(locked, isFalse);
      expect(afterDone, isTrue);
    }
  });

  test('trilha Plus não espera AT/NT, mas segue a ordem do caminho', () {
    Trail make(String slug, String realm, String? after, int order) => Trail(
      slug: slug,
      title: slug,
      description: '',
      icon: '📖',
      order: order,
      unlockAfter: after,
      comingSoon: false,
      color: '#2F5D4A',
      realmId: realm,
      categoryId: realm == 'vida-crista' ? 'historia-igreja' : 'historia',
      modules: [
        TrailModule(
          title: 'Mod',
          icon: '🌍',
          missions: [
            Mission(
              slug: '$slug-1',
              title: 'M',
              intro: '',
              type: 'lesson',
              stepsReward: 50,
              questions: [],
            ),
          ],
        ),
      ],
    );
    final atos = make('atos', 'novo-testamento', null, 1);
    final historia = make('historia-igreja', 'vida-crista', 'atos', 1);
    final primitiva = make(
      'igreja-primitiva',
      'vida-crista',
      'historia-igreja',
      2,
    );
    final all = [atos, historia, primitiva];

    expect(TrailProgress.blockingTrail(historia, all, []), isNull);
    expect(
      TrailProgress.blockingTrail(primitiva, all, [])?.slug,
      'historia-igreja',
    );
    expect(
      TrailProgress.blockingTrail(primitiva, all, ['historia-igreja-1']),
      isNull,
    );
    if (CatalogAccess.openAllForTesting) return;
    expect(TrailProgress.isTrailUnlocked(historia, all, []), isTrue);
    expect(TrailProgress.isTrailUnlocked(primitiva, all, []), isFalse);
  });

  test('intent trail leads only for whoever chose that reason', () {
    final anxiety = contentTrail(
      slug: 'ansiedade',
      mission: 'a1',
      order: 0,
      realmId: 'vida-crista',
      categoryId: 'discipulado',
    );
    final knowGod = contentTrail(
      slug: 'conhecer-a-deus',
      mission: 'k1',
      order: 2,
      realmId: 'vida-crista',
      categoryId: 'discipulado',
    );
    final sermon = contentTrail(
      slug: 'sermao-do-monte',
      mission: 's1',
      order: 199,
      realmId: 'vida-crista',
      categoryId: 'discipulado',
    );
    final all = [anxiety, knowGod, sermon];
    addTearDown(() => TrailProgress.preferredTrailSlug = null);

    TrailProgress.preferredTrailSlug = null;
    expect(TrailProgress.findActiveTrail(all, [])?.slug, 'ansiedade');
    // Sem motivo, a trilha do motivo não entra na fila de ninguém.
    expect(
      TrailProgress.findActiveTrail(all, ['a1'])?.slug,
      isNot('conhecer-a-deus'),
    );
    expect(TrailProgress.isTrailUnlocked(knowGod, all, []), isTrue);

    TrailProgress.preferredTrailSlug = 'conhecer-a-deus';
    expect(TrailProgress.findActiveTrail(all, [])?.slug, 'conhecer-a-deus');
    // Terminada, volta para a ordem do caminho.
    expect(TrailProgress.findActiveTrail(all, ['k1'])?.slug, 'ansiedade');
  });

  test('Home follows the last trail walked, then where it continues', () {
    final anxiety = contentTrail(
      slug: 'ansiedade',
      mission: 'a1',
      order: 0,
      realmId: 'vida-crista',
      categoryId: 'discipulado',
    );
    final knowGod = contentTrail(
      slug: 'conhecer-a-deus',
      mission: 'entrada-deus-05',
      order: 2,
      realmId: 'vida-crista',
      categoryId: 'discipulado',
    );
    final gospels = contentTrail(
      slug: 'evangelhos',
      mission: 'e1',
      order: 50,
      realmId: 'novo-testamento',
      categoryId: 'evangelhos',
    );
    final exodus = contentTrail(slug: 'exodo', mission: 'x1', order: 2);
    final all = [anxiety, knowGod, gospels, exodus];
    addTearDown(() {
      TrailProgress.preferredTrailSlug = null;
      TrailProgress.lastPlayedMissionSlug = null;
    });

    TrailProgress.preferredTrailSlug = 'conhecer-a-deus';
    TrailProgress.lastPlayedMissionSlug = null;
    expect(TrailProgress.findActiveTrail(all, [])?.slug, 'conhecer-a-deus');

    // Andou em Êxodo pela aba Trilhas: o CTA vai junto.
    TrailProgress.lastPlayedMissionSlug = 'x1';
    expect(TrailProgress.findActiveTrail(all, [])?.slug, 'exodo');

    // Terminou a trilha do motivo: segue para onde ela continua.
    TrailProgress.lastPlayedMissionSlug = 'entrada-deus-05';
    expect(
      TrailProgress.findActiveTrail(all, ['entrada-deus-05'])?.slug,
      'evangelhos',
    );
  });

  test('started trails list the last walked first, then by day', () {
    final genesis = contentTrail(slug: 'genesis-1-11', mission: 'g1');
    final exodus = contentTrail(slug: 'exodo', mission: 'x1', order: 2);
    final psalms = contentTrail(slug: 'salmos', mission: 'p1', order: 3);
    final untouched = contentTrail(slug: 'rute', mission: 'r1', order: 4);
    addTearDown(() => TrailProgress.lastPlayedMissionSlug = null);
    // Duas cenas por trilha, para "começada" não virar "terminada".
    Trail twoScenes(Trail t) => Trail(
      slug: t.slug,
      title: t.title,
      description: '',
      icon: t.icon,
      order: t.order,
      comingSoon: false,
      color: t.color,
      realmId: t.realmId,
      categoryId: t.categoryId,
      modules: [
        TrailModule(
          title: '',
          icon: '',
          missions: [
            ...t.modules.first.missions,
            Mission(
              slug: '${t.slug}-2',
              title: '',
              intro: '',
              type: 'lesson',
              stepsReward: 50,
              questions: const [],
            ),
          ],
        ),
      ],
    );
    final all = [genesis, exodus, psalms, untouched].map(twoScenes).toList();

    TrailProgress.lastPlayedMissionSlug = 'x1';
    final started = TrailProgress.startedTrails(
      all,
      ['g1', 'x1', 'p1'],
      completedOn: {
        'g1': '2026-10-20',
        'x1': '2026-10-01',
        'p1': '2026-10-21',
      },
    );
    expect(started.map((t) => t.slug), ['exodo', 'salmos', 'genesis-1-11']);

    // Salmos só tem cena emprestada de uma trilha de entrada: não abre.
    final withBorrowed = TrailProgress.startedTrails(
      all,
      ['g1', 'x1', 'p1'],
      borrowed: ['p1'],
    );
    expect(withBorrowed.map((t) => t.slug), ['exodo', 'genesis-1-11']);
  });
}
