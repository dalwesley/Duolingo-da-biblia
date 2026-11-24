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
import '../services/companion_service.dart';
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
import 'profile_section.dart';
import 'ui_primitives.dart';

/// "Dar esta trilha a alguém": no topo do mapa de uma trilha do Peregrino+,
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
          const SizedBox(width: AppSpace.sm),
          CinematicIcon(
            glyph: CinematicGlyph.chevron,
            size: 14,
            accent: a.textSecondary,
            framed: false,
          ),
        ],
      ),
    );
  }
}

/// Folha do passe para [trail]: compartilhar, trocar o passe guardado
/// para outra trilha ou dizer para quem ele já foi neste mês.
///
/// [onChanged] roda depois do compartilhamento (o passe foi criado ou
/// trocou de trilha) — a folha já fechou antes de gravar.
Future<void> showTrailGiftSheet(
  BuildContext context,
  Trail trail, {
  VoidCallback? onChanged,
}) async {
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
  final sheetText = used
      ? description
      : '$description\n\n${l10n.referralInviteLine}';
  await showPathPreviewSheet(
    context,
    title: trail.localizedTitle,
    description: sheetText,
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
                onChanged?.call();
              },
            ),
          ),
  );
}

/// Passe aberto, num toque: quem receber escolhe a trilha. É o jeito mais
/// curto de dar — quem dá não precisa saber qual trilha a pessoa quer.
Future<void> sendOpenTrailGift(
  BuildContext context, {
  VoidCallback? onChanged,
}) async {
  ActHaptics.tap();
  await _shareTrailGift(context, null);
  onChanged?.call();
}

