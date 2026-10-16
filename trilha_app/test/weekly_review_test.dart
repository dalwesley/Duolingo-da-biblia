import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/progress_service.dart';

void main() {
  group('Weekly review week', () {
    test('Sunday reviews the week ending that day', () {
      final p = ProgressService();
      // 2026-10-18 is a Sunday; its week starts Monday 2026-10-12.
      expect(p.weeklyReviewWeekKey(DateTime(2026, 10, 18, 20)), '2026-10-12');
    });

    test('Monday to Saturday review the previous week', () {
      final p = ProgressService();
      expect(p.weeklyReviewWeekKey(DateTime(2026, 10, 19)), '2026-10-12');
      expect(p.weeklyReviewWeekKey(DateTime(2026, 10, 24)), '2026-10-12');
      expect(p.weeklyReviewWeekKey(DateTime(2026, 10, 25)), '2026-10-19');
    });

    test('scenes are those first done inside the week, in date order', () {
      final p = ProgressService()
        ..missionCompletedOn = {
          'b': '2026-10-15',
          'a': '2026-10-12',
          'c': '2026-10-18',
          'before': '2026-10-11',
          'after': '2026-10-19',
        };
      expect(p.missionsCompletedInWeek('2026-10-12'), ['a', 'b', 'c']);
    });

    test('done weeks are tracked by Monday key', () {
      final p = ProgressService()..weeklyReviewsDone = ['2026-10-12'];
      expect(p.isWeeklyReviewDone('2026-10-12'), isTrue);
      expect(p.isWeeklyReviewDone('2026-10-19'), isFalse);
    });
  });
}
