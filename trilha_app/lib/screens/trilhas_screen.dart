import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../l10n/app_language.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/realm_visuals.dart';
import '../utils/trail_progress.dart';
import '../utils/trail_visuals.dart';
import '../widgets/act_feel.dart';
import '../widgets/app_sheet.dart';
import '../widgets/author_suggestion_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/coming_soon_trails_card.dart';
import '../widgets/immersive_background.dart';
import '../widgets/offline_curriculum_dialog.dart';
import '../widgets/realm_world_atmosphere.dart';
import '../widgets/relic_panel.dart';
import '../widgets/shell_tab_scope.dart';
import '../widgets/stway_brand.dart';
import '../widgets/trail_suggestion_sheet.dart';
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
    with SingleTickerProviderStateMixin, ShellTabFreezeMixin {
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
    // Mesma árvore antes e depois da entrada: devolver o filho sem o
    // wrapper no fim remontava o card inteiro (estado e animações dele).
    // drive() não prende listener no controller (CurvedAnimation prenderia
    // um por build).
    final start = (0.08 * index).clamp(0.0, 0.55);
    final end = (start + 0.42).clamp(0.0, 1.0);
    final curve = _enter.drive(
      CurveTween(curve: Interval(start, end, curve: AppMotion.enter)),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: curve.drive(
          Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }

  void _openRealm(TrailRealm realm) {
    final trails = _trails!;
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: AppMotion.gentle,
        reverseTransitionDuration: AppMotion.gentle,
        pageBuilder: (_, animation, secondaryAnimation) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: AppMotion.enter,
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

  Future<void> _suggestTrail() async {
    final ok = await showTrailSuggestionSheet(context);
    if (!mounted || !ok) return;
    showAppToastFor(
      context,
      message: context.l10n.suggestionTrailSent,
      glyph: CinematicGlyph.spark,
    );
  }

  Future<void> _suggestAuthor() async {
    final ok = await showAuthorSuggestionSheet(context);
    if (!mounted || !ok) return;
    showAppToastFor(
      context,
      message: context.l10n.suggestionAuthorSent,
      glyph: CinematicGlyph.people,
    );
  }

  Future<void> _openDonate() => openDonatePage();

  void _showTeologiaSoonSheet() {
    final visuals = RealmVisuals.of(TrailRealm.teologia);
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
                title: TrailRealm.teologia.label,
                subtitle:
                    ctx.l10n.realmTeologiaSoonBody,
                center: true,
              ),
              const SizedBox(height: AppSpace.lg),
              SoftBadge(
                text: ctx.l10n.commonComingSoon,
                accent: visuals.accent,
                textColor: visuals.accent,
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
    final realmTrails = trails
        .where((t) => TrailRealm.fromId(t.realmId) == realm)
        .toList();
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
    final stamps = [
      for (final t in realmTrails)
        _TrailStamp(
          visuals: TrailVisuals.forTrail(t),
          ratio:
              TrailProgress.getProgress(
                t,
                progress.completedMissions,
                clearedTrailModes: progress.clearedTrailModes,
              ).pct /
              100,
          open:
              !t.comingSoon &&
              t.missionSlugs.isNotEmpty &&
              TrailProgress.isTrailUnlocked(
                t,
                trails,
                progress.completedMissions,
                clearedTrailModes: progress.clearedTrailModes,
              ),
        ),
    ];
    return _RealmInfo(
      realm: realm,
      stamps: stamps,
      trailCount: realmTrails.length,
      unlockedCount: unlocked,
      completedCount: completed,
      locked: locked,
    );
  }

  @override
  Widget build(BuildContext context) {
    return freezeTab(() => _buildTrilhas(context));
  }

  Widget _buildTrilhas(BuildContext context) {
    final progress = tabListens
        ? context.watch<ProgressService>()
        : context.read<ProgressService>();
    final topInset = MediaQuery.viewPaddingOf(context).top;

    if (_trails == null) {
      return const AppSpinner();
    }

    if (_trails!.isEmpty) {
      return ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpace.screen,
          topInset + AppSpace.xxl,
          AppSpace.screen,
          scrollPaddingBelowNav(context),
        ),
        children: [
          EmptyState(
            glyph: CinematicGlyph.path,
            title: context.l10n.trailsEmptyTitle,
            body: context.l10n.trailsEmptyBody,
            action: CopperCta(
              label: _retryingCatalog
                  ? context.l10n.trailsDownloading
                  : context.l10n.commonTryAgain,
              onTap: _retryingCatalog ? null : _maybeShowOfflineDialog,
              showArrow: false,
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
      _infoFor(
        TrailRealm.teologia,
        trails,
        progress,
        locked: trails
            .where((t) => TrailRealm.fromId(t.realmId) == TrailRealm.teologia)
            .every((t) => t.comingSoon || t.missionSlugs.isEmpty),
      ),
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
        if (active != null && current != null)
          _reveal(
            0,
            TickerMode(
              enabled: widget.portalsActive,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.section),
                child: _NowPlayingStrip(
                  trail: active,
                  mission: current,
                  progress: TrailProgress.getLiveProgress(
                    active,
                    progress.completedMissions,
                  ),
                  atRisk: progress.isStreakAtRisk,
                  countdown: progress.streakRiskCountdown,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TrailMapScreen(slug: active.slug),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        _reveal(
          1,
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: AppSpace.lg),
            child: RelicChapter(
              title: context.l10n.trailsAreasHeading,
              accent: AppRoles.chrome,
            ),
          ),
        ),
        for (var i = 0; i < realms.length; i++)
          _reveal(
            2 + i,
            Column(
              children: [
                if (i > 0)
                  _PathLink(
                    from: RealmVisuals.of(realms[i - 1].realm).accent,
                    to: RealmVisuals.of(realms[i].realm).accent,
                    walked: realms[i - 1].completedCount > 0,
                    animate: widget.portalsActive,
                  ),
                _RealmPoster(
                  info: realms[i],
                  act: i + 1,
                  featured: activeRealm == realms[i].realm && !realms[i].locked,
                  animate: widget.portalsActive,
                  onTap: realms[i].locked
                      ? _showTeologiaSoonSheet
                      : () => _openRealm(realms[i].realm),
                ),
              ],
            ),
          ),
        _reveal(
          2 + realms.length,
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.section),
            child: ComingSoonTrailsCard(
              onSuggest: _suggestTrail,
              onSuggestAuthor: _suggestAuthor,
            ),
          ),
        ),
        _reveal(
          3 + realms.length,
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.section),
            child: DonateCard(onDonate: _openDonate),
          ),
        ),
      ],
    );
  }
}

