import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/corner_challenge.dart';
import 'package:trilha_app/models/trail.dart';

void main() {
  final catalog = [_trail()];

  group('CornerMatch.propose', () {
    test('same trail and same next scene', () {
      final hit = CornerMatch.propose(
        catalog: catalog,
        myCompleted: const ['gen-01'],
        myClearedModes: const {},
        theirCompleted: const ['gen-01'],
        theirClearedModes: const {},
      );
      expect(hit, isNotNull);
      expect(hit!.trailSlug, 'genesis-1-11');
      expect(hit.missionSlug, 'gen-02');
      expect(hit.missionTitle, 'A queda');
      expect(hit.moduleTitle, 'O Jardim');
    });

    test('different trail returns null', () {
      final two = [_trail(), _trail(slug: 'exodo', title: 'Êxodo')];
      final hit = CornerMatch.propose(
        catalog: two,
        myCompleted: const ['gen-01'],
        myClearedModes: const {},
        theirCompleted: const ['gen-01', 'gen-02', 'gen-03'],
        theirClearedModes: const {},
      );
      expect(hit, isNull);
    });

    test('same trail but different next scene returns null', () {
      final hit = CornerMatch.propose(
        catalog: catalog,
        myCompleted: const ['gen-01'],
        myClearedModes: const {},
        theirCompleted: const ['gen-01', 'gen-02'],
        theirClearedModes: const {},
      );
      expect(hit, isNull);
    });

    test('finished trail cannot be challenged', () {
      final hit = CornerMatch.propose(
        catalog: catalog,
        myCompleted: const ['gen-01', 'gen-02', 'gen-03'],
        myClearedModes: const {},
        theirCompleted: const ['gen-01', 'gen-02', 'gen-03'],
        theirClearedModes: const {},
      );
      expect(hit, isNull);
    });

    test('cleared mode counts as trail done', () {
      final hit = CornerMatch.propose(
        catalog: catalog,
        myCompleted: const ['gen-01'],
        myClearedModes: const {},
        theirCompleted: const ['gen-01'],
        theirClearedModes: const {
          'genesis-1-11': ['semente'],
        },
      );
      expect(hit, isNull);
    });

    test('both at the first scene', () {
      final hit = CornerMatch.propose(
        catalog: catalog,
        myCompleted: const [],
        myClearedModes: const {},
        theirCompleted: const [],
        theirClearedModes: const {},
      );
      expect(hit?.missionSlug, 'gen-01');
      expect(hit?.moduleTitle, 'A Criação');
    });

    test('ignores untouched entry trail in front of the catalog', () {
      final mixed = [
        Trail(
          slug: 'ansiedade',
          title: 'Ansiedade',
          description: '',
          icon: '🌊',
          order: 0,
          comingSoon: false,
          color: '#4C6EF5',
          modules: [
            TrailModule(
              title: 'Lançar',
              icon: '🌊',
              missions: [_mission('dor-01', 'Tesouros')],
            ),
          ],
        ),
        _trail(),
      ];
      final hit = CornerMatch.propose(
        catalog: mixed,
        myCompleted: const ['gen-01'],
        myClearedModes: const {},
        theirCompleted: const ['gen-01'],
        theirClearedModes: const {},
      );
      expect(hit?.trailSlug, 'genesis-1-11');
      expect(hit?.missionSlug, 'gen-02');
    });

    test('blockReason when they finished the trail', () {
      expect(
        CornerMatch.blockReason(
          catalog: catalog,
          myCompleted: const ['gen-01'],
          myClearedModes: const {},
          theirCompleted: const ['gen-01', 'gen-02', 'gen-03'],
          theirClearedModes: const {},
        ),
        CornerCopy.noCorner,
      );
    });

    test('blockReason when next scene differs', () {
      expect(
        CornerMatch.blockReason(
          catalog: catalog,
          myCompleted: const ['gen-01'],
          myClearedModes: const {},
          theirCompleted: const ['gen-01', 'gen-02'],
          theirClearedModes: const {},
        ),
        CornerCopy.differentScene,
      );
    });
  });

  group('CornerChallenge copy', () {
    const me = 'me';
    const them = 'nat';

    test('pending incoming', () {
      final c = _challenge(status: CornerStatus.pending);
      expect(c.headline(me), CornerCopy.incomingTitle);
      expect(c.subline(me), CornerCopy.incomingFrom('Natã'));
    });

    test('you did the scene, they have not', () {
      final fromThem = _challenge(
        status: CornerStatus.active,
        challengerDoneAt: null,
        opponentDoneAt: '2026-09-20T12:00:00',
      );
      expect(fromThem.headline(me), CornerCopy.inviteTitle('A queda'));
      expect(fromThem.subline(me), CornerCopy.waitingArrival('Natã'));
      expect(fromThem.iDone(me), isTrue);
      expect(fromThem.theyDone(me), isFalse);
    });

    test('both done — they arrived together', () {
      final c = _challenge(
        status: CornerStatus.settled,
        challengerDoneAt: 'a',
        opponentDoneAt: 'b',
        opponentCorrect: 6,
        opponentTotal: 6,
        challengerCorrect: 5,
        challengerTotal: 6,
      );
      expect(c.outcome(me), CornerOutcome.together);
      expect(c.headline(me), CornerCopy.togetherHeadline);
      expect(c.subline(me), CornerCopy.togetherLine);
      expect(c.outcome(them), CornerOutcome.together);
    });

    test('week ended and neither arrived', () {
      final c = _challenge(
        status: CornerStatus.settled,
        weekStart: '2000-01-03',
      );
      expect(c.outcome(me), CornerOutcome.none);
      expect(c.headline(me), CornerCopy.noneHeadline);
      expect(c.subline(me), CornerCopy.noneLine);
    });

    test('week ended without them', () {
      final c = _challenge(
        status: CornerStatus.active,
        weekStart: '2000-01-03',
        opponentDoneAt: '2000-01-04',
      );
      expect(c.isThisWeek, isFalse);
      expect(c.outcome(me), CornerOutcome.onlyMe);
      expect(c.headline(me), CornerCopy.youArrivedHeadline);
    });

    test('active corner opens that scene even if the trail is gated', () {
      final c = _challenge(status: CornerStatus.active);
      expect(c.opensFor(me, 'gen-02'), isTrue);
      expect(c.opensFor(me, 'gen-03'), isFalse);
      expect(CornerChallenge.authorizes('gen-02', me, [c]), isTrue);
    });

    test('done or pending corner does not skip the lock', () {
      expect(
        _challenge(
          status: CornerStatus.active,
          opponentDoneAt: 'now',
        ).opensFor(me, 'gen-02'),
        isFalse,
      );
      expect(
        _challenge(status: CornerStatus.pending).opensFor(me, 'gen-02'),
        isFalse,
      );
    });
  });

  group('CornerHomePick', () {
    const me = 'me';

    test('hides a closed challenge', () {
      final settled = _challenge(
        status: CornerStatus.settled,
        challengerDoneAt: 'a',
        opponentDoneAt: 'b',
        opponentCorrect: 5,
        opponentTotal: 6,
        challengerCorrect: 5,
        challengerTotal: 6,
      );
      expect(CornerHomePick.of([settled], me), isNull);
    });

    test('keeps an active challenge', () {
      final active = _challenge(status: CornerStatus.active);
      expect(CornerHomePick.of([active], me)?.id, 'c1');
    });
  });

  group('CornerRecord', () {
    const me = 'me';

    test('one together becomes 1 completa · 1 junto', () {
      final tied = _challenge(
        status: CornerStatus.settled,
        challengerDoneAt: 'a',
        opponentDoneAt: 'b',
        opponentCorrect: 5,
        opponentTotal: 6,
        challengerCorrect: 5,
        challengerTotal: 6,
      );
      final record = CornerRecord.of([tied], me);
      expect(record.arrived, 1);
      expect(record.together, 1);
      expect(record.line, '1 completa · 1 junto');
      expect(record.whisper, 'Cenas feitas lado a lado.');
    });

    test('one arrival alone becomes 1 completa', () {
      final alone = _challenge(
        status: CornerStatus.settled,
        opponentDoneAt: 'b',
      );
      final record = CornerRecord.of([alone], me);
      expect(record.arrived, 1);
      expect(record.together, 0);
      expect(record.line, '1 completa');
      expect(record.whisper, 'Cada cena feita conta.');
    });
  });

  group('CornerScoreboard', () {
    const me = 'me';

    test('open challenge stays off the closed list', () {
      final active = _challenge(status: CornerStatus.active);
      final board = CornerScoreboard.of([active], me);
      expect(board.open.single.id, 'c1');
      expect(board.closed, isEmpty);
    });

    test('together counts as won and juntos', () {
      final tied = _challenge(
        status: CornerStatus.settled,
        weekStart: '2026-09-21',
        challengerDoneAt: 'a',
        opponentDoneAt: 'b',
      );
      final board = CornerScoreboard.of([tied], me);
      expect(board.won, 1);
      expect(board.together, 1);
      expect(board.lost, 0);
      expect(board.closed.single.mark, CornerResultMark.together);
      expect(
        board.closed.single.caption(me),
        '21 set · Com Natã · os dois chegaram',
      );
    });

    test('arriving alone is a win', () {
      final alone = _challenge(
        status: CornerStatus.settled,
        weekStart: '2000-01-03',
        opponentDoneAt: 'b',
      );
      final board = CornerScoreboard.of([alone], me);
      expect(board.won, 1);
      expect(board.closed.single.mark, CornerResultMark.won);
      expect(board.closed.single.caption(me), '3 jan · Com Natã · +10 passos');
    });

    test('the other person arriving is a loss', () {
      final them = _challenge(
        status: CornerStatus.settled,
        weekStart: '2000-01-03',
        challengerDoneAt: 'a',
      );
      final board = CornerScoreboard.of([them], me);
      expect(board.lost, 1);
      expect(board.closed.single.mark, CornerResultMark.lost);
      expect(
        board.closed.single.caption(me),
        '3 jan · Natã chegou · você não chegou',
      );
    });

    test('nobody arriving is a loss', () {
      final none = _challenge(
        status: CornerStatus.settled,
        weekStart: '2000-01-03',
      );
      final board = CornerScoreboard.of([none], me);
      expect(board.lost, 1);
      expect(
        board.closed.single.caption(me),
        '3 jan · Com Natã · ninguém chegou',
      );
    });

    test('leaving shows before Sunday and counts as a loss', () {
      final left = _challenge(status: CornerStatus.active, withdrawnBy: me);
      final board = CornerScoreboard.of([left], me);
      expect(board.open, isEmpty);
      expect(board.lost, 1);
      expect(board.closed.single.mark, CornerResultMark.left);
      expect(board.closed.single.caption(me), contains('Você saiu'));
    });

    test('newer week comes first and declined invites stay out', () {
      final older = _challenge(
        id: 'old',
        status: CornerStatus.settled,
        weekStart: '2026-01-05',
        opponentDoneAt: 'a',
      );
      final newer = _challenge(
        id: 'new',
        status: CornerStatus.settled,
        weekStart: '2026-09-21',
        challengerDoneAt: 'a',
      );
      final declined = _challenge(id: 'no', status: CornerStatus.declined);
      final board = CornerScoreboard.of([older, newer, declined], me);
      expect(board.closed.map((r) => r.challenge.id), ['new', 'old']);
      expect(board.won, 1);
      expect(board.lost, 1);
    });
  });

  group('stripLine', () {
    const me = 'me';

    test('live invite wins over the tally', () {
      final invite = _challenge(status: CornerStatus.pending);
      expect(
        CornerCopy.stripLine(live: invite, uid: me, days: 3, won: 2, lost: 1),
        'Natã te chamou',
      );
    });

    test('tally when nothing is open', () {
      expect(
        CornerCopy.stripLine(uid: me, days: 3, won: 2, lost: 1),
        '2 ganhou · 1 perdeu',
      );
    });

    test('idle when there is no history', () {
      expect(
        CornerCopy.stripLine(uid: me, days: 3, won: 0, lost: 0),
        CornerCopy.stripIdle,
      );
    });
  });
}

