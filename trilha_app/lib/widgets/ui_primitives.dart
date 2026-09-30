import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';

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

  /// Palco da próxima missão na Home — precisa ocupar o primeiro viewport,
  /// não parecer mais um tile na lista.
  static double heroStageHeight(double screenHeight) =>
      (screenHeight * 0.52).clamp(380.0, 520.0);

  /// Ícone leading em listas (quests, trilhas).
  static const leadingIcon = 40.0;

  /// Ícone compacto em badges/chips.
  static const chipIcon = 14.0;

  /// Escala de ícone solto (sem poço). Nada fora dela.
  static const iconSm = 16.0;
  static const iconMd = 20.0;
  static const iconLg = 24.0;

  /// Ícone de herói de sheet / estado vazio / celebração.
  static const iconHero = 56.0;

  /// Raio do [UserAvatar]: pequeno (lista densa, grupo), médio (row),
  /// grande (palco da companhia / perfil de alguém).
  static const avatarSm = 16.0;
  static const avatarMd = 20.0;
  static const avatarLg = 30.0;

  /// Retrato de identidade: cartão do peregrino ([avatarXl]) e herói do
  /// perfil ([avatarHero]). Só nesses dois lugares.
  static const avatarXl = 40.0;
  static const avatarHero = 52.0;

  /// Espessura de borda dos painéis.
  static const cardBorderWidth = 1.75;

  /// Borda de destaque — amarelo do CTA por padrão (nunca ≤0.5: vira “dourado”).
  static Color accentBorder({double alpha = 0.85, Color? color}) =>
      (color ?? AppColors.accent).withValues(alpha: alpha.clamp(0.55, 1.0));

  /// Fill suave sobre accent (chips) — borda separada via [accentBorder].
  static Color accentFill({double alpha = 0.18, Color? color}) =>
      (color ?? AppColors.accent).withValues(alpha: alpha);

  /// Sombra de painel — lip duro embaixo + soft ambient.
  /// [hardLip] false: só o halo, sem a faixa preta que parece outro card.
  static List<BoxShadow> cardShadow({
    bool elevated = false,
    bool accent = false,
    Color? tint,
    bool hardLip = true,
  }) {
    final lip = elevated ? 5.0 : 4.0;
    return [
      if (hardLip)
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

  /// Brilho do CTA ouro — o mesmo do botão do site
  /// (`0 12px 34px rgba(247,187,1,.26)`).
  static List<BoxShadow> accentGlow({
    double blur = 34,
    double alpha = 0.26,
    Offset offset = const Offset(0, 12),
    Color? color,
  }) => [
    BoxShadow(
      color: (color ?? AppColors.accent).withValues(alpha: alpha),
      blurRadius: blur,
      offset: offset,
    ),
  ];
}

/// Botão CTA ouro — ação principal em cards, sheets e telas.
///
/// Mesmo padrão do botão do site (`.btn-gold`): fill [AppColors.accent],
/// raio [AppRadii.md], altura fixa (52; 44 quando [dense]), texto normal
/// (sem caixa alta), brilho dourado embaixo e leve aperto no toque.
class CopperCta extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final CinematicGlyph? trailing;
  final CinematicGlyph? leading;
  final bool expanded;
  final EdgeInsetsGeometry? padding;
  final bool showArrow;
  final bool dense;

  /// Herói: mais alto e com letra maior (card "Continuar" da Hoje).
  final bool large;

  /// Só desenho — o toque é do pai (ex.: o card inteiro é o botão).
  /// Fica em opacidade cheia mesmo sem [onTap].
  final bool decorative;

  /// Brilho dourado. Ligado por padrão (padrão do site); desligue em
  /// listas densas onde vários botões ficam lado a lado.
  final bool showGlow;
  final bool busy;

  /// 0–1: o fundo enche da esquerda para a direita (contagem até avançar).
  final double? progress;

  static const height = 52.0;
  static const denseHeight = 44.0;
  static const largeHeight = 60.0;

  const CopperCta({
    super.key,
    required this.label,
    this.onTap,
    this.trailing = CinematicGlyph.forward,
    this.leading,
    this.expanded = true,
    this.padding,
    this.showArrow = false,
    this.dense = false,
    this.large = false,
    this.decorative = false,
    this.showGlow = true,
    this.busy = false,
    this.progress,
  });

  /// Texto do botão: Nunito 700, espaçamento leve — como no site.
  static TextStyle labelStyle({double size = 16, Color? color}) =>
      AppTypography.body(
        size: size,
        weight: FontWeight.w700,
        color: color ?? AppColors.inkOnAccent,
      ).copyWith(letterSpacing: 0.32, height: 1.1);

  @override
  State<CopperCta> createState() => _CopperCtaState();
}

