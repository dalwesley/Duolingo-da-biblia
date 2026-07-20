import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';

/// Nav inferior — glifos brand + label; ativo em cobre sobre moss suave.
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
      (glyph: CinematicGlyph.home, label: 'Hoje'),
      (glyph: CinematicGlyph.book, label: 'Bíblia'),
      (glyph: CinematicGlyph.path, label: 'Trilhas'),
      (glyph: CinematicGlyph.people, label: 'Juntos'),
      (glyph: CinematicGlyph.tune, label: 'Config'),
    ];

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final style = appearance ?? Appearance.of(context);

    return ColoredBox(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpace.md,
          0,
          AppSpace.md,
          bottomInset > 0 ? bottomInset + 6 : AppSpace.md,
        ),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: style.navBarFill,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: style.navBarBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final active = currentIndex == i;
              final tab = tabs[i];
              final color = active
                  ? AppColors.accent
                  : Colors.white.withValues(alpha: 0.4);

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: active
                            ? BoxDecoration(
                                color: AppColors.primaryLight.withValues(alpha: 0.28),
                                borderRadius: BorderRadius.circular(AppRadii.sm),
                                border: Border.all(
                                  color: AppColors.accent.withValues(alpha: 0.35),
                                ),
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
                        style: AppTypography.label(
                          size: 10,
                          letterSpacing: 0.1,
                          color: color,
                          weight: active ? FontWeight.w900 : FontWeight.w700,
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
