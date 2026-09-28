/// Copy do fim da cena — celebra o passo; ranking vai no cartão da caravana.
class CelebrationCopy {
  /// Lâmpadas acabaram: a cena não fecha — fica como tentativa.
  static const failedKicker = 'Faltou luz';
  static const failedHeadline = 'Tente de novo';
  static const failedDetail =
      'As lâmpadas acabaram antes do fim. A cena espera você — de novo, com calma.';

  static String kicker({
    required bool perfect,
    required bool isReplay,
    required bool isBoss,
  }) {
    if (perfect) return 'Sem erro';
    if (isReplay) return 'Revisão';
    if (isBoss) return 'Travessia final';
    return 'Mais uma cena';
  }

  static String headline({
    required bool perfect,
    required bool isReplay,
    required bool isBoss,
  }) {
    if (perfect) return 'Clareza total';
    if (isReplay) return 'Você voltou ao texto';
    if (isBoss) return 'Travessia concluída';
    return 'Cena concluída';
  }

  static String caravanaTitle({
    required int rank,
    required bool inPromotionZone,
  }) {
    if (!inPromotionZone) return '$rankº na caravana';
    if (rank == 1) return 'Você lidera a caravana';
    return 'Zona de subida';
  }

  static String caravanaDetail({
    required int rank,
    required bool inPromotionZone,
  }) {
    if (!inPromotionZone) {
      return 'Cada cena move a caravana. Continue nesta semana.';
    }
    if (rank == 1) {
      return 'Segure o 1º até o domingo e você avança de caravana.';
    }
    return '$rankº agora · os primeiros sobem no domingo.';
  }
}

/// Falas do companheiro no fim da missão — sobre o passo, não sobre o ranking.
class MascotMessages {
  static String celebration({
    required bool isBoss,
    required int pct,
    bool perfect = false,
    bool isReplay = false,
  }) {
    if (perfect) return 'Nenhuma lâmpada perdida. Isso fica.';
    if (isBoss) {
      return pct >= 80
          ? 'O desafio final ficou para trás. Siga o mapa.'
          : 'Travessia feita. Vale reforçar o que ainda tremeu.';
    }
    if (isReplay) return 'Voltar ao texto fortalece o que já caminhou.';
    if (pct == 100) return 'Tudo claro. Volte amanhã para continuar.';
    if (pct >= 70) return 'Bom passo. A trilha te espera amanhã.';
    return 'Cena feita. Reforce o que faltou — a memória agradece.';
  }
}