class _CopperCtaState extends State<CopperCta> {
  bool _down = false;

  /// Parte cheia em ouro; o resto em ouro apagado, como uma barra dentro do botão.
  static LinearGradient _fillGradient(double t) {
    final dim = Color.lerp(AppRoles.action, Colors.black, 0.32)!;
    return LinearGradient(
      colors: [AppRoles.action, AppRoles.action, dim, dim],
      stops: [0, t, t, 1],
    );
  }

  void _press(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final enabled = w.onTap != null && !w.busy;
    final lit = enabled || w.decorative;
    final pad =
        w.padding ?? const EdgeInsets.symmetric(horizontal: AppSpace.lg);
    final fontSize = w.dense ? 14.0 : (w.large ? 18.0 : 16.0);
    final glow = w.showGlow && lit
        ? (w.dense
              ? AppMetrics.accentGlow(
                  blur: 20,
                  alpha: 0.2,
                  offset: const Offset(0, 6),
                )
              : AppMetrics.accentGlow())
        : null;

    // Desligado não é "amarelo apagado" (vira oliva no céu): poço neutro.
    final off = !lit && !w.busy;
    final a = Appearance.of(context);
    final ink = off ? a.textFaint : AppColors.inkOnAccent;
    final child = AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: 1,
      child: AnimatedScale(
        scale: _down ? 0.98 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          width: w.expanded ? double.infinity : null,
          constraints: BoxConstraints(
            minHeight: w.dense
                ? CopperCta.denseHeight
                : (w.large ? CopperCta.largeHeight : CopperCta.height),
          ),
          padding: pad,
          decoration: BoxDecoration(
            color: off
                ? a.insetFill
                : (w.progress == null ? AppRoles.action : null),
            gradient: off || w.progress == null
                ? null
                : _fillGradient(w.progress!.clamp(0.0, 1.0)),
            border: off ? Border.all(color: a.insetBorder) : null,
            borderRadius: BorderRadius.circular(AppRadii.md),
            boxShadow: glow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: w.expanded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (w.busy) ...[
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.inkOnAccent,
                  ),
                ),
                const SizedBox(width: 10),
              ] else if (w.leading != null) ...[
                CinematicIcon(
                  glyph: w.leading!,
                  size: w.dense ? 16 : 18,
                  accent: ink,
                  framed: false,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  w.label,
                  textAlign: TextAlign.center,
                  style: CopperCta.labelStyle(size: fontSize, color: ink),
                ),
              ),
              if (!w.busy && w.showArrow) ...[
                const SizedBox(width: 8),
                CinematicIcon(
                  glyph: CinematicGlyph.forward,
                  size: 18,
                  accent: ink,
                  framed: false,
                ),
              ] else if (!w.busy && w.trailing != null) ...[
                const SizedBox(width: 8),
                CinematicIcon(
                  glyph: w.trailing!,
                  size: 16,
                  accent: ink,
                  framed: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled
            ? () {
                ActHaptics.tap();
                w.onTap!();
              }
            : null,
        onTapDown: enabled ? (_) => _press(true) : null,
        onTapUp: enabled ? (_) => _press(false) : null,
        onTapCancel: enabled ? () => _press(false) : null,
        child: child,
      ),
    );
  }
}

/// Seta de lista — mesmo glifo em todas as rows.
class ListChevron extends StatelessWidget {
  final Color color;
  final double size;

  const ListChevron({super.key, required this.color, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return CinematicIcon(
      glyph: CinematicGlyph.chevron,
      size: size,
      accent: color,
      framed: false,
    );
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
    this.uppercase = false,
  });

