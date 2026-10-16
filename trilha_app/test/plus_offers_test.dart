import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/plus_offers.dart';

void main() {
  PlusOfferKind? pick({
    DateTime? today,
    bool paid = false,
    bool storeReady = true,
    int scenes = 0,
    DateTime? promoUntil,
    Set<String> shown = const {},
    String? lastWeek,
  }) => PlusOffers.pick(
    today: today ?? DateTime(2026, 12, 1),
    paid: paid,
    storeReady: storeReady,
    scenesDone: scenes,
    promoUntil: promoUntil,
    shown: shown,
    lastOfferWeek: lastWeek,
    thisWeek: '2026-11-30',
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

  test('after the promo: ended notice first, then seven scenes', () {
    final until = DateTime(2026, 11, 20);
    expect(pick(scenes: 9, promoUntil: until), PlusOfferKind.promoEnded);
    expect(
      pick(scenes: 9, promoUntil: until, shown: {'promoEnded'}),
      PlusOfferKind.sevenScenes,
    );
  });
}
