import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
}
