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

  /// Gradientes por fase — dia claro e vivo, noite profunda.
  static LinearGradient backgroundGradient([DayPhase? phase]) {
    return switch (phase ?? current()) {
      DayPhase.morning => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3D2E7A),
            Color(0xFF6B5CA8),
            Color(0xFF9B7CC8),
            Color(0xFFCF9A6E),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.afternoon => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A3F8C),
            Color(0xFF6C5CE7),
            Color(0xFF8B7CF6),
            Color(0xFF6C5CE7),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.evening => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0814),
            Color(0xFF1A1235),
            Color(0xFF2A1848),
            Color(0xFF3D2040),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.night => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF05040C),
            Color(0xFF0D0B1A),
            Color(0xFF15102A),
            Color(0xFF1A1430),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
    };
  }

  static Color scaffoldBackground([DayPhase? phase]) {
    return switch (phase ?? current()) {
      DayPhase.morning => const Color(0xFF3D2E7A),
      DayPhase.afternoon => const Color(0xFF4A3F8C),
      DayPhase.evening => const Color(0xFF0A0814),
      DayPhase.night => const Color(0xFF05040C),
    };
  }
}
