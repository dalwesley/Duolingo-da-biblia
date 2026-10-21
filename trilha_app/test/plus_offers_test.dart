import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/plus_offers.dart';

void main() {
  PlusOfferKind? pick({
    DateTime? today,
    bool paid = false,
    bool storeReady = true,
    int scenes = 0,
    int age = 10,
    DateTime? promoUntil,
    Set<String> shown = const {},
    String? lastWeek,
    DateTime? plusEndedAt,
  }) => PlusOffers.pick(
    today: today ?? DateTime(2026, 12, 1),
    paid: paid,
    storeReady: storeReady,
    scenesDone: scenes,
    accountAgeDays: age,
    promoUntil: promoUntil,
    shown: shown,
    lastOfferWeek: lastWeek,
    thisWeek: '2026-11-30',
    plusEndedAt: plusEndedAt,
  );

  test('never for payers, without a store, or twice in a week', () {
    expect(pick(scenes: 9, paid: true), isNull);
    expect(pick(scenes: 9, storeReady: false), isNull);
    expect(pick(scenes: 9, lastWeek: '2026-11-30'), isNull);
    expect(pick(scenes: 9), PlusOfferKind.sevenScenes);
  });

  test('seven scenes shows once', () {
    expect(pick(scenes: 6), isNull);
    expect(pick(scenes: 7, shown: {'sevenScenes'}), isNull);
  });

  test('seven scenes in a day-one marathon does not offer yet', () {
    expect(pick(scenes: 9, age: 0), isNull);
    expect(pick(scenes: 9, age: 1), isNull);
    expect(
      pick(scenes: 9, age: PlusOffers.minAccountAgeDays),
      PlusOfferKind.sevenScenes,
    );
  });

  test('promo notices ignore account age (they are calendar-driven)', () {
    final until = DateTime(2026, 11, 20);
    expect(
      pick(scenes: 9, age: 0, promoUntil: until),
      PlusOfferKind.promoEnded,
    );
  });

  test('during the promo only the ending notice, in its last 7 days', () {
    final until = DateTime(2026, 12, 20);
    expect(pick(scenes: 9, promoUntil: until), isNull);
    expect(
      pick(scenes: 9, promoUntil: until, today: DateTime(2026, 12, 14)),
      PlusOfferKind.promoEndingSoon,
    );
    expect(
      pick(
        scenes: 9,
        promoUntil: until,
        today: DateTime(2026, 12, 14),
        shown: {'promoEndingSoon'},
      ),
      isNull,
    );
  });

  test('winback: two weeks after the Plus ended, then near a year', () {
    final ended = DateTime(2026, 11, 1);
    expect(pick(plusEndedAt: ended, today: DateTime(2026, 11, 10)), isNull);
    expect(
      pick(plusEndedAt: ended, today: DateTime(2026, 11, 20)),
      PlusOfferKind.winbackEarly,
    );
    expect(
      pick(
        plusEndedAt: ended,
        today: DateTime(2026, 11, 20),
        shown: {'winbackEarly'},
        scenes: 9,
      ),
      PlusOfferKind.sevenScenes,
    );
    expect(
      pick(plusEndedAt: ended, today: DateTime(2027, 11, 20)),
      PlusOfferKind.winbackLate,
    );
    // Depois da tardia, a cedo não volta com papo de "2 semanas".
    expect(
      pick(
        plusEndedAt: ended,
        today: DateTime(2027, 11, 27),
        shown: {'winbackLate'},
      ),
      isNull,
    );
    expect(pick(plusEndedAt: ended, paid: true), isNull);
  });

  test('after the promo: ended notice first, then seven scenes', () {
    final until = DateTime(2026, 11, 20);
    expect(pick(scenes: 9, promoUntil: until), PlusOfferKind.promoEnded);
    expect(
      pick(scenes: 9, promoUntil: until, shown: {'promoEnded'}),
      PlusOfferKind.sevenScenes,
    );
  });
}
