import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';

/// Tokens visuais compartilhados — barras, labels e badges iguais em toda a app.
class AppMetrics {
  /// Altura única das barras de progresso lineares.
  static const progressHeight = 5.0;

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
  static const leadingIcon = 34.0;

  /// Ícone compacto em badges/chips.
  static const chipIcon = 14.0;

  /// Borda padrão (branca suave).
  static Color border(BuildContext context) => Appearance.of(context).cardBorder;

  /// Borda de destaque (açafrão).
  static Color accentBorder({double alpha = 0.45}) =>
      AppColors.accent.withValues(alpha: alpha);

  /// Sombra padrão de card.
  static List<BoxShadow> cardShadow({bool elevated = false, bool accent = false}) => [
        if (accent)
          BoxShadow(
            color: AppColors.accent.withValues(alpha: elevated ? 0.28 : 0.18),
            blurRadius: elevated ? 22 : 16,
            offset: const Offset(0, 8),
          ),
        BoxShadow(
          color: Colors.black.withValues(alpha: elevated ? 0.32 : 0.22),
          blurRadius: elevated ? 16 : 10,
          offset: Offset(0, elevated ? 8 : 4),
        ),
      ];
}

/// Botão CTA açafrão — ação principal em cards e telas.
class CopperCta extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final CinematicGlyph? trailing;
  final bool expanded;
  final EdgeInsetsGeometry padding;
  final bool showArrow;

  const CopperCta({
    super.key,
    required this.label,
    this.onTap,
    this.trailing = CinematicGlyph.path,
    this.expanded = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppGradients.gold,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.4),
            offset: const Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Text(label.toUpperCase(), style: AppTypography.cta(size: 14)),
          if (showArrow) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: AppColors.inkOnAccent,
            ),
          ] else if (trailing != null) ...[
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
    );

    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, child: child);
  }
}

/// Barra de progresso fina padronizada.
class AppProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final Color? trackColor;
  final double height;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color,
    this.trackColor,
    this.height = AppMetrics.progressHeight,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: trackColor ?? a.progressTrack,
        color: color ?? AppColors.accent,
      ),
    );
  }
}

/// Label de seção — uppercase, tracking fixo (MISSÕES DIÁRIAS, etc.).
class SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  final double size;

  const SectionLabel(
    this.text, {
    super.key,
    this.color,
    this.size = 11,
  });

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
  final Color? background;
  final bool filled;

  const CountBadge(
    this.text, {
    super.key,
    this.color,
    this.background,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final ink = color ?? AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled
            ? (background ?? ink.withValues(alpha: 0.14))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: filled ? null : Border.all(color: ink.withValues(alpha: 0.28)),
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

/// Chip/badge suave com ícone brand ou Material (legacy).
class SoftBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final CinematicGlyph? glyph;
  final Color? accent;
  final Color? textColor;
  final bool bordered;

  const SoftBadge({
    super.key,
    required this.text,
    this.icon,
    this.glyph,
    this.accent,
    this.textColor,
    this.bordered = true,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final tone = accent ?? AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: bordered
            ? Border.all(color: tone.withValues(alpha: 0.22))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (glyph != null) ...[
            CinematicIcon(
              glyph: glyph!,
              size: AppMetrics.chipIcon,
              accent: tone.withValues(alpha: 0.95),
              framed: false,
            ),
            const SizedBox(width: 4),
          ] else if (icon != null) ...[
            Icon(icon, size: AppMetrics.chipIcon, color: tone.withValues(alpha: 0.95)),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w800,
              color: textColor ?? a.text.withValues(alpha: 0.9),
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

  const CardHeader({
    super.key,
    required this.label,
    this.trailing,
  });

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
