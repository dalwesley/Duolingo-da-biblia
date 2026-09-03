import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/progress_service.dart';

void main() {
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
  });
}
