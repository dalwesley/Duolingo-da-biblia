import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/realm_visuals.dart';
import '../utils/trail_progress.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/hero_continue_card.dart';
import '../widgets/immersive_background.dart';
import '../widgets/offline_curriculum_dialog.dart';
import '../widgets/realm_world_atmosphere.dart';
import '../widgets/ui_primitives.dart';
import 'realm_journey_screen.dart';
import 'trail_map_screen.dart';

/// Seleção de trilhas — cada reino é um caminho cinematográfico.
class TrilhasScreen extends StatefulWidget {
  final TrailRepository repo;
  final bool asPushedPage;
  final Widget? topBar;

  /// Quando false (aba oculta no IndexedStack), pausa animações dos portais.
  final bool portalsActive;

  const TrilhasScreen({
    super.key,
    required this.repo,
    this.asPushedPage = false,
    this.topBar,
    this.portalsActive = true,
  });

  @override
  State<TrilhasScreen> createState() => _TrilhasScreenState();
}

class _TrilhasScreenState extends State<TrilhasScreen>
    with SingleTickerProviderStateMixin {
  List<Trail>? _trails;
  late final AnimationController _enter;
  bool _retryingCatalog = false;
  bool _offlineDialogShown = false;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _load();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    if (forceRefresh) {
      setState(() {
        _retryingCatalog = true;
        _trails = null;
      });
    }
    final trails = await widget.repo.getTrails(forceRefresh: forceRefresh);
    if (mounted) {
      setState(() {
        _trails = trails;
        _retryingCatalog = false;
      });
      if (trails.isEmpty) {
        _maybeShowOfflineDialog();
      } else {
        _offlineDialogShown = false;
      }
    }
  }

  void _maybeShowOfflineDialog() {
    if (_offlineDialogShown || !mounted) return;
    _offlineDialogShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || (_trails?.isNotEmpty ?? false)) return;
      final ok = await showOfflineCurriculumDialog(
        context,
        onRetry: () async {
          final trails = await widget.repo.getTrails(forceRefresh: true);
          if (mounted) {
            setState(() {
              _trails = trails;
              _retryingCatalog = false;
            });
          }
          return trails.isNotEmpty;
        },
      );
      if (!mounted) return;
      if (!ok) _offlineDialogShown = false;
    });
  }

  Widget _reveal(int index, Widget child) {
    if (_enter.isCompleted) return child;
    final start = (0.08 * index).clamp(0.0, 0.55);
    final end = (start + 0.42).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _enter,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  void _openRealm(TrailRealm realm) {
    HapticFeedback.mediumImpact();
    final trails = _trails!;
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, animation, secondaryAnimation) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.04, end: 1).animate(fade),
              child: RealmJourneyScreen(realm: realm, allTrails: trails),
            ),
          );
        },
      ),
    );
  }

  void _showTeologiaSoonSheet() {
    HapticFeedback.selectionClick();
    final visuals = RealmVisuals.of(TrailRealm.teologia);
    final a = Appearance.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: a.cardFill,
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
                'Teologia',
                style: AppTypography.display(size: 26, color: a.text),
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                'Hermenêutica, línguas originais e dogmática — em preparação.',
                textAlign: TextAlign.center,
                style: AppTypography.body(
                  size: 14,
                  height: 1.4,
                  color: a.textMuted(0.72),
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Text(
                'Em breve',
                style: AppTypography.label(
                  size: 12,
                  letterSpacing: 1.2,
                  color: visuals.accent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _RealmInfo _infoFor(
    TrailRealm realm,
    List<Trail> trails,
    ProgressService progress, {
    bool locked = false,
  }) {
    final realmTrails =
        trails.where((t) => TrailRealm.fromId(t.realmId) == realm).toList();
    final unlocked = realmTrails
        .where(
          (t) =>
              TrailProgress.isTrailUnlocked(
                t,
                trails,
                progress.completedMissions,
                clearedTrailModes: progress.clearedTrailModes,
              ) &&
              t.missionSlugs.isNotEmpty &&
              !t.comingSoon,
        )
        .length;
    final completed = realmTrails
        .where(
          (t) => TrailProgress.isTrailCompleted(
            t,
            progress.completedMissions,
            clearedTrailModes: progress.clearedTrailModes,
          ),
        )
        .length;
    return _RealmInfo(
      realm: realm,
      trailCount: realmTrails.length,
      unlockedCount: unlocked,
      completedCount: completed,
      locked: locked,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final topInset = MediaQuery.viewPaddingOf(context).top;

    if (_trails == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_trails!.isEmpty) {
      final a = Appearance.of(context);
      return ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpace.screen,
          topInset + AppSpace.xxl,
          AppSpace.screen,
          scrollPaddingBelowNav(context),
        ),
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpace.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Missões ainda não chegaram',
                  textAlign: TextAlign.center,
                  style: AppTypography.title(size: 18, color: a.text),
                ),
                const SizedBox(height: AppSpace.md),
                Text(
                  'O currículo baixa na primeira abertura. Se a rede oscilar, toque para tentar de novo.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(size: 14, color: a.textMuted(0.7)),
                ),
                const SizedBox(height: AppSpace.xxl),
                CopperCta(
                  label: _retryingCatalog ? 'Baixando…' : 'Tentar de novo',
                  onTap: _retryingCatalog ? null : _maybeShowOfflineDialog,
                  showArrow: false,
                ),
              ],
            ),
          ),
        ],
      );
    }

    final trails = _trails!;
    final active = TrailProgress.findActiveTrail(
      trails,
      progress.completedMissions,
      clearedTrailModes: progress.clearedTrailModes,
    );
    final current = active == null
        ? null
        : TrailProgress.getCurrentMission(active, progress.completedMissions);
    final activeRealm = active == null
        ? null
        : TrailRealm.fromId(active.realmId);
    final realms = [
      _infoFor(TrailRealm.antigoTestamento, trails, progress),
      _infoFor(TrailRealm.novoTestamento, trails, progress),
      _infoFor(TrailRealm.vidaCrista, trails, progress),
      _infoFor(TrailRealm.teologia, trails, progress, locked: true),
    ];

    final topPad = widget.topBar != null
        ? topInset + AppSpace.sm
        : widget.asPushedPage
        ? AppSpace.md
        : AppSpace.sm;
    final bottomPad = widget.asPushedPage
        ? 32 + MediaQuery.viewPaddingOf(context).bottom
        : scrollPaddingBelowNav(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpace.screen,
        topPad,
        AppSpace.screen,
        bottomPad,
      ),
      physics: const BouncingScrollPhysics(),
      children: [
        if (widget.topBar != null) ...[
          widget.topBar!,
          const SizedBox(height: AppSpace.afterTopBar),
        ],
        if (active != null)
          _reveal(
            0,
            TickerMode(
              enabled: widget.portalsActive,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.section),
                child: HeroContinueCard(
                  mission: current,
                  trailTitle: active.title,
                  trailSlug: active.slug,
                  trailColor: active.color,
                  onTap: current != null
                      ? () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  TrailMapScreen(slug: active.slug),
                            ),
                          );
                        }
                      : null,
                  goalMet: progress.dailyGoalMet,
                  atRisk: progress.isStreakAtRisk,
                  lampsReady: ProgressService.lampsForMission(
                    isBoss: current?.isBoss ?? false,
                  ),
                ),
              ),
            ),
          ),
        _reveal(
          1,
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: AppSpace.lg),
            child: _FilmChapterMark(label: 'Os caminhos'),
          ),
        ),
        for (var i = 0; i < realms.length; i++)
          _reveal(
            2 + i,
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.section),
              child: _RealmPoster(
                info: realms[i],
                featured: activeRealm == realms[i].realm && !realms[i].locked,
                animate: widget.portalsActive,
                onTap: realms[i].locked
                    ? _showTeologiaSoonSheet
                    : () => _openRealm(realms[i].realm),
              ),
            ),
          ),
      ],
    );
  }
}

