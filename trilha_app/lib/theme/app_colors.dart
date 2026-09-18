import 'package:flutter/material.dart';

/// Cores de marca e UI compartilhada do STWAY.
///
/// Use **só** estes tokens em telas/chrome/CTAs.
/// Atmosferas de trilha, fase do dia e pintura de cena ficam
/// nos arquivos que as consomem — evita misturar paleta de cena com botão.
///
/// Chrome (regra):
/// - Fundo: Appearance / DayPhase / night*
/// - Texto: textOnDark / Appearance.text|textMuted
/// - Amarelo sólido: [accent] (#F7BB01) — nunca accentBright/sand/ember em labels
/// - Modos: Observação [accent], Compreensão [coral], Interpretação [orchid]
/// - CTA: [accent] chapado + inkOnAccent
/// - Borda accent: alpha ≥ 0.55 (senão vira “dourado”)
class AppColors {
  AppColors._();

  // Marca — azul trilha mais vivo + amarelo do wordmark
  static const primary = Color(0xFF4A9EFF);
  static const primaryLight = Color(0xFF6BA8C4);
  static const primaryDark = Color(0xFF040910);

  /// CTA / conquista — amarelo do wordmark STWAY (#F7BB01), chapado.
  static const accent = Color(0xFFF7BB01);
  static const accentDark = Color(0xFFC99200);
  static const accentSoft = Color(0xFFD4C078);

  /// Variante mais clara do accent — nunca como amarelo sólido de UI.
  static const accentBright = Color(0xFFE0BE4A);
  static const inkOnAccent = Color(0xFF140E00);

  static const teal = Color(0xFF3AAB98);
  static const streak = Color(0xFFFF3D6E);

  /// Compreensão — coral, complementar ao céu teal/azul.
  static const coral = Color(0xFFFF9468);
  static const coralBright = Color(0xFFE0B098);
  static const coralSoft = Color(0xFFE8C8BC);
  static const inkOnCoral = Color(0xFF1C0704);

  /// Interpretação — orquídea, fora da família azul do céu.
  static const orchid = Color(0xFFF48CFF);
  static const orchidBright = Color(0xFFC8A0D0);
  static const orchidSoft = Color(0xFFD8C0DC);
  static const inkOnOrchid = Color(0xFF16081C);
  static const ice = Color(0xFF5AABC0);
  static const iceSoft = Color(0xFF8BB8C8);
  static const iceDeep = Color(0xFF0E2E3C);

  static const error = Color(0xFFFF4F63);
  static const errorSoft = Color(0xFFFFC4CC);

  /// Ouro, coral e orquídea — chrome de modo, sem misturar branco no glifo.
  static bool isSolidChrome(Color color) {
    final v = color.toARGB32();
    return v == accent.toARGB32() ||
        v == accentBright.toARGB32() ||
        v == coral.toARGB32() ||
        v == coralBright.toARGB32() ||
        v == orchid.toARGB32() ||
        v == orchidBright.toARGB32();
  }

  /// Tinta de glifo que punciona no céu pintado e nos cards.
  ///
  /// Ouro/coral/orquídea ficam chapados. Ciano/azul do céu (cedar, slate,
  /// ice, primary) sobem rumo ao branco. Pretos de CTA não sobem.
  static Color glyphInk(Color color) {
    if (isSolidChrome(color)) return color;
    final l = color.computeLuminance();
    if (l < 0.08) return color;

    const target = 0.52;
    if (l >= target) return color;

    final hue = HSLColor.fromColor(color).hue;
    final skyFamily = hue >= 165 && hue <= 235;
    final maxLift = skyFamily ? 0.55 : 0.34;
    final t = ((target - l) * (skyFamily ? 1.2 : 0.85)).clamp(0.0, maxLift);
    return Color.lerp(color, Colors.white, t)!;
  }

  // HUD — void mais profundo, painéis com contraste de jogo
  static const night = Color(0xFF070B14);
  static const nightMid = Color(0xFF0E1624);
  static const nightLight = Color(0xFF162033);
  static const nightElevated = Color(0xFF1C2A42);
  static const sheet = nightMid;

  /// Painéis de card por fase (Appearance.cardFill).
  static const cardMorning = Color(0xFF152536);
  static const cardMorningSoft = Color(0xFF1C3148);
  static const cardAfternoon = Color(0xFF122E3E);
  static const cardAfternoonSoft = Color(0xFF183848);

  static const surface = Color(0xFFE8ECF2);
  static const card = Colors.white;
  static const text = Color(0xFF0E1620);
  static const textOnDark = Color(0xFFF2F5FA);
  static const textMuted = Color(0xFF5A6878);
  static const textMutedDark = Color(0xFF9AADC0);

  static const medalGold = Color(0xFFE0B868);
  static const medalSilver = Color(0xFFB0B6C4);
  static const medalBronze = Color(0xFFC97B4A);
  static const medalIron = Color(0xFF8B939E);
  static const medalPlatinum = Color(0xFFC4CAD6);
  static const medalDiamond = Color(0xFF7AB4C4);
  static const medalMirra = Color(0xFFB88A5A);
  static const medalInk = Color(0xFF4A3400);

  // Acentos de reino (UI, não céu de cena) — um pouco mais saturados
  static const clay = Color(0xFFFFA898);
  static const clayDeep = Color(0xFFB06858);
  static const cedar = Color(0xFF3DCFBE);
  static const cedarDeep = Color(0xFF1A6A5C);
  static const slate = Color(0xFF7EB0D8);
  static const slateDeep = Color(0xFF2A4A70);
  static const sand = Color(0xFFE0B878);
  static const sandDeep = Color(0xFF8A5E30);
  static const ember = Color(0xFFFF7A45);
  static const emberDeep = Color(0xFFB84820);
  static const sky = Color(0xFF6AB0D8);

  /// Chrome da aba (nav + leading) — amarelo só em Hoje / CTA / conquista.
  /// Trilhas (areia) ≠ Bíblia (cedar): frio vs quente, sem colisão.
  static Color tabChrome(int index) => switch (index) {
    0 => accent, // Hoje
    1 => sand, // Trilhas — caminho / bronze
    2 => cedar, // Bíblia — palavra / teal
    3 => clay, // Juntos
    _ => slate, // Ajustes
  };
}
