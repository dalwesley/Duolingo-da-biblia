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
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/realm_visuals.dart';
import '../utils/trail_progress.dart';
import '../widgets/act_feel.dart';
import '../widgets/app_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/journey_path.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import 'trail_map_screen.dart';

/// Peregrinação cinematográfica — trilhas dentro de um reino.
class RealmJourneyScreen extends StatefulWidget {
  final TrailRealm realm;
  final List<Trail> allTrails;

  const RealmJourneyScreen({
    super.key,
    required this.realm,
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
      _scheduleJumpToCurrent();
      // Mesma conta noutro aparelho pode ter avançado — puxa antes de pintar.
      unawaited(_pullCloudProgress());
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

  List<JourneyPathItem> _buildItems(
    List<String> completed, {
    Map<String, List<String>> clearedTrailModes = const {},
    Map<String, String> trailDifficulties = const {},
  }) {
    final realmTrails =
        widget.allTrails
            .where((t) => TrailRealm.fromId(t.realmId) == widget.realm)
            .toList()
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
        widget.allTrails,
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
        ),
      );
    }

    return items;
  }

  void _jumpToCurrent() {
    if (!mounted) return;
    final ctx = _currentKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.28,
      duration: AppMotion.slow,
      curve: AppMotion.enter,
    );
  }

  void _scheduleJumpToCurrent() {
    if (!mounted || _jumped) return;
    if (_currentKey.currentContext == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scheduleJumpToCurrent(),
      );
      return;
    }
    _jumped = true;
    Future.delayed(const Duration(milliseconds: 180), _jumpToCurrent);
  }

  void _onNodeTap(JourneyPathItem item) {
    ActHaptics.tap();
    final trail = item.trail;
    final canOpen =
        item.state == JourneyNodeState.current ||
        item.state == JourneyNodeState.completed ||
        item.state == JourneyNodeState.upcoming;

    if (canOpen && trail.missionSlugs.isNotEmpty && !trail.comingSoon) {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: AppMotion.slow,
          pageBuilder: (_, animation, secondaryAnimation) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: AppMotion.enter,
              ),
              child: TrailMapScreen(slug: trail.slug),
            );
          },
        ),
      );
      return;
    }

    _showSoonSheet(item);
  }

  void _showSoonSheet(JourneyPathItem item) {
    final visuals = RealmVisuals.of(widget.realm);
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
                title: item.trail.localizedTitle,
                subtitle: item.trail.localizedDescription,
                center: true,
              ),
              const SizedBox(height: AppSpace.xxl),
              Text(
                item.state == JourneyNodeState.locked
                    ? context.l10n.journeyLockedHint
                    : context.l10n.journeySoonHint,
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

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final visuals = RealmVisuals.of(widget.realm);
    final items = _buildItems(
      progress.completedMissions,
      clearedTrailModes: progress.clearedTrailModes,
      trailDifficulties: progress.trailDifficulties,
    );
    final bottom = MediaQuery.of(context).padding.bottom;
    final mode = progress.settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);

    // Regra de cor: a TopBar é chrome neutro (igual em todo o app); a cor da
    // área mora só no conteúdo — caminho, estações e o chip "você está aqui".
    return ImmersiveScaffold(
      mode: mode,
      style: appearance,
      body: Stack(
        children: [
          Column(
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
                  title: widget.realm.label,
                  subtitle: visuals.eyebrow,
                  onBack: () => Navigator.pop(context),
                  leadingGlyph: CinematicGlyph.path,
                  chromeAccent: AppRoles.chrome,
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  controller: _scroll,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: AppSpace.lg)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12, 4, 12, 120 + bottom),
                        child: JourneyPath(
                          items: items,
                          accent: visuals.accent,
                          glow: visuals.glow,
                          currentKey: _currentKey,
                          onTap: _onNodeTap,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Soft jump control — not a loud FAB
          Positioned(
            right: 18,
            bottom: 28 + bottom,
            child: _JumpChip(accent: visuals.accent, onTap: _jumpToCurrent),
          ),
        ],
      ),
    );
  }
}

class _JumpChip extends StatelessWidget {
  final Color accent;
  final VoidCallback onTap;

  const _JumpChip({required this.accent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      tint: accent,
      elevated: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.section,
        vertical: AppSpace.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.rise,
            size: AppMetrics.iconSm,
            accent: accent,
            framed: false,
            glowing: false,
          ),
          const SizedBox(width: AppSpace.sm),
          Text(
            context.l10n.journeyYouAreHere,
            style: AppTypography.label(
              size: 12,
              color: Appearance.of(context).text,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
