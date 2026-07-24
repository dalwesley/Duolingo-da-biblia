import '../models/difficulty.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';
import 'package:flutter/material.dart';

/// Visual da dificuldade — glifos da marca + oceano/açafrão.
class DifficultyVisuals {
  DifficultyVisuals._();

  static Color accentFor(TrailDifficulty d) => switch (d) {
        TrailDifficulty.semente => AppColors.accent,
        TrailDifficulty.caminhada => AppColors.primaryLight,
        TrailDifficulty.profundezas => AppColors.sky,
      };

  static CinematicGlyph glyphFor(TrailDifficulty d) => switch (d) {
        TrailDifficulty.semente => CinematicGlyph.seed,
        TrailDifficulty.caminhada => CinematicGlyph.path,
        TrailDifficulty.profundezas => CinematicGlyph.depths,
      };
}
