import '../models/difficulty.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';
import 'package:flutter/material.dart';

/// Visual da dificuldade — glifos da marca + cores olive/dourado (sem azul/lilás legado).
class DifficultyVisuals {
  DifficultyVisuals._();

  static Color accentFor(TrailDifficulty d) => switch (d) {
        TrailDifficulty.semente => AppColors.accent,
        TrailDifficulty.caminhada => AppColors.primaryLight,
        TrailDifficulty.profundezas => AppColors.cedarDeep,
      };

  static CinematicGlyph glyphFor(TrailDifficulty d) => switch (d) {
        TrailDifficulty.semente => CinematicGlyph.seed,
        TrailDifficulty.caminhada => CinematicGlyph.path,
        TrailDifficulty.profundezas => CinematicGlyph.depths,
      };

  static Color accentForId(String id) =>
      accentFor(TrailDifficulty.fromId(id) ?? TrailDifficulty.semente);

  static CinematicGlyph glyphForId(String id) =>
      glyphFor(TrailDifficulty.fromId(id) ?? TrailDifficulty.semente);
}
