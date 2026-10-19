import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/bible_reading_plan.dart';

BibleReadingPlan _plan({
  required int completedDays,
  String? lastDay,
  String? guidedId,
}) => BibleReadingPlan(
  active: true,
  order: BibleReadingOrder.canonical,
  minutesPerDay: 10,
  cursor: 0,
  lastCompletedDay: lastDay,
  completedDays: completedDays,
  startedAt: '2026-10-01',
  guidedId: guidedId,
);

void main() {
  final today = DateTime.now().toIso8601String().substring(0, 10);

  test('the whole Bible plan never locks', () {
    for (final d in [0, 3, 50]) {
      expect(_plan(completedDays: d).lockedToday(plusOpen: false), isFalse);
    }
  });

  test('a guided plan without Plus locks from day one', () {
    final plan = _plan(completedDays: 0, guidedId: 'evangelhos-30');
    expect(plan.lockedToday(plusOpen: false), isTrue);
    expect(plan.lockedToday(plusOpen: true), isFalse);
  });

  test('a guided day already read today is not locked', () {
    final plan = _plan(
      completedDays: 5,
      lastDay: today,
      guidedId: 'evangelhos-30',
    );
    expect(plan.lockedToday(plusOpen: false), isFalse);
  });

  test('an inactive plan never locks', () {
    expect(BibleReadingPlan.inactive.lockedToday(plusOpen: false), isFalse);
  });

  test('plans saved before the reset load as inactive', () {
    final old = _plan(completedDays: 1).toMap()..remove('v');
    expect(BibleReadingPlan.fromMap(old).active, isFalse);
    final current = _plan(completedDays: 1).toMap();
    expect(BibleReadingPlan.fromMap(current).active, isTrue);
  });
}
