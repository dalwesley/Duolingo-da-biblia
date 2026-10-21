import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/plus_access.dart';

void main() {
  test('features stay open when there is no store configured', () {
    expect(
      PlusAccess.featuresOpen(hasPlus: false, storeConfigured: false),
      isTrue,
    );
  });

  test('a configured store closes features without Plus, even offline', () {
    // Oferta vazia/falha de rede não pode liberar tudo (fail-open antigo).
    expect(
      PlusAccess.featuresOpen(hasPlus: false, storeConfigured: true),
      isFalse,
    );
    expect(
      PlusAccess.featuresOpen(hasPlus: true, storeConfigured: true),
      isTrue,
    );
  });

  group('cached entitlement grace', () {
    final now = DateTime(2026, 12, 10);

    test('no cache, no grace', () {
      expect(
        PlusAccess.cachedPlusActive(
          cachedPlus: false,
          expiresAt: now.add(const Duration(days: 30)),
          now: now,
        ),
        isFalse,
      );
    });

    test('lifetime cache never expires', () {
      expect(
        PlusAccess.cachedPlusActive(
          cachedPlus: true,
          expiresAt: null,
          now: now,
        ),
        isTrue,
      );
    });

    test('active until the end date, then 7 grace days', () {
      final end = DateTime(2026, 12, 12);
      expect(
        PlusAccess.cachedPlusActive(cachedPlus: true, expiresAt: end, now: now),
        isTrue,
      );
      expect(
        PlusAccess.cachedPlusActive(
          cachedPlus: true,
          expiresAt: end,
          now: DateTime(2026, 12, 19),
        ),
        isTrue,
      );
      expect(
        PlusAccess.cachedPlusActive(
          cachedPlus: true,
          expiresAt: end,
          now: DateTime(2026, 12, 20),
        ),
        isFalse,
      );
    });
  });

  test('produto do Pioneiro, com ou sem o plano base do Android', () {
    expect(PlusAccess.isPioneerProduct('plus_founder_annual'), isTrue);
    expect(PlusAccess.isPioneerProduct('plus_founder_annual:annual'), isTrue);
    expect(PlusAccess.isPioneerProduct('plus_annual'), isFalse);
    expect(PlusAccess.isPioneerProduct('plus_founder_annual_x'), isFalse);
    expect(PlusAccess.isPioneerProduct(null), isFalse);
  });
}
