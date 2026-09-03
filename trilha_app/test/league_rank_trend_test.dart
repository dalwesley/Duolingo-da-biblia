import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/league_service.dart';

void main() {
  const week = '2026-08-31';

  group('WeeklyRankSnapshot', () {
    test('first look of the week has no trend', () {
      final snap = WeeklyRankSnapshot();
      expect(
        snap.observe(8, week: week, today: '2026-09-01'),
        isTrue,
      );
      expect(snap.trendFor(8, week: week), isNull);
    });

    test('same-day climb shows up without prior day', () {
      final snap = WeeklyRankSnapshot();
      snap.observe(8, week: week, today: '2026-09-01');
      snap.observe(5, week: week, today: '2026-09-01');
      final trend = snap.trendFor(5, week: week);
      expect(trend, isNotNull);
      expect(trend!.drift, RankDrift.up);
      expect(trend.places, 3);
      expect(trend.label, 'Subiu 3 posições hoje');
    });

    test('same-day drop uses singular copy', () {
      final snap = WeeklyRankSnapshot();
      snap.observe(4, week: week, today: '2026-09-01');
      snap.observe(5, week: week, today: '2026-09-01');
      final trend = snap.trendFor(5, week: week);
      expect(trend!.drift, RankDrift.down);
      expect(trend.places, 1);
      expect(trend.label, 'Desceu 1 posição hoje');
    });

    test('same-day refresh without movement stays quiet on first day', () {
      final snap = WeeklyRankSnapshot();
      snap.observe(6, week: week, today: '2026-09-01');
      expect(snap.observe(6, week: week, today: '2026-09-01'), isFalse);
      expect(snap.trendFor(6, week: week), isNull);
    });

    test('next day uses last rank as baseline and can be stable', () {
      final snap = WeeklyRankSnapshot();
      snap.observe(7, week: week, today: '2026-09-01');
      snap.observe(7, week: week, today: '2026-09-02');
      final trend = snap.trendFor(7, week: week);
      expect(trend!.drift, RankDrift.stable);
      expect(trend.label, 'Posição estável hoje');
    });

    test('next day climb compares against yesterday close', () {
      final snap = WeeklyRankSnapshot();
      snap.observe(10, week: week, today: '2026-09-01');
      snap.observe(8, week: week, today: '2026-09-01');
      snap.observe(5, week: week, today: '2026-09-02');
      final trend = snap.trendFor(5, week: week);
      expect(trend!.drift, RankDrift.up);
      expect(trend.places, 3);
      expect(trend.baseline, 8);
    });

    test('new week resets and hides trend', () {
      final snap = WeeklyRankSnapshot();
      snap.observe(3, week: week, today: '2026-09-06');
      snap.observe(2, week: '2026-09-07', today: '2026-09-07');
      expect(snap.trendFor(2, week: '2026-09-07'), isNull);
      expect(snap.anchoredFromPriorDay, isFalse);
      expect(snap.baseline, 2);
    });

    test('ignore invalid rank', () {
      final snap = WeeklyRankSnapshot();
      expect(snap.observe(0, week: week, today: '2026-09-01'), isFalse);
      expect(snap.trendFor(0, week: week), isNull);
    });
  });

  group('WeeklyRankTrend copy', () {
    test('singular up', () {
      const trend = WeeklyRankTrend(
        drift: RankDrift.up,
        places: 1,
        rank: 4,
        baseline: 5,
      );
      expect(trend.label, 'Subiu 1 posição hoje');
    });
  });
}
