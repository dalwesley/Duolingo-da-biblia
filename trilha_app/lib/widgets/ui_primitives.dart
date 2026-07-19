import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';

/// Tokens visuais compartilhados — barras, labels e badges iguais em toda a app.
class AppMetrics {
  /// Altura única das barras de progresso lineares.
  static const progressHeight = 4.0;

  /// Padding padrão dos GlassCards de conteúdo.
  static const cardPadding = EdgeInsets.fromLTRB(16, 14, 16, 14);

  /// Raio padrão dos cards (alias de [AppRadii.lg]).
  static const cardRadius = AppRadii.lg;
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
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Text(
      text.toUpperCase(),
      style: AppTypography.label(
        size: size,
        letterSpacing: 1.2,
        color: color ?? a.text.withValues(alpha: 0.92),
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
        border: filled
            ? null
            : Border.all(color: ink.withValues(alpha: 0.28)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: ink,
          height: 1.1,
        ),
      ),
    );
  }
}

/// Chip/badge suave com ícone opcional (streak, status).
class SoftBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? accent;
  final Color? textColor;
  final bool bordered;

  const SoftBadge({
    super.key,
    required this.text,
    this.icon,
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
          if (icon != null) ...[
            Icon(icon, size: 14, color: tone.withValues(alpha: 0.95)),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
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