class _RealmInfo {
  final TrailRealm realm;
  final int trailCount;
  final int unlockedCount;
  final int completedCount;
  final bool locked;

  const _RealmInfo({
    required this.realm,
    required this.trailCount,
    required this.unlockedCount,
    required this.completedCount,
    required this.locked,
  });

  double get ratio =>
      trailCount <= 0 ? 0 : (completedCount / trailCount).clamp(0.0, 1.0);
}

class _FilmChapterMark extends StatelessWidget {
  final String label;

  const _FilmChapterMark({required this.label});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: a.cardBorder.withValues(alpha: 0.7),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label.toUpperCase(),
            style: AppTypography.label(
              size: 11,
              letterSpacing: 2.4,
              color: a.textMuted(0.72),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: a.cardBorder.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _RealmPoster extends StatefulWidget {
  final _RealmInfo info;
  final bool featured;
  final bool animate;
  final VoidCallback onTap;

  const _RealmPoster({
    required this.info,
    required this.featured,
    required this.animate,
    required this.onTap,
  });

  @override
  State<_RealmPoster> createState() => _RealmPosterState();
}

class _RealmPosterState extends State<_RealmPoster> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final visuals = RealmVisuals.of(widget.info.realm);
    final a = Appearance.of(context);
    final locked = widget.info.locked;
    final featured = widget.featured;
    final height = featured ? 320.0 : 248.0;
    final progressLabel = locked
        ? 'Em preparação'
        : widget.info.completedCount > 0
            ? '${widget.info.completedCount} de ${widget.info.trailCount} trilhas'
            : widget.info.unlockedCount > 0
                ? '${widget.info.unlockedCount} abertas'
                : '${widget.info.trailCount} trilhas';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
            boxShadow: [
              ...AppMetrics.cardShadow(elevated: true),
              if (featured)
                BoxShadow(
                  color: visuals.accent.withValues(alpha: 0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                RealmWorldAtmosphere(
                  realm: widget.info.realm,
                  animate: widget.animate && !locked,
                  locked: locked,
                  featured: featured,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: CinematicIcon(
                      glyph: locked ? CinematicGlyph.lock : visuals.glyph,
                      size: featured ? 72 : 58,
                      accent: visuals.accent,
                      glowing: featured && widget.animate && !locked,
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilmEyebrow(
                        text: visuals.eyebrow,
                        accent: visuals.accent,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.info.realm.label,
                        textAlign: TextAlign.center,
                        style: AppTypography.display(
                          size: featured ? 34 : 28,
                          color: a.text,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        visuals.tagline,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(
                          size: 13,
                          height: 1.35,
                          color: a.text.withValues(alpha: 0.72),
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppProgressBar(
                        value: locked ? 0 : widget.info.ratio,
                        height: 8,
                        color: visuals.accent,
                        trackColor: visuals.accent.withValues(alpha: 0.18),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (featured)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(
                                'EM CENA',
                                style: AppTypography.label(
                                  size: 10,
                                  letterSpacing: 1.6,
                                  color: visuals.accent,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              progressLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body(
                                size: 12,
                                weight: FontWeight.w700,
                                color: a.textMuted(0.62),
                              ),
                            ),
                          ),
                          Text(
                            locked ? 'EM BREVE' : 'ENTRAR',
                            style: AppTypography.label(
                              size: 11,
                              letterSpacing: 1.6,
                              color: visuals.accent,
                            ),
                          ),
                          const SizedBox(width: 4),
                          CinematicIcon(
                            glyph: CinematicGlyph.path,
                            size: 16,
                            accent: visuals.accent,
                            framed: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppMetrics.heroRadius,
                        ),
                        border: Border.all(
                          color: visuals.accent.withValues(
                            alpha: featured ? 0.62 : locked ? 0.22 : 0.4,
                          ),
                          width: featured ? 1.7 : 1.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
