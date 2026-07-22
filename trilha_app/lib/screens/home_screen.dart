import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../models/trail.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/layout_utils.dart';
import '../utils/liturgical_calendar.dart';
import '../utils/trail_progress.dart';
import '../utils/trail_visuals.dart';
import '../models/daily_quest.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/daily_quests_card.dart';
import '../widgets/hero_continue_card.dart';
import '../widgets/immersive_background.dart';
import '../widgets/liturgical_banner.dart';
import '../widgets/share_streak_button.dart';
import '../widgets/streak_risk_banner.dart';
import '../widgets/streak_week.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import 'bible_screen.dart';
import 'memory_screen.dart';
import 'practice_screen.dart';

/// Home — um único trabalho: o próximo passo na Palavra.
class HomeScreen extends StatefulWidget {
  final TrailRepository repo;
  final void Function(String slug) onOpenTrail;
  final void Function(String missionSlug) onOpenMission;
  final VoidCallback onOpenTrilhas;
  final Widget? topBar;

  const HomeScreen({
    super.key,
    required this.repo,
    required this.onOpenTrail,
    required this.onOpenMission,
    required this.onOpenTrilhas,
    this.topBar,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Trail>? _trails;
  late final AnimationController _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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
    if (mounted) setState(() => _trails = trails);
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
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curve),
        child: child,
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
        // Duolingo: status do dia primeiro (streak/meta), depois o CTA.
        if (progress.showStreakRiskBanner) ...[
          _reveal(
            0,
            StreakRiskBanner(
              onContinue: current != null
                  ? () => widget.onOpenMission(current.slug)
                  : widget.onOpenTrilhas,
            ),
          ),
          const SizedBox(height: AppSpace.section),
        ],
        _reveal(
          progress.showStreakRiskBanner ? 1 : 0,
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
        _reveal(
          2,
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
          ),
        ),
        const SizedBox(height: AppSpace.section),
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
        if (LiturgicalCalendar.isHighSeason) ...[
          const SizedBox(height: AppSpace.section),
          _reveal(
            5,
            LiturgicalBanner(
              onOpenBible: () {
                _openBible(LiturgicalCalendar.momentFor().focusRef);
              },
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
    final progress = context.watch<ProgressService>();
    final title = goalMet
        ? 'Meta de hoje cumprida'
        : atRisk
        ? 'Alcance a caravana'
        : playedToday
        ? 'Meta de hoje'
        : returningAfterGap
        ? 'Sua caminhada continua'
        : 'Meta de hoje';
    final String detail;
    if (goalMet) {
      if (questsLeft > 0) {
        detail = questsLeft == 1
            ? 'Ainda há 1 missão diária · passos extras abaixo'
            : 'Ainda há $questsLeft missões diárias · passos extras abaixo';
      } else if (streak > 0) {
        detail = streak == 1
            ? 'Amanhã a caravana segue · 1 dia protegido'
            : 'Amanhã a caravana segue · $streak dias protegidos';
      } else {
        detail = 'Amanhã um passo recomeça a caminhada';
      }
    } else if (atRisk) {
      detail =
          'Faltam ${progress.streakRiskCountdown} · um passo e você alcança';
    } else if (playedToday) {
      detail = '$missionsToday de $goal';
    } else if (returningAfterGap) {
      detail = 'Um passo basta para reacender a chama';
    } else {
      detail = 'Ainda sem passo hoje · meta $goal';
    }

    return GlassCard(
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body(
                        size: 13,
                        weight: FontWeight.w800,
                        color: goalMet
                            ? AppColors.teal
                            : atRisk
                            ? AppColors.streak
                            : a.text.withValues(alpha: 0.92),
                        height: 1.25,
                      ),
                    ),
                    Text(
                      detail,
                      style: AppTypography.body(
                        size: 12,
                        weight: FontWeight.w600,
                        color: a.textMuted(0.55),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SoftBadge(
                text: streak == 1 ? '1 dia' : '$streak dias',
                glyph: CinematicGlyph.flame,
                accent: atRisk ? AppColors.streak : AppColors.accent,
              ),
            ],
          ),
          if (streak > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const StreakFreezeChip(),
                if (atRisk && !progress.showStreakRiskBanner) ...[
                  const SizedBox(width: 8),
                  SoftBadge(
                    text: progress.streakRiskCountdown,
                    glyph: CinematicGlyph.calendar,
                    accent: AppColors.streak,
                  ),
                ],
              ],
            ),
          ],
          if (!returningAfterGap && !goalMet) ...[
            const SizedBox(height: 12),
            AppProgressBar(
              value: goalPct,
              color: atRisk ? AppColors.streak : AppColors.accent,
            ),
          ],
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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

/// Mapa da trilha — só após a meta (não compete com Caminhar).
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
