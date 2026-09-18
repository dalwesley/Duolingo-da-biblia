import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';

class StreakWeek extends StatelessWidget {
  /// Se omitido, lê o [ProgressService] local (home).
  final bool Function(DateTime day)? playedOnDate;
  final bool Function(DateTime day)? frozenOnDate;

  const StreakWeek({
    super.key,
    this.playedOnDate,
    this.frozenOnDate,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        playedOnDate == null ? context.watch<ProgressService>() : null;
    final a = Appearance.of(context);
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    bool played(DateTime day) =>
        playedOnDate?.call(day) ?? progress!.playedOnDate(day);
    bool frozen(DateTime day) =>
        frozenOnDate?.call(day) ?? progress?.wasFrozenOnDate(day) ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = DateTime(monday.year, monday.month, monday.day + i);
        final isToday =
            day.year == today.year &&
            day.month == today.month &&
            day.day == today.day;
        final active = played(day);
        final iced = frozen(day);

        return Column(
          children: [
            if (iced)
              const _FrozenDayOrb()
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: active ? AppGradients.gold : null,
                  color: active ? null : Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: isToday
                        ? AppColors.accent
                        : Colors.white.withValues(alpha: active ? 0 : 0.12),
                    width: isToday ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: active
                      ? const CinematicIcon(
                          glyph: CinematicGlyph.check,
                          size: 16,
                          accent: AppColors.inkOnAccent,
                          framed: false,
                        )
                      : Text(
                          labels[i],
                          style: AppTypography.label(
                            size: 10,
                            letterSpacing: 0,
                            weight: FontWeight.w700,
                            color: isToday
                                ? AppColors.accent.withValues(alpha: 0.95)
                                : a.textMuted(0.4),
                          ),
                        ),
                ),
              ),
            SizedBox(
              height: 14,
              child: isToday
                  ? Text(
                      'hoje',
                      style: AppTypography.label(
                        size: 9,
                        letterSpacing: 0.2,
                        color: AppColors.accent.withValues(alpha: 0.9),
                      ),
                    )
                  : null,
            ),
          ],
        );
      }),
    );
  }
}

/// Dia protegido pelo gelo — mesma linguagem do CTA congelado:
/// cristal, geada, brilho preso e varredura de reflexo.
class _FrozenDayOrb extends StatefulWidget {
  const _FrozenDayOrb();

  @override
  State<_FrozenDayOrb> createState() => _FrozenDayOrbState();
}

class _FrozenDayOrbState extends State<_FrozenDayOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          return SizedBox(
            width: 34,
            height: 34,
            child: CustomPaint(
              painter: _FrozenOrbPainter(t: _pulse.value),
              size: const Size.square(34),
            ),
          );
        },
      ),
    );
  }
}

class _FrozenOrbPainter extends CustomPainter {
  final double t;

  _FrozenOrbPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    final breathe = 0.5 + 0.5 * math.sin(t * math.pi * 2);
    final rect = Rect.fromCircle(center: c, radius: r);

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    _paintIceBody(canvas, c, r, rect);
    _paintFrostFilm(canvas, size, breathe);
    _paintCracks(canvas, c, r, breathe);
    _paintSnowflake(canvas, c, r, breathe);
    _paintCrystals(canvas, size, breathe);
    _paintRim(canvas, c, r, rect);

