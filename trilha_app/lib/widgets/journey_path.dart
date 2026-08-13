import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/trail_visuals.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

enum JourneyNodeState { locked, upcoming, current, completed, soon }

class JourneyPathItem {
  final Trail trail;
  final JourneyNodeState state;
  final TrailCategory category;
  final int done;
  final int total;
  final int chapterIndex;

  /// Ex.: "Semente concluída" — diferencia modo limpo de progresso zerado.
  final String? statusLabel;

  const JourneyPathItem({
    required this.trail,
    required this.state,
    required this.category,
    this.done = 0,
    this.total = 0,
    this.chapterIndex = 1,
    this.statusLabel,
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
        statusLabel: item.statusLabel,
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
          style: AppTypography.label(
            size: 11,
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
              style: AppTypography.body(
                size: 13,
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
            child: ClipRect(
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
                              ? accent
                              : Colors.white.withValues(alpha: 0.2),
                          active: railActive,
                          seed: item.trail.slug.hashCode ^ item.chapterIndex,
                        ),
                        child: const SizedBox(width: 42),
                      ),
                    ),
                ],
              ),
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
                  : _QuietStation(item: item, accent: accent, onTap: onTap),
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
    final size = isCurrent ? 16.0 : 10.0;
    return SizedBox(
      height: isCurrent ? 26 : 20,
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone || isCurrent
                ? accent
                : Colors.white.withValues(alpha: isLocked ? 0.12 : 0.22),
            border: Border.all(
              color: isCurrent ? accent : Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: isDone
              ? Center(
                  child: CinematicIcon(
                    glyph: CinematicGlyph.check,
                    size: 8,
                    accent: AppColors.night.withValues(alpha: 0.85),
                    framed: false,
                  ),
                )
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

  _RailPainter({required this.color, required this.active, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 1) return;

    final path = _trailPath(size);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 1.6 : 1.4
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    if (active) {
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

class _HeroStation extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final pct = item.total > 0 ? item.done / item.total : 0.0;
    final a = Appearance.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            color: a.cardFill,
            border: Border.all(
              color: AppMetrics.accentBorder(alpha: 0.45),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.xl,
              AppSpace.lg,
              AppSpace.xl,
              AppSpace.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'CENA ${_roman(item.chapterIndex)}',
                      style: AppTypography.label(
                        size: 10,
                        letterSpacing: 2.4,
                        color: accent.withValues(alpha: 0.9),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        color: accent.withValues(alpha: 0.14),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'AGORA',
                        style: AppTypography.label(
                          size: 9,
                          letterSpacing: 0.8,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  item.trail.title,
                  style: AppTypography.display(size: 28, height: 1.05),
                ),
                const SizedBox(height: AppSpace.sm),
                Text(
                  item.trail.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body(
                    size: 13,
                    height: 1.35,
                    color: a.textMuted(0.55),
                  ),
                ),
                const SizedBox(height: AppSpace.lg),
                if (item.total > 0) ...[
                  AppProgressBar(
                    value: pct,
                    color: accent,
                    trackColor: a.progressTrack,
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    if (item.total > 0)
                      Text(
                        item.statusLabel ??
                            '${item.done} de ${item.total} passos',
                        style: AppTypography.body(
                          size: 12,
                          weight: FontWeight.w600,
                          color: a.textMuted(0.5),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      'CONTINUAR →',
                      style: AppTypography.cta(size: 12, color: accent),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _roman(int n) {
    const map = [
      'I',
      'II',
      'III',
      'IV',
      'V',
      'VI',
      'VII',
      'VIII',
      'IX',
      'X',
      'XI',
      'XII',
      'XIII',
      'XIV',
      'XV',
      'XVI',
      'XVII',
      'XVIII',
      'XIX',
      'XX',
    ];
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
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              color: Appearance.of(
                context,
              ).cardFill.withValues(alpha: isLocked ? 0.55 : 1),
              border: Border.all(
                color: isDone
                    ? accent.withValues(alpha: 0.28)
                    : Appearance.of(context).cardBorder,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.lg,
                AppSpace.section,
                AppSpace.lg,
                AppSpace.section,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      gradient: isLocked ? null : visuals.iconGradient,
                      color: isLocked
                          ? Colors.white.withValues(alpha: 0.06)
                          : null,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: isDone || isLocked || isSoon
                        ? CinematicIcon(
                            glyph: isDone
                                ? CinematicGlyph.check
                                : isLocked
                                ? CinematicGlyph.lock
                                : CinematicGlyph.calendar,
                            size: 22,
                            accent: isDone
                                ? accent
                                : Colors.white.withValues(
                                    alpha: isLocked ? 0.4 : 0.9,
                                  ),
                            framed: false,
                          )
                        : CinematicIcon(
                            glyph: visuals.glyph,
                            size: 22,
                            accent: Colors.white.withValues(alpha: 0.92),
                            framed: false,
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
                          style: AppTypography.display(
                            size: 20,
                            height: 1.1,
                            color: Colors.white.withValues(
                              alpha: isLocked ? 0.65 : 0.92,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpace.xs),
                        Text(
                          item.statusLabel ??
                              (isDone
                                  ? 'Concluída'
                                  : isSoon
                                  ? 'Em breve neste caminho'
                                  : isLocked
                                  ? 'Ainda além do horizonte'
                                  : item.total > 0
                                  ? '${item.done}/${item.total} passos'
                                  : item.trail.description),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            size: 12,
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
    const map = [
      'I',
      'II',
      'III',
      'IV',
      'V',
      'VI',
      'VII',
      'VIII',
      'IX',
      'X',
      'XI',
      'XII',
      'XIII',
      'XIV',
      'XV',
      'XVI',
      'XVII',
      'XVIII',
      'XIX',
      'XX',
    ];
    if (n >= 1 && n <= map.length) return map[n - 1];
    return '$n';
  }
}
