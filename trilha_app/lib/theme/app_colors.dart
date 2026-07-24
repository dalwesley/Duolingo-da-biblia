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
/// - Amarelo sólido: [accent] (#FFC107) — nunca accentBright/sand/ember em labels
/// - CTA: AppGradients.gold + inkOnAccent
/// - Borda accent: alpha ≥ 0.55 (senão vira “dourado”)
class AppColors {
  AppColors._();

  // Marca
  static const primary = Color(0xFF3B8BEA);
  static const primaryLight = Color(0xFF7EC4F5);
  static const primaryDark = Color(0xFF0A1628);

  /// CTA / conquista (chama) — sólido = meio do botão Continuar.
  /// Gradiente: [accentBright] → [accent] → [accentDark] via [AppGradients.gold].
  static const accent = Color(0xFFFFC107);
  static const accentDark = Color(0xFFE0A000);
  static const accentSoft = Color(0xFFFFE6A8);
  /// Só topo do gradiente CTA — não usar como amarelo sólido de UI.
  static const accentBright = Color(0xFFFFE066);
  static const inkOnAccent = Color(0xFF1A1200);

  static const teal = Color(0xFF2DD4BF);
  static const streak = Color(0xFFFF4D6A);
  static const ice = Color(0xFF7EC8E3);
  static const iceSoft = Color(0xFFB5E0F0);
  static const iceDeep = Color(0xFF163848);

  static const error = Color(0xFFFF5C6A);
  static const errorSoft = Color(0xFFFFC0C8);

  // HUD
  static const night = Color(0xFF0B1220);
  static const nightMid = Color(0xFF121C2C);
  static const nightLight = Color(0xFF1C2A40);
  static const nightElevated = Color(0xFF243652);
  static const sheet = nightMid;

  /// Painéis de card por fase (Appearance.cardFill).
  static const cardMorning = Color(0xFF182838);
  static const cardMorningSoft = Color(0xFF1E3048);
  static const cardAfternoon = Color(0xFF143040);
  static const cardAfternoonSoft = Color(0xFF1A3A4C);

  static const surface = Color(0xFFE8ECF2);
  static const card = Colors.white;
  static const text = Color(0xFF0E1620);
  static const textOnDark = Color(0xFFEEF2F7);
  static const textMuted = Color(0xFF5A6878);
  static const textMutedDark = Color(0xFF8FA0B2);

  static const medalGold = Color(0xFFFFD78A);
  static const medalSilver = Color(0xFFC8CEDC);
  static const medalBronze = Color(0xFFE0A06A);
  static const medalInk = Color(0xFF4A3400);

  // Acentos de reino (UI, não céu de cena)
  static const clay = Color(0xFFE8A090);
  static const clayDeep = Color(0xFFB06858);
  static const cedar = Color(0xFF3DB8A8);
  static const cedarDeep = Color(0xFF1A6A5C);
  static const slate = Color(0xFF7AA0C4);
  static const slateDeep = Color(0xFF2A4A70);
  static const sand = Color(0xFFD4AE70);
  static const sandDeep = Color(0xFF8A5E30);
  static const ember = Color(0xFFFF7A45);
  static const emberDeep = Color(0xFFB84820);
  static const sky = Color(0xFF6AB0D8);
}
