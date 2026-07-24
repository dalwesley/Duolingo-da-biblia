import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum DayPhase { morning, afternoon, evening, night }

/// Céus por horário — floresta STWAY (alinhado à logo).
class _PhaseSky {
  static const morning = [
    Color(0xFF1A3A32),
    Color(0xFF2B463D),
    Color(0xFF3D5F51),
    Color(0xFF16332E),
  ];
  static const afternoon = [
    Color(0xFF0E2A26),
    Color(0xFF1D3C36),
    Color(0xFF2B463D),
    Color(0xFF143028),
  ];
  static const evening = [
    Color(0xFF061B1B),
    Color(0xFF0D2521),
    Color(0xFF16332E),
    Color(0xFF0A1C1A),
  ];
  static const night = [
    AppColors.night,
    AppColors.nightMid,
    Color(0xFF16332E),
    Color(0xFF0A1C1A),
  ];

  static const morningScaffold = Color(0xFF2B463D);
  static const afternoonScaffold = Color(0xFF1D3C36);
  static const eveningScaffold = Color(0xFF0D2521);
}

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

  /// Céus de treino — floresta da marca, sem azul de arena.
  static LinearGradient backgroundGradient([DayPhase? phase]) {
    return switch (phase ?? current()) {
      DayPhase.morning => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _PhaseSky.morning,
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.afternoon => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _PhaseSky.afternoon,
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.evening => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _PhaseSky.evening,
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
      DayPhase.night => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _PhaseSky.night,
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
    };
  }

  static Color scaffoldBackground([DayPhase? phase]) {
    return switch (phase ?? current()) {
      DayPhase.morning => _PhaseSky.morningScaffold,
      DayPhase.afternoon => _PhaseSky.afternoonScaffold,
      DayPhase.evening => _PhaseSky.eveningScaffold,
      DayPhase.night => AppColors.night,
    };
  }
}
