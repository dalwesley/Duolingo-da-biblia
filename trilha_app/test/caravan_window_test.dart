import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/league_service.dart';

LeagueEntry _p(String name, int steps) =>
    LeagueEntry(uid: name, name: name, steps: steps);

const _me = 'me';

LeagueEntry _meAt(int steps) =>
    LeagueEntry(uid: _me, name: _me, steps: steps, isUser: true);

List<String> _names(List<({LeagueEntry? entry, int rank})> rows) => [
  for (final r in rows) r.entry == null ? '···' : '${r.rank}:${r.entry!.name}',
];

void main() {
  group('caravanWindow', () {
    test('small caravan shows everyone in order', () {
      final rows = LeagueService.caravanWindow(
        me: _meAt(300),
        top: [_p('a', 900), _p('b', 500), _p('c', 100)],
        above: const [],
        below: const [],
        ahead: 2,
        total: 4,
        reach: 180,
      );
      expect(_names(rows), ['1:a', '2:b', '3:me', '4:c']);
    });

    test('near the top: one list, no gap, one below me', () {
      final top = [for (var i = 0; i < 8; i++) _p('p$i', 1000 - i * 100)];
      final rows = LeagueService.caravanWindow(
        me: _meAt(650),
        top: top,
        above: const [],
        below: const [],
        ahead: 4,
        total: 500,
        reach: 180,
      );
      expect(_names(rows), ['1:p0', '2:p1', '3:p2', '4:p3', '5:me', '6:p4']);
    });

    test('far down: podium, gap, reachable neighbours, me, one below', () {
      final rows = LeagueService.caravanWindow(
        me: _meAt(300),
        top: [_p('a', 5000), _p('b', 4000), _p('c', 3000), _p('d', 2900)],
        above: [_p('n1', 320), _p('n2', 420), _p('n3', 900)],
        below: [_p('s1', 290), _p('s2', 10)],
        ahead: 47,
        total: 1000,
        reach: 180,
      );
      expect(_names(rows), [
        '1:a',
        '2:b',
        '3:c',
        '···',
        '46:n2',
        '47:n1',
        '48:me',
        '49:s1',
      ]);
    });

    test('nobody within reach still shows the nearest above', () {
      final rows = LeagueService.caravanWindow(
        me: _meAt(100),
        top: [_p('a', 5000), _p('b', 4000), _p('c', 3000)],
        above: [_p('n1', 900), _p('n2', 1200)],
        below: const [],
        ahead: 20,
        total: 21,
        reach: 180,
      );
      expect(_names(rows), ['1:a', '2:b', '3:c', '···', '20:n1', '21:me']);
    });
  });

  test('nextToPass needs one step more than the gap', () {
    final rows = LeagueService.caravanWindow(
      me: _meAt(300),
      top: [_p('a', 323)],
      above: const [],
      below: const [],
      ahead: 1,
      total: 2,
      reach: 180,
    );
    final next = LeagueService.nextToPass(rows)!;
    expect(next.who.name, 'a');
    expect(next.steps, 24);
    expect(
      LeagueService.nextToPass([(entry: _meAt(9), rank: 1)]),
      isNull,
    );
  });

  test('reachSteps uses own average, clamped', () {
    expect(LeagueService.reachSteps(monthSteps: 600, monthScenes: 10), 180);
    expect(LeagueService.reachSteps(monthSteps: 0, monthScenes: 0), 180);
    expect(LeagueService.reachSteps(monthSteps: 5000, monthScenes: 2), 600);
  });

  test('goal scales with last month and reveals by milestones', () {
    expect(LeagueService.monthSceneGoal(0), 60);
    expect(LeagueService.monthSceneGoal(23), 280);
    expect(LeagueService.goalReveal(scenes: 10, goal: 100), 0);
    expect(LeagueService.goalReveal(scenes: 30, goal: 100), 0.25);
    expect(LeagueService.goalReveal(scenes: 60, goal: 100), 0.5);
    expect(LeagueService.goalReveal(scenes: 120, goal: 100), 1);
  });

  test('previousMonthKey crosses the year', () {
    expect(LeagueService.previousMonthKey('2026-12'), '2026-11');
    expect(LeagueService.previousMonthKey('2027-01'), '2026-12');
  });

  group('goalPace', () {
    test('first two days are just the start', () {
      final p = LeagueService.goalPace(
        done: 5,
        goal: 300,
        now: DateTime(2026, 11, 2, 10),
      );
      expect(p.pace, GoalPace.starting);
    });

    test('on track projects the arrival day', () {
      // 160 em 15 dias ≈ 10,7/dia; faltam 140 → ~13 dias → dia 29.
      final p = LeagueService.goalPace(
        done: 160,
        goal: 300,
        now: DateTime(2026, 11, 16),
      );
      expect(p.pace, GoalPace.onTrack);
      expect(p.arrivalDay, 29);
    });

    test('behind asks scenes per day until the end', () {
      final p = LeagueService.goalPace(
        done: 60,
        goal: 300,
        now: DateTime(2026, 11, 21),
      );
      expect(p.pace, GoalPace.behind);
      expect(p.left, 240);
      expect(p.perDay, 24);
    });

    test('reached', () {
      final p = LeagueService.goalPace(done: 300, goal: 300);
      expect(p.pace, GoalPace.reached);
    });
  });

  test('goalStop follows the milestones', () {
    expect(LeagueService.goalStop(scenes: 10, goal: 100), -1);
    expect(LeagueService.goalStop(scenes: 25, goal: 100), 0);
    expect(LeagueService.goalStop(scenes: 70, goal: 100), 1);
    expect(LeagueService.goalStop(scenes: 100, goal: 100), 2);
  });

  group('goalMood', () {
    test('start of the month', () {
      final m = LeagueService.goalMood(
        done: 3,
        goal: 80,
        daysSinceAdvance: 0,
        now: DateTime(2026, 11, 2),
      );
      expect(m.mood, GoalMood.starting);
    });

    test('final stretch beats stalled', () {
      final m = LeagueService.goalMood(
        done: 62,
        goal: 80,
        daysSinceAdvance: 4,
        now: DateTime(2026, 11, 28, 12),
      );
      expect(m.mood, GoalMood.finalStretch);
      expect(m.days, 3);
      expect(m.left, 18);
    });

    test('stalled after two quiet days', () {
      final m = LeagueService.goalMood(
        done: 30,
        goal: 80,
        daysSinceAdvance: 3,
        now: DateTime(2026, 11, 15),
      );
      expect(m.mood, GoalMood.stalled);
      expect(m.days, 3);
    });

    test('fast when arriving 5+ days early', () {
      // 62 em 18 dias ≈ 3,4/dia; faltam 18 → ~5 dias → dia 24.
      final m = LeagueService.goalMood(
        done: 62,
        goal: 80,
        daysSinceAdvance: 0,
        now: DateTime(2026, 11, 19),
      );
      expect(m.mood, GoalMood.fast);
      expect(m.arrivalDay, 24);
    });

    test('steady otherwise', () {
      final m = LeagueService.goalMood(
        done: 40,
        goal: 80,
        daysSinceAdvance: 0,
        now: DateTime(2026, 11, 15),
      );
      expect(m.mood, GoalMood.steady);
    });
  });
}
