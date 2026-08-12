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

/// Painel de cena na lição (estudo / pergunta / memória) — glass translúcido.
class ScenePanel extends StatelessWidget {
  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry padding;
  final double radius;

  const ScenePanel({
    super.key,
    required this.child,
    required this.accent,
    this.padding = const EdgeInsets.all(AppSpace.lg),
    this.radius = AppRadii.lg,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: AppColors.nightElevated.withValues(alpha: 0.72),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: AppMetrics.cardShadow(elevated: true),
        ),
        child: child,
      ),
    );
  }
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
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpace.lg,
      vertical: AppSpace.lg,
    ),
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppGradients.gold,
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: AppMetrics.accentGlow(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Text(label.toUpperCase(), style: AppTypography.cta(size: 15)),
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
