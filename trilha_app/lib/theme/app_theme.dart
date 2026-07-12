import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Identidade Trilha — jornada sagrada, não clone do Duolingo.
/// Roxo profundo + dourado divino + creme quente.
class AppColors {
  static const primary = Color(0xFF5B4FCF);
  static const primaryLight = Color(0xFF8B7CF6);
  static const primaryDark = Color(0xFF352880);
  static const accent = Color(0xFFE8B84B);
  static const accentDark = Color(0xFFC99A2E);
  static const accentSoft = Color(0xFFFFF3D6);
  static const teal = Color(0xFF4ECDC4);
  static const streak = Color(0xFFFF8C42);
  static const completed = Color(0xFFE8B84B);
  static const completedDark = Color(0xFFB8892A);
  static const error = Color(0xFFFF6B6B);
  static const night = Color(0xFF0D0B1A);
  static const nightMid = Color(0xFF1A1530);
  static const nightLight = Color(0xFF2A2248);
  static const surface = Color(0xFFFFF8F0);
  static const card = Colors.white;
  static const text = Color(0xFF1E1B2E);
  static const textOnDark = Color(0xFFFFF8F0);
  static const textMuted = Color(0xFF8A849C);
  static const textMutedDark = Color(0xFFB8B0CC);

  // Legado — mapear verde antigo para dourado
  static const success = accent;
  static const successDark = accentDark;
  static const warning = accent;
}

class AppGradients {
  static const cosmic = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1035), Color(0xFF2D1B69), Color(0xFF1A1530)],
  );

  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B4FCF), Color(0xFF7B5CF0), Color(0xFF9B6FE8)],
  );

  static const gold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5D78E), Color(0xFFE8B84B), Color(0xFFC99A2E)],
  );

  static const dawn = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1530), Color(0xFF2A2248), Color(0xFFFFF8F0)],
    stops: [0.0, 0.45, 1.0],
  );

  static const glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33FFFFFF), Color(0x14FFFFFF)],
  );
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

    return base.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textOnDark,
        displayColor: AppColors.textOnDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.nightLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
      ),
    );
  }

  static Color parseHex(String hex) {
    final value = hex.replaceAll('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }

  static List<BoxShadow> glow(Color color, {double blur = 24}) => [
        BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: blur, spreadRadius: 0),
        BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: blur * 2, spreadRadius: 4),
      ];
}
