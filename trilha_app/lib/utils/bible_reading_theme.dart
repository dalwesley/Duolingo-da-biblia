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

  TextStyle get verseStyle => AppTypography.verse(
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

  TextStyle get titleStyle => AppTypography.verse(
        size: 28,
        weight: FontWeight.w700,
        color: ink,
      );

  static BibleReadingStyle resolve(AppearanceStyle appearance) {
    if (appearance.isDay) {
      return BibleReadingStyle(
        isDay: true,
        page: AppColors.surface,
        pageBorder: const Color(0xFFC8D0DC),
        ink: AppColors.text,
        inkMuted: AppColors.textMuted,
        verseNumber: AppColors.sandDeep,
        highlightFill: AppColors.accent.withValues(alpha: 0.22),
        highlightBorder: AppColors.accentDark.withValues(alpha: 0.55),
        savedFill: AppColors.accent.withValues(alpha: 0.1),
        chrome: AppColors.textOnDark,
        chromeBorder: const Color(0xFFB8C4D0),
        chipFill: const Color(0xFFDCE2EA),
      );
    }
    return BibleReadingStyle(
      isDay: false,
      page: AppColors.nightElevated,
      pageBorder: AppColors.nightLight,
      ink: AppColors.textOnDark,
      inkMuted: AppColors.textMutedDark,
      verseNumber: AppColors.accentBright,
      highlightFill: AppColors.accent.withValues(alpha: 0.18),
      highlightBorder: AppColors.accent.withValues(alpha: 0.4),
      savedFill: AppColors.accent.withValues(alpha: 0.08),
      chrome: AppColors.nightMid,
      chromeBorder: const Color(0xFF2A2A3A),
      chipFill: AppColors.nightLight,
    );
  }
}
