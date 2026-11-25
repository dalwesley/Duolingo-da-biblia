import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/caravan_profile_extras.dart';
import 'package:trilha_app/models/caravan_profile_prefs.dart';
import 'package:trilha_app/services/backend_service.dart';

void main() {
  Map<String, dynamic> payload(CaravanProfilePrefs prefs) => {
    'caravanProfilePrefs': prefs.toMap(),
    'answerCorrect': {'semente.choice': 8},
    'answerTotal': {'semente.choice': 10},
    'weekAnswerCorrect': {'2026-11-23.semente': 4},
    'weekAnswerTotal': {'2026-11-23.semente': 5},
    'bibleBookmarks': ['gn:1:1', 'jo:3:16'],
    'bibleNotes': {'gn:1:1': {'text': 'privado'}},
  };

  test('study and word stay out of the public doc by default', () {
    final split = BackendService.splitPayload(
      payload(const CaravanProfilePrefs()),
    );
    for (final k in CaravanProfileExtras.studyKeys) {
      expect(split.public.containsKey(k), isFalse, reason: k);
    }
    expect(split.public.containsKey(CaravanProfileExtras.wordKey), isFalse);
    expect(split.public.containsKey('answerTotal'), isFalse);
  });

  test('open eyes publish only the summary, never note text', () {
    final prefs = const CaravanProfilePrefs()
        .copyWithSection(CaravanProfileSection.study, true)
        .copyWithSection(CaravanProfileSection.word, true);
    final split = BackendService.splitPayload(payload(prefs));
    expect(split.public['studyTotal'], {'semente.choice': 10});
    expect(split.public['studyWeekTotal'], {'2026-11-23.semente': 5});
    expect(split.public['wordCounts'], {'bookmarks': 2, 'notes': 1});
    expect(split.public.containsKey('bibleNotes'), isFalse);
    expect(split.public.containsKey('answerTotal'), isFalse);

    final extras = CaravanProfileExtras.fromCloudMap(split.public);
    expect(extras.hasStudy, isTrue);
    expect(extras.bookmarkCount, 2);
    expect(extras.noteCount, 1);
  });

  test('recentWeeks keeps the last 8 weeks', () {
    final map = {
      for (var i = 1; i <= 10; i++)
        '2026-${i.toString().padLeft(2, '0')}-01.semente': i,
    };
    final kept = CaravanProfileExtras.recentWeeks(map);
    expect(kept.length, 8);
    expect(kept.containsKey('2026-01-01.semente'), isFalse);
    expect(kept.containsKey('2026-10-01.semente'), isTrue);
  });
}
