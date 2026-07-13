import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/trail_repository.dart';
import '../models/trail.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/trail_progress.dart';
import '../utils/layout_utils.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/trail_card.dart';

class TrilhasScreen extends StatefulWidget {
  final TrailRepository repo;
  final void Function(String slug) onOpenTrail;

  const TrilhasScreen({super.key, required this.repo, required this.onOpenTrail});

  @override
  State<TrilhasScreen> createState() => _TrilhasScreenState();
}

class _TrilhasScreenState extends State<TrilhasScreen>
    with SingleTickerProviderStateMixin {
  List<Trail>? _trails;
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _load();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final trails = await widget.repo.getTrails();
    if (mounted) setState(() => _trails = trails);
  }

  Widget _reveal(int index, Widget child) {
    final start = (0.1 * index).clamp(0.0, 0.6);
    final end = (start + 0.4).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _enter,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(curve),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final topInset = MediaQuery.of(context).padding.top;

    if (_trails == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    final trails = _trails!;
    final unlocked = trails
        .where((t) => TrailProgress.isTrailUnlocked(t, trails, progress.completedMissions))
        .toList();
    final locked = trails
        .where((t) => !TrailProgress.isTrailUnlocked(t, trails, progress.completedMissions))
        .toList();
    final active = unlocked
        .where(
          (t) =>
              t.missionSlugs.isNotEmpty &&
              !TrailProgress.isTrailCompleted(t, progress.completedMissions),
        )
        .toList();
    final completed = unlocked
        .where((t) => TrailProgress.isTrailCompleted(t, progress.completedMissions))
        .toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(20, topInset + 72, 20, scrollPaddingBelowNav(context)),
      children: [
        _reveal(0, const _WorldsHeader()),
        const SizedBox(height: 22),
        _reveal(
          1,
          _WorldStats(
            unlocked: unlocked.length,
            locked: locked.length,
            totalMissions: trails.fold(0, (s, t) => s + t.missionSlugs.length),
          ),
        ),
        if (active.isNotEmpty) ...[
          const SizedBox(height: 28),
          _reveal(2, const _ChapterLabel(title: 'Sua jornada')),
          const SizedBox(height: 14),
          ...active.asMap().entries.map((e) {
            return _reveal(
              3 + e.key,
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TrailCard(
                  trail: e.value,
                  allTrails: trails,
                  featured: true,
                  onTap: () => widget.onOpenTrail(e.value.slug),
                ),
              ),
            );
          }),
        ],
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 12),
          _reveal(6, const _ChapterLabel(title: 'Mundos concluídos')),
          const SizedBox(height: 14),
          ...completed.map(
            (trail) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TrailCard(
                trail: trail,
                allTrails: trails,
                onTap: () => widget.onOpenTrail(trail.slug),
              ),
            ),
          ),
        ],
        if (locked.isNotEmpty) ...[
          const SizedBox(height: 12),
          _reveal(7, const _ChapterLabel(title: 'Horizontes futuros')),
          const SizedBox(height: 14),
          ...locked.map(
            (trail) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TrailCard(trail: trail, allTrails: trails),
            ),
          ),
        ],
      ],
    );
  }
}

class _WorldsHeader extends StatelessWidget {
  const _WorldsHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'ESCOLHA O MUNDO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppColors.accent.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Cada trilha é um\ncapítulo da história',
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

class _WorldStats extends StatelessWidget {
  final int unlocked;
  final int locked;
  final int totalMissions;

  const _WorldStats({
    required this.unlocked,
    required this.locked,
    required this.totalMissions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatSeal(
            glyph: CinematicGlyph.book,
            value: '$unlocked',
            label: 'Liberados',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatSeal(
            glyph: CinematicGlyph.tower,
            value: '$locked',
            label: 'Em breve',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatSeal(
            glyph: CinematicGlyph.scroll,
            value: '$totalMissions',
            label: 'Cenas',
          ),
        ),
      ],
    );
  }
}

class _StatSeal extends StatelessWidget {
  final CinematicGlyph glyph;
  final String value;
  final String label;

  const _StatSeal({
    required this.glyph,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: a.cardGradient,
        border: Border.all(color: a.cardBorder),
      ),
      child: Column(
        children: [
          CinematicIcon(
            glyph: glyph,
            size: 28,
            accent: AppColors.accent,
            glowing: false,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: a.text,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: a.textMuted(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterLabel extends StatelessWidget {
  final String title;

  const _ChapterLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 1.5,
          color: AppColors.accent.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
