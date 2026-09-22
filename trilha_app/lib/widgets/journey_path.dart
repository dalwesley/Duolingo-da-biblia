import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/difficulty.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/trail_progress.dart';
import '../utils/trail_visuals.dart';
import 'cinematic_icon.dart';
import 'mode_emblem.dart';
import 'ui_primitives.dart';

enum JourneyNodeState { locked, upcoming, current, completed, soon }

class JourneyPathItem {
  final Trail trail;
  final JourneyNodeState state;
  final TrailCategory category;
  final int done;
  final int total;
  final int chapterIndex;

  /// Ex.: "Observação concluída" — diferencia modo limpo de progresso zerado.
  final String? statusLabel;

  /// IDs dos modos já selados nesta trilha (`semente`, `caminhada`, …).
  final List<String> clearedModeIds;

  /// Modo ativo nesta trilha (`semente` = Observação).
  final String? activeDifficultyId;

  const JourneyPathItem({
    required this.trail,
    required this.state,
    required this.category,
    this.done = 0,
    this.total = 0,
    this.chapterIndex = 1,
    this.statusLabel,
    this.clearedModeIds = const [],
    this.activeDifficultyId,
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
        clearedModeIds: item.clearedModeIds,
        activeDifficultyId: item.activeDifficultyId,
      );

      children.add(
        KeyedSubtree(
          key: item.state == JourneyNodeState.current ? currentKey : null,
          child: _PathStation(
            item: station,
            nextItem: i + 1 < items.length ? items[i + 1] : null,
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
  final JourneyPathItem? nextItem;
  final Color accent;
  final Color glow;
  final bool isLast;
  final VoidCallback onTap;

  const _PathStation({
    required this.item,
    this.nextItem,
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
    final liveModeColor = _liveModeAccentOf(item);
    final railColor = _stationChromeOf(item) ?? accent;
    final nextRailColor = nextItem == null
        ? railColor
        : (_stationChromeOf(nextItem!) ?? railColor);

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
                    accent: railColor,
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
                              ? railColor
                              : Colors.white.withValues(alpha: 0.2),
                          endColor: railActive ? nextRailColor : null,
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
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: isCurrent
                  ? _HeroStation(
                      item: item,
                      accent: liveModeColor ?? accent,
                      onTap: onTap,
                    )
                  : _QuietStation(
                      item: item,
                      accent: liveModeColor ?? accent,
                      onTap: onTap,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

Color? _stationChromeOf(JourneyPathItem item) {
  if (item.state == JourneyNodeState.locked ||
      item.state == JourneyNodeState.soon) {
    return null;
  }
  final live = _liveModeAccentOf(item);
  if (live != null) return live;
  final open = TrailDifficulty.fromId(item.activeDifficultyId);
  if (open != null) return DifficultyVisuals.accentFor(open);
  return _sealedModeAccentOf(item);
}

/// Cor do modo vivo (o que a pessoa está andando agora).
/// Trilha selada e parada não herda o ouro da Observação concluída.
Color? _liveModeAccentOf(JourneyPathItem item) {
  if (item.state == JourneyNodeState.locked ||
      item.state == JourneyNodeState.soon) {
    return null;
  }
  final live = TrailDifficulty.fromId(item.activeDifficultyId);
  if (item.state == JourneyNodeState.completed) {
    if (live != null && !item.clearedModeIds.contains(live.id)) {
      return DifficultyVisuals.accentFor(live);
    }
    return null;
  }
  return live == null ? null : DifficultyVisuals.accentFor(live);
}

Color? _sealedModeAccentOf(JourneyPathItem item) {
  final ordered = TrailProgress.orderedClearedDifficulties(item.clearedModeIds);
  if (ordered.isEmpty) return null;
  return DifficultyVisuals.accentFor(ordered.last);
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
    final size = isCurrent ? 14.0 : 9.0;
    final fill = isDone || isCurrent
        ? accent
        : Colors.white.withValues(alpha: isLocked ? 0.14 : 0.22);
    return SizedBox(
      height: isCurrent ? 28 : 20,
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: Border.all(
              color: isCurrent
                  ? accent.withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: isLocked ? 0.08 : 0.14),
              width: isCurrent ? 1.2 : 1,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.45),
                      blurRadius: 14,
                      spreadRadius: 1.5,
                    ),
                  ]
                : null,
          ),
          child: isDone
              ? Center(
                  child: CinematicIcon(
                    glyph: CinematicGlyph.check,
                    size: 7,
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
  final Color? endColor;
  final bool active;
  final int seed;

  _RailPainter({
    required this.color,
    this.endColor,
    required this.active,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 1) return;

    final path = _trailPath(size);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = active ? 1.6 : 1.4
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final tail = endColor;
    if (tail != null && tail.toARGB32() != color.toARGB32()) {
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, tail],
      ).createShader(Offset.zero & size);
    } else {
      paint.color = color;
    }

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
      old.color != color ||
      old.endColor != endColor ||
      old.active != active ||
      old.seed != seed;
}

class _HeroStation extends StatelessWidget {
  final JourneyPathItem item;
  final Color accent;
  final VoidCallback onTap;

  const _HeroStation({
    required this.item,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = item.total > 0 ? item.done / item.total : 0.0;
    final a = Appearance.of(context);
    final visuals = TrailVisuals.forTrail(item.trail);
    final mode = TrailDifficulty.fromId(item.activeDifficultyId);
    final modeCleared =
        mode != null && item.clearedModeIds.contains(mode.id);
    final modeColor = mode != null
        ? DifficultyVisuals.accentFor(mode)
        : accent;
    final onSky = DifficultyVisuals.onSky(modeColor);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          decoration: DifficultyVisuals.stationCard(
            accent: modeColor,
            baseFill: a.cardFill,
            lit: true,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: Stack(
              children: [
                Positioned(
                  right: -6,
                  bottom: -18,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.11,
                      child: CinematicIcon(
                        glyph: visuals.glyph,
                        size: 124,
                        accent: onSky,
                        framed: false,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.xl,
                    AppSpace.xl,
                    AppSpace.xl,
                    AppSpace.lg + 2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'CENA ${_roman(item.chapterIndex)}',
                            style: AppTypography.label(
                              size: 10,
                              letterSpacing: 2.6,
                              color: onSky.withValues(alpha: 0.78),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'você está aqui',
                            style: AppTypography.label(
                              size: 9,
                              letterSpacing: 1.2,
                              color: onSky.withValues(alpha: 0.62),
                            ),
                          ),
                        ],
                      ),
                      if (mode != null) ...[
                        const SizedBox(height: AppSpace.sm + 2),
                        ModeStatusChip(
                          difficulty: mode,
                          cleared: modeCleared,
                        ),
                      ],
                      const SizedBox(height: AppSpace.md),
                      Text(
                        item.trail.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.display(size: 28, height: 1.06),
                      ),
                      const SizedBox(height: AppSpace.sm),
                      Text(
                        item.trail.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(
                          size: 13,
                          height: 1.35,
                          color: a.textMuted(0.52),
                        ),
                      ),
                      if (item.total > 0) ...[
                        const SizedBox(height: AppSpace.lg),
                        _DustHairline(value: pct, color: modeColor),
                        const SizedBox(height: 10),
                        Text(
                          item.statusLabel ??
                              '${item.done} de ${item.total} passos',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            size: 12,
                            weight: FontWeight.w600,
                            color: onSky.withValues(alpha: 0.86),
                          ),
                        ),
                      ],
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
    final a = Appearance.of(context);
    final liveColor = _liveModeAccentOf(item);
    final sealedColor = isDone ? _sealedModeAccentOf(item) : null;
    final chrome = liveColor ?? sealedColor;
    final replaying = liveColor != null;
    final sealedIdle = isDone && !replaying && sealedColor != null;
    final openMode = TrailDifficulty.fromId(item.activeDifficultyId);
    final openUncleared =
        openMode != null && !item.clearedModeIds.contains(openMode.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Ink(
          decoration: isLocked || isSoon
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  color: a.cardFill.withValues(alpha: isLocked ? 0.38 : 0.5),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                )
              : chrome != null
                  ? DifficultyVisuals.stationCard(
                      accent: chrome,
                      baseFill: a.cardFill,
                      lit: false,
                      sealed: sealedIdle,
                    )
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      color: a.cardFill,
                      border: Border.all(color: a.cardBorder),
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
                _QuietLeading(
                  visuals: visuals,
                  isDone: isDone,
                  isLocked: isLocked,
                  isSoon: isSoon,
                  accent: chrome ?? accent,
                  clearedModeIds: item.clearedModeIds,
                  openDifficulty: openUncleared && !isLocked ? openMode : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionLabel(
                        'Cena ${_roman(item.chapterIndex)}',
                        size: 10,
                        color: Colors.white.withValues(
                          alpha: isLocked ? 0.28 : 0.38,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.trail.title,
                        style: AppTypography.display(
                          size: 20,
                          height: 1.1,
                          color: Colors.white.withValues(
                            alpha: isLocked ? 0.48 : 0.92,
                          ),
                        ),
                      ),
                      if (openUncleared && !isLocked && !isSoon) ...[
                        const SizedBox(height: 6),
                        ModeStatusChip(
                          difficulty: openMode,
                          compact: true,
                        ),
                      ],
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        isLocked
                            ? 'Ainda além do horizonte'
                            : isSoon
                                ? 'Em breve neste caminho'
                                : item.statusLabel ??
                                    (isDone
                                        ? 'Concluída'
                                        : item.total > 0
                                            ? '${item.done}/${item.total} passos'
                                            : item.trail.description),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(
                          size: 12,
                          color: isLocked
                              ? Colors.white.withValues(alpha: 0.32)
                              : chrome != null
                                  ? chrome.withValues(alpha: 0.9)
                                  : Colors.white.withValues(alpha: 0.42),
                        ),
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

class _QuietLeading extends StatelessWidget {
  final TrailVisuals visuals;
  final bool isDone;
  final bool isLocked;
  final bool isSoon;
  final Color accent;
  final List<String> clearedModeIds;
  final TrailDifficulty? openDifficulty;

  const _QuietLeading({
    required this.visuals,
    required this.isDone,
    required this.isLocked,
    required this.isSoon,
    required this.accent,
    required this.clearedModeIds,
    this.openDifficulty,
  });

  @override
  Widget build(BuildContext context) {
    if (openDifficulty != null) {
      return ModeEmblem(
        key: ValueKey('mode-emblem-${openDifficulty!.id}'),
        difficulty: openDifficulty!,
        size: 44,
        cleared: false,
        active: true,
      );
    }
    if (isDone && clearedModeIds.isNotEmpty) {
      final n = clearedModeIds.toSet().length;
      return ModeEmblemStrip(
        clearedModeIds: clearedModeIds,
        clearedOnly: true,
        emblemSize: n > 1 ? 34 : 44,
      );
    }

    if (isLocked || isSoon) {
      return SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: CinematicIcon(
            glyph: visuals.glyph,
            size: 22,
            accent: Colors.white.withValues(alpha: isLocked ? 0.22 : 0.38),
            framed: false,
          ),
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        gradient: visuals.iconGradient,
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: CinematicIcon(
        glyph: visuals.glyph,
        size: 22,
        accent: accent,
        framed: false,
      ),
    );
  }
}

/// Progresso como poeira no chão — não a barra gorda de curso.
class _DustHairline extends StatelessWidget {
  final double value;
  final Color color;

  const _DustHairline({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = value.clamp(0.0, 1.0);
    return SizedBox(
      height: 2,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = (constraints.maxWidth * t).clamp(
            t > 0 ? 6.0 : 0.0,
            constraints.maxWidth,
          );
          return Stack(
            children: [
              Container(
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              if (w > 0)
                Container(
                  width: w,
                  height: 2,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
