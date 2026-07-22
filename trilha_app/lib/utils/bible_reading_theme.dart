import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'appearance.dart';

/// Tema de leitura bíblica — contraste alto no sol, suave à noite.
/// O tamanho da fonte segue a escala global do app ([MediaQuery.textScaler]).
class BibleReadingStyle {
  final bool isDay;
  final Color page;
  final Color pageBorder;
  final Color ink;
  final Color inkMuted;
  final Color verseNumber;
  final Color highlightFill;
  final Color highlightBorder;
  final Color savedFill;
  final Color chrome;
  final Color chromeBorder;
  final Color chipFill;

  const BibleReadingStyle({
    required this.isDay,
    required this.page,
    required this.pageBorder,
    required this.ink,
    required this.inkMuted,
    required this.verseNumber,
    required this.highlightFill,
    required this.highlightBorder,
    required this.savedFill,
    required this.chrome,
    required this.chromeBorder,
    required this.chipFill,
  });

  static const baseSize = 21.0;
  static const lineHeight = 1.72;

  TextStyle get verseStyle => AppTypography.display(
        size: baseSize,
        height: lineHeight,
        weight: FontWeight.w500,
        color: ink,
      );

  TextStyle get numberStyle => AppTypography.label(
        size: 11,
        letterSpacing: 0.3,
        color: verseNumber,
      );

  TextStyle get metaStyle => AppTypography.body(
        size: 12,
        weight: FontWeight.w600,
        color: inkMuted,
      );

  TextStyle get titleStyle => AppTypography.display(
        size: 28,
        weight: FontWeight.w700,
        color: ink,
      );

  static BibleReadingStyle resolve(AppearanceStyle appearance) {
    if (appearance.isDay) {
      return const BibleReadingStyle(
        isDay: true,
        page: Color(0xFFF2F4F8),
        pageBorder: Color(0xFFC8D0DC),
        ink: Color(0xFF121820),
        inkMuted: Color(0xFF4A5868),
        verseNumber: Color(0xFF8A6030),
        highlightFill: Color(0x33E8922A),
        highlightBorder: Color(0x99E8922A),
        savedFill: Color(0x18E8922A),
        chrome: Color(0xFFE8ECF2),
        chromeBorder: Color(0xFFB8C4D0),
        chipFill: Color(0xFFDCE2EA),
      );
    }
    return const BibleReadingStyle(
      isDay: false,
      page: Color(0xFF101820),
      pageBorder: Color(0xFF243040),
      ink: Color(0xFFE8ECF2),
      inkMuted: Color(0xFF8A98A8),
      verseNumber: Color(0xFFE0A84A),
      highlightFill: Color(0x33E8922A),
      highlightBorder: Color(0x66E8922A),
      savedFill: Color(0x18E8922A),
      chrome: Color(0xFF141C28),
      chromeBorder: Color(0xFF2A3848),
      chipFill: Color(0xFF1A2430),
    );
  }
}