    canvas.restore();
  }

  void _paintIceBody(
    Canvas canvas,
    Offset c,
    double r,
    Rect rect,
  ) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.28, -0.36),
          radius: 1.12,
          colors: [
            AppColors.iceSoft,
            AppColors.ice,
            const Color(0xFF2A6A82),
            AppColors.iceDeep,
          ],
          stops: const [0.0, 0.38, 0.72, 1.0],
        ).createShader(rect),
    );

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.52, 0.58),
          radius: 0.82,
          colors: [
            AppColors.iceDeep.withValues(alpha: 0.5),
            AppColors.iceDeep.withValues(alpha: 0.18),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(rect),
    );
  }

  void _paintFrostFilm(Canvas canvas, Size size, double breathe) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.42),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.16 + breathe * 0.04),
            AppColors.iceSoft.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.42)),
    );

    // Geada rastejando nas bordas
    final edge = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        colors: [
          AppColors.iceSoft.withValues(alpha: 0.12),
          Colors.transparent,
          AppColors.iceSoft.withValues(alpha: 0.14),
          Colors.transparent,
          AppColors.iceSoft.withValues(alpha: 0.1),
        ],
        stops: const [0.0, 0.22, 0.5, 0.78, 1.0],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.shortestSide / 2 - 1.4,
      edge,
    );
  }

  void _paintCracks(Canvas canvas, Offset c, double r, double breathe) {
    final glow = Paint()
      ..color = AppColors.iceSoft.withValues(alpha: 0.28 + breathe * 0.1)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final crack = Paint()
      ..color = AppColors.iceSoft.withValues(alpha: 0.28 + breathe * 0.08)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    void branch(Offset from, double angle, double len, int depth) {
      if (depth <= 0 || len < 1.6) return;
      final to = Offset(
        from.dx + math.cos(angle) * len,
        from.dy + math.sin(angle) * len,
      );
      canvas.drawLine(from, to, glow);
      canvas.drawLine(from, to, crack);
      branch(to, angle - 0.62, len * 0.55, depth - 1);
      branch(to, angle + 0.48, len * 0.48, depth - 1);
    }

    branch(
      Offset(c.dx + r * 0.78, c.dy - r * 0.55),
      math.pi * 0.72,
      r * 0.42,
      3,
    );
    branch(
      Offset(c.dx - r * 0.72, c.dy - r * 0.18),
      math.pi * 0.22,
      r * 0.28,
      2,
    );
  }

  void _paintSnowflake(Canvas canvas, Offset c, double r, double breathe) {
    final s = r * 0.78;

    canvas.drawCircle(
      c,
      s * 0.42,
      Paint()
        ..color = AppColors.iceSoft.withValues(alpha: 0.12 + breathe * 0.04)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2.4),
    );

    final armGlow = Paint()
      ..color = AppColors.iceSoft.withValues(alpha: 0.7)
      ..strokeWidth = 2.15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.1);

    final arm = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.iceSoft,
          AppColors.ice,
          const Color(0xFF3A8AAA),
        ],
      ).createShader(Rect.fromCircle(center: c, radius: s))
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final highlight = Paint()
      ..color = AppColors.iceSoft.withValues(alpha: 0.45)
      ..strokeWidth = 0.45
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3 - math.pi / 2;
      final tip = c + Offset(math.cos(a) * s * 0.52, math.sin(a) * s * 0.52);
      final mid = c + Offset(math.cos(a) * s * 0.28, math.sin(a) * s * 0.28);
      canvas.drawLine(c, tip, armGlow);
      canvas.drawLine(c, tip, arm);
      canvas.drawLine(c, Offset.lerp(c, tip, 0.72)!, highlight);

      for (final sign in [-1.0, 1.0]) {
        final ba = a + sign * 0.72;
        final bTip =
            mid + Offset(math.cos(ba) * s * 0.18, math.sin(ba) * s * 0.18);
        canvas.drawLine(mid, bTip, arm);
        canvas.drawLine(mid, bTip, highlight);
      }

      // Losango na ponta — faceta de cristal
      final facet = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(
          tip.dx - math.cos(a) * s * 0.1 + math.sin(a) * s * 0.055,
          tip.dy - math.sin(a) * s * 0.1 - math.cos(a) * s * 0.055,
        )
        ..lineTo(
          tip.dx - math.cos(a) * s * 0.1 - math.sin(a) * s * 0.055,
          tip.dy - math.sin(a) * s * 0.1 + math.cos(a) * s * 0.055,
        )
        ..close();
      canvas.drawPath(
        facet,
        Paint()..color = AppColors.iceSoft.withValues(alpha: 0.55),
      );
    }

    canvas.drawCircle(
      c,
      s * 0.09,
      Paint()..color = AppColors.iceSoft,
    );
    canvas.drawCircle(
      c,
      s * 0.045,
      Paint()..color = AppColors.iceSoft.withValues(alpha: 0.85),
    );
  }

  void _paintCrystals(Canvas canvas, Size size, double breathe) {
    const specs = [
      (0.18, 0.22, 1.15, 0.0),
      (0.78, 0.28, 0.9, 0.33),
      (0.22, 0.74, 0.8, 0.62),
      (0.82, 0.7, 1.05, 0.18),
      (0.62, 0.16, 0.7, 0.8),
    ];
    for (final spec in specs) {
      final (nx, ny, s, phase) = spec;
      final cycle = (t * 0.55 + phase) % 1.0;
      final alpha =
          (0.25 + 0.55 * (1 - (cycle - 0.5).abs() * 2) + breathe * 0.12)
              .clamp(0.0, 0.9);
      final ox = nx * size.width;
      final oy = ny * size.height;
      canvas.save();
      canvas.translate(ox, oy);
      canvas.rotate(cycle * math.pi + phase * math.pi);
      final paint = Paint()
        ..color = Color.lerp(
          AppColors.iceSoft,
          AppColors.ice,
          phase < 0.4 ? 0.35 : 0.15,
        )!.withValues(alpha: alpha);
      final path = Path()
        ..moveTo(0, -s * 1.6)
        ..lineTo(s * 0.7, 0)
        ..lineTo(0, s * 1.6)
        ..lineTo(-s * 0.7, 0)
        ..close();
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  void _paintRim(
    Canvas canvas,
    Offset c,
    double r,
    Rect rect,
  ) {
    canvas.drawCircle(
      c,
      r - 0.7,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.55
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.iceSoft.withValues(alpha: 0.55),
            AppColors.ice.withValues(alpha: 0.45),
            AppColors.iceDeep.withValues(alpha: 0.7),
            AppColors.ice.withValues(alpha: 0.4),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _FrozenOrbPainter oldDelegate) =>
      oldDelegate.t != t;
}
