import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/walk_companion.dart';

String _daysAgo(int days) {
  final d = DateTime.now().subtract(Duration(days: days));
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

WalkCompanion _base({
  bool iWalked = true,
  bool theyWalked = false,
  String? theyLastWalk,
  String? theyLastSeen,
  String? lastShared,
  int sharedDays = 1,
  int myWeekly = 0,
  int theirWeekly = 0,
  bool awaiting = false,
}) {
  return WalkCompanion(
    code: 'ABCD',
    displayName: 'Lídia',
    sharedDays: sharedDays,
    lastSharedDate: lastShared,
    iWalkedToday: iWalked,
    theyWalkedToday: theyWalked,
    awaitingPartner: awaiting,
    isHost: true,
    theyLastWalkDate: theyLastWalk,
    theyLastSeenDate: theyLastSeen,
    myWeeklySteps: myWeekly,
    theirWeeklySteps: theirWeekly,
  );
}

void main() {
  group('WalkCompanion idle / steps', () {
    test('theyDaysAway uses lastSeen when fresher than walk', () {
      final c = _base(theyLastWalk: _daysAgo(10), theyLastSeen: _daysAgo(3));
      expect(c.theyDaysAway, 3);
      expect(c.theyDaysSinceWalk, 10);
      expect(c.theyDaysSinceSeen, 3);
    });

    test('theyDaysAway falls back to lastWalk', () {
      final c = _base(theyLastWalk: _daysAgo(5));
      expect(c.theyDaysAway, 5);
    });

    test('insightLine shows absence without step ranking', () {
      final c = _base(
        theyLastWalk: _daysAgo(4),
        myWeekly: 120,
        theirWeekly: 40,
      );
      expect(c.insightLine, contains('caminho'));
      expect(c.insightLine, isNot(contains('passos')));
    });

    test('insightLine when partner walked is quiet', () {
      final c = _base(
        iWalked: false,
        theyWalked: true,
        theyLastWalk: _daysAgo(0),
        myWeekly: 10,
        theirWeekly: 55,
      );
      expect(c.insightLine, isNull);
      expect(c.statusLine, contains('sua vez'));
    });

    test('delay tiers 1-3 / 4-6 / 7+', () {
      final fresh = _base(theyLastWalk: _daysAgo(2));
      expect(fresh.delayCopy?.tier, CompanionDelayTier.fresh);
      expect(fresh.nudgeShareText(), contains('sua falta'));
      expect(
        fresh.nudgeShareText(),
        contains('trilha-biblia.web.app/abrir/juntos'),
      );
      expect(fresh.nudgeShareText(), isNot(contains('stway://juntos')));

      final dusty = _base(theyLastWalk: _daysAgo(5));
      expect(dusty.delayCopy?.tier, CompanionDelayTier.dusty);
      expect(dusty.nudgeShareText(), contains('caminho continua aberto'));
      expect(dusty.statusLine, contains('dias sem estudar'));

      final lost = _base(theyLastWalk: _daysAgo(9));
      expect(lost.delayCopy?.tier, CompanionDelayTier.lost);
      expect(lost.nudgeShareText(), contains('lugar ao meu lado'));
      expect(lost.nudgeShareText(), contains('já dei meus passos'));
      expect(lost.delayCopy?.headline, 'Ainda tem lugar ao meu lado');
    });

    test('theyAreDusty when away without walking today', () {
      expect(_base(theyLastWalk: _daysAgo(3)).theyAreDusty, isTrue);
      expect(
        _base(theyWalked: true, theyLastWalk: _daysAgo(0)).theyAreDusty,
        isFalse,
      );
    });

    test('nudge presets follow delay and incoming banner', () {
      expect(
        _base(theyLastWalk: _daysAgo(2)).nudgePresets.first,
        contains('esperando'),
      );
      expect(
        _base(theyLastWalk: _daysAgo(5)).nudgePresets.first,
        contains('falta'),
      );
      expect(
        _base(theyLastWalk: _daysAgo(9)).nudgePresets.first,
        contains('lugar'),
      );

      final incoming = WalkCompanion(
        code: 'ABCD',
        displayName: 'Lídia',
        sharedDays: 1,
        iWalkedToday: false,
        theyWalkedToday: true,
        awaitingPartner: false,
        isHost: true,
        incomingNudgeFromName: 'Dalwesley',
        incomingNudgeMessage: 'Tô te esperando na trilha',
        incomingNudgeDay: '2026-09-08',
      );
      expect(incoming.hasIncomingNudge, isTrue);
      expect(incoming.incomingNudgeDay, '2026-09-08');

      final walked = WalkCompanion(
        code: 'ABCD',
        displayName: 'Lídia',
        sharedDays: 1,
        iWalkedToday: true,
        theyWalkedToday: false,
        awaitingPartner: false,
        isHost: true,
        incomingNudgeFromName: 'Dalwesley',
        incomingNudgeMessage: 'Vem',
      );
      expect(walked.hasIncomingNudge, isFalse);
    });
  });

  group('WalkCompanion week together', () {
    // Semana da caravana: seg 14/09/2026 → dom 20/09/2026.
    final sunday = DateTime(2026, 9, 20);
    final saturday = DateTime(2026, 9, 19);
    final wednesday = DateTime(2026, 9, 16);

    test('counts together days inside the league week', () {
      final c = _base(
        theyWalked: true,
        lastShared: '2026-09-16',
        sharedDays: 3,
      );
      expect(c.togetherDaysThisWeek(wednesday), 3);
      expect(c.coveredLeagueWeekTogether(wednesday), isFalse);
    });

    test('caps at 7 and ignores streak from the previous week', () {
      final long = _base(
        theyWalked: true,
        lastShared: '2026-09-20',
        sharedDays: 40,
      );
      expect(long.togetherDaysThisWeek(sunday), 7);
      expect(long.coveredLeagueWeekTogether(sunday), isTrue);
    });

    test('full week only on Sunday with both walking', () {
      final sat = _base(
        theyWalked: true,
        lastShared: '2026-09-19',
        sharedDays: 6,
      );
      expect(sat.coveredLeagueWeekTogether(saturday), isFalse);

      final missed = _base(
        theyWalked: true,
        lastShared: '2026-09-20',
        sharedDays: 6,
      );
      expect(missed.coveredLeagueWeekTogether(sunday), isFalse);

      final solo = _base(
        theyWalked: false,
        lastShared: '2026-09-19',
        sharedDays: 7,
      );
      expect(solo.coveredLeagueWeekTogether(sunday), isFalse);

      final done = _base(
        theyWalked: true,
        lastShared: '2026-09-20',
        sharedDays: 7,
      );
      expect(done.coveredLeagueWeekTogether(sunday), isTrue);
      expect(WalkCompanion.weekTogetherBonusSteps, 50);
    });

    test('paints half when one walks and full when both do', () {
      final wednesday = DateTime(2026, 9, 16);
      final c = WalkCompanion(
        code: 'ABCD',
        displayName: 'Regina',
        sharedDays: 1,
        lastSharedDate: '2026-09-15',
        iWalkedToday: true,
        theyWalkedToday: false,
        awaitingPartner: false,
        isHost: true,
        theyLastWalkDate: '2026-09-14',
        myWalkDates: const ['2026-09-16'],
        theirWalkDates: const ['2026-09-14'],
      );

      final monday = c.presenceOn(DateTime(2026, 9, 14), now: wednesday);
      expect(monday.me, isFalse);
      expect(monday.them, isTrue);
      expect(monday.walkers, 1);

      final tuesday = c.presenceOn(DateTime(2026, 9, 15), now: wednesday);
      expect(tuesday.both, isTrue);

      final today = c.presenceOn(wednesday, now: wednesday);
      expect(today.me, isTrue);
      expect(today.them, isFalse);

      final thursday = c.presenceOn(DateTime(2026, 9, 17), now: wednesday);
      expect(thursday.walkers, 0);

      expect(c.bothWalkedThisWeek(now: wednesday), 1);
    });

    test('local play dates fill my half before the cloud list arrives', () {
      final thursday = DateTime(2026, 9, 24);
      final c = _base(
        iWalked: false,
        theyWalked: false,
        theyLastWalk: '2026-09-22',
        sharedDays: 0,
        lastShared: null,
      );
      final mine = c.presenceOn(
        DateTime(2026, 9, 22),
        now: thursday,
        alsoMine: const ['2026-09-22'],
      );
      expect(mine.both, isTrue);
      final today = c.presenceOn(thursday, now: thursday);
      expect(today.walkers, 0);
    });

    test('awaiting partner never covers the week', () {
      final c = _base(
        theyWalked: true,
        lastShared: '2026-09-20',
        sharedDays: 7,
        awaiting: true,
      );
      expect(c.togetherDaysThisWeek(sunday), 0);
      expect(c.coveredLeagueWeekTogether(sunday), isFalse);
    });
  });
}
