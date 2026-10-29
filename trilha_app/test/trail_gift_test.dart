import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/trail_gift.dart';

void main() {
  test('mês do passe em UTC, igual à regra', () {
    expect(TrailGift.monthKey(DateTime.utc(2026, 3, 31, 23)), '2026-03');
    expect(TrailGift.monthKey(DateTime.utc(2026, 11, 1)), '2026-11');
  });

  test('código de 8 letras sem 0/O/1/I, aceito pela regra', () {
    final code = TrailGift.newCode(Random(7));
    expect(code, matches(RegExp(r'^[A-Z0-9]{8}$')));
    expect(code, isNot(matches(RegExp('[01OI]'))));
  });

  test('passe resgatado guarda o nome de quem recebeu', () {
    final open = TrailGift.fromMap('AB23CD45', {
      'fromUid': 'u1',
      'fromName': 'Ana',
      'trailSlug': 'oracao',
    })!;
    expect(open.redeemed, isFalse);
    final taken = TrailGift.fromMap('AB23CD45', {
      'fromUid': 'u1',
      'fromName': 'Ana',
      'trailSlug': 'oracao',
      'toUid': 'u2',
      'toName': 'Bia',
    })!;
    expect(taken.redeemed, isTrue);
    expect(taken.toName, 'Bia');
    expect(TrailGift.fromMap('X', {'fromUid': 'u1'}), isNull);
  });
}
