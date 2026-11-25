import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('quests de outro dia não contam hoje (app aberto na virada)', () {
    final p = ProgressService()
      ..questDay = '2000-01-01'
      ..questProgressMap = {'mission': 1}
      ..questClaimed = ['mission'];
    expect(p.isQuestClaimed('mission'), isFalse);
    expect(p.questProgress('mission'), 0);
    expect(p.dailyChestAvailable, isFalse);
    expect(p.questsCompletedToday, 0);
  });

  test('cena de hoje conta a quest e libera o baú', () async {
    final p = ProgressService();
    await p.completeMission('gen-test-01', 40, correct: 3, total: 3);
    expect(p.isQuestClaimed('mission'), isTrue);
    expect(p.questProgress('mission'), 1);
    expect(p.dailyChestAvailable, isTrue);
  });

  test('rolloverIfNeeded vira dia e semana parados de ontem', () async {
    final p = ProgressService();
    await p.load();
    await Future<void>.delayed(Duration.zero);
    p
      ..questDay = '2000-01-01'
      ..questProgressMap = {'mission': 1}
      ..questClaimed = ['mission']
      ..weeklyWeek = '2000-01-03'
      ..weeklySteps = 50
      ..weeklyProgressMap = {'scenes': 3}
      ..weeklyClaimed = ['scenes'];
    var notified = 0;
    p.addListener(() => notified++);
    await p.rolloverIfNeeded();
    await Future<void>.delayed(Duration.zero);
    expect(p.questDay, isNot('2000-01-01'));
    expect(p.questProgressMap, isEmpty);
    expect(p.weeklyWeek, isNot('2000-01-03'));
    expect(p.weeklySteps, 0);
    expect(p.lastWeekSteps, 50);
    expect(p.weeklyClaimed, isEmpty);
    expect(notified, greaterThan(0));

    notified = 0;
    await p.rolloverIfNeeded();
    await Future<void>.delayed(Duration.zero);
    expect(notified, 0, reason: 'nada virou: não salva nem notifica');
  });
}

