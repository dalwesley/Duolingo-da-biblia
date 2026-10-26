import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/models/caravan_pilgrim_profile.dart';
import 'package:trilha_app/models/pilgrim_medals.dart';
import 'package:trilha_app/models/season_walk.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/services/progress_service.dart';
import 'package:trilha_app/widgets/season_walk_together.dart';

Trail _trail(List<Mission> missions) => Trail(
  slug: 'mateus',
  title: 'Mateus',
  description: '',
  icon: '📖',
  order: 1,
  comingSoon: false,
  color: '#2F5D4A',
  modules: [TrailModule(title: 'Mod', icon: '🌍', missions: missions)],
);

Mission _mission(String slug, String type) => Mission(
  slug: slug,
  title: slug,
  intro: '',
  type: type,
  stepsReward: 50,
  questions: const [],
);

Set<String> _rareIds(CaravanPilgrimProfile profile, List<Trail> catalog) => {
  for (final vault in PilgrimMedals.evaluateVaults(
    profile: profile,
    catalog: catalog,
  ))
    for (final s in vault.rareMedals)
      if (s.unlocked) s.def.id,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Ranking: cena paga uma vez por modo', () {
    test('trocar de modo e voltar não paga de novo no mês', () async {
      final p = ProgressService();
      await p.completeMission('cena-1', 50, mode: 'semente');
      expect(p.currentMonthSteps, 50);

      // Troca de modo zera a trilha: a cena volta a ser "nova".
      p.completedMissions = [];
      await p.completeMission('cena-1', 75, mode: 'caminhada');
      expect(p.currentMonthSteps, 125, reason: 'modo novo conta');

      p.completedMissions = [];
      final journeyBefore = p.steps;
      await p.completeMission('cena-1', 50, mode: 'semente');
      expect(p.currentMonthSteps, 125, reason: 'modo já pago não conta');
      expect(p.steps - journeyBefore, 50, reason: 'a jornada continua somando');
      expect(p.currentWeekScenes, 2);
    });
  });

  group('Medalhas', () {
    test('Caminho usa a melhor sequência, não só a atual', () {
      const profile = CaravanPilgrimProfile(
        name: 'Ana',
        steps: 10,
        streak: 1,
        bestStreak: 15,
      );
      expect(profile.streakRecord, 15);
    });

    test('Travessia perfeita vale pelo tipo da cena, não pelo slug', () {
      final catalog = [
        _trail([_mission('a-queda', 'lesson'), _mission('o-diluvio', 'boss')]),
      ];
      final perfectBoss = CaravanPilgrimProfile(
        name: 'Ana',
        steps: 10,
        perfectMissions: const ['o-diluvio'],
      );
      final perfectLesson = CaravanPilgrimProfile(
        name: 'Ana',
        steps: 10,
        perfectMissions: const ['a-queda'],
      );
      expect(
        _rareIds(perfectBoss, catalog),
        contains('discovery:perfect_boss'),
      );
      expect(
        _rareIds(perfectLesson, catalog),
        isNot(contains('discovery:perfect_boss')),
      );
    });
  });

  group('Caminhada coletiva', () {
    final campaign = SeasonWalkCampaign(
      id: 'advento-2026',
      kind: SeasonWalkKind.advent,
      title: 'Advento',
      subtitle: '',
      start: DateTime(2026, 11, 29),
      days: [
        for (var i = 1; i <= 7; i++)
          SeasonWalkDay(
            index: i,
            missionSlug: 'cena-$i',
            trailSlug: 'mateus',
            title: 'Dia $i',
            insight: '',
          ),
      ],
    );

    test('aparece 21 dias antes e some depois do último dia', () {
      expect(
        SeasonWalkTogetherCard.visibleOn(campaign, DateTime(2026, 11, 7)),
        isFalse,
      );
      expect(
        SeasonWalkTogetherCard.visibleOn(campaign, DateTime(2026, 11, 8)),
        isTrue,
      );
      expect(
        SeasonWalkTogetherCard.visibleOn(campaign, DateTime(2026, 12, 5)),
        isTrue,
      );
      expect(
        SeasonWalkTogetherCard.visibleOn(campaign, DateTime(2026, 12, 6)),
        isFalse,
      );
    });

    test('conta os dias até o início', () {
      expect(
        SeasonWalkTogetherCard.daysUntilStart(campaign, DateTime(2026, 11, 26)),
        3,
      );
      expect(
        SeasonWalkTogetherCard.daysUntilStart(campaign, DateTime(2026, 12, 1)),
        0,
      );
    });
  });
}
