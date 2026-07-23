import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../utils/realm_visuals.dart';
import '../utils/trail_progress.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/journey_path.dart';
import '../widgets/top_bar.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleJumpToCurrent());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  List<JourneyPathItem> _buildItems(List<String> completed) {
    final realmTrails = widget.allTrails
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
      final unlocked =
          TrailProgress.isTrailUnlocked(trail, widget.allTrails, completed);
      final done = TrailProgress.isTrailCompleted(trail, completed);
      final prog = TrailProgress.getProgress(trail, completed);
      final hasContent = trail.missionSlugs.isNotEmpty && !trail.comingSoon;

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
      duration: const Duration(milliseconds: 620),
      curve: Curves.easeOutCubic,
    );
  }

  void _scheduleJumpToCurrent() {
    if (!mounted || _jumped) return;
    if (_currentKey.currentContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleJumpToCurrent());
      return;
    }
    _jumped = true;
    Future.delayed(const Duration(milliseconds: 180), _jumpToCurrent);
  }

  void _onNodeTap(JourneyPathItem item) {
    HapticFeedback.selectionClick();
    final trail = item.trail;
    final canOpen = item.state == JourneyNodeState.current ||
        item.state == JourneyNodeState.completed ||
        item.state == JourneyNodeState.upcoming;

    if (canOpen && trail.missionSlugs.isNotEmpty && !trail.comingSoon) {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 480),
          pageBuilder: (_, animation, secondaryAnimation) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.night,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpace.xxl,
            AppSpace.lg,
            AppSpace.xxl,
            AppSpace.xxl + MediaQuery.of(ctx).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpace.xxl),
              Text(
                item.trail.title,
                textAlign: TextAlign.center,
                style: AppTypography.display(size: 30),
              ),
              const SizedBox(height: AppSpace.md),
              Text(
                item.trail.description,
                textAlign: TextAlign.center,
                style: AppTypography.body(
                  size: 15,
                  height: 1.5,
                  color: Colors.white.withValues(alpha: 0.58),
                ),
              ),
              const SizedBox(height: AppSpace.xxl),
              Text(
                item.state == JourneyNodeState.locked
                    ? 'Continue a jornada anterior para alcançar este horizonte.'
                    : 'Esta trilha ainda está sendo escrita — em breve no caminho.',
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
    final items = _buildItems(progress.completedMissions);
    final bottom = MediaQuery.of(context).padding.bottom;
    final mode = progress.settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);

    return Appearance(
      mode: mode,
      style: appearance,
      child: Scaffold(
        backgroundColor: DayPhaseHelper.scaffoldBackground(appearance.phase),
        body: ImmersiveBackground(
          appearance: appearance,
          child: Stack(
            children: [
              CustomScrollView(
              controller: _scroll,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpace.screen,
                      MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
                      AppSpace.screen,
                      0,
                    ),
                    child: TopBar(
                      inline: true,
                      immersive: true,
                      dark: true,
                      title: widget.realm.label,
                      onBack: () => Navigator.pop(context),
                      leadingGlyph: CinematicGlyph.path,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: AppSpace.lg),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 20, 140 + bottom),
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

            // Soft jump control — not a loud FAB
            Positioned(
              right: 18,
              bottom: 28 + bottom,
              child: _JumpChip(
                accent: visuals.accent,
                onTap: _jumpToCurrent,
              ),
            ),
          ],
        ),
        ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.section,
            vertical: AppSpace.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            color: AppColors.night.withValues(alpha: 0.93),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.rise,
                size: 16,
                accent: accent,
                framed: false,
                glowing: false,
              ),
              const SizedBox(width: AppSpace.sm),
              Text(
                'Seu passo',
                style: AppTypography.label(
                  size: 12,
                  color: Colors.white.withValues(alpha: 0.88),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
