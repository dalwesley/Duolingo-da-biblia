import 'package:flutter/material.dart';

/// Cores de marca e UI compartilhada do STWAY.
///
/// Use **só** estes tokens em telas/chrome/CTAs.
/// Atmosferas de trilha, fase do dia e pintura de cena ficam
/// nos arquivos que as consomem — evita misturar paleta de cena com botão.
///
/// Âncora: logo (navy → glow → path) + “A” dourado do wordmark.
/// Regra de tela: no máx. 2 cromáticos — (modo **ou** presença) + ouro.
///
/// Chrome (regra):
/// - Fundo: Appearance / DayPhase / night*
/// - Texto: textOnDark / Appearance.text|textMuted
/// - Ouro sólido: [accent] (#F7BB01) — CTA / recompensa / seleção na cena
/// - Modos: Observação [sprout], Compreensão [coral], Interpretação [orchid]
/// - Presença / sucesso: [glow] — path aceso da splash
/// - CTA: [accent] chapado + inkOnAccent
/// - Borda accent: alpha ≥ 0.55 (senão vira “dourado”)
class AppColors {
  AppColors._();

  // Marca — azul trilha + amarelo do wordmark
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

  /// Path aceso da splash — presença / “estudou” / sucesso na home.
  static const glow = Color(0xFF5EB8E8);

  /// Alias legado — preferir [glow].
  static const teal = glow;

  /// Sequência (chama) — fogo âmbar, longe do vermelho de erro.
  static const streak = Color(0xFFFF8A3D);

  /// Observação — mint frio, vizinho do glow (não disputa o ouro).
  static const sprout = Color(0xFF7DCF8A);
  static const inkOnSprout = Color(0xFF0A160C);

  /// Versões escuras dos modos — só sobre placa clara (marfim da cena),
  /// onde o tom do céu some (≥4.5:1 no marfim).
  static const sproutDeep = Color(0xFF2F6B3A);
  static const coralDeep = Color(0xFF8F4A28);
  static const orchidDeep = Color(0xFF3D4A9E);

  /// Compreensão — coral soft, único quente de modo (abaixo do ouro).
  static const coral = Color(0xFFE8895C);
  static const coralBright = Color(0xFFE0B098);
  static const coralSoft = Color(0xFFE8C8BC);
  static const inkOnCoral = Color(0xFF1A0A04);

  /// Interpretação — lilac-azul da família navy (não magenta).
  static const orchid = Color(0xFF8B9CFF);
  static const orchidBright = Color(0xFFA8B4FF);
  static const orchidSoft = Color(0xFFC4CAF0);
  static const inkOnOrchid = Color(0xFF0C0E1C);
  static const ice = Color(0xFF5AABC0);
  static const iceSoft = Color(0xFF8BB8C8);
  static const iceDeep = Color(0xFF0E2E3C);

  static const error = Color(0xFFFF4F63);

  /// Poeira — quem está parado há dias (dupla, semente, aceno).
  static const dust = Color(0xFFC4A070);

  /// Sombra projetada de palco (cartas, faixas de versículo).
  static const dropShadow = Color(0x59000000);

  /// Véu atrás de sheets e diálogos — o mesmo em todo o app.
  static const scrim = Color(0x9E000000);
  static const errorSoft = Color(0xFFFFC4CC);

  /// Ouro, mint, coral e lilac — chrome de modo/CTA, sem misturar branco no glifo.
  static bool isSolidChrome(Color color) {
    final v = color.toARGB32();
    return v == accent.toARGB32() ||
        v == sprout.toARGB32() ||
        v == accentBright.toARGB32() ||
        v == coral.toARGB32() ||
        v == coralBright.toARGB32() ||
        v == orchid.toARGB32() ||
        v == orchidBright.toARGB32();
  }

  /// Tinta de glifo que punciona no céu pintado e nos cards.
  ///
  /// Ouro/mint/coral/lilac ficam chapados. Ciano/azul do céu (cedar, slate,
  /// ice, primary, glow) sobem rumo ao branco. Pretos de CTA não sobem.
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

  /// Pioneiro — violeta, fora do ouro das raras e da orquídea dos modos.
  static const medalAurora = Color(0xFF7C4DFF);
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
}

/// Papéis de cor. Telas pedem o **papel**, nunca o tom (`AppColors.clay`).
///
/// Um papel, uma cor:
/// - [action] — botão principal e o que se toca para avançar;
/// - [reward] — passos, medalha, baú, meta cumprida;
/// - [chrome] — nav, TopBar, ícone de aba (neutro, igual em todas);
/// - [selected] — escolha no chrome escuro (contorno claro);
/// - [success] / [presence] — concluído, "estudou hoje" (glow da splash);
/// - [streak] — sequência (chama âmbar), só ela;
/// - [risk] / [error] — algo em perigo ou que falhou;
/// - modos: [observation] · [comprehension] · [interpretation];
/// - áreas: [areaOldTestament] · [areaNewTestament] · [areaChristianLife] ·
///   [areaTheology] — só dentro de Trilhas.
///
/// Na cena: idle escuro · seleção branca · acerto ouro · erro vermelho.
/// Cor de modo fica no mapa / seletor, não nos gestos.
/// Glow ([presence]) = home / orbs, não gestos.
class AppRoles {
  AppRoles._();

  static const action = AppColors.accent;
  static const onAction = AppColors.inkOnAccent;
  static const reward = AppColors.accent;
  static const onReward = AppColors.inkOnAccent;

  /// Aço frio — distinto do branco de [selected], para o chrome não
  /// competir com a pílula de seleção (senão a tela vira tudo branco).
  static const chrome = Color(0xFF9EB0C4);
  static const selected = Color(0xFFF2F5FA);

  /// Seleção sobre placa clara (respostas marfim da cena): contorno escuro
  /// (legado). Preferir fill [action] nas placas de resposta.
  static const selectedOnLight = Color(0xCC070B14);
  static const selectedOutlineWidth = 2.0;

  static const success = AppColors.glow;
  static const presence = success;
  static const streak = AppColors.streak;
  static const risk = AppColors.error;
  static const error = AppColors.error;

  static const observation = AppColors.sprout;
  static const comprehension = AppColors.coral;
  static const interpretation = AppColors.orchid;

  static const areaOldTestament = AppColors.sand;
  static const areaNewTestament = AppColors.clay;
  static const areaChristianLife = AppColors.cedar;
  static const areaTheology = AppColors.slate;
}
