import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../models/trail.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/liturgical_calendar.dart';
import '../utils/trail_progress.dart';
import '../utils/trail_visuals.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/hero_continue_card.dart';
import '../widgets/immersive_background.dart';
import '../widgets/liturgical_banner.dart';
import '../widgets/share_streak_button.dart';
import '../widgets/streak_week.dart';
import 'bible_screen.dart';
import 'memory_screen.dart';
import 'practice_screen.dart';

class HomeScreen extends StatefulWidget {
  final TrailRepository repo;
  final void Function(String slug) onOpenTrail;
  final void Function(String missionSlug) onOpenMission;
  final VoidCallback onOpenTrilhas;

  const HomeScreen({
    super.key,
    required this.repo,
    required this.onOpenTrail,
    required this.onOpenMission,
    required this.onOpenTrilhas,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Trail>? _trails;
  late final AnimationController _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeIn = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..forward();
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
    final end = (start + 0.4).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _fadeIn,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(curve),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final bottomInset = MediaQuery.of(context).padding.bottom;

    if (_trails == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    final trails = _trails!;
    final active = TrailProgress.findActiveTrail(trails, progress.completedMissions);
    final current = active != null
        ? TrailProgress.getCurrentMission(active, progress.completedMissions)
        : null;
    final prog = active != null
        ? TrailProgress.getProgress(active, progress.completedMissions)
        : null;
    final goal = progress.settings.dailyGoal;
    final goalPct = goal > 0 ? progress.missionsToday / goal : 0.0;
    final playedToday = progress.missionsToday > 0;
    final a = Appearance.of(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        AppSpace.lg,
        20,
        110 + bottomInset,
      ),
      children: [
        _reveal(
          0,
          HeroContinueCard(
            mission: current,
            trailTitle: active?.title ?? '',
            trailSlug: active?.slug ?? 'genesis-1-11',
            trailColor: active?.color ?? '#2F5D4A',
            onTap: current != null ? () => widget.onOpenMission(current.slug) : null,
          ),
        ),
        if (LiturgicalCalendar.isHighSeason) ...[
          const SizedBox(height: 14),
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
          _MetaStrip(
            missionsToday: progress.missionsToday,
            goal: goal,
            goalPct: goalPct,
            streak: progress.streak,
            playedToday: playedToday,
            returningAfterGap: progress.isReturningAfterGap,
            userName: progress.userName,
            steps: progress.steps,
          ),
        ),
        const SizedBox(height: 14),
        _reveal(
          2,
          GlassCard(
            elevated: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MemoryScreen()),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                CinematicIcon(
                  glyph: CinematicGlyph.scroll,
                  size: 40,
                  accent: AppColors.accent,
                  glowing: false,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Memorizar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: a.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Guarde a Palavra no coração',
                        style: TextStyle(fontSize: 12, color: a.textMuted(0.6)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: a.textMuted(0.5), size: 20),
              ],
            ),
          ),
        ),
        if (progress.mistakeQuestionIds.isNotEmpty) ...[
          const SizedBox(height: 14),
          _reveal(
            2,
            GlassCard(
              elevated: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PracticeScreen()),
              ),
              child: Row(
                children: [
                  CinematicIcon(
                    glyph: CinematicGlyph.echo,
                    size: 44,
                    accent: AppColors.error,
                    glowing: true,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reforçar memória',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: a.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${progress.mistakeQuestionIds.length} passagem(ns) para revisitar',
                          style: TextStyle(fontSize: 12, color: a.textMuted(0.6)),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: a.textMuted(0.5),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
        if (active != null && prog != null) ...[
          const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        _reveal(
          4,
          GlassCard(
            elevated: true,
            onTap: widget.onOpenTrilhas,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                CinematicIcon(
                  glyph: CinematicGlyph.path,
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
                        'Todas as trilhas',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: a.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Escolha ou continue sua jornada',
                        style: TextStyle(fontSize: 12, color: a.textMuted(0.6)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: a.textMuted(0.5), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaStrip extends StatelessWidget {
  final int missionsToday;
  final int goal;
  final double goalPct;
  final int streak;
  final bool playedToday;
  final bool returningAfterGap;
  final String userName;
  final int steps;

  const _MetaStrip({
    required this.missionsToday,
    required this.goal,
    required this.goalPct,
    required this.streak,
    required this.playedToday,
    required this.returningAfterGap,
    required this.userName,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final todayCopy = playedToday
        ? (missionsToday >= goal
            ? 'Hoje você já deu $missionsToday passo${missionsToday == 1 ? '' : 's'}.'
            : 'Hoje: $missionsToday de $goal passos.')
        : returningAfterGap
            ? 'Sua caminhada continua daqui.\nVamos dar o próximo passo?'
            : 'Hoje você ainda não deu nenhum passo.';

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Continue sua caminhada',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: a.text,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _WalkStat(
                  icon: Icons.directions_walk_rounded,
                  value: '$steps',
                  label: 'passos',
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _WalkStat(
                  icon: Icons.wb_sunny_rounded,
                  value: '$streak',
                  label: streak == 1 ? 'dia caminhando' : 'dias caminhando',
                  color: AppColors.streak,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            todayCopy,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: a.text.withValues(alpha: 0.9),
            ),
          ),
          if (!returningAfterGap) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goalPct.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: a.text.withValues(alpha: 0.08),
                color: AppColors.accent,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: StreakWeek(streak: streak, playedToday: playedToday)),
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

class _WalkStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _WalkStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: a.text,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
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
      elevated: true,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyphResolver.forTrail(trail.slug),
            size: 40,
            accent: visuals.accent,
            glowing: true,
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
          Icon(Icons.arrow_forward_rounded, color: visuals.accent.withValues(alpha: 0.8), size: 20),
        ],
      ),
    );
  }
}
