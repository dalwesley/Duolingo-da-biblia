import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/trail.dart';
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

  test('id base ignora o plano base do Android', () {
    expect(PlusAccess.baseProductId('plus_annual:annual'), 'plus_annual');
    expect(PlusAccess.baseProductId('plus_annual'), 'plus_annual');
  });

  group('Plus de quem libera a cena (doc público)', () {
    final now = DateTime(2026, 11, 10);

    test('sem doc ou sem plusActive não libera', () {
      expect(PlusAccess.profileHasPlus(null, now: now), isFalse);
      expect(PlusAccess.profileHasPlus({}, now: now), isFalse);
      expect(
        PlusAccess.profileHasPlus({'plusActive': false}, now: now),
        isFalse,
      );
    });

    test('plusActive sem data de fim libera', () {
      expect(PlusAccess.profileHasPlus({'plusActive': true}, now: now), isTrue);
    });

    test('plusActive atrasado não vale depois do fim + graça', () {
      Map<String, dynamic> doc(String end) => {
        'plusActive': true,
        'plusExpiresAt': end,
      };
      expect(
        PlusAccess.profileHasPlus(doc('2026-11-05T12:00:00.000Z'), now: now),
        isTrue,
      );
      expect(
        PlusAccess.profileHasPlus(doc('2026-11-01T12:00:00.000Z'), now: now),
        isFalse,
      );
    });
  });

  test('trilha que espera outra paga vira porta do Plus', () {
    Trail make(String slug, String realm, String category) => Trail(
      slug: slug,
      title: slug,
      description: '',
      icon: '',
      order: 1,
      comingSoon: false,
      color: '#000000',
      realmId: realm,
      categoryId: category,
      modules: const [],
    );
    final prayer = make('oracao', 'vida-crista', 'oracao');
    final fasting = make('jejum', 'vida-crista', 'oracao');
    final genesis = make('genesis-1-11', 'antigo-testamento', 'pentateuco');
    final exodus = make('exodo', 'antigo-testamento', 'pentateuco');

    expect(PlusAccess.waitsOnPlus(fasting, prayer), isTrue);
    // Bíblia grátis: o livro anterior termina sem Plus.
    expect(PlusAccess.waitsOnPlus(exodus, genesis), isFalse);
    expect(PlusAccess.waitsOnPlus(fasting, null), isFalse);
  });

  test('passe de trilha abre a trilha do Plus só para quem recebeu', () {
    Trail make(String slug) => Trail(
      slug: slug,
      title: slug,
      description: '',
      icon: '',
      order: 1,
      comingSoon: false,
      color: '#000000',
      realmId: 'vida-crista',
      categoryId: 'oracao',
      modules: const [],
    );
    final prayer = make('oracao');
    final fasting = make('jejum');
    addTearDown(() => PlusAccess.giftedTrails = const {});

    PlusAccess.giftedTrails = {'oracao'};
    expect(PlusAccess.trailInPlus(prayer), isTrue);
    expect(PlusAccess.trailIsPlus(prayer), isFalse);
    expect(PlusAccess.missionNeedsPlus(prayer, 'qualquer'), isFalse);
    expect(PlusAccess.trailIsPlus(fasting), isTrue);
    // Jejum espera Oração, que agora termina sem o Plus.
    expect(PlusAccess.waitsOnPlus(fasting, prayer), isFalse);
  });
}
