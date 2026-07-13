import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final onDark = immersive || dark || onBack != null;

    return AppBar(
      backgroundColor: immersive
          ? Colors.transparent
          : (dark ? AppColors.night : AppColors.card),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: onBack != null
          ? IconButton(
              onPressed: onBack,
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: Colors.white,
                ),
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
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: onDark ? Colors.white : AppColors.text,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: onDark
                          ? Colors.white.withValues(alpha: 0.55)
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
      actions: [
        _XpBadge(value: progress.xp),
        const SizedBox(width: 8),
        _StreakBadge(value: progress.streak),
        const SizedBox(width: 14),
      ],
    );
  }
}

class _XpBadge extends StatelessWidget {
  final int value;

  const _XpBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppGradients.gold,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.35),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.spark,
            size: 16,
            accent: Color(0xFF3D2E00),
            glowing: false,
            framed: false,
          ),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3D2E00),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int value;

  const _StreakBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.streak.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 14,
            color: AppColors.streak,
          ),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