  @override
  Widget build(BuildContext context) {
    final ink = color ?? AppRoles.chrome;
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
              style: uppercase
                  ? AppTypography.cta(size: 13, color: textColor)
                  : CopperCta.labelStyle(size: 15, color: textColor),
            ),
          ],
        ),
      ),
    );

    if (!enabled) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ActHaptics.tap();
          onTap!();
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
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

  /// Mesma altura e fonte do [CopperCta] — para quando os dois são
  /// escolhas lado a lado (ex.: tentar de novo / pular).
  final bool matchCopper;

  const GhostCta({
    super.key,
    required this.label,
    this.onTap,
    this.leading,
    this.danger = false,
    this.expanded = false,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    this.matchCopper = false,
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
        onTap: onTap == null
            ? null
            : () {
                danger ? ActHaptics.confirm() : ActHaptics.tap();
                onTap!();
              },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          width: expanded ? double.infinity : null,
          // Mesma família do CTA ouro (`.btn-ghost` do site): cantos 14,
          // altura mínima confortável, texto normal.
          constraints: BoxConstraints(
            minHeight: matchCopper ? CopperCta.height : 48,
          ),
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
                  style: CopperCta.labelStyle(
                    size: matchCopper ? 16 : 14,
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

/// Barra de progresso chapada — fill sólido, sem bevel.
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
    final fill = color ?? AppRoles.chrome;
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
                          color: fill,
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

/// Ação terciária em texto (agora não, atualizar, sair) — alvo ≥ 44dp,
/// sem competir com o CTA principal. Substitui TextButton no app.
class TextCta extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool danger;
  final CinematicGlyph? leading;
  final Color? color;

  const TextCta({
    super.key,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.leading,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final base =
        color ??
        (danger ? AppColors.error.withValues(alpha: 0.9) : a.textMuted(0.72));
    final ink = onTap == null ? base.withValues(alpha: 0.4) : base;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  danger ? ActHaptics.confirm() : ActHaptics.tap();
                  onTap!();
                },
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leading != null) ...[
                    CinematicIcon(
                      glyph: leading!,
                      size: 16,
                      accent: ink,
                      framed: false,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppTypography.body(
                        size: 13,
                        weight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Poço dentro de um card — agrupa um trecho (semana, código, versão)
/// sem virar outro card: fundo mais fundo, borda quase invisível.
class InsetPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  const InsetPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.md),
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: a.insetFill,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: borderColor ?? a.insetBorder),
      ),
      child: child,
    );
  }
}

