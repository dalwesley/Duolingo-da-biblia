import 'package:flutter/material.dart';

/// Cores de marca e UI compartilhada do STWAY.
///
/// Paleta extraída da logo (floresta · creme · sálvia).
/// Use **só** estes tokens em telas/chrome/CTAs.
/// Atmosferas de trilha, fase do dia e pintura de cena ficam
/// nos arquivos que as consomem — evita misturar paleta de cena com botão.
class AppColors {
  AppColors._();

  // Marca — terreno / profundidade
  /// Verde médio da logo (camadas do ícone).
  static const primary = Color(0xFF3D5F51);
  /// Sálvia — “A” do wordmark e brilho de marca.
  static const primaryLight = Color(0xFF768270);
  /// Floresta profunda — fundo de marca.
  static const primaryDark = Color(0xFF061B1B);

  /// CTA / caminho (creme da trilha na logo).
  static const accent = Color(0xFFE3D7C2);
  static const accentDark = Color(0xFFC4B59A);
  static const accentSoft = Color(0xFFEDE6D8);
  static const accentBright = Color(0xFFF0E8D8);
  static const inkOnAccent = Color(0xFF061B1B);

  /// Verde vivo de apoio (luz / tarde).
  static const teal = Color(0xFF4A8F78);
  static const streak = Color(0xFFFF4D6A);
  static const ice = Color(0xFF8FB8A8);
  static const iceSoft = Color(0xFFC5D9CE);
  static const iceDeep = Color(0xFF16332E);

  static const error = Color(0xFFFF5C6A);
  static const errorSoft = Color(0xFFFFC0C8);

  // HUD — noite floresta
  static const night = Color(0xFF061B1B);
  static const nightMid = Color(0xFF0D2521);
  static const nightLight = Color(0xFF16332E);
  static const nightElevated = Color(0xFF23433B);
  static const sheet = nightMid;

  /// Painéis de card por fase (Appearance.cardFill).
  static const cardMorning = Color(0xFF132321);
  static const cardMorningSoft = Color(0xFF1A322C);
  static const cardAfternoon = Color(0xFF16332E);
  static const cardAfternoonSoft = Color(0xFF1D3C36);

  static const surface = Color(0xFFE8ECF2);
  static const card = Colors.white;
  static const text = Color(0xFF0E1620);
  /// Creme da logo — texto sobre fundo escuro.
  static const textOnDark = Color(0xFFE3D7C2);
  static const textMuted = Color(0xFF5A6878);
  static const textMutedDark = Color(0xFF9AAB9E);

  static const medalGold = Color(0xFFE3D7C2);
  static const medalSilver = Color(0xFFC8CEDC);
  static const medalBronze = Color(0xFFC4B59A);
  static const medalInk = Color(0xFF2B463D);

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
