/// Ofertas do Peregrino+ que abrem sozinhas na Home (folha, nunca no meio de
/// uma cena). Cada uma aparece uma vez; no máximo uma por semana.
enum PlusOfferKind {
  /// A promoção de lançamento acabou.
  promoEnded,

  /// Faltam 7 dias ou menos para a promoção acabar.
  promoEndingSoon,

  /// 7 cenas novas feitas, fora da promoção.
  sevenScenes,

  /// O Peregrino+ acabou há 2+ semanas: convite de retorno.
  winbackEarly,

  /// O Peregrino+ acabou há quase um ano: último convite de retorno.
  winbackLate;

  /// Origem no analytics do paywall.
  String get source => switch (this) {
    PlusOfferKind.promoEnded => 'promo_ended',
    PlusOfferKind.promoEndingSoon => 'promo_ending',
    PlusOfferKind.sevenScenes => 'seven_scenes',
    PlusOfferKind.winbackEarly => 'winback_early',
    PlusOfferKind.winbackLate => 'winback_late',
  };
}

class PlusOffers {
  static const scenesForOffer = 7;
  static const endingSoonDays = 7;

  /// A oferta das 7 cenas só depois que a pessoa voltou outro dia:
  /// maratona no dia 1 não é hábito, e o paywall ali custa retenção.
  static const minAccountAgeDays = 2;

  /// Retorno: 2 semanas depois que o Plus acabou, e de novo perto de 1 ano.
  static const winbackEarlyDays = 14;
  static const winbackLateDays = 330;

  /// Qual oferta mostrar hoje, ou null.
  ///
  /// [promoUntil] é o último dia da promoção no Remote Config (mesmo que já
  /// tenha passado). [shown] são as ofertas já vistas; [lastOfferWeek] e
  /// [thisWeek] são segundas YYYY-MM-DD. [accountAgeDays] são os dias desde
  /// a primeira abertura (0 = hoje) — só a oferta das 7 cenas olha para ele;
  /// os avisos da promoção são do calendário, não do comportamento.
  static PlusOfferKind? pick({
    required DateTime today,
    required bool paid,
    required bool storeReady,
    required int scenesDone,
    required int accountAgeDays,
    required DateTime? promoUntil,
    required Set<String> shown,
    required String? lastOfferWeek,
    required String thisWeek,
    DateTime? plusEndedAt,
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
    // Quem já foi assinante recebe o convite de retorno antes da oferta
    // genérica: semana 2 depois do fim, e de novo perto de um ano.
    if (plusEndedAt != null) {
      final endDay = DateTime(
        plusEndedAt.year,
        plusEndedAt.month,
        plusEndedAt.day,
      );
      final since = day.difference(endDay).inDays;
      if (since >= winbackLateDays && fresh(PlusOfferKind.winbackLate)) {
        return PlusOfferKind.winbackLate;
      }
      // A janela cedo fecha quando a tardia abre: nada de "faz 2 semanas"
      // depois do convite de "quase um ano".
      if (since >= winbackEarlyDays &&
          since < winbackLateDays &&
          fresh(PlusOfferKind.winbackEarly)) {
        return PlusOfferKind.winbackEarly;
      }
    }
    if (scenesDone >= scenesForOffer &&
        accountAgeDays >= minAccountAgeDays &&
        fresh(PlusOfferKind.sevenScenes)) {
      return PlusOfferKind.sevenScenes;
    }
    return null;
  }
}
