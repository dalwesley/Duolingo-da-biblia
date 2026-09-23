import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/data/entry_trails.dart';
import 'package:trilha_app/data/season_walk_catalog.dart';
import 'package:trilha_app/data/trail_repository.dart';
import 'package:trilha_app/models/season_walk.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/utils/liturgical_calendar.dart';
import 'package:trilha_app/widgets/mission_listen_button.dart';

void main() {
  group('SeasonWalkCatalog', () {
    test('advent 2026 has 26 shared days', () {
      final start = LiturgicalCalendar.adventStart(2026);
      final c = SeasonWalkCatalog.advent2026(start);
      expect(c.days, hasLength(26));
      expect(c.kind, SeasonWalkKind.advent);
      expect(c.dayIndexOn(start), 1);
      expect(c.contains(start.subtract(const Duration(days: 1))), isFalse);
    });

    test('days 1–3 stay free even without Pro', () {
      final start = LiturgicalCalendar.adventStart(2026);
      final c = SeasonWalkCatalog.advent2026(start);
      final today = start.add(const Duration(days: 3));
      final d1 = SeasonWalkCatalog.access(
        campaign: c,
        index: 1,
        today: today,
        proConfigured: true,
        isPro: false,
      );
      final d4 = SeasonWalkCatalog.access(
        campaign: c,
        index: 4,
        today: today,
        proConfigured: true,
        isPro: false,
      );
      expect(d1.playable, isTrue);
      expect(d4.needsPro, isTrue);
      expect(d4.playable, isFalse);
    });

    test('without IAP configured, day 4 stays open', () {
      final start = LiturgicalCalendar.adventStart(2026);
      final c = SeasonWalkCatalog.advent2026(start);
      final access = SeasonWalkCatalog.access(
        campaign: c,
        index: 4,
        today: start.add(const Duration(days: 4)),
        proConfigured: false,
        isPro: false,
      );
      expect(access.playable, isTrue);
    });

    test('cannot skip into the future', () {
      final start = LiturgicalCalendar.adventStart(2026);
      final c = SeasonWalkCatalog.advent2026(start);
      final access = SeasonWalkCatalog.access(
        campaign: c,
        index: 10,
        today: start,
        proConfigured: false,
        isPro: false,
      );
      expect(access.future, isTrue);
      expect(access.playable, isFalse);
    });

    test('in September the 40-day walk is gone; Advent is next', () {
      final c = SeasonWalkCatalog.current(DateTime(2026, 9, 16));
      expect(c.kind, SeasonWalkKind.advent);
      expect(c.contains(DateTime(2026, 9, 16)), isFalse);
    });
  });

  group('Entry trails and seals', () {
    test('anxiety and restart overlay have 5 missions each', () {
      expect(EntryTrails.overlay, hasLength(2));
      for (final t in EntryTrails.overlay) {
        expect(t.missionSlugs, hasLength(5));
        for (final m in t.modules.expand((mod) => mod.missions)) {
          expect(m.bankSection, isNotEmpty);
          expect(m.bankTrailSlug, isNotEmpty);
        }
      }
    });

    test('entry overlay wins over empty remote stub', () {
      final stub = Trail(
        slug: 'recomeco',
        title: 'Recomeço (remoto vazio)',
        description: '',
        icon: '',
        order: 99,
        comingSoon: true,
        color: '#000000',
        modules: const [],
      );
      final merged = TrailRepository.mergeEntry([stub]);
      final hit = merged.firstWhere((t) => t.slug == 'recomeco');
      expect(hit.comingSoon, isFalse);
      expect(hit.missionSlugs, hasLength(5));
      expect(hit.title, 'Recomeço');
      expect(merged.where((t) => t.slug == 'recomeco'), hasLength(1));
    });

    test('seals unlock only after the anchor mission', () {
      expect(CharacterSeals.unlocked(const []), isEmpty);
      final one = CharacterSeals.unlocked(['gen-03-imagem']);
      expect(one, hasLength(1));
      expect(one.single.name, 'Imagem');
    });

    test('first encounter is the unlock, replay is not', () {
      expect(CharacterSeals.unlocksOn('gen-03-imagem', const []), isTrue);
      expect(
        CharacterSeals.unlocksOn('gen-03-imagem', ['gen-03-imagem']),
        isFalse,
      );
      expect(CharacterSeals.unlocksOn('gen-01-criador', const []), isFalse);
    });

    test('last pain-trail missions continue into the canon', () {
      expect(EntryTrails.continuesTo['dor-ansia-05'], 'sermao-do-monte');
      expect(EntryTrails.continuesTo['dor-recome-05'], 'genesis-1-11');
    });

    test('anxiety contentment hook matches the borrowed bank', () {
      final m = EntryTrails.overlay
          .firstWhere((t) => t.slug == 'ansiedade')
          .modules
          .first
          .missions
          .firstWhere((x) => x.slug == 'dor-ansia-02');
      expect(m.hookRef, 'Filipenses 4:12–13');
      expect(m.bankSection, 'fp-03-contentamento');
    });
  });

  group('Walk review picker', () {
    test('prefers a mistake over the first pool item', () {
      final id = SeasonWalkAccess.pickReviewActId(
        poolIds: const ['a', 'b', 'c'],
        mistakeIds: const ['c'],
        usedIds: const ['a'],
      );
      expect(id, 'c');
    });

    test('skips already used when no mistakes', () {
      final id = SeasonWalkAccess.pickReviewActId(
        poolIds: const ['a', 'b', 'c'],
        mistakeIds: const [],
        usedIds: const ['a'],
      );
      expect(id, 'b');
    });
  });

  group('Mission audio script', () {
    test('joins clipped verse and insight', () {
      final text = MissionListenButton.script(
        verse: 'No princípio criou Deus os céus e a terra.',
        insight: 'Deus é o centro, não eu',
      );
      expect(text, contains('princípio'));
      expect(text, contains('Hoje: Deus é o centro, não eu'));
    });
  });
}
