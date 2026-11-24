import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/store_rating_pace.dart';

bool _ask({
  int scenes = 10,
  int days = 5,
  int correct = 9,
  int total = 10,
  bool perfect = false,
  bool rated = false,
  int declines = 0,
  int? lastShownMs,
  DateTime? now,
}) => StoreRatingPace.shouldAsk(
  now: now ?? DateTime(2026, 11, 23),
  scenesDone: scenes,
  accountAgeDays: days,
  correct: correct,
  total: total,
  perfect: perfect,
  rated: rated,
  declines: declines,
  lastShownMs: lastShownMs,
);

void main() {
  test('good scene after enough use asks', () => expect(_ask(), isTrue));
  test('too few scenes or too new does not ask', () {
    expect(_ask(scenes: 4), isFalse);
    expect(_ask(days: 1), isFalse);
  });
  test('weak scene does not ask, perfect does', () {
    expect(_ask(correct: 6, total: 10), isFalse);
    expect(_ask(correct: 0, total: 0, perfect: true), isTrue);
  });
  test('stops after rating or max declines', () {
    expect(_ask(rated: true), isFalse);
    expect(_ask(declines: StoreRatingPace.maxDeclines), isFalse);
  });
  test('respects gap since last ask', () {
    final now = DateTime(2026, 11, 23);
    final recent = now.subtract(const Duration(days: 10));
    final old = now.subtract(const Duration(days: 22));
    expect(_ask(now: now, lastShownMs: recent.millisecondsSinceEpoch), isFalse);
    expect(_ask(now: now, lastShownMs: old.millisecondsSinceEpoch), isTrue);
  });
}
