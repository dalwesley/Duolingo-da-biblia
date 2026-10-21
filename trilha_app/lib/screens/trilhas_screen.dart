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
import '../widgets/shell_tab_scope.dart';
import '../widgets/trail_suggestion_sheet.dart';
import '../widgets/ui_primitives.dart';
import '../services/subscription_service.dart';
import '../utils/plus_access.dart';
import 'realm_journey_screen.dart';
import 'trail_map_screen.dart';
import 'support_screen.dart';

/// Seleção de trilhas — linhas por grupo, um card por caminho.
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

  void _openJourney(TrailJourney journey) {
    final trails = _trails!;
    final reduced = MediaQuery.disableAnimationsOf(context);
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: reduced ? Duration.zero : AppMotion.standard,
        reverseTransitionDuration: reduced ? Duration.zero : AppMotion.quick,
        pageBuilder: (_, _, _) =>
            RealmJourneyScreen(journey: journey, allTrails: trails),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
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

  void _showSoonSheet(TrailJourney journey) {
    final visuals = RealmVisuals.of(journey.realm);
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
                title: journey.label,
                subtitle: journey.description.trim().isEmpty
                    ? ctx.l10n.trailsJourneySoonBody
                    : journey.description,
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

  _JourneyInfo _infoFor(
    TrailJourney journey,
    List<Trail> trails,
    ProgressService progress,
  ) {
    final journeyTrails = trails.where((t) => t.journey == journey).toList();
    final unlocked = journeyTrails
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
    final completed = journeyTrails
        .where(
          (t) => TrailProgress.isTrailCompleted(
            t,
            progress.completedMissions,
            clearedTrailModes: progress.clearedTrailModes,
          ),
        )
        .length;
    return _JourneyInfo(
      journey: journey,
      trailCount: journeyTrails.length,
      unlockedCount: unlocked,
      completedCount: completed,
      locked: journeyTrails.every(
        (t) => t.comingSoon || t.missionSlugs.isEmpty,
      ),
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
    final activeJourney = active?.journey;
    // Todo card aparece; sem trilha publicada ainda, fica "Em breve"
    // (como Teologia hoje) e vai para o fim da linha — o que já dá para
    // andar vem primeiro, na ordem do catálogo.
    final shelves = [
      for (final shelf in TrailShelf.values)
        (
          shelf: shelf,
          cards: () {
            final all = [
              for (final journey in TrailJourney.forShelf(shelf))
                _infoFor(journey, trails, progress),
            ];
            return [
              ...all.where((info) => !info.locked),
              ...all.where((info) => info.locked),
            ];
          }(),
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
            if (active != null && current != null)
              _reveal(
                0,
                TickerMode(
                  enabled: widget.portalsActive,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpace.screen + gutter,
                      0,
                      AppSpace.screen + gutter,
                      AppSpace.section,
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
                            builder: (_) => TrailMapScreen(slug: active.slug),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            for (var i = 0; i < shelves.length; i++)
              _reveal(
                1 + i,
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.section),
                  child:
                      (shelves[i].shelf == TrailShelf.biblia
                      ? _PosterCarousel.new
                      : _JourneyShelf.new)(
                        shelf: shelves[i].shelf,
                        cards: shelves[i].cards,
                        activeJourney: activeJourney,
                        inset: AppSpace.screen + gutter,
                        animate: widget.portalsActive,
                        onOpen: (info) => info.locked
                            ? _showSoonSheet(info.journey)
                            : _openJourney(info.journey),
                      ),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpace.screen + gutter,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _reveal(
                    1 + shelves.length,
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpace.sm),
                      child: ComingSoonTrailsCard(
                        onSuggest: _suggestTrail,
                        onSuggestAuthor: _suggestAuthor,
                      ),
                    ),
                  ),
                  if (context.watch<SubscriptionService>().supportConfigured)
                    _reveal(
                      2 + shelves.length,
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

class _JourneyInfo {
  final TrailJourney journey;
  final int trailCount;
  final int unlockedCount;
  final int completedCount;
  final bool locked;

  const _JourneyInfo({
    required this.journey,
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
  late final Animation<double> _glow = _pulse.drive(
    Tween<double>(begin: 0.4, end: 1).chain(CurveTween(curve: AppMotion.move)),
  );
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
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                const Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppRoles.action,
                                    ),
                                  ),
                                ),
                                FadeTransition(
                                  opacity: _glow,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppRoles.action.withValues(
                                            alpha: 0.46,
                                          ),
                                          blurRadius: 18,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const SizedBox(
                                      width: 50,
                                      height: 50,
                                    ),
                                  ),
                                ),
                                const Center(
                                  child: CinematicIcon(
                                    glyph: CinematicGlyph.forward,
                                    size: AppMetrics.iconMd,
                                    accent: AppRoles.onAction,
                                    framed: false,
                                  ),
                                ),
                              ],
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

/// Linha da Bíblia: pôsteres em carrossel. O do meio cresce e anima o céu;
/// os vizinhos recuam e apagam, e o céu corre mais devagar que o card.
/// Tocar no vizinho traz ele ao centro; tocar no do meio abre o caminho.
class _PosterCarousel extends StatefulWidget {
  final TrailShelf shelf;
  final List<_JourneyInfo> cards;
  final TrailJourney? activeJourney;
  final double inset;
  final bool animate;
  final ValueChanged<_JourneyInfo> onOpen;

  const _PosterCarousel({
    required this.shelf,
    required this.cards,
    required this.activeJourney,
    required this.inset,
    required this.animate,
    required this.onOpen,
  });

  @override
  State<_PosterCarousel> createState() => _PosterCarouselState();
}

class _PosterCarouselState extends State<_PosterCarousel> {
  late final PageController _pages = PageController(
    viewportFraction: 0.66,
    initialPage: math.max(
      0,
      widget.cards.indexWhere((c) => c.journey == widget.activeJourney),
    ),
  );

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  double get _page {
    if (_pages.hasClients && _pages.position.haveDimensions) {
      return _pages.page ?? _pages.initialPage.toDouble();
    }
    return _pages.initialPage.toDouble();
  }

  void _tap(int index) {
    if (index == _page.round()) {
      widget.onOpen(widget.cards[index]);
      return;
    }
    ActHaptics.tap();
    _pages.animateToPage(
      index,
      duration: AppMotion.gentle,
      curve: AppMotion.enter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.cards;
    return LayoutBuilder(
      builder: (context, constraints) {
        final posterWidth = constraints.maxWidth * _pages.viewportFraction;
        final height = (posterWidth * 1.22).clamp(270.0, 360.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.inset),
              child: SectionLabel(widget.shelf.label, size: 12),
            ),
            const SizedBox(height: AppSpace.md),
            SizedBox(
              height: height,
              child: PageView.builder(
                controller: _pages,
                physics: const BouncingScrollPhysics(),
                itemCount: cards.length,
                onPageChanged: (_) => ActHaptics.tap(),
                itemBuilder: (context, i) => AnimatedBuilder(
                  animation: _pages,
                  builder: (context, _) {
                    final delta = (_page - i).clamp(-1.0, 1.0);
                    final distance = delta.abs();
                    return Transform.scale(
                      scale: 1 - 0.1 * distance,
                      child: Opacity(
                        opacity: 1 - 0.45 * distance,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _JourneyPoster(
                            info: cards[i],
                            focused: distance < 0.5,
                            active: cards[i].journey == widget.activeJourney,
                            parallax: delta,
                            animate: widget.animate,
                            onTap: () => _tap(i),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (cards.length > 1) ...[
              const SizedBox(height: AppSpace.md),
              AnimatedBuilder(
                animation: _pages,
                builder: (context, _) {
                  final current = _page.round();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < cards.length; i++)
                        AnimatedContainer(
                          duration: AppMotion.quick,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == current ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: AppColors.textOnDark.withValues(
                              alpha: i == current ? 0.9 : 0.3,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Pôster de um caminho da Bíblia: a paisagem da área de ponta a ponta,
/// selo com o progresso no alto e o nome em serifa.
class _JourneyPoster extends StatefulWidget {
  final _JourneyInfo info;
  final bool focused;
  final bool active;
  final double parallax;
  final bool animate;
  final VoidCallback onTap;

  const _JourneyPoster({
    required this.info,
    required this.focused,
    required this.active,
    required this.parallax,
    required this.animate,
    required this.onTap,
  });

  @override
  State<_JourneyPoster> createState() => _JourneyPosterState();
}

class _JourneyPosterState extends State<_JourneyPoster> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final journey = info.journey;
    final visuals = RealmVisuals.of(journey.realm);
    final locked = info.locked;
    final focused = widget.focused;
    final night = AppearanceStyle.resolve(AppearanceMode.night);
    final countLabel = locked
        ? context.l10n.commonComingSoon
        : info.completedCount > 0
        ? context.l10n.trailsRealmTrailsDone(
            info.completedCount,
            info.trailCount,
          )
        : info.unlockedCount > 0
        ? context.l10n.trailsRealmOpenCount(info.unlockedCount)
        : context.l10n.trailsRealmTrailCount(info.trailCount);
    final cta = locked
        ? context.l10n.trailsLearnMore
        : (widget.active || info.completedCount > 0
              ? context.l10n.commonContinue
              : context.l10n.commonStart);

    return Semantics(
      button: true,
      label: '${journey.label}. $countLabel',
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          if (widget.focused) ActHaptics.confirm();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: AppMotion.quick,
          curve: AppMotion.enter,
          child: GlassCard(
            padding: EdgeInsets.zero,
            radius: AppMetrics.heroRadius,
            tint: widget.active && !locked ? AppRoles.action : visuals.accent,
            glow: locked ? 0.15 : (focused ? 0.9 : 0.35),
            color: const Color(0xFF0A1018),
            child: Appearance(
              style: night,
              mode: AppearanceMode.night,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Céu com folga dos lados: o parallax corre sem mostrar borda.
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: -36 - widget.parallax * 28,
                    right: -36 + widget.parallax * 28,
                    child: RealmWorldAtmosphere(
                      realm: journey.realm,
                      animate: widget.animate && focused && !locked,
                      locked: locked,
                      featured: focused,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x0006080C),
                          Color(0x2206080C),
                          Color(0xCC06080C),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.lg,
                      AppSpace.xl,
                      AppSpace.lg,
                      AppSpace.lg,
                    ),
                    child: Column(
                      children: [
                        _RealmMark(
                          size: 68,
                          glyph: journey.categories.length > 1
                              ? visuals.glyph
                              : TrailVisuals.forCategory(
                                  journey.categories.single.id,
                                ),
                          accent: visuals.accent,
                          ratio: info.ratio,
                          locked: locked,
                          featured: focused && widget.animate,
                        ),
                        const Spacer(),
                        Text(
                          journey.label,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.display(
                            size: 30,
                            color: night.text,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: AppSpace.xs + 2),
                        Text(
                          countLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            size: 12,
                            weight: FontWeight.w700,
                            color: night.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpace.md),
                        AnimatedOpacity(
                          opacity: focused ? 1 : 0,
                          duration: AppMotion.quick,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.xl,
                              vertical: AppSpace.sm + 2,
                            ),
                            decoration: BoxDecoration(
                              color: locked
                                  ? night.textSecondary.withValues(alpha: 0.2)
                                  : AppRoles.action,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              cta,
                              style: AppTypography.body(
                                size: 14,
                                weight: FontWeight.w800,
                                color: locked ? night.text : AppRoles.onAction,
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

/// Linha da aba Trilhas. Todo card tem o mesmo tamanho em todas as linhas;
/// o que não cabe rola para o lado, já aberto no card onde a pessoa está.
class _JourneyShelf extends StatefulWidget {
  final TrailShelf shelf;
  final List<_JourneyInfo> cards;
  final TrailJourney? activeJourney;
  final double inset;
  final bool animate;
  final ValueChanged<_JourneyInfo> onOpen;

  const _JourneyShelf({
    required this.shelf,
    required this.cards,
    required this.activeJourney,
    required this.inset,
    required this.animate,
    required this.onOpen,
  });

  @override
  State<_JourneyShelf> createState() => _JourneyShelfState();
}

class _JourneyShelfState extends State<_JourneyShelf> {
  static const _gap = AppSpace.sm + 2;

  ScrollController? _scroll;

  @override
  void dispose() {
    _scroll?.dispose();
    super.dispose();
  }

  double _initialOffset(double cardWidth, double viewport) {
    final index = widget.cards.indexWhere(
      (c) => c.journey == widget.activeJourney,
    );
    if (index <= 0) return 0;
    final step = cardWidth + _gap;
    final extent = widget.cards.length * step - _gap + widget.inset * 2;
    final max = math.max(0.0, extent - viewport);
    // Deixa um pedaço do card anterior à vista — mostra que a linha rola.
    return (index * step - step * 0.4).clamp(0.0, max);
  }

  Widget _card(_JourneyInfo info) => _JourneyCard(
    info: info,
    featured: info.journey == widget.activeJourney && !info.locked,
    animate: widget.animate,
    onTap: () => widget.onOpen(info),
  );

  @override
  Widget build(BuildContext context) {
    final cards = widget.cards;
    final height = 84 + 52 * MediaQuery.textScalerOf(context).scale(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.inset),
          child: SectionLabel(widget.shelf.label, size: 12),
        ),
        const SizedBox(height: AppSpace.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final viewport = constraints.maxWidth;
            final content = viewport - widget.inset * 2;
            // ~2,4 cards à vista: o pedaço do próximo mostra que rola.
            final width = ((content - _gap * 2) / 2.4).clamp(120.0, 180.0);
            _scroll ??= ScrollController(
              initialScrollOffset: _initialOffset(width, viewport),
            );
            return SizedBox(
              height: height,
              child: ListView.separated(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: widget.inset),
                itemCount: cards.length,
                separatorBuilder: (_, _) => const SizedBox(width: _gap),
                itemBuilder: (_, i) =>
                    SizedBox(width: width, child: _card(cards[i])),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Card de um caminho: anel de progresso, nome e quanto já foi andado.
class _JourneyCard extends StatefulWidget {
  final _JourneyInfo info;
  final bool featured;
  final bool animate;
  final VoidCallback onTap;

  const _JourneyCard({
    required this.info,
    required this.featured,
    required this.animate,
    required this.onTap,
  });

  @override
  State<_JourneyCard> createState() => _JourneyCardState();
}

class _JourneyCardState extends State<_JourneyCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final journey = info.journey;
    final visuals = RealmVisuals.of(journey.realm);
    final glyph = journey.categories.length > 1
        ? visuals.glyph
        : TrailVisuals.forCategory(journey.categories.single.id);
    final locked = info.locked;
    final featured = widget.featured;
    // Tema é Peregrino+ (a 1ª cena de cada trilha segue grátis).
    final plusTag =
        !locked &&
        PlusAccess.realmIsPlus(journey.realm) &&
        !context.watch<SubscriptionService>().plusFeaturesOpen;
    final progressLabel = locked
        ? context.l10n.commonComingSoon
        : info.completedCount > 0
        ? context.l10n.trailsRealmTrailsDone(
            info.completedCount,
            info.trailCount,
          )
        : info.unlockedCount > 0
        ? context.l10n.trailsRealmOpenCount(info.unlockedCount)
        : context.l10n.trailsRealmTrailCount(info.trailCount);

    return Semantics(
      button: true,
      label: plusTag
          ? '${journey.label}. ${context.l10n.paywallTitle}. $progressLabel'
          : '${journey.label}. $progressLabel',
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
          scale: _pressed ? 0.97 : 1,
          duration: AppMotion.quick,
          curve: AppMotion.enter,
          child: _JourneyCardFace(
            realm: journey.realm,
            accent: visuals.accent,
            locked: locked,
            featured: featured,
            animate: widget.animate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RealmMark(
                      size: 40,
                      glyph: glyph,
                      accent: visuals.accent,
                      ratio: info.ratio,
                      locked: locked,
                      featured: featured && widget.animate,
                    ),
                    const Spacer(),
                    if (plusTag)
                      SoftBadge(
                        text: context.l10n.paywallTitle,
                        accent: AppRoles.reward,
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  journey.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(
                    size: 14,
                    color: AppColors.textOnDark.withValues(
                      alpha: locked ? 0.7 : 1,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(
                  progressLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(
                    size: 11,
                    weight: FontWeight.w700,
                    color: featured
                        ? AppRoles.action
                        : AppColors.textOnDark.withValues(alpha: 0.78),
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

/// Fundo do card: o céu da área (o mesmo dos pôsteres antigos), escurecido
/// embaixo para o texto. Só o card onde a pessoa está anima o céu.
class _JourneyCardFace extends StatelessWidget {
  final TrailRealm realm;
  final Color accent;
  final bool locked;
  final bool featured;
  final bool animate;
  final Widget child;

  const _JourneyCardFace({
    required this.realm,
    required this.accent,
    required this.locked,
    required this.featured,
    required this.animate,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final night = AppearanceStyle.resolve(AppearanceMode.night);
    return GlassCard(
      padding: EdgeInsets.zero,
      tint: accent,
      glow: locked ? 0.15 : (featured ? 0.85 : 0.45),
      color: const Color(0xFF0A1018),
      child: Appearance(
        style: night,
        mode: AppearanceMode.night,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: RealmWorldAtmosphere(
                realm: realm,
                animate: animate && featured && !locked,
                locked: locked,
                featured: featured,
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x1406080C),
                    Color(0x3306080C),
                    Color(0xA306080C),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.all(AppSpace.md), child: child),
          ],
        ),
      ),
    );
  }
}

/// Anel do reino — o progresso da área, com o glifo no centro.
class _RealmMark extends StatelessWidget {
  final double size;
  final CinematicGlyph glyph;
  final Color accent;
  final double ratio;
  final bool locked;
  final bool featured;

  const _RealmMark({
    this.size = 52,
    required this.glyph,
    required this.accent,
    required this.ratio,
    required this.locked,
    required this.featured,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final inner = size * 0.7;
    return SizedBox(
      width: size,
      height: size,
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
                width: inner,
                height: inner,
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
