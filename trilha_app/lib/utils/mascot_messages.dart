/// Copy do fim da missão — celebra o passo; ranking vai no cartão da caravana.
class CelebrationCopy {
  static String kicker({
    required bool perfect,
    required bool isReplay,
    required bool isBoss,
  }) {
    if (perfect) return 'SEM ERRO';
    if (isReplay) return 'DE NOVO NO TEXTO';
    if (isBoss) return 'O PASSO MAIOR';
    return 'MAIS UM PASSO';
  }

  static String headline({
    required bool perfect,
    required bool isReplay,
    required bool isBoss,
  }) {
    if (perfect) return 'Clareza total';
    if (isReplay) return 'Memória reforçada';
    if (isBoss) return 'Boss vencido';
    return 'Missão cumprida';
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
      return 'Cada missão move o grupo. Continue nesta semana.';
    }
    if (rank == 1) {
      return 'Segure o 1º até o domingo e você avança de caravana.';
    }
    return '$rankº agora · os 7 primeiros sobem no domingo.';
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
          ? 'O passo maior ficou pra trás. Segue o mapa.'
          : 'Boss feito. Vale reforçar o que ainda tremeu.';
    }
    if (isReplay) return 'Voltar ao texto fortalece o que já caminhou.';
    if (pct == 100) return 'Tudo claro. Volte amanhã para não perder o fio.';
    if (pct >= 70) return 'Bom passo. A trilha te espera amanhã.';
    return 'Missão feita. Reforce o que faltou — a memória agradece.';
  }
}
