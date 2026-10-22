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
import '../widgets/anan_speech.dart';
import '../widgets/app_sheet.dart';
import '../widgets/author_suggestion_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/cloud_mascot.dart';
import '../widgets/coming_soon_trails_card.dart';
import '../widgets/home_brand_backdrop.dart';
import '../widgets/immersive_background.dart';
import '../widgets/top_bar.dart';
import '../widgets/offline_curriculum_dialog.dart';
import '../widgets/realm_world_atmosphere.dart';
import '../widgets/shell_tab_scope.dart';
import '../widgets/trail_suggestion_sheet.dart';
import '../widgets/ui_primitives.dart';
import '../services/subscription_service.dart';
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

  void _openHub(_TrailHub hub) {
    final trails = _trails;
    if (trails == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _TrailDoorScreen(
          hub: hub,
          trails: trails,
          onOpenJourney: _openJourney,
          onSoon: _showSoonSheet,
        ),
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
    _showSoonCopy(
      title: journey.label,
      subtitle: journey.description.trim().isEmpty
          ? context.l10n.trailsJourneySoonBody
          : journey.description,
      accent: visuals.accent,
    );
  }

  void _showSoonCopy({
    required String title,
    required String subtitle,
    required Color accent,
  }) {
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
                title: title,
                subtitle: subtitle,
                center: true,
              ),
              const SizedBox(height: AppSpace.lg),
              SoftBadge(
                text: ctx.l10n.commonComingSoon,
                accent: accent,
                textColor: accent,
              ),
            ],
          ),
        );
      },
    );
  }

  _HubTile _hubTile(
    _TrailHub hub, {
    required List<({TrailShelf shelf, List<_JourneyInfo> cards})> shelves,
    required TrailJourney? activeJourney,
  }) {
    final copy = _hubCopy(context, hub);
    final cards = shelves.firstWhere((row) => row.shelf == hub.shelf).cards;
    final trails = cards.fold(0, (sum, card) => sum + card.trailCount);
    final done = cards.fold(0, (sum, card) => sum + card.completedCount);
    final locked = cards.isEmpty || cards.every((card) => card.locked);
    return _HubTile(
      hub: hub,
      title: copy.title,
      subtitle: copy.subtitle,
      trailCount: trails,
      completedCount: done,
      locked: locked,
      plus: hub.shelf != TrailShelf.biblia,
      featured: activeJourney?.shelf == hub.shelf,
      onTap: () => _openHub(hub),
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
            _reveal(
              1,
              _TrailHubGrid(
                inset: AppSpace.screen + gutter,
                animate: widget.portalsActive,
                tiles: [
                  for (final hub in _TrailHub.values)
                    _hubTile(
                      hub,
                      shelves: shelves,
                      activeJourney: activeJourney,
                    ),
                ],
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
                    2,
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
                      3,
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

enum _TrailHub { bible, themes, life, study }

extension on _TrailHub {
  TrailShelf get shelf => switch (this) {
    _TrailHub.bible => TrailShelf.biblia,
    _TrailHub.themes => TrailShelf.tematicos,
    _TrailHub.life => TrailShelf.vidaCrista,
    _TrailHub.study => TrailShelf.teologia,
  };

  /// Céu do card. Temas usa o do Novo Testamento para não repetir o da Bíblia.
  TrailRealm get sky => switch (this) {
    _TrailHub.bible => TrailRealm.antigoTestamento,
    _TrailHub.themes => TrailRealm.novoTestamento,
    _TrailHub.life => TrailRealm.vidaCrista,
    _TrailHub.study => TrailRealm.teologia,
  };

  CinematicGlyph get glyph => switch (this) {
    _TrailHub.bible => CinematicGlyph.book,
    _TrailHub.themes => CinematicGlyph.path,
    _TrailHub.life => CinematicGlyph.seed,
    _TrailHub.study => CinematicGlyph.scroll,
  };
}

({String title, String subtitle}) _hubCopy(
  BuildContext context,
  _TrailHub hub,
) {
  final l10n = context.l10n;
  return (
    title: switch (hub) {
      _TrailHub.bible => l10n.trailsShelfBible,
      _TrailHub.themes => l10n.trailsHubThemes,
      _TrailHub.life => TrailRealm.vidaCrista.label,
      _TrailHub.study => l10n.trailsHubStudy,
    },
    subtitle: switch (hub) {
      _TrailHub.bible => l10n.trailsHubBibleBody,
      _TrailHub.themes => l10n.trailsHubThemesBody,
      _TrailHub.life => RealmVisuals.of(TrailRealm.vidaCrista).tagline,
      _TrailHub.study => l10n.trailsHubStudyBody,
    },
  );
}

/// O que há na porta, no card de apresentação acima dos caminhos.
String _hubIntro(BuildContext context, _TrailHub hub) {
  final l10n = context.l10n;
  return switch (hub) {
    _TrailHub.bible => l10n.trailsDoorIntroBible,
    _TrailHub.themes => l10n.trailsDoorIntroThemes,
    _TrailHub.life => l10n.trailsDoorIntroLife,
    _TrailHub.study => l10n.trailsDoorIntroStudy,
  };
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
    locked: journeyTrails.every((t) => t.comingSoon || t.missionSlugs.isEmpty),
  );
}

class _HubTile {
  final _TrailHub hub;
  final String title;
  final String subtitle;
  final int trailCount;
  final int completedCount;
  final bool locked;
  final bool plus;
  final bool featured;
  final VoidCallback onTap;

  const _HubTile({
    required this.hub,
    required this.title,
    required this.subtitle,
    required this.trailCount,
    required this.completedCount,
    required this.locked,
    required this.plus,
    required this.featured,
    required this.onTap,
  });
}

/// Quatro portas em faixa: Bíblia, Temas, Vida Cristã, Estudo.
class _TrailHubGrid extends StatelessWidget {
  final double inset;
  final bool animate;
  final List<_HubTile> tiles;

  const _TrailHubGrid({
    required this.inset,
    required this.animate,
    required this.tiles,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(inset, 0, inset, AppSpace.lg),
      child: Column(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpace.md),
            _PathCard(
              sky: tiles[i].hub.sky,
              glyph: tiles[i].hub.glyph,
              title: tiles[i].title,
              subtitle: tiles[i].subtitle,
              trailCount: tiles[i].trailCount,
              completedCount: tiles[i].completedCount,
              locked: tiles[i].locked,
              plus: tiles[i].plus,
              featured: tiles[i].featured,
              animate: animate,
              onTap: tiles[i].onTap,
            ),
          ],
        ],
      ),
    );
  }
}

