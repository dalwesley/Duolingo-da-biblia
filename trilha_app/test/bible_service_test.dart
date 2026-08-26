import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/bible_service.dart';

void main() {
  test('looksLikeReference accepts citations and rejects labels', () {
    expect(BibleService.looksLikeReference('Gênesis 1:1–2'), isTrue);
    expect(BibleService.looksLikeReference('Êxodo 3'), isTrue);
    expect(BibleService.looksLikeReference('1 Pedro 2:9'), isTrue);
    expect(BibleService.looksLikeReference('Contexto'), isFalse);
    expect(BibleService.looksLikeReference(''), isFalse);
  });
}
