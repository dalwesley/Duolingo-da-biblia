import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';

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
      (glyph: CinematicGlyph.spark, label: 'Início'),
      (glyph: CinematicGlyph.path, label: 'Mundos'),
      (glyph: CinematicGlyph.crown, label: 'Liga'),
      (glyph: CinematicGlyph.lamp, label: 'Ajustes'),
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
          child: Container(
              height: 68,
              decoration: BoxDecoration(
                color: immersive
                    ? style.navBarFill
                    : (onDark
                        ? const Color(0xFF15102A).withValues(alpha: 0.92)
                        : Colors.white.withValues(alpha: 0.95)),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: immersive
                      ? style.navBarBorder
                      : (onDark
                          ? Colors.white.withValues(alpha: 0.18)
                          : Colors.black.withValues(alpha: 0.06)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final active = currentIndex == i;
                  final tab = tabs[i];
                  final activeColor =
                      onDark ? const Color(0xFF3D2E00) : Colors.white;
                  final idleColor = onDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : AppColors.textMuted;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.all(5),
                        decoration: active
                            ? BoxDecoration(
                                gradient: onDark
                                    ? AppGradients.gold
                                    : AppGradients.hero,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: onDark
                                    ? [
                                        BoxShadow(
                                          color: AppColors.accent
                                              .withValues(alpha: 0.4),
                                          blurRadius: 14,
                                        ),
                                      ]
                                    : null,
                              )
                            : null,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CinematicIcon(
                              glyph: tab.glyph,
                              size: 26,
                              accent: active ? activeColor : idleColor,
                              glowing: active,
                              framed: false,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tab.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                                color: active ? activeColor : idleColor,
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
    );
  }
}
