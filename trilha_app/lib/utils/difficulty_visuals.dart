import '../models/difficulty.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';
import 'package:flutter/material.dart';

/// Visual da dificuldade — glifos da marca + acentos que contrastam o céu.
class DifficultyVisuals {
  DifficultyVisuals._();

  /// Luminância do ouro de Observação — referência de punch no céu.
  static const _goldLuminance = 0.50;

  /// Contorno / chrome por modo: amarelo → coral → orquídea.
  /// Teal e azul de marca somem no céu (manhã/tarde/noite) — não usar.
  static Color accentFor(TrailDifficulty d) => switch (d) {
    TrailDifficulty.semente => AppColors.accent,
    TrailDifficulty.caminhada => AppColors.coral,
    TrailDifficulty.profundezas => AppColors.orchid,
  };

  static Color brightFor(TrailDifficulty d) => switch (d) {
    TrailDifficulty.semente => AppColors.accentBright,
    TrailDifficulty.caminhada => AppColors.coralBright,
    TrailDifficulty.profundezas => AppColors.orchidBright,
  };

  static Color softFor(TrailDifficulty d) => switch (d) {
    TrailDifficulty.semente => AppColors.accentSoft,
    TrailDifficulty.caminhada => AppColors.coralSoft,
    TrailDifficulty.profundezas => AppColors.orchidSoft,
  };

  static CinematicGlyph glyphFor(TrailDifficulty d) => switch (d) {
    TrailDifficulty.semente => CinematicGlyph.seed,
    TrailDifficulty.caminhada => CinematicGlyph.path,
    TrailDifficulty.profundezas => CinematicGlyph.depths,
  };

  /// Texto escuro sobre o acento sólido (pills "Modo atual").
  static Color inkOn(TrailDifficulty d) => switch (d) {
    TrailDifficulty.semente => AppColors.inkOnAccent,
    TrailDifficulty.caminhada => AppColors.inkOnCoral,
    TrailDifficulty.profundezas => AppColors.inkOnOrchid,
  };

  /// Texto/ícone no céu — ouro/coral/orquídea já puncionam; outros sobem.
  static Color onSky(Color accent) {
    if (AppColors.isSolidChrome(accent)) return accent;
    final l = accent.computeLuminance();
    if (l >= _goldLuminance) return accent;
    final t = ((_goldLuminance - l) * 0.9).clamp(0.0, 0.28);
    return Color.lerp(accent, Colors.white, t)!;
  }

  /// Wash de chip/card — compensa acentos mais escuros que o ouro.
  static Color chipFill(Color accent, {double alpha = 0.40}) {
    final lift = (_goldLuminance - accent.computeLuminance()).clamp(0.0, 0.32);
    return Color.lerp(accent, Colors.white, lift)!.withValues(alpha: alpha);
  }
}
