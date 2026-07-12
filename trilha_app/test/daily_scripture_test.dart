import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/daily_scripture.dart';

void main() {
  test('today returns a verse tuple', () {
    final verse = DailyScripture.today();
    expect(verse.$1.isNotEmpty, isTrue);
    expect(verse.$2.isNotEmpty, isTrue);
  });
}
