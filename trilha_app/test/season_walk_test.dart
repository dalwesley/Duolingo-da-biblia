import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/data/entry_trails.dart';
import 'package:trilha_app/data/season_walk_catalog.dart';
import 'package:trilha_app/data/trail_repository.dart';
import 'package:trilha_app/l10n/app_language.dart';
import 'package:trilha_app/models/season_walk.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/utils/liturgical_calendar.dart';
import 'package:trilha_app/utils/season_walk_debug.dart';
import 'package:trilha_app/widgets/mission_listen_button.dart';
import 'package:trilha_app/widgets/season_walk_together.dart';

void main() {
  group('SeasonWalkCatalog', () {
    test('advent 2026 has 26 shared days', () {
      final start = LiturgicalCalendar.adventStart(2026);
      final c = SeasonWalkCatalog.advent(start);
      expect(c.days, hasLength(26));
      expect(c.kind, SeasonWalkKind.advent);
      expect(c.dayIndexOn(start), 1);
      expect(c.contains(start.subtract(const Duration(days: 1))), isFalse);
    });

    test('next year gets its own advent id', () {
      final c = SeasonWalkCatalog.current(DateTime(2027, 12, 5));
      expect(c.id, 'advento-2027');
      expect(c.start, LiturgicalCalendar.adventStart(2027));
      expect(
        SeasonWalkCatalog.current(DateTime(2026, 12, 5)).id,
        'advento-2026',
      );
    });

    test('with Plus, every day up to today is open', () {
      final start = LiturgicalCalendar.adventStart(2026);
      final c = SeasonWalkCatalog.advent(start);
      final today = start.add(const Duration(days: 9));
      for (var i = 1; i <= 10; i++) {
        final access = SeasonWalkCatalog.access(
          campaign: c,
          index: i,
          today: today,
          plusOpen: true,
        );
        expect(access.playable, isTrue, reason: 'day $i');
        expect(access.needsPlus, isFalse, reason: 'day $i');
      }
    });

    test('without Plus, days 1–3 stay open and day 4 asks for it', () {
      final start = LiturgicalCalendar.adventStart(2026);
      final c = SeasonWalkCatalog.advent(start);
      final today = start.add(const Duration(days: 9));
      for (var i = 1; i <= 3; i++) {
        final access = SeasonWalkCatalog.access(
          campaign: c,
          index: i,
          today: today,
          plusOpen: false,
        );
        expect(access.playable, isTrue, reason: 'day $i');
      }
      for (var i = 4; i <= 10; i++) {
        final access = SeasonWalkCatalog.access(
          campaign: c,
          index: i,
          today: today,
          plusOpen: false,
        );
        expect(access.playable, isFalse, reason: 'day $i');
        expect(access.needsPlus, isTrue, reason: 'day $i');
        expect(access.future, isFalse, reason: 'day $i');
      }
    });

    test('cannot skip into the future', () {
      final start = LiturgicalCalendar.adventStart(2026);
      final c = SeasonWalkCatalog.advent(start);
      final access = SeasonWalkCatalog.access(
        campaign: c,
        index: 10,
        today: start,
        plusOpen: true,
      );
      expect(access.future, isTrue);
      expect(access.playable, isFalse);
      expect(access.needsPlus, isFalse);
    });

    test('locked days tease the trail without spoiling the scene title', () {
      expect(SeasonWalkCatalog.trailTeaser('evangelhos'), 'Os Quatro Evangelhos');
      expect(SeasonWalkCatalog.trailTeaser('genesis-1-11'), 'Gênesis 1–11');
      final start = LiturgicalCalendar.adventStart(2026);
      final c = SeasonWalkCatalog.advent(start);
      final day = c.dayAt(2)!;
      expect(day.trailSlug, 'genesis-1-11');
      expect(day.title, isNot(contains('Gênesis')));
    });

    test('lab clock shows the home card before Advent starts', () {
      final start = LiturgicalCalendar.adventStart(2026);
      final cardDay = start.subtract(const Duration(days: 7));
      SeasonWalkDebug.bind(cardDay);
      addTearDown(() => SeasonWalkDebug.bind(null));
      final c = SeasonWalkCatalog.current();
      expect(SeasonWalkTogetherCard.visibleOn(c, SeasonWalkDebug.today()), isTrue);
      expect(c.dayIndexOn(SeasonWalkDebug.today()), isNull);
      expect(c.start, start);
    });

    test('in September the 40-day walk is gone; Advent is next', () {
      final c = SeasonWalkCatalog.current(DateTime(2026, 9, 16));
      expect(c.kind, SeasonWalkKind.advent);
      expect(c.contains(DateTime(2026, 9, 16)), isFalse);
    });
  });

  group('Entry trails and seals', () {
    test('entry overlays keep continuesTo and their own banks', () {
      final bySlug = {for (final t in EntryTrails.overlay) t.slug: t};
      expect(bySlug.keys.toSet(), EntryTrails.slugs);
      expect(bySlug['ansiedade']!.missionSlugs, hasLength(5));
      expect(bySlug['conhecer-a-deus']!.missionSlugs, hasLength(5));
      expect(bySlug['entender-a-biblia']!.missionSlugs, hasLength(7));
      for (final t in EntryTrails.overlay) {
        expect(EntryTrails.continuesTo[t.missionSlugs.last], isNotNull);
      }
      // Motivos: banco próprio (section = slug da cena).
      for (final slug in ['ansiedade', 'conhecer-a-deus', 'entender-a-biblia']) {
        for (final m in bySlug[slug]!.modules.expand((mod) => mod.missions)) {
          expect(m.bankSection, isNull);
          expect(m.bankTrailSlug, isNull);
          expect(m.resolvedBankSection, m.slug);
        }
      }
      // Recomeço saiu: as cenas de Gênesis e do Sermão ficam nas trilhas delas.
      expect(bySlug.containsKey('recomeco'), isFalse);
    });

    test('no entry scene shares completion with canon banks', () {
      expect(EntryTrails.linkedScenes('dor-ansia-01'), isEmpty);
      expect(EntryTrails.linkedScenes('entrada-deus-01'), isEmpty);
      expect(EntryTrails.linkedScenes('entrada-biblia-01'), isEmpty);
      expect(EntryTrails.linkedScenes('gen-06-queda'), isEmpty);
      expect(EntryTrails.linkedScenes('sm-03-os-que-choram'), isEmpty);
      expect(EntryTrails.linkedScenes('gen-02-dias'), isEmpty);
    });

    test('entry overlay wins over empty remote stub', () {
      final stub = Trail(
        slug: 'ansiedade',
        title: 'Ansiedade (remoto vazio)',
        description: '',
        icon: '',
        order: 99,
        comingSoon: true,
        color: '#000000',
        modules: const [],
      );
      final merged = TrailRepository.mergeEntry([stub]);
      final hit = merged.firstWhere((t) => t.slug == 'ansiedade');
      expect(hit.comingSoon, isFalse);
      expect(hit.missionSlugs, hasLength(5));
      expect(merged.where((t) => t.slug == 'ansiedade'), hasLength(1));
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
    });

    test('anxiety contentment scene keeps its own section, not Filipenses bank', () {
      final m = EntryTrails.overlay
          .firstWhere((t) => t.slug == 'ansiedade')
          .modules
          .first
          .missions
          .firstWhere((x) => x.slug == 'dor-ansia-02');
      expect(m.hookRef, 'Filipenses 4:12–13');
      expect(m.bankSection, isNull);
      expect(m.resolvedBankSection, 'dor-ansia-02');
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
      final l10n = lookupAppLocalizations(const Locale('pt'));
      final text = MissionListenButton.script(
        verse: 'No princípio criou Deus os céus e a terra.',
        insight: 'Deus é o centro, não eu',
        l10n: l10n,
      );
      expect(text, contains('princípio'));
      expect(text, contains('Hoje: Deus é o centro, não eu'));
    });
  });
}
