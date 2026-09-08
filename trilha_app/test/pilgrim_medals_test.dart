import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/caravan_pilgrim_profile.dart';
import 'package:trilha_app/models/pilgrim_medal_catalog.dart';
import 'package:trilha_app/models/pilgrim_medals.dart';
import 'package:trilha_app/models/trail.dart';

Trail _trail(String slug, List<String> slugs) => Trail(
      slug: slug,
      title: slug == 'genesis-1-11' ? 'Gênesis 1–11' : slug,
      description: '',
      icon: '📖',
      order: 1,
      comingSoon: false,
      color: '#2F5D4A',
      modules: [
        TrailModule(
          title: 'Mod',
          icon: '🌍',
          missions: [
            for (final s in slugs)
              Mission(
                slug: s,
                title: s,
                intro: '',
                type: 'lesson',
                stepsReward: 50,
                questions: const [],
              ),
          ],
        ),
      ],
    );

void main() {
  group('PilgrimMedals v3.2', () {
    test('word track reaches silver from 25 chapters only', () {
      const profile = CaravanPilgrimProfile(
        name: 'Ana',
        steps: 100,
        bibleChaptersRead: 30,
      );

      final word = PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: const [],
      ).first.tracks.firstWhere(
            (t) => t.track.id == PilgrimMedalCatalog.trackWordId,
          );

      expect(word.levelIndex, 1);
      expect(word.currentLevel?.id, 'track:word:chapters_25');
      expect(word.currentLevel?.tier, PilgrimMedalTier.silver);
      expect(word.currentLevel?.isTrophy, isTrue);
    });

    test('word 7 chapters is still spark, not a medal', () {
      const profile = CaravanPilgrimProfile(
        name: 'Ana',
        steps: 10,
        bibleChaptersRead: 7,
      );

      final word = PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: const [],
      ).first.tracks.firstWhere(
            (t) => t.track.id == PilgrimMedalCatalog.trackWordId,
          );
      expect(word.currentLevel?.id, 'track:word:chapters_1');
      expect(word.currentLevel?.isSpark, isTrue);
    });

    test('finished book does not grant Palavra gold', () {
      const profile = CaravanPilgrimProfile(
        name: 'João',
        steps: 1,
        completeBibleBooks: ['mt'],
        completeNtBooks: ['mt'],
        bibleChaptersRead: 28,
      );

      final word = PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: const [],
      ).first.tracks.firstWhere(
            (t) => t.track.id == PilgrimMedalCatalog.trackWordId,
          );
      expect(word.currentLevel?.id, 'track:word:chapters_25');
      expect(word.isComplete, isFalse);

      final rares = PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: const [],
      ).firstWhere((v) => v.vault.kind == PilgrimVaultKind.discovery);
      expect(
        rares.rareMedals.any((m) => m.def.id == 'discovery:word_nt'),
        isFalse,
      );
      expect(
        rares.rareMedals.any((m) => m.def.id == 'discovery:word_ot'),
        isFalse,
      );
    });

    test('100 chapters is Palavra gold', () {
      const profile = CaravanPilgrimProfile(
        name: 'Ana',
        steps: 1,
        bibleChaptersRead: 100,
      );
      final word = PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: const [],
      ).first.tracks.firstWhere(
            (t) => t.track.id == PilgrimMedalCatalog.trackWordId,
          );
      expect(word.currentLevel?.id, 'track:word:chapters_100');
      expect(word.isComplete, isTrue);
    });

    test('leader day does not paint 90-day path', () {
      const profile = CaravanPilgrimProfile(
        name: 'Ana',
        steps: 10,
        streak: 3,
        daysAsCaravanLeader: 1,
      );

      final path = PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: const [],
      ).first.tracks.firstWhere(
            (t) => t.track.id == PilgrimMedalCatalog.trackPathId,
          );
      expect(path.levelIndex, 0);
      expect(path.currentLevel?.id, 'track:path:streak_3');
      expect(path.isComplete, isFalse);

      final rares = PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: const [],
      ).firstWhere((v) => v.vault.kind == PilgrimVaultKind.discovery);
      expect(
        rares.rareMedals.any((m) => m.def.id == 'discovery:leader' && m.unlocked),
        isTrue,
      );
    });

    test('five perfect missions stay spark, not a medal', () {
      const profile = CaravanPilgrimProfile(
        name: 'Ana',
        steps: 100,
        perfectMissions: ['gen-01', 'gen-02', 'gen-03', 'gen-04', 'gen-05'],
      );

      final formation = PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: const [],
      ).first.tracks.firstWhere(
            (t) => t.track.id == PilgrimMedalCatalog.trackFormationId,
          );

      expect(formation.levelIndex, 0);
      expect(formation.currentLevel?.isSpark, isTrue);
    });

    test('boss 100% does not complete formation', () {
      const profile = CaravanPilgrimProfile(
        name: 'Ana',
        steps: 10,
        perfectMissions: ['gen-boss-01'],
      );

      final formation = PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: const [],
      ).first.tracks.firstWhere(
            (t) => t.track.id == PilgrimMedalCatalog.trackFormationId,
          );
      expect(formation.levelIndex, 0);
      expect(formation.isComplete, isFalse);
    });

    test('memory starts at one verse spark', () {
      const profile = CaravanPilgrimProfile(
        name: 'Ana',
        steps: 1,
        memoryMasteredCount: 1,
      );
      final memory = PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: const [],
      ).first.tracks.firstWhere(
            (t) => t.track.id == PilgrimMedalCatalog.trackMemoryId,
          );
      expect(memory.currentLevel?.id, 'track:memory:verse_1');
      expect(memory.currentLevel?.isSpark, isTrue);
    });

    test('trophyTiles skips sparks', () {
      const profile = CaravanPilgrimProfile(
        name: 'Ana',
        steps: 10,
        bibleChaptersRead: 25,
      );
      final word = PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: const [],
      ).first.tracks.firstWhere(
            (t) => t.track.id == PilgrimMedalCatalog.trackWordId,
          );
      final trophies = PilgrimMedals.trophyTiles(word);
      expect(trophies.map((t) => t.id), isNot(contains('track:word:chapters_1')));
      expect(trophies.map((t) => t.id), contains('track:word:chapters_25'));
      expect(trophies.where((t) => t.unlocked).length, 1);
    });

    test('newTierUps excludes celebrated level ids', () {
      const profile = CaravanPilgrimProfile(
        name: 'Test',
        steps: 10,
        sharedVerseCount: 1,
      );

      final pending = PilgrimMedals.newTierUps(
        profile,
        {'track:witness:share_1'},
        const [],
      );
      expect(
        pending.map((t) => t.celebrationId),
        isNot(contains('track:witness:share_1')),
      );
      expect(
        PilgrimMedals.newTierUps(profile, const {}, const [])
            .map((t) => t.celebrationId),
        contains('track:witness:share_1'),
      );
    });

    test('newTierUps migrates v2 celebrated ids', () {
      const profile = CaravanPilgrimProfile(
        name: 'Test',
        steps: 10,
        sharedVerseCount: 1,
      );

      final pending = PilgrimMedals.newTierUps(
        profile,
        {'witness_share_1'},
        const [],
      );
      expect(pending, isEmpty);
    });

    test('nearestLocked picks closest quantifiable level', () {
      const profile = CaravanPilgrimProfile(
        name: 'Test',
        steps: 10,
        bibleChaptersRead: 22,
        perfectMissions: ['gen-01'],
        sharedVerseCount: 3,
        memoryMasteredCount: 1,
      );

      final proximity = PilgrimMedals.nearestLocked(
        profile: profile,
        catalog: const [],
      );
      expect(proximity?.nextLevel.id, 'track:word:chapters_25');
      expect(proximity?.remaining, 3);
      expect(proximity?.isNearMiss, isTrue);
      expect(proximity?.actionMessage, contains('Palavra'));
    });

    test('isJourneyVaultComplete when all journey tracks maxed', () {
      final profile = CaravanPilgrimProfile(
        name: 'Test',
        steps: 500,
        streak: 90,
        bibleChaptersRead: 200,
        sharedVerseCount: 50,
        memoryMasteredCount: 50,
        perfectMissions: List.filled(25, 'm'),
        completeBibleBooks: const ['gn', 'mt'],
        completeNtBooks: const ['mt'],
      );

      final journey = PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: const [],
      ).firstWhere((v) => v.vault.id == PilgrimMedalCatalog.journeyVaultId);

      expect(journey.isComplete, isTrue);
      expect(
        PilgrimMedals.isJourneyVaultComplete(profile, const []),
        isTrue,
      );
    });

    test('nearestLocked returns streak hint when close', () {
      const profile = CaravanPilgrimProfile(
        name: 'Test',
        steps: 10,
        streak: 29,
        bibleChaptersRead: 30,
        completeBibleBooks: ['mt'],
        completeNtBooks: ['mt'],
        sharedVerseCount: 3,
        memoryMasteredCount: 5,
        perfectMissions: ['gen-01'],
      );

      final proximity = PilgrimMedals.nearestLocked(
        profile: profile,
        catalog: const [],
      );
      expect(proximity?.nextLevel.id, 'track:path:streak_30');
      expect(proximity?.remaining, 1);
      expect(proximity?.isNearMiss, isTrue);
      expect(proximity?.shortMessage, contains('Falta 1'));
      expect(proximity?.actionMessage, contains('Falta 1'));
    });

    test('trail semente has proximity from missions done', () {
      final trail = _trail('genesis-1-11', ['a', 'b', 'c', 'd']);
      const profile = CaravanPilgrimProfile(
        name: 'Test',
        steps: 10,
        completedMissions: ['a', 'b', 'c'],
      );

      final proximity = PilgrimMedals.nearestLocked(
        profile: profile,
        catalog: [trail],
        priorityTrailSlug: 'genesis-1-11',
      );
      expect(proximity?.track.trailSlug, 'genesis-1-11');
      expect(proximity?.remaining, 1);
    });

    test('celebrationLine prefers the open trail', () {
      final trail = _trail('genesis-1-11', ['a', 'b']);
      const profile = CaravanPilgrimProfile(
        name: 'Test',
        steps: 10,
        completedMissions: ['a'],
        perfectMissions: ['a'],
        streak: 3,
      );

      final line = PilgrimMedals.celebrationLine(
        profile: profile,
        catalog: [trail],
        trailSlug: 'genesis-1-11',
        perfect: true,
      );
      expect(line?.track.trailSlug, 'genesis-1-11');
      expect(line?.monitorMessage, contains('Gênesis'));
    });
  });
}
