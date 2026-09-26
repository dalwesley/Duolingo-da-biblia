import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/theme/app_theme.dart';

void main() {
  group('AppTypeScale.snap', () {
    test('keeps sizes that are already on the scale', () {
      for (final s in AppTypeScale.title) {
        expect(AppTypeScale.snap(s, AppTypeScale.title), s);
      }
    });

    test('snaps to the nearest step', () {
      expect(AppTypeScale.snap(17, AppTypeScale.title), 16);
      expect(AppTypeScale.snap(23, AppTypeScale.title), 24);
      expect(AppTypeScale.snap(26.5, AppTypeScale.display), 28);
    });

    test('ties go down so layouts never grow', () {
      expect(AppTypeScale.snap(15, AppTypeScale.title), 14);
      expect(AppTypeScale.snap(22, AppTypeScale.display), 20);
      expect(AppTypeScale.snap(26, AppTypeScale.display), 24);
    });

    test('clamps outside the range to the ends', () {
      expect(AppTypeScale.snap(8, AppTypeScale.label), 10);
      expect(AppTypeScale.snap(60, AppTypeScale.display), 48);
    });
  });
}
