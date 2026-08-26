import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';

/// Tokens visuais compartilhados — barras, labels e badges iguais em toda a app.
class AppMetrics {
  /// Altura das barras de progresso (chunky / 3D).
  static const progressHeight = 16.0;

  /// Padding padrão dos cards de conteúdo.
  static const cardPadding = EdgeInsets.all(AppSpace.lg);

  /// Padding compacto (listas / rows).
  static const cardPaddingCompact = EdgeInsets.symmetric(
    horizontal: AppSpace.lg,
    vertical: AppSpace.md,
  );

  /// Raio padrão dos cards.
  static const cardRadius = AppRadii.lg;

  /// Raio do card hero / destaque.
  static const heroRadius = AppRadii.xl;

  /// Ícone leading em listas (quests, trilhas).
  static const leadingIcon = 40.0;

  /// Ícone compacto em badges/chips.
  static const chipIcon = 14.0;

  /// Espessura de borda dos painéis.
  static const cardBorderWidth = 1.75;

  /// Borda de destaque — amarelo do CTA por padrão (nunca ≤0.5: vira “dourado”).
  static Color accentBorder({double alpha = 0.85, Color? color}) =>
      (color ?? AppColors.accent).withValues(alpha: alpha.clamp(0.55, 1.0));

  /// Fill suave sobre accent (chips) — borda separada via [accentBorder].
  static Color accentFill({double alpha = 0.18, Color? color}) =>
      (color ?? AppColors.accent).withValues(alpha: alpha);

  /// Sombra de painel de jogo — lip duro embaixo + soft ambient.
  static List<BoxShadow> cardShadow({
    bool elevated = false,
    bool accent = false,
    Color? tint,
  }) {
    final lip = elevated ? 5.0 : 4.0;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: elevated ? 0.55 : 0.42),
        offset: Offset(0, lip),
        blurRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: elevated ? 0.28 : 0.18),
        blurRadius: elevated ? 18 : 12,
        offset: Offset(0, elevated ? 10 : 6),
      ),
    ];
  }

  /// Lip 3D do CTA — sem glow colorido.
  static List<BoxShadow> accentGlow({
    double blur = 10,
    double alpha = 0.22,
    Offset offset = const Offset(0, 4),
    Color? color,
  }) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      offset: const Offset(0, 4),
      blurRadius: 0,
    ),
  ];
}

/// Botão CTA açafrão — ação principal em cards, sheets e telas.
///
/// Padrão: [AppGradients.gold], raio [AppRadii.md], [AppTypography.cta],
/// tinta [AppColors.inkOnAccent], sombra [AppMetrics.accentGlow].
class CopperCta extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final CinematicGlyph? trailing;
  final CinematicGlyph? leading;
  final bool expanded;
  final EdgeInsetsGeometry? padding;
  final bool showArrow;
  final bool dense;
  final bool showGlow;
  final bool busy;

  const CopperCta({
    super.key,
    required this.label,
    this.onTap,
    this.trailing = CinematicGlyph.path,
    this.leading,
    this.expanded = true,
    this.padding,
    this.showArrow = false,
    this.dense = false,
    this.showGlow = true,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !busy;
    final pad =
        padding ??
        EdgeInsets.symmetric(
          horizontal: AppSpace.lg,
          vertical: dense ? 14.0 : AppSpace.lg,
        );
    final fontSize = dense ? 13.0 : 15.0;

    final child = AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled || busy ? 1 : 0.45,
      child: Container(
        padding: pad,
        decoration: BoxDecoration(
          gradient: AppGradients.gold,
          borderRadius: BorderRadius.circular(AppRadii.md),
          boxShadow: showGlow ? AppMetrics.accentGlow() : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (busy) ...[
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.inkOnAccent,
                ),
              ),
              const SizedBox(width: 8),
            ] else if (leading != null) ...[
              CinematicIcon(
                glyph: leading!,
                size: dense ? 16 : 18,
                accent: AppColors.inkOnAccent,
                framed: false,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTypography.cta(size: fontSize),
              ),
            ),
            if (!busy && showArrow) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: AppColors.inkOnAccent,
              ),
            ] else if (!busy && trailing != null) ...[
              const SizedBox(width: 8),
              CinematicIcon(
                glyph: trailing!,
                size: 16,
                accent: AppColors.inkOnAccent,
                framed: false,
              ),
            ],
          ],
        ),
      ),
    );

    if (!enabled) return child;
    return GestureDetector(onTap: onTap, child: child);
  }
}

