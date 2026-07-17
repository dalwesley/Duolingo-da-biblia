import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../models/trail.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/daily_scripture.dart';
import '../utils/layout_utils.dart';
import '../utils/liturgical_calendar.dart';
import '../utils/trail_progress.dart';
import '../utils/trail_visuals.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/daily_quests_card.dart';
import '../widgets/hero_continue_card.dart';
import '../widgets/immersive_background.dart';
import '../widgets/liturgical_banner.dart';
import '../widgets/share_streak_button.dart';
import '../widgets/streak_week.dart';
import '../widgets/verse_of_day_card.dart';
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

  Widget _reveal(int index, Widget child) {
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
          const SizedBox(height: 12),
        ],
        _reveal(
          0,
          VerseOfDayCard(
            onOpen: () {
              final ref = DailyScripture.today().$2;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BibleReaderScreen(reference: ref),
                ),
              );
            },
          ),
        ),
        if (LiturgicalCalendar.isHighSeason) ...[
          const SizedBox(height: 12),
          _reveal(
            1,
            LiturgicalBanner(
              onOpenBible: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BibleReaderScreen(
                      reference: LiturgicalCalendar.momentFor().focusRef,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 14),
        _reveal(
          1,
          HeroContinueCard(
            mission: current,
            trailTitle: active?.title ?? '',
            trailSlug: active?.slug ?? 'genesis-1-11',
            trailColor: active?.color ?? '#2F5D4A',
            onTap: current != null
                ? () => widget.onOpenMission(current.slug)
                : null,
            onExploreTrails: widget.onOpenTrilhas,
          ),
        ),
        const SizedBox(height: 14),
        _reveal(
          2,
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
          ),
        ),
        const SizedBox(height: 14),
        _reveal(3, const DailyQuestsCard()),
        const SizedBox(height: 14),
        _reveal(4, const _MemoryPracticeLinks()),
        if (active != null && prog != null) ...[
          const SizedBox(height: 14),
          _reveal(
            5,
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

/// Atalhos de memorização e reforço — saíram do perfil para a home.
class _MemoryPracticeLinks extends StatelessWidget {
  const _MemoryPracticeLinks();

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);

    return Column(
      children: [
        GlassCard(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MemoryScreen()),
          ),
          child: Row(
            children: [
              const CinematicIcon(
                glyph: CinematicGlyph.scroll,
                size: 40,
                accent: AppColors.accent,
                glowing: false,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Memorizar',
                      style: AppTypography.title(size: 15, color: a.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      progress.memoryMastered.isEmpty
                          ? 'Guarde a Palavra no coração'
                          : '${progress.memoryMastered.length} firmes no coração',
                      style: AppTypography.body(
                        size: 12,
                        color: a.textMuted(0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: a.textMuted(0.45),
                size: 18,
              ),
            ],
          ),
        ),
        if (progress.mistakeQuestionIds.isNotEmpty) ...[
          const SizedBox(height: 12),
          GlassCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PracticeScreen()),
            ),
            child: Row(
              children: [
                const CinematicIcon(
                  glyph: CinematicGlyph.echo,
                  size: 40,
                  accent: AppColors.error,
                  glowing: false,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revisitar',
                        style: AppTypography.title(size: 15, color: a.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${progress.mistakeQuestionIds.length} passagem(ns) para reforçar',
                        style: AppTypography.body(
                          size: 12,
                          color: a.textMuted(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: a.textMuted(0.45),
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ],
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
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final title = goalMet
        ? 'Meta de hoje cumprida'
        : playedToday
        ? 'Meta de hoje'
        : returningAfterGap
        ? 'Sua caminhada continua'
        : 'Meta de hoje';
    final detail = goalMet
        ? null
        : playedToday
        ? '$missionsToday de $goal'
        : returningAfterGap
        ? 'Um passo basta para reacender a chama'
        : 'Ainda sem passo hoje · meta $goal';

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
                        color: a.text.withValues(alpha: 0.92),
                        height: 1.25,
                      ),
                    ),
                    if (detail != null) ...[
                      Text(
                        detail,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: a.textMuted(0.55),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _StreakChip(streak: streak),
            ],
          ),
          if (!returningAfterGap && !goalMet) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goalPct.clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: a.text.withValues(alpha: 0.08),
                color: AppColors.accent,
              ),
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

class _StreakChip extends StatelessWidget {
  final int streak;

  const _StreakChip({required this.streak});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 14,
            color: AppColors.accent.withValues(alpha: 0.95),
          ),
          const SizedBox(width: 4),
          Text(
            streak == 1 ? '1 dia' : '$streak dias',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: a.text.withValues(alpha: 0.9),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

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
    final pct = total > 0 ? done / total : 0.0;
    final a = Appearance.of(context);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyphResolver.forTrail(trail.slug),
            size: 40,
            accent: visuals.accent,
            glowing: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trail.title,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: a.text,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 4,
                    backgroundColor: a.progressTrack,
                    color: visuals.glow,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Abrir mapa · $done/$total missões',
                  style: TextStyle(fontSize: 11, color: a.textMuted(0.55)),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_rounded,
            color: visuals.accent.withValues(alpha: 0.8),
            size: 20,
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
          const SizedBox(height: 12),
        ],
        _ShimmerBox(controller: _shimmer, height: 88),
        const SizedBox(height: 14),
        _ShimmerBox(controller: _shimmer, height: 210),
        const SizedBox(height: 14),
        _ShimmerBox(controller: _shimmer, height: 132),
        const SizedBox(height: 14),
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
