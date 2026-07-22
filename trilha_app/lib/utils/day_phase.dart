import 'package:flutter/material.dart';

enum DayPhase { morning, afternoon, evening, night }

class DayPhaseHelper {
  static DayPhase current() => phaseAt(DateTime.now());

  static DayPhase phaseAt(DateTime time) {
    final h = time.hour;
    if (h >= 5 && h < 12) return DayPhase.morning;
    if (h >= 12 && h < 18) return DayPhase.afternoon;
    if (h >= 18 && h < 22) return DayPhase.evening;
    return DayPhase.night;
  }

  static String greeting([DayPhase? phase]) {
    return switch (phase ?? current()) {
      DayPhase.morning => 'Bom dia',
      DayPhase.afternoon => 'Boa tarde',
      DayPhase.evening => 'Boa noite',
      DayPhase.night => 'Boa noite',
    };
  }

  /// Gradientes por fase — horizonte oceânico; escuro o bastante para texto claro.
  /// Manhã = aurora azul-rosa; tarde = sol alto teal — bem distintos.
  static LinearGradient backgroundGradient([DayPhase? phase]) {
    return switch (phase ?? current()) {
      DayPhase.morning => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E2E52), // azul-hora fria
            Color(0xFF355878),
            Color(0xFF5A6878),
            Color(0xFF6A5040), // chão quente de aurora
          ],
          stops: [0.0, 0.32, 0.62, 1.0],
        ),
      DayPhase.afternoon => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0C3A52), // azul-teal aberto
            Color(0xFF1A5A72),
            Color(0xFF2A7888),
            Color(0xFF1A4858),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.evening => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0C1424),
            Color(0xFF1A2840),
            Color(0xFF3A3048),
            Color(0xFF6A4830),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.night => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF05080E),
            Color(0xFF070B12),
            Color(0xFF0E1620),
            Color(0xFF142030),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
    };
  }

  static Color scaffoldBackground([DayPhase? phase]) {
    return switch (phase ?? current()) {
      DayPhase.morning => const Color(0xFF355878),
      DayPhase.afternoon => const Color(0xFF1A5A72),
      DayPhase.evening => const Color(0xFF141C30),
      DayPhase.night => const Color(0xFF080C14),
    };
  }
}
