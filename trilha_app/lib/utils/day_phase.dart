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

  /// Céus de treino — azul de arena, sem crepúsculo litúrgico.
  static LinearGradient backgroundGradient([DayPhase? phase]) {
    return switch (phase ?? current()) {
      DayPhase.morning => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A4A88),
            Color(0xFF2A6AB0),
            Color(0xFF1E5080),
            Color(0xFF123050),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.afternoon => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0E4A68),
            Color(0xFF1A7A98),
            Color(0xFF2A98A8),
            Color(0xFF145060),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.evening => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF101828),
            Color(0xFF1A3058),
            Color(0xFF243868),
            Color(0xFF152038),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.night => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B1220),
            Color(0xFF121C2C),
            Color(0xFF1A2A44),
            Color(0xFF122038),
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
