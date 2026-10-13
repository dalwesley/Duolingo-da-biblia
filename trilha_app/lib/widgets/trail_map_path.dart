import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/genesis_theme.dart';
import '../utils/trail_progress.dart';
import 'cinematic_icon.dart';
import 'journey_station_card.dart';
import 'winding_trail.dart';

/// Cenas de uma etapa como cards numa curva — mesmo padrão do mapa do reino.
class TrailMapPath extends StatelessWidget {
  final List<Mission> missions;
  final int startGlobalIndex;
  final List<String> allSlugs;
  final List<String> completedMissions;
  final GenesisModuleTheme? theme;
  final Color? modeAccent;
  final void Function(String slug)? onMissionTap;

  const TrailMapPath({
    super.key,
    required this.missions,
    required this.startGlobalIndex,
    required this.allSlugs,
    required this.completedMissions,
    this.theme,
    this.modeAccent,
    this.onMissionTap,
  });

  bool _completed(String slug) => completedMissions.contains(slug);

  bool _unlocked(String slug) =>
      TrailProgress.isMissionUnlocked(slug, allSlugs, completedMissions);

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) return const SizedBox.shrink();

    final a = Appearance.of(context);
    final accent = modeAccent ?? theme?.pathActive ?? AppRoles.chrome;
    final glow = Color.lerp(accent, Colors.white, 0.22)!;

    return WindingTrail(
      walked: accent,
      track: Color.lerp(a.progressTrack, AppColors.textOnDark, 0.55)!,
      waveOffset: startGlobalIndex,
      stops: [
        for (var i = 0; i < missions.length; i++)
          _stop(context, i, accent, glow),
      ],
    );
  }

  WindingStop _stop(
    BuildContext context,
    int i,
    Color accent,
    Color glow,
  ) {
    final mission = missions[i];
    final completed = _completed(mission.slug);
    final unlocked = _unlocked(mission.slug);
    final current = unlocked && !completed;
    final state = completed
        ? JourneyNodeState.completed
        : (current
              ? JourneyNodeState.current
              : JourneyNodeState.locked);
    final index = startGlobalIndex + i + 1;
    final chrome = (current || completed)
        ? (mission.isBoss ? AppRoles.reward : accent)
        : null;
    final eyebrow = mission.isBoss
        ? context.l10n.trailMapCrossing
        : '${context.l10n.commonScene} ${journeyRomanNumeral(index)}';

    return WindingStop(
      nodeSize: 72,
      passed: completed,
      centerAnchor: true,
      child: JourneyStationCard(
        title: mission.localizedTitle,
        eyebrow: eyebrow,
        state: state,
        accent: accent,
        glow: glow,
        chrome: chrome,
        onTap: unlocked ? () => onMissionTap?.call(mission.slug) : null,
        leading: mission.isBoss
            ? CinematicIcon(
                glyph: CinematicGlyph.crown,
                size: 22,
                accent: chrome ?? accent,
                framed: false,
              )
            : null,
        statusLine: completed
            ? context.l10n.trailsCleared
            : (unlocked ? null : context.l10n.journeyBeyondHorizon),
        semanticsLabel: mission.localizedTitle,
      ),
    );
  }
}
