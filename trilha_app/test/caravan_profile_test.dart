import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/caravan_profile_prefs.dart';
import 'package:trilha_app/models/caravan_pilgrim_profile.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/widgets/pilgrim_profile_sections.dart';

void main() {
  group('CaravanProfilePrefs', () {
    test('defaults all sections visible', () {
      const prefs = CaravanProfilePrefs();
      for (final s in CaravanProfileSection.values) {
        expect(prefs.isVisible(s), isTrue);
      }
    });

    test('copyWithSection toggles one field', () {
      const prefs = CaravanProfilePrefs();
      final next = prefs.copyWithSection(CaravanProfileSection.bible, false);
      expect(next.isVisible(CaravanProfileSection.bible), isFalse);
      expect(next.isVisible(CaravanProfileSection.trails), isTrue);
    });

    test('shouldShow hides from others when off', () {
      final prefs =
          const CaravanProfilePrefs().copyWithSection(CaravanProfileSection.accuracy, false);
      expect(
        prefs.shouldShow(CaravanProfileSection.accuracy, isOwner: false),
        isFalse,
      );
      expect(
        prefs.shouldShow(CaravanProfileSection.accuracy, isOwner: true),
        isTrue,
      );
    });
  });

  group('CaravanPilgrimProfile accuracy', () {
    test('accuracyPercent from lifetime stats', () {
      const profile = CaravanPilgrimProfile(
        name: 'João',
        steps: 10,
        lifetimeQuestionsCorrect: 8,
        lifetimeQuestionsAnswered: 10,
      );
      expect(profile.accuracyPercent, 80);
    });
  });

  group('pilgrim profile copy', () {
    test('formatCount uses thousands separator', () {
      expect(pilgrimFormatCount(1923), '1.923');
      expect(pilgrimFormatCount(12), '12');
      expect(pilgrimFormatCount(1000000), '1.000.000');
    });

    test('short stop label drops articles', () {
      expect(pilgrimShortStopLabel('A Criação'), 'Criação');
      expect(pilgrimShortStopLabel('O Jardim'), 'Jardim');
      expect(pilgrimShortStopLabel('Depois do Éden'), 'Éden');
    });
  });

  group('CaravanPilgrimProfile.fromCloudMap', () {
    test('reads ranking fields from typical cloud payload', () {
      final profile = CaravanPilgrimProfile.fromCloudMap(
        uid: 'u1',
        data: {
          'userName': 'Maria',
          'steps': 42,
          'streak': 3,
          'lastWalkDate': '2026-09-01',
          'lastSeenDate': '2026-09-02',
          'completedMissions': ['gen-01'],
          'photoUrl': 'https://example.com/maria.jpg',
        },
      );
      expect(profile.name, 'Maria');
      expect(profile.steps, 42);
      expect(profile.streak, 3);
      expect(profile.lastWalkDate, '2026-09-01');
      expect(profile.missionsCompleted, 1);
      expect(profile.photoUrl, 'https://example.com/maria.jpg');
    });

    test('tolerates Timestamp-like dates and string numbers', () {
      final profile = CaravanPilgrimProfile.fromCloudMap(
        uid: 'u2',
        fallbackName: 'Card',
        data: {
          'steps': '17',
          'xp': 9,
          'lastWalkDate': _FakeTimestamp(DateTime(2026, 8, 20, 21, 4)),
          'lastSeenDate': DateTime(2026, 8, 21, 8),
          'firstOpenDate': '2026-01-03T12:00:00.000',
          'lifetimeQuestionsCorrect': '4',
        },
      );
      expect(profile.name, 'Card');
      expect(profile.steps, 17);
      expect(profile.lastWalkDate, '2026-08-20');
      expect(profile.lastSeenDate, '2026-08-21');
      expect(profile.firstOpenDate, '2026-01-03');
      expect(profile.lifetimeQuestionsCorrect, 4);
    });

    test('ignores unexpected types instead of throwing', () {
      final profile = CaravanPilgrimProfile.fromCloudMap(
        uid: 'u3',
        fallbackName: 'Ana',
        data: {
          'userName': 123,
          'steps': true,
          'lastWalkDate': {'seconds': 1},
          'completedMissions': 'gen-01',
        },
      );
      expect(profile.name, 'Ana');
      expect(profile.steps, 0);
      expect(profile.lastWalkDate, isNull);
      expect(profile.completedMissions, isEmpty);
    });
  });

  group('CaravanPilgrimProfile.enriched', () {
    test('fills module stops and last mission insight from catalog', () async {
      const profile = CaravanPilgrimProfile(
        name: 'João',
        steps: 10,
        completedMissions: ['gen-01', 'gen-02'],
        lastMissionSlug: 'gen-02',
      );
      final catalog = [
        Trail(
          slug: 'genesis-1-11',
          title: 'Gênesis 1–11',
          description: 'Do princípio aos primeiros povos',
          icon: '📖',
          order: 1,
          comingSoon: false,
          color: '#2F5D4A',
          modules: [
            TrailModule(
              title: 'A Criação',
              icon: '☀️',
              missions: [
                _mission('gen-01', 'No princípio', insight: 'Deus fala e há luz'),
              ],
            ),
            TrailModule(
              title: 'O Jardim',
              icon: '🌳',
              missions: [
                _mission(
                  'gen-02',
                  'A queda',
                  insight: 'Deus ainda pergunta onde estás',
                  hookRef: 'Gênesis 3:9',
                ),
                _mission('gen-02b', 'Caim'),
              ],
            ),
            TrailModule(
              title: 'Depois do Éden',
              icon: '🌊',
              missions: [_mission('gen-03', 'O dilúvio')],
            ),
          ],
        ),
      ];

      final out = await profile.enriched(catalog: catalog, bibleBooks: const []);
      expect(out.trails, hasLength(1));
      expect(out.trails.first.description, 'Do princípio aos primeiros povos');
      expect(out.trails.first.modules, hasLength(3));
      expect(out.trails.first.modules[0].isComplete, isTrue);
      expect(out.trails.first.modules[1].isCurrent, isTrue);
      expect(out.trails.first.modules[2].hasStarted, isFalse);
      expect(out.lastMissionTitle, 'A queda');
      expect(out.lastTrailTitle, 'Gênesis 1–11');
      expect(out.lastMissionInsight, 'Deus ainda pergunta onde estás');
      expect(out.lastMissionRef, 'Gênesis 3:9');
    });

    test('infers last scene from completed missions when slug is missing',
        () async {
      const profile = CaravanPilgrimProfile(
        name: 'Josias',
        steps: 10,
        completedMissions: ['gen-01', 'gen-02'],
      );
      final catalog = [
        Trail(
          slug: 'genesis-1-11',
          title: 'Gênesis 1–11',
          description: 'Do princípio aos primeiros povos',
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
                _mission('gen-02', 'A queda', hookRef: 'Gênesis 3:9'),
                _mission('gen-02b', 'Caim'),
              ],
            ),
          ],
        ),
      ];

      final out = await profile.enriched(catalog: catalog, bibleBooks: const []);
      expect(out.lastMissionTitle, 'A queda');
      expect(out.lastTrailTitle, 'Gênesis 1–11');
      expect(out.lastMissionRef, 'Gênesis 3:9');
    });
  });
}

Mission _mission(
  String slug,
  String title, {
  String? insight,
  String? hookRef,
}) =>
    Mission(
      slug: slug,
      title: title,
      intro: '',
      type: 'lesson',
      stepsReward: 50,
      questions: const [],
      centralInsight: insight,
      hookRef: hookRef,
    );

class _FakeTimestamp {
  final DateTime value;
  _FakeTimestamp(this.value);
  DateTime toDate() => value;
}
