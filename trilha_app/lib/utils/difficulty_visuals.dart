import '../models/difficulty.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';
import 'package:flutter/material.dart';

/// Visual da dificuldade — glifos da marca + oceano/açafrão.
class DifficultyVisuals {
  DifficultyVisuals._();

  /// Contorno / chrome por modo: amarelo → teal → azul.
  static Color accentFor(TrailDifficulty d) => switch (d) {
        TrailDifficulty.semente => AppColors.accent,
        TrailDifficulty.caminhada => AppColors.teal,
        TrailDifficulty.profundezas => AppColors.primary,
      };

  static CinematicGlyph glyphFor(TrailDifficulty d) => switch (d) {
        TrailDifficulty.semente => CinematicGlyph.seed,
        TrailDifficulty.caminhada => CinematicGlyph.path,
        TrailDifficulty.profundezas => CinematicGlyph.depths,
      };

  /// Texto escuro sobre o acento sólido (pills "Modo atual").
  static Color inkOn(TrailDifficulty d) => switch (d) {
        TrailDifficulty.semente => AppColors.inkOnAccent,
        TrailDifficulty.caminhada => const Color(0xFF04241E),
        TrailDifficulty.profundezas => const Color(0xFF041018),
      };
}