/// Eyebrow / rótulo de seção — o ÚNICO jeito de escrever texto pequeno em
/// maiúsculas. Escreva a string em caixa normal; ele caixa-alta sozinho.
/// Cor padrão [AppearanceStyle.sectionLabel]; accent só em destaque.
class SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  final double size;
  final TextAlign? textAlign;

  const SectionLabel(
    this.text, {
    super.key,
    this.color,
    this.size = 11,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Text(
      text.toUpperCase(),
      textAlign: textAlign,
      style: AppTypography.label(
        size: size,
        letterSpacing: 1.3,
        color: color ?? a.sectionLabel,
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
    final ink = color ?? AppRoles.chrome;
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

  /// Preenchido na cor do tom (recompensa, “Ativo”) — texto escuro.
  final bool solid;

  const SoftBadge({
    super.key,
    required this.text,
    this.glyph,
    this.accent,
    this.textColor,
    this.bordered = true,
    this.solid = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final tone = accent ?? AppRoles.chrome;
    final isBrand = tone.toARGB32() == AppColors.accent.toARGB32();
    final ink = solid ? AppColors.inkOnAccent : (textColor ?? a.text);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: solid ? tone : tone.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: bordered && !solid
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
              accent: solid ? ink : tone,
              framed: false,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w800,
              color: ink,
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
  final CinematicGlyph? glyph;
  final Color? accent;

  const CardHeader({
    super.key,
    required this.label,
    this.trailing,
    this.glyph,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final mark = accent ?? a.sectionLabel;
    return Row(
      children: [
        if (glyph != null) ...[
          CinematicIcon(
            glyph: glyph!,
            size: 16,
            accent: mark,
            framed: false,
            glowing: false,
          ),
          const SizedBox(width: 8),
        ],
        Expanded(child: SectionLabel(label, color: accent)),
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
/// Seleção é contorno claro ([AppRoles.selected]) — amarelo é só ação e
/// recompensa. Passe [accent] só quando a escolha é de um modo/área.
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
    final chrome = accent ?? AppRoles.selected;
    final gold = style == AppSelectChipStyle.solid && selected;
    final useCta = style != AppSelectChipStyle.soft;

    final Color ink;
    if (gold) {
      ink = AppColors.night;
    } else if (selected) {
      ink = chrome;
    } else {
      ink = unselectedColor ?? (useCta ? a.textMuted(0.7) : a.text);
    }

    final BoxDecoration decoration;
    switch (style) {
      case AppSelectChipStyle.solid:
        decoration = BoxDecoration(
          color: gold ? chrome : null,
          borderRadius: borderRadius,
        );
      case AppSelectChipStyle.soft:
        decoration = BoxDecoration(
          color: selected
              ? AppMetrics.accentFill(color: chrome, alpha: 0.12)
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
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        borderRadius: borderRadius,
        child: body,
      ),
    );
  }
}

/// Tile de escolha — contorno claro quando selecionado (metas, horários…).
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
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? (selectedAccent ?? AppRoles.selected).withValues(alpha: 0.12)
                : a.cardFillSoft,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(
              color: selected
                  ? (selectedAccent ?? AppRoles.selected)
                  : a.cardBorder.withValues(alpha: 0.55),
              width: selected ? 2 : 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

enum AppToastTone { accent, warn }

/// Aviso cinematográfico — flutuante, filete dourado, acima da nav.
void showAppToast(
  ScaffoldMessengerState messenger, {
  required String message,
  CinematicGlyph glyph = CinematicGlyph.check,
  AppToastTone tone = AppToastTone.accent,
  double? bottomGap,
}) {
  final accent = tone == AppToastTone.warn ? AppRoles.risk : AppRoles.success;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      duration: const Duration(milliseconds: 3400),
      margin: EdgeInsets.fromLTRB(AppSpace.md, 0, AppSpace.md, bottomGap ?? 96),
      content: _AppToastCard(message: message, glyph: glyph, accent: accent),
    ),
  );
}

void showAppToastFor(
  BuildContext context, {
  required String message,
  CinematicGlyph glyph = CinematicGlyph.check,
  AppToastTone tone = AppToastTone.accent,
}) {
  showAppToast(
    ScaffoldMessenger.of(context),
    message: message,
    glyph: glyph,
    tone: tone,
    bottomGap: scrollPaddingBelowNav(context),
  );
}

class _AppToastCard extends StatelessWidget {
  final String message;
  final CinematicGlyph glyph;
  final Color accent;

  const _AppToastCard({
    required this.message,
    required this.glyph,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        color: AppColors.nightElevated,
        border: Border.all(color: accent.withValues(alpha: 0.85), width: 1.75),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.md - 1),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, color: accent),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                child: CinematicIcon(
                  glyph: glyph,
                  size: 22,
                  accent: accent,
                  framed: false,
                  glowing: true,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 14, 12),
                  child: Text(
                    message,
                    style: AppTypography.body(
                      size: 14,
                      weight: FontWeight.w800,
                      height: 1.3,
                      color: AppColors.textOnDark,
                    ),
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

/// Divisória entre rows de um card — uma cor, 1px. [indent] alinha com o
/// texto quando a row tem ícone à esquerda.
class ListDivider extends StatelessWidget {
  final double indent;
  final double endIndent;

  const ListDivider({super.key, this.indent = 0, this.endIndent = 0});

  /// Recuo padrão para rows com ícone de [AppMetrics.leadingIcon].
  static const iconIndent = AppSpace.lg + AppMetrics.leadingIcon + AppSpace.md;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Padding(
      padding: EdgeInsets.only(left: indent, right: endIndent),
      child: SizedBox(
        height: 1,
        width: double.infinity,
        child: ColoredBox(color: a.divider),
      ),
    );
  }
}

/// Ponto de novidade (aba, card, avatar). Um tamanho, um anel na cor da
/// superfície por baixo.
class AlertDot extends StatelessWidget {
  final Color color;
  final Color? ring;
  final double size;
  final bool glow;

  const AlertDot({
    super.key,
    this.color = AppColors.streak,
    this.ring,
    this.size = 9,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: ring ?? a.cardFill, width: 1.5),
        boxShadow: glow
            ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8)]
            : null,
      ),
    );
  }
}

/// Carregando — um spinner só. [inline] para dentro de botão/linha.
class AppSpinner extends StatelessWidget {
  final Color color;
  final bool inline;

  const AppSpinner({
    super.key,
    this.color = AppRoles.chrome,
    this.inline = false,
  });

  @override
  Widget build(BuildContext context) {
    final spinner = CircularProgressIndicator(
      color: color,
      strokeWidth: inline ? 2 : 3,
    );
    if (!inline) return Center(child: spinner);
    return SizedBox(width: 18, height: 18, child: spinner);
  }
}

/// Título de sheet — eyebrow opcional, título 20 e apoio. Use no topo de
/// todo [AppSheetPanel] comum; celebração usa [celebration] (display 28).
class AppSheetHeader extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget? leading;
  final Color? eyebrowColor;
  final bool center;
  final bool celebration;

  const AppSheetHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.leading,
    this.eyebrowColor,
    this.center = false,
    this.celebration = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final align = center ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading!, const SizedBox(height: AppSpace.md)],
        if (eyebrow != null) ...[
          SectionLabel(eyebrow!, color: eyebrowColor, textAlign: align),
          const SizedBox(height: 6),
        ],
        Text(
          title,
          textAlign: align,
          style: celebration
              ? AppTypography.display(size: 28, color: a.text)
              : AppTypography.title(size: 20, color: a.text),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: align,
            style: AppTypography.body(
              size: 14,
              height: 1.4,
              color: a.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Estado vazio — glifo 40, título, texto e CTA opcional.
class EmptyState extends StatelessWidget {
  final CinematicGlyph glyph;
  final String title;
  final String? body;
  final Widget? action;
  final Color? accent;

  const EmptyState({
    super.key,
    required this.glyph,
    required this.title,
    this.body,
    this.action,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.lg,
        vertical: AppSpace.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CinematicIcon(
            glyph: glyph,
            size: AppMetrics.leadingIcon,
            accent: accent ?? AppRoles.chrome,
          ),
          const SizedBox(height: AppSpace.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 18, color: a.text),
          ),
          if (body != null) ...[
            const SizedBox(height: 6),
            Text(
              body!,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 14,
                height: 1.4,
                color: a.textSecondary,
              ),
            ),
          ],
          if (action != null) ...[const SizedBox(height: AppSpace.lg), action!],
        ],
      ),
    );
  }
}

/// Aviso de erro inline — o mesmo em todo o app. Glifo de erro, texto de
/// apoio (nunca vermelho solto) e, se houver [onRetry], "Tentar de novo".
///
/// [standalone]: card próprio numa lista ([GlassCard]); `false` quando o
/// erro fica dentro de outro card ([InsetPanel] com borda de erro).
class InlineNotice extends StatelessWidget {
  final String message;
  final Future<void> Function()? onRetry;
  final bool busy;
  final bool standalone;

  const InlineNotice({
    super.key,
    required this.message,
    this.onRetry,
    this.busy = false,
    this.standalone = true,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final row = Row(
      children: [
        const CinematicIcon(
          glyph: CinematicGlyph.wrong,
          size: AppMetrics.iconMd,
          accent: AppRoles.error,
          framed: false,
        ),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Text(
            message,
            style: AppTypography.body(
              size: 13,
              height: 1.35,
              color: a.textSecondary,
            ),
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(width: AppSpace.sm),
          busy
              ? const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(child: AppSpinner(inline: true)),
                )
              : TextCta(
                  label: context.l10n.commonTryAgain,
                  leading: CinematicGlyph.refresh,
                  onTap: onRetry,
                ),
        ],
      ],
    );
    if (standalone) {
      return GlassCard(padding: AppMetrics.cardPaddingCompact, child: row);
    }
    return InsetPanel(
      borderColor: AppRoles.error.withValues(alpha: 0.45),
      child: row,
    );
  }
}
