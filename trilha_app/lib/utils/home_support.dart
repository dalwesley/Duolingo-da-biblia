import 'package:shared_preferences/shared_preferences.dart';

/// Faixa de apoio na Home: no máximo 1× por semana civil (segunda).
/// Quem já apoiou fica [supporterCooldownWeeks] sem ver; depois volta com
/// o convite de retorno.
enum HomeSupportKind {
  /// Primeiro pedido (ainda não é apoiador).
  ask,

  /// Já apoiou antes: "volte a apoiar".
  again,
}

const homeSupportLastShownWeekKey = 'homeSupportLastShownWeek';
const homeSupportLastSupportedAtKey = 'homeSupportLastSupportedAt';

class HomeSupport {
  /// Semanas sem mostrar a faixa depois de um apoio (ou da 1ª detecção
  /// local de apoiador neste aparelho).
  static const supporterCooldownWeeks = 8;

  static const cooldownDays = supporterCooldownWeeks * 7;

  /// Qual copy mostrar hoje, ou null se a faixa deve ficar escondida.
  ///
  /// [thisWeek] e [lastShownWeek] são segundas YYYY-MM-DD (mesmo formato
  /// de [LeagueService.weekKey]). [lastSupportedAt] é o dia em que o
  /// aparelho registrou o último apoio (compra ou 1ª vez que viu o selo).
  static HomeSupportKind? pick({
    required bool storeReady,
    required bool isSupporter,
    required String thisWeek,
    required String? lastShownWeek,
    required DateTime today,
    required DateTime? lastSupportedAt,
  }) {
    if (!storeReady) return null;
    if (lastShownWeek == thisWeek) return null;

    final day = DateTime(today.year, today.month, today.day);
    if (isSupporter) {
      if (lastSupportedAt == null) return null;
      final supported = DateTime(
        lastSupportedAt.year,
        lastSupportedAt.month,
        lastSupportedAt.day,
      );
      if (day.difference(supported).inDays < cooldownDays) return null;
      return HomeSupportKind.again;
    }
    return HomeSupportKind.ask;
  }

  /// Dia (ISO YYYY-MM-DD) do último apoio registrado neste aparelho.
  static Future<DateTime?> loadLastSupportedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(homeSupportLastSupportedAtKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static Future<String?> loadLastShownWeek() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(homeSupportLastShownWeekKey);
  }

  /// Grava o dia do apoio (compra concluída ou 1ª detecção local do selo).
  static Future<void> markSupported([DateTime? at]) async {
    final day = at ?? DateTime.now();
    final iso = DateTime(
      day.year,
      day.month,
      day.day,
    ).toIso8601String().substring(0, 10);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(homeSupportLastSupportedAtKey, iso);
  }

  static Future<void> markShown(String week) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(homeSupportLastShownWeekKey, week);
  }

  /// Laboratório: esquece semana mostrada e data do apoio neste aparelho.
  static Future<void> resetState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(homeSupportLastShownWeekKey);
    await prefs.remove(homeSupportLastSupportedAtKey);
  }
}
