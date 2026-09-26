import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../data/season_walk_catalog.dart';
import '../models/trail.dart';
import '../widgets/act_feel.dart';
import '../services/analytics_service.dart';
import '../services/companion_service.dart';
import '../services/corner_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/liturgical_calendar.dart';
import '../utils/trail_progress.dart';
import '../utils/tomorrow_hook.dart';
import '../models/daily_quest.dart';
import '../widgets/app_sheet.dart';
import '../widgets/corner_board.dart';
import '../widgets/corner_home_card.dart';
import '../widgets/juntos_inbox.dart';
import '../widgets/home_brand_backdrop.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/comeback_sheet.dart';
import '../widgets/daily_chest_card.dart';
import '../widgets/daily_quests_card.dart';
import '../widgets/hero_card_atmosphere.dart';
import '../widgets/hero_continue_card.dart';
import '../widgets/home_player_header.dart';
import '../widgets/home_word_card.dart';
import '../widgets/immersive_background.dart';
import '../widgets/offline_curriculum_dialog.dart';
import '../widgets/reminder_prompt_sheet.dart';
import '../widgets/streak_repair_banner.dart';
import '../widgets/season_challenge_banner.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/wave_hands_overlay.dart';
import 'bible_screen.dart';
import 'memory_screen.dart';
import 'practice_screen.dart';
import 'season_walk_screen.dart';

/// Home — um único trabalho: a próxima cena.
class HomeScreen extends StatefulWidget {
  final TrailRepository repo;
  final void Function(String missionSlug) onOpenMission;
  final VoidCallback onOpenTrilhas;
  final VoidCallback? onOpenLeague;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onOpenBible;

  const HomeScreen({
    super.key,
    required this.repo,
    required this.onOpenMission,
    required this.onOpenTrilhas,
    this.onOpenLeague,
    this.onOpenProfile,
    this.onOpenBible,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Trail>? _trails;
  late final AnimationController _fadeIn;
  bool _comebackChecked = false;
  bool _reminderChecked = false;
  bool _retryingCatalog = false;
  bool _offlineDialogShown = false;

  @override
  void initState() {
    super.initState();
    _fadeIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    )..forward();
    _load();
  }

  @override
  void dispose() {
    _fadeIn.dispose();
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
      AnalyticsService.instance.logHomeView();
      if (trails.isEmpty) {
        _maybeShowOfflineDialog();
      } else {
        _offlineDialogShown = false;
        final progress = context.read<ProgressService>();
        final hook = TomorrowHook.resolve(
          trails: trails,
          completed: progress.completedMissions,
          clearedTrailModes: progress.clearedTrailModes,
        );
        if (hook != null) {
          unawaited(() async {
            final hydrated = await hook.withReaderVerse();
            await progress.setNextScene(
              title: hydrated.title,
              tease: hydrated.trailer,
            );
          }());
        }
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
      if (!ok) {
        // Permite reabrir o diálogo no próximo retry da card.
        _offlineDialogShown = false;
      }
    });
  }