/// Cria (ou troca) o passe do mês e abre o compartilhar. [trail] nulo é o
/// passe aberto.
Future<void> _shareTrailGift(BuildContext context, Trail? trail) async {
  final sub = context.read<SubscriptionService>();
  // Espelha a rule: teste grátis não cria passe (evita PERMISSION_DENIED).
  if (!sub.canShareTrailGift) {
    await showAppToastFor(
      context,
      message: context.l10n.trailGiftSendFailed,
      glyph: CinematicGlyph.wrong,
      tone: AppToastTone.warn,
    );
    return;
  }
  final backend = context.read<BackendService>();
  final name = context.read<ProgressService>().publicUserName;
  final slug = trail?.slug ?? '';
  final gift = await backend.sendTrailGift(trailSlug: slug, fromName: name);
  if (!context.mounted) return;
  final l10n = context.l10n;
  if (gift == null || gift.redeemed) {
    unawaited(
      AnalyticsService.instance.logTrailGift(
        action: 'send',
        trail: slug,
        result: gift == null ? 'failed' : 'used',
      ),
    );
    var usedTitle = trail?.localizedTitle ?? '';
    if (gift != null && gift.trailSlug.isNotEmpty && gift.trailSlug != slug) {
      final other = await TrailRepository().getTrailBySlug(gift.trailSlug);
      if (!context.mounted) return;
      usedTitle = other?.localizedTitle ?? gift.trailSlug;
    }
    await showAppToastFor(
      context,
      message: gift == null
          ? l10n.trailGiftSendFailed
          : l10n.trailGiftSheetUsed(
              usedTitle,
              (gift.toName ?? '').isEmpty
                  ? l10n.trailGiftSomeone
                  : gift.toName!,
            ),
      glyph: CinematicGlyph.wrong,
      tone: AppToastTone.warn,
    );
    return;
  }
  unawaited(
    AnalyticsService.instance.logTrailGift(
      action: 'send',
      trail: gift.trailSlug,
      result: gift.trailSlug.isEmpty ? 'shared_open' : 'shared',
    ),
  );
  // O passe guardado pode ser de outra trilha (ex.: aberto que já existia
  // e não aceita voltar a ser aberto): o texto segue o passe real.
  final link = InviteDeepLinkService.trailGiftHttpsUrl(gift.code);
  final String text;
  if (gift.trailSlug.isEmpty) {
    text = l10n.trailGiftShareOpenText(link, gift.code);
  } else {
    var title = trail?.localizedTitle ?? '';
    if (gift.trailSlug != slug) {
      final other = await TrailRepository().getTrailBySlug(gift.trailSlug);
      if (!context.mounted) return;
      title = other?.localizedTitle ?? gift.trailSlug;
    }
    text = l10n.trailGiftShareText(title, link, gift.code);
  }
  await SharePlus.instance.share(
    ShareParams(text: text, subject: l10n.trailGiftShareSubject),
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

  if (!backend.isActive) {
    // Sem conta: o passe espera o login e abre sozinho depois.
    InviteDeepLinkService.instance.holdTrailGiftCode(code);
    return fail(TrailGiftRedeem.needsAccount);
  }
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
    final sub = context.read<SubscriptionService>();
    // Link aberto com o app fechado: a loja ainda não respondeu. Espera
    // um pouco antes de decidir (assinante não gasta o passe).
    if (!sub.storeAnswered) {
      await sub.waitStoreAnswer();
      if (!context.mounted) return;
    }
    // Já tem Plus de verdade, ou build sem loja (tudo aberto): não gaste.
    // Promo de lançamento ainda resgata — o passe fica depois da promo.
    if (sub.isPeregrinoPlus || !sub.isConfigured) {
      return fail(TrailGiftRedeem.notNeeded, trail: peek.trailSlug);
    }
    // Loja ainda não respondeu: pode ser assinante. Falha sem resgatar.
    if (!sub.storeAnswered) {
      return fail(TrailGiftRedeem.failed, trail: peek.trailSlug);
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
      toName: progress.publicUserName,
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
    builder: (sheet) => _GiftTrailPicker(
      title: context.l10n.trailGiftPickTitle(fromName),
      subtitle: context.l10n.trailGiftPickSubtitle,
      trails: trails,
    ),
  );
}

/// Quem assina escolhe qual trilha do Peregrino+ vai liberar.
Future<Trail?> pickTrailToGive(BuildContext context) async {
  final trails = (await TrailRepository().getTrails())
      .where(
        (t) =>
            PlusAccess.trailInPlus(t) &&
            !t.comingSoon &&
            t.missionSlugs.isNotEmpty,
      )
      .toList();
  if (!context.mounted || trails.isEmpty) return null;
  return showAppSheet<Trail>(
    context,
    builder: (sheet) => _GiftTrailPicker(
      title: context.l10n.trailGiftGivePickTitle,
      subtitle: context.l10n.trailGiftGivePickSubtitle,
      trails: trails,
    ),
  );
}

class _GiftTrailPicker extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Trail> trails;

  const _GiftTrailPicker({
    required this.title,
    required this.subtitle,
    required this.trails,
  });

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
              title: title,
              subtitle: subtitle,
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

/// "Sua assinatura libera alguém" no Perfil: o passe do mês sempre à mão
/// (antes só existia no fim do mapa de uma trilha do Peregrino+). Mostra se
/// o passe está livre, guardado para uma trilha, no convite de companhia ou
/// já dado — e leva a escolher, compartilhar de novo ou trocar a trilha.
/// No teste grátis só avisa (a regra não cria passe no teste).
class TrailGiftMonthCard extends StatefulWidget {
  /// Falso no teste grátis: só o aviso, sem ação.
  final bool canGive;

  const TrailGiftMonthCard({super.key, required this.canGive});

  @override
  State<TrailGiftMonthCard> createState() => _TrailGiftMonthCardState();
}

class _TrailGiftMonthCardState extends State<TrailGiftMonthCard> {
  bool _loaded = false;
  TrailGift? _gift;
  Trail? _trail;

  @override
  void initState() {
    super.initState();
    if (widget.canGive) {
      _load();
    } else {
      _loaded = true;
    }
  }

  Future<void> _load() async {
    final gift = await context.read<BackendService>().fetchMonthTrailGift();
    Trail? trail;
    if (gift != null && gift.trailSlug.isNotEmpty) {
      trail = await TrailRepository().getTrailBySlug(gift.trailSlug);
    }
    if (!mounted) return;
    setState(() {
      _gift = gift;
      _trail = trail;
      _loaded = true;
    });
  }

  Future<void> _pickAndShare() async {
    final trail = await pickTrailToGive(context);
    if (trail == null || !mounted) return;
    await showTrailGiftSheet(context, trail, onChanged: _load);
  }

  Future<void> _sendOpen() => sendOpenTrailGift(context, onChanged: _load);

  Future<void> _reshare() async {
    final trail = _trail;
    if (trail == null) return _pickAndShare();
    await showTrailGiftSheet(context, trail, onChanged: _load);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final gift = _gift;
    final trailTitle = _trail?.localizedTitle ?? gift?.trailSlug ?? '';
    final used = gift != null && gift.redeemed;
    // Passe aberto só está "no convite" se o convite ainda espera alguém.
    // Convite cancelado ou vencido deixa o passe aberto solto: volta a ser
    // um passe livre (escolher a trilha grava nele).
    final giftCode = gift?.code;
    final inLiveInvite = context.select<CompanionService, bool>(
      (c) => c.companions.any(
        (m) =>
            m.awaitingPartner && m.giftCode != null && m.giftCode == giftCode,
      ),
    );
    final open = gift != null && !used && gift.trailSlug.isEmpty;
    final openInInvite = open && inLiveInvite;
    final reserved = gift != null && !used && gift.trailSlug.isNotEmpty;
    final free = gift == null;

    final String text;
    if (!widget.canGive) {
      text = l10n.trailGiftMonthTrial;
    } else if (used) {
      final name = gift.toName ?? '';
      text = l10n.trailGiftSheetUsed(
        trailTitle,
        name.isEmpty ? l10n.trailGiftSomeone : name,
      );
    } else if (openInInvite) {
      text = l10n.trailGiftMonthOpen;
    } else if (open) {
      text = l10n.trailGiftMonthOpenLink;
    } else if (reserved) {
      text = l10n.trailGiftMonthReserved(trailTitle);
    } else {
      text = l10n.trailGiftMonthReady;
    }

    // Ação principal: mandar o passe (aberto ou o já guardado). A
    // secundária: escolher ou trocar a trilha.
    final List<Widget> actions;
    if (!widget.canGive || used) {
      actions = const [];
    } else if (openInInvite) {
      actions = [
        GhostCta(
          label: l10n.trailGiftMonthChoose,
          leading: CinematicGlyph.gift,
          expanded: true,
          onTap: _pickAndShare,
        ),
      ];
    } else {
      actions = [
        CopperCta(
          label: free ? l10n.trailGiftMonthSend : l10n.trailGiftMonthReshare,
          leading: free ? CinematicGlyph.gift : CinematicGlyph.share,
          expanded: true,
          onTap: reserved ? _reshare : _sendOpen,
        ),
        const SizedBox(height: AppSpace.sm),
        GhostCta(
          label: reserved ? l10n.trailGiftMonthSwap : l10n.trailGiftMonthPick,
          leading: reserved ? CinematicGlyph.refresh : CinematicGlyph.book,
          expanded: true,
          onTap: _pickAndShare,
        ),
      ];
    }

    return ProfileSection(
      accent: AppRoles.reward,
      glyph: CinematicGlyph.gift,
      title: l10n.trailGiftMonthTitle,
      lit: widget.canGive && _loaded && (free || open) && !openInInvite,
      child: !_loaded
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpace.md),
              child: AppSpinner(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  text,
                  style: AppTypography.body(
                    size: 13,
                    height: 1.45,
                    color: a.textSecondary,
                  ),
                ),
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: AppSpace.md),
                  ...actions,
                ],
              ],
            ),
    );
  }
}
