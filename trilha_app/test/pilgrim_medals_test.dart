import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/caravan_pilgrim_profile.dart';
import 'package:trilha_app/models/pilgrim_medal_catalog.dart';
import 'package:trilha_app/models/pilgrim_medals.dart';

void main() {
  group('PilgrimMedals v3', () {
    test('word track reaches bronze from chapters only', () {
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
      expect(word.currentLevel?.tier, PilgrimMedalTier.bronze);
    });

    test('formation track unlocks silver with five perfect missions', () {
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

      expect(formation.levelIndex, 1);
      expect(formation.currentLevel?.tier, PilgrimMedalTier.silver);
    });

    test('gospel level requires gospel abbrev', () {
      const withGospel = CaravanPilgrimProfile(
        name: 'João',
        steps: 1,
        completeBibleBooks: ['mt'],
        completeNtBooks: ['mt'],
        bibleChaptersRead: 28,
      );
      const withoutGospel = CaravanPilgrimProfile(
        name: 'João',
        steps: 1,
        bibleChaptersRead: 50,
      );

      int wordLevel(CaravanPilgrimProfile p) => PilgrimMedals.evaluateVaults(
            profile: p,
            catalog: const [],
          ).first.tracks
              .firstWhere((t) => t.track.id == PilgrimMedalCatalog.trackWordId)
              .levelIndex;

      expect(wordLevel(withGospel), greaterThanOrEqualTo(3));
      expect(wordLevel(withoutGospel), 1);
    });

    test('newTierUps excludes celebrated level ids', () {
      const profile = CaravanPilgrimProfile(
        name: 'Test',
        steps: 10,
        sharedVerseCount: 1,
      );

      final pending = PilgrimMedals.newTierUps(
        profile,
        {'track:witness:0'},
        const [],
      );
      expect(
        pending.map((t) => t.celebrationId),
        isNot(contains('track:witness:0')),
      );
      expect(
        PilgrimMedals.newTierUps(profile, const {}, const [])
            .map((t) => t.celebrationId),
        contains('track:witness:0'),
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
        sharedVerseCount: 1,
      );

      final proximity = PilgrimMedals.nearestLocked(
        profile: profile,
        catalog: const [],
      );
      expect(proximity?.nextLevel.id, 'track:word:1');
      expect(proximity?.remaining, 3);
    });

    test('isJourneyVaultComplete when all journey tracks maxed', () {
      final profile = CaravanPilgrimProfile(
        name: 'Test',
        steps: 500,
        streak: 90,
        bibleChaptersRead: 200,
        sharedVerseCount: 50,
        memoryMasteredCount: 50,
        daysAsCaravanLeader: 1,
        perfectMissions: [...List.filled(25, 'm'), 'gen-boss-01'],
        lifetimeQuestionsAnswered: 50,
        lifetimeQuestionsCorrect: 45,
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
        streak: 6,
        bibleChaptersRead: 30,
        sharedVerseCount: 1,
        perfectMissions: ['gen-01'],
      );

      final proximity = PilgrimMedals.nearestLocked(
        profile: profile,
        catalog: const [],
      );
      expect(proximity?.nextLevel.id, 'track:path:1');
      expect(proximity?.remaining, 1);
      expect(proximity?.shortMessage, contains('Falta 1'));
    });
  });
}
