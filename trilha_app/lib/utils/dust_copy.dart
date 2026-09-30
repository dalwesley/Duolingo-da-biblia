import '../l10n/l10n_global.dart';

/// Copy de sequência em risco — calmo, no mundo do caminho: o que está em
/// risco, quanto tempo falta, o que fazer. Sem poeira nem perseguição.
class DustCopy {
  DustCopy._();

  static int get _tick =>
      DateTime.now().day * 17 + DateTime.now().hour * 3;

  // ── Notificações: título curto (cabe na bandeja) ─────────────────────────

  static String atRiskTitle({bool lateEvening = false}) {
    final l = L10n.current;
    if (lateEvening) {
      return _pick([
        l.dustDayEnding,
        l.dustStillTime,
        l.dustStreakWaits,
      ]);
    }
    final hour = DateTime.now().hour;
    if (hour < 14) {
      return _pick([
        l.dustSceneToday,
        l.dustTrailWaits,
        l.homeMoodDusty,
      ]);
    }
    return _pick([
      l.homeMoodDusty,
      l.dustFewHours,
      l.dustSceneTodayWaits,
    ]);
  }

  static String atRiskBody({
    required String name,
    required String countdown,
    required bool hasFreeze,
    required int streak,
  }) {
    final l = L10n.current;
    if (hasFreeze) {
      return _pick([
        l.dustRiskBodyFreeze1(name, countdown),
        l.dustRiskBodyStreak(streak, countdown),
        l.dustRiskBodyFreeze3(countdown),
      ]);
    }
    return _pick([
      l.dustRiskBodyNoFreeze1(name, countdown),
      l.dustRiskBodyNoFreeze2(streak, countdown),
      l.dustRiskBodyNoFreeze3(countdown),
    ]);
  }

  static String eveningSoftBody({
    required String name,
    required String countdown,
    required bool hasFreeze,
  }) {
    final l = L10n.current;
    if (hasFreeze) {
      return _pick([
        l.dustEveningFreeze1(name, countdown),
        l.dustEveningFreeze2(countdown),
      ]);
    }
    return _pick([
      l.dustRiskBodyNoFreeze1(name, countdown),
      l.dustEveningNoFreeze2(countdown),
    ]);
  }

  static String lostAwayTitle({required int daysAway}) {
    final l = L10n.current;
    if (daysAway >= 3) {
      return _pick([
        l.dustTrailWaits,
        l.dustContinueWhere,
        l.dustNextSceneWaits,
      ]);
    }
    if (daysAway >= 2) {
      return _pick([
        l.dustTwoDays,
        l.dustCanReturn,
        l.dustComeBackToday,
      ]);
    }
    return _pick([
      l.dustOneDay,
      l.dustSceneWaits,
      l.dustComeBackToday,
    ]);
  }

  static String lostAwayBody({
    required String name,
    required int streak,
    required int daysAway,
    required bool hasFreeze,
  }) {
    final l = L10n.current;
    if (daysAway >= 3) {
      return hasFreeze
          ? l.dustAwayManyFreeze(name, daysAway)
          : l.dustAwayManyNoFreeze(name, daysAway);
    }
    if (daysAway >= 2) {
      return hasFreeze
          ? l.dustAwayTwoFreeze(name)
          : l.dustAwayTwoNoFreeze(name);
    }
    return streak > 0
        ? l.dustAwayStreak(name, streak)
        : l.dustAwayNoStreak(name);
  }

  // ── UI in-app (curto, sob o card / marcos) ───────────────────────────────

  static String uiRiskLine({required bool hasFreeze}) {
    final l = L10n.current;
    if (hasFreeze) {
      return _pick([
        l.dustUiFreeze1,
        l.dustUiFreeze2,
        l.dustUiFreeze3,
      ]);
    }
    return _pick([
      l.dustUiNoFreeze1,
      l.dustUiNoFreeze2,
      l.dustUiNoFreeze3,
    ]);
  }

  static String uiRiskDetail() {
    final l = L10n.current;
    return _pick([
      l.dustUiNoFreeze1,
      l.dustUiDetail2,
      l.dustUiDetail3,
    ]);
  }

  /// Linha do hero card (com countdown). Uma frase: o que acaba, quando, o que fazer.
  static String heroRiskLine({
    required String countdown,
    required bool hasFreeze,
    int streak = 0,
  }) {
    final l = L10n.current;
    // ≤1 dia: "a sequência" sem número (o plural =0/=1 cobre).
    final n = streak < 0 ? 0 : streak;
    if (hasFreeze) {
      return l.dustHeroRiskFreeze(n, countdown);
    }
    return l.dustHeroRiskNoFreeze(n, countdown);
  }

  /// Buraco já aberto (ontem vazio). Gelo da semana não cobre de novo.
  static String heroGapLine({required bool hasFreeze}) {
    final l = L10n.current;
    if (hasFreeze) {
      return l.dustHeroGapFreeze;
    }
    return l.dustHeroGapNoFreeze;
  }

  static String _pick(List<String> options) {
    if (options.isEmpty) return '';
    return options[_tick.abs() % options.length];
  }
}
