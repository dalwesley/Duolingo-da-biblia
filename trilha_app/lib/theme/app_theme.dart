import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

export 'app_colors.dart';

import 'app_colors.dart';

/// Tema STWAY — tipografia, raios, espaçamento e ThemeData.
/// Cores: ver [AppColors] em `app_colors.dart` (fonte única).
class AppGradients {
  static const cosmic = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.night, AppColors.primaryDark, AppColors.nightMid],
  );

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

  static const copper = gold;

  static const dawn = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.nightMid, AppColors.nightLight, AppColors.surface],
    stops: [0.0, 0.45, 1.0],
  );

  static const sheet = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.nightElevated, AppColors.nightMid],
  );

  static const glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33FFFFFF), Color(0x14FFFFFF)],
  );

  /// Horizonte — azul → chama.
  static const plasma = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.accent],
  );
}

/// Escala tipográfica unificada.
class AppTypography {
  /// Headlines de UI / jogo — sans forte.
  static TextStyle display({
    double size = 28,
    FontWeight weight = FontWeight.w800,
    Color color = AppColors.textOnDark,
    double height = 1.1,
    FontStyle fontStyle = FontStyle.normal,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        fontStyle: fontStyle,
      );

  /// Versículo / passagem — só leitura bíblica e citação de estudo.
  static TextStyle verse({
    double size = 21,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.textOnDark,
    double height = 1.5,
    FontStyle fontStyle = FontStyle.normal,
  }) =>
      GoogleFonts.cormorantGaramond(
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
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.textOnDark,
    double height = 1.4,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  static TextStyle label({
    double size = 11,
    FontWeight weight = FontWeight.w800,
    Color color = AppColors.accent,
    double letterSpacing = 1.4,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  static TextStyle cta({
    double size = 14,
    Color color = AppColors.inkOnAccent,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: 0.4,
      );
}

/// Raios padronizados.
class AppRadii {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 28.0;
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
  static const underTopBar = 72.0;
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.surface,
    );

    return base.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
    );
  }

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

    final jakarta = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textOnDark,
      displayColor: AppColors.textOnDark,
    );

    return base.copyWith(
      textTheme: jakarta.copyWith(
        displayLarge: AppTypography.display(size: 34),
        displayMedium: AppTypography.display(size: 28),
        displaySmall: AppTypography.display(size: 24),
        headlineMedium: AppTypography.display(size: 22, weight: FontWeight.w700),
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
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.nightLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.inkOnAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
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

  static List<BoxShadow> glow(Color color, {double blur = 20}) => [
        BoxShadow(color: color.withValues(alpha: 0.16), blurRadius: blur, spreadRadius: 0),
        BoxShadow(color: color.withValues(alpha: 0.06), blurRadius: blur * 1.4, spreadRadius: 1),
      ];

  static List<BoxShadow> cardShadow({bool elevated = false}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: elevated ? 0.24 : 0.16),
          blurRadius: elevated ? 18 : 12,
          offset: Offset(0, elevated ? 8 : 5),
        ),
      ];
}
