import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../models/difficulty.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/trail_progress.dart';
import 'act_feel.dart';
import 'immersive_background.dart';
import 'mode_emblem.dart';
import 'relic_panel.dart';
import 'ui_primitives.dart';
import 'winding_trail.dart';

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

/// Trilhas de uma área como níveis numa curva.
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

    final a = Appearance.of(context);
    final children = <Widget>[];
    TrailCategory? lastCategory;
    var chapter = 0;
    var wave = 0;
    final run = <WindingStop>[];

    void flush(TrailCategory? category) {
      if (run.isEmpty || category == null) return;
      children.add(
        Padding(
          padding: EdgeInsets.only(top: children.isEmpty ? 4 : 28, bottom: 4),
          child: RelicChapter(
            title: category.label,
            whisper: category.description,
            accent: accent,
          ),
        ),
      );
      children.add(
        WindingTrail(
          walked: accent,
          track: Color.lerp(a.progressTrack, AppColors.textOnDark, 0.55)!,
          waveOffset: wave - run.length,
          stops: List<WindingStop>.from(run),
        ),
      );
      run.clear();
    }

    for (final item in items) {
      if (item.category != lastCategory) {
        flush(lastCategory);
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
      final isCurrent = item.state == JourneyNodeState.current;
      run.add(
        WindingStop(
          key: isCurrent ? currentKey : null,
          nodeSize: 72,
          passed: item.state == JourneyNodeState.completed,
          centerAnchor: true,
          child: _TrailCard(
            item: station,
            accent: accent,
            glow: glow,
            onTap: () => onTap(item),
          ),
        ),
      );
      wave++;
    }
    flush(lastCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _TrailCard extends StatelessWidget {
  final JourneyPathItem item;
  final Color accent;
  final Color glow;
  final VoidCallback onTap;

  const _TrailCard({
    required this.item,
    required this.accent,
    required this.glow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = item.state == JourneyNodeState.current;
    final isDone = item.state == JourneyNodeState.completed;
    final isLocked = item.state == JourneyNodeState.locked;
    final isSoon = item.state == JourneyNodeState.soon;
    final a = Appearance.of(context);
    final mode = _emblemMode(item);
    final tone = _stationChromeOf(item);
    final chrome = tone ?? accent;
    final left = (item.total - item.done).clamp(0, item.total);
    final lit = !isLocked && !isSoon && (isCurrent || tone != null);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (mode != null) ...[
              ModeEmblem(
                key: ValueKey('mode-emblem-${mode.id}'),
                difficulty: mode,
                size: 26,
                cleared: item.clearedModeIds.contains(mode.id),
                active: !item.clearedModeIds.contains(mode.id),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: SectionLabel(
                context.l10n.trailsTrailNumber(
                  _romanNumeral(item.chapterIndex),
                ),
                size: 10,
                color: isCurrent ? chrome : a.textFaint,
              ),
            ),
            if (isCurrent)
              Text(
                context.l10n.journeyNow,
                style: AppTypography.label(size: 11, color: chrome),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          item.trail.localizedTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.display(
            size: isCurrent ? 20 : 18,
            height: 1.1,
            color: isLocked || isSoon ? a.textSecondary : a.text,
          ),
        ),
        const SizedBox(height: 4),
        if (isCurrent && mode != null)
          Text(
            context.l10n.modeNamed(mode.labelPt),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w800,
              color: chrome,
            ),
          ),
        if (!isCurrent)
          Text(
            _quietStatus(context, isLocked, isSoon, isDone),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w700,
              color: isLocked || isSoon ? a.textFaint : chrome,
            ),
          ),
        if (isCurrent && item.total > 0) ...[
          const SizedBox(height: 8),
          AppProgressBar(
            value: item.done / item.total,
            color: chrome,
            trackColor: a.progressTrack,
            height: 6,
          ),
          const SizedBox(height: 6),
          Text(
            left > 0
                ? context.l10n.journeyScenesLeft(left)
                : (item.statusLabel ??
                      context.l10n.trailsScenesOf(item.done, item.total)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w700,
              color: a.text,
            ),
          ),
        ],
        if (isCurrent) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              context.l10n.journeyPlay,
              style: AppTypography.cta(size: 14, color: chrome),
            ),
          ),
        ],
      ],
    );

    final pad = const EdgeInsets.fromLTRB(14, 12, 14, 12);
    final card = lit
        ? DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              boxShadow: [
                BoxShadow(
                  color: (isCurrent ? glow : chrome).withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: DecoratedBox(
              decoration: DifficultyVisuals.stationCard(
                accent: chrome,
                baseFill: a.cardFill,
                lit: isCurrent,
                sealed: isDone && !isCurrent,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 3,
                      child: ColoredBox(color: chrome),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      child: body,
                    ),
                  ],
                ),
              ),
            ),
          )
        : GlassCard(padding: pad, child: body);

    return Opacity(
      opacity: isLocked || isSoon ? 0.72 : 1,
      child: ActPress(
        onTap: onTap,
        depth: isLocked || isSoon ? 0 : (isCurrent ? 3 : 2),
        child: Semantics(
          label: item.trail.localizedTitle,
          button: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final preferred = math.min(
                176.0,
                math.max(148.0, constraints.maxWidth * 0.56),
              );
              final width = math.min(preferred, constraints.maxWidth);
              return SizedBox(width: width, child: card);
            },
          ),
        ),
      ),
    );
  }

  String _quietStatus(
    BuildContext context,
    bool isLocked,
    bool isSoon,
    bool isDone,
  ) {
    if (isLocked) return context.l10n.journeyBeyondHorizon;
    if (isSoon) return context.l10n.commonComingSoon;
    if (item.statusLabel != null) return item.statusLabel!;
    if (isDone) return context.l10n.trailsCleared;
    if (item.total > 0) {
      return context.l10n.trailsScenesShort(item.done, item.total);
    }
    return item.trail.localizedDescription;
  }
}

/// Selo do nó: modo em curso, ou o único modo já selado.
TrailDifficulty? _emblemMode(JourneyPathItem item) {
  final isLocked = item.state == JourneyNodeState.locked;
  final isSoon = item.state == JourneyNodeState.soon;
  final open = TrailDifficulty.fromId(item.activeDifficultyId);
  final openUncleared = open != null && !item.clearedModeIds.contains(open.id);
  if (openUncleared && !isLocked && !isSoon) return open;
  if (item.state != JourneyNodeState.completed) return null;
  final sealed = TrailProgress.orderedClearedDifficulties(item.clearedModeIds);
  if (sealed.length != 1) return null;
  return sealed.first;
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

String _romanNumeral(int n) {
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
