import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool immersive;
  final bool dark;
  final AppearanceStyle? appearance;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.immersive = false,
    this.dark = false,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (icon: Icons.home_rounded, label: 'Início'),
      (icon: Icons.map_rounded, label: 'Trilhas'),
      (icon: Icons.tune_rounded, label: 'Ajustes'),
    ];

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final style = appearance ?? Appearance.of(context);
    final onDark = immersive ? style.onDark : dark;

    return ColoredBox(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset > 0 ? bottomInset + 8 : 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: immersive
                    ? style.navBarFill
                    : (onDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.95)),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: immersive
                      ? style.navBarBorder
                      : (onDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.06)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: onDark ? 0.25 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final active = currentIndex == i;
                  final tab = tabs[i];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.all(5),
                        decoration: active
                            ? BoxDecoration(
                                gradient: onDark ? AppGradients.gold : AppGradients.hero,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: active && onDark
                                    ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 12)]
                                    : null,
                              )
                            : null,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              tab.icon,
                              size: 22,
                              color: active
                                  ? (onDark ? const Color(0xFF3D2E00) : Colors.white)
                                  : (onDark ? Colors.white.withValues(alpha: 0.55) : AppColors.textMuted),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tab.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: active
                                    ? (onDark ? const Color(0xFF3D2E00) : Colors.white)
                                    : (onDark ? Colors.white.withValues(alpha: 0.55) : AppColors.textMuted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
