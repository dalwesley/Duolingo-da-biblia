import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trail.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/trail_progress.dart';
import '../utils/trail_visuals.dart';
import 'cinematic_icon.dart';

class TrailCard extends StatelessWidget {
  final Trail trail;
  final List<Trail> allTrails;
  final VoidCallback? onTap;
  final bool featured;

  const TrailCard({
    super.key,
    required this.trail,
    required this.allTrails,
    this.onTap,
    this.featured = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final unlocked = TrailProgress.isTrailUnlocked(trail, allTrails, progress.completedMissions);
    final completed = TrailProgress.isTrailCompleted(trail, progress.completedMissions);
    final prog = TrailProgress.getProgress(trail, progress.completedMissions);
    final hasContent = trail.missionSlugs.isNotEmpty;
    final canOpen = unlocked && hasContent && !trail.comingSoon;
    final visuals = TrailVisuals.forSlug(trail.slug);
    final unlockLabel = _unlockLabel();

    final card = _TrailCardShell(
      visuals: visuals,
      featured: featured && canOpen,
      dimmed: !unlocked,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TrailIcon(slug: trail.slug, visuals: visuals, locked: !unlocked),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trail.title,
                            style: TextStyle(
                              fontSize: featured && canOpen ? 20 : 17,
                              fontWeight: FontWeight.w900,
                              color: unlocked ? Colors.white : Colors.white.withValues(alpha: 0.75),
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (trail.comingSoon && unlocked) _StatusChip(label: 'EM BREVE', color: visuals.accent),
                        if (completed) const _StatusChip(label: 'COMPLETA', color: AppColors.accent),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      trail.description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: unlocked ? 0.72 : 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (canOpen) ...[
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: visuals.accent.withValues(alpha: 0.9), size: 28),
              ],
            ],
          ),
          if (hasContent && unlocked) ...[
            const SizedBox(height: 18),
            _ProgressStrip(visuals: visuals, done: prog.done, total: prog.total, pct: prog.pct),
          ],
          if (!unlocked && unlockLabel != null) ...[
            const SizedBox(height: 16),
            _UnlockBanner(label: unlockLabel, accent: visuals.accent),
          ],
        ],
      ),
    );

    if (canOpen && onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: visuals.accent.withValues(alpha: 0.12),
          highlightColor: visuals.accent.withValues(alpha: 0.06),
          child: card,
        ),
      );
    }
    return card;
  }

  String? _unlockLabel() {
    if (trail.unlockAfter == null) return null;
    final prev = allTrails.where((t) => t.slug == trail.unlockAfter).firstOrNull;
    return 'Complete ${prev?.title ?? trail.unlockAfter} para desbloquear';
  }
}

class _TrailCardShell extends StatelessWidget {
  final TrailVisuals visuals;
  final bool featured;
  final bool dimmed;
  final Widget child;

  const _TrailCardShell({
    required this.visuals,
    required this.featured,
    required this.dimmed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: visuals.cardGradient,
        border: Border.all(
          color: featured
              ? visuals.glow.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: dimmed ? 0.08 : 0.14),
          width: featured ? 1.5 : 1,
        ),
        boxShadow: [
          if (featured)
            BoxShadow(color: visuals.glow.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 10))
          else
            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          if (featured)
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [visuals.glow.withValues(alpha: 0.2), Colors.transparent]),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(featured ? 22 : 18),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _TrailIcon extends StatelessWidget {
  final String slug;
  final TrailVisuals visuals;
  final bool locked;

  const _TrailIcon({required this.slug, required this.visuals, required this.locked});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Opacity(
          opacity: locked ? 0.45 : 1,
          child: CinematicIcon(
            glyph: CinematicGlyphResolver.forTrail(slug),
            size: 64,
            accent: visuals.accent,
            glowing: !locked,
          ),
        ),
        if (locked)
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.nightMid,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6)],
              ),
              child: Icon(Icons.lock_rounded, size: 13, color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
      ],
    );
  }
}

class _ProgressStrip extends StatelessWidget {
  final TrailVisuals visuals;
  final int done;
  final int total;
  final int pct;

  const _ProgressStrip({
    required this.visuals,
    required this.done,
    required this.total,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    final value = total > 0 ? done / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Progresso', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.5))),
            Text('$pct%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: visuals.accent)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 7,
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              color: visuals.glow,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$done de $total missões',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.45)),
        ),
      ],
    );
  }
}

class _UnlockBanner extends StatelessWidget {
  final String label;
  final Color accent;

  const _UnlockBanner({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 16, color: accent.withValues(alpha: 0.85)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.7), height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.4),
      ),
    );
  }
}
