import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('juntar com a nuvem', () {
    test(
      'trilha deixada não volta pela nuvem (cenas, postais, modos)',
      () async {
        final p = ProgressService();
        p.missionCompletedOn = {'rt-01': '2026-11-01', 'jn-01': '2026-11-02'};
        p.postcardsOn = {'rt-01': '2026-11-01'};
        p.perfectMissions = ['rt-01'];
        p.clearedTrailModes = {
          'rute': ['semente'],
        };
        p.trailAnswerTotal = {'rute': 10};
        p.trailAnswerCorrect = {'rute': 8};
        await p.leaveTrail(trailSlug: 'rute', missionSlugs: ['rt-01']);

        // A nuvem ainda tem o que havia antes de sair.
        await p.applyFromCloud({
          'version': 2,
          'missionCompletedOn': {'rt-01': '2026-11-01', 'jn-01': '2026-11-02'},
          'postcardsOn': {'rt-01': '2026-11-01'},
          'perfectMissions': ['rt-01'],
          'clearedTrailModes': {
            'rute': ['semente'],
          },
          'trailAnswerTotal': {'rute': 10},
          'trailAnswerCorrect': {'rute': 8},
        });

        expect(p.missionCompletedOn.keys, ['jn-01']);
        expect(p.postcardsOn, isEmpty);
        expect(p.perfectMissions, isEmpty);
        expect(p.clearedTrailModes.containsKey('rute'), isFalse);
        expect(p.trailAnswerTotal.containsKey('rute'), isFalse);
      },
    );

    test('cena refeita depois de sair volta a valer', () async {
      final p = ProgressService();
      p.missionCompletedOn = {'rt-01': '2026-11-01'};
      await p.leaveTrail(trailSlug: 'rute', missionSlugs: ['rt-01']);
      // Refez a cena: sai da lápide.
      p.leftMissionSlugs = [];
      await p.applyFromCloud({
        'version': 2,
        'missionCompletedOn': {'rt-01': '2026-11-01'},
      });
      expect(p.missionCompletedOn.keys, ['rt-01']);
    });

    test('dado de antes do reset não volta', () async {
      final p = ProgressService();
      p.steps = 500;
      p.missionCompletedOn = {'rt-01': '2026-11-01'};
      await p.resetProgress();
      expect(p.progressEpoch, greaterThan(0));
      expect(p.steps, 0);

      // Outro aparelho (ou o cache) ainda sem a marca do reset.
      await p.applyFromCloud({
        'version': 2,
        'steps': 500,
        'missionCompletedOn': {'rt-01': '2026-11-01'},
      });
      expect(p.steps, 0);
      expect(p.missionCompletedOn, isEmpty);
    });

    test('reset feito em outro aparelho zera este antes de juntar', () async {
      final p = ProgressService();
      p.steps = 900;
      p.missionCompletedOn = {'rt-01': '2026-11-01'};
      p.sceneLastDoneOn = {'rt-01': '2026-11-01'};
      await p.applyFromCloud({
        'version': 2,
        'progressEpoch': 1000,
        'steps': 20,
        'missionCompletedOn': {'jn-01': '2026-11-20'},
      });
      expect(p.progressEpoch, 1000);
      expect(p.steps, 20);
      expect(p.missionCompletedOn.keys, ['jn-01']);
      expect(p.sceneLastDoneOn, isEmpty);
    });

    test('mesma marca: junta normalmente', () async {
      final p = ProgressService();
      p.progressEpoch = 1000;
      p.steps = 30;
      await p.applyFromCloud({
        'version': 2,
        'progressEpoch': 1000,
        'steps': 50,
      });
      expect(p.steps, 50);
    });
  });
}
