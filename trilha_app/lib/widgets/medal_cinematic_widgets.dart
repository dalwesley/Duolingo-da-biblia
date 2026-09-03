import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/pilgrim_medals.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';

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
    final glow = accent.withValues(alpha: (0.14 + breath * 0.1) * intensity);
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
      ..color = accent.withValues(alpha: 0.04 * intensity)
      ..strokeWidth = 1.2;
    for (var i = 0; i < 6; i++) {
      final angle = (i / 6) * math.pi * 2 + breath * 0.3;
      final end = center + Offset(math.cos(angle) * size.width * 0.55, math.sin(angle) * size.height * 0.4);
      canvas.drawLine(center, end, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MedalSpotlightPainter old) =>
      old.accent != accent || old.breath != breath || old.intensity != intensity;
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
                          color: accent.withValues(alpha: 0.45 + breath * 0.2),
                          blurRadius: 32 + breath * 12,
                          spreadRadius: 2 + breath * 4,
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
                  accent.withValues(alpha: 0.35),
                  accent.withValues(alpha: 0.08),
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
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MedalRingPainter(
          progress: progress,
          accent: accent,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$value',
                style: AppTypography.title(
                  size: size * 0.28,
                  weight: FontWeight.w900,
                  color: accent,
                ),
              ),
              Text(
                '/$total',
                style: AppTypography.label(
                  size: size * 0.12,
                  letterSpacing: 0.2,
                  color: a.textMuted(0.42),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedalRingPainter extends CustomPainter {
  final double progress;
  final Color accent;

  _MedalRingPainter({required this.progress, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    const stroke = 5.0;

    final track = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

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
      old.progress != progress || old.accent != accent;
}

/// Medallion compacto para o grid do cofre — moeda metálica por material.
class MedalVaultMedallion extends StatelessWidget {
  final PilgrimMedalTile tile;
  final VoidCallback onTap;

  const MedalVaultMedallion({
    super.key,
    required this.tile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = tile.unlocked;
    final palette = _MedalTierPalette.forTier(tile.tier, unlocked: unlocked);
    final iconSize = unlocked ? 26.0 : 22.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: palette.glow.withValues(alpha: 0.2),
        highlightColor: palette.glow.withValues(alpha: 0.08),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (unlocked)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: palette.glow.withValues(alpha: 0.42),
                          blurRadius: 10,
                          spreadRadius: 0.5,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              CustomPaint(
                painter: _MedallionCoinPainter(palette: palette),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: Opacity(
                      opacity: unlocked ? 1 : 0.22,
                      child: CinematicIcon(
                        glyph: tile.glyph,
                        size: iconSize,
                        accent: unlocked
                            ? palette.glyph
                            : Colors.white.withValues(alpha: 0.35),
                        framed: false,
                        glowing: unlocked,
                      ),
                    ),
                  ),
                ),
              ),
              if (!unlocked)
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF3A4250),
                          const Color(0xFF1A1E26),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: CinematicIcon(
                        glyph: CinematicGlyph.lock,
                        size: 8,
                        accent: Colors.white.withValues(alpha: 0.72),
                        framed: false,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedalTierPalette {
  final Color rimLight;
  final Color rimMid;
  final Color rimDark;
  final Color faceLight;
  final Color faceMid;
  final Color faceDark;
  final Color glyph;
  final Color glow;

  const _MedalTierPalette({
    required this.rimLight,
    required this.rimMid,
    required this.rimDark,
    required this.faceLight,
    required this.faceMid,
    required this.faceDark,
    required this.glyph,
    required this.glow,
  });

  factory _MedalTierPalette.forTier(
    PilgrimMedalTier tier, {
    required bool unlocked,
  }) {
    if (!unlocked) return _MedalTierPalette.locked();
    return switch (tier) {
      PilgrimMedalTier.iron => const _MedalTierPalette(
          rimLight: Color(0xFFB8C0CA),
          rimMid: Color(0xFF7A8490),
          rimDark: Color(0xFF4A525C),
          faceLight: Color(0xFF9AA5B2),
          faceMid: Color(0xFF6B7580),
          faceDark: Color(0xFF3D4550),
          glyph: Color(0xFFE8EDF2),
          glow: AppColors.medalIron,
        ),
      PilgrimMedalTier.bronze => const _MedalTierPalette(
          rimLight: Color(0xFFE8A86A),
          rimMid: Color(0xFFC97B4A),
          rimDark: Color(0xFF7A4528),
          faceLight: Color(0xFFD4925E),
          faceMid: Color(0xFFA86538),
          faceDark: Color(0xFF5C3218),
          glyph: Color(0xFFFFE8D4),
          glow: AppColors.medalBronze,
        ),
      PilgrimMedalTier.silver => const _MedalTierPalette(
          rimLight: Color(0xFFF2F6FC),
          rimMid: Color(0xFFC8CEDC),
          rimDark: Color(0xFF7A8494),
          faceLight: Color(0xFFE4EAF4),
          faceMid: Color(0xFFA8B0C0),
          faceDark: Color(0xFF5A6270),
          glyph: Color(0xFFFFFFFF),
          glow: AppColors.medalSilver,
        ),
      PilgrimMedalTier.gold => const _MedalTierPalette(
          rimLight: Color(0xFFFFF0C8),
          rimMid: Color(0xFFFFD78A),
          rimDark: Color(0xFFB8862E),
          faceLight: Color(0xFFFFE8A8),
          faceMid: Color(0xFFE8B85A),
          faceDark: Color(0xFF8A6020),
          glyph: Color(0xFFFFF8E8),
          glow: AppColors.medalGold,
        ),
      PilgrimMedalTier.platinum => const _MedalTierPalette(
          rimLight: Color(0xFFFFFFFF),
          rimMid: Color(0xFFE8ECF4),
          rimDark: Color(0xFF98A4B8),
          faceLight: Color(0xFFF8FAFF),
          faceMid: Color(0xFFD0D8E8),
          faceDark: Color(0xFF7888A0),
          glyph: Color(0xFFFFFFFF),
          glow: AppColors.medalPlatinum,
        ),
      PilgrimMedalTier.diamond => const _MedalTierPalette(
          rimLight: Color(0xFFE8FFFF),
          rimMid: Color(0xFF9EE8FF),
          rimDark: Color(0xFF3A9CB8),
          faceLight: Color(0xFFB8F4FF),
          faceMid: Color(0xFF68D0F0),
          faceDark: Color(0xFF2878A0),
          glyph: Color(0xFFE8FFFF),
          glow: AppColors.medalDiamond,
        ),
      PilgrimMedalTier.mirra => const _MedalTierPalette(
          rimLight: Color(0xFFD4B088),
          rimMid: Color(0xFFB88A5A),
          rimDark: Color(0xFF6A4828),
          faceLight: Color(0xFFC8A070),
          faceMid: Color(0xFF9A7048),
          faceDark: Color(0xFF4A3018),
          glyph: Color(0xFFFFECD8),
          glow: AppColors.medalMirra,
        ),
    };
  }

  factory _MedalTierPalette.locked() => _MedalTierPalette(
        rimLight: const Color(0xFF4A5260),
        rimMid: const Color(0xFF2E3540),
        rimDark: const Color(0xFF181C22),
        faceLight: const Color(0xFF323A48),
        faceMid: const Color(0xFF222830),
        faceDark: const Color(0xFF12161C),
        glyph: Colors.white.withValues(alpha: 0.35),
        glow: const Color(0xFF3A4250),
      );
}

class _MedallionCoinPainter extends CustomPainter {
  final _MedalTierPalette palette;

  const _MedallionCoinPainter({required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;
    final rimR = outerR * 0.96;
    final faceR = outerR * 0.78;
    final innerR = outerR * 0.62;

    _drawOuterRim(canvas, center, rimR);
    _drawFace(canvas, center, faceR, innerR);
    _drawSpecular(canvas, center, faceR);
    _drawTicks(canvas, center, rimR);
  }

  void _drawOuterRim(Canvas canvas, Offset center, double radius) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          palette.rimDark,
          palette.rimLight,
          palette.rimMid,
          palette.rimDark,
          palette.rimLight,
          palette.rimMid,
          palette.rimDark,
        ],
        stops: const [0.0, 0.15, 0.35, 0.5, 0.65, 0.85, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, radius, paint);

    final innerCut = Paint()
      ..shader = RadialGradient(
        colors: [palette.faceMid, palette.rimDark],
        stops: const [0.82, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, radius * 0.88, innerCut);

    final edge = Paint()
      ..color = palette.rimDark.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, radius, edge);
  }

  void _drawFace(Canvas canvas, Offset center, double faceR, double innerR) {
    final rect = Rect.fromCircle(center: center, radius: faceR);
    final face = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 1.05,
        colors: [palette.faceLight, palette.faceMid, palette.faceDark],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, faceR, face);

    final innerRing = Paint()
      ..color = palette.rimDark.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, innerR, innerRing);

    final highlightRing = Paint()
      ..color = palette.rimLight.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    canvas.drawCircle(center, faceR * 0.92, highlightRing);
  }

  void _drawSpecular(Canvas canvas, Offset center, double faceR) {
    final specCenter = center + Offset(-faceR * 0.22, -faceR * 0.28);
    final spec = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.38),
          Colors.white.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: specCenter, radius: faceR * 0.42));
    canvas.drawCircle(specCenter, faceR * 0.38, spec);
  }

  void _drawTicks(Canvas canvas, Offset center, double rimR) {
    final tickPaint = Paint()
      ..color = palette.rimLight.withValues(alpha: 0.45)
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round;
    const count = 12;
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2 - math.pi / 2;
      final cos = math.cos(angle);
      final sin = math.sin(angle);
      final inner = rimR * 0.9;
      final outer = rimR * 0.98;
      canvas.drawLine(
        center + Offset(cos * inner, sin * inner),
        center + Offset(cos * outer, sin * outer),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MedallionCoinPainter old) =>
      old.palette.rimMid != palette.rimMid;
}

/// Emblema evolutivo — uma família ou trilha com material atual.
class MedalTrackEmblem extends StatelessWidget {
  final PilgrimTrackState trackState;
  final VoidCallback onTap;
  final bool compact;

  const MedalTrackEmblem({
    super.key,
    required this.trackState,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final started = trackState.hasStarted;
    final current = trackState.currentLevel;
    final accent = started && current != null
        ? tierColor(current.tier)
        : a.textMuted(0.28);
    final labelSize = compact ? 9.0 : 10.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Ink(
          padding: EdgeInsets.symmetric(
            vertical: compact ? 8 : 10,
            horizontal: compact ? 4 : 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            gradient: started
                ? RadialGradient(
                    center: const Alignment(0, -0.4),
                    radius: 1.2,
                    colors: [
                      accent.withValues(alpha: 0.22),
                      Colors.white.withValues(alpha: 0.03),
                    ],
                  )
                : null,
            border: Border.all(
              color: started
                  ? accent.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CinematicIcon(
                glyph: trackState.track.glyph,
                size: compact ? 22 : 26,
                accent: accent,
                framed: started,
              ),
              SizedBox(height: compact ? 4 : 6),
              Text(
                trackState.track.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label(
                  size: labelSize,
                  letterSpacing: 0.2,
                  color: started ? a.textMuted(0.78) : a.textMuted(0.42),
                ),
              ),
              if (started && current != null) ...[
                const SizedBox(height: 2),
                Text(
                  tierLabel(current.tier).toUpperCase(),
                  style: AppTypography.label(
                    size: compact ? 7 : 8,
                    letterSpacing: 0.8,
                    color: accent,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
