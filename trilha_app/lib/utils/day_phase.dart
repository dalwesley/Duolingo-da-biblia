import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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

  /// Céus do caminho — aurora / sol alto / crepúsculo / tinta.
  static LinearGradient backgroundGradient([DayPhase? phase]) {
    return switch (phase ?? current()) {
      DayPhase.morning => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A3058),
            Color(0xFF3A6088),
            Color(0xFF6A7888),
            Color(0xFF8A6848),
          ],
          stops: [0.0, 0.32, 0.62, 1.0],
        ),
      DayPhase.afternoon => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0C3A58),
            Color(0xFF1A6A88),
            Color(0xFF2A8898),
            Color(0xFF1A5060),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.evening => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0C1428),
            Color(0xFF1A2848),
            Color(0xFF4A3858),
            Color(0xFF6A4830),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.night => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.night,
            AppColors.night,
            AppColors.nightMid,
            AppColors.nightLight,
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
    };
  }

  static Color scaffoldBackground([DayPhase? phase]) {
    return switch (phase ?? current()) {
      DayPhase.morning => const Color(0xFF3A6088),
      DayPhase.afternoon => const Color(0xFF1A6A88),
      DayPhase.evening => const Color(0xFF1A2848),
      DayPhase.night => AppColors.night,
    };
  }
}
