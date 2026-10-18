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
  season,
  weeklyReview,
  consistency,
  reinforce,
  badge;

  CinematicGlyph get glyph => switch (this) {
    PlusPerk.season => CinematicGlyph.calendar,
    PlusPerk.weeklyReview => CinematicGlyph.scroll,
    PlusPerk.consistency => CinematicGlyph.path,
    PlusPerk.reinforce => CinematicGlyph.target,
    PlusPerk.badge => CinematicGlyph.gift,
  };

  String title(AppLocalizations l10n) => switch (this) {
    PlusPerk.season => l10n.paywallPerkSeasonTitle,
    PlusPerk.weeklyReview => l10n.paywallPerkWeeklyTitle,
    PlusPerk.consistency => l10n.paywallPerkStreakTitle,
    PlusPerk.reinforce => l10n.paywallPerkReinforceTitle,
    PlusPerk.badge => l10n.paywallPerkBadgeTitle,
  };

  String body(AppLocalizations l10n) => switch (this) {
    PlusPerk.season => l10n.paywallPerkSeasonBody,
    PlusPerk.weeklyReview => l10n.paywallPerkWeeklyBody,
    PlusPerk.consistency => l10n.paywallPerkStreakBody,
    PlusPerk.reinforce => l10n.paywallPerkReinforceBody,
    PlusPerk.badge => l10n.paywallPerkBadgeBody,
  };
}

/// Cartão do Peregrino+: superfície dos cards tingida de dourado com brilho
/// no topo, rótulo dourado em caixa alta, ícones emoldurados em dourado.
///
/// [detailed] mostra a frase de cada benefício (paywall). [locked] põe o
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
        for (var i = 0; i < PlusPerk.values.length; i++) ...[
          if (i > 0) SizedBox(height: detailed ? AppSpace.lg : 10),
          _PerkRow(
            perk: PlusPerk.values[i],
            iconSize: iconSize,
            detailed: detailed,
            locked: locked,
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
