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
        page: Color(0xFFF7F2E6),
        pageBorder: Color(0xFFD8CFBE),
        ink: Color(0xFF1A1712),
        inkMuted: Color(0xFF5C564C),
        verseNumber: Color(0xFF8A6540),
        highlightFill: Color(0x33C4783E),
        highlightBorder: Color(0x99C4783E),
        savedFill: Color(0x18C4783E),
        chrome: Color(0xFFF0EADF),
        chromeBorder: Color(0xFFD0C6B4),
        chipFill: Color(0xFFE8E0D2),
      );
    }
    return const BibleReadingStyle(
      isDay: false,
      page: Color(0xFF171512),
      pageBorder: Color(0xFF2E2A24),
      ink: Color(0xFFEDE6D6),
      inkMuted: Color(0xFFA89F8E),
      verseNumber: Color(0xFFC9A66B),
      highlightFill: Color(0x33C4783E),
      highlightBorder: Color(0x66C4783E),
      savedFill: Color(0x18C4783E),
      chrome: Color(0xFF1E1B17),
      chromeBorder: Color(0xFF3A342C),
      chipFill: Color(0xFF25211C),
    );
  }
}
