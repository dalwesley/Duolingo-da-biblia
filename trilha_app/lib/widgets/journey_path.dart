import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../theme/app_theme.dart';
import '../utils/trail_visuals.dart';
import 'ui_primitives.dart';

enum JourneyNodeState { locked, upcoming, current, completed, soon }

class JourneyPathItem {
  final Trail trail;
  final JourneyNodeState state;
  final TrailCategory category;
  final int done;
  final int total;
  final int chapterIndex;

  const JourneyPathItem({
    required this.trail,
    required this.state,
    required this.category,
    this.done = 0,
    this.total = 0,
    this.chapterIndex = 1,
  });
}

/// Peregrinação cinematográfica — estações editoriais, não nós de jogo.
class JourneyPath extends StatelessWidget {
  final List<JourneyPathItem> items;
  final Color accent;
  final Color glow;
  final void Function(JourneyPathItem item) onTap;
  final GlobalKey? currentKey;

  const JourneyPath({
    super.key,
    required this.items,
    required this.accent,
    required this.glow,
    required this.onTap,
    this.currentKey,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final children = <Widget>[];
    TrailCategory? lastCategory;
    var chapter = 0;

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.category != lastCategory) {
        children.add(
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 4 : 36, bottom: 20),
            child: _FilmIntertitle(
              label: item.category.label,
              description: item.category.description,
              accent: accent,
            ),
          ),
        );
        lastCategory = item.category;
      }

      chapter++;
      final station = JourneyPathItem(
        trail: item.trail,
        state: item.state,
        category: item.category,
        done: item.done,
        total: item.total,
        chapterIndex: chapter,
      );

      children.add(
        KeyedSubtree(
          key: item.state == JourneyNodeState.current ? currentKey : null,
          child: _PathStation(
            item: station,
            accent: accent,
            glow: glow,
            isLast: i == items.length - 1,
            onTap: () => onTap(item),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _FilmIntertitle extends StatelessWidget {
  final String label;
  final String description;
  final Color accent;

  const _FilmIntertitle({
    required this.label,
    required this.description,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 3.2,
            color: accent.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 48,
          height: 1.5,
          color: accent.withValues(alpha: 0.45),
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.52),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PathStation extends StatelessWidget {
  final JourneyPathItem item;
  final Color accent;
  final Color glow;
  final bool isLast;
  final VoidCallback onTap;

  const _PathStation({
    required this.item,
    required this.accent,
    required this.glow,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = item.state == JourneyNodeState.current;
    final isDone = item.state == JourneyNodeState.completed;
    final isLocked = item.state == JourneyNodeState.locked;
    final railActive = isDone || isCurrent;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                _RailBeacon(
                  accent: accent,
                  glow: glow,
                  isCurrent: isCurrent,
                  isDone: isDone,
                  isLocked: isLocked,
                ),
                if (!isLast)
                  Expanded(
                    child: CustomPaint(
                      painter: _RailPainter(
                        color: railActive
                            ? accent.withValues(alpha: 0.55)
                            : Colors.white.withValues(alpha: 0.14),
                        active: railActive,
                        seed: item.trail.slug.hashCode ^ item.chapterIndex,
                      ),
                      child: const SizedBox(width: 42),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: isCurrent
                  ? _HeroStation(
                      item: item,
                      accent: accent,
                      glow: glow,
                      onTap: onTap,
                    )
                  : _QuietStation(
                      item: item,
                      accent: accent,
                      onTap: onTap,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RailBeacon extends StatelessWidget {
  final Color accent;
  final Color glow;
  final bool isCurrent;
  final bool isDone;
  final bool isLocked;

  const _RailBeacon({
    required this.accent,
    required this.glow,
    required this.isCurrent,
    required this.isDone,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    final size = isCurrent ? 18.0 : 12.0;
    return SizedBox(
      height: isCurrent ? 28 : 22,
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isDone || isCurrent
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accent, Color.lerp(accent, Colors.black, 0.25)!],
                  )
                : null,
            color: isDone || isCurrent
                ? null
                : Colors.white.withValues(alpha: isLocked ? 0.12 : 0.22),
            border: Border.all(
              color: isCurrent
                  ? Colors.white.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.15),
              width: isCurrent ? 1.5 : 1,
            ),
            boxShadow: [
              if (isCurrent)
                BoxShadow(
                  color: glow.withValues(alpha: 0.55),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: isDone
              ? Icon(Icons.check_rounded, size: 8, color: AppColors.night.withValues(alpha: 0.85))
              : null,
        ),
      ),
    );
  }
}

class _RailPainter extends CustomPainter {
  final Color color;
  final bool active;
  final int seed;

  _RailPainter({
    required this.color,
    required this.active,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 1) return;

    final path = _trailPath(size);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 2.4 : 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (active) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      _drawDashed(canvas, path, paint, dash: 10, gap: 4);
    } else {
      _drawDashed(canvas, path, paint, dash: 5.5, gap: 5.5);
    }
  }

  /// Caminho orgânico: começa e termina no centro, com curvas e trechos retos.
  Path _trailPath(Size size) {
    final rng = math.Random(seed);
    final cx = size.width / 2;
    final h = size.height;
    final swing = size.width * (0.22 + rng.nextDouble() * 0.14);
    final dir = seed.isEven ? 1.0 : -1.0;

    final y1 = h * (0.18 + rng.nextDouble() * 0.08);
    final y2 = h * (0.42 + rng.nextDouble() * 0.1);
    final y3 = h * (0.68 + rng.nextDouble() * 0.08);

    final path = Path()..moveTo(cx, 0);
    path.lineTo(cx + dir * swing * 0.08, y1 * 0.55);
    path.cubicTo(
      cx + dir * swing * 0.15,
      y1,
      cx + dir * swing,
      y1 + (y2 - y1) * 0.25,
      cx + dir * swing * 0.85,
      y2,
    );
    path.cubicTo(
      cx + dir * swing * 0.55,
      y2 + (y3 - y2) * 0.35,
      cx - dir * swing * 0.25,
      y2 + (y3 - y2) * 0.65,
      cx - dir * swing * 0.7,
      y3,
    );
    path.cubicTo(
      cx - dir * swing * 0.35,
      y3 + (h - y3) * 0.4,
      cx + dir * swing * 0.05,
      h - 4,
      cx,
      h,
    );
    return path;
  }

  void _drawDashed(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dash,
    required double gap,
  }) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final len = draw ? dash : gap;
        final next = math.min(distance + len, metric.length);
        if (draw) {
          canvas.drawPath(metric.extractPath(distance, next), paint);
        }
        distance = next;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RailPainter old) =>
      old.color != color || old.active != active || old.seed != seed;
}

class _HeroStation extends StatefulWidget {
  final JourneyPathItem item;
  final Color accent;
  final Color glow;
  final VoidCallback onTap;

  const _HeroStation({
    required this.item,
    required this.accent,
    required this.glow,
    required this.onTap,
  });

  @override
  State<_HeroStation> createState() => _HeroStationState();
}

class _HeroStationState extends State<_HeroStation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final visuals = TrailVisuals.forTrail(item.trail);
    final pct = item.total > 0 ? item.done / item.total : 0.0;
    return AnimatedBuilder(
      animation: _breath,
      builder: (context, child) {
        final glowStrength = 0.18 + (_breath.value * 0.12);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: widget.glow.withValues(alpha: glowStrength),
                blurRadius: 36,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(26),
          child: Ink(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(visuals.cardGradient.colors.first, Colors.black, 0.15)!,
                  Color.lerp(visuals.cardGradient.colors.last, const Color(0xFF05040A), 0.2)!,
                ],
              ),
              border: Border.all(
                color: widget.accent.withValues(alpha: 0.42),
                width: 1.2,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: CustomPaint(
                      painter: _StationMoodPainter(
                        accent: visuals.accent,
                        glow: widget.glow,
                        seed: item.trail.slug.hashCode,
                        intense: true,
                      ),
                    ),
                  ),
                ),
                // Film edge vignette
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        gradient: RadialGradient(
                          center: const Alignment(-0.2, -0.3),
                          radius: 1.15,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.45),
                          ],
                          stops: const [0.4, 1],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'CENA ${_roman(item.chapterIndex)}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.4,
                              color: widget.accent.withValues(alpha: 0.9),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: widget.accent.withValues(alpha: 0.18),
                              border: Border.all(
                                color: widget.accent.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              'NO CAMINHO',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: widget.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        item.trail.title,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.trail.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: Colors.white.withValues(alpha: 0.62),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (item.total > 0) ...[
                        AppProgressBar(
                          value: pct,
                          color: widget.accent,
                          trackColor: Colors.white.withValues(alpha: 0.1),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Row(
                        children: [
                          if (item.total > 0)
                            Text(
                              '${item.done} de ${item.total} passos',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          const Spacer(),
                          Text(
                            'ENTRAR →',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              color: widget.accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _roman(int n) {
    const map = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X',
        'XI', 'XII', 'XIII', 'XIV', 'XV', 'XVI', 'XVII', 'XVIII', 'XIX', 'XX'];
    if (n >= 1 && n <= map.length) return map[n - 1];
    return '$n';
  }
}

class _QuietStation extends StatelessWidget {
  final JourneyPathItem item;
  final Color accent;
  final VoidCallback onTap;

  const _QuietStation({
    required this.item,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = TrailVisuals.forTrail(item.trail);
    final isDone = item.state == JourneyNodeState.completed;
    final isLocked = item.state == JourneyNodeState.locked;
    final isSoon = item.state == JourneyNodeState.soon;
    final alpha = isLocked ? 0.55 : 1.0;

    return Opacity(
      opacity: alpha,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: isDone ? 0.07 : 0.05),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
              border: Border.all(
                color: isDone
                    ? accent.withValues(alpha: 0.28)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: isLocked
                          ? null
                          : visuals.iconGradient,
                      color: isLocked
                          ? Colors.white.withValues(alpha: 0.06)
                          : null,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Icon(
                      isDone
                          ? Icons.check_rounded
                          : isLocked
                              ? Icons.lock_outline_rounded
                              : isSoon
                                  ? Icons.schedule_rounded
                                  : visuals.icon,
                      color: isDone
                          ? accent
                          : Colors.white.withValues(alpha: isLocked ? 0.4 : 0.9),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionLabel(
                          'Cena ${_roman(item.chapterIndex)}',
                          size: 10,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.trail.title,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: isLocked ? 0.65 : 0.92),
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isDone
                              ? 'Concluída'
                              : isSoon
                                  ? 'Em breve neste caminho'
                                  : isLocked
                                      ? 'Ainda além do horizonte'
                                      : item.total > 0
                                          ? '${item.done}/${item.total} passos'
                                          : item.trail.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDone
                                ? accent.withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.42),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLocked)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.28),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _roman(int n) {
    const map = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X',
        'XI', 'XII', 'XIII', 'XIV', 'XV', 'XVI', 'XVII', 'XVIII', 'XIX', 'XX'];
    if (n >= 1 && n <= map.length) return map[n - 1];
    return '$n';
  }
}

class _StationMoodPainter extends CustomPainter {
  final Color accent;
  final Color glow;
  final int seed;
  final bool intense;

  _StationMoodPainter({
    required this.accent,
    required this.glow,
    required this.seed,
    required this.intense,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    // Soft light blooms
    for (var i = 0; i < 3; i++) {
      final cx = size.width * (0.55 + rng.nextDouble() * 0.4);
      final cy = size.height * (0.1 + rng.nextDouble() * 0.5);
      final r = size.width * (0.25 + rng.nextDouble() * 0.25);
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              (i.isEven ? accent : glow).withValues(alpha: intense ? 0.14 : 0.06),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
      );
    }

    // Horizon haze
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.45),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            accent.withValues(alpha: 0.06),
          ],
        ).createShader(Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.45)),
    );

    // Distant hill silhouette
    final hill = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.58,
        size.width * 0.5,
        size.height * 0.7,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.82,
        size.width,
        size.height * 0.64,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      hill,
      Paint()..color = Colors.black.withValues(alpha: 0.22),
    );
  }

  @override
  bool shouldRepaint(covariant _StationMoodPainter old) =>
      old.accent != accent || old.intense != intense;
}
