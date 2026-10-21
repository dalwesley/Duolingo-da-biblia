import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'restarting a guided plan resumes the sample instead of renewing it',
    () async {
      SharedPreferences.setMockInitialValues({});
      final progress = ProgressService();

      await progress.startGuidedReadingPlan('evangelhos-30');
      expect(progress.bibleReadingPlan.completedDays, 0);

      await progress.completeBibleReadingPortion(
        toCursor: 1,
        chapters: const [(abbrev: 'mt', chapter: 1)],
      );
      expect(progress.guidedSampleDays['evangelhos-30'], 1);

      await progress.clearBibleReadingPlan();
      await progress.startGuidedReadingPlan('evangelhos-30');

      // Retoma do dia 2: encerrar e recomeçar não devolveu a amostra.
      expect(progress.bibleReadingPlan.completedDays, 1);
      expect(progress.bibleReadingPlan.cursor, 1);
      expect(progress.bibleReadingPlan.lockedToday(plusOpen: false), isFalse);
    },
  );

  test('daily review slug marks today as done', () async {
    SharedPreferences.setMockInitialValues({});
    final progress = ProgressService();
    expect(progress.isDailyReviewDoneToday, isFalse);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await progress.completeMission('daily-review-$today', 30);
    expect(progress.isDailyReviewDoneToday, isTrue);
  });
}
