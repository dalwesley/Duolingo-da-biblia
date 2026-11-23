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

  group('listas que se apagam item a item', () {
    int now() => DateTime.now().millisecondsSinceEpoch;

    test('erro resolvido aqui não volta da nuvem mais velha', () async {
      final p = ProgressService();
      await p.recordMistake('q1', answer: 'a');
      await p.recordMistake('q2', answer: 'b');
      await p.clearMistake('q1');
      await p.applyFromCloud({
        'version': 2,
        'mistakeQuestionIds': ['q1', 'q2'],
        'mistakeAnswers': {'q1': 'a', 'q2': 'b'},
        'listEdits': {
          'mistakes': {'q1': now() - 5000, 'q2': now() - 5000},
        },
      });
      expect(p.mistakeQuestionIds, ['q2']);
      expect(p.mistakeAnswers.keys, ['q2']);
    });

    test('resolvido em outro aparelho (nuvem mais nova) some aqui', () async {
      final p = ProgressService();
      await p.recordMistake('q1');
      await p.recordMistake('q2');
      await p.applyFromCloud({
        'version': 2,
        'mistakeQuestionIds': ['q2'],
        'listEdits': {
          'mistakes': {'q1': -(now() + 5000)},
        },
      });
      expect(p.mistakeQuestionIds, ['q2']);
    });

    test(
      'favoritos novos dos dois lados ficam (offline × outro aparelho)',
      () async {
        final p = ProgressService();
        await p.toggleBibleBookmark('gn', 1, 1);
        await p.applyFromCloud({
          'version': 2,
          'bibleBookmarks': ['jo:3:16'],
          'listEdits': {
            'bookmarks': {'jo:3:16': now() - 60000},
          },
        });
        expect(p.bibleBookmarks.toSet(), {'gn:1:1', 'jo:3:16'});
      },
    );

    test('erro novo da 1.0.49 (sem registro) não se perde', () async {
      final p = ProgressService();
      await p.recordMistake('q1');
      await p.clearMistake('q1');
      await p.applyFromCloud({
        'version': 2,
        'mistakeQuestionIds': ['q1', 'q3'],
        'listEdits': {
          'mistakes': {'q1': now() - 5000},
        },
      });
      expect(p.mistakeQuestionIds, ['q3']);
    });

    test('nuvem de app antigo (sem registro) soma como antes', () async {
      final p = ProgressService();
      await p.toggleBibleBookmark('gn', 1, 1);
      await p.applyFromCloud({
        'version': 2,
        'bibleBookmarks': ['jo:3:16'],
      });
      expect(p.bibleBookmarks.toSet(), {'gn:1:1', 'jo:3:16'});
    });

    test(
      'espelho local devolve favorito feito sem rede antes de fechar',
      () async {
        final offline = ProgressService();
        await offline.toggleBibleBookmark('gn', 1, 1);
        final cache = offline.toCloudMap();

        // App reaberto: a nuvem entra primeiro, sem o favorito.
        final p = ProgressService();
        await p.applyFromCloud({
          'version': 2,
          'bibleBookmarks': ['jo:3:16'],
        });
        p.mergeItemListsFromCache(cache);
        expect(p.bibleBookmarks.toSet(), {'gn:1:1', 'jo:3:16'});
        expect(p.listEdits['bookmarks']!.containsKey('gn:1:1'), isTrue);
      },
    );

    test('espelho de antes do reset não volta', () async {
      final offline = ProgressService();
      await offline.toggleBibleBookmark('gn', 1, 1);
      final cache = offline.toCloudMap();
      final p = ProgressService()..progressEpoch = 99;
      p.mergeItemListsFromCache(cache);
      expect(p.bibleBookmarks, isEmpty);
    });

    test('registro com mais de 120 dias sai', () async {
      final p = ProgressService();
      final old = now() - 130 * 86400000;
      await p.applyFromCloud({
        'version': 2,
        'bibleBookmarks': <String>[],
        'listEdits': {
          'bookmarks': {'gn:1:1': -old},
        },
      });
      expect(p.listEdits['bookmarks'], isEmpty);
    });
  });
}
