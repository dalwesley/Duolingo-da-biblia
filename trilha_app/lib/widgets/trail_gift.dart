import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/trail_art.dart';
import '../data/trail_repository.dart';
import '../l10n/app_language.dart';
import '../models/trail.dart';
import '../models/trail_gift.dart';
import '../screens/trail_map_screen.dart';
import '../services/analytics_service.dart';
import '../services/backend_service.dart';
import '../services/invite_deep_link_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../utils/trail_progress.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/plus_access.dart';
import 'accept_invite_sheet.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'path_preview_sheet.dart';
import 'ui_primitives.dart';

/// "Sua assinatura libera alguém": no mapa de uma trilha do Peregrino+,
/// quem assina libera a trilha inteira para outra pessoa (1 passe por mês).
class TrailGiftCard extends StatelessWidget {
  final Trail trail;

  const TrailGiftCard({super.key, required this.trail});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return GlassCard(
      tint: AppRoles.reward,
      glow: 0.5,
      onTap: () => showTrailGiftSheet(context, trail),
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.gift,
            size: AppMetrics.leadingIcon,
            accent: AppRoles.reward,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.trailGiftCardTitle,
                  style: AppTypography.title(size: 15, color: a.text),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(
                  l10n.trailGiftCardBody,
                  style: AppTypography.body(size: 13, color: a.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Folha do passe para [trail]: compartilhar, trocar o passe guardado
/// para outra trilha ou dizer para quem ele já foi neste mês.
Future<void> showTrailGiftSheet(BuildContext context, Trail trail) async {
  ActHaptics.tap();
  final backend = context.read<BackendService>();
  final current = await backend.fetchMonthTrailGift();
  if (!context.mounted) return;
  final l10n = context.l10n;
  String? currentTitle;
  final openInInvite =
      current != null && !current.redeemed && current.trailSlug.isEmpty;
  if (current != null &&
      current.trailSlug.isNotEmpty &&
      current.trailSlug != trail.slug) {
    final other = await TrailRepository().getTrailBySlug(current.trailSlug);
    if (!context.mounted) return;
    currentTitle = other?.localizedTitle ?? current.trailSlug;
  }
  final used = current != null && current.redeemed;
  final description = used
      ? l10n.trailGiftSheetUsed(
          currentTitle ?? trail.localizedTitle,
          current.toName!.isEmpty ? l10n.trailGiftSomeone : current.toName!,
        )
      : openInInvite
      ? l10n.trailGiftSheetSwapOpen
      : currentTitle != null
      ? l10n.trailGiftSheetSwap(currentTitle)
      : l10n.trailGiftSheetBody;
  await showPathPreviewSheet(
    context,
    title: trail.localizedTitle,
    description: description,
    art: TrailArt.of(trail.slug),
    eyebrow: l10n.trailGiftEyebrow,
    accent: AppRoles.reward,
    glyph: CinematicGlyph.gift,
    footer: used
        ? null
        : Builder(
            builder: (sheet) => CopperCta(
              label: l10n.trailGiftShareCta,
              leading: CinematicGlyph.share,
              expanded: true,
              onTap: () async {
                Navigator.of(sheet).pop();
                await _shareTrailGift(context, trail);
              },
            ),
          ),
  );
}

Future<void> _shareTrailGift(BuildContext context, Trail trail) async {
  final backend = context.read<BackendService>();
  final name = context.read<ProgressService>().userName;
  final gift = await backend.sendTrailGift(
    trailSlug: trail.slug,
    fromName: name,
  );
  if (!context.mounted) return;
  final l10n = context.l10n;
  if (gift == null || gift.redeemed) {
    unawaited(
      AnalyticsService.instance.logTrailGift(
        action: 'send',
        trail: trail.slug,
        result: gift == null ? 'failed' : 'used',
      ),
    );
    await showAppToastFor(
      context,
      message: gift == null
          ? l10n.trailGiftSendFailed
          : l10n.trailGiftSheetUsed(
              trail.localizedTitle,
              gift.toName!.isEmpty ? l10n.trailGiftSomeone : gift.toName!,
            ),
      glyph: CinematicGlyph.wrong,
      tone: AppToastTone.warn,
    );
    return;
  }
  unawaited(
    AnalyticsService.instance.logTrailGift(
      action: 'send',
      trail: trail.slug,
      result: 'shared',
    ),
  );
  await SharePlus.instance.share(
    ShareParams(
      text: l10n.trailGiftShareText(
        trail.localizedTitle,
        InviteDeepLinkService.trailGiftHttpsUrl(gift.code),
      ),
      subject: l10n.trailGiftShareSubject,
    ),
  );
}

/// "Tenho um código": quem instalou o app depois de receber o link cola a
/// mensagem ou digita as 8 letras.
Future<void> enterTrailGiftCode(BuildContext context) async {
  final code = await showAcceptInviteSheet(
    context,
    subtitle: context.l10n.trailGiftCodeSubtitle,
    extract: InviteDeepLinkService.findTrailGiftCode,
    scan: false,
  );
  if (code == null || code.isEmpty || !context.mounted) return;
  await redeemTrailGiftLink(context, code);
}

/// Quem recebeu abriu o link do passe: confere, resgata e abre a trilha.
/// O passe só é gasto quando a trilha ainda pede o Plus para esta pessoa.
Future<void> redeemTrailGiftLink(BuildContext context, String code) async {
  final backend = context.read<BackendService>();
  final progress = context.read<ProgressService>();
  final l10n = context.l10n;

  Future<void> fail(
    TrailGiftRedeem outcome, {
    String trail = '',
    String pendingTitle = '',
  }) {
    unawaited(
      AnalyticsService.instance.logTrailGift(
        action: 'redeem',
        trail: trail,
        result: outcome.name,
      ),
    );
    return showAppToastFor(
      context,
      message: switch (outcome) {
        TrailGiftRedeem.needsAccount => l10n.trailGiftNeedsAccount,
        TrailGiftRedeem.invalid => l10n.trailGiftInvalid,
        TrailGiftRedeem.own => l10n.trailGiftOwn,
        TrailGiftRedeem.taken => l10n.trailGiftTaken,
        TrailGiftRedeem.notNeeded => l10n.trailGiftNotNeeded,
        TrailGiftRedeem.pendingGift => l10n.trailGiftPending(pendingTitle),
        TrailGiftRedeem.failed || TrailGiftRedeem.done => l10n.trailGiftFailed,
      },
      glyph: CinematicGlyph.gift,
      tone: AppToastTone.warn,
    );
  }

  if (!backend.isActive) return fail(TrailGiftRedeem.needsAccount);
  final peek = await backend.fetchTrailGift(code);
  if (!context.mounted) return;
  if (peek == null) return fail(TrailGiftRedeem.invalid);
  if (peek.fromUid == backend.uid) {
    return fail(TrailGiftRedeem.own, trail: peek.trailSlug);
  }
  final fromName = peek.fromName.isEmpty
      ? l10n.trailGiftSomeone
      : peek.fromName;

  // Passe aberto (veio no convite de companhia): a trilha é escolhida aqui.
  Trail? trail;
  if (peek.trailSlug.isNotEmpty) {
    trail = await TrailRepository().getTrailBySlug(peek.trailSlug);
    if (!context.mounted) return;
    if (trail == null) return fail(TrailGiftRedeem.invalid);
  }

  if (trail == null || !progress.giftedTrails.containsKey(trail.slug)) {
    if (context.read<SubscriptionService>().isPeregrinoPlus) {
      return fail(TrailGiftRedeem.notNeeded, trail: peek.trailSlug);
    }
    // Um passe por vez: o recebido antes precisa terminar.
    final pending = await _unfinishedGift(progress);
    if (!context.mounted) return;
    if (pending != null) {
      return fail(
        TrailGiftRedeem.pendingGift,
        trail: peek.trailSlug,
        pendingTitle: pending.localizedTitle,
      );
    }
    String? chosen;
    if (trail == null) {
      trail = await _pickGiftTrail(context, fromName);
      if (trail == null || !context.mounted) return;
      chosen = trail.slug;
    }
    final result = await backend.redeemTrailGift(
      code,
      toName: progress.userName,
      chosenTrail: chosen,
    );
    if (!context.mounted) return;
    if (result.outcome != TrailGiftRedeem.done) {
      return fail(result.outcome, trail: trail.slug);
    }
    // Quem deu pode ter trocado a trilha entre a leitura e o resgate.
    final slug = result.gift?.trailSlug ?? trail.slug;
    if (slug != trail.slug) {
      trail = await TrailRepository().getTrailBySlug(slug) ?? trail;
      if (!context.mounted) return;
    }
    await progress.receiveTrailGift(trail.slug, peek.fromName);
    if (!context.mounted) return;
    unawaited(
      AnalyticsService.instance.logTrailGift(
        action: 'redeem',
        trail: trail.slug,
        result: chosen == null ? 'done' : 'done_open',
      ),
    );
    unawaited(
      backend.saveNow(
        progress,
        LeagueService.weekKey(),
        league: context.read<LeagueService>(),
      ),
    );
  }

  final opened = trail;
  await showPathPreviewSheet(
    context,
    title: opened.localizedTitle,
    description: l10n.trailGiftReceivedBody(fromName),
    art: TrailArt.of(opened.slug),
    eyebrow: l10n.trailGiftEyebrow,
    accent: AppRoles.reward,
    glyph: CinematicGlyph.gift,
    detail: opened.localizedDescription,
    footer: Builder(
      builder: (sheet) => CopperCta(
        label: l10n.commonStart,
        expanded: true,
        onTap: () {
          Navigator.of(sheet).pop();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TrailMapScreen(slug: opened.slug),
            ),
          );
        },
      ),
    ),
  );
}

/// Trilha recebida por passe e ainda não terminada, ou null.
Future<Trail?> _unfinishedGift(ProgressService progress) async {
  final repo = TrailRepository();
  for (final slug in progress.giftedTrails.keys) {
    final trail = await repo.getTrailBySlug(slug);
    if (trail == null || trail.comingSoon) continue;
    if (!TrailProgress.isTrailCompleted(
      trail,
      progress.completedMissions,
      clearedTrailModes: progress.clearedTrailModes,
    )) {
      return trail;
    }
  }
  return null;
}

/// Passe aberto: quem recebeu escolhe uma trilha do Peregrino+.
Future<Trail?> _pickGiftTrail(BuildContext context, String fromName) async {
  final gifted = context.read<ProgressService>().giftedTrails;
  final trails = (await TrailRepository().getTrails())
      .where(
        (t) =>
            PlusAccess.trailInPlus(t) &&
            !t.comingSoon &&
            t.missionSlugs.isNotEmpty &&
            !gifted.containsKey(t.slug),
      )
      .toList();
  if (!context.mounted || trails.isEmpty) return null;
  return showAppSheet<Trail>(
    context,
    builder: (sheet) => _GiftTrailPicker(fromName: fromName, trails: trails),
  );
}

class _GiftTrailPicker extends StatelessWidget {
  final String fromName;
  final List<Trail> trails;

  const _GiftTrailPicker({required this.fromName, required this.trails});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final maxH = MediaQuery.sizeOf(context).height * 0.8;
    return AppSheetPanel(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetHeader(
              eyebrow: l10n.trailGiftEyebrow,
              eyebrowColor: AppRoles.reward,
              title: l10n.trailGiftPickTitle(fromName),
              subtitle: l10n.trailGiftPickSubtitle,
              center: true,
            ),
            const SizedBox(height: AppSpace.md),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: trails.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpace.sm),
                itemBuilder: (context, i) {
                  final trail = trails[i];
                  return AppChoiceTile(
                    selected: false,
                    onTap: () => Navigator.of(context).pop(trail),
                    child: Row(
                      children: [
                        CinematicIcon(
                          glyph: CinematicGlyphResolver.forTrail(trail.slug),
                          size: AppMetrics.iconSm,
                          accent: AppRoles.reward,
                          framed: false,
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trail.localizedTitle,
                                style: AppTypography.title(
                                  size: 15,
                                  color: a.text,
                                ),
                              ),
                              Text(
                                trail.journey.label,
                                style: AppTypography.body(
                                  size: 12,
                                  color: a.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
