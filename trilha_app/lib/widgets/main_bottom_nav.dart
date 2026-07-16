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
      (glyph: CinematicGlyph.spark, icon: null, label: 'Caminhada'),
      (glyph: CinematicGlyph.book, icon: null, label: 'Bíblia'),
      (glyph: CinematicGlyph.crown, icon: null, label: 'Juntos'),
      (glyph: null, icon: Icons.settings_rounded, label: 'Config'),
    ];

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final style = appearance ?? Appearance.of(context);

    return ColoredBox(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset > 0 ? bottomInset + 8 : 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          child: Container(
              height: 68,
              decoration: BoxDecoration(
                color: style.navBarFill,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(color: style.navBarBorder),
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
                  final activeColor = AppColors.inkOnAccent;
                  final idleColor = Colors.white.withValues(alpha: 0.5);

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
                                gradient: AppGradients.gold,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(alpha: 0.22),
                                    blurRadius: 10,
                                  ),
                                ],
                              )
                            : null,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (tab.icon != null)
                              Icon(
                                tab.icon,
                                size: 22,
                                color: active ? activeColor : idleColor,
                              )
                            else
                              CinematicIcon(
                                glyph: tab.glyph!,
                                size: 26,
                                accent: active ? activeColor : idleColor,
                                glowing: active,
                                framed: false,
                              ),
                            const SizedBox(height: 2),
                            Text(
                              tab.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
