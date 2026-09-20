import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'realm_world_atmosphere.dart';
import 'ui_primitives.dart';

/// Slot vazio no fim do mapa — próximos lançamentos + CTA de sugestão.
class ComingSoonTrailsCard extends StatefulWidget {
  final VoidCallback onSuggest;

  const ComingSoonTrailsCard({super.key, required this.onSuggest});

  @override
  State<ComingSoonTrailsCard> createState() => _ComingSoonTrailsCardState();
}

class _ComingSoonTrailsCardState extends State<ComingSoonTrailsCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    const accent = AppColors.accent;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onSuggest();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          height: 232,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
              boxShadow: AppMetrics.cardShadow(elevated: false),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppMetrics.heroRadius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF0B2430),
                          Color(0xFF071820),
                        ],
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                    child: Column(
                      children: [
                        _PlusMark(accent: accent.withValues(alpha: 0.88)),
                        const SizedBox(height: 14),
                        const FilmEyebrow(
                          text: 'NO HORIZONTE',
                          accent: accent,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Lançamentos em breve',
                          textAlign: TextAlign.center,
                          style: AppTypography.display(
                            size: 22,
                            color: a.text,
                            height: 1.08,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Novos caminhos estão sendo preparados.',
                          textAlign: TextAlign.center,
                          style: AppTypography.body(
                            size: 13,
                            height: 1.35,
                            color: a.text.withValues(alpha: 0.68),
                          ),
                        ),
                        const Spacer(),
                        IgnorePointer(
                          child: OutlineCta(
                            label: 'Sugerir uma trilha',
                            leading: CinematicGlyph.spark,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _DashedRRectPainter(
                          color: Color(0x99F7BB01),
                          radius: AppMetrics.heroRadius,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlusMark extends StatelessWidget {
  final Color accent;

  const _PlusMark({required this.accent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: CustomPaint(
        painter: _DashedCirclePainter(color: accent.withValues(alpha: 0.55)),
        child: Center(
          child: Text(
            '+',
            style: AppTypography.display(
              size: 28,
              color: accent,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final rect = Offset.zero & size;
    final path = Path()..addOval(rect.deflate(1));
    _strokeDashed(canvas, path, paint, dash: 3.5, gap: 3);
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedRRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeCap = StrokeCap.round;
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.8),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    _strokeDashed(canvas, path, paint, dash: 7, gap: 5.5);
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

void _strokeDashed(
  Canvas canvas,
  Path path,
  Paint paint, {
  required double dash,
  required double gap,
}) {
  for (final metric in path.computeMetrics()) {
    var dist = 0.0;
    while (dist < metric.length) {
      final next = dist + dash;
      canvas.drawPath(
        metric.extractPath(dist, next.clamp(0, metric.length)),
        paint,
      );
      dist = next + gap;
    }
  }
}
