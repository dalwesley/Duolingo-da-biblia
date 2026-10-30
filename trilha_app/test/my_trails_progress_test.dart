import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/models/user_intent.dart';
import 'package:trilha_app/services/progress_service.dart';
import 'package:trilha_app/utils/trail_progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'a cena da própria trilha a escolhe; replay e outro fluxo não',
    () async {
      final p = ProgressService();
      await p.completeMission('genesis-1', 10, chooseTrail: 'genesis');
      await p.completeMission('isaias-1', 10);
      await p.completeMission(
        'mateus-1',
        10,
        isReplay: true,
        chooseTrail: 'mateus',
      );
      expect(p.trailChosenAt.keys, ['genesis']);

      final first = p.trailChosenAt['genesis'];
      await p.completeMission('genesis-2', 10, chooseTrail: 'genesis');
      expect(p.trailChosenAt['genesis'], first, reason: 'a ordem não muda');
    },
  );

  test('sair da trilha e fechar o modo tiram da lista', () async {
    final p = ProgressService();
    await p.completeMission('genesis-1', 10, chooseTrail: 'genesis');
    await p.completeMission('mateus-1', 10, chooseTrail: 'mateus');
    await p.leaveTrail(trailSlug: 'genesis', missionSlugs: ['genesis-1']);
    expect(p.trailChosenAt.keys, ['mateus']);
    await p.markTrailModeCleared('mateus', 'semente');
    expect(p.trailChosenAt, isEmpty);
  });

  test('a nuvem junta as listas e fica a escolha mais antiga', () async {
    final p = ProgressService()
      ..trailChosenAt = {'genesis': '2026-10-05T09:00:00'};
    await p.applyFromCloud({
      'version': 2,
      'trailChosenAt': {
        'genesis': '2026-10-01T09:00:00',
        'mateus': '2026-10-03T09:00:00',
      },
      'trailChoicesSeedV': 2,
    });
    expect(p.trailChosenAt, {
      'genesis': '2026-10-01T09:00:00',
      'mateus': '2026-10-03T09:00:00',
    });
    expect(p.trailChoicesSeeded, isTrue);
  });

  test('a semente vale uma vez e não apaga escolha feita', () async {
    final p = ProgressService();
    await p.seedTrailChoices(['ansiedade', 'genesis']);
    expect(p.trailChosenAt.keys.toList()..sort(), ['ansiedade', 'genesis']);
    expect(
      p.trailChosenAt['ansiedade']!.compareTo(p.trailChosenAt['genesis']!),
      lessThan(0),
    );
    await p.seedTrailChoices(['mateus']);
    expect(p.trailChosenAt.containsKey('mateus'), isFalse);
  });

  test('escolha feita antes da semente não apaga a trilha antiga', () async {
    final p = ProgressService();
    await p.completeMission('ansiedade-1', 10, chooseTrail: 'ansiedade');
    await p.seedTrailChoices(['genesis', 'ansiedade']);
    final order = p.trailChosenAt.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    expect(order.map((e) => e.key), ['genesis', 'ansiedade']);
  });

  test('sair da trilha: a nuvem não devolve escolha nem cena', () async {
    final p = ProgressService();
    await p.completeMission('genesis-1', 10, chooseTrail: 'genesis');
    await p.leaveTrail(trailSlug: 'genesis', missionSlugs: ['genesis-1']);
    expect(p.completedMissions, isEmpty);
    expect(p.trailChosenAt, isEmpty);
    expect(p.trailsLeftAt.containsKey('genesis'), isTrue);
    expect(p.leftMissionSlugs, ['genesis-1']);

    await p.applyFromCloud({
      'version': 2,
      'completedMissions': ['genesis-1', 'mateus-1'],
      'trailChosenAt': {'genesis': '2026-10-01T09:00:00'},
      'trailChoicesSeedV': 2,
    });
    expect(p.completedMissions, ['mateus-1']);
    expect(p.trailChosenAt.containsKey('genesis'), isFalse);
  });

  test('reservar na abertura trava a vaga antes de completar', () async {
    final p = ProgressService();
    await p.reserveTrailChoice('genesis');
    expect(p.trailChosenAt.keys, ['genesis']);
    await p.completeMission('genesis-1', 10, chooseTrail: 'genesis');
    expect(p.trailChosenAt.keys, ['genesis']);
  });

  test('outra trilha na vaga limpa o motivo de entrada', () async {
    final p = ProgressService()
      ..settings = const AppSettings(intent: UserIntent.peace);
    expect(TrailProgress.preferredTrailSlug, 'ansiedade');
    await p.reserveTrailChoice('genesis-1-11');
    expect(p.settings.intent, isNull);
    expect(TrailProgress.preferredTrailSlug, isNull);
    expect(p.toCloudMap()['settings'], containsPair('intent', ''));
  });

  test('reservar a própria porta do motivo mantém o motivo', () async {
    final p = ProgressService()
      ..settings = const AppSettings(intent: UserIntent.know);
    await p.reserveTrailChoice('conhecer-a-deus');
    expect(p.settings.intent, UserIntent.know);
    expect(TrailProgress.preferredTrailSlug, 'conhecer-a-deus');
  });
}
