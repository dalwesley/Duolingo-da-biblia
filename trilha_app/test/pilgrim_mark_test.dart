import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/widgets/pilgrim_mark.dart';

void main() {
  group('PilgrimMarkSpec', () {
    test('same seed always yields same palette and pose', () {
      const seed = 'uid-joao-1';
      final a = PilgrimMarkSpec.fromSeed(seed);
      final b = PilgrimMarkSpec.fromSeed(seed);
      expect(a.pose, b.pose);
      expect(a.cloak, b.cloak);
      expect(a.skin, b.skin);
    });

    test('trims and ignores case', () {
      final a = PilgrimMarkSpec.fromSeed('Maria');
      final b = PilgrimMarkSpec.fromSeed('  MARIA  ');
      expect(a.pose, b.pose);
      expect(a.cloak, b.cloak);
    });

    test('different people can get different marks', () {
      final a = PilgrimMarkSpec.fromSeed('uid-a');
      final b = PilgrimMarkSpec.fromSeed('uid-b');
      expect(
        a.pose != b.pose || a.cloak != b.cloak || a.skin != b.skin,
        isTrue,
      );
    });

    test('empty seed is safe', () {
      final spec = PilgrimMarkSpec.fromSeed('');
      expect(spec.pose, inInclusiveRange(0, PilgrimMarkSpec.poseCount - 1));
    });
  });
}
