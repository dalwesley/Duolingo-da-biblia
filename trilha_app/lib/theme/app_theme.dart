import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identidade Trilha — estudo bíblico claro e firme.
/// Olive/cedro + dourado de conquista + pergaminho quente.
/// Sem lilás, mint neon ou estética “sol radiante”.
class AppColors {
  static const primary = Color(0xFF2F5D4A);
  static const primaryLight = Color(0xFF4A8B6F);
  static const primaryDark = Color(0xFF1E3D32);
  static const accent = Color(0xFFD4A84B);
  static const accentDark = Color(0xFFB8892A);
  static const accentSoft = Color(0xFFFFF3D6);
  /// Texto sobre botões/doses douradas.
  static const inkOnAccent = Color(0xFF3D2E00);
  static const teal = Color(0xFF3DB8A8);
  static const streak = Color(0xFFE07A3A);
  static const completed = Color(0xFFD4A84B);
  static const completedDark = Color(0xFFB8892A);
  static const error = Color(0xFFE05A5A);
  static const night = Color(0xFF121816);
  static const nightMid = Color(0xFF1A221E);
  static const nightLight = Color(0xFF28332C);
  static const surface = Color(0xFFF7F1E6);
  static const card = Colors.white;
  static const text = Color(0xFF1A211C);
  static const textOnDark = Color(0xFFF7F1E6);
  static const textMuted = Color(0xFF6B726C);
  static const textMutedDark = Color(0xFFA8B0AA);

  // Família de conteúdo (trilhas/reinos) — derivados da marca, sem arco-íris
  static const clay = Color(0xFFD4A08A); // NT / evangelhos
  static const clayDeep = Color(0xFFB06B4F);
  static const cedar = Color(0xFF6B9B7A); // vida cristã
  static const cedarDeep = Color(0xFF3D6B55);
  static const slate = Color(0xFF8A9AAB); // teologia / hermenêutica
  static const slateDeep = Color(0xFF4A5A6B);
  static const sand = Color(0xFFC4A882); // história / línguas
  static const sandDeep = Color(0xFF8A6E4E);
  static const ember = Color(0xFFE08A5A); // apocalipse / fogo
  static const emberDeep = Color(0xFFB05A35);
  static const sky = Color(0xFF7A9EBA); // proféticos / êxodo
  static const skyDeep = Color(0xFF3D6A8A);

  // Legado
  static const success = accent;
  static const successDark = accentDark;
  static const warning = accent;
}

class AppGradients {
  static const cosmic = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF121816), Color(0xFF1E3D32), Color(0xFF1A221E)],
  );

  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2F5D4A), Color(0xFF3D7A5C), Color(0xFF4A8B6F)],
  );

  static const gold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5D78E), Color(0xFFD4A84B), Color(0xFFB8892A)],
  );

  static const dawn = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A221E), Color(0xFF28332C), Color(0xFFF7F1E6)],
    stops: [0.0, 0.45, 1.0],
  );

  static const glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33FFFFFF), Color(0x14FFFFFF)],
  );
}

/// Escala tipográfica unificada.
class AppTypography {
  static TextStyle display({
    double size = 28,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.textOnDark,
    double height = 1.1,
  }) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
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
  /// Gutter horizontal das telas.
  static const screen = 20.0;
  /// Offset sob TopBar / status.
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
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.night,
      cardColor: AppColors.nightLight,
      dividerColor: Colors.white12,
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
        headlineMedium: AppTypography.display(size: 22, weight: FontWeight.w600),
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
    );
  }

  static Color parseHex(String hex) {
    final value = hex.replaceAll('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }

  /// Brilho discreto — presença, não neon.
  static List<BoxShadow> glow(Color color, {double blur = 20}) => [
        BoxShadow(color: color.withValues(alpha: 0.14), blurRadius: blur, spreadRadius: 0),
        BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: blur * 1.4, spreadRadius: 1),
      ];

  static List<BoxShadow> cardShadow({bool elevated = false}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: elevated ? 0.22 : 0.14),
          blurRadius: elevated ? 18 : 12,
          offset: Offset(0, elevated ? 8 : 5),
        ),
      ];
}