class _TrailStamp {
  final TrailVisuals visuals;
  final double ratio;
  final bool open;

  const _TrailStamp({
    required this.visuals,
    required this.ratio,
    required this.open,
  });
}

class _RealmInfo {
  final TrailRealm realm;
  final List<_TrailStamp> stamps;
  final int trailCount;
  final int unlockedCount;
  final int completedCount;
  final bool locked;

  const _RealmInfo({
    required this.realm,
    this.stamps = const [],
    required this.trailCount,
    required this.unlockedCount,
    required this.completedCount,
    required this.locked,
  });

  double get ratio =>
      trailCount <= 0 ? 0 : (completedCount / trailCount).clamp(0.0, 1.0);
}

/// Próxima cena da trilha ativa — faixa compacta; o palco grande fica na Home.
class _NowPlayingStrip extends StatefulWidget {
  final Trail trail;
  final Mission mission;
  final ({int done, int total, int pct}) progress;
  final bool atRisk;
  final String countdown;
  final VoidCallback onTap;

  const _NowPlayingStrip({
    required this.trail,
    required this.mission,
    required this.progress,
    required this.atRisk,
    required this.countdown,
    required this.onTap,
  });

  @override
  State<_NowPlayingStrip> createState() => _NowPlayingStripState();
}

class _NowPlayingStripState extends State<_NowPlayingStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);
  bool _pressed = false;

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final visuals = TrailVisuals.forTrail(widget.trail);
    final accent = visuals.accent;
    final label = widget.atRisk
        ? context.l10n.trailsStreakAtRisk(widget.countdown)
        : context.l10n.trailsInProgress;
    final labelColor = widget.atRisk ? AppRoles.risk : accent;
    final p = widget.progress;

    return Semantics(
      button: true,
      label: context.l10n.trailsContinueSemantics(widget.mission.localizedTitle),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          ActHaptics.confirm();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.985 : 1,
          duration: AppMotion.quick,
          curve: AppMotion.enter,
          child: GlassCard(
            radius: AppMetrics.heroRadius,
            elevated: true,
            tint: accent,
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppMetrics.heroRadius - AppMetrics.cardBorderWidth,
              ),
              child: Stack(
                children: [
                  // Halo do glifo — luz da trilha vazando pelo canto.
                  Positioned(
                    left: -40,
                    top: -50,
                    child: IgnorePointer(
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              accent.withValues(alpha: 0.28),
                              accent.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: AppMetrics.cardPadding,
                    child: Row(
                      children: [
                        CinematicIcon(
                          glyph: visuals.glyph,
                          size: AppMetrics.iconHero,
                          accent: accent,
                          glowing: true,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SectionLabel(label, size: 10, color: labelColor),
                              const SizedBox(height: 4),
                              Text(
                                widget.mission.localizedTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.title(
                                  size: 16,
                                  color: a.text,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.l10n.trailsLabeledScenesOf(
                                  widget.trail.localizedTitle,
                                  p.done,
                                  p.total,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.body(
                                  size: 12,
                                  color: a.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              AppProgressBar(
                                value: p.total == 0 ? 0 : p.done / p.total,
                                height: 6,
                                color: accent,
                                trackColor: accent.withValues(alpha: 0.18),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        RepaintBoundary(
                          child: AnimatedBuilder(
                            animation: _pulse,
                            builder: (context, child) {
                              final t = AppMotion.move.transform(
                                _pulse.value,
                              );
                              return Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppRoles.action,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppRoles.action.withValues(
                                        alpha: 0.18 + 0.28 * t,
                                      ),
                                      blurRadius: 10 + 12 * t,
                                      spreadRadius: 1 + 2 * t,
                                    ),
                                  ],
                                ),
                                child: child,
                              );
                            },
                            child: const Center(
                              child: CinematicIcon(
                                glyph: CinematicGlyph.forward,
                                size: AppMetrics.iconMd,
                                accent: AppRoles.onAction,
                                framed: false,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Trecho do caminho entre dois reinos — pontilhado que desce e brilha.
class _PathLink extends StatefulWidget {
  final Color from;
  final Color to;
  final bool walked;
  final bool animate;

  const _PathLink({
    required this.from,
    required this.to,
    required this.walked,
    required this.animate,
  });

  @override
  State<_PathLink> createState() => _PathLinkState();
}

class _PathLinkState extends State<_PathLink>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _flow.repeat();
  }

  @override
  void didUpdateWidget(covariant _PathLink oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_flow.isAnimating) {
      _flow.repeat();
    } else if (!widget.animate && _flow.isAnimating) {
      _flow.stop();
    }
  }

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _PathLinkPainter(
            from: widget.from,
            to: widget.to,
            walked: widget.walked,
            flow: _flow,
          ),
        ),
      ),
    );
  }
}

class _PathLinkPainter extends CustomPainter {
  final Color from;
  final Color to;
  final bool walked;
  final Animation<double> flow;

  _PathLinkPainter({
    required this.from,
    required this.to,
    required this.walked,
    required this.flow,
  }) : super(repaint: flow);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final h = size.height;
    final alpha = walked ? 0.85 : 0.4;
    const dot = 3.0;
    const gap = 9.0;
    final offset = flow.value * gap;
    final paint = Paint()..style = PaintingStyle.fill;
    for (var y = -gap + offset; y < h; y += gap) {
      if (y < 0) continue;
      final t = (y / h).clamp(0.0, 1.0);
      final c = Color.lerp(from, to, t)!;
      // Fica mais fino perto das pontas — parece sair de dentro do pôster.
      final edge = math.sin(t * math.pi).clamp(0.35, 1.0);
      paint.color = c.withValues(alpha: alpha * edge);
      canvas.drawCircle(Offset(cx, y), dot * 0.5 * (0.7 + 0.3 * edge), paint);
    }
    // Marco no meio do trecho.
    final mid = Offset(cx, h / 2);
    final c = Color.lerp(from, to, 0.5)!;
    canvas.drawCircle(
      mid,
      9,
      Paint()
        ..color = c.withValues(alpha: walked ? 0.28 : 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    final diamond = Path()
      ..moveTo(mid.dx, mid.dy - 5.5)
      ..lineTo(mid.dx + 5.5, mid.dy)
      ..lineTo(mid.dx, mid.dy + 5.5)
      ..lineTo(mid.dx - 5.5, mid.dy)
      ..close();
    canvas.drawPath(
      diamond,
      Paint()..color = c.withValues(alpha: walked ? 0.95 : 0.5),
    );
  }

  @override
  bool shouldRepaint(covariant _PathLinkPainter old) =>
      old.from != from || old.to != to || old.walked != walked;
}

/// Céu do pôster anda mais devagar que o scroll — profundidade.
class _ParallaxFlowDelegate extends FlowDelegate {
  final ScrollableState scrollable;
  final BuildContext itemContext;
  final double overscan;

  _ParallaxFlowDelegate({
    required this.scrollable,
    required this.itemContext,
    required this.overscan,
  }) : super(repaint: scrollable.position);

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(
      width: constraints.maxWidth,
      height: constraints.maxHeight * overscan,
    );
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final box = itemContext.findRenderObject() as RenderBox?;
    final viewport = scrollable.context.findRenderObject() as RenderBox?;
    if (box == null || viewport == null || !box.hasSize) {
      context.paintChild(0);
      return;
    }
    final itemOffset = box.localToGlobal(
      box.size.centerLeft(Offset.zero),
      ancestor: viewport,
    );
    final viewH = scrollable.position.viewportDimension;
    final fraction = (itemOffset.dy / viewH).clamp(0.0, 1.0);
    final extra = context.size.height * (overscan - 1);
    final dy = -extra * fraction;
    context.paintChild(0, transform: Matrix4.translationValues(0, dy, 0));
  }

  @override
  bool shouldRepaint(_ParallaxFlowDelegate old) =>
      scrollable != old.scrollable ||
      itemContext != old.itemContext ||
      overscan != old.overscan;
}

const _romanActs = ['I', 'II', 'III', 'IV', 'V', 'VI'];

class _RealmPoster extends StatefulWidget {
  final _RealmInfo info;
  final int act;
  final bool featured;
  final bool animate;
  final VoidCallback onTap;

  const _RealmPoster({
    required this.info,
    required this.act,
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
    final stamps = locked ? const <_TrailStamp>[] : widget.info.stamps;
    final height = (featured ? 340.0 : 268.0) + (stamps.isEmpty ? 0 : 20);
    final progressLabel = locked
        ? context.l10n.commonComingSoon
        : widget.info.completedCount > 0
        ? context.l10n.trailsRealmTrailsDone(
            widget.info.completedCount,
            widget.info.trailCount,
          )
        : widget.info.unlockedCount > 0
        ? context.l10n.trailsRealmOpenCount(widget.info.unlockedCount)
        : context.l10n.trailsRealmTrailCount(widget.info.trailCount);
    final scrollable = Scrollable.maybeOf(context);
    final act = widget.act - 1 < _romanActs.length
        ? _romanActs[widget.act - 1]
        : '${widget.act}';

    final world = RealmWorldAtmosphere(
      realm: widget.info.realm,
      animate: widget.animate && !locked,
      locked: locked,
      featured: featured,
      terrain: false,
    );

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        ActHaptics.confirm();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: AppMotion.quick,
        curve: AppMotion.enter,
        child: AnimatedContainer(
          duration: AppMotion.gentle,
          curve: AppMotion.enter,
          height: height,
          // Cartaz = palco (GlassCard `glow`): borda e brilho na cor da área,
          // mais aceso no reino em que a pessoa está. O céu do reino fica
          // dentro do card — cenário só dentro de card herói.
          child: GlassCard(
            radius: AppMetrics.heroRadius,
            padding: EdgeInsets.zero,
            tint: visuals.accent,
            glow: locked
                ? 0
                : featured
                ? 1
                : 0.3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (scrollable != null)
                  Flow(
                    delegate: _ParallaxFlowDelegate(
                      scrollable: scrollable,
                      itemContext: context,
                      overscan: 1.22,
                    ),
                    children: [world],
                  )
                else
                  world,
                _BrandFloor(locked: locked),
                // Numeral do ato — marca d'água de abertura de capítulo.
                Positioned(
                  left: 18,
                  top: 10,
                  child: IgnorePointer(
                    child: Text(
                      act,
                      style: AppTypography.display(
                        size: 48,
                        weight: FontWeight.w900,
                        color: visuals.accent.withValues(
                          alpha: locked ? 0.1 : 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: CinematicIcon(
                      glyph: locked ? CinematicGlyph.lock : visuals.glyph,
                      size: AppMetrics.iconHero,
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
                      SectionLabel(
                        visuals.eyebrow,
                        color: visuals.accent,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.info.realm.label,
                        textAlign: TextAlign.center,
                        style: AppTypography.display(
                          size: featured ? 32 : 28,
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
                          color: a.textSecondary,
                        ),
                      ),
                      if (stamps.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _StampRow(stamps: stamps, accent: visuals.accent),
                      ],
                      const SizedBox(height: 14),
                      AppProgressBar(
                        value: locked ? 0 : widget.info.ratio,
                        height: 6,
                        color: visuals.accent,
                        trackColor: visuals.accent.withValues(alpha: 0.18),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (featured)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: SectionLabel(
                                context.l10n.journeyNow,
                                size: 10,
                                color: visuals.accent,
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
                                color: a.textSecondary,
                              ),
                            ),
                          ),
                          SectionLabel(
                            locked
                                ? context.l10n.trailsLearnMore
                                : (featured || widget.info.completedCount > 0
                                      ? context.l10n.commonContinue
                                      : context.l10n.commonStart),
                            color: visuals.accent,
                          ),
                          const SizedBox(width: 4),
                          CinematicIcon(
                            glyph: CinematicGlyph.forward,
                            size: AppMetrics.iconSm,
                            accent: visuals.accent,
                            framed: false,
                          ),
                        ],
                      ),
                    ],
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

/// Chão do cartaz: a trilha STWAY, escura, sob o céu estrelado do reino.
///
/// O caminho aparece nas laterais. O centro, onde está o título, fica no escuro.
class _BrandFloor extends StatelessWidget {
  final bool locked;

  const _BrandFloor({required this.locked});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x00FFFFFF),
                Color(0x00FFFFFF),
                Color(0xB8FFFFFF),
                Color(0x8CFFFFFF),
              ],
              stops: [0.0, 0.28, 0.5, 1.0],
            ).createShader(rect),
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(
                locked
                    ? const <double>[
                        0.16,
                        0.02,
                        0.01,
                        0,
                        4,
                        0.01,
                        0.18,
                        0.03,
                        0,
                        4,
                        0.01,
                        0.03,
                        0.22,
                        0,
                        6,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]
                    : const <double>[
                        0.34,
                        0.05,
                        0.02,
                        0,
                        8,
                        0.02,
                        0.38,
                        0.08,
                        0,
                        10,
                        0.02,
                        0.08,
                        0.52,
                        0,
                        14,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ],
              ),
              child: const StwayPathBackdrop(
                alignment: Alignment(0, 0.22),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, 0.35),
                radius: 0.85,
                colors: [
                  Color(0xE0000000),
                  Color(0x99000000),
                  Color(0x00000000),
                ],
                stops: [0.0, 0.42, 1.0],
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00000000),
                  Color(0x00000000),
                  Color(0x8A000000),
                  Color(0xCC000000),
                ],
                stops: [0.0, 0.42, 0.68, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Selos das trilhas do reino — anel de progresso em volta do glifo.
class _StampRow extends StatelessWidget {
  static const _max = 6;

  final List<_TrailStamp> stamps;
  final Color accent;

  const _StampRow({required this.stamps, required this.accent});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final shown = stamps.take(_max).toList();
    final extra = stamps.length - shown.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final s in shown)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _StampDisc(stamp: s),
          ),
        if (extra > 0)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              '+$extra',
              style: AppTypography.label(size: 12, color: a.textSecondary),
            ),
          ),
      ],
    );
  }
}

class _StampDisc extends StatelessWidget {
  static const _size = 34.0;

  final _TrailStamp stamp;

  const _StampDisc({required this.stamp});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final accent = stamp.visuals.accent;
    final done = stamp.ratio >= 1;
    return SizedBox(
      width: _size,
      height: _size,
      child: CustomPaint(
        painter: _RingPainter(
          ratio: stamp.open ? stamp.ratio : 0,
          color: accent,
          track: stamp.open
              ? accent.withValues(alpha: 0.22)
              : a.cardBorder.withValues(alpha: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? accent.withValues(alpha: 0.9) : a.insetFill,
            ),
            child: Center(
              child: CinematicIcon(
                glyph: stamp.open ? stamp.visuals.glyph : CinematicGlyph.lock,
                size: AppMetrics.chipIcon,
                accent: done
                    ? AppColors.night
                    : stamp.open
                    ? accent
                    : a.textFaint,
                framed: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double ratio;
  final Color color;
  final Color track;

  const _RingPainter({
    required this.ratio,
    required this.color,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 2.5;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );
    if (ratio <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * ratio.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.ratio != ratio || old.color != color || old.track != track;
}