Trail _trail({String slug = 'genesis-1-11', String title = 'Gênesis 1–11'}) =>
    Trail(
      slug: slug,
      title: title,
      description: '',
      icon: '📖',
      order: 1,
      comingSoon: false,
      color: '#2F5D4A',
      modules: [
        TrailModule(
          title: 'A Criação',
          icon: '☀️',
          missions: [_mission('gen-01', 'No princípio')],
        ),
        TrailModule(
          title: 'O Jardim',
          icon: '🌳',
          missions: [_mission('gen-02', 'A queda'), _mission('gen-03', 'Caim')],
        ),
      ],
    );

Mission _mission(String slug, String title) => Mission(
  slug: slug,
  title: title,
  intro: '',
  type: 'lesson',
  stepsReward: 50,
  questions: const [],
);

CornerChallenge _challenge({
  String id = 'c1',
  CornerStatus status = CornerStatus.active,
  String weekStart = '',
  String? challengerDoneAt,
  String? opponentDoneAt,
  int? challengerCorrect,
  int? challengerTotal,
  int? opponentCorrect,
  int? opponentTotal,
  String? withdrawnBy,
}) {
  return CornerChallenge(
    id: id,
    challengerId: 'nat',
    challengerName: 'Natã',
    opponentId: 'me',
    opponentName: 'Eu',
    trailSlug: 'genesis-1-11',
    trailTitle: 'Gênesis 1–11',
    missionSlug: 'gen-02',
    missionTitle: 'A queda',
    moduleTitle: 'O Jardim',
    weekStart: weekStart.isEmpty ? cornerWeekStart() : weekStart,
    status: status,
    challengerDoneAt: challengerDoneAt,
    opponentDoneAt: opponentDoneAt,
    challengerCorrect: challengerCorrect,
    challengerTotal: challengerTotal,
    opponentCorrect: opponentCorrect,
    opponentTotal: opponentTotal,
    withdrawnBy: withdrawnBy,
  );
}
