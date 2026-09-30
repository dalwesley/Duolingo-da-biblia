import 'package:flutter/material.dart';

/// Luz do app — uma fonte só, como num set de filmagem.
///
/// A luz principal vem de cima, levemente da esquerda ([keyFrom]). Cards
/// ganham um véu de luz nessa direção ([sheen]); sombras caem para o lado
/// oposto, macias ([shadow]). A estação litúrgica tinge o mundo inteiro por
/// cima do céu da fase do dia ([grade]) — como gradação de cor.
class AppLight {
  AppLight._();

  /// De onde vem a luz principal.
  static const keyFrom = Alignment(-0.45, -1);
  static const keyTo = Alignment(0.45, 1);

  /// Força da gradação da estação sobre o céu (0–1).
  static const gradeStrength = 0.10;

  /// Véu de luz por cima de um card — brilho na borda que encara a luz.
  static Gradient sheen({double strength = 1}) => LinearGradient(
    begin: keyFrom,
    end: keyTo,
    colors: [
      Colors.white.withValues(alpha: 0.075 * strength),
      Colors.white.withValues(alpha: 0.0),
    ],
    stops: const [0, 0.42],
  );

  /// Gradação da estação: tinge o céu a partir da luz, some no chão.
  static Gradient grade(Color season, {double strength = gradeStrength}) =>
      RadialGradient(
        center: const Alignment(-0.3, -1.1),
        radius: 1.35,
        colors: [
          season.withValues(alpha: strength),
          season.withValues(alpha: strength * 0.35),
          season.withValues(alpha: 0),
        ],
        stops: const [0, 0.45, 1],
      );

  /// Vinheta de lente — escurece as bordas, guia o olho ao centro.
  static const vignette = RadialGradient(
    center: Alignment(0, -0.15),
    radius: 1.15,
    colors: [Color(0x00000000), Color(0x00000000), Color(0x40000000)],
    stops: [0, 0.62, 1],
  );

  /// Sombra macia: ambiente largo + contato curto. Sem "lábio" duro.
  static List<BoxShadow> shadow({bool elevated = false}) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: elevated ? 0.34 : 0.24),
      blurRadius: elevated ? 32 : 22,
      spreadRadius: -4,
      offset: Offset(0, elevated ? 16 : 10),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: elevated ? 0.22 : 0.16),
      blurRadius: elevated ? 8 : 6,
      offset: Offset(0, elevated ? 3 : 2),
    ),
  ];

  /// Placa tátil da cena — lábio duro (juice de toque) + sombra macia.
  /// **Só** nas placas de resposta da cena; o resto do app usa [shadow].
  static List<BoxShadow> lip({double depth = 4}) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.42),
      offset: Offset(0, depth),
      blurRadius: 0,
    ),
    ...shadow(),
  ];
}
