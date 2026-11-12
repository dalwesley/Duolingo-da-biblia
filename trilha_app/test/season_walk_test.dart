import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/data/entry_trails.dart';
import 'package:trilha_app/data/season_walk_catalog.dart';
import 'package:trilha_app/l10n/app_language.dart';
import 'package:trilha_app/models/season_walk.dart';
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

    test('Advent 2026 is a launch gift: every past day opens without Plus', () {
      final start = LiturgicalCalendar.adventStart(2026);
      final c = SeasonWalkCatalog.advent(start);
      expect(c.isGift, isTrue);
      final today = start.add(const Duration(days: 9));
      for (var i = 1; i <= 10; i++) {
        final access = SeasonWalkCatalog.access(
          campaign: c,
          index: i,
          today: today,
          plusOpen: false,
        );
        expect(access.playable, isTrue, reason: 'day $i');
        expect(access.needsPlus, isFalse, reason: 'day $i');
      }
    });

    test('without Plus, day 1 stays open and day 2 asks for it', () {
      // Campanha que não é presente (o Advento seguinte).
      final start = LiturgicalCalendar.adventStart(2027);
      final c = SeasonWalkCatalog.advent(start);
      final today = start.add(const Duration(days: 9));
      for (var i = 1; i <= 1; i++) {
        final access = SeasonWalkCatalog.access(
          campaign: c,
          index: i,
          today: today,
          plusOpen: false,
        );
        expect(access.playable, isTrue, reason: 'day $i');
      }
      for (var i = 2; i <= 10; i++) {
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
      expect(
        SeasonWalkCatalog.trailTeaser('evangelhos'),
        'Os Quatro Evangelhos',
      );
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
      expect(
        SeasonWalkTogetherCard.visibleOn(c, SeasonWalkDebug.today()),
        isTrue,
      );
      expect(c.dayIndexOn(SeasonWalkDebug.today()), isNull);
      expect(c.start, start);
    });

    test('after Christmas the Home counts down to next Advent', () {
      final c = SeasonWalkCatalog.current(DateTime(2026, 12, 26));
      expect(c.start, LiturgicalCalendar.adventStart(2027));
      expect(c.id, 'advento-2027');
    });

    test('the Advent that just ended still credits for a week', () {
      final ended = SeasonWalkCatalog.justEnded(DateTime(2026, 12, 26));
      expect(ended?.id, 'advento-2026');
      expect(
        SeasonWalkCatalog.justEnded(DateTime(2026, 12, 31))?.id,
        'advento-2026',
      );
      expect(SeasonWalkCatalog.justEnded(DateTime(2027, 1, 1)), isNull);
      expect(SeasonWalkCatalog.justEnded(DateTime(2026, 12, 24)), isNull);
    });

    test('grace of a December Advent crosses New Year', () {
      // 2028 começa em 3/12; 26 dias vão até 28/12, graça até 4/1.
      final ended = SeasonWalkCatalog.justEnded(DateTime(2029, 1, 2));
      expect(ended?.id, 'advento-2028');
    });

    test('in September the 40-day walk is gone; Advent is next', () {
      final c = SeasonWalkCatalog.current(DateTime(2026, 9, 16));
      expect(c.kind, SeasonWalkKind.advent);
      expect(c.contains(DateTime(2026, 9, 16)), isFalse);
    });
  });

  group('Entry trails and seals', () {
    test('entry trail rules keep continuesTo; content comes from Firestore', () {
      expect(EntryTrails.slugs, {
        'ansiedade',
        'conhecer-a-deus',
        'entender-a-biblia',
      });
      expect(EntryTrails.continuesTo.keys, {
        'dor-ansia-05',
        'entrada-deus-05',
        'entrada-biblia-07',
      });
      // Recomeço saiu: as cenas de Gênesis e do Sermão ficam nas trilhas delas.
      expect(EntryTrails.slugs.contains('recomeco'), isFalse);
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
