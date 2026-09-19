import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../data/season_walk_catalog.dart';
import '../models/trail.dart';
import '../services/analytics_service.dart';
import '../services/companion_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/liturgical_calendar.dart';
import '../utils/trail_progress.dart';
import '../models/daily_quest.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/comeback_sheet.dart';
import '../widgets/companion_nudge_home_card.dart';
import '../widgets/daily_chest_card.dart';
import '../widgets/daily_quests_card.dart';
import '../widgets/hero_continue_card.dart';
import '../widgets/home_player_header.dart';
import '../widgets/home_word_card.dart';
import '../widgets/immersive_background.dart';
import '../widgets/league_outcome_card.dart';
import '../widgets/league_risk_card.dart';
import '../widgets/offline_curriculum_dialog.dart';
import '../widgets/reminder_prompt_sheet.dart';
import '../widgets/streak_repair_banner.dart';
import '../widgets/medal_proximity_whisper.dart';
import '../widgets/season_challenge_banner.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/wave_hands_overlay.dart';
import 'bible_screen.dart';
import 'memory_screen.dart';
import 'practice_screen.dart';
import 'season_walk_screen.dart';

/// Home — um único trabalho: a próxima lição.
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
              child: reference == null || reference.isEmpty
                  ? BibleScreen(
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
                    )
                  : BibleReaderScreen(reference: reference),
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
    final walk = current != null
        ? () => widget.onOpenMission(current.slug)
        : widget.onOpenTrilhas;

    return Stack(
      children: [
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
                onTapMission: current != null
                    ? () => widget.onOpenMission(current.slug)
                    : widget.onOpenTrilhas,
                onLiturgyTap: () =>
                    _openBible(LiturgicalCalendar.momentFor().focusRef),
              ),
            ),
            if (nudge != null) ...[
              const SizedBox(height: AppSpace.md),
              _reveal(
                0,
                CompanionNudgeHomeCard(
                  companion: nudge,
                  onWalk: walk,
                  onOpenCompanhia: widget.onOpenLeague,
                ),
              ),
            ],
            const SizedBox(height: AppSpace.md),
            // Resultado da semana da caravana — coletar na Home (não na aba Juntos).
            Builder(
              builder: (context) {
                final league = context.watch<LeagueService>();
                if (!league.isLoaded || league.pendingOutcome == null) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    _reveal(0, const LeagueOutcomeCard()),
                    const SizedBox(height: AppSpace.section),
                  ],
                );
              },
            ),
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
                    lampsReady: ProgressService.lampsForMission(
                      isBoss: current?.isBoss ?? false,
                    ),
                  ),
                  MedalHomeWhisper(
                    catalog: trails,
                    priorityTrailSlug: active?.slug,
                    onBible: _openBible,
                    onMemory: _openMemory,
                    onMission: current != null
                        ? () => widget.onOpenMission(current.slug)
                        : widget.onOpenTrilhas,
                    onShare: _openBible,
                  ),
                  const SizedBox(height: AppSpace.md),
                  _WalkHomeCard(heroMissionSlug: current?.slug),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.section),
            if (goalMet) ...[
              _reveal(2, SeasonChallengeBanner(catalog: trails)),
            ],
            if (progress.showStreakRepairOffer) ...[
              _reveal(2, const StreakRepairBanner()),
              const SizedBox(height: AppSpace.section),
            ],
            if (goalMet)
              Builder(
                builder: (context) {
                  final league = context.watch<LeagueService>();
                  if (!league.isLoaded) return const SizedBox.shrink();
                  final entries = league.standings(
                    userName: progress.userName,
                    userWeeklySteps: progress.weeklySteps,
                  );
                  final rank = league.userRank(entries);
                  if (!league.isNearDemotion(rank)) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      _reveal(
                        3,
                        LeagueRiskCard(onOpenLeague: widget.onOpenLeague),
                      ),
                      const SizedBox(height: AppSpace.section),
                    ],
                  );
                },
              ),
            if (goalMet) ...[
              _reveal(
                3,
                DailyQuestsCard(
                  onQuestTap: (q) => _onQuestTap(q, missionSlug: current?.slug),
                ),
              ),
              const SizedBox(height: AppSpace.section),
            ],
            if (progress.dailyChestAvailable) ...[
              _reveal(3, const DailyChestCard()),
              const SizedBox(height: AppSpace.section),
            ],
            _reveal(
              4,
              HomeWordCard(mission: current, onOpen: (ref) => _openBible(ref)),
            ),
            if (progress.mistakeQuestionIds.isNotEmpty) ...[
              const SizedBox(height: AppSpace.section),
              _reveal(4, const _RevisitPracticeLink()),
            ],
          ],
        ),
        WaveHandsOverlay(active: nudge != null),
      ],
    );
  }
}

/// Só revisitar erros — memorizar vive na própria aba.
class _RevisitPracticeLink extends StatelessWidget {
  const _RevisitPracticeLink();

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);
    final n = progress.mistakeQuestionIds.length;

    return GlassCard(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const PracticeScreen())),
      padding: AppMetrics.cardPaddingCompact,
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.refresh,
            size: AppMetrics.leadingIcon,
            accent: AppColors.error,
            glowing: false,
          ),
          const SizedBox(width: AppSpace.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revisitar',
                  style: AppTypography.title(size: 14, color: a.text),
                ),
                const SizedBox(height: 2),
                Text(
                  '$n para reforçar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(size: 12, color: a.textMuted(0.55)),
                ),
              ],
            ),
          ),
          CinematicIcon(
            glyph: CinematicGlyph.chevron,
            size: 18,
            accent: a.textMuted(0.45),
            framed: false,
          ),
        ],
      ),
    );
  }
}

/// Catálogo vazio (sem cache + falha de rede) — comum no 1º boot offline.
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
        _ShimmerBox(controller: _shimmer, height: 168),
        const SizedBox(height: AppSpace.md),
        _ShimmerBox(controller: _shimmer, height: 280),
        const SizedBox(height: AppSpace.section),
        _ShimmerBox(controller: _shimmer, height: 132),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final AnimationController controller;
  final double height;

  const _ShimmerBox({required this.controller, required this.height});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final base = a.text.withValues(alpha: 0.05);
    final highlight = a.text.withValues(alpha: 0.12);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        return Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
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
        padding: const EdgeInsets.only(top: 2),
        child: TextButton(
          onPressed: () => openSeasonWalk(context),
          child: Text(
            done
                ? 'Dia $index de ${campaign.length} feito · ${campaign.title}'
                : 'Dia $index de ${campaign.length} · ${campaign.title}',
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w600,
              color: a.textMuted(0.6),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: GlassCard(
        padding: AppMetrics.cardPaddingCompact,
        child: InkWell(
          onTap: () => openSeasonWalk(context),
          child: Row(
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.calendar,
                size: 36,
                accent: AppColors.accent,
                framed: false,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.title,
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
                        color: a.textMuted(0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
