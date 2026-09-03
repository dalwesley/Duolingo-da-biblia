import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/caravan_pilgrim_profile.dart';
import 'package:trilha_app/models/pilgrim_medal_catalog.dart';
import 'package:trilha_app/models/pilgrim_medals.dart';

void main() {
  group('PilgrimMedals engagement v3', () {
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

    test('expandCelebratedIds maps v2 medal to v3 levels', () {
      final expanded = PilgrimMedalCatalog.expandCelebratedIds([
        'journey:word:chapters_25',
      ]);
      expect(expanded, contains('track:word:0'));
      expect(expanded, contains('track:word:1'));
      expect(expanded, isNot(contains('track:word:2')));
    });
  });
}
