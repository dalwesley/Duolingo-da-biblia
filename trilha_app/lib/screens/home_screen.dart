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
import '../widgets/streak_risk_banner.dart';
import '../widgets/streak_week.dart';
import '../widgets/ui_primitives.dart';
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
          const SizedBox(height: 10),
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
          const SizedBox(height: 12),
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
          ),
        ),
        const SizedBox(height: 14),
        _reveal(
          2,
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
        _reveal(2, const DailyQuestsCard()),
        if (active != null && prog != null) ...[
          const SizedBox(height: 14),
          _reveal(
            3,
            _ActiveTrailLine(
              trail: active,
              done: prog.done,
              total: prog.total,
              onTap: () => widget.onOpenTrail(active.slug),
            ),
          ),
        ],
        const SizedBox(height: 12),
        _reveal(4, const _MemoryPracticeLinks()),
        const SizedBox(height: 12),
        _reveal(
          5,
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
            6,
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
      ],
    );
  }
}

/// Atalhos compactos — prática secundária, sem roubar o CTA.
class _MemoryPracticeLinks extends StatelessWidget {
  const _MemoryPracticeLinks();

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final hasPractice = progress.mistakeQuestionIds.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: _MiniPracticeChip(
            title: 'Memorizar',
            subtitle: progress.memoryMastered.isEmpty
                ? 'No coração'
                : '${progress.memoryMastered.length} firmes',
            glyph: CinematicGlyph.scroll,
            accent: AppColors.accent,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MemoryScreen()),
            ),
          ),
        ),
        if (hasPractice) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _MiniPracticeChip(
              title: 'Revisitar',
              subtitle: '${progress.mistakeQuestionIds.length} para reforçar',
              glyph: CinematicGlyph.echo,
              accent: AppColors.error,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PracticeScreen()),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MiniPracticeChip extends StatelessWidget {
  final String title;
  final String subtitle;
  final CinematicGlyph glyph;
  final Color accent;
  final VoidCallback onTap;

  const _MiniPracticeChip({
    required this.title,
    required this.subtitle,
    required this.glyph,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          CinematicIcon(
            glyph: glyph,
            size: 32,
            accent: accent,
            glowing: false,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title(size: 13, color: a.text),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(
                    size: 11,
                    color: a.textMuted(0.55),
                  ),
                ),
              ],
            ),
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
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final progress = context.watch<ProgressService>();
    final title = goalMet
        ? 'Meta de hoje cumprida'
        : atRisk
            ? 'Salve sua sequência'
            : playedToday
                ? 'Meta de hoje'
                : returningAfterGap
                    ? 'Sua caminhada continua'
                    : 'Meta de hoje';
    final detail = goalMet
        ? null
        : atRisk
            ? 'Faltam ${progress.streakRiskCountdown} · um passo basta'
            : playedToday
                ? '$missionsToday de $goal'
                : returningAfterGap
                    ? 'Um passo basta para reacender a chama'
                    : 'Ainda sem passo hoje · meta $goal';

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
                        color: atRisk
                            ? AppColors.streak
                            : a.text.withValues(alpha: 0.92),
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
              SoftBadge(
                text: streak == 1 ? '1 dia' : '$streak dias',
                icon: Icons.local_fire_department_rounded,
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
                    icon: Icons.timer_outlined,
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
      padding: AppMetrics.cardPadding,
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
                AppProgressBar(value: pct, color: visuals.glow),
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
