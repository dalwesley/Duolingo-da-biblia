import '../models/difficulty.dart';
import '../theme/app_theme.dart';
import '../widgets/cinematic_icon.dart';
import 'package:flutter/material.dart';

/// Visual da dificuldade — glifos da marca + acentos que contrastam o céu.
class DifficultyVisuals {
  DifficultyVisuals._();

  /// Luminância do ouro de Observação — referência de punch no céu.
  static const _goldLuminance = 0.50;

  /// Contorno / chrome por modo: mint → coral soft → lilac-azul.
  /// Amarelo é ação/recompensa; glow azul é presença — não usar como modo.
  static Color accentFor(TrailDifficulty d) => switch (d) {
    TrailDifficulty.semente => AppRoles.observation,
    TrailDifficulty.caminhada => AppRoles.comprehension,
    TrailDifficulty.profundezas => AppRoles.interpretation,
  };

  static CinematicGlyph glyphFor(TrailDifficulty d) => switch (d) {
    TrailDifficulty.semente => CinematicGlyph.seed,
    TrailDifficulty.caminhada => CinematicGlyph.path,
    TrailDifficulty.profundezas => CinematicGlyph.depths,
  };

  /// Texto escuro sobre o acento sólido (pills "Modo atual").
  static Color inkOn(TrailDifficulty d) => switch (d) {
    TrailDifficulty.semente => AppColors.inkOnSprout,
    TrailDifficulty.caminhada => AppColors.inkOnCoral,
    TrailDifficulty.profundezas => AppColors.inkOnOrchid,
  };

  /// Tinta do modo sobre placa clara (marfim): o tom de céu vira a
  /// versão escura. Qualquer outro acento cai no contorno escuro padrão.
  static Color onLight(Color accent) {
    final v = accent.toARGB32();
    if (v == AppRoles.observation.toARGB32()) return AppColors.sproutDeep;
    if (v == AppRoles.comprehension.toARGB32()) return AppColors.coralDeep;
    if (v == AppRoles.interpretation.toARGB32()) return AppColors.orchidDeep;
    return AppRoles.selectedOnLight;
  }

  /// Texto/ícone no céu — ouro/coral/orquídea já puncionam; outros sobem.
  static Color onSky(Color accent) => AppColors.glyphInk(accent);

  /// Wash de chip/card — compensa acentos mais escuros que o ouro.
  static Color chipFill(Color accent, {double alpha = 0.40}) {
    final lift = (_goldLuminance - accent.computeLuminance()).clamp(0.0, 0.32);
    return Color.lerp(accent, Colors.white, lift)!.withValues(alpha: alpha);
  }

  /// Cartão da jornada — o modo entra no contorno e num wash leve.
  /// Wash forte vira “app amador”; o palco fica noite, o acento pontua.
  static BoxDecoration stationCard({
    required Color accent,
    required Color baseFill,
    required bool lit,
    bool sealed = false,
  }) {
    final wash = lit ? 0.16 : (sealed ? 0.08 : 0.0);
    final edge = Color.lerp(baseFill, accent, wash)!;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(edge, Colors.white, lit ? 0.06 : 0.02)!,
          edge,
          Color.lerp(baseFill, const Color(0xFF000000), lit ? 0.10 : 0.04)!,
        ],
        stops: const [0.0, 0.42, 1.0],
      ),
      border: Border.all(
        color: accent.withValues(alpha: lit ? 0.78 : (sealed ? 0.58 : 0.42)),
        width: lit ? 1.5 : 1.15,
      ),
    );
  }
}
