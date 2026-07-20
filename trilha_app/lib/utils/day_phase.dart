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

  /// Gradientes por fase — floresta fria; escuro o bastante para texto claro.
  static LinearGradient backgroundGradient([DayPhase? phase]) {
    return switch (phase ?? current()) {
      DayPhase.morning => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2A4450),
            Color(0xFF345850),
            Color(0xFF3D5248),
            Color(0xFF3A3830),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.afternoon => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF243F36),
            Color(0xFF2F5548),
            Color(0xFF3D5A48),
            Color(0xFF383830),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.evening => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF141C24),
            Color(0xFF1E2A30),
            Color(0xFF3A3228),
            Color(0xFF5A3E28),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.night => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0E0C),
            Color(0xFF0E1210),
            Color(0xFF161C19),
            Color(0xFF1A2420),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
    };
  }

  static Color scaffoldBackground([DayPhase? phase]) {
    return switch (phase ?? current()) {
      DayPhase.morning => const Color(0xFF3A5566),
      DayPhase.afternoon => const Color(0xFF2F5548),
      DayPhase.evening => const Color(0xFF1A2430),
      DayPhase.night => const Color(0xFF0C100E),
    };
  }
}
