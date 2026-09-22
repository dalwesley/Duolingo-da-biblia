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
  static Color onSky(Color accent) => AppColors.glyphInk(accent);

  /// Wash de chip/card — compensa acentos mais escuros que o ouro.
  static Color chipFill(Color accent, {double alpha = 0.40}) {
    final lift = (_goldLuminance - accent.computeLuminance()).clamp(0.0, 0.32);
    return Color.lerp(accent, Colors.white, lift)!.withValues(alpha: alpha);
  }

  /// Cartão da jornada — o modo entra no contorno, não no fill.
  /// Wash forte vira “app amador”; o palco fica noite, o acento pontua.
  static BoxDecoration stationCard({
    required Color accent,
    required Color baseFill,
    required bool lit,
    bool sealed = false,
  }) {
    final wash = lit ? 0.07 : 0.0;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      color: wash == 0 ? baseFill : Color.lerp(baseFill, accent, wash),
      border: Border.all(
        color: accent.withValues(alpha: lit ? 0.70 : (sealed ? 0.55 : 0.40)),
        width: lit ? 1.4 : 1.15,
      ),
    );
  }
}
