import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/sync_service.dart';

void main() {
  test('export and parse roundtrip', () {
    final sync = SyncService();
    final json = sync.exportJson(
      xp: 100,
      streak: 3,
      lastPlayedDate: '2026-07-11',
      completedMissions: ['m1', 'm2'],
      missionsToday: 1,
      userName: 'Teste',
    );
    final parsed = sync.parseImport(json);
    expect(parsed, isNotNull);
    expect(parsed!.xp, 100);
    expect(parsed.streak, 3);
    expect(parsed.completedMissions, ['m1', 'm2']);
    expect(parsed.userName, 'Teste');
  });

  test('invalid json returns null', () {
    final sync = SyncService();
    expect(sync.parseImport('not json'), isNull);
  });
}
