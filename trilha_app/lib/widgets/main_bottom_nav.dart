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
      (glyph: CinematicGlyph.spark, label: 'Hoje'),
      (glyph: CinematicGlyph.book, label: 'Bíblia'),
      (glyph: CinematicGlyph.path, label: 'Trilhas'),
      (glyph: CinematicGlyph.dove, label: 'Juntos'),
      (glyph: CinematicGlyph.tune, label: 'Config'),
    ];

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final style = appearance ?? Appearance.of(context);

    return ColoredBox(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          bottomInset > 0 ? bottomInset + 8 : 16,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.xl),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: style.navBarFill,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: style.navBarBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final active = currentIndex == i;
                final tab = tabs[i];
                final activeColor = AppColors.inkOnAccent;
                final idleColor = Colors.white.withValues(alpha: 0.48);
                final color = active ? activeColor : idleColor;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.all(4),
                      decoration: active
                          ? BoxDecoration(
                              gradient: AppGradients.gold,
                              borderRadius: BorderRadius.circular(18),
                            )
                          : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CinematicIcon(
                            glyph: tab.glyph,
                            size: 22,
                            accent: color,
                            glowing: false,
                            framed: false,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tab.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.1,
                              color: color,
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
