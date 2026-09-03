import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/league_service.dart';

void main() {
  group('LeagueEntry activity labels', () {
    test('formatBrDate converts YYYY-MM-DD', () {
      expect(LeagueEntry.formatBrDate('2025-12-25'), '25/12/2025');
      expect(LeagueEntry.formatBrDate(null), isNull);
    });

    test('formatShortBrDate uses DD/MM', () {
      expect(LeagueEntry.formatShortBrDate('2025-12-25'), '25/12');
    });

    test('metaPills separates role, walk and online', () {
      const entry = LeagueEntry(
        name: 'João',
        steps: 100,
        lastWalkDate: '2025-12-25',
        lastSeenDate: '2025-12-20',
      );
      final pills = entry.metaPills(rank: 1);
      expect(pills.map((p) => p.label), ['Líder', '25/12', 'Online 20/12']);
    });

    test('metaPills hides redundant online when walked today', () {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final entry = LeagueEntry(
        name: 'João',
        steps: 100,
        lastWalkDate: today,
        lastSeenDate: today,
      );
      final pills = entry.metaPills(rank: 2);
      expect(pills.map((p) => p.label), ['Vice', 'Caminhou hoje']);
    });

    test('activitySummary shows ativo hoje when both are today', () {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final entry = LeagueEntry(
        name: 'João',
        steps: 100,
        lastWalkDate: today,
        lastSeenDate: today,
      );
      expect(entry.activitySummary, 'Ativo hoje');
      expect(entry.isOnlineToday, isTrue);
    });

    test('lastOnlineLabel shows hoje when seen today', () {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final entry = LeagueEntry(
        name: 'João',
        steps: 100,
        lastSeenDate: today,
      );
      expect(entry.lastOnlineLabel, 'Online hoje');
    });
  });
}
