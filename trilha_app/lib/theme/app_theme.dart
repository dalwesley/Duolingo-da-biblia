import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identidade Steway — **Academia da Palavra**.
/// Loop de treino (streak, missões, passos) + estudo real na missão.
/// Dark HUD + chama (CTA); tipografia sagrada só no leitor bíblico.
class AppColors {
  /// Céu / chrome do treino — azul vivo de jogo.
  static const primary = Color(0xFF3B8BEA);
  static const primaryLight = Color(0xFF7EC4F5);
  static const primaryDark = Color(0xFF0A1628);

  /// Chama — CTAs, passos, conquista.
  static const accent = Color(0xFFFFC107);
  static const accentDark = Color(0xFFE0A000);
  static const accentSoft = Color(0xFFFFE6A8);
  static const accentBright = Color(0xFFFFE066);

  /// Texto sobre a chama.
  static const inkOnAccent = Color(0xFF1A1200);

  /// Maré — acerto / vida.
  static const teal = Color(0xFF2DD4BF);
  /// Urgência do streak.
  static const streak = Color(0xFFFF4D6A);
  static const ice = Color(0xFF7EC8E3);
  static const iceSoft = Color(0xFFB5E0F0);
  static const iceDeep = Color(0xFF163848);

  static const completed = accent;
  static const completedDark = accentDark;
  static const error = Color(0xFFFF5C6A);
  static const errorSoft = Color(0xFFFFC0C8);

  /// Noite do treino — HUD escuro azulado (não void contemplativo).
  static const night = Color(0xFF0B1220);
  static const nightMid = Color(0xFF121C2C);
  static const nightLight = Color(0xFF1C2A40);
  static const nightElevated = Color(0xFF243652);
  static const sheet = nightMid;
  static const sheetElevated = nightLight;

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

  // Reinos — saturados, mas da mesma família (terra / mar / fogo)
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
