import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

export 'app_colors.dart';

import 'app_colors.dart';

/// Tema STWAY — tipografia, raios, espaçamento e ThemeData.
/// Cores: ver [AppColors] em `app_colors.dart` (fonte única).
///
/// Visual ~70% game: Exo 2 (HUD/títulos) + Nunito (corpo), raios de painel.
class AppGradients {
  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
  );

  /// Chama — CTAs e badges (alias histórico: gold).
  static const gold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.accentBright, AppColors.accent, AppColors.accentDark],
  );
}

/// Escala tipográfica unificada — HUD de jogo sem mudar copy.
class AppTypography {
  /// Headlines de UI / jogo — geometric game.
  static TextStyle display({
    double size = 28,
    FontWeight weight = FontWeight.w800,
    Color color = AppColors.textOnDark,
    double height = 1.1,
    FontStyle fontStyle = FontStyle.normal,
  }) => GoogleFonts.exo2(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    fontStyle: fontStyle,
    letterSpacing: -0.3,
  );

  /// Versículo / passagem — só leitura bíblica e citação de estudo.
  static TextStyle verse({
    double size = 21,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.textOnDark,
    double height = 1.5,
    FontStyle fontStyle = FontStyle.normal,
  }) => GoogleFonts.cormorantGaramond(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    fontStyle: fontStyle,
  );

  static TextStyle title({
    double size = 18,
    FontWeight weight = FontWeight.w800,
    Color color = AppColors.textOnDark,
    double height = 1.2,
  }) => GoogleFonts.exo2(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: -0.2,
  );

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.textOnDark,
    double height = 1.4,
  }) => GoogleFonts.nunito(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );

  static TextStyle label({
    double size = 11,
    FontWeight weight = FontWeight.w800,
    Color color = AppColors.accent,
    double letterSpacing = 1.6,
  }) => GoogleFonts.exo2(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
  );

  static TextStyle cta({
    double size = 14,
    Color color = AppColors.inkOnAccent,
  }) => GoogleFonts.exo2(
    fontSize: size,
    fontWeight: FontWeight.w900,
    color: color,
    letterSpacing: 1.0,
  );
}

/// Raios padronizados — painéis de jogo (menos “blob”, mais HUD).
class AppRadii {
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const pill = 999.0;
}

/// Espaçamento padronizado.
class AppSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const screen = 20.0;
  static const section = 16.0;
  static const afterTopBar = section;
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.accent,
        surface: AppColors.nightMid,
        onSurface: AppColors.textOnDark,
        onPrimary: AppColors.textOnDark,
        onSecondary: AppColors.inkOnAccent,
        error: AppColors.error,
        tertiary: AppColors.teal,
      ),
      scaffoldBackgroundColor: AppColors.night,
      cardColor: AppColors.nightLight,
      dividerColor: Colors.white12,
      canvasColor: AppColors.nightMid,
    );

    final bodyTheme = GoogleFonts.nunitoTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textOnDark,
      displayColor: AppColors.textOnDark,
    );

    return base.copyWith(
      textTheme: bodyTheme.copyWith(
        displayLarge: AppTypography.display(size: 34),
        displayMedium: AppTypography.display(size: 28),
        displaySmall: AppTypography.display(size: 24),
        headlineMedium: AppTypography.display(
          size: 22,
          weight: FontWeight.w700,
        ),
        titleLarge: AppTypography.title(size: 20),
        titleMedium: AppTypography.title(size: 16),
        bodyLarge: AppTypography.body(size: 15),
        bodyMedium: AppTypography.body(size: 14),
        labelLarge: AppTypography.label(size: 12, color: AppColors.textOnDark),
        labelSmall: AppTypography.label(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.nightLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.nightLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(
            color: AppColors.textOnDark.withValues(alpha: 0.14),
            width: 1.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.inkOnAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: Colors.white12,
      ),
    );
  }

  static Color parseHex(String hex) {
    final value = hex.replaceAll('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }

  static List<BoxShadow> glow(Color color, {double blur = 12}) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.28),
      blurRadius: blur.clamp(6, 14),
      offset: const Offset(0, 4),
    ),
  ];

  /// Sombra neutra — preferir [AppMetrics.cardShadow] quando houver accent/elevação.
  static List<BoxShadow> cardShadow({bool elevated = false}) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: elevated ? 0.55 : 0.4),
      offset: Offset(0, elevated ? 5 : 4),
      blurRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: elevated ? 0.28 : 0.18),
      blurRadius: elevated ? 18 : 12,
      offset: Offset(0, elevated ? 10 : 6),
    ),
  ];
}