  void _maybeShowComeback(ProgressService progress, {String? missionSlug}) {
    if (_comebackChecked) return;
    if (!progress.shouldShowComeback) {
      _comebackChecked = true;
      return;
    }
    _comebackChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showComebackSheet(
        context,
        onContinue: () {
          if (missionSlug != null) {
            widget.onOpenMission(missionSlug);
          } else {
            widget.onOpenTrilhas();
          }
        },
      );
    });
  }

  void _maybePromptReminders(ProgressService progress) {
    if (_reminderChecked) return;
    if (progress.notificationsPrompted) {
      _reminderChecked = true;
      return;
    }
    final first = progress.firstLessonDate;
    if (first == null || first.isEmpty) return;
    if (progress.shouldShowComeback) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (progress.notificationsPrompted) {
        _reminderChecked = true;
        return;
      }
      final route = ModalRoute.of(context);
      if (route == null || !route.isCurrent) return;
      if (_reminderChecked) return;
      _reminderChecked = true;
      showReminderPromptSheet(context);
    });
  }

  void _openBible([String? reference]) {
    if ((reference == null || reference.isEmpty) &&
        widget.onOpenBible != null) {
      widget.onOpenBible!();
      return;
    }
    if (reference != null && reference.isNotEmpty) {
      BibleReaderScreen.open(context, reference);
      return;
    }
    final mode = context.read<ProgressService>().settings.appearanceMode;
    final appearance = AppearanceStyle.resolve(mode);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Appearance(
          mode: mode,
          style: appearance,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: ImmersiveBackground(
              appearance: appearance,
              child: BibleScreen(
                topBar: TopBar(
                  inline: true,
                  immersive: true,
                  dark: appearance.onDark,
                  title: 'Bíblia',
                  subtitle: 'A Palavra, offline',
                  leadingGlyph: CinematicGlyph.book,
                  chromeAccent: AppColors.cedar,
                  onBack: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openMemory() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const MemoryScreen()));
  }

  /// Quests → ação certa (missão, Bíblia, memorizar).
  void _onQuestTap(DailyQuest quest, {String? missionSlug}) {
    switch (quest.id) {
      case 'mission':
      case 'accuracy':
      case 'perfect':
        if (missionSlug != null) {
          widget.onOpenMission(missionSlug);
        } else {
          widget.onOpenTrilhas();
        }
        return;
      case 'read':
      case 'bookmark':
        _openBible();
        return;
      case 'seasonal':
        _openBible(LiturgicalCalendar.momentFor().focusRef);
        return;
      case 'memory':
        _openMemory();
        return;
      default:
        if (missionSlug != null) {
          widget.onOpenMission(missionSlug);
        } else {
          widget.onOpenTrilhas();
        }
    }
  }

  Widget _reveal(int index, Widget child) {
    if (_fadeIn.isCompleted) return child;
    final start = (0.1 * index).clamp(0.0, 0.65);
    final end = (start + 0.38).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _fadeIn,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curve),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curve),
          child: child,
        ),
      ),
    );
  }

  void _openDesafioFace() {
    final corner = context.read<CornerService>().face;
    if (corner == null) return;
    _openCardSheet(
      CornerHomeCard(
        challenge: corner,
        onWalk: () {
          Navigator.of(context).pop();
          widget.onOpenMission(corner.missionSlug);
        },
      ),
    );
  }

  /// Cartões compactos de "Mais para hoje" — cada um abre o card completo
  /// numa folha (ou leva direto ao destino).
  List<_MoreTile> _moreToday(
    BuildContext context, {
    required ProgressService progress,
    required bool goalMet,
    required List<Trail> trails,
    required String? missionSlug,
  }) {
    final juntos = JuntosInbox.pending(context);
    final mistakes = progress.mistakeQuestionIds.length;
    return [
      if (progress.dailyChestAvailable)
        _MoreTile(
          glyph: CinematicGlyph.gem,
          title: 'Baú do dia',
          caption: 'Pronto para abrir',
          color: AppColors.accent,
          hot: true,
          onTap: () => _openCardSheet(const DailyChestCard()),
        ),
      if (juntos > 0)
        _MoreTile(
          glyph: CinematicGlyph.people,
          title: 'Juntos',
          caption: juntos == 1 ? '1 novidade' : '$juntos novidades',
          color: AppColors.streak,
          hot: true,
          onTap: () => widget.onOpenLeague?.call(),
        ),
      if (goalMet)
        _MoreTile(
          glyph: CinematicGlyph.target,
          title: 'Tarefas do dia',
          caption: 'Passos extras',
          color: AppColors.teal,
          onTap: () => _openCardSheet(
            DailyQuestsCard(
              onQuestTap: (q) {
                Navigator.of(context).pop();
                _onQuestTap(q, missionSlug: missionSlug);
              },
            ),
          ),
        ),
      if (goalMet)
        _MoreTile(
          glyph: CinematicGlyph.crown,
          title: 'Desafio da estação',
          caption: 'Ver progresso',
          color: AppColors.orchid,
          onTap: () => _openCardSheet(SeasonChallengeBanner(catalog: trails)),
        ),
      if (mistakes > 0)
        _MoreTile(
          glyph: CinematicGlyph.refresh,
          title: 'Revisitar',
          caption: '$mistakes para reforçar',
          color: AppColors.error,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PracticeScreen())),
        ),
    ];
  }

  Future<void> _openCardSheet(Widget card) {
    // O card já é o painel (GlassCard próprio): sem AppSheetPanel, para não
    // empilhar card dentro de card — só a casca e a alça do design system.
    return showAppSheet<void>(
      context,
      builder: (context) {
        final bottom = MediaQuery.paddingOf(context).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Alça: mostra que a folha fecha arrastando para baixo.
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: SheetGrabber(),
              ),
              Flexible(child: SingleChildScrollView(child: card)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();

    if (_trails == null) {
      return const _HomeSkeleton();
    }

    if (_trails!.isEmpty) {
      return _CatalogUnavailable(
        retrying: _retryingCatalog,
        onShowDialog: _maybeShowOfflineDialog,
      );
    }

    final trails = _trails!;
    final active = TrailProgress.findActiveTrail(
      trails,
      progress.completedMissions,
      clearedTrailModes: progress.clearedTrailModes,
    );
    final current = active != null
        ? TrailProgress.getCurrentMission(active, progress.completedMissions)
        : null;
    final goalMet = progress.dailyGoalMet;

    _maybeShowComeback(progress, missionSlug: current?.slug);
    _maybePromptReminders(progress);

    final nudge = context.watch<CompanionService>().incomingNudge;

    final trailMood = resolveHeroCardMood(
      atRisk: progress.isStreakAtRisk,
      yesterdayFrozen: progress.yesterdayWasFrozen,
      walkedToday: progress.walkedToday,
      returningAfterGap: progress.isReturningAfterGap,
    );

    return HomeTrailChrome(
      outline: homeTrailOutline(trailMood),
      child: Stack(
        children: [
          Positioned.fill(
            child: HomeBrandBackdrop(style: Appearance.of(context)),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpace.screen,
              MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
              AppSpace.screen,
              scrollPaddingBelowNav(context),
            ),
            physics: const ClampingScrollPhysics(),
            children: [
              // Header: saudação + estação + pulso do dia.
              _reveal(
                0,
                HomePlayerHeader(
                  onProfileTap: widget.onOpenProfile,
                  onTapMission: goalMet
                      ? null
                      : current != null
                      ? () => widget.onOpenMission(current.slug)
                      : widget.onOpenTrilhas,
                  onLiturgyTap: () =>
                      _openBible(LiturgicalCalendar.momentFor().focusRef),
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              // CTA dominante: missão pronta.
              _reveal(
                1,
                Column(
                  children: [
                    HeroContinueCard(
                      mission: current,
                      trailTitle: active?.title ?? '',
                      trailSlug: active?.slug ?? 'genesis-1-11',
                      trailColor: active?.color ?? '#1B3A5C',
                      onTap: current != null
                          ? () => widget.onOpenMission(current.slug)
                          : null,
                      onExploreTrails: widget.onOpenTrilhas,
                      goalMet: goalMet,
                      atRisk: progress.isStreakAtRisk,
                    ),
                    _WalkHomeCard(heroMissionSlug: current?.slug),
                  ],
                ),
              ),
              if (context.watch<CornerService>().face != null) ...[
                const SizedBox(height: AppSpace.section),
                _reveal(
                  2,
                  DesafioEntry(
                    onTap: () {
                      ActHaptics.tap();
                      _openDesafioFace();
                    },
                  ),
                ),
              ],
              // Uma coisa só abaixo da missão: o reparo da sequência, se houver.
              if (progress.showStreakRepairOffer) ...[
                const SizedBox(height: AppSpace.section),
                _reveal(2, const StreakRepairBanner()),
              ],
              // O resto vive em "Mais para hoje" (abre em folha) e na aba
              // Juntos — nada some, só deixa de disputar com a missão.
              Builder(
                builder: (context) {
                  final tiles = _moreToday(
                    context,
                    progress: progress,
                    goalMet: goalMet,
                    trails: trails,
                    missionSlug: current?.slug,
                  );
                  if (tiles.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpace.section),
                    child: _reveal(3, _MoreToday(tiles: tiles)),
                  );
                },
              ),
              if (current == null) ...[
                const SizedBox(height: AppSpace.section),
                _reveal(
                  4,
                  HomeWordCard(
                    mission: current,
                    onOpen: (ref) => _openBible(ref),
                  ),
                ),
              ],
            ],
          ),
          WaveHandsOverlay(active: nudge != null),
        ],
      ),
    );
  }
}

class _CatalogUnavailable extends StatelessWidget {
  final bool retrying;
  final VoidCallback onShowDialog;

  const _CatalogUnavailable({
    required this.retrying,
    required this.onShowDialog,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpace.screen,
        MediaQuery.viewPaddingOf(context).top + AppSpace.xxl,
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
                'As cenas ainda não chegaram',
                textAlign: TextAlign.center,
                style: AppTypography.title(size: 18, color: a.text),
              ),
              const SizedBox(height: AppSpace.md),
              Text(
                'O currículo baixa na primeira abertura. Se a rede oscilar, toque para tentar de novo.',
                textAlign: TextAlign.center,
                style: AppTypography.body(size: 14, color: a.textSecondary),
              ),
              const SizedBox(height: AppSpace.xxl),
              CopperCta(
                label: retrying ? 'Baixando…' : 'Tentar de novo',
                onTap: retrying ? null : onShowDialog,
                showArrow: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Skeleton exibido enquanto o catálogo de trilhas carrega — espelha o layout
/// real da home para evitar tela preta na abertura.
class _HomeSkeleton extends StatefulWidget {
  const _HomeSkeleton();

  @override
  State<_HomeSkeleton> createState() => _HomeSkeletonState();
}

class _HomeSkeletonState extends State<_HomeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpace.screen,
        MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
        AppSpace.screen,
        scrollPaddingBelowNav(context),
      ),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Mesmas alturas do conteúdo real — sem pulo quando carrega.
        _ShimmerBox(
          controller: _shimmer,
          height: HeroContinueCard.homeHeaderReserve,
        ),
        const SizedBox(height: AppSpace.lg),
        _ShimmerBox(
          controller: _shimmer,
          height: HeroContinueCard.stageHeight(context),
          radius: AppMetrics.heroRadius,
        ),
        const SizedBox(height: AppSpace.section),
        _ShimmerBox(controller: _shimmer, height: 96),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final AnimationController controller;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.controller,
    required this.height,
    this.radius = AppMetrics.cardRadius,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final base = Color.lerp(a.cardFill, a.text, 0.03)!;
    final highlight = Color.lerp(a.cardFill, a.text, 0.1)!;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        return Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: a.cardBorder),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * t, 0),
              end: Alignment(1 + 2 * t, 0),
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
            ),
          ),
        );
      },
    );
  }
}

