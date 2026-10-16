/// Ofertas do Peregrino+ que abrem sozinhas na Home (folha, nunca no meio de
/// uma cena). Cada uma aparece uma vez; no máximo uma por semana.
enum PlusOfferKind {
  /// A promoção de lançamento acabou.
  promoEnded,

  /// Faltam 7 dias ou menos para a promoção acabar.
  promoEndingSoon,

  /// 7 cenas novas feitas, fora da promoção.
  sevenScenes;

  /// Origem no analytics do paywall.
  String get source => switch (this) {
    PlusOfferKind.promoEnded => 'promo_ended',
    PlusOfferKind.promoEndingSoon => 'promo_ending',
    PlusOfferKind.sevenScenes => 'seven_scenes',
  };
}

class PlusOffers {
  static const scenesForOffer = 7;
  static const endingSoonDays = 7;

  /// Qual oferta mostrar hoje, ou null.
  ///
  /// [promoUntil] é o último dia da promoção no Remote Config (mesmo que já
  /// tenha passado). [shown] são as ofertas já vistas; [lastOfferWeek] e
  /// [thisWeek] são segundas YYYY-MM-DD.
  static PlusOfferKind? pick({
    required DateTime today,
    required bool paid,
    required bool storeReady,
    required int scenesDone,
    required DateTime? promoUntil,
    required Set<String> shown,
    required String? lastOfferWeek,
    required String thisWeek,
  }) {
    if (paid || !storeReady) return null;
    if (lastOfferWeek == thisWeek) return null;
    final day = DateTime(today.year, today.month, today.day);
    bool fresh(PlusOfferKind k) => !shown.contains(k.name);

    if (promoUntil != null) {
      if (day.isAfter(promoUntil)) {
        if (fresh(PlusOfferKind.promoEnded)) return PlusOfferKind.promoEnded;
      } else {
        final left = promoUntil.difference(day).inDays;
        if (left <= endingSoonDays && fresh(PlusOfferKind.promoEndingSoon)) {
          return PlusOfferKind.promoEndingSoon;
        }
        // Durante a promoção todo mundo tem o Plus: nada a oferecer.
        return null;
      }
    }
    if (scenesDone >= scenesForOffer && fresh(PlusOfferKind.sevenScenes)) {
      return PlusOfferKind.sevenScenes;
    }
    return null;
  }
}
