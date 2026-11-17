import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/season_walk_catalog.dart';
import '../l10n/app_language.dart';
import '../models/advent_prize.dart';
import '../models/season_walk.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/juntos_invite_pace.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'ui_primitives.dart';

/// O que a pessoa escolheu na folha de convite da aba Juntos.
enum JuntosInviteChoice { share, later }

/// Por onde sai o convite da indicação — só estes contam para o mês de
/// Plus (functions/referral.js): Companhia ou grupo.
enum JuntosReferralVia { companion, group }

/// Folha de convite da aba Juntos: Advento (dupla/grupo antes da foto do
/// 1º dia) ou indicação (1 mês de Plus por quem assinar). Advento: o botão
/// abre o compartilhar da estação. Indicação: abre o convite da Companhia
/// ou do grupo ([via]), os únicos que contam para o mês. Quem chama faz o
/// envio. O ritmo fica em [JuntosInvitePace].
Future<JuntosInviteChoice> showJuntosInviteSheet(
  BuildContext context, {
  required JuntosInviteKind kind,
  AdventPrizeConfig? advent,
  JuntosReferralVia via = JuntosReferralVia.companion,
}) async {
  final choice = await showAppSheet<JuntosInviteChoice>(
    context,
    builder: (_) => _JuntosInviteSheet(kind: kind, advent: advent, via: via),
  );
  return choice ?? JuntosInviteChoice.later;
}

class _JuntosInviteSheet extends StatelessWidget {
  final JuntosInviteKind kind;
  final AdventPrizeConfig? advent;
  final JuntosReferralVia via;

  const _JuntosInviteSheet({
    required this.kind,
    required this.advent,
    required this.via,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final isAdvent = kind == JuntosInviteKind.advent && advent != null;
    final cfg = advent;
    final locale = Localizations.localeOf(context).toLanguageTag();
    // Datas do prêmio são de Brasília (UTC-3), como no card do Advento.
    String day(DateTime utc) =>
        DateFormat.MMMMd(locale).format(utc.subtract(const Duration(hours: 3)));

    void pop(JuntosInviteChoice c) => Navigator.of(context).pop(c);

    final rows = <(CinematicGlyph, String, String?)>[
      if (isAdvent && cfg != null) ...[
        (
          CinematicGlyph.walker,
          l10n.adventPrizeTierSolo,
          l10n.adventPrizeMonths(cfg.soloMonths),
        ),
        (
          CinematicGlyph.heart,
          l10n.adventPrizeTierPair,
          l10n.adventPrizeMonths(cfg.pairMonths),
        ),
        (
          CinematicGlyph.people,
          l10n.adventPrizeTierGroup(cfg.groupMin),
          l10n.adventPrizeMonths(cfg.groupMonths),
        ),
      ] else ...[
        (CinematicGlyph.gift, l10n.referralInviteLine, null),
        (CinematicGlyph.people, l10n.juntosInviteReferralHow, null),
        (CinematicGlyph.calendar, l10n.juntosInviteReferralCap, null),
      ],
    ];

    // Advento: a pintura da estação no topo, afundando na folha; o Anan
    // pousa no pé dela.
    final heroH = (MediaQuery.sizeOf(context).height * 0.24).clamp(
      150.0,
      210.0,
    );
    return AppSheetPanel(
      background: isAdvent
          ? Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: heroH,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      SeasonWalkCatalog.artAsset(SeasonWalkKind.advent),
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.15),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            a.cardFill.withValues(alpha: 0),
                            a.cardFill.withValues(alpha: 0.55),
                            a.cardFill,
                          ],
                          stops: const [0.35, 0.72, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isAdvent) SizedBox(height: heroH - 96),
          AppSheetHeader(
            face: CloudFace.feliz,
            center: true,
            eyebrow: isAdvent
                ? l10n.adventPrizeKicker
                : l10n.juntosInviteReferralEyebrow,
            title: isAdvent
                ? l10n.juntosInviteAdventTitle
                : l10n.juntosInviteReferralTitle,
          ),
          const SizedBox(height: AppSpace.md),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isAdvent) ...[
                    Text(
                      l10n.juntosInviteAdventBody,
                      style: AppTypography.body(
                        size: 14,
                        height: 1.35,
                        color: a.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),
                  ],
                  for (final (glyph, text, trailing) in rows)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.md),
                      child: Row(
                        crossAxisAlignment: trailing == null
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        children: [
                          CinematicIcon(
                            glyph: glyph,
                            size: AppMetrics.leadingIcon,
                            accent: a.place,
                          ),
                          const SizedBox(width: AppSpace.md),
                          Expanded(
                            child: Text(
                              text,
                              style: AppTypography.body(
                                size: 14,
                                height: 1.35,
                                color: a.text,
                              ),
                            ),
                          ),
                          if (trailing != null) ...[
                            const SizedBox(width: AppSpace.sm),
                            Text(
                              trailing,
                              style: AppTypography.body(
                                size: 14,
                                weight: FontWeight.w800,
                                color: a.text,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  if (isAdvent && cfg != null)
                    Text(
                      l10n.adventPrizeRosterBefore(day(cfg.rosterAt)),
                      style: AppTypography.body(
                        size: 12,
                        height: 1.35,
                        color: a.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          CopperCta(
            label: isAdvent
                ? l10n.walkTogetherInvite
                : via == JuntosReferralVia.companion
                ? l10n.juntosInviteCompanion
                : l10n.roomFormingInvite,
            leading: CinematicGlyph.share,
            trailing: null,
            onTap: () => pop(JuntosInviteChoice.share),
          ),
          const SizedBox(height: AppSpace.xs),
          Center(
            child: TextCta(
              label: l10n.commonNotNow,
              onTap: () => pop(JuntosInviteChoice.later),
            ),
          ),
        ],
      ),
    );
  }
}
