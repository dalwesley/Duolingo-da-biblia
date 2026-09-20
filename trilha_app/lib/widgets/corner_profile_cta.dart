import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/caravan_pilgrim_profile.dart';
import '../models/corner_challenge.dart';
import '../models/trail.dart';
import '../services/backend_service.dart';
import '../services/corner_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';
import 'corner_invite_sheet.dart';
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
    } else if (!CornerMatch.forceOpenForPreview && corners.hasOpenThisWeek) {
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

    final usable = proposal ??
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

  Future<void> _challenge(
    BuildContext context,
    CornerProposal proposal,
  ) async {
    HapticFeedback.lightImpact();
    final ok = await showCornerInviteSheet(
      context,
      proposal: proposal,
      peerName: profile.name,
    );
    if (!ok || !context.mounted) return;
    final corners = context.read<CornerService>();
    final progress = context.read<ProgressService>();
    final created = await corners.propose(
      opponentId: profile.uid!,
      opponentName: profile.name,
      myName: progress.userName,
      proposal: proposal,
    );
    if (!context.mounted) return;
    if (created == null) {
      final msg = corners.lastError ?? CornerCopy.sendFailed;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
    final enabled = onTap != null;
    final title = proposal == null
        ? CornerCopy.ctaChallenge
        : CornerCopy.inviteTitle(proposal!.missionTitle);
    final sub = blocked ?? CornerCopy.sameStretch;
    final accent = enabled
        ? AppColors.accent
        : AppColors.accent.withValues(alpha: 0.38);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.nightLight.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: accent.withValues(alpha: enabled ? 0.45 : 0.22),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CinematicIcon(
                  glyph: CinematicGlyph.flag,
                  size: 36,
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
                          color: Colors.white.withValues(
                            alpha: enabled ? 1 : 0.72,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: AppTypography.body(
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.62),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CopperCta(
              label: CornerCopy.ctaChallenge,
              leading: CinematicGlyph.flag,
              trailing: null,
              dense: true,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final CornerChallenge challenge;
  final String myUid;
  final Future<void> Function() onAccept;
  final Future<void> Function() onDecline;

  const _StatusCard({
    required this.challenge,
    required this.myUid,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final incoming = challenge.status == CornerStatus.pending &&
        challenge.iAmOpponent(myUid);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        AppSpace.md,
        AppSpace.screen,
        0,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.nightLight.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                challenge.headline(myUid),
                style: AppTypography.title(size: 16, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                challenge.subline(myUid),
                style: AppTypography.body(
                  size: 12,
                  color: Colors.white.withValues(alpha: 0.62),
                ),
              ),
              if (incoming) ...[
                const SizedBox(height: 12),
                CopperCta(
                  label: CornerCopy.accept,
                  leading: CinematicGlyph.check,
                  trailing: null,
                  dense: true,
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await onAccept();
                  },
                ),
                const SizedBox(height: 8),
                GhostCta(
                  label: CornerCopy.decline,
                  expanded: true,
                  onTap: () async {
                    await onDecline();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
