import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Card de perfil / relíquia — um [GlassCard] com wash e filete sutis na
/// cor de [accent]. O padrão é chrome (card comum do perfil); medalha, baú e
/// selo pedem [AppRoles.reward] explicitamente.
class RelicPanel extends StatelessWidget {
  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool elevated;

  const RelicPanel({
    super.key,
    required this.child,
    this.accent = AppRoles.chrome,
    this.padding = AppMetrics.cardPadding,
    this.onTap,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      elevated: elevated,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppMetrics.cardRadius),
        child: Stack(
          children: [
            Positioned.fill(child: RelicAtmosphere(accent: accent)),
            Positioned(
              left: 22,
              right: 22,
              top: 0,
              child: Container(
                height: 1.15,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      accent.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// Wash radial sutil — o mesmo fôlego dos selos e do cofre.
class RelicAtmosphere extends StatelessWidget {
  final Color accent;

  const RelicAtmosphere({super.key, this.accent = AppRoles.chrome});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.92),
            radius: 1.18,
            colors: [
              accent.withValues(alpha: 0.1),
              accent.withValues(alpha: 0.03),
              Colors.transparent,
            ],
            stops: const [0.0, 0.42, 1.0],
          ),
        ),
      ),
    );
  }
}

class RelicChapter extends StatelessWidget {
  final String title;
  final String? whisper;
  final Color accent;
  final Widget? trailing;
  final bool displayTitle;

  /// Ação no canto (olho de privacidade), depois de [trailing].
  final Widget? action;

  /// Filete sob a linha do título: título · olho, filete, conteúdo.
  final bool divided;

  const RelicChapter({
    super.key,
    required this.title,
    this.whisper,
    this.accent = AppRoles.chrome,
    this.trailing,
    this.displayTitle = true,
    this.action,
    this.divided = true,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(AppRadii.hair),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displayTitle ? title : title.toUpperCase(),
                style: displayTitle
                    ? AppTypography.title(size: 16, color: a.text)
                    : AppTypography.label(
                        size: 11,
                        letterSpacing: 1.4,
                        color: a.sectionLabel,
                      ),
              ),
            ),
            ?trailing,
            ?action,
          ],
        ),
        if (divided) ...[
          const SizedBox(height: AppSpace.sm),
          Container(
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.hair),
              color: a.divider,
            ),
          ),
        ],
        if (whisper != null && whisper!.isNotEmpty) ...[
          SizedBox(height: divided ? AppSpace.sm : 6),
          Padding(
            padding: const EdgeInsets.only(left: 13),
            child: Text(
              whisper!,
              style: AppTypography.body(size: 12, color: a.textSecondary),
            ),
          ),
        ],
      ],
    );
  }
}

class RelicHairline extends StatelessWidget {
  final Color accent;

  const RelicHairline({super.key, this.accent = AppRoles.chrome});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            accent.withValues(alpha: 0.28),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

/// Filamento decorativo — não a barra de HUD. Para dado que outra tela
/// mostra em barra (progresso de trilha), use [AppProgressBar].
class RelicProgress extends StatelessWidget {
  final double value;
  final Color accent;

  const RelicProgress({
    super.key,
    required this.value,
    this.accent = AppRoles.chrome,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final t = value.clamp(0.0, 1.0);
    return SizedBox(
      height: 3,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.hair),
              color: a.progressTrack,
            ),
          ),
          if (t > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: t,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.hair),
                    gradient: LinearGradient(
                      colors: [accent.withValues(alpha: 0.55), accent],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Ícone de seção (tarefas, sequência, recorde, trilha, privacidade…).
///
/// Chapado num quadrado arredondado de propósito: moeda de metal em relevo
/// é só medalha, lacre de cera é só selo — o resto não pode parecer
/// conquista.
class RelicDisc extends StatelessWidget {
  final CinematicGlyph? glyph;
  final String? mark;
  final Color accent;
  final double size;
  final bool lit;

  const RelicDisc({
    super.key,
    this.glyph,
    this.mark,
    required this.accent,
    this.size = 44,
    this.lit = true,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final ink = lit ? accent : a.textFaint;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ink.withValues(alpha: lit ? 0.14 : 0.06),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: ink.withValues(alpha: lit ? 0.4 : 0.2)),
      ),
      alignment: Alignment.center,
      child: glyph != null
          ? CinematicIcon(
              glyph: glyph!,
              size: size * 0.5,
              accent: ink,
              framed: false,
            )
          : (mark != null
                ? Text(
                    mark!,
                    style: AppTypography.title(
                      size: size * 0.34,
                      exact: true,
                      weight: FontWeight.w900,
                      color: ink,
                    ),
                  )
                : null),
    );
  }
}

class RelicMetal {
  final Color rimLight;
  final Color rimDark;
  final Color faceLight;
  final Color faceMid;
  final Color faceDark;
  final Color glyph;
  final Color groove;
  final Color ridge;

  const RelicMetal({
    required this.rimLight,
    required this.rimDark,
    required this.faceLight,
    required this.faceMid,
    required this.faceDark,
    required this.glyph,
    required this.groove,
    required this.ridge,
  });

  factory RelicMetal.fromAccent(Color accent, {required bool lit}) {
    if (!lit) {
      return const RelicMetal(
        rimLight: Color(0xFF4A5260),
        rimDark: Color(0xFF181C22),
        faceLight: Color(0xFF323A48),
        faceMid: Color(0xFF222830),
        faceDark: Color(0xFF12161C),
        glyph: Color(0xFF8A8070),
        groove: Color(0xFF101218),
        ridge: Color(0xFF5A5248),
      );
    }
    final light = Color.lerp(accent, const Color(0xFFFFF0C8), 0.42)!;
    final mid = Color.lerp(accent, const Color(0xFF8A6020), 0.28)!;
    final dark = Color.lerp(accent, const Color(0xFF1A1208), 0.55)!;
    return RelicMetal(
      rimLight: light,
      rimDark: dark,
      faceLight: Color.lerp(accent, light, 0.35)!,
      faceMid: mid,
      faceDark: dark,
      glyph: Color.lerp(accent, const Color(0xFFFFF6D8), 0.62)!,
      groove: Color.lerp(accent, const Color(0xFF140C04), 0.82)!,
      ridge: const Color(0xFFFFF4D0),
    );
  }
}
