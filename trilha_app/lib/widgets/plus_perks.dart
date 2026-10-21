import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Os benefícios do Peregrino+ — fonte única de ícone, título e frase.
/// Toda tela que lista o Plus usa [PlusPerkCard]; nada de lista própria.
enum PlusPerk {
  themeTrails,
  season,
  weeklyReview,
  readingPlans,
  consistency,
  reinforce,
  explainErrors,
  badge,
  recognition;

  /// Os três que abrem as listas curtas (ofertas, aviso, perfil).
  static const highlights = [
    PlusPerk.themeTrails,
    PlusPerk.season,
    PlusPerk.readingPlans,
    PlusPerk.weeklyReview,
  ];

  CinematicGlyph get glyph => switch (this) {
    PlusPerk.themeTrails => CinematicGlyph.path,
    PlusPerk.season => CinematicGlyph.calendar,
    PlusPerk.weeklyReview => CinematicGlyph.scroll,
    PlusPerk.readingPlans => CinematicGlyph.book,
    PlusPerk.consistency => CinematicGlyph.path,
    PlusPerk.reinforce => CinematicGlyph.target,
    PlusPerk.explainErrors => CinematicGlyph.lamp,
    PlusPerk.badge => CinematicGlyph.gift,
    PlusPerk.recognition => CinematicGlyph.heart,
  };

  String title(AppLocalizations l10n) => switch (this) {
    PlusPerk.themeTrails => l10n.paywallPerkThemesTitle,
    PlusPerk.season => l10n.paywallPerkSeasonTitle,
    PlusPerk.weeklyReview => l10n.paywallPerkWeeklyTitle,
    PlusPerk.readingPlans => l10n.paywallPerkPlansTitle,
    PlusPerk.consistency => l10n.paywallPerkStreakTitle,
    PlusPerk.reinforce => l10n.paywallPerkReinforceTitle,
    PlusPerk.explainErrors => l10n.explainErrorsTitle,
    PlusPerk.badge => l10n.paywallPerkBadgeTitle,
    PlusPerk.recognition => l10n.paywallPerkRecognitionTitle,
  };

  String body(AppLocalizations l10n) => switch (this) {
    PlusPerk.themeTrails => l10n.paywallPerkThemesBody,
    PlusPerk.season => l10n.paywallPerkSeasonBody,
    PlusPerk.weeklyReview => l10n.paywallPerkWeeklyBody,
    PlusPerk.readingPlans => l10n.paywallPerkPlansBody,
    PlusPerk.consistency => l10n.paywallPerkStreakBody,
    PlusPerk.reinforce => l10n.paywallPerkReinforceBody,
    PlusPerk.explainErrors => l10n.paywallPerkExplainBody,
    PlusPerk.badge => l10n.paywallPerkBadgeBody,
    PlusPerk.recognition => l10n.paywallPerkRecognitionBody,
  };
}

/// Cartão do Peregrino+: superfície dos cards tingida de dourado com brilho
/// no topo, rótulo dourado em caixa alta, ícones emoldurados em dourado.
///
/// [detailed] mostra todos, com a frase de cada um (paywall); o compacto
/// mostra só [PlusPerk.highlights] e "e mais N". [locked] põe o
/// cadeado à direita (aviso de fim da promoção). [boxed] false tira o
/// fundo, para quando o cartão já está dentro de outro.
class PlusPerkCard extends StatelessWidget {
  final String? header;
  final bool detailed;
  final bool locked;
  final bool boxed;
  final Widget? footer;

  const PlusPerkCard({
    super.key,
    this.header,
    this.detailed = false,
    this.locked = false,
    this.boxed = true,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final iconSize = detailed ? AppMetrics.leadingIcon : AppMetrics.iconLg;
    final perks = detailed ? PlusPerk.values : PlusPerk.highlights;
    final more = PlusPerk.values.length - perks.length;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          (header ?? l10n.plusPerksHeader).toUpperCase(),
          style: AppTypography.body(
            size: 12,
            weight: FontWeight.w800,
            color: AppRoles.reward,
          ),
        ),
        const SizedBox(height: AppSpace.md),
        for (var i = 0; i < perks.length; i++) ...[
          if (i > 0) SizedBox(height: detailed ? AppSpace.lg : 10),
          _PerkRow(
            perk: perks[i],
            iconSize: iconSize,
            detailed: detailed,
            locked: locked,
          ),
        ],
        if (more > 0) ...[
          const SizedBox(height: 10),
          Text(
            l10n.plusPerksMore(more),
            style: AppTypography.body(
              size: 13,
              weight: FontWeight.w700,
              color: Appearance.of(context).textSecondary,
            ),
          ),
        ],
        if (footer != null) ...[
          SizedBox(height: detailed ? AppSpace.lg : 10),
          footer!,
        ],
      ],
    );

    if (!boxed) return content;
    // Superfície sólida dos cards, puxada para o dourado, com brilho de
    // palco no topo — lê bem sobre a trilha do fundo.
    return GlassCard(
      tint: AppRoles.reward,
      glow: 0.5,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: content,
    );
  }
}

class _PerkRow extends StatelessWidget {
  final PlusPerk perk;
  final double iconSize;
  final bool detailed;
  final bool locked;

  const _PerkRow({
    required this.perk,
    required this.iconSize,
    required this.detailed,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: detailed
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        CinematicIcon(
          glyph: perk.glyph,
          size: iconSize,
          accent: AppRoles.reward,
        ),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                perk.title(l10n),
                style: AppTypography.title(size: 15, color: a.text),
              ),
              if (detailed) ...[
                const SizedBox(height: 2),
                Text(
                  perk.body(l10n),
                  style: AppTypography.body(size: 13, color: a.textSecondary),
                ),
              ],
            ],
          ),
        ),
        if (locked)
          CinematicIcon(
            glyph: CinematicGlyph.lock,
            size: AppMetrics.iconMd,
            accent: a.textFaint,
            framed: false,
          ),
      ],
    );
  }
}
