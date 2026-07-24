import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../models/trail.dart';
import '../services/analytics_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/liturgical_calendar.dart';
import '../utils/trail_progress.dart';
import '../utils/trail_visuals.dart';
import '../models/daily_quest.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/comeback_sheet.dart';
import '../widgets/daily_quests_card.dart';
import '../widgets/hero_continue_card.dart';
import '../widgets/immersive_background.dart';
import '../widgets/league_risk_card.dart';
import '../widgets/share_streak_button.dart';
import '../widgets/streak_repair_banner.dart';
import '../widgets/streak_risk_banner.dart';
import '../widgets/streak_week.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import 'bible_screen.dart';
import 'memory_screen.dart';
import 'practice_screen.dart';

/// Home — um único trabalho: a próxima lição.
class HomeScreen extends StatefulWidget {
  final TrailRepository repo;
  final void Function(String slug) onOpenTrail;
  final void Function(String missionSlug) onOpenMission;
  final VoidCallback onOpenTrilhas;
  final VoidCallback? onOpenLeague;
  final Widget? topBar;

  const HomeScreen({
    super.key,
    required this.repo,
    required this.onOpenTrail,
    required this.onOpenMission,
    required this.onOpenTrilhas,
    this.onOpenLeague,
    this.topBar,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Trail>? _trails;
  late final AnimationController _fadeIn;
  bool _comebackChecked = false;

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

  Future<void> _load() async {
    final trails = await widget.repo.getTrails();
    if (mounted) {
      setState(() => _trails = trails);
      AnalyticsService.instance.logHomeView();
    }
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

  void _openBible([String? reference]) {
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
      return _HomeSkeleton(topBar: widget.topBar);
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
    final prog = active != null
        ? TrailProgress.getProgress(active, progress.completedMissions)
        : null;
    final goal = progress.settings.dailyGoal;
    final playedToday = progress.walkedToday;
    final goalMet = progress.dailyGoalMet;
    final goalPct = goal > 0 ? progress.missionsToday / goal : 0.0;

    _maybeShowComeback(progress, missionSlug: current?.slug);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpace.screen,
        widget.topBar != null
            ? MediaQuery.viewPaddingOf(context).top + AppSpace.sm
            : AppSpace.sm,
        AppSpace.screen,
        scrollPaddingBelowNav(context),
      ),
      physics: const ClampingScrollPhysics(),
      children: [
        if (widget.topBar != null) ...[
          widget.topBar!,
          const SizedBox(height: AppSpace.afterTopBar),
        ],
        // CTA primeiro — um trabalho dominante: a próxima missão.
        _reveal(
          0,
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
            streak: progress.streak,
          ),
        ),
        const SizedBox(height: AppSpace.section),
        // Status do dia / streak (compacto, depois do CTA).
        if (progress.showStreakRiskBanner) ...[
          _reveal(
            1,
            StreakRiskBanner(
              onContinue: current != null
                  ? () => widget.onOpenMission(current.slug)
                  : widget.onOpenTrilhas,
            ),
          ),
          const SizedBox(height: AppSpace.section),
        ],
        if (progress.showStreakRepairOffer) ...[
          _reveal(1, const StreakRepairBanner()),
          const SizedBox(height: AppSpace.section),
        ],
        _reveal(
          1,
          _DayPulse(
            missionsToday: progress.missionsToday,
            goal: goal,
            goalPct: goalPct,
            streak: progress.streak,
            playedToday: playedToday,
            goalMet: goalMet,
            returningAfterGap: progress.isReturningAfterGap,
            userName: progress.userName,
            steps: progress.steps,
            atRisk: progress.isStreakAtRisk,
            questsLeft: DailyQuestDefs.all.length - progress.questsCompletedToday,
          ),
        ),
        const SizedBox(height: AppSpace.section),
        Builder(
          builder: (context) {
            final league = context.watch<LeagueService>();
            if (!league.isLoaded) return const SizedBox.shrink();
            final entries = league.standings(
              userName: progress.userName,
              userWeeklySteps: progress.weeklySteps,
            );
            final rank = league.userRank(entries);
            if (!league.isNearDemotion(rank)) return const SizedBox.shrink();
            return Column(
              children: [
                _reveal(2, LeagueRiskCard(onOpenLeague: widget.onOpenLeague)),
                const SizedBox(height: AppSpace.section),
              ],
            );
          },
        ),
        _reveal(
          2,
          DailyQuestsCard(
            onQuestTap: (q) => _onQuestTap(q, missionSlug: current?.slug),
          ),
        ),
        if (progress.mistakeQuestionIds.isNotEmpty) ...[
          const SizedBox(height: AppSpace.section),
          _reveal(3, const _RevisitPracticeLink()),
        ],
        if (active != null && prog != null && goalMet) ...[
          const SizedBox(height: AppSpace.section),
          _reveal(
            4,
            _ActiveTrailLine(
              trail: active,
              done: prog.done,
              total: prog.total,
              onTap: () => widget.onOpenTrail(active.slug),
            ),
          ),
        ],
      ],
    );
  }
}