/// CTA secundário — contorno accent, fundo quase transparente.
class OutlineCta extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final CinematicGlyph? leading;
  final bool expanded;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool uppercase;

  const OutlineCta({
    super.key,
    required this.label,
    this.onTap,
    this.leading,
    this.expanded = true,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    this.color,
    this.uppercase = true,
  });

  @override
  Widget build(BuildContext context) {
    final ink = color ?? AppColors.accent;
    final enabled = onTap != null;
    final border = enabled
        ? ink.withValues(alpha: color != null ? 0.65 : 0.45)
        : (color != null
              ? ink.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.12));
    final textColor = enabled
        ? ink
        : (color != null
              ? ink.withValues(alpha: 0.75)
              : Colors.white.withValues(alpha: 0.35));

    final child = AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled || color != null ? 1 : 0.7,
      child: Container(
        width: expanded ? double.infinity : null,
        padding: padding,
        decoration: BoxDecoration(
          color: color != null
              ? ink.withValues(alpha: enabled ? 0.14 : 0.08)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (leading != null) ...[
              CinematicIcon(
                glyph: leading!,
                size: 18,
                accent: textColor,
                framed: false,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              uppercase ? label.toUpperCase() : label,
              textAlign: TextAlign.center,
              style: AppTypography.cta(size: 13, color: textColor),
            ),
          ],
        ),
      ),
    );

    if (!enabled) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: child,
      ),
    );
  }
}

/// CTA fantasma — fill suave + borda (ações secundárias em settings, etc.).
class GhostCta extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final CinematicGlyph? leading;
  final bool danger;
  final bool expanded;
  final EdgeInsetsGeometry padding;

  const GhostCta({
    super.key,
    required this.label,
    this.onTap,
    this.leading,
    this.danger = false,
    this.expanded = false,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final ink = danger ? AppColors.error : a.text;
    final border = danger
        ? AppColors.error.withValues(alpha: 0.45)
        : a.cardBorder;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          width: expanded ? double.infinity : null,
          padding: padding,
          decoration: BoxDecoration(
            color: danger
                ? AppColors.error.withValues(alpha: 0.08)
                : a.cardFillSoft,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (leading != null) ...[
                CinematicIcon(
                  glyph: leading!,
                  size: 16,
                  accent: ink,
                  framed: false,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    size: 13,
                    weight: FontWeight.w800,
                    color: ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra de progresso chunky 3D — fill claro + faixa escura embaixo.
class AppProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final Color? trackColor;
  final double height;

  /// Tom mais escuro da “base” 3D. Null = deriva de [color].
  final Color? depthColor;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color,
    this.trackColor,
    this.height = AppMetrics.progressHeight,
    this.depthColor,
  });

  static Color _depthOf(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness * 0.72).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation * 1.05).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final fill = color ?? AppColors.accent;
    final depth = depthColor ?? _depthOf(fill);
    final track = trackColor ?? a.progressTrack;
    final t = value.clamp(0.0, 1.0);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fillWidth = constraints.maxWidth * t;
            return Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: track),
                if (fillWidth > 0)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: fillWidth,
                      height: height,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [fill, depth],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Label de seção — uppercase, tracking fixo (MISSÕES DIÁRIAS, etc.).
class SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  final double size;

  const SectionLabel(this.text, {super.key, this.color, this.size = 11});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Text(
      text.toUpperCase(),
      style: AppTypography.label(
        size: size,
        letterSpacing: 1.3,
        color: color ?? a.text.withValues(alpha: 0.88),
      ),
    );
  }
}

/// Badge de contagem — pill compacto (`2/3`, `+40`).
class CountBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final bool filled;

  const CountBadge(this.text, {super.key, this.color, this.filled = true});

  @override
  Widget build(BuildContext context) {
    final ink = color ?? AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? ink.withValues(alpha: 0.18) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: filled
              ? ink.withValues(alpha: 0.7)
              : ink.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      child: Text(
        text,
        style: AppTypography.body(
          size: 12,
          weight: FontWeight.w900,
          color: ink,
          height: 1.1,
        ),
      ),
    );
  }
}

