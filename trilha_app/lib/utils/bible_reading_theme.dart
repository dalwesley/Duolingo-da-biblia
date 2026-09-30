import 'package:flutter/material.dart';
import '../l10n/l10n_global.dart';
import '../theme/app_theme.dart';
import 'appearance.dart';

/// Papel da página de leitura — escolha no painel "Aa" do leitor.
enum BiblePaper {
  auto,
  light,
  sepia,
  night;

  String get label => switch (this) {
    BiblePaper.auto => L10n.current.biblePaperAuto,
    BiblePaper.light => L10n.current.biblePaperLight,
    BiblePaper.sepia => L10n.current.biblePaperSepia,
    BiblePaper.night => L10n.current.biblePaperNight,
  };

  static BiblePaper of({required bool? readingNight, required bool sepia}) {
    if (readingNight == true) return BiblePaper.night;
    if (sepia) return BiblePaper.sepia;
    if (readingNight == false) return BiblePaper.light;
    return BiblePaper.auto;
  }
}

/// Tema de leitura bíblica — contraste alto no sol, suave à noite.
/// Independente do visual do app: a página pode ser noite só para ler.
/// O tamanho da fonte segue a escala global do app ([MediaQuery.textScaler]).
///
/// É uma paleta de papel (como a de um cenário): os tons crus de papel e
/// tinta ficam aqui. Nada nela é ação ou recompensa, então não há amarelo —
/// número de versículo é tinta apagada e o versículo tocado/ouvido ganha um
/// véu da própria tinta do papel (seleção neutra, visível em todo papel).
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

  TextStyle get numberStyle =>
      AppTypography.label(size: 11, letterSpacing: 0.3, color: verseNumber);

  TextStyle get metaStyle =>
      AppTypography.body(size: 12, weight: FontWeight.w600, color: inkMuted);

  TextStyle get titleStyle =>
      AppTypography.verse(size: 28, weight: FontWeight.w700, color: ink);

  static BibleReadingStyle resolve(
    AppearanceStyle appearance, {
    bool? readingNight,
    bool sepia = false,
  }) {
    final isDay = readingNight == null ? appearance.isDay : !readingNight;
    if (isDay && sepia) {
      const ink = Color(0xFF3B2A1A);
      const muted = Color(0xFF7A6248);
      return BibleReadingStyle(
        isDay: true,
        page: const Color(0xFFF4E9D4),
        pageBorder: muted.withValues(alpha: 0.28),
        ink: ink,
        inkMuted: muted,
        verseNumber: muted,
        highlightFill: ink.withValues(alpha: 0.1),
        highlightBorder: ink.withValues(alpha: 0.45),
        savedFill: muted.withValues(alpha: 0.08),
        chrome: const Color(0xFFF4E9D4),
        chromeBorder: muted.withValues(alpha: 0.35),
        chipFill: const Color(0xFFE8DAC0),
      );
    }
    if (isDay) {
      return BibleReadingStyle(
        isDay: true,
        page: AppColors.surface,
        pageBorder: AppColors.textMuted.withValues(alpha: 0.35),
        ink: AppColors.text,
        inkMuted: AppColors.textMuted,
        verseNumber: AppColors.textMuted,
        highlightFill: AppColors.text.withValues(alpha: 0.08),
        highlightBorder: AppColors.text.withValues(alpha: 0.4),
        savedFill: AppColors.textMuted.withValues(alpha: 0.08),
        chrome: AppColors.textOnDark,
        chromeBorder: AppColors.textMuted.withValues(alpha: 0.4),
        chipFill: const Color(0xFFDCE2EA),
      );
    }
    return BibleReadingStyle(
      isDay: false,
      page: AppColors.nightElevated,
      pageBorder: AppColors.nightLight,
      ink: AppColors.textOnDark,
      inkMuted: AppColors.textMutedDark,
      verseNumber: AppColors.textMutedDark,
      highlightFill: AppColors.textOnDark.withValues(alpha: 0.1),
      highlightBorder: AppColors.textOnDark.withValues(alpha: 0.45),
      savedFill: AppColors.textOnDark.withValues(alpha: 0.05),
      chrome: AppColors.nightMid,
      chromeBorder: AppColors.nightElevated,
      chipFill: AppColors.nightLight,
    );
  }
}
