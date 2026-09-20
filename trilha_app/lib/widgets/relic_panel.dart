import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'embossed_glyph.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Painel de relíquia — wash dourado, filete no topo, sem poço de HUD.
class RelicPanel extends StatelessWidget {
  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool elevated;

  const RelicPanel({
    super.key,
    required this.child,
    this.accent = AppColors.accent,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 18),
    this.onTap,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      elevated: elevated,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppMetrics.cardRadius),
        child: Stack(
          children: [
            Positioned.fill(child: RelicAtmosphere(accent: accent)),
            Positioned(
              left: 22,
              right: 22,
              top: 0,
              child: Container(
                height: 1.15,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      accent.withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// Wash radial — o mesmo fôlego dos selos e do cofre.
class RelicAtmosphere extends StatelessWidget {
  final Color accent;

  const RelicAtmosphere({super.key, this.accent = AppColors.accent});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.92),
            radius: 1.18,
            colors: [
              accent.withValues(alpha: 0.16),
              accent.withValues(alpha: 0.045),
              Colors.transparent,
            ],
            stops: const [0.0, 0.42, 1.0],
          ),
        ),
      ),
    );
  }
}

class RelicChapter extends StatelessWidget {
  final String title;
  final String? whisper;
  final Color accent;
  final Widget? trailing;
  final bool displayTitle;

  const RelicChapter({
    super.key,
    required this.title,
    this.whisper,
    this.accent = AppColors.accent,
    this.trailing,
    this.displayTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displayTitle ? title : title.toUpperCase(),
                style: displayTitle
                    ? AppTypography.title(size: 16, color: a.text)
                    : AppTypography.label(
                        size: 11,
                        letterSpacing: 1.4,
                        color: a.textMuted(0.78),
                      ),
              ),
            ),
            ?trailing,
          ],
        ),
        if (whisper != null && whisper!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 13),
            child: Text(
              whisper!,
              style: AppTypography.body(
                size: 12,
                color: a.textMuted(0.55),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class RelicHairline extends StatelessWidget {
  final Color accent;

  const RelicHairline({super.key, this.accent = AppColors.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            accent.withValues(alpha: 0.28),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

/// Filamento de ouro — não a barra chunky de HUD.
class RelicProgress extends StatelessWidget {
  final double value;
  final Color accent;

  const RelicProgress({
    super.key,
    required this.value,
    this.accent = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    final t = value.clamp(0.0, 1.0);
    return SizedBox(
      height: 3,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          if (t > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: t,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [
                        accent.withValues(alpha: 0.55),
                        accent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Disco gravado — metal batido, glifo em relevo. Não é ícone em círculo.
class RelicDisc extends StatelessWidget {
  final CinematicGlyph? glyph;
  final String? mark;
  final Color accent;
  final double size;
  final bool lit;

  const RelicDisc({
    super.key,
    this.glyph,
    this.mark,
    required this.accent,
    this.size = 44,
    this.lit = true,
  });

  @override
  Widget build(BuildContext context) {
    final metal = RelicMetal.fromAccent(accent, lit: lit);
    final glyphSize = size * 0.42;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RelicDiscPainter(metal: metal, lit: lit),
          ),
          if (glyph != null)
            EmbossedGlyph(
              glyph: glyph!,
              size: glyphSize,
              fill: metal.glyph,
              groove: metal.groove,
              ridge: metal.ridge,
              depth: lit ? 1.05 : 0.65,
              opacity: lit ? 1 : 0.42,
            )
          else if (mark != null)
            Text(
              mark!,
              style: AppTypography.title(
                size: size * 0.34,
                weight: FontWeight.w900,
                color: metal.glyph,
              ),
            ),
        ],
      ),
    );
  }
}

class RelicMetal {
  final Color rimLight;
  final Color rimDark;
  final Color faceLight;
  final Color faceMid;
  final Color faceDark;
  final Color glyph;
  final Color groove;
  final Color ridge;

  const RelicMetal({
    required this.rimLight,
    required this.rimDark,
    required this.faceLight,
    required this.faceMid,
    required this.faceDark,
    required this.glyph,
    required this.groove,
    required this.ridge,
  });

  factory RelicMetal.fromAccent(Color accent, {required bool lit}) {
    if (!lit) {
      return const RelicMetal(
        rimLight: Color(0xFF4A5260),
        rimDark: Color(0xFF181C22),
        faceLight: Color(0xFF323A48),
        faceMid: Color(0xFF222830),
        faceDark: Color(0xFF12161C),
        glyph: Color(0xFF8A8070),
        groove: Color(0xFF101218),
        ridge: Color(0xFF5A5248),
      );
    }
    final light = Color.lerp(accent, const Color(0xFFFFF0C8), 0.42)!;
    final mid = Color.lerp(accent, const Color(0xFF8A6020), 0.28)!;
    final dark = Color.lerp(accent, const Color(0xFF1A1208), 0.55)!;
    return RelicMetal(
      rimLight: light,
      rimDark: dark,
      faceLight: Color.lerp(accent, light, 0.35)!,
      faceMid: mid,
      faceDark: dark,
      glyph: Color.lerp(accent, const Color(0xFFFFF6D8), 0.62)!,
      groove: Color.lerp(accent, const Color(0xFF140C04), 0.82)!,
      ridge: const Color(0xFFFFF4D0),
    );
  }
}

class _RelicDiscPainter extends CustomPainter {
  final RelicMetal metal;
  final bool lit;

  const _RelicDiscPainter({required this.metal, required this.lit});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    canvas.drawCircle(
      center + Offset(0, size.width * 0.04),
      r * 0.92,
      Paint()
        ..color = Colors.black.withValues(alpha: lit ? 0.42 : 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.4),
    );

    final rim = Rect.fromCircle(center: center, radius: r * 0.96);
    canvas.drawCircle(
      center,
      r * 0.96,
      Paint()
        ..shader = SweepGradient(
          colors: [
            metal.rimDark,
            metal.faceMid,
            metal.rimLight,
            metal.faceMid,
            metal.rimDark,
          ],
          stops: const [0.0, 0.22, 0.48, 0.78, 1.0],
        ).createShader(rim),
    );

    canvas.drawCircle(
      center,
      r * 0.74,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.38, -0.48),
          radius: 1.05,
          colors: [metal.faceLight, metal.faceMid, metal.faceDark],
          stops: const [0.0, 0.52, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: r * 0.74)),
    );

    canvas.drawCircle(
      center,
      r * 0.58,
      Paint()
        ..color = metal.rimDark.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    if (lit) {
      canvas.save();
      canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: r * 0.74)),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: center + Offset(-r * 0.16, -r * 0.28),
          width: r * 1.2,
          height: r * 0.52,
        ),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              metal.rimLight.withValues(alpha: 0.38),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: center, radius: r * 0.74)),
      );
      canvas.restore();
    }

    final tick = Paint()
      ..color = metal.rimLight.withValues(alpha: lit ? 0.5 : 0.16)
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round;
    const count = 20;
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2;
      final cos = math.cos(angle);
      final sin = math.sin(angle);
      canvas.drawLine(
        center + Offset(cos * r * 0.86, sin * r * 0.86),
        center + Offset(cos * r * 0.96, sin * r * 0.96),
        tick,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RelicDiscPainter old) =>
      old.metal != metal || old.lit != lit;
}
