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

  /// Estrelas só quando o céu escurece de verdade.
  static bool showStars([DayPhase? phase]) {
    final p = phase ?? current();
    return p == DayPhase.evening || p == DayPhase.night;
  }

  /// Gradientes por fase — dia vivo, mas escuro o bastante para texto branco.
  static LinearGradient backgroundGradient([DayPhase? phase]) {
    return switch (phase ?? current()) {
      DayPhase.morning => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3A5566),
            Color(0xFF4A6B62),
            Color(0xFF5A6550),
            Color(0xFF4F4638),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.afternoon => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2F5548),
            Color(0xFF3F6B58),
            Color(0xFF5A7558),
            Color(0xFF4A4838),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.evening => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A2430),
            Color(0xFF2A3840),
            Color(0xFF4A4035),
            Color(0xFF6B4A30),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.night => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0C100E),
            Color(0xFF121816),
            Color(0xFF1A221E),
            Color(0xFF1E2A24),
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
