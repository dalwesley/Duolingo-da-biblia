import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/caravan_pilgrim_profile.dart';
import '../models/corner_challenge.dart';
import '../models/trail.dart';
import '../services/backend_service.dart';
import '../services/corner_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'corner_withdraw.dart';
import 'corner_burst.dart';
import 'crossing_burst.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// CTA no perfil da Caravana — sempre visível; inativo se não der para chamar.
class CornerProfileCta extends StatelessWidget {
  final CaravanPilgrimProfile profile;
  final List<Trail> catalog;

  const CornerProfileCta({
    super.key,
    required this.profile,
    required this.catalog,
  });

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final corners = context.watch<CornerService>();
    final backend = context.watch<BackendService>();
    final uid = backend.uid;
    final peerId = profile.uid;
    if (peerId == null || peerId.isEmpty || peerId == uid) {
      return const SizedBox.shrink();
    }

    final existing = uid == null ? null : corners.withPeer(peerId);
    if (existing != null && uid != null) {
      return _StatusCard(
        challenge: existing,
        myUid: uid,
        acceptBlocked: corners.isBusy(except: existing.id),
        onAccept: () => corners.accept(existing.id),
        onDecline: () => corners.decline(existing.id),
      );
    }

    final proposal = catalog.isEmpty
        ? null
        : CornerMatch.propose(
            catalog: catalog,
            myCompleted: progress.completedMissions,
            myClearedModes: progress.clearedTrailModes,
            theirCompleted: profile.completedMissions,
            theirClearedModes: profile.clearedTrailModes,
          );

    String? blocked;
    if (!backend.isActive || uid == null) {
      blocked = CornerCopy.needsCloud;
    } else if (corners.isBusy()) {
      blocked = CornerCopy.busyWeek;
    } else if (proposal == null && !CornerMatch.forceOpenForPreview) {
      blocked = catalog.isEmpty
          ? CornerCopy.noCorner
          : CornerMatch.blockReason(
                  catalog: catalog,
                  myCompleted: progress.completedMissions,
                  myClearedModes: progress.clearedTrailModes,
                  theirCompleted: profile.completedMissions,
                  theirClearedModes: profile.clearedTrailModes,
                ) ??
                CornerCopy.noCorner;
    }

    final usable =
        proposal ??
        (CornerMatch.forceOpenForPreview
            ? CornerMatch.fallbackProposal(
                catalog: catalog,
                myCompleted: progress.completedMissions,
                myClearedModes: progress.clearedTrailModes,
              )
            : null);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        AppSpace.md,
        AppSpace.screen,
        0,
      ),
      child: _ChallengeCard(
        proposal: usable,
        blocked: blocked,
        onTap: usable == null || blocked != null
            ? null
            : () => _challenge(context, usable),
      ),
    );
  }

  /// Segurar o botão já é a confirmação — animação e envio na sequência.
  Future<void> _challenge(BuildContext context, CornerProposal proposal) async {
    final corners = context.read<CornerService>();
    final progress = context.read<ProgressService>();
    final messenger = ScaffoldMessenger.maybeOf(context);
    // Animação primeiro; envio (e o rebuild do card) só depois que some.
    await showCornerBurst(
      context,
      peerName: profile.name,
      peerPhoto: profile.photoUrl,
      caption: CornerCopy.burstSent,
      kicker: proposal.missionTitle,
    );
    final created = await corners.propose(
      opponentId: profile.uid!,
      opponentName: profile.name,
      myName: progress.userName,
      proposal: proposal,
      opponentPhotoUrl: profile.photoUrl,
    );
    if (created == null) {
      final msg = corners.lastError ?? CornerCopy.sendFailed;
      if (messenger != null) {
        showAppToast(
          messenger,
          message: msg,
          glyph: CinematicGlyph.wrong,
          tone: AppToastTone.warn,
        );
      }
    }
  }
}

class _ChallengeCard extends StatelessWidget {
  final CornerProposal? proposal;
  final String? blocked;
  final VoidCallback? onTap;

  const _ChallengeCard({
    required this.proposal,
    required this.blocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final enabled = onTap != null;
    final title = proposal == null
        ? CornerCopy.ctaInvite
        : CornerCopy.inviteTitle(proposal!.missionTitle);
    final sub = blocked ?? CornerCopy.sameStretch;
    final accent = enabled ? AppRoles.chrome : a.textFaint;

    return GlassCard(
      glow: enabled ? 0.45 : 0.1,
      tint: AppRoles.chrome,
      radius: AppMetrics.heroRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.flag,
                size: AppMetrics.leadingIcon,
                accent: accent,
                glowing: enabled,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.title(
                        size: 16,
                        color: enabled ? a.text : a.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
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
          const SizedBox(height: 12),
          HoldToConfirmCta(label: CornerCopy.holdInvite, onConfirm: onTap),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final CornerChallenge challenge;
  final String myUid;
  final bool acceptBlocked;
  final Future<void> Function() onAccept;
  final Future<void> Function() onDecline;

  const _StatusCard({
    required this.challenge,
    required this.myUid,
    required this.acceptBlocked,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final incoming =
        challenge.status == CornerStatus.pending &&
        challenge.iAmOpponent(myUid);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        AppSpace.md,
        AppSpace.screen,
        0,
      ),
      child: GlassCard(
        glow: 0.3,
        tint: AppRoles.chrome,
        radius: AppMetrics.heroRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              challenge.headline(myUid),
              style: AppTypography.title(size: 16, color: a.text),
            ),
            const SizedBox(height: 4),
            Text(
              challenge.subline(myUid),
              style: AppTypography.body(size: 12, color: a.textSecondary),
            ),
            if (incoming) ...[
              const SizedBox(height: 12),
              HoldToConfirmCta(
                label: CornerCopy.holdAccept,
                leading: CinematicGlyph.check,
                onConfirm: acceptBlocked
                    ? null
                    : () async {
                        await showCornerBurst(
                          context,
                          peerName: challenge.peerName(myUid),
                          peerPhoto: challenge.peerPhoto(myUid),
                          caption: CornerCopy.burstAccepted,
                          kicker: challenge.missionTitle,
                        );
                        await onAccept();
                      },
              ),
              if (acceptBlocked) ...[
                const SizedBox(height: 6),
                Text(
                  CornerCopy.busyAccept,
                  textAlign: TextAlign.center,
                  style: AppTypography.body(size: 12, color: a.textSecondary),
                ),
              ],
              const SizedBox(height: 8),
              GhostCta(
                label: CornerCopy.decline,
                expanded: true,
                onTap: () async {
                  await onDecline();
                },
              ),
            ] else if (challenge.canWithdraw(myUid)) ...[
              const SizedBox(height: 10),
              Center(
                child: TextCta(
                  label: CornerCopy.withdraw,
                  danger: true,
                  onTap: () => confirmCornerWithdraw(
                    context,
                    challenge: challenge,
                    myUid: myUid,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
