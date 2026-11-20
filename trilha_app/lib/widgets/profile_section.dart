import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Linguagem única dos quadros do Perfil: painel noturno de veludo, moldura
/// de luz na cor da seção, brilho no canto do ícone e o mesmo cabeçalho
/// (disco com ícone, título em serifa, ação à direita). Só a cor muda de um
/// quadro para outro — Sequência, Tarefas, Cofre, Estudo, Palavra.
class ProfileSection extends StatelessWidget {
  final Color accent;
  final CinematicGlyph glyph;
  final String title;
  final String? caption;
  final Widget? trailing;

  /// Corpo do quadro; sem ele, só o cabeçalho (estados vazios).
  final Widget? child;

  /// Camadas extras atrás do conteúdo (a luz e a poeira do Cofre).
  final List<Widget> backdrop;

  /// Toque no quadro inteiro (Na Palavra abre a folha).
  final VoidCallback? onTap;

  /// Mais luz na moldura — cores frias (azul) somem no fundo noturno.
  final bool lit;

  /// Sempre noite, em qualquer céu (Cofre, palcos pintados).
  final bool night;

  const ProfileSection({
    super.key,
    required this.accent,
    required this.glyph,
    required this.title,
    this.child,
    this.caption,
    this.trailing,
    this.backdrop = const [],
    this.onTap,
    this.lit = false,
    this.night = false,
  });

  @override
  Widget build(BuildContext context) {
    return ProfilePanel(
      accent: accent,
      backdrop: backdrop,
      onTap: onTap,
      lit: lit,
      night: night,
      padding: EdgeInsets.fromLTRB(
        AppSpace.md,
        AppSpace.md,
        AppSpace.md,
        child == null ? AppSpace.md : AppSpace.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileSectionHeader(
            accent: accent,
            glyph: glyph,
            title: title,
            caption: caption,
            trailing: trailing,
          ),
          if (child case final body?) ...[
            const SizedBox(height: AppSpace.md),
            body,
          ],
        ],
      ),
    );
  }
}

/// A moldura dos quadros do Perfil sem o cabeçalho: veludo noturno, borda
/// de luz na cor [accent] e brilho no canto. Serve a qualquer card que deva
/// falar a mesma língua do Perfil (Juntos, Companhia, Desafio).
class ProfilePanel extends StatelessWidget {
  final Color accent;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final List<Widget> backdrop;
  final VoidCallback? onTap;

  /// Mais luz na moldura e no canto — o card pede ação ou celebra.
  final bool lit;

  /// Sempre noite, em qualquer céu: pinturas, Cofre, palcos — o que só
  /// brilha no escuro. Os outros painéis seguem o céu do app.
  final bool night;

  const ProfilePanel({
    super.key,
    required this.accent,
    required this.child,
    this.padding = AppMetrics.cardPadding,
    this.backdrop = const [],
    this.onTap,
    this.lit = false,
    this.night = false,
  });

  static const nightBase = Color(0xFF0A0F1E);

  /// Cor de fundo do painel em cada céu (o pé dos degradês de pintura).
  static Color baseOf(AppearanceStyle style) {
    if (!style.onDark) return Color.lerp(style.cardFill, Colors.white, 0.45)!;
    if (style.look == AppearanceLook.night) return nightBase;
    return Color.lerp(style.cardFill, nightBase, 0.5)!;
  }

  @override
  Widget build(BuildContext context) {
    final outer = Appearance.of(context);
    final forceNight = night && outer.look != AppearanceLook.night;
    final style = forceNight
        ? AppearanceStyle.resolve(AppearanceMode.night)
        : outer;
    final dark = style.onDark;

    // Fundo: veludo na cor da seção. Noite = quase preto; tarde = o azul
    // da tarde mais fundo; manhã = papel claro com um véu da cor.
    final Color base;
    final Color top;
    if (!dark) {
      // Papel claro como o dos cards de Explorar, com um véu leve da cor.
      base = Color.lerp(style.cardFill, Colors.white, 0.45)!;
      top = Color.lerp(base, accent, lit ? 0.12 : 0.08)!;
    } else if (style.look == AppearanceLook.night) {
      base = nightBase;
      top = Color.lerp(accent, nightBase, lit ? 0.78 : 0.84)!;
    } else {
      base = Color.lerp(style.cardFill, nightBase, 0.5)!;
      top = Color.lerp(accent, base, lit ? 0.8 : 0.86)!;
    }
    final glow = dark ? (lit ? 0.32 : 0.22) : (lit ? 0.2 : 0.14);
    final edgeHi = dark
        ? Color.lerp(accent, Colors.white, 0.35)!.withValues(alpha: 0.85)
        : accent.withValues(alpha: 0.9);

    final panel = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        // Moldura: a luz da seção bate em cima e some embaixo.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            edgeHi,
            accent.withValues(alpha: lit ? 0.5 : (dark ? 0.30 : 0.4)),
            accent.withValues(alpha: lit ? 0.24 : (dark ? 0.12 : 0.2)),
          ],
          stops: const [0, 0.45, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: dark
                ? accent.withValues(alpha: lit ? 0.3 : 0.16)
                : Color.lerp(
                    accent,
                    Colors.black,
                    0.4,
                  )!.withValues(alpha: lit ? 0.22 : 0.14),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg - 1.2),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [top, base],
                  ),
                ),
              ),
            ),
            // Brilho no canto do ícone.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.95, -1.05),
                      radius: 1.0,
                      colors: [
                        accent.withValues(alpha: glow),
                        accent.withValues(alpha: 0.06),
                        accent.withValues(alpha: 0),
                      ],
                      stops: const [0, 0.45, 1],
                    ),
                  ),
                ),
              ),
            ),
            ...backdrop,
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );

    final tap = onTap;
    final body = tap == null
        ? panel
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: tap,
            child: panel,
          );
    if (!forceNight) return body;
    return Appearance(style: style, mode: AppearanceMode.night, child: body);
  }
}

/// Cabeçalho comum: disco com o ícone na cor da seção, título em serifa,
/// legenda curta e a ação (olho, contagem, seta) à direita.
class ProfileSectionHeader extends StatelessWidget {
  final Color accent;
  final CinematicGlyph glyph;
  final String title;
  final String? caption;
  final Widget? trailing;

  const ProfileSectionHeader({
    super.key,
    required this.accent,
    required this.glyph,
    required this.title,
    this.caption,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    // Glifo: um pouco de luz na noite, um pouco de tinta no papel claro.
    final ink = a.onDark
        ? Color.lerp(accent, Colors.white, 0.15)!
        : a.ink(accent);
    final caption = this.caption;
    final trailing = this.trailing;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                accent.withValues(alpha: a.onDark ? 0.32 : 0.22),
                accent.withValues(alpha: a.onDark ? 0.12 : 0.08),
              ],
            ),
            border: Border.all(color: accent.withValues(alpha: 0.55)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: a.onDark ? 0.3 : 0.18),
                blurRadius: 10,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: CinematicIcon(
            glyph: glyph,
            size: 17,
            accent: ink,
            framed: false,
          ),
        ),
        const SizedBox(width: AppSpace.sm + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.display(
                  size: 22,
                  color: a.text,
                  height: 1.05,
                ),
              ),
              if (caption != null)
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(
                    size: 12,
                    weight: FontWeight.w700,
                    color: a.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