/// Chip/badge suave com glifo brand.
class SoftBadge extends StatelessWidget {
  final String text;
  final CinematicGlyph? glyph;
  final Color? accent;
  final Color? textColor;
  final bool bordered;

  const SoftBadge({
    super.key,
    required this.text,
    this.glyph,
    this.accent,
    this.textColor,
    this.bordered = true,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final tone = accent ?? AppColors.accent;
    final isBrand = tone.toARGB32() == AppColors.accent.toARGB32();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: bordered
            ? Border.all(
                color: isBrand
                    ? AppMetrics.accentBorder(alpha: 0.75)
                    : tone.withValues(alpha: 0.65),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (glyph != null) ...[
            CinematicIcon(
              glyph: glyph!,
              size: AppMetrics.chipIcon,
              accent: tone,
              framed: false,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w800,
              color: textColor ?? a.text,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabeçalho de card: label à esquerda + badge à direita.
class CardHeader extends StatelessWidget {
  final String label;
  final Widget? trailing;

  const CardHeader({super.key, required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SectionLabel(label)),
        ?trailing,
      ],
    );
  }
}

/// Estilo do chip selecionável.
///
/// - [soft]: fill + borda (planos, ordem de livros)
/// - [solid]: tile ouro quando selecionado (abas de ranking)
/// - [ghost]: só destaque sutil no selecionado (segmentos em glass)
enum AppSelectChipStyle { soft, solid, ghost }

/// Pill de escolha compartilhado — Bíblia, plano, liga, etc.
///
/// Em chrome de tela (ex.: Bíblia), passe [accent] = [AppColors.cedar].
/// Sem [accent], soft/ghost usam o amarelo do CTA ([AppColors.accent]).
class AppSelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final AppSelectChipStyle style;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? unselectedColor;
  final Color? accent;

  const AppSelectChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.style = AppSelectChipStyle.soft,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadii.pill)),
    this.fontSize = 13,
    this.fontWeight = FontWeight.w800,
    this.unselectedColor,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final chrome = accent ?? AppColors.accent;
    final gold = style == AppSelectChipStyle.solid && selected;
    final useCta = style != AppSelectChipStyle.soft;

    final Color ink;
    if (gold) {
      ink = AppColors.inkOnAccent;
    } else if (selected) {
      ink = chrome;
    } else {
      ink = unselectedColor ?? (useCta ? a.textMuted(0.7) : a.text);
    }

    final BoxDecoration decoration;
    switch (style) {
      case AppSelectChipStyle.solid:
        decoration = BoxDecoration(
          gradient: gold ? AppGradients.gold : null,
          borderRadius: borderRadius,
        );
      case AppSelectChipStyle.soft:
        decoration = BoxDecoration(
          color: selected
              ? AppMetrics.accentFill(color: chrome, alpha: 0.22)
              : a.cardFillSoft,
          borderRadius: borderRadius,
          border: Border.all(
            color: selected
                ? AppMetrics.accentBorder(color: chrome, alpha: 0.7)
                : a.cardBorder,
          ),
        );
      case AppSelectChipStyle.ghost:
        decoration = BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: 0.04) : null,
          borderRadius: borderRadius,
          border: selected
              ? Border.all(
                  color: AppMetrics.accentBorder(color: chrome, alpha: 0.45),
                )
              : null,
        );
    }

    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: useCta
          ? AppTypography.cta(size: fontSize, color: ink)
          : AppTypography.body(size: fontSize, weight: fontWeight, color: ink),
    );

    final body = Ink(padding: padding, decoration: decoration, child: text);
    if (onTap == null) return body;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: borderRadius, child: body),
    );
  }
}

/// Tile de escolha — gradiente ouro quando selecionado (Aparência, metas, etc.).
class AppChoiceTile extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final Color? selectedAccent;

  const AppChoiceTile({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.selectedAccent,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            gradient: selected && selectedAccent == null
                ? AppGradients.gold
                : null,
            color: selected ? selectedAccent : a.cardFillSoft,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(
              color: selected
                  ? (selectedAccent ?? Colors.transparent)
                  : a.cardBorder.withValues(alpha: 0.55),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
