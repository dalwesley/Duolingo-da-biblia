import 'package:shared_preferences/shared_preferences.dart';

/// Ritmo do convite para avaliar na loja (folha da Anan após uma cena boa).
///
/// Regras: só depois de [minScenes] cenas e [minAccountDays] dias de uso;
/// [gapDays] entre convites; para de vez depois de ir à loja ou de
/// [maxDeclines] "Agora não". O convite é neutro (não pergunta se gosta):
/// a Play proíbe filtrar quem vai à loja pela opinião.
class StoreRatingPace {
  StoreRatingPace._();

  static const minScenes = 5;
  static const minAccountDays = 2;
  static const gapDays = 21;
  static const maxDeclines = 3;
  static const goodRatio = 0.8;

  static const _keyLastShown = 'store_rating_last_shown_ms';
  static const _keyDeclines = 'store_rating_declines';
  static const _keyRated = 'store_rating_rated';

  /// Decisão pura (testável).
  static bool shouldAsk({
    required DateTime now,
    required int scenesDone,
    required int accountAgeDays,
    required int correct,
    required int total,
    required bool perfect,
    required bool rated,
    required int declines,
    required int? lastShownMs,
  }) {
    if (rated || declines >= maxDeclines) return false;
    if (scenesDone < minScenes || accountAgeDays < minAccountDays) {
      return false;
    }
    final good = perfect || (total > 0 && correct / total >= goodRatio);
    if (!good) return false;
    if (lastShownMs != null) {
      final last = DateTime.fromMillisecondsSinceEpoch(lastShownMs);
      if (now.difference(last).inDays < gapDays) return false;
    }
    return true;
  }

  static Future<bool> load({
    required DateTime now,
    required int scenesDone,
    required int accountAgeDays,
    required int correct,
    required int total,
    required bool perfect,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return shouldAsk(
      now: now,
      scenesDone: scenesDone,
      accountAgeDays: accountAgeDays,
      correct: correct,
      total: total,
      perfect: perfect,
      rated: prefs.getBool(_keyRated) ?? false,
      declines: prefs.getInt(_keyDeclines) ?? 0,
      lastShownMs: prefs.getInt(_keyLastShown),
    );
  }

  static Future<void> markShown(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastShown, now.millisecondsSinceEpoch);
  }

  static Future<void> markDeclined() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDeclines, (prefs.getInt(_keyDeclines) ?? 0) + 1);
  }

  static Future<void> markRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRated, true);
  }

  /// Laboratório.
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastShown);
    await prefs.remove(_keyDeclines);
    await prefs.remove(_keyRated);
  }
}
