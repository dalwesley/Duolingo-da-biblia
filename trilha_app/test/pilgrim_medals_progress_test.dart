import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProgressService medals', () {
    test('records perfect mission on first 100% completion', () async {
      final progress = ProgressService();
      await progress.completeMission(
        'gen-test-01',
        40,
        correct: 6,
        total: 6,
      );

      expect(progress.perfectMissions, contains('gen-test-01'));
    });

    test('does not duplicate perfect mission slug', () async {
      final progress = ProgressService();
      await progress.completeMission('gen-test-01', 40, correct: 6, total: 6);
      await progress.completeMission(
        'gen-test-01',
        40,
        isReplay: true,
        correct: 6,
        total: 6,
      );

      expect(progress.perfectMissions.where((s) => s == 'gen-test-01').length, 1);
    });

    test('increments shared verse count', () async {
      final progress = ProgressService();
      await progress.recordSharedVerse('João 3:16');
      await progress.recordSharedVerse('Salmos 23:1');

      expect(progress.sharedVerseCount, 2);
      expect(progress.sharedVerses.first, 'Salmos 23:1');
    });

    test('records perfect on replay with 100%', () async {
      final progress = ProgressService();
      await progress.completeMission('gen-test-02', 40, correct: 4, total: 6);
      await progress.completeMission(
        'gen-test-02',
        40,
        correct: 6,
        total: 6,
      );

      expect(progress.perfectMissions, contains('gen-test-02'));
    });

    test('marks bible-before-mission when chapter is read first', () async {
      final progress = ProgressService();
      await progress.recordBibleReading('gn', 1);
      await progress.completeMission('gen-test-03', 40, correct: 6, total: 6);
      expect(progress.bibleBeforeMission, isTrue);
    });

    test('reset keeps pioneer date and drops leftover medal counters', () async {
      final progress = ProgressService();
      progress.firstOpenDate = '2026-03-01';
      progress.lifetimeQuestionsCorrect = 90;
      progress.lifetimeQuestionsAnswered = 100;
      progress.daysAsCaravanLeader = 4;
      progress.bibleBeforeMission = true;
      progress.clearedTrailModes = {
        'genesis-1-11': ['semente'],
      };
      await progress.resetProgress();

      expect(progress.firstOpenDate, '2026-03-01');
      expect(progress.lifetimeQuestionsAnswered, 0);
      expect(progress.lifetimeQuestionsCorrect, 0);
      expect(progress.daysAsCaravanLeader, 0);
      expect(progress.bibleBeforeMission, isFalse);
      expect(progress.clearedTrailModes, isEmpty);
    });

    test('cloud snapshot of a reset walk drops every medal but pioneer', () async {
      final progress = ProgressService();
      await progress.applyFromCloud({
        'version': 2,
        'steps': 0,
        'streak': 0,
        'completedMissions': <String>[],
        'playDates': ['2025-01-01', '2026-08-01'],
        'perfectMissions': <String>[],
        'readBibleChapters': <String>[],
        'sharedVerseCount': 0,
        'memoryMastered': <String>[],
        'missionReflections': <String, String>{},
        'lifetimeQuestionsCorrect': 90,
        'lifetimeQuestionsAnswered': 100,
        'daysAsCaravanLeader': 2,
        'bibleBeforeMission': true,
        'firstOpenDate': '2026-03-01',
        'clearedTrailModes': {
          'genesis-1-11': ['semente'],
        },
      });

      expect(progress.firstOpenDate, '2026-03-01');
      expect(progress.playDates, isEmpty);
      expect(progress.lifetimeQuestionsAnswered, 0);
      expect(progress.daysAsCaravanLeader, 0);
      expect(progress.bibleBeforeMission, isFalse);
      expect(progress.clearedTrailModes, isEmpty);
    });

    test('real walk keeps accuracy counters from the cloud', () async {
      final progress = ProgressService();
      await progress.applyFromCloud({
        'version': 2,
        'steps': 40,
        'completedMissions': ['gen-test-01'],
        'playDates': ['2026-09-01'],
        'lifetimeQuestionsCorrect': 9,
        'lifetimeQuestionsAnswered': 10,
      });

      expect(progress.lifetimeQuestionsAnswered, 10);
      expect(progress.lifetimeQuestionsCorrect, 9);
    });

    test('does not mark bible-before-mission when mission is first', () async {
      final progress = ProgressService();
      await progress.completeMission('gen-test-04', 40, correct: 6, total: 6);
      await progress.recordBibleReading('gn', 1);
      expect(progress.bibleBeforeMission, isFalse);
    });
  });
}
