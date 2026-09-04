import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/caravan_profile_prefs.dart';
import 'package:trilha_app/models/caravan_pilgrim_profile.dart';

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
        },
      );
      expect(profile.name, 'Maria');
      expect(profile.steps, 42);
      expect(profile.streak, 3);
      expect(profile.lastWalkDate, '2026-09-01');
      expect(profile.missionsCompleted, 1);
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
}

class _FakeTimestamp {
  final DateTime value;
  _FakeTimestamp(this.value);
  DateTime toDate() => value;
}
