import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'lantern_glyph.dart';
import '../l10n/app_language.dart';

/// Lâmpadas = vidas da missão.
/// Cada erro apaga uma; zerar encerra a cena.
class LampsBar extends StatelessWidget {
  final int current;
  final int max;
  final Color accent;
  final bool labeled;

  /// Faixa larga (topo da pergunta) — ocupa a largura disponível.
  final bool fullWidth;

  /// Altura reduzida em telas curtas.
  final bool compact;

  const LampsBar({
    super.key,
    required this.current,
    this.max = 5,
    this.accent = AppColors.accent,
    this.labeled = false,
    this.fullWidth = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final iconH = compact ? 24.0 : (fullWidth ? 30.0 : 28.0);
    final iconW = compact ? 18.0 : (fullWidth ? 22.0 : 20.0);
    final icons = Row(
      mainAxisAlignment: fullWidth
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: List.generate(max, (i) {
        final on = i < current;
        return Padding(
          padding: EdgeInsets.only(
            left: i == 0 ? 0 : (fullWidth ? (compact ? 8 : 10) : 7),
          ),
          child: AnimatedScale(
            scale: on ? 1 : 0.9,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: on ? 1 : 0.32,
              duration: const Duration(milliseconds: 220),
              child: CustomPaint(
                size: Size(iconW, iconH),
                painter: LanternPainter(lit: on, color: accent),
              ),
            ),
          ),
        );
      }),
    );

    if (!labeled) return icons;

    final header = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        CinematicIcon(
          glyph: CinematicGlyph.lamp,
          size: 14,
          accent: accent.withValues(alpha: 0.9),
          framed: false,
        ),
        const SizedBox(width: 6),
        Text(
          context.l10n.homeLampsTitle,
          style: AppTypography.label(
            size: 11,
            letterSpacing: 0.6,
            color: a.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$current/$max',
          style: AppTypography.body(
            size: 12,
            weight: FontWeight.w900,
            color: accent,
          ),
        ),
      ],
    );

    return Semantics(
      label: context.l10n.homeLampsSemantics(current, max),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: fullWidth
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.center,
        children: [
          header,
          SizedBox(height: compact ? 6 : (fullWidth ? 10 : 8)),
          icons,
          if (!compact) ...[
            SizedBox(height: fullWidth ? 8 : 6),
            Text(
              context.l10n.homeLampsHint,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 11,
                weight: FontWeight.w600,
                color: a.textFaint,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
