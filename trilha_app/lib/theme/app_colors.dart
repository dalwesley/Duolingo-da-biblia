import 'package:flutter/material.dart';

/// Cores de marca e UI compartilhada do STWAY.
///
/// Use **só** estes tokens em telas/chrome/CTAs.
/// Atmosferas de trilha, fase do dia e pintura de cena ficam
/// nos arquivos que as consomem — evita misturar paleta de cena com botão.
class AppColors {
  AppColors._();

  // Marca
  static const primary = Color(0xFF3B8BEA);
  static const primaryLight = Color(0xFF7EC4F5);
  static const primaryDark = Color(0xFF0A1628);

  /// CTA / conquista (chama).
  static const accent = Color(0xFFFFC107);
  static const accentDark = Color(0xFFE0A000);
  static const accentSoft = Color(0xFFFFE6A8);
  static const accentBright = Color(0xFFFFE066);
  static const inkOnAccent = Color(0xFF1A1200);

  static const teal = Color(0xFF2DD4BF);
  static const streak = Color(0xFFFF4D6A);
  static const ice = Color(0xFF7EC8E3);
  static const iceSoft = Color(0xFFB5E0F0);
  static const iceDeep = Color(0xFF163848);

  static const completed = accent;
  static const completedDark = accentDark;
  static const error = Color(0xFFFF5C6A);
  static const errorSoft = Color(0xFFFFC0C8);

  // HUD
  static const night = Color(0xFF0B1220);
  static const nightMid = Color(0xFF121C2C);
  static const nightLight = Color(0xFF1C2A40);
  static const nightElevated = Color(0xFF243652);
  static const sheet = nightMid;
  static const sheetElevated = nightLight;

  /// Overlay escuro (vinhetas / scrims).
  static const scrimSoft = Color(0x66000000);
  static const scrimMid = Color(0x99000000);
  static const scrimStrong = Color(0xCC000000);

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
  static const skyDeep = Color(0xFF2A5A88);

  static const success = teal;
  static const successDark = cedarDeep;
  static const warning = accent;
}
