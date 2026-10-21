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
          Mission(slug: 'm1', title: 'M1', intro: '', type: 'lesson', stepsReward: 50, questions: []),
          Mission(slug: 'm2', title: 'M2', intro: '', type: 'lesson', stepsReward: 50, questions: []),
        ],
      ),
    ],
  );

  test('first mission is always unlocked', () {
    expect(TrailProgress.isMissionUnlocked('m1', trail.missionSlugs, []), isTrue);
  });

  test('mission unlock respects sequence when catalog gated', () {
    final unlocked =
        TrailProgress.isMissionUnlocked('m2', trail.missionSlugs, []);
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
    expect(
      TrailProgress.isTrailUnlocked(sermon, path, ['a1', 'r1']),
      isTrue,
    );
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

  test('a trail outside NT still waits for a prerequisite in another journey', () {
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
    expect(
      TrailProgress.isTrailUnlocked(prayer, [psalms, prayer], []),
      isFalse,
    );
    expect(
      TrailProgress.isTrailUnlocked(prayer, [psalms, prayer], ['p1']),
      isTrue,
    );
  });

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
    final afterDone =
        TrailProgress.isTrailUnlocked(trails[1], trails, ['m1', 'm2']);
    if (CatalogAccess.openAllForTesting) {
      expect(locked, isTrue);
      expect(afterDone, isTrue);
    } else {
      expect(locked, isFalse);
      expect(afterDone, isTrue);
    }
  });
}
