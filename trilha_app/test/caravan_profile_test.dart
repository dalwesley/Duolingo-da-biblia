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
}
