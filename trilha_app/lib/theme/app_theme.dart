import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identidade Trilha — caminho no cedro.
/// Floresta fria + cobre de conquista + pedra-limestone.
/// Sem lilás, mint neon, creme quente genérico ou dourado de stock.
class AppColors {
  static const primary = Color(0xFF243F36);
  static const primaryLight = Color(0xFF3D6B58);
  static const primaryDark = Color(0xFF152820);
  /// Cobre — conquista, passos, CTAs.
  static const accent = Color(0xFFC4783E);
  static const accentDark = Color(0xFF9A5A28);
  static const accentSoft = Color(0xFFF5E6D4);
  /// Texto sobre botões/doses de cobre.
  static const inkOnAccent = Color(0xFF2A1808);
  /// Moss — sucesso / concluído (substitui teal neon).
  static const teal = Color(0xFF5A9E88);
  static const streak = Color(0xFFE07040);
  static const completed = Color(0xFFC4783E);
  static const completedDark = Color(0xFF9A5A28);
  static const error = Color(0xFFD45A5A);
  static const night = Color(0xFF0E1210);
  static const nightMid = Color(0xFF161C19);
  static const nightLight = Color(0xFF222A25);
  /// Pedra fria — sem pergaminho amarelado.
  static const surface = Color(0xFFE8E6E0);
  static const card = Colors.white;
  static const text = Color(0xFF141A17);
  static const textOnDark = Color(0xFFE8E6E0);
  static const textMuted = Color(0xFF657068);
  static const textMutedDark = Color(0xFF9AA39C);

  // Família de conteúdo (trilhas/reinos)
  static const clay = Color(0xFFC9947E); // NT / evangelhos
  static const clayDeep = Color(0xFFA06650);
  static const cedar = Color(0xFF5E8F70); // vida cristã
  static const cedarDeep = Color(0xFF345A48);
  static const slate = Color(0xFF7E90A0); // teologia / hermenêutica
  static const slateDeep = Color(0xFF3E4E5E);
  static const sand = Color(0xFFB89A72); // história / línguas
  static const sandDeep = Color(0xFF7A6040);
  static const ember = Color(0xFFD07848); // apocalipse / fogo
  static const emberDeep = Color(0xFFA05030);
  static const sky = Color(0xFF6E92AE); // proféticos / êxodo
  static const skyDeep = Color(0xFF385A78);

  // Legado
  static const success = accent;
  static const successDark = accentDark;
  static const warning = accent;
}

class AppGradients {
  static const cosmic = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E1210), Color(0xFF152820), Color(0xFF161C19)],
  );

  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF243F36), Color(0xFF2F5548), Color(0xFF3D6B58)],
  );

  /// Cobre — CTAs e badges de progresso (alias histórico: gold).
  static const gold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8B07A), Color(0xFFC4783E), Color(0xFF9A5A28)],
  );

  static const copper = gold;

  static const dawn = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF161C19), Color(0xFF222A25), Color(0xFFE8E6E0)],
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
  /// Gutter horizontal das telas.
  static const screen = 20.0;
  /// Ritmo vertical entre cards de conteúdo.
  static const section = 16.0;
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
