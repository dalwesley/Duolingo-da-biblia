import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../models/pilgrim_medals.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'medal_art.dart';
import 'recognition_heart_badge.dart';

/// Halo radial + raios suaves — fundo de sheets e tiles de medalha.
class MedalSpotlightPainter extends CustomPainter {
  final Color accent;
  final double breath;
  final double intensity;

  const MedalSpotlightPainter({
    required this.accent,
    this.breath = 0.5,
    this.intensity = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.22);
    final glow = accent.withValues(alpha: (0.06 + breath * 0.04) * intensity);
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (center.dx / size.width) * 2 - 1,
          (center.dy / size.height) * 2 - 1,
        ),
        radius: 0.95,
        colors: [glow, Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, paint);

    final rayPaint = Paint()
      ..color = accent.withValues(alpha: 0.02 * intensity)
      ..strokeWidth = 1.2;
    for (var i = 0; i < 6; i++) {
      final angle = (i / 6) * math.pi * 2 + breath * 0.3;
      final end =
          center +
          Offset(
            math.cos(angle) * size.width * 0.55,
            math.sin(angle) * size.height * 0.4,
          );
      canvas.drawLine(center, end, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MedalSpotlightPainter old) =>
      old.accent != accent ||
      old.breath != breath ||
      old.intensity != intensity;
}

/// Emblema central com pulso — medalha em destaque.
class MedalHeroEmblem extends StatelessWidget {
  final Color accent;
  final CinematicGlyph glyph;
  final double size;
  final double breath;
  final bool glowing;
  final bool framed;
  final Widget? overlay;

  const MedalHeroEmblem({
    super.key,
    required this.accent,
    required this.glyph,
    this.size = 64,
    this.breath = 0.5,
    this.glowing = true,
    this.framed = true,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    final halo = 1 + breath * 0.12;
    return SizedBox(
      width: size * 1.85,
      height: size * 1.85,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: halo,
            child: Container(
              width: size * 1.35,
              height: size * 1.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: glowing
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
          Container(
            width: size * 1.22,
            height: size * 1.22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: 0.18),
                  accent.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
              border: Border.all(
                color: accent.withValues(alpha: 0.65),
                width: 2,
              ),
            ),
          ),
          CinematicIcon(
            glyph: glyph,
            size: size,
            accent: accent,
            framed: framed,
            glowing: glowing,
          ),
          ?overlay,
        ],
      ),
    );
  }
}

/// Anel de progresso cinematográfico.
class MedalRingProgress extends StatelessWidget {
  final int value;
  final int total;
  final double progress;
  final Color accent;
  final double size;

  const MedalRingProgress({
    super.key,
    required this.value,
    required this.total,
    required this.progress,
    required this.accent,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return MedalHaloRing(
      progress: progress,
      accent: accent,
      size: size,
      stroke: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: AppTypography.title(
              size: size * 0.28,
              exact: true,
              weight: FontWeight.w900,
              color: accent,
            ),
          ),
          Text(
            '/$total',
            style: AppTypography.label(
              size: size * 0.12,
              exact: true,
              letterSpacing: 0.2,
              color: a.textFaint,
            ),
          ),
        ],
      ),
    );
  }
}

/// Halo fino em volta de um emblema — progresso sem números.
class MedalHaloRing extends StatelessWidget {
  final double progress;
  final Color accent;
  final double size;
  final double stroke;
  final Widget? child;

  const MedalHaloRing({
    super.key,
    required this.progress,
    required this.accent,
    this.size = 72,
    this.stroke = 3,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MedalRingPainter(
          progress: progress,
          accent: accent,
          track: Appearance.of(context).progressTrack,
          stroke: stroke,
        ),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

class _MedalRingPainter extends CustomPainter {
  final double progress;
  final Color accent;
  final Color track;
  final double stroke;

  _MedalRingPainter({
    required this.progress,
    required this.accent,
    required this.track,
    this.stroke = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - stroke;

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    final arc = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [
          accent.withValues(alpha: 0.5),
          accent,
          accent.withValues(alpha: 0.85),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _MedalRingPainter old) =>
      old.progress != progress ||
      old.accent != accent ||
      old.track != track ||
      old.stroke != stroke;
}

/// A medalha do cofre — a mesma [MedalArt] do baú, no metal do nível;
/// trancada, apagada na noite. [ribbons] nas folhas de destaque.
class MedalVaultMedallion extends StatelessWidget {
  final PilgrimMedalTile tile;
  final VoidCallback? onTap;
  final double? size;
  final bool mystery;
  final bool ribbons;

  const MedalVaultMedallion({
    super.key,
    required this.tile,
    this.onTap,
    this.size,
    this.mystery = false,
    this.ribbons = false,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = tile.unlocked;
    final diameter = size ?? 52;
    final metal = MedalArt.metalFor(tile.tier);

    final coin = MedalArt(
      metal: metal,
      size: diameter,
      locked: !unlocked,
      ribbons: ribbons,
      glyph: unlocked || mystery
          ? (mystery && !unlocked ? CinematicGlyph.spark : tile.glyph)
          : null,
      glyphOpacity: mystery && !unlocked ? 0.55 : 1,
    );

    if (onTap == null) return coin;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: metal.withValues(alpha: 0.2),
        highlightColor: metal.withValues(alpha: 0.08),
        child: coin,
      ),
    );
  }
}

/// Emblema da família — moeda no centro, halo com o avanço na escada
/// (Bronze → Prata → Ouro) e o material atual escrito embaixo.
class MedalTrackEmblem extends StatelessWidget {
  final PilgrimTrackState trackState;
  final VoidCallback onTap;
  final bool compact;
  final bool featured;

  /// Degraus já acesos, para o número de corações no próprio cofre.
  final Set<String>? heartKeys;

  const MedalTrackEmblem({
    super.key,
    required this.trackState,
    required this.onTap,
    this.compact = false,
    this.featured = false,
    this.heartKeys,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final started = trackState.hasStarted;
    final current = trackState.currentLevel;
    final accent = started && current != null
        ? tierColor(current.tier)
        : a.textMuted(0.38);
    final tile = PilgrimMedalTile.fromTrack(trackState);
    // Cabe 5 por linha num cartão de 360px (halo incluso).
    final diameter = compact ? 38.0 : 46.0;
    final halo = diameter + 12;
    final tierText = started && current != null
        ? (trackState.isComplete
              ? context.l10n.medalTrackComplete
              : tierLabel(current.tier))
        : context.l10n.medalTrackUnlit;

    return Semantics(
      button: true,
      label: '${trackState.track.title}, $tierText',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: featured || trackState.isComplete
                        ? [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.35),
                              blurRadius: 18,
                            ),
                          ]
                        : null,
                  ),
                  child: MedalHaloRing(
                    progress: trackState.progress,
                    accent: started ? accent : a.textMuted(0.25),
                    size: halo,
                    stroke: 2.5,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        MedalVaultMedallion(tile: tile, size: diameter),
                        if (heartKeys != null)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: ReceivedHeartBadge(
                              subjectKeys: heartKeys!,
                              compact: true,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  trackState.track.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(
                    size: 11,
                    weight: FontWeight.w800,
                    color: started ? a.text : a.textFaint,
                  ).copyWith(height: 1.15),
                ),
                const SizedBox(height: 1),
                Text(
                  tierText,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: AppTypography.body(
                    size: 11,
                    weight: FontWeight.w700,
                    color: started ? accent : a.textFaint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
