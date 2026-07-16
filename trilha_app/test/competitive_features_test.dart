import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/liturgical_calendar.dart';
import 'package:trilha_app/utils/spiritual_growth.dart';

void main() {
  group('LiturgicalCalendar', () {
    test('Easter 2026 is April 5', () {
      expect(LiturgicalCalendar.easterSunday(2026), DateTime(2026, 4, 5));
    });

    test('Holy Week before Easter', () {
      final m = LiturgicalCalendar.momentFor(DateTime(2026, 4, 1));
      expect(m.season, LiturgicalSeason.holyWeek);
      expect(LiturgicalCalendar.seasonalQuestToday(DateTime(2026, 4, 1)), isNotNull);
    });

    test('Ordinary time has no seasonal quest', () {
      final m = LiturgicalCalendar.momentFor(DateTime(2026, 7, 15));
      expect(m.season, LiturgicalSeason.ordinary);
      expect(LiturgicalCalendar.seasonalQuestToday(DateTime(2026, 7, 15)), isNull);
    });
  });

  group('SpiritualGrowth', () {
    test('stages unlock with streak', () {
      expect(SpiritualGrowth.fromStreak(0).stage, GrowthStage.seed);
      expect(SpiritualGrowth.fromStreak(2).stage, GrowthStage.sprout);
      expect(SpiritualGrowth.fromStreak(5).stage, GrowthStage.sapling);
      expect(SpiritualGrowth.fromStreak(10).stage, GrowthStage.olive);
      expect(SpiritualGrowth.fromStreak(20).stage, GrowthStage.lamp);
    });
  });
}