/// Card de caminho — o mesmo na aba (Bíblia, Temas, Vida Cristã, Estudo) e
/// dentro de cada porta: glifo, nome, o que há no caminho e o progresso.
/// Altura pelo conteúdo, nunca pelo espaço da tela — por isso o texto não
/// estoura em telas pequenas nem sobra vazio nas grandes.
class _PathCard extends StatefulWidget {
  final TrailRealm sky;
  final CinematicGlyph glyph;
  final String? eyebrow;
  final String title;
  final String subtitle;
  final int trailCount;
  final int completedCount;
  final bool locked;
  final bool plus;
  final bool featured;
  final bool animate;

  /// Dentro da porta: descrição inteira por baixo do cabeçalho.
  final bool detailed;
  final VoidCallback onTap;

  const _PathCard({
    required this.sky,
    required this.glyph,
    this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.trailCount,
    required this.completedCount,
    required this.locked,
    required this.plus,
    required this.featured,
    required this.animate,
    this.detailed = false,
    required this.onTap,
  });

  double get ratio =>
      trailCount <= 0 ? 0 : (completedCount / trailCount).clamp(0.0, 1.0);

  @override
  State<_PathCard> createState() => _PathCardState();
}

class _PathCardState extends State<_PathCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final card = widget;
    final visuals = RealmVisuals.of(card.sky);
    final night = AppearanceStyle.resolve(AppearanceMode.night);
    final plusTag =
        !card.locked &&
        card.plus &&
        !context.watch<SubscriptionService>().plusFeaturesOpen;
    final progressLabel = card.locked
        ? context.l10n.commonComingSoon
        : card.completedCount > 0
        ? context.l10n.trailsRealmTrailsDone(
            card.completedCount,
            card.trailCount,
          )
        : context.l10n.trailsRealmTrailCount(card.trailCount);
    final subtitle = card.subtitle.trim();
    final icon = CinematicIcon(
      glyph: card.glyph,
      size: 48,
      accent: visuals.accent,
    );
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (card.eyebrow != null) ...[
          SectionLabel(
            card.eyebrow!,
            size: 10,
            maxLines: 1,
            color: night.textSecondary,
          ),
          const SizedBox(height: 2),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                card.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.display(
                  size: 24,
                  color: night.text,
                  height: 1.05,
                ),
              ),
            ),
            if (plusTag) ...[
              const SizedBox(width: AppSpace.xs),
              const CinematicIcon(
                glyph: CinematicGlyph.plus,
                size: 24,
                framed: false,
              ),
            ],
          ],
        ),
      ],
    );
    Widget description(int maxLines) => Text(
      subtitle,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.body(size: 14, color: night.textSecondary),
    );
    final footer = Row(
      children: [
        Flexible(
          // Com barra, o rótulo fica inteiro; a barra cede.
          flex: card.locked ? 1 : 0,
          child: Text(
            progressLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(
              size: 13,
              weight: FontWeight.w700,
              color: card.locked ? night.textSecondary : night.text,
            ),
          ),
        ),
        if (!card.locked) ...[
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: AppProgressBar(
              value: card.ratio,
              height: 6,
              color: visuals.accent,
              trackColor: visuals.accent.withValues(alpha: 0.28),
            ),
          ),
        ],
      ],
    );

    return Semantics(
      button: true,
      label: [
        card.title,
        if (plusTag)
          context.l10n.paywallTitle
        else if (subtitle.isNotEmpty)
          subtitle,
        progressLabel,
      ].join('. '),
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          ActHaptics.confirm();
          card.onTap();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: AppMotion.quick,
          curve: AppMotion.enter,
          child: _JourneyCardFace(
            realm: card.sky,
            accent: visuals.accent,
            locked: card.locked,
            featured: card.featured,
            animate: card.animate,
            padding: const EdgeInsets.all(AppSpace.lg),
            child: card.detailed
                // Dentro da porta: a descrição corre por baixo, na largura toda.
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          icon,
                          const SizedBox(width: AppSpace.lg),
                          Expanded(child: header),
                        ],
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: AppSpace.md),
                        description(5),
                      ],
                      const SizedBox(height: AppSpace.md),
                      footer,
                    ],
                  )
                : Row(
                    children: [
                      icon,
                      const SizedBox(width: AppSpace.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            header,
                            if (subtitle.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              description(2),
                            ],
                            const SizedBox(height: AppSpace.md),
                            footer,
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

/// Porta de um card da aba: os caminhos da linha, um por card, em lista.
class _TrailDoorScreen extends StatelessWidget {
  final _TrailHub hub;
  final List<Trail> trails;
  final ValueChanged<TrailJourney> onOpenJourney;
  final ValueChanged<TrailJourney> onSoon;

  const _TrailDoorScreen({
    required this.hub,
    required this.trails,
    required this.onOpenJourney,
    required this.onSoon,
  });

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final mode = progress.settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);
    final copy = _hubCopy(context, hub);
    final active = TrailProgress.findActiveTrail(
      trails,
      progress.completedMissions,
      clearedTrailModes: progress.clearedTrailModes,
    );
    final activeJourney = active?.journey;
    final shelfCards = () {
      final all = [
        for (final journey in TrailJourney.forShelf(hub.shelf))
          _infoFor(journey, trails, progress),
      ];
      return [
        ...all.where((info) => !info.locked),
        ...all.where((info) => info.locked),
      ];
    }();

    return ImmersiveScaffold(
      mode: mode,
      style: appearance,
      frameBody: false,
      background: Stack(
        fit: StackFit.expand,
        children: [
          AmbientAtmosphere(phase: appearance.phase),
          HomeBrandBackdrop(style: appearance),
        ],
      ),
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
              title: copy.title,
              subtitle: copy.subtitle,
              onBack: () => Navigator.pop(context),
              leadingGlyph: hub.glyph,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final inset =
                    AppSpace.screen + contentGutterOf(constraints.maxWidth);
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    inset,
                    AppSpace.lg,
                    inset,
                    32 + MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  physics: const BouncingScrollPhysics(),
                  // O primeiro item é a apresentação da porta; depois, os cards.
                  itemCount: shelfCards.length + 1,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpace.md),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return _DoorIntroCard(
                        body: _hubIntro(context, hub),
                        locked:
                            shelfCards.isEmpty ||
                            shelfCards.every((card) => card.locked),
                        trailCount: shelfCards.fold(
                          0,
                          (sum, card) => sum + card.trailCount,
                        ),
                        completedCount: shelfCards.fold(
                          0,
                          (sum, card) => sum + card.completedCount,
                        ),
                      );
                    }
                    final info = shelfCards[i - 1];
                    final journey = info.journey;
                    final visuals = RealmVisuals.of(journey.realm);
                    // AT e NT juntam categorias: falam como a área.
                    final whole = journey.categories.length > 1;
                    return _PathCard(
                      sky: journey.realm,
                      glyph: whole
                          ? visuals.glyph
                          : TrailVisuals.forCategory(
                              journey.categories.single.id,
                            ),
                      eyebrow: whole ? visuals.eyebrow : null,
                      title: journey.label,
                      subtitle: journey.description,
                      trailCount: info.trailCount,
                      completedCount: info.completedCount,
                      locked: info.locked,
                      plus: journey.requiresPlus,
                      featured: journey == activeJourney,
                      animate: true,
                      detailed: true,
                      onTap: () => info.locked
                          ? onSoon(journey)
                          : onOpenJourney(journey),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Apresentação da porta: o tema, como as trilhas funcionam e quantas são.
/// Não abre nada — é só leitura, por isso fica sem a atmosfera dos cards.
/// É a fala do Anan ([AnanSpeech]) — carregando quando a porta toda ainda é
/// "Em breve".
class _DoorIntroCard extends StatelessWidget {
  final String body;
  final bool locked;
  final int trailCount;
  final int completedCount;

  const _DoorIntroCard({
    required this.body,
    required this.locked,
    required this.trailCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final countLabel = locked
        ? context.l10n.commonComingSoon
        : completedCount > 0
        ? context.l10n.trailsRealmTrailsDone(completedCount, trailCount)
        : context.l10n.trailsRealmTrailCount(trailCount);
    return AnanSpeech(
      face: locked ? CloudFace.carregando : CloudFace.feliz,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SectionLabel(
            context.l10n.trailsDoorIntroLabel,
            size: 10,
            maxLines: 1,
            color: AnanSpeechBubble.muted,
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            body,
            style: AppTypography.body(size: 15, color: AnanSpeechBubble.ink),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            context.l10n.trailsDoorIntroHowItWorks,
            style: AppTypography.body(size: 13, color: AnanSpeechBubble.muted),
          ),
          if (trailCount > 0) ...[
            const SizedBox(height: AppSpace.md),
            Text(
              countLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w700,
                color: locked ? AnanSpeechBubble.muted : AnanSpeechBubble.ink,
              ),
            ),
          ],
        ],
      ),
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

/// Fundo do card: o céu da área (o mesmo dos pôsteres antigos), escurecido
/// embaixo para o texto. Só o card onde a pessoa está anima o céu.
class _JourneyCardFace extends StatelessWidget {
  final TrailRealm realm;
  final Color accent;
  final bool locked;
  final bool featured;
  final bool animate;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _JourneyCardFace({
    required this.realm,
    required this.accent,
    required this.locked,
    required this.featured,
    required this.animate,
    this.padding = const EdgeInsets.all(AppSpace.md),
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
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(
              child: RealmWorldAtmosphere(
                realm: realm,
                animate: animate && featured && !locked,
                locked: locked,
                featured: featured,
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x5906080C),
                      Color(0x8C06080C),
                      Color(0xE606080C),
                    ],
                    stops: [0.0, 0.42, 1.0],
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}
