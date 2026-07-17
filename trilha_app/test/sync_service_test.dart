import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/progress_service.dart';
import 'package:trilha_app/services/sync_service.dart';

void main() {
  test('export and parse roundtrip v2', () {
    final sync = SyncService();
    final progress = ProgressService();
    progress.steps = 100;
    progress.streak = 3;
    progress.lastPlayedDate = '2026-07-11';
    progress.completedMissions = ['m1', 'm2'];
    progress.missionsToday = 1;
    progress.userName = 'Teste';

    final json = sync.exportJson(progress);
    final parsed = sync.parseImport(json);
    expect(parsed, isNotNull);
    expect(parsed!['version'], 2);
    expect(parsed['steps'], 100);
    expect(parsed['streak'], 3);
    expect((parsed['completedMissions'] as List).cast<String>(), ['m1', 'm2']);
    expect(parsed['userName'], 'Teste');
  });

  test('legacy v1 import still parses', () {
    final sync = SyncService();
    const legacy = '''
    {
      "version": 1,
      "steps": 42,
      "streak": 2,
      "lastPlayedDate": "2026-07-11",
      "completedMissions": ["a"],
      "missionsToday": 1,
      "userName": "Legado"
    }
    ''';
    final parsed = sync.parseImport(legacy);
    expect(parsed, isNotNull);
    expect(parsed!['version'], 1);
    expect(parsed['steps'], 42);
    expect(parsed['userName'], 'Legado');
  });

  test('invalid json returns null', () {
    final sync = SyncService();
    expect(sync.parseImport('not json'), isNull);
  });
}
