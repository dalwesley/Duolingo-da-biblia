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

  /// Nulo = `a.chrome` da aparência atual.
  final Color? accent;

  /// Cor da chama e do brilho das acesas. Nula = a mesma de [accent].
  final Color? flame;
  final bool labeled;

  /// Faixa larga (topo da pergunta) — ocupa a largura disponível.
  final bool fullWidth;

  /// Altura reduzida em telas curtas.
  final bool compact;

  /// Última lâmpada: o flash vermelho é só a que acabou de apagar.
  final bool atRisk;

  /// Índice (0-based) da lâmpada que acabou de apagar — flash de erro.
  final int? flashOffIndex;

  const LampsBar({
    super.key,
    required this.current,
    this.max = 5,
    this.accent,
    this.flame,
    this.labeled = false,
    this.fullWidth = false,
    this.compact = false,
    this.atRisk = false,
    this.flashOffIndex,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final accent = this.accent ?? a.chrome;
    // Travessia acende mais lamparinas: no topo da cena elas apertam.
    final dense = compact && max > 6;
    final iconH = dense ? 20.0 : (compact ? 24.0 : (fullWidth ? 30.0 : 28.0));
    final iconW = dense ? 15.0 : (compact ? 18.0 : (fullWidth ? 22.0 : 20.0));
    final litColor = accent;
    final icons = Row(
      mainAxisAlignment: fullWidth
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: List.generate(max, (i) {
        final on = i < current;
        final flashing = flashOffIndex == i;
        final color = flashing ? AppRoles.error : (on ? litColor : accent);
        return Padding(
          padding: EdgeInsets.only(
            left: i == 0
                ? 0
                : (fullWidth ? (compact ? 8 : 10) : (dense ? 4 : 7)),
          ),
          child: AnimatedScale(
            scale: flashing ? 1.18 : (on ? 1 : 0.9),
            duration: AppMotion.standard,
            curve: AppMotion.pop,
            child: AnimatedOpacity(
              opacity: flashing ? 1 : (on ? 1 : (atRisk ? 0.18 : 0.32)),
              duration: AppMotion.standard,
              child: CustomPaint(
                size: Size(iconW, iconH),
                painter: LanternPainter(
                  lit: on || flashing,
                  color: color,
                  unlitInk: a.text,
                  flame: flashing ? null : flame,
                ),
              ),
            ),
          ),
        );
      }),
    );

    if (!labeled) {
      return Semantics(
        label: context.l10n.homeLampsSemantics(current, max),
        child: icons,
      );
    }

    final header = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        CinematicIcon(
          glyph: CinematicGlyph.lamp,
          size: 14,
          accent: litColor.withValues(alpha: 0.9),
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
            color: litColor,
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
