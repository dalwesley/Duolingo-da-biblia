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
      expect(fromThem.headline(me), CornerCopy.youDid('A queda'));
      expect(fromThem.iDone(me), isTrue);
      expect(fromThem.theyDone(me), isFalse);
    });

    test('both done — higher accuracy leads', () {
      final c = _challenge(
        status: CornerStatus.settled,
        challengerDoneAt: 'a',
        opponentDoneAt: 'b',
        opponentCorrect: 6,
        opponentTotal: 6,
        challengerCorrect: 5,
        challengerTotal: 6,
      );
      expect(c.headline(me), CornerCopy.winHeadline);
      expect(c.scoreSign(me), 1);
      expect(c.subline(me), CornerCopy.yourReadingLed);
      expect(c.scoreSign(them), -1);
    });

    test('tie', () {
      final c = _challenge(
        status: CornerStatus.settled,
        challengerDoneAt: 'a',
        opponentDoneAt: 'b',
        opponentCorrect: 5,
        opponentTotal: 6,
        challengerCorrect: 5,
        challengerTotal: 6,
      );
      expect(c.scoreSign(me), 0);
      expect(c.headline(me), CornerCopy.tieHeadline);
      expect(c.subline(me), CornerCopy.tied);
    });

    test('week ended without them', () {
      final c = _challenge(
        status: CornerStatus.active,
        weekStart: '2000-01-03',
        opponentDoneAt: '2000-01-04',
      );
      expect(c.isThisWeek, isFalse);
      expect(c.headline(me), CornerCopy.stayedThisSide('A queda'));
    });

    test('active corner opens that scene even if the trail is gated', () {
      final c = _challenge(status: CornerStatus.active);
      expect(c.opensFor(me, 'gen-02'), isTrue);
      expect(c.opensFor(me, 'gen-03'), isFalse);
      expect(
        CornerChallenge.authorizes('gen-02', me, [c]),
        isTrue,
      );
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

    test('one tie becomes 1 empate', () {
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
      expect(record.closed, 1);
      expect(record.ties, 1);
      expect(record.line, '1 empate');
      expect(record.whisper, CornerCopy.tied);
    });

    test('one win becomes 1 vitória', () {
      final win = _challenge(
        status: CornerStatus.settled,
        challengerDoneAt: 'a',
        opponentDoneAt: 'b',
        opponentCorrect: 6,
        opponentTotal: 6,
        challengerCorrect: 5,
        challengerTotal: 6,
      );
      final record = CornerRecord.of([win], me);
      expect(record.wins, 1);
      expect(record.line, '1 vitória');
      expect(record.whisper, CornerCopy.yourReadingLed);
    });
  });
}

Trail _trail({
  String slug = 'genesis-1-11',
  String title = 'Gênesis 1–11',
}) =>
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
          missions: [
            _mission('gen-02', 'A queda'),
            _mission('gen-03', 'Caim'),
          ],
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
  CornerStatus status = CornerStatus.active,
  String weekStart = '',
  String? challengerDoneAt,
  String? opponentDoneAt,
  int? challengerCorrect,
  int? challengerTotal,
  int? opponentCorrect,
  int? opponentTotal,
}) {
  return CornerChallenge(
    id: 'c1',
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
  );
}
