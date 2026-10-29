import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/data/bible_canonical_groups.dart';
import 'package:trilha_app/services/backend_service.dart';
import 'package:trilha_app/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Instrumentação de domínio (acerto por trilha)', () {
    test('acumula por trilha junto do modo.gesto', () {
      final p = ProgressService();
      p.recordAnswer(
        mode: 'semente',
        type: 'tap',
        correct: true,
        trailSlug: 'genesis-1-11',
      );
      p.recordAnswer(
        mode: 'semente',
        type: 'choice',
        correct: false,
        trailSlug: 'genesis-1-11',
      );
      p.recordAnswer(
        mode: 'caminhada',
        type: 'tap',
        correct: true,
        trailSlug: 'mateus',
      );

      expect(p.trailAnswerTotal['genesis-1-11'], 2);
      expect(p.trailAnswerCorrect['genesis-1-11'], 1);
      expect(p.trailAccuracyPercent('genesis-1-11'), 50);
      expect(p.trailAccuracyPercent('mateus'), 100);
      // O mapa antigo continua igual.
      expect(p.answerTotal['semente.tap'], 1);
    });

    test('sem trilha, só o modo.gesto é alimentado', () {
      final p = ProgressService();
      p.recordAnswer(mode: 'semente', type: 'tap', correct: true);
      expect(p.trailAnswerTotal, isEmpty);
      expect(p.trailAccuracyPercent('genesis-1-11'), isNull);
    });

    test('viaja no payload (payload → restauração)', () {
      final p = ProgressService();
      p.recordAnswer(
        mode: 'semente',
        type: 'tap',
        correct: true,
        trailSlug: 'genesis-1-11',
      );
      final payload = p.toCloudMap();
      expect(payload['trailAnswerTotal'], {'genesis-1-11': 1});
      expect(payload['trailAnswerCorrect'], {'genesis-1-11': 1});
    });
  });
  group('Seu mapa (acerto por grupo canônico)', () {
    test('acumula por grupo.modo e viaja no payload', () {
      final p = ProgressService();
      p.recordDomainAnswer(group: 'pentateuco', mode: 'semente', correct: true);
      p.recordDomainAnswer(
        group: 'pentateuco',
        mode: 'semente',
        correct: false,
      );
      p.recordDomainAnswer(
        group: 'evangelhos',
        mode: 'caminhada',
        correct: true,
      );
      expect(p.domainAnswerTotal['pentateuco.semente'], 2);
      expect(p.domainAnswerCorrect['pentateuco.semente'], 1);
      final payload = p.toCloudMap();
      expect(payload['domainAnswerTotal'], {
        'pentateuco.semente': 2,
        'evangelhos.caminhada': 1,
      });
    });

    test('recomeçar a trilha não apaga o mapa', () async {
      final p = ProgressService();
      p.recordAnswer(
        mode: 'semente',
        type: 'tap',
        correct: true,
        trailSlug: 'genesis-1-11',
      );
      p.recordDomainAnswer(group: 'pentateuco', mode: 'semente', correct: true);
      await p.leaveTrail(trailSlug: 'genesis-1-11', missionSlugs: const []);
      expect(p.trailAnswerTotal, isEmpty);
      expect(p.domainAnswerTotal['pentateuco.semente'], 1);
    });

    test('livro cai no grupo certo', () {
      expect(BibleCanonicalGroups.ofBook(0)?.id, 'pentateuco');
      expect(BibleCanonicalGroups.ofBook(39)?.id, 'evangelhos');
      expect(BibleCanonicalGroups.ofBook(43)?.id, 'historia-nt');
      expect(BibleCanonicalGroups.ofBook(65)?.id, 'profecia');
      expect(BibleCanonicalGroups.ofBook(66), isNull);
    });

    test('acerto por trilha e por grupo ficam no doc privado', () {
      final split = BackendService.splitPayload({
        'trailAnswerCorrect': {'genesis-1-11': 1},
        'trailAnswerTotal': {'genesis-1-11': 1},
        'domainAnswerCorrect': {'pentateuco.semente': 1},
        'domainAnswerTotal': {'pentateuco.semente': 1},
      });
      expect(split.public, isEmpty);
      expect(split.private.keys, hasLength(4));
    });
  });
}
