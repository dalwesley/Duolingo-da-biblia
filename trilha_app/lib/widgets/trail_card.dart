import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final unlocked =
        TrailProgress.isTrailUnlocked(trail, allTrails, progress.completedMissions);
    final completed =
        TrailProgress.isTrailCompleted(trail, progress.completedMissions);
    final prog = TrailProgress.getProgress(trail, progress.completedMissions);
    final hasContent = trail.missionSlugs.isNotEmpty;
    final canOpen = unlocked && hasContent && !trail.comingSoon;
    final visuals = TrailVisuals.forTrail(trail);
    final unlockLabel = _unlockLabel();

    final card = _TrailWorldShell(
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
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: featured && canOpen ? 26 : 22,
                              fontWeight: FontWeight.w700,
                              color: unlocked
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.7),
                              height: 1.15,
                            ),
                          ),
                        ),
                        if (trail.comingSoon && unlocked)
                          _StatusChip(label: 'EM BREVE', color: visuals.accent),
                        if (completed)
                          const _StatusChip(label: 'COMPLETA', color: AppColors.accent),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      trail.description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: unlocked ? 0.7 : 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasContent && unlocked) ...[
            const SizedBox(height: 18),
            _ProgressStrip(
              visuals: visuals,
              done: prog.done,
              total: prog.total,
              pct: prog.pct,
            ),
          ],
          if (!unlocked && unlockLabel != null) ...[
            const SizedBox(height: 16),
            _UnlockBanner(label: unlockLabel, accent: visuals.accent),
          ],
          if (unlocked && trail.comingSoon) ...[
            const SizedBox(height: 16),
            _UnlockBanner(
              label: 'Em produção — logo no mapa',
              accent: visuals.accent,
            ),
          ],
          if (canOpen) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  featured ? 'ABRIR MAPA' : 'ENTRAR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: visuals.accent,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 16, color: visuals.accent),
              ],
            ),
          ],
        ],
      ),
    );

    if (canOpen && onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
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

class _TrailWorldShell extends StatelessWidget {
  final TrailVisuals visuals;
  final bool featured;
  final bool dimmed;
  final Widget child;

  const _TrailWorldShell({
    required this.visuals,
    required this.featured,
    required this.dimmed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: visuals.cardGradient,
        border: Border.all(
          color: featured
              ? visuals.glow.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: dimmed ? 0.08 : 0.14),
          width: featured ? 1.5 : 1,
        ),
        boxShadow: [
          if (featured)
            BoxShadow(
              color: visuals.glow.withValues(alpha: 0.3),
              blurRadius: 28,
              offset: const Offset(0, 12),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // Atmosphere glow
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: featured ? 160 : 100,
                height: featured ? 160 : 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      visuals.glow.withValues(alpha: featured ? 0.28 : 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Bottom vignette
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(featured ? 22 : 18),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrailIcon extends StatelessWidget {
  final String slug;
  final TrailVisuals visuals;
  final bool locked;

  const _TrailIcon({
    required this.slug,
    required this.visuals,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Opacity(
          opacity: locked ? 0.4 : 1,
          child: CinematicIcon(
            glyph: CinematicGlyphResolver.forTrail(slug),
            size: 68,
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
              ),
              child: Icon(
                Icons.lock_rounded,
                size: 13,
                color: Colors.white.withValues(alpha: 0.7),
              ),
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
            Text(
              'PROGRESSO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
            Text(
              '$pct%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: visuals.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 6,
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              color: visuals.glow,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$done de $total cenas',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.45),
          ),
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
        color: Colors.black.withValues(alpha: 0.3),
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
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.3,
              ),
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
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
