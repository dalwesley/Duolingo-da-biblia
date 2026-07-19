import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';

/// Nav inferior — linguagem Duolingo: ícone + label, ativo em verde/dourado limpo.
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
          12,
          0,
          12,
          bottomInset > 0 ? bottomInset + 6 : 12,
        ),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: style.navBarFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: style.navBarBorder),
          ),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final active = currentIndex == i;
              final tab = tabs[i];
              final color = active
                  ? AppColors.accent
                  : Colors.white.withValues(alpha: 0.42);

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: active
                            ? BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(12),
                              )
                            : null,
                        child: CinematicIcon(
                          glyph: tab.glyph,
                          size: 22,
                          accent: color,
                          glowing: false,
                          framed: false,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tab.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                          letterSpacing: 0.1,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
