import '../l10n/l10n_global.dart';

/// Copy do fim da cena — celebra o passo; ranking vai no cartão da caravana.
class CelebrationCopy {
  /// Lâmpadas acabaram: a cena não fecha — fica como tentativa.
  static String get failedKicker => L10n.current.mascotFailedKicker;
  static String get failedHeadline => L10n.current.commonTryAgain;
  static String get failedDetail => L10n.current.mascotFailedDetail;

  static String kicker({
    required bool perfect,
    required bool isReplay,
    required bool isBoss,
  }) {
    final l = L10n.current;
    if (perfect) return l.mascotKickerPerfect;
    if (isReplay) return l.mascotKickerReplay;
    if (isBoss) return l.mascotKickerBoss;
    return l.mascotKickerScene;
  }

  static String headline({
    required bool perfect,
    required bool isReplay,
    required bool isBoss,
  }) {
    final l = L10n.current;
    if (perfect) return l.mascotHeadlinePerfect;
    if (isReplay) return l.mascotHeadlineReplay;
    if (isBoss) return l.mascotHeadlineBoss;
    return l.mascotHeadlineScene;
  }

  static String caravanaTitle({
    required int rank,
    required bool inPromotionZone,
  }) {
    final l = L10n.current;
    if (!inPromotionZone) return l.mascotCaravanRank(rank);
    if (rank == 1) return l.mascotCaravanLead;
    return l.mascotCaravanZone;
  }

  static String caravanaDetail({
    required int rank,
    required bool inPromotionZone,
  }) {
    final l = L10n.current;
    if (!inPromotionZone) {
      return l.mascotCaravanDetailOut;
    }
    if (rank == 1) {
      return l.mascotCaravanDetailLead;
    }
    return l.mascotCaravanDetailZone(rank);
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
    final l = L10n.current;
    if (perfect) return l.mascotPerfect;
    if (isBoss) {
      return pct >= 80 ? l.mascotBossHigh : l.mascotBossLow;
    }
    if (isReplay) return l.mascotReplay;
    if (pct == 100) return l.mascotAllClear;
    if (pct >= 70) return l.mascotGood;
    return l.mascotReinforce;
  }
}
