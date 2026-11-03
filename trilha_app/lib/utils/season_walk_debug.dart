import 'package:flutter/foundation.dart';

/// Relógio da Caminhada sazonal — só em [kDebugMode], via Laboratório.
///
/// Sem override, [today] é o dia civil real. Com override, home, card e
/// calendário usam a data simulada (ex.: pré-Advento para ver o card).
class SeasonWalkDebug {
  SeasonWalkDebug._();

  static DateTime? _today;

  static bool get active => kDebugMode && _today != null;

  static DateTime? get overrideToday => _today;

  /// Dia civil da Caminhada (ano-mês-dia, sem hora).
  static DateTime today([DateTime? fallback]) {
    if (kDebugMode && _today != null) return _today!;
    final n = fallback ?? DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static void bind(DateTime? day) {
    if (!kDebugMode) return;
    _today = day == null ? null : DateTime(day.year, day.month, day.day);
  }

  static int? _crowd;

  /// Laboratório: quantos peregrinos fingir na folha da Estação (`null` =
  /// os de verdade). Só nesta sessão.
  static int? get crowd => kDebugMode ? _crowd : null;

  static void bindCrowd(int? count) {
    if (!kDebugMode) return;
    _crowd = count;
  }
}
