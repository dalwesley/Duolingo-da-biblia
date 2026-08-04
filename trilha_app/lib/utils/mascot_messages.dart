/// Falas do companheiro — placar e tensão de jogo.
class MascotMessages {
  static String celebration({
    required bool isBoss,
    required int pct,
    bool perfect = false,
    int? leagueRank,
    bool nearPromote = false,
  }) {
    if (perfect) {
      if (nearPromote) return 'Perfeita · quase sobe de caravana.';
      if (leagueRank != null && leagueRank > 0) {
        return 'Perfeita · $leagueRankº na caravana.';
      }
      return 'Combo perfeito · zero lâmpadas perdidas.';
    }
    if (isBoss) {
      return pct >= 80
          ? 'Boss fechado. Placar limpo — segue o mapa.'
          : 'Boss feito. Reforce e suba o placar.';
    }
    if (nearPromote) return 'Quase promove · mais uma missão nesta semana.';
    if (leagueRank != null && leagueRank > 0 && leagueRank <= 7) {
      return '$leagueRankº na caravana · zona de subida.';
    }
    if (pct == 100) return 'Clareza 100% · memória fechada.';
    if (pct >= 70) return '+passos no placar. Volte amanhã.';
    return 'Missão no placar. Reforce o que faltou.';
  }
}
