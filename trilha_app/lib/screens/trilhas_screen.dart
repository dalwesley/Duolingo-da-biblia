import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../models/trail.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/trail_progress.dart';
import '../utils/layout_utils.dart';
import '../widgets/trail_card.dart';

class TrilhasScreen extends StatefulWidget {
  final TrailRepository repo;
  final void Function(String slug) onOpenTrail;

  const TrilhasScreen({super.key, required this.repo, required this.onOpenTrail});

  @override
  State<TrilhasScreen> createState() => _TrilhasScreenState();
}

class _TrilhasScreenState extends State<TrilhasScreen> {
  List<Trail>? _trails;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final trails = await widget.repo.getTrails();
    if (mounted) setState(() => _trails = trails);
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final topInset = MediaQuery.of(context).padding.top;

    if (_trails == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    final trails = _trails!;
    final unlocked = trails.where((t) => TrailProgress.isTrailUnlocked(t, trails, progress.completedMissions)).toList();
    final locked = trails.where((t) => !TrailProgress.isTrailUnlocked(t, trails, progress.completedMissions)).toList();
    final active = unlocked.where((t) => t.missionSlugs.isNotEmpty && !TrailProgress.isTrailCompleted(t, progress.completedMissions)).toList();
    final completed = unlocked.where((t) => TrailProgress.isTrailCompleted(t, progress.completedMissions)).toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(20, topInset + 76, 20, scrollPaddingBelowNav(context)),
      children: [
        _StatsRow(unlocked: unlocked.length, locked: locked.length, totalMissions: _totalMissions(trails)),
        const SizedBox(height: 28),
        if (active.isNotEmpty) ...[
          const _SectionHeader(title: 'Sua jornada', icon: Icons.explore_rounded),
          const SizedBox(height: 14),
          ...active.map((trail) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TrailCard(
                  trail: trail,
                  allTrails: trails,
                  featured: true,
                  onTap: () => widget.onOpenTrail(trail.slug),
                ),
              )),
        ],
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 8),
          const _SectionHeader(title: 'Concluídas', icon: Icons.verified_rounded),
          const SizedBox(height: 14),
          ...completed.map((trail) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TrailCard(
                  trail: trail,
                  allTrails: trails,
                  onTap: () => widget.onOpenTrail(trail.slug),
                ),
              )),
        ],
        if (locked.isNotEmpty) ...[
          const SizedBox(height: 8),
          const _SectionHeader(title: 'Próximas trilhas', icon: Icons.lock_clock_rounded),
          const SizedBox(height: 14),
          ...locked.map((trail) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TrailCard(trail: trail, allTrails: trails),
              )),
        ],
      ],
    );
  }

  int _totalMissions(List<Trail> trails) {
    return trails.fold(0, (sum, t) => sum + t.missionSlugs.length);
  }
}

class _StatsRow extends StatelessWidget {
  final int unlocked;
  final int locked;
  final int totalMissions;

  const _StatsRow({required this.unlocked, required this.locked, required this.totalMissions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatTile(value: '$unlocked', label: 'Liberadas', icon: Icons.auto_stories_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _StatTile(value: '$locked', label: 'Em breve', icon: Icons.hourglass_top_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _StatTile(value: '$totalMissions', label: 'Missões', icon: Icons.flag_rounded)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatTile({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        gradient: a.cardGradient,
        color: a.cardGradient == null ? a.cardFill : null,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: a.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.accent.withValues(alpha: 0.9)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: a.text)),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: a.textMuted(0.5))),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: a.text, letterSpacing: 0.2),
        ),
      ],
    );
  }
}
