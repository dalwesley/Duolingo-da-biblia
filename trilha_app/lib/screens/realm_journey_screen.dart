import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_language.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../services/room_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/plus_access.dart';
import '../utils/realm_visuals.dart';
import '../utils/trail_progress.dart';
import '../widgets/act_feel.dart';
import '../widgets/app_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/journey_path.dart';
import '../widgets/journey_sky.dart';
import '../widgets/top_bar.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/ui_primitives.dart';
import 'trail_map_screen.dart';

/// Peregrinação cinematográfica — as trilhas de um card da aba Trilhas.
class RealmJourneyScreen extends StatefulWidget {
  final TrailJourney journey;
  final List<Trail> allTrails;

  const RealmJourneyScreen({
    super.key,
    required this.journey,
    required this.allTrails,
  });

  @override
  State<RealmJourneyScreen> createState() => _RealmJourneyScreenState();
}

class _RealmJourneyScreenState extends State<RealmJourneyScreen> {
  final _scroll = ScrollController();
  final _currentKey = GlobalKey();
  bool _jumped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scheduleJumpToCurrent();
      // Depois do fade de entrada, para não reconstruir a lista no meio dele.
      final wait = MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppMotion.standard;
      Future<void>.delayed(wait, () {
        if (mounted) unawaited(_pullCloudProgress());
      });
    });
  }

  Future<void> _pullCloudProgress() async {
    if (!mounted) return;
    final backend = context.read<BackendService>();
    if (!backend.isActive) return;
    await backend.pullLatestProgress(
      context.read<ProgressService>(),
      league: context.read<LeagueService>(),
      roomCode: context.read<RoomService>().activeCode,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _jumpToCurrent() {
    if (!mounted) return;
    final ctx = _currentKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.28,
      duration: MediaQuery.of(context).disableAnimations
          ? Duration.zero
          : AppMotion.slow,
      curve: AppMotion.enter,
    );
  }

  void _scheduleJumpToCurrent() {
    if (!mounted || _jumped) return;
    // A completed realm may have no current node. Do not reschedule forever.
    if (_currentKey.currentContext == null) return;
    _jumped = true;
    final wait = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.standard;
    Future<void>.delayed(wait, _jumpToCurrent);
  }

  void _onNodeTap(JourneyPathItem item) => openJourneyItem(context, item);

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final journey = widget.journey;
    final visuals = RealmVisuals.of(journey.realm);
    final items = realmJourneyItems(
      context,
      journey: journey,
      allTrails: widget.allTrails,
      progress: progress,
    );
    if (!_jumped &&
        items.any((item) => item.state == JourneyNodeState.current)) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scheduleJumpToCurrent(),
      );
    }
    final bottom = MediaQuery.of(context).padding.bottom;
    final mode = progress.settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);

    // Regra de cor: a TopBar é chrome neutro (igual em todo o app); a cor da
    // área mora só no conteúdo — caminho e estações.
    return ImmersiveScaffold(
      mode: mode,
      style: appearance,
      frameBody: false,
      background: JourneySkyBackdrop(journey: journey, appearance: appearance),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpace.screen,
              MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
              AppSpace.screen,
              0,
            ),
            child: TopBar(
              inline: true,
              immersive: true,
              title: journey.label,
              // Card de uma categoria só: a área vira o subtítulo.
              subtitle: journey.categories.length > 1
                  ? visuals.eyebrow
                  : journey.shelf.label,
              onBack: () => Navigator.pop(context),
              leadingGlyph: CinematicGlyph.path,
            ),
          ),
          Expanded(
            child: ContentFrame(
              child: CustomScrollView(
                controller: _scroll,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: AppSpace.lg)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        4,
                        0,
                        AppSpace.xxxl + bottom,
                      ),
                      child: JourneyPath(
                        items: items,
                        accent: visuals.accent,
                        glow: visuals.glow,
                        currentKey: _currentKey,
                        onTap: _onNodeTap,
                        phaseCards: journey.categories.length > 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Trilhas de um card na ordem do cânon, com o estado de cada uma.
List<JourneyPathItem> realmJourneyItems(
  BuildContext context, {
  required TrailJourney journey,
  required List<Trail> allTrails,
  required ProgressService progress,
}) {
  final completed = progress.completedMissions;
  final clearedTrailModes = progress.clearedTrailModes;
  final trailDifficulties = progress.trailDifficulties;
  final plusOpen = context.watch<SubscriptionService>().plusFeaturesOpen;
  final realmTrails = allTrails.where((t) => t.journey == journey).toList()
    ..sort((a, b) {
      final ca = TrailCategory.fromId(a.categoryId).order;
      final cb = TrailCategory.fromId(b.categoryId).order;
      if (ca != cb) return ca.compareTo(cb);
      return a.order.compareTo(b.order);
    });

  var sawCurrent = false;
  final items = <JourneyPathItem>[];

  for (final trail in realmTrails) {
    final unlocked = TrailProgress.isTrailUnlocked(
      trail,
      allTrails,
      completed,
      clearedTrailModes: clearedTrailModes,
    );
    final done = TrailProgress.isTrailCompleted(
      trail,
      completed,
      clearedTrailModes: clearedTrailModes,
    );
    final prog = TrailProgress.getProgress(
      trail,
      completed,
      clearedTrailModes: clearedTrailModes,
    );
    final hasContent = trail.missionSlugs.isNotEmpty && !trail.comingSoon;
    final cleared = clearedTrailModes[trail.slug] ?? const <String>[];
    final live = TrailProgress.getLiveProgress(trail, completed);
    final storedId = TrailProgress.resolvedDifficultyId(
      trail.slug,
      trailDifficulties[trail.slug],
    );
    final openId = TrailProgress.openDifficultyId(
      activeDifficultyId: storedId,
      clearedModes: cleared,
    );
    final replaying = TrailProgress.isReplayingUnclearedMode(
      clearedModes: cleared,
      activeDifficultyId: storedId,
      liveDone: live.done,
      total: live.total,
    );
    final clearedLabel = TrailProgress.clearedModeStatusLabel(cleared);
    final String? statusLabel;
    if (done && clearedLabel != null) {
      if (replaying) {
        statusLabel = context.l10n.journeyModeInProgress(
          TrailProgress.modeLabel(storedId),
        );
      } else if (openId != null && !cleared.contains(openId)) {
        statusLabel = context.l10n.journeyModeAhead(
          TrailProgress.modeLabel(openId),
        );
      } else {
        statusLabel = clearedLabel;
      }
    } else if (!done && unlocked && hasContent && storedId != null) {
      statusLabel = TrailProgress.activeModeProgressLabel(
        clearedModes: cleared,
        activeDifficultyId: storedId,
        liveDone: live.done,
        total: live.total,
      );
    } else {
      statusLabel = null;
    }

    final JourneyNodeState state;
    if (!unlocked) {
      state = JourneyNodeState.locked;
    } else if (done) {
      state = JourneyNodeState.completed;
    } else if (!hasContent) {
      state = JourneyNodeState.soon;
    } else if (!sawCurrent) {
      state = JourneyNodeState.current;
      sawCurrent = true;
    } else {
      state = JourneyNodeState.upcoming;
    }

    items.add(
      JourneyPathItem(
        trail: trail,
        state: state,
        category: TrailCategory.fromId(trail.categoryId),
        done: prog.done,
        total: prog.total,
        statusLabel: statusLabel,
        clearedModeIds: cleared,
        activeDifficultyId: openId ?? storedId,
        plusLocked:
            !plusOpen &&
            unlocked &&
            !done &&
            PlusAccess.trailIsPlus(trail) &&
            PlusAccess.missionNeedsPlus(
              trail,
              TrailProgress.getCurrentMission(
                    trail,
                    progress.completedMissionsForTrail(
                      trailSlug: trail.slug,
                      missionSlugs: trail.missionSlugs,
                    ),
                  )?.slug ??
                  '',
            ),
        lockedBy: unlocked
            ? null
            : TrailProgress.blockingTrail(
                trail,
                allTrails,
                completed,
                clearedTrailModes: clearedTrailModes,
              )?.localizedTitle,
      ),
    );
  }

  return items;
}

/// Abre a trilha; bloqueada ou sem conteúdo mostra o aviso.
void openJourneyItem(BuildContext context, JourneyPathItem item) {
  ActHaptics.tap();
  final trail = item.trail;
  final canOpen =
      item.state == JourneyNodeState.current ||
      item.state == JourneyNodeState.completed ||
      item.state == JourneyNodeState.upcoming;

  if (canOpen && trail.missionSlugs.isNotEmpty && !trail.comingSoon) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: reduced ? Duration.zero : AppMotion.standard,
        reverseTransitionDuration: reduced ? Duration.zero : AppMotion.quick,
        pageBuilder: (_, _, _) => TrailMapScreen(slug: trail.slug),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
    return;
  }

  final visuals = RealmVisuals.of(TrailRealm.fromId(trail.realmId));
  showAppSheet<void>(
    context,
    builder: (ctx) {
      return AppSheetPanel(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.xxl,
          AppSpace.md,
          AppSpace.xxl,
          AppSpace.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpace.sm),
            AppSheetHeader(
              face: CloudFace.triste,
              title: trail.localizedTitle,
              subtitle: trail.localizedDescription,
              center: true,
            ),
            const SizedBox(height: AppSpace.xxl),
            Text(
              item.state == JourneyNodeState.locked
                  ? (item.lockedBy != null
                        ? ctx.l10n.journeyLockedFinish(item.lockedBy!)
                        : ctx.l10n.journeyLockedHint)
                  : ctx.l10n.journeySoonHint,
              textAlign: TextAlign.center,
              style: AppTypography.label(
                size: 13,
                color: visuals.accent.withValues(alpha: 0.9),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    },
  );
}
