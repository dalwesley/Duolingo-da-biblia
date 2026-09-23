import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/caravan_pilgrim_profile.dart';
import 'package:trilha_app/models/caravan_profile_prefs.dart';
import 'package:trilha_app/models/recognition.dart';

void main() {
  group('Recognition', () {
    test('doc id is one tap per person, kind and subject', () {
      expect(
        Recognition.docId(
          fromUid: 'ana',
          toUid: 'pedro',
          kind: RecognitionKind.walk,
          subjectKey: '2026-09-22',
        ),
        'ana_pedro_walk_2026-09-22',
      );
      expect(
        Recognition.docId(
          fromUid: 'ana',
          toUid: 'lia',
          kind: RecognitionKind.medal,
          subjectKey: 'track:path:streak_14',
        ),
        'ana_lia_medal_track:path:streak_14',
      );
      expect(
        Recognition.docId(
          fromUid: 'ana',
          toUid: 'pedro',
          kind: RecognitionKind.medal,
          subjectKey: 'track:path:streak_14',
        ),
        isNot(
          Recognition.docId(
            fromUid: 'ana',
            toUid: 'lia',
            kind: RecognitionKind.medal,
            subjectKey: 'track:path:streak_14',
          ),
        ),
      );
    });

    test('walk key is a date and medal key stays inside the id alphabet', () {
      expect(
        Recognition.validSubject(RecognitionKind.walk, '2026-09-22'),
        isTrue,
      );
      expect(Recognition.validSubject(RecognitionKind.walk, 'ontem'), isFalse);
      expect(
        Recognition.validSubject(RecognitionKind.medal, 'track:path:streak_14'),
        isTrue,
      );
      expect(
        Recognition.validSubject(RecognitionKind.medal, 'medalha livre'),
        isFalse,
      );
    });

    test('headline uses the catalog title, not a free label', () {
      const walk = Recognition(
        id: 'a',
        fromUid: 'ana',
        fromName: 'Ana',
        toUid: 'pedro',
        kind: RecognitionKind.walk,
        subjectKey: '2026-09-22',
      );
      expect(walk.headline, 'Ana reconheceu a sua cena');
      expect(walk.subjectLabel, 'Cena de 22 set');

      const medal = Recognition(
        id: 'b',
        fromUid: 'ana',
        fromName: 'Ana',
        toUid: 'pedro',
        kind: RecognitionKind.medal,
        subjectKey: 'track:path:streak_14',
      );
      expect(medal.headline, 'Ana reconheceu a medalha Duas semanas');
      expect(medal.subjectLabel, 'Duas semanas');
      expect(medal.historyLine, 'Ana · Duas semanas');

      const unknown = Recognition(
        id: 'c',
        fromUid: 'ana',
        fromName: 'Ana',
        toUid: 'pedro',
        kind: RecognitionKind.medal,
        subjectKey: 'track:nope:missing',
      );
      expect(unknown.headline, 'Ana reconheceu uma medalha sua');
      expect(unknown.subjectLabel, 'Uma medalha');
    });

    test('first name is what the other person reads', () {
      expect(recognitionFromName('  Ana Maria  '), 'Ana');
      expect(recognitionFromName(''), 'Alguém');
    });
  });

  group('recognizable targets', () {
    test('walk date follows what the profile shares', () {
      const open = CaravanPilgrimProfile(
        name: 'Lia',
        steps: 10,
        lastWalkDate: '2026-09-22',
        lastMissionCompletedDate: '2026-09-21',
      );
      expect(recognizableWalkDate(open), '2026-09-21');

      final hidden = CaravanPilgrimProfile(
        name: 'Lia',
        steps: 10,
        lastWalkDate: '2026-09-22',
        lastMissionCompletedDate: '2026-09-21',
        prefs: CaravanProfilePrefs({
          CaravanProfileSection.presence: false,
          CaravanProfileSection.lastMission: false,
        }),
      );
      expect(recognizableWalkDate(hidden), isNull);

      final presenceOnly = CaravanPilgrimProfile(
        name: 'Lia',
        steps: 10,
        lastWalkDate: '2026-09-22',
        prefs: CaravanProfilePrefs({CaravanProfileSection.lastMission: false}),
      );
      expect(recognizableWalkDate(presenceOnly), '2026-09-22');
    });

    test('streak medals already earned can be recognized one by one', () {
      const profile = CaravanPilgrimProfile(name: 'Lia', steps: 40, streak: 14);
      final medals = recognizableMedals(profile: profile, catalog: const []);
      final ids = medals.map((medal) => medal.id).toList();
      expect(ids, contains('track:path:streak_3'));
      expect(ids, contains('track:path:streak_14'));
      expect(ids, isNot(contains('track:path:streak_30')));
    });

    test('hidden medals are not offered', () {
      final profile = CaravanPilgrimProfile(
        name: 'Lia',
        steps: 40,
        streak: 14,
        prefs: CaravanProfilePrefs({CaravanProfileSection.medals: false}),
      );
      expect(recognizableMedals(profile: profile, catalog: const []), isEmpty);
    });
  });
}
