import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/caravan_pilgrim_profile.dart';
import '../models/pilgrim_medals.dart';
import '../models/trail.dart';
import '../services/backend_service.dart';
import '../services/medal_engagement_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'medal_unlock_sheet.dart';

/// Linha de “falta pouco” no Hoje — só aparece no near-miss.
class MedalHomeWhisper extends StatefulWidget {
  final List<Trail> catalog;
  final String? priorityTrailSlug;
  final VoidCallback? onBible;
  final VoidCallback? onMemory;
  final VoidCallback? onMission;
  final VoidCallback? onShare;

  const MedalHomeWhisper({
    super.key,
    required this.catalog,
    this.priorityTrailSlug,
    this.onBible,
    this.onMemory,
    this.onMission,
    this.onShare,
  });

  @override
  State<MedalHomeWhisper> createState() => _MedalHomeWhisperState();
}

class _MedalHomeWhisperState extends State<MedalHomeWhisper> {
  @override
  void dispose() {
    MedalEngagementService.instance.homeVisibleProximityId = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = widget.catalog;
    final priorityTrailSlug = widget.priorityTrailSlug;
    if (catalog.isEmpty) {
      MedalEngagementService.instance.homeVisibleProximityId = null;
      return const SizedBox.shrink();
    }
    final progress = context.watch<ProgressService>();
    final uid = context.read<BackendService>().uid ?? '';
    final profile = CaravanPilgrimProfile.fromProgress(
      progress: progress,
      uid: uid,
    );
    final proximity = PilgrimMedals.nearestLocked(
      profile: profile,
      catalog: catalog,
      ctx: PilgrimMedalEvalContext.fromProgress(progress),
      priorityTrailSlug: priorityTrailSlug,
    );
    if (proximity == null || !proximity.isNearMiss) {
      MedalEngagementService.instance.homeVisibleProximityId = null;
      return const SizedBox.shrink();
    }
    // Já mostrando esta mensagem inline — o snackbar de engajamento não repete.
    MedalEngagementService.instance.homeVisibleProximityId =
        proximity.nextLevel.id;

    final accent = tierColor(proximity.nextLevel.tier);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.sm),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          switch (proximity.ctaKind) {
            case MedalCtaKind.bible:
              widget.onBible?.call();
            case MedalCtaKind.memory:
              widget.onMemory?.call();
            case MedalCtaKind.share:
              widget.onShare?.call();
            case MedalCtaKind.trail:
            case MedalCtaKind.mission:
              widget.onMission?.call();
            case MedalCtaKind.none:
              final vaults = PilgrimMedals.evaluateVaults(
                profile: profile,
                catalog: catalog,
                ctx: PilgrimMedalEvalContext.fromProgress(progress),
              );
              for (final vault in vaults) {
                for (final track in vault.tracks) {
                  if (track.track.id == proximity.track.id) {
                    showTrackDetailSheet(context, track);
                    return;
                  }
                }
              }
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Text(
          proximity.actionMessage,
          textAlign: TextAlign.center,
          style: AppTypography.label(
            size: 12,
            letterSpacing: 0.25,
            color: accent.withValues(alpha: 0.92),
          ),
        ),
      ),
    );
  }
}
