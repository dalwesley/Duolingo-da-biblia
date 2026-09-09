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
  int myWeekly = 0,
  int theirWeekly = 0,
}) {
  return WalkCompanion(
    code: 'ABCD',
    displayName: 'Lídia',
    sharedDays: 1,
    iWalkedToday: iWalked,
    theyWalkedToday: theyWalked,
    awaitingPartner: false,
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

    test('insightLine shows absence and step lead', () {
      final c = _base(
        theyLastWalk: _daysAgo(4),
        myWeekly: 120,
        theirWeekly: 40,
      );
      expect(c.insightLine, contains('poeira'));
      expect(c.insightLine, contains('Você 80 passos à frente'));
    });

    test('insightLine when partner ahead', () {
      final c = _base(
        iWalked: false,
        theyWalked: true,
        theyLastWalk: _daysAgo(0),
        myWeekly: 10,
        theirWeekly: 55,
      );
      expect(c.insightLine, contains('Lídia 45 passos à frente'));
    });

    test('delay tiers 1-3 / 4-6 / 7+', () {
      final fresh = _base(theyLastWalk: _daysAgo(2));
      expect(fresh.delayCopy?.tier, CompanionDelayTier.fresh);
      expect(fresh.nudgeShareText(), contains('ficando pra trás'));
      expect(
        fresh.nudgeShareText(),
        contains('trilha-biblia.web.app/abrir/juntos'),
      );
      expect(fresh.nudgeShareText(), isNot(contains('stway://juntos')));

      final dusty = _base(theyLastWalk: _daysAgo(5));
      expect(dusty.delayCopy?.tier, CompanionDelayTier.dusty);
      expect(dusty.nudgeShareText(), contains('poeira'));
      expect(dusty.statusLine, contains('sente falta'));

      final lost = _base(theyLastWalk: _daysAgo(9));
      expect(lost.delayCopy?.tier, CompanionDelayTier.lost);
      expect(lost.nudgeShareText(), contains('Te perdi na multidão'));
      expect(lost.nudgeShareText(), contains('retomar nossa caminhada'));
      expect(lost.delayCopy?.headline, 'Te perdi na multidão');
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
        contains('poeira'),
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
}
