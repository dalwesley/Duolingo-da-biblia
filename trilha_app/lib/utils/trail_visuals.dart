import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Ícones e gradientes por trilha — visual profissional, sem emojis na UI.
class TrailVisuals {
  final IconData icon;
  final LinearGradient iconGradient;
  final LinearGradient cardGradient;
  final Color accent;
  final Color glow;

  const TrailVisuals({
    required this.icon,
    required this.iconGradient,
    required this.cardGradient,
    required this.accent,
    required this.glow,
  });

  static TrailVisuals forSlug(String slug, {Color? fallbackAccent}) {
    return switch (slug) {
      'genesis-1-11' => const TrailVisuals(
          icon: Icons.auto_stories_rounded,
          iconGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B7CF6), Color(0xFF5B4FCF)],
          ),
          cardGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A1F5C), Color(0xFF1A1530)],
          ),
          accent: AppColors.primaryLight,
          glow: AppColors.accent,
        ),
      'exodo' => const TrailVisuals(
          icon: Icons.landscape_rounded,
          iconGradient: LinearGradient(
            colors: [Color(0xFF74B9FF), Color(0xFF0984E3)],
          ),
          cardGradient: LinearGradient(
            colors: [Color(0xFF0F2847), Color(0xFF0A1A30)],
          ),
          accent: Color(0xFF74B9FF),
          glow: Color(0xFF0984E3),
        ),
      'evangelhos' => const TrailVisuals(
          icon: Icons.favorite_rounded,
          iconGradient: LinearGradient(
            colors: [Color(0xFFFFAB91), Color(0xFFE17055)],
          ),
          cardGradient: LinearGradient(
            colors: [Color(0xFF3D2018), Color(0xFF1F100C)],
          ),
          accent: Color(0xFFFFAB91),
          glow: Color(0xFFE17055),
        ),
      'atos' => const TrailVisuals(
          icon: Icons.local_fire_department_rounded,
          iconGradient: LinearGradient(
            colors: [Color(0xFFFFE082), Color(0xFFFDCB6E)],
          ),
          cardGradient: LinearGradient(
            colors: [Color(0xFF3D3010), Color(0xFF1F1808)],
          ),
          accent: Color(0xFFFFE082),
          glow: Color(0xFFFDCB6E),
        ),
      'apocalipse' => const TrailVisuals(
          icon: Icons.workspace_premium_rounded,
          iconGradient: LinearGradient(
            colors: [Color(0xFFD4C4FF), Color(0xFFA29BFE)],
          ),
          cardGradient: LinearGradient(
            colors: [Color(0xFF2A2548), Color(0xFF151228)],
          ),
          accent: Color(0xFFD4C4FF),
          glow: Color(0xFFA29BFE),
        ),
      _ => TrailVisuals(
          icon: Icons.menu_book_rounded,
          iconGradient: LinearGradient(
            colors: [fallbackAccent ?? AppColors.primaryLight, fallbackAccent ?? AppColors.primary],
          ),
          cardGradient: const LinearGradient(
            colors: [Color(0xFF2A2248), Color(0xFF1A1530)],
          ),
          accent: fallbackAccent ?? AppColors.primaryLight,
          glow: fallbackAccent ?? AppColors.accent,
        ),
    };
  }
}
