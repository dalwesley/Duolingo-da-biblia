import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/caravan_pilgrim_profile.dart';
import '../models/pilgrim_medals.dart';
import '../models/trail.dart';
import '../services/backend_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'medal_unlock_sheet.dart';

/// Linha de “falta pouco” no Hoje — só aparece no near-miss.
class MedalHomeWhisper extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (catalog.isEmpty) return const SizedBox.shrink();
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
      return const SizedBox.shrink();
    }

    final accent = tierColor(proximity.nextLevel.tier);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.sm),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          switch (proximity.ctaKind) {
            case MedalCtaKind.bible:
              onBible?.call();
            case MedalCtaKind.memory:
              onMemory?.call();
            case MedalCtaKind.share:
              onShare?.call();
            case MedalCtaKind.trail:
            case MedalCtaKind.mission:
              onMission?.call();
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
