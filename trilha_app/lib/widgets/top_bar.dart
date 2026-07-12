import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool immersive;
  final bool dark;
  /// Saudação em cima + nome em destaque (home).
  final bool personalGreeting;

  const TopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.immersive = false,
    this.dark = false,
    this.personalGreeting = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    // No fundo imersivo o topo do gradient é sempre escuro o bastante para texto claro.
    final onDark = immersive || dark || onBack != null;

    return AppBar(
      backgroundColor: immersive ? Colors.transparent : (dark ? AppColors.night : AppColors.card),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: onBack != null
          ? IconButton(
              onPressed: onBack,
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: onDark ? Colors.white.withValues(alpha: 0.12) : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: onDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08)),
                ),
                child: Icon(Icons.arrow_back_rounded, size: 20, color: onDark ? Colors.white : AppColors.text),
              ),
            )
          : immersive
              ? null
              : const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Center(
                    child: CinematicIcon(
                      glyph: CinematicGlyph.spark,
                      size: 40,
                      accent: AppColors.primaryLight,
                      glowing: false,
                    ),
                  ),
                ),
      title: personalGreeting
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: onDark ? Colors.white.withValues(alpha: 0.62) : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: onDark ? Colors.white : AppColors.text,
                    height: 1.15,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: onDark ? Colors.white : AppColors.text),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: onDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
      actions: [
        _XpBadge(value: progress.xp, dark: onDark),
        const SizedBox(width: 8),
        _StreakBadge(value: progress.streak, dark: onDark),
        const SizedBox(width: 14),
      ],
    );
  }
}

class _XpBadge extends StatelessWidget {
  final int value;
  final bool dark;

  const _XpBadge({required this.value, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: dark ? AppGradients.gold : null,
        color: dark ? null : AppColors.accentSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: dark ? 0 : 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, size: 14, color: dark ? const Color(0xFF3D2E00) : AppColors.accentDark),
          const SizedBox(width: 4),
          Text('$value', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: dark ? const Color(0xFF3D2E00) : AppColors.accentDark)),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int value;
  final bool dark;

  const _StreakBadge({required this.value, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: 0.12) : AppColors.streak.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.streak.withValues(alpha: dark ? 0.4 : 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.streak),
          const SizedBox(width: 4),
          Text('$value', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: dark ? Colors.white : AppColors.streak)),
        ],
      ),
    );
  }
}
