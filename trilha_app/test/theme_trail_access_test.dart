import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/models/trail_catalog.dart';
import 'package:trilha_app/utils/plus_access.dart';
import 'package:trilha_app/utils/trail_progress.dart';

Trail _trail(String realmId, {String categoryId = 'pentateuco'}) => Trail(
  slug: 'test-$realmId',
  title: 'Test',
  description: '',
  icon: '📖',
  order: 1,
  comingSoon: false,
  color: '#2F5D4A',
  realmId: realmId,
  categoryId: categoryId,
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
    TrailModule(
      title: 'Mod 2',
      icon: '🌍',
      missions: [
        Mission(
          slug: 'm3',
          title: 'M3',
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
  test('card da Bíblia é grátis: AT e NT não pedem Plus', () {
    for (final (realm, category) in [
      (TrailRealm.antigoTestamento.id, 'pentateuco'),
      (TrailRealm.antigoTestamento.id, 'profetas-menores'),
      (TrailRealm.novoTestamento.id, 'evangelhos'),
      (TrailRealm.novoTestamento.id, 'epistolas'),
    ]) {
      final t = _trail(realm, categoryId: category);
      expect(PlusAccess.trailIsPlus(t), isFalse, reason: category);
      expect(PlusAccess.missionNeedsPlus(t, 'm2'), isFalse);
      expect(PlusAccess.missionNeedsPlus(t, 'm3'), isFalse);
    }
  });

  test('Sabedoria e os temas são Plus, com a 1ª cena de amostra', () {
    final wisdom = _trail(
      TrailRealm.antigoTestamento.id,
      categoryId: 'poeticos',
    );
    expect(wisdom.journey, TrailJourney.sabedoria);
    expect(PlusAccess.trailIsPlus(wisdom), isTrue);
    expect(PlusAccess.missionNeedsPlus(wisdom, 'm1'), isFalse);
    expect(PlusAccess.missionNeedsPlus(wisdom, 'm2'), isTrue);

    final themes = _trail(TrailRealm.novoTestamento.id, categoryId: 'panorama');
    expect(themes.journey, TrailJourney.panorama);
    expect(PlusAccess.trailIsPlus(themes), isTrue);
  });

  test('tema é Plus, com a 1ª cena de amostra', () {
    for (final realm in [TrailRealm.vidaCrista, TrailRealm.teologia]) {
      final t = _trail(realm.id);
      expect(PlusAccess.trailIsPlus(t), isTrue);
      expect(PlusAccess.missionNeedsPlus(t, 'm1'), isFalse);
      expect(PlusAccess.missionNeedsPlus(t, 'm2'), isTrue);
      expect(PlusAccess.missionNeedsPlus(t, 'm3'), isTrue);
    }
  });

  test('próxima cena pede Plus só depois da amostra', () {
    final t = _trail(TrailRealm.vidaCrista.id);
    expect(TrailProgress.nextSceneNeedsPlus(t, []), isFalse);
    expect(TrailProgress.nextSceneNeedsPlus(t, ['m1']), isTrue);
    expect(TrailProgress.nextSceneNeedsPlus(t, ['m1', 'm2', 'm3']), isFalse);
    expect(
      TrailProgress.nextSceneNeedsPlus(_trail(TrailRealm.novoTestamento.id), [
        'm1',
      ]),
      isFalse,
    );
  });
}
