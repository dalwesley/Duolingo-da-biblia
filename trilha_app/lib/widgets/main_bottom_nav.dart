import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Nav inferior — chrome neutro ([AppRoles.chrome]) igual em todas as abas.
///
/// Glifo sem poço (`framed: false`) dentro da pílula da aba ativa; o poço
/// emoldurado fica só na marca da [TopBar]. Mesmo raio da cápsula da TopBar
/// ([AppMetrics.cardRadius]).
class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool immersive;
  final bool dark;
  final AppearanceStyle? appearance;

  /// Abas com novidade — ganham um ponto aceso no ícone.
  final Set<int> alerts;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.immersive = false,
    this.dark = false,
    this.appearance,
    this.alerts = const {},
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = [
      (glyph: CinematicGlyph.home, label: l10n.commonToday),
      (glyph: CinematicGlyph.path, label: l10n.navTrails),
      (glyph: CinematicGlyph.book, label: l10n.navBible),
      (glyph: CinematicGlyph.people, label: l10n.navTogether),
      (glyph: CinematicGlyph.tune, label: l10n.settingsTitle),
    ];

    final bottomInset = MediaQuery.of(context).padding.bottom;
    final style = appearance ?? Appearance.of(context);

    // Chrome da nav: escala limitada — evita corte com fonte grande.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.15,
      child: ColoredBox(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpace.md,
            0,
            AppSpace.md,
            bottomInset > 0 ? bottomInset + 6 : AppSpace.md,
          ),
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: style.navBarFill,
              borderRadius: BorderRadius.circular(AppMetrics.cardRadius),
              border: Border.all(
                color: style.navBarBorder,
                width: AppMetrics.cardBorderWidth,
              ),
              boxShadow: AppMetrics.cardShadow(elevated: true),
            ),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final active = currentIndex == i;
                final tab = tabs[i];
                const tone = AppRoles.chrome;
                final color = active ? tone : style.iconMuted;

                return Expanded(
                  child: Semantics(
                    button: true,
                    selected: active,
                    label: alerts.contains(i)
                        ? l10n.navTabWithNews(tab.label)
                        : tab.label,
                    excludeSemantics: true,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () {
                          if (!active) ActHaptics.tap();
                          onTap(i);
                        },
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        splashColor: tone.withValues(alpha: 0.12),
                        highlightColor: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Aba ativa ganha uma pílula acesa atrás do
                              // ícone — lê "você está aqui" de relance.
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                                width: active ? 56 : 40,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: active
                                      ? tone.withValues(alpha: 0.18)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.pill,
                                  ),
                                  border: Border.all(
                                    color: active
                                        ? tone.withValues(alpha: 0.55)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    CinematicIcon(
                                      glyph: tab.glyph,
                                      size: AppMetrics.iconLg,
                                      accent: color,
                                      framed: false,
                                      glowing: false,
                                    ),
                                    if (alerts.contains(i))
                                      Positioned(
                                        top: 3,
                                        right: active ? 12 : 5,
                                        child: AlertDot(ring: style.navBarFill),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tab.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label(
                                  size: 11,
                                  letterSpacing: 0.1,
                                  color: color,
                                  weight: active
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
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
