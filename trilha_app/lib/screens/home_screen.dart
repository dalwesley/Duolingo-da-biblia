import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../models/trail.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/trail_progress.dart';
import '../utils/trail_visuals.dart';
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
    _fadeIn = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
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
    final start = (0.08 * index).clamp(0.0, 0.7);
    final end = (start + 0.35).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _fadeIn,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(curve),
        child: child,
      ),
    );
  }

  String _streakLabel(int streak) {
    if (streak == 1) return '1 dia de sequência';
    return '$streak dias de sequência';
  }

  String _goalCopy(int missionsToday, int goal) {
    if (missionsToday >= goal) return 'Meta alcançada hoje!';
    final left = (goal - missionsToday).clamp(0, goal);
    if (left == 1) return 'Falta 1 missão para a meta';
    return 'Faltam $left missões para a meta';
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
    final current = active != null ? TrailProgress.getCurrentMission(active, progress.completedMissions) : null;
    final prog = active != null ? TrailProgress.getProgress(active, progress.completedMissions) : null;
    final goal = progress.settings.dailyGoal;
    final goalPct = goal > 0 ? progress.missionsToday / goal : 0.0;
    final playedToday = progress.missionsToday > 0;
    final a = Appearance.of(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 56, 20, 100 + bottomInset),
      children: [
        _reveal(0, const ScripturePill()),
        const SizedBox(height: 18),
        _reveal(
          2,
          HeroContinueCard(
            mission: current,
            trailTitle: active?.title ?? '',
            trailSlug: active?.slug ?? 'genesis-1-11',
            trailColor: active?.color ?? '#6C5CE7',
            onTap: current != null ? () => widget.onOpenMission(current.slug) : null,
          ),
        ),
        const SizedBox(height: 14),
        _reveal(4, const DailyQuestsCard()),
        const SizedBox(height: 14),
        _reveal(5, const WeeklyQuestsCard()),
        if (progress.mistakeQuestionIds.isNotEmpty) ...[
          const SizedBox(height: 14),
          _reveal(
            6,
            GlassCard(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PracticeScreen())),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.error.withValues(alpha: 0.18),
                    ),
                    child: const Icon(Icons.replay_circle_filled_rounded, color: AppColors.error),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Revisar erros', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: a.text)),
                        Text(
                          '${progress.mistakeQuestionIds.length} pergunta(s) para reforçar',
                          style: TextStyle(fontSize: 12, color: a.textMuted(0.55)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: a.textMuted(0.7)),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        _reveal(
          6,
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RingProgress(
                      value: goalPct,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${progress.missionsToday}',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: a.text),
                          ),
                          Text(
                            '/$goal',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: a.textMuted(0.45)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meta diária',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: a.text),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _goalCopy(progress.missionsToday, goal),
                            style: TextStyle(fontSize: 12, height: 1.3, color: a.textMuted(0.65)),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department_rounded, color: AppColors.streak, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _streakLabel(progress.streak),
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: a.text),
                                ),
                              ),
                              if (progress.streakFreezeAvailable) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.ac_unit_rounded, size: 16, color: Colors.lightBlueAccent.withValues(alpha: 0.9)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    ShareStreakButton(
                      streak: progress.streak,
                      userName: progress.userName,
                      xp: progress.xp,
                      compact: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StreakWeek(streak: progress.streak, playedToday: playedToday),
              ],
            ),
          ),
        ),
        if (active != null && prog != null) ...[
          const SizedBox(height: 14),
          _reveal(
            7,
            Builder(
              builder: (context) {
                final visuals = TrailVisuals.forSlug(active.slug);
                final pct = prog.total > 0 ? prog.done / prog.total : 0.0;
                return GlassCard(
                  onTap: () => widget.onOpenTrail(active.slug),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: visuals.iconGradient,
                          boxShadow: [
                            BoxShadow(color: visuals.glow.withValues(alpha: 0.35), blurRadius: 12),
                          ],
                        ),
                        child: Icon(visuals.icon, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              active.title,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: a.text),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${prog.done} de ${prog.total} missões',
                              style: TextStyle(fontSize: 12, color: a.textMuted(0.55)),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 7,
                                backgroundColor: a.progressTrack,
                                color: AppTheme.parseHex(active.color),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right_rounded, color: a.textMuted(0.7)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 14),
        _reveal(
          6,
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  icon: Icons.auto_awesome_rounded,
                  value: '${progress.xp}',
                  label: 'XP',
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPill(
                  icon: Icons.flag_rounded,
                  value: '${progress.completedMissions.length}',
                  label: 'Missões',
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPill(
                  icon: Icons.auto_stories_rounded,
                  value: '${trails.where((t) => t.missionSlugs.isNotEmpty).length}',
                  label: 'Trilhas',
                  color: AppColors.teal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: a.textMuted(0.5)),
          ),
        ],
      ),
    );
  }
}