class _WalkHomeCard extends StatelessWidget {
  final String? heroMissionSlug;

  const _WalkHomeCard({this.heroMissionSlug});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final progress = context.watch<ProgressService>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final campaign = SeasonWalkCatalog.current(today);
    if (!campaign.contains(today)) return const SizedBox.shrink();
    final index = campaign.dayIndexOn(today);
    final day = index == null ? null : campaign.dayAt(index);
    final ymd =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final done =
        day != null &&
        (progress.isWalkDateDone(campaign.id, ymd) ||
            progress.isMissionCompleted(day.missionSlug));
    final sameAsHero =
        day != null &&
        heroMissionSlug != null &&
        day.missionSlug == heroMissionSlug;

    // A missão do hero já é o dia da Caminhada — não duplica o CTA.
    if (sameAsHero) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: TextCta(
          label: done
              ? 'Dia $index de ${campaign.length} feito · ${campaign.title}'
              : 'Dia $index de ${campaign.length} · ${campaign.title}',
          onTap: () => openSeasonWalk(context),
          color: a.textSecondary,
        ),
      );
    }

    // Toque no card inteiro (antes o InkWell ficava dentro do padding).
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.sm),
      child: Semantics(
        button: true,
        label: day == null
            ? '${campaign.title}. ${campaign.subtitle}'
            : '${campaign.title}. Dia $index${done ? ' feito' : ''}: ${day.title}',
        excludeSemantics: true,
        child: GlassCard(
          padding: AppMetrics.cardPaddingCompact,
          onTap: () => openSeasonWalk(context),
          child: Row(
            children: [
              const CinematicIcon(
                glyph: CinematicGlyph.calendar,
                size: AppMetrics.leadingIcon,
                accent: AppColors.accent,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(size: 14, color: a.text),
                    ),
                    Text(
                      day == null
                          ? campaign.subtitle
                          : done
                          ? 'Dia $index feito · ${day.title}'
                          : 'Dia $index · ${day.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        size: 12,
                        color: a.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              if (done)
                const CinematicIcon(
                  glyph: CinematicGlyph.check,
                  size: 18,
                  accent: AppColors.teal,
                  framed: false,
                )
              else
                ListChevron(color: a.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreTile {
  final CinematicGlyph glyph;
  final String title;
  final String caption;
  final Color color;
  final bool hot;
  final VoidCallback onTap;

  const _MoreTile({
    required this.glyph,
    required this.title,
    required this.caption,
    required this.color,
    required this.onTap,
    this.hot = false,
  });
}

/// "Mais para hoje": um painel só, com linhas — lista de ações, não
/// mosaico de cartões soltos. O humor da trilha (borda da sequência) fica
/// no card da missão; aqui o painel é neutro para não disputar.
class _MoreToday extends StatelessWidget {
  final List<_MoreTile> tiles;

  const _MoreToday({required this.tiles});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    const radius = AppRadii.xl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
          child: Row(
            children: [
              Semantics(
                header: true,
                child: const SectionLabel('Mais para hoje'),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        a.text.withValues(alpha: 0.14),
                        a.text.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(a.cardFill, AppColors.textOnDark, 0.05)!,
                a.cardFill,
              ],
            ),
            border: Border.all(color: a.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Column(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0)
                    const ListDivider(
                      indent: AppSpace.lg + 44 + AppSpace.md,
                      endIndent: AppSpace.lg,
                    ),
                  _MoreTileRow(tile: tiles[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MoreTileRow extends StatefulWidget {
  final _MoreTile tile;

  const _MoreTileRow({required this.tile});

  @override
  State<_MoreTileRow> createState() => _MoreTileRowState();
}

class _MoreTileRowState extends State<_MoreTileRow> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final tile = widget.tile;
    final tone = AppColors.glyphInk(tile.color);
    return Semantics(
      button: true,
      label: '${tile.title}, ${tile.caption}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: () {
          ActHaptics.tap();
          tile.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.lg,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            // Linha com novidade ganha um brilho da própria cor vindo do
            // ícone; pressionar clareia a linha inteira.
            gradient: LinearGradient(
              colors: [
                tone.withValues(alpha: tile.hot ? 0.12 : 0),
                tone.withValues(alpha: 0),
              ],
              stops: const [0, 0.7],
            ),
          ),
          foregroundDecoration: BoxDecoration(
            color: _pressed ? a.text.withValues(alpha: 0.06) : null,
          ),
          child: Row(
            children: [
              _MoreTileBadge(tile: tile, tone: tone),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tile.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(size: 16, color: a.text),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tile.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        size: 12,
                        weight: tile.hot ? FontWeight.w700 : FontWeight.w600,
                        color: tile.hot ? tone : a.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              AnimatedSlide(
                duration: const Duration(milliseconds: 140),
                offset: _pressed ? const Offset(0.15, 0) : Offset.zero,
                child: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tile.hot
                        ? tone.withValues(alpha: 0.16)
                        : a.text.withValues(alpha: 0.05),
                  ),
                  child: CinematicIcon(
                    glyph: CinematicGlyph.chevron,
                    size: 14,
                    accent: tile.hot ? tone : a.textFaint,
                    framed: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ícone da linha: ladrilho com degradê da cor da ação e, se houver
/// novidade, um ponto aceso no canto — como selo de notificação.
class _MoreTileBadge extends StatelessWidget {
  final _MoreTile tile;
  final Color tone;

  const _MoreTileBadge({required this.tile, required this.tone});

  @override
  Widget build(BuildContext context) {
    const size = 44.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tone.withValues(alpha: 0.30),
                  tone.withValues(alpha: 0.10),
                ],
              ),
              border: Border.all(color: tone.withValues(alpha: 0.32)),
            ),
            child: CinematicIcon(
              glyph: tile.glyph,
              size: 22,
              accent: tile.color,
              framed: false,
            ),
          ),
          if (tile.hot)
            Positioned(
              top: -3,
              right: -3,
              child: AlertDot(color: tone, size: 12, glow: true),
            ),
        ],
      ),
    );
  }
}
