import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/backend_service.dart';

void main() {
  test('personal fields go private; public keeps profile data + summaries', () {
    final split = BackendService.splitPayload({
      'userName': 'Ana',
      'steps': 10,
      'completedMissions': ['a'],
      'email': 'ana@x.com',
      'activeRoomCode': 'ABC123',
      'companionCodes': ['XYZ'],
      'missionReflections': {'a': 'texto', 'b': 'outro'},
      'mistakeQuestionIds': ['q1'],
      'settings': {'portraitStyle': 'photo', 'sound': true},
    });
    expect(
      split.public.keys,
      containsAll(['userName', 'steps', 'completedMissions']),
    );
    for (final k in [
      'email',
      'activeRoomCode',
      'companionCodes',
      'missionReflections',
      'mistakeQuestionIds',
      'settings',
    ]) {
      expect(split.public.containsKey(k), isFalse, reason: k);
      expect(split.private.containsKey(k), isTrue, reason: k);
    }
    expect(split.public['reflectionCount'], 2);
    expect(split.public['portraitStyle'], 'photo');
  });
}
