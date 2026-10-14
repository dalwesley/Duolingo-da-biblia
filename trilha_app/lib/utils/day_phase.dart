import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum DayPhase { morning, afternoon, evening, night }

/// Cores de céu por horário — só usadas por [DayPhaseHelper].
class _PhaseSky {
  static const morning = [
    Color(0xFF1A4E90),
    Color(0xFF2E74C0),
    Color(0xFF1E5890),
    Color(0xFF123050),
  ];
  static const afternoon = [
    Color(0xFF123860),
    Color(0xFF1E5898),
    Color(0xFF2A68B0),
    Color(0xFF102848),
  ];
  static const evening = [
    Color(0xFF0E1A2C),
    Color(0xFF163058),
    Color(0xFF1E4070),
    Color(0xFF121E34),
  ];
  static const night = [
    AppColors.night,
    AppColors.nightMid,
    Color(0xFF1A3458),
    Color(0xFF102030),
  ];

  static const morningScaffold = Color(0xFF2A6098);
  static const afternoonScaffold = Color(0xFF1A4878);
  static const eveningScaffold = Color(0xFF162844);
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

  /// Saudação pelo horário do aparelho (independente do tema visual).
  static String greeting([DayPhase? phase]) {
    return switch (phase ?? current()) {
      DayPhase.morning => 'Bom dia',
      DayPhase.afternoon => 'Boa tarde',
      DayPhase.evening => 'Boa noite',
      DayPhase.night => 'Boa noite',
    };
  }

  /// Céus de prática — azul de arena, sem crepúsculo litúrgico.
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
