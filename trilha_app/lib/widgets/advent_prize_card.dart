import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../models/advent_prize.dart';
import '../models/season_walk.dart';
import '../services/advent_prize_service.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/liturgical_calendar.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Celebra uma vez cada subida de prêmio do Advento (1, 2 ou 3 meses).
/// Chamado pela tela do Advento e pelo shell ao voltar de uma cena.
Future<void> maybeCelebrateAdventPrize(
  BuildContext context,
  String campaignId,
) async {
  if (_celebrating) return;
  _celebrating = true;
  try {
    await _celebrate(context, campaignId);
  } finally {
    _celebrating = false;
  }
}

bool _celebrating = false;

Future<void> _celebrate(BuildContext context, String campaignId) async {
  final service = AdventPrizeService.instance;
  final months = await service.unseenMonths(campaignId);
  if (months <= 0 || !context.mounted) return;
  await service.markSeen(campaignId);
  if (!context.mounted) return;
  final sub = context.read<SubscriptionService>();
  await sub.refreshCustomerInfo();
  if (!context.mounted) return;
  final tier = service.stateFor(campaignId).tier;
  final l10n = context.l10n;
  await showAppDialog<void>(
    context,
    builder: (ctx) => AppDialog(
      face: CloudFace.sucesso,
      title: l10n.adventPrizeEarnedTitle(months),
      content: Text(switch (tier) {
        AdventTier.group => l10n.adventPrizeEarnedGroup,
        AdventTier.pair => l10n.adventPrizeEarnedPair,
        _ => l10n.adventPrizeEarnedSolo,
      }, textAlign: TextAlign.center),
      actions: [
        CopperCta(
          label: ctx.l10n.commonGotIt,
          dense: true,
          trailing: null,
          onTap: () => Navigator.pop(ctx),
        ),
      ],
    ),
  );
}

/// Promessa, níveis, cenas confirmadas X/N e validade do Plus.
/// Some quando a campanha não tem prêmio.
class AdventPrizeCard extends StatefulWidget {
  final SeasonWalkCampaign campaign;

  const AdventPrizeCard({super.key, required this.campaign});

  @override
  State<AdventPrizeCard> createState() => _AdventPrizeCardState();
}

class _AdventPrizeCardState extends State<AdventPrizeCard> {
  @override
  void initState() {
    super.initState();
    AdventPrizeService.instance.addListener(_onChange);
    _load();
  }

  @override
  void dispose() {
    AdventPrizeService.instance.removeListener(_onChange);
    super.dispose();
  }

  /// Prova confirmada com esta tela aberta: celebra aqui (o shell espera).
  void _onChange() {
    if (!mounted || !(ModalRoute.isCurrentOf(context) ?? false)) return;
    maybeCelebrateAdventPrize(context, widget.campaign.id);
  }

  Future<void> _load() async {
    await AdventPrizeService.instance.refresh(widget.campaign.id);
    if (!mounted) return;
    await maybeCelebrateAdventPrize(context, widget.campaign.id);
  }

  @override
  Widget build(BuildContext context) {
    final cfg = AdventPrizeService.instance.configFor(widget.campaign.id);
    if (cfg == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: AdventPrizeService.instance,
      builder: (context, _) => _body(context, cfg),
    );
  }

  Widget _body(BuildContext context, AdventPrizeConfig cfg) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final campaign = widget.campaign;
    final service = AdventPrizeService.instance;
    final state = service.stateFor(campaign.id);
    final sub = context.watch<SubscriptionService>();
    final localDone = context.select(
      (ProgressService p) => p.walkDatesFor(campaign.id).length,
    );
    final locale = Localizations.localeOf(context).toLanguageTag();
    String day(DateTime utc) => DateFormat.MMMMd(locale).format(
      // Datas do prêmio são de Brasília (UTC-3).
      utc.subtract(const Duration(hours: 3)),
    );
    final now = DateTime.now();
    final open = cfg.isOpen(now);
    final beforeRoster = now.toUtc().isBefore(cfg.rosterAt);
    final accent = LiturgicalCalendar.accentOf(LiturgicalSeason.advent);
    final accentInk = a.onDark ? accent : a.ink(accent);
    final total = campaign.length;

    Widget tierRow(AdventTier tier, String label) {
      final months = cfg.monthsFor(tier);
      final got = state.tier == tier;
      final reach = !got && state.months == 0 && state.reachable == tier;
      final color = got || reach ? accentInk : a.textSecondary;
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            Icon(
              got ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body(
                  size: 13,
                  weight: got || reach ? FontWeight.w700 : FontWeight.w500,
                  color: got || reach ? a.text : a.textSecondary,
                ),
              ),
            ),
            Text(
              l10n.adventPrizeMonths(months),
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    final notes = <String>[
      if (!service.canEarn)
        l10n.adventPrizeNeedsLogin
      else if (!open && !state.completed)
        l10n.adventPrizeClosed
      else if (!state.completed)
        l10n.adventPrizeStepADay(day(cfg.deadline), cfg.maxPerDay),
      if (service.canEarn &&
          open &&
          !state.completed &&
          localDone > state.confirmed)
        l10n.adventPrizeUnconfirmed,
      if (service.canEarn && beforeRoster)
        l10n.adventPrizeRosterBefore(day(cfg.rosterAt))
      else if (service.canEarn && state.months == 0 && open)
        switch (state.reachable) {
          AdventTier.group => l10n.adventPrizeRosterGroup(cfg.groupMin),
          AdventTier.pair => l10n.adventPrizeRosterPair,
          _ => l10n.adventPrizeRosterSolo,
        },
      if (state.completed &&
          state.tier == AdventTier.solo &&
          state.reachable != AdventTier.solo &&
          open)
        l10n.adventPrizeWaitingOthers,
    ];

    final expires = sub.plusExpiresAt;
    return GlassCard(
      tint: accent,
      glow: 0.4,
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.gift,
                size: AppMetrics.iconSm,
                accent: accent,
                framed: false,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SectionLabel(
                  l10n.adventPrizeKicker,
                  size: 10,
                  color: accentInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.adventPrizePromise(total, cfg.maxMonths),
            style: AppTypography.title(size: 16, color: a.text),
          ),
          const SizedBox(height: 6),
          tierRow(AdventTier.solo, l10n.adventPrizeTierSolo),
          tierRow(AdventTier.pair, l10n.adventPrizeTierPair),
          tierRow(AdventTier.group, l10n.adventPrizeTierGroup(cfg.groupMin)),
          const SizedBox(height: 14),
          AppProgressBar(
            value: total == 0 ? 0 : (state.confirmed / total).clamp(0.0, 1.0),
            color: accent,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.adventPrizeConfirmed(state.confirmed, total),
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w700,
              color: accentInk,
            ),
          ),
          if (state.months > 0) ...[
            const SizedBox(height: 10),
            Text(
              l10n.adventPrizeEarnedTitle(state.months),
              style: AppTypography.body(
                size: 14,
                weight: FontWeight.w700,
                color: a.text,
              ),
            ),
            if (sub.plusWillRenew)
              Text(
                l10n.adventPrizeKept,
                style: AppTypography.body(size: 12, color: a.textSecondary),
              )
            else if (sub.isPeregrinoPlus && expires != null)
              Text(
                l10n.adventPrizePlusUntil(
                  DateFormat.yMMMMd(locale).format(expires.toLocal()),
                ),
                style: AppTypography.body(size: 12, color: a.textSecondary),
              ),
          ],
          for (final note in notes) ...[
            const SizedBox(height: 8),
            Text(
              note,
              style: AppTypography.body(
                size: 12,
                height: 1.4,
                color: a.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
