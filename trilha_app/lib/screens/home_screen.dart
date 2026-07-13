import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../models/trail.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/trail_progress.dart';
import '../utils/trail_visuals.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/hero_continue_card.dart';
import '../widgets/immersive_background.dart';
import '../widgets/streak_week.dart';
import '../widgets/daily_quests_card.dart';
import '../widgets/milestone_chests.dart';
import '../widgets/share_streak_button.dart';
import 'practice_screen.dart';

class HomeScreen extends StatefulWidget {
  final TrailRepository repo;
  final void Function(String slug) onOpenTrail;
  final void Function(String missionSlug) onOpenMission;

  const HomeScreen({
    super.key,
    required this.repo,
    required this.onOpenTrail,
    required this.onOpenMission,
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
        MediaQuery.of(context).padding.top + 64,
        20,
        110 + bottomInset,
      ),
      children: [
        // Cena de abertura — escritura do dia
        _reveal(0, const _OpeningScripture()),
        const SizedBox(height: 28),

        // Portal da jornada — CTA dominante
        _reveal(
          1,
          HeroContinueCard(
            mission: current,
            trailTitle: active?.title ?? '',
            trailSlug: active?.slug ?? 'genesis-1-11',
            trailColor: active?.color ?? '#6C5CE7',
            onTap: current != null ? () => widget.onOpenMission(current.slug) : null,
          ),
        ),
        const SizedBox(height: 20),

        // Faixa de fidelidade — compacta, editorial
        _reveal(
          2,
          _FidelityStrip(
            missionsToday: progress.missionsToday,
            goal: goal,
            goalPct: goalPct,
            streak: progress.streak,
            streakFreeze: progress.streakFreezeAvailable,
            playedToday: playedToday,
            userName: progress.userName,
            xp: progress.xp,
          ),
        ),
        const SizedBox(height: 22),

        // Missões do dia
        _reveal(3, const DailyQuestsCard()),
        const SizedBox(height: 14),
        _reveal(4, const WeeklyQuestsCard()),

        if (progress.mistakeQuestionIds.isNotEmpty) ...[
          const SizedBox(height: 14),
          _reveal(
            5,
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
          const SizedBox(height: 22),
          _reveal(
            6,
            _TrailPortal(
              trail: active,
              done: prog.done,
              total: prog.total,
              onTap: () => widget.onOpenTrail(active.slug),
            ),
          ),
        ],

        const SizedBox(height: 24),
        _reveal(
          7,
          _JourneySeals(
            xp: progress.xp,
            missions: progress.completedMissions.length,
            trails: trails.where((t) => t.missionSlugs.isNotEmpty).length,
          ),
        ),
      ],
    );
  }
}

/// Escritura como abertura de cena — tipografia editorial.
class _OpeningScripture extends StatelessWidget {
  const _OpeningScripture();

  @override
  Widget build(BuildContext context) {
    return const ScripturePill(cinematic: true);
  }
}

class _FidelityStrip extends StatelessWidget {
  final int missionsToday;
  final int goal;
  final double goalPct;
  final int streak;
  final bool streakFreeze;
  final bool playedToday;
  final String userName;
  final int xp;

  const _FidelityStrip({
    required this.missionsToday,
    required this.goal,
    required this.goalPct,
    required this.streak,
    required this.streakFreeze,
    required this.playedToday,
    required this.userName,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final left = (goal - missionsToday).clamp(0, goal);
    final copy = missionsToday >= goal
        ? 'Meta alcançada hoje'
        : left == 1
            ? 'Falta 1 missão'
            : 'Faltam $left missões';

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RingProgress(
                value: goalPct,
                size: 64,
                stroke: 6,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$missionsToday',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: a.text,
                        height: 1,
                      ),
                    ),
                    Text(
                      '/$goal',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: a.textMuted(0.45),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FIDELIDADE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                        color: AppColors.accent.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      copy,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: a.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          color: AppColors.streak,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          streak == 1 ? '1 dia' : '$streak dias',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: a.text,
                          ),
                        ),
                        if (streakFreeze) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.ac_unit_rounded,
                            size: 14,
                            color: Colors.lightBlueAccent.withValues(alpha: 0.9),
                          ),
                        ],
                        const Spacer(),
                        ShareStreakButton(
                          streak: streak,
                          userName: userName,
                          xp: xp,
                          compact: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreakWeek(streak: streak, playedToday: playedToday),
        ],
      ),
    );
  }
}

class _TrailPortal extends StatelessWidget {
  final Trail trail;
  final int done;
  final int total;
  final VoidCallback onTap;

  const _TrailPortal({
    required this.trail,
    required this.done,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = TrailVisuals.forSlug(trail.slug);
    final pct = total > 0 ? done / total : 0.0;
    final a = Appearance.of(context);

    return GlassCard(
      elevated: true,
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyphResolver.forTrail(trail.slug),
            size: 56,
            accent: visuals.accent,
            glowing: true,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MAPA DA TRILHA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                    color: visuals.accent.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trail.title,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: a.text,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 5,
                    backgroundColor: a.progressTrack,
                    color: visuals.glow,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$done de $total cenas',
                  style: TextStyle(fontSize: 11, color: a.textMuted(0.55)),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_rounded, color: visuals.accent.withValues(alpha: 0.8)),
        ],
      ),
    );
  }
}

class _JourneySeals extends StatelessWidget {
  final int xp;
  final int missions;
  final int trails;

  const _JourneySeals({
    required this.xp,
    required this.missions,
    required this.trails,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Seal(
            glyph: CinematicGlyph.spark,
            value: '$xp',
            label: 'XP',
            accent: AppColors.accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Seal(
            glyph: CinematicGlyph.scroll,
            value: '$missions',
            label: 'Cenas',
            accent: AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Seal(
            glyph: CinematicGlyph.cosmos,
            value: '$trails',
            label: 'Mundos',
            accent: AppColors.teal,
          ),
        ),
      ],
    );
  }
}

class _Seal extends StatelessWidget {
  final CinematicGlyph glyph;
  final String value;
  final String label;
  final Color accent;

  const _Seal({
    required this.glyph,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          CinematicIcon(glyph: glyph, size: 32, accent: accent, glowing: false),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: a.textMuted(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
