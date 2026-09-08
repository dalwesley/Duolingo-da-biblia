import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/caravan_pilgrim_profile.dart';
import 'package:trilha_app/models/pilgrim_medal_catalog.dart';
import 'package:trilha_app/models/pilgrim_medals.dart';
import 'package:trilha_app/models/trail.dart';

void main() {
  group('PilgrimMedals engagement v3.1', () {
    test('newRareUnlocks excludes celebrated ids', () {
      const profile = CaravanPilgrimProfile(
        name: 'Test',
        steps: 10,
        firstOpenDate: '2026-01-01',
      );

      final pending = PilgrimMedals.newRareUnlocks(
        profile,
        {'discovery:founder'},
        const [],
        ctx: const PilgrimMedalEvalContext(firstOpenDate: '2026-01-01'),
      );
      expect(
        pending.map((s) => s.def.id),
        isNot(contains('discovery:founder')),
      );
      expect(
        PilgrimMedals.newRareUnlocks(
          profile,
          const {},
          const [],
          ctx: const PilgrimMedalEvalContext(firstOpenDate: '2026-01-01'),
        ).map((s) => s.def.id),
        contains('discovery:founder'),
      );
    });

    test('tilesForVault returns one emblem per family, not every level', () {
      const profile = CaravanPilgrimProfile(
        name: 'Ana',
        steps: 10,
        bibleChaptersRead: 25,
      );
      final journey = PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: const [],
      ).firstWhere((v) => v.vault.id == PilgrimMedalCatalog.journeyVaultId);

      final tiles = PilgrimMedals.tilesForVault(journey);
      expect(tiles.length, PilgrimMedalCatalog.journeyTracks.length);
      expect(tiles.map((t) => t.id), contains('track:word'));
      expect(tiles.map((t) => t.id), isNot(contains('track:word:chapters_25')));
    });

    test('trail vault is one evolving emblem, not three coins', () {
      final trail = Trail(
        slug: 'genesis-1-11',
        title: 'Gênesis 1–11',
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
              Mission(
                slug: 'a',
                title: 'a',
                intro: '',
                type: 'lesson',
                stepsReward: 50,
                questions: const [],
              ),
            ],
          ),
        ],
      );
      const profile = CaravanPilgrimProfile(
        name: 'Ana',
        steps: 10,
        completedMissions: ['a'],
      );
      final vault = PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: [trail],
      ).firstWhere((v) => v.vault.kind == PilgrimVaultKind.trail);

      expect(vault.tracks, hasLength(1));
      expect(PilgrimMedals.tilesForVault(vault), hasLength(1));
      expect(vault.tracks.first.track.title, 'Gênesis 1–11');
    });

    test('visibleDiscoveryTiles hides locked rares', () {
      const profile = CaravanPilgrimProfile(name: 'Ana', steps: 1);
      final discovery = PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: const [],
        ctx: const PilgrimMedalEvalContext(firstOpenDate: '2026-01-01'),
      ).firstWhere((v) => v.vault.kind == PilgrimVaultKind.discovery);

      final visible = PilgrimMedals.visibleDiscoveryTiles(discovery);
      expect(visible.map((t) => t.id), contains('discovery:founder'));
      expect(visible.length, 1);
      expect(PilgrimMedals.hiddenDiscoveryCount(discovery), greaterThan(1));
    });

    test('collapsedNewTierUps keeps highest per track', () {
      const profile = CaravanPilgrimProfile(
        name: 'Ana',
        steps: 10,
        bibleChaptersRead: 25,
      );
      final pending = PilgrimMedals.newTierUps(profile, const {}, const []);
      expect(pending.length, greaterThan(1));
      expect(
        pending.map((u) => u.track.id).toSet(),
        contains(PilgrimMedalCatalog.trackWordId),
      );

      final collapsed = PilgrimMedals.collapsedNewTierUps(pending);
      final word = collapsed.where(
        (u) => u.track.id == PilgrimMedalCatalog.trackWordId,
      );
      expect(word.length, 1);
      expect(word.first.level.id, 'track:word:chapters_25');
    });

    test('founder is silent', () {
      final founder = PilgrimMedalCatalog.rareMedals.firstWhere(
        (m) => m.id == 'discovery:founder',
      );
      expect(founder.silent, isTrue);
    });

    test('expandCelebratedIds maps v2 medal to semantic prefix', () {
      final expanded = PilgrimMedalCatalog.expandCelebratedIds([
        'journey:word:chapters_25',
      ]);
      expect(expanded, contains('track:word:chapters_1'));
      expect(expanded, contains('track:word:chapters_25'));
      expect(expanded, isNot(contains('track:word:chapters_7')));
      expect(expanded, isNot(contains('track:word:book')));
    });

    test('legacy numeric word:1 means 25 chapters not 7', () {
      final expanded = PilgrimMedalCatalog.expandCelebratedIds([
        'track:word:1',
      ]);
      expect(expanded, contains('track:word:chapters_25'));
      expect(expanded, contains('track:word:chapters_1'));
      expect(expanded, isNot(contains('track:word:chapters_7')));
    });

    test('bible before mission unlocks rare', () {
      const profile = CaravanPilgrimProfile(name: 'Test', steps: 1);
      final pending = PilgrimMedals.newRareUnlocks(
        profile,
        const {},
        const [],
        ctx: const PilgrimMedalEvalContext(bibleBeforeMission: true),
      );
      expect(
        pending.map((s) => s.def.id),
        contains('discovery:bible_before'),
      );
    });

    test('advent vault visible during window', () {
      const profile = CaravanPilgrimProfile(name: 'Test', steps: 1);
      final vaults = PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: const [],
        ctx: PilgrimMedalEvalContext(
          now: DateTime(2026, 12, 1),
        ),
      );
      expect(
        vaults.any((v) => v.vault.id == PilgrimMedalCatalog.advent2026VaultId),
        isTrue,
      );
    });

    test('advent vault hidden outside window without progress', () {
      const profile = CaravanPilgrimProfile(name: 'Test', steps: 1);
      final vaults = PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: const [],
        ctx: PilgrimMedalEvalContext(
          now: DateTime(2026, 9, 2),
        ),
      );
      expect(
        vaults.any((v) => v.vault.id == PilgrimMedalCatalog.advent2026VaultId),
        isFalse,
      );
    });
  });
}