/// Só revisitar erros — Memorizar já tem card de quest.
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.md,
      ),
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.echo,
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
                  style: AppTypography.title(size: 13, color: a.text),
                ),
                Text(
                  '$n para reforçar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(size: 11, color: a.textMuted(0.55)),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: a.textMuted(0.45),
          ),
        ],
      ),
    );
  }
}

/// Pulso do dia — sequência da semana + meta diária.
class _DayPulse extends StatelessWidget {
  final int missionsToday;
  final int goal;
  final double goalPct;
  final int streak;
  final bool playedToday;
  final bool goalMet;
  final bool returningAfterGap;
  final String userName;
  final int steps;
  final bool atRisk;
  final int questsLeft;

  const _DayPulse({
    required this.missionsToday,
    required this.goal,
    required this.goalPct,
    required this.streak,
    required this.playedToday,
    required this.goalMet,
    required this.returningAfterGap,
    required this.userName,
    required this.steps,
    required this.atRisk,
    this.questsLeft = 0,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final String detail;
    if (goalMet) {
      if (questsLeft > 0) {
        detail = questsLeft == 1
            ? 'Ainda há 1 missão diária · passos extras'
            : 'Ainda há $questsLeft missões diárias';
      } else if (streak > 0) {
        detail = streak == 1
            ? 'Meta ok · 1 dia protegido'
            : 'Meta ok · $streak dias protegidos';
      } else {
        detail = 'Meta cumprida';
      }
    } else if (atRisk) {
      detail = 'Sequência em risco · continue agora';
    } else if (playedToday) {
      detail = '$missionsToday de $goal na meta';
    } else if (returningAfterGap) {
      detail = 'Retome com uma lição';
    } else {
      detail = 'Meta de hoje · $goal lição${goal == 1 ? '' : 'ões'}';
    }

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CinematicIcon(
                glyph: atRisk ? CinematicGlyph.flame : CinematicGlyph.check,
                size: 18,
                accent: atRisk
                    ? AppColors.streak
                    : goalMet
                        ? AppColors.teal
                        : AppColors.accent,
                framed: false,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(
                    size: 13,
                    weight: FontWeight.w700,
                    color: atRisk
                        ? AppColors.streak
                        : goalMet
                            ? AppColors.teal
                            : a.text.withValues(alpha: 0.88),
                  ),
                ),
              ),
              SoftBadge(
                text: streak == 1 ? '1 dia' : '$streak dias',
                glyph: CinematicGlyph.flame,
                accent: atRisk ? AppColors.streak : AppColors.accent,
              ),
            ],
          ),
          if (!returningAfterGap && !goalMet) ...[
            const SizedBox(height: 10),
            AppProgressBar(
              value: goalPct,
              height: 5,
              color: atRisk ? AppColors.streak : AppColors.accent,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(child: StreakWeek()),
              ShareStreakButton(
                streak: streak,
                userName: userName,
                steps: steps,
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Mapa da trilha — só após a meta (não compete com Treinar).
class _ActiveTrailLine extends StatelessWidget {
  final Trail trail;
  final int done;
  final int total;
  final VoidCallback onTap;

  const _ActiveTrailLine({
    required this.trail,
    required this.done,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = TrailVisuals.forTrail(trail);
    final a = Appearance.of(context);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.md,
      ),
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyphResolver.forTrail(trail.slug),
            size: AppMetrics.leadingIcon,
            accent: visuals.accent,
            glowing: false,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mapa · ${trail.title} · $done/$total',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w700,
                color: a.text.withValues(alpha: 0.88),
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: a.textMuted(0.45),
          ),
        ],
      ),
    );
  }
}

/// Skeleton exibido enquanto o catálogo de trilhas carrega — espelha o layout
/// real da home para evitar tela preta na abertura.
class _HomeSkeleton extends StatefulWidget {
  final Widget? topBar;

  const _HomeSkeleton({this.topBar});

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
        widget.topBar != null
            ? MediaQuery.viewPaddingOf(context).top + AppSpace.sm
            : AppSpace.sm,
        AppSpace.screen,
        scrollPaddingBelowNav(context),
      ),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        if (widget.topBar != null) ...[
          widget.topBar!,
          const SizedBox(height: AppSpace.afterTopBar),
        ],
        _ShimmerBox(controller: _shimmer, height: 88),
        const SizedBox(height: AppSpace.section),
        _ShimmerBox(controller: _shimmer, height: 210),
        const SizedBox(height: AppSpace.section),
        _ShimmerBox(controller: _shimmer, height: 132),
        const SizedBox(height: AppSpace.section),
        _ShimmerBox(controller: _shimmer, height: 190),
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
