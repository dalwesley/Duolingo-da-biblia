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
import '../widgets/cloud_mascot.dart';
import '../widgets/coming_soon_trails_card.dart';
import '../widgets/immersive_background.dart';
import '../widgets/offline_curriculum_dialog.dart';
import '../widgets/realm_world_atmosphere.dart';
import '../widgets/relic_panel.dart';
import '../widgets/shell_tab_scope.dart';
import '../widgets/trail_suggestion_sheet.dart';
import '../widgets/ui_primitives.dart';
import '../services/subscription_service.dart';
import 'realm_journey_screen.dart';
import 'trail_map_screen.dart';
import 'support_screen.dart';

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

  Future<void> _openDonate() => openSupport(context);

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
                face: CloudFace.triste,
                title: TrailRealm.teologia.label,
                subtitle: ctx.l10n.realmTeologiaSoonBody,
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
    return freezeTab(() => _buildTrilhas(context));
  }

  Widget _buildTrilhas(BuildContext context) {
    final a = Appearance.of(context);
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
          AppSpace.screen + contentGutterOf(MediaQuery.sizeOf(context).width),
          topInset + AppSpace.xxl,
          AppSpace.screen + contentGutterOf(MediaQuery.sizeOf(context).width),
          scrollPaddingBelowNav(context),
        ),
        children: [
          EmptyState(
            mark: CloudMascot(
              face: _retryingCatalog ? CloudFace.carregando : CloudFace.erro,
              size: 120,
            ),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = contentGutterOf(constraints.maxWidth);
        return ListView(
          padding: EdgeInsets.fromLTRB(0, topPad, 0, bottomPad),
          physics: const BouncingScrollPhysics(),
          children: [
            if (widget.topBar != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.screen,
                ),
                child: widget.topBar!,
              ),
              const SizedBox(height: AppSpace.afterTopBar),
            ],
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpace.screen + gutter,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (active != null && current != null)
                    _reveal(
                      0,
                      TickerMode(
                        enabled: widget.portalsActive,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpace.section,
                          ),
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
                                  builder: (_) =>
                                      TrailMapScreen(slug: active.slug),
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
                      padding: const EdgeInsets.only(
                        top: 4,
                        bottom: AppSpace.lg,
                      ),
                      child: RelicChapter(
                        title: context.l10n.trailsAreasHeading,
                        accent: a.chrome,
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
                            featured:
                                activeRealm == realms[i].realm &&
                                !realms[i].locked,
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
                  if (context.watch<SubscriptionService>().supportConfigured)
                    _reveal(
                      3 + realms.length,
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpace.section),
                        child: DonateCard(onDonate: _openDonate),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
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
      label: context.l10n.trailsContinueSemantics(
        widget.mission.localizedTitle,
      ),
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
                              final t = AppMotion.move.transform(_pulse.value);
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
      height: 28,
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
      6,
      Paint()
        ..color = c.withValues(alpha: walked ? 0.28 : 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    final diamond = Path()
      ..moveTo(mid.dx, mid.dy - 4)
      ..lineTo(mid.dx + 4, mid.dy)
      ..lineTo(mid.dx, mid.dy + 4)
      ..lineTo(mid.dx - 4, mid.dy)
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

const _romanActs = ['I', 'II', 'III', 'IV', 'V', 'VI'];

/// Estação da área. O anel mostra o quanto já foi caminhado;
/// as trilhas de dentro abrem num toque.
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
    final locked = widget.info.locked;
    final featured = widget.featured && !locked;
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
    final act = widget.act - 1 < _romanActs.length
        ? _romanActs[widget.act - 1]
        : '${widget.act}';
    final cta = locked
        ? context.l10n.trailsLearnMore
        : (featured || widget.info.completedCount > 0
              ? context.l10n.commonContinue
              : context.l10n.commonStart);

    // Céu do reino é noturno; o texto acompanha, senão some no astro.
    final night = AppearanceStyle.resolve(AppearanceMode.night);
    return Semantics(
      button: true,
      label: '${widget.info.realm.label}. $progressLabel',
      excludeSemantics: true,
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
            padding: EdgeInsets.zero,
            radius: AppMetrics.heroRadius,
            tint: visuals.accent,
            glow: locked ? 0.15 : (featured ? 0.85 : 0.45),
            color: const Color(0xFF0A1018),
            child: SizedBox(
              height: featured ? 148 : 128,
              child: Appearance(
                style: night,
                mode: AppearanceMode.night,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      top: -36,
                      left: 0,
                      right: 0,
                      height: 240,
                      child: RealmWorldAtmosphere(
                        realm: widget.info.realm,
                        animate: widget.animate && !locked,
                        locked: locked,
                        featured: featured,
                        terrain: false,
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0x9906080C),
                            Color(0x5506080C),
                            Color(0x1406080C),
                          ],
                          stops: [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Row(
                        children: [
                          _RealmMark(
                            glyph: visuals.glyph,
                            accent: visuals.accent,
                            ratio: widget.info.ratio,
                            locked: locked,
                            featured: featured && widget.animate,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SectionLabel(
                                  '$act · ${visuals.eyebrow}',
                                  size: 10,
                                  color: visuals.accent,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.info.realm.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.title(
                                    size: 16,
                                    color: night.text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  visuals.tagline,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.body(
                                    size: 12,
                                    color: night.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        progressLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.body(
                                          size: 12,
                                          weight: FontWeight.w700,
                                          color: night.textSecondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SectionLabel(
                                      cta,
                                      size: 10,
                                      color: visuals.accent,
                                    ),
                                    const SizedBox(width: 2),
                                    ListChevron(
                                      color: visuals.accent,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ],
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
      ),
    );
  }
}

/// Anel do reino — o progresso da área, com o glifo no centro.
class _RealmMark extends StatelessWidget {
  final CinematicGlyph glyph;
  final Color accent;
  final double ratio;
  final bool locked;
  final bool featured;

  const _RealmMark({
    required this.glyph,
    required this.accent,
    required this.ratio,
    required this.locked,
    required this.featured,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return SizedBox(
      width: 52,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: accent.withValues(
                alpha: locked ? 0 : (featured ? 0.55 : 0.32),
              ),
              blurRadius: featured ? 18 : 12,
            ),
          ],
        ),
        child: CustomPaint(
          painter: _RingPainter(
            ratio: locked ? 0 : ratio,
            color: accent,
            track: accent.withValues(alpha: locked ? 0.2 : 0.45),
          ),
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: locked ? 0.12 : 0.22),
              ),
              child: SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: CinematicIcon(
                    glyph: locked ? CinematicGlyph.lock : glyph,
                    size: AppMetrics.iconMd,
                    accent: locked ? a.textFaint : accent,
                    framed: false,
                    glowing: featured,
                  ),
                ),
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
    const stroke = 3.0;
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
