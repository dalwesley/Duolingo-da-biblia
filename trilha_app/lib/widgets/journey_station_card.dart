import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/difficulty_visuals.dart';
import 'act_feel.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

enum JourneyNodeState { locked, upcoming, current, completed, soon }

/// Card de estação na curva — mapa do reino e mapa da trilha.
class JourneyStationCard extends StatelessWidget {
  final String title;
  final String eyebrow;
  final JourneyNodeState state;
  final Color accent;
  final Color glow;
  final VoidCallback? onTap;
  final Widget? leading;
  final String? currentSubtitle;
  final String? statusLine;
  final int done;
  final int total;
  final String? semanticsLabel;

  /// Acento do chrome quando difere do [accent] (ex.: modo selado).
  final Color? chrome;

  const JourneyStationCard({
    super.key,
    required this.title,
    required this.eyebrow,
    required this.state,
    required this.accent,
    required this.glow,
    this.onTap,
    this.leading,
    this.currentSubtitle,
    this.statusLine,
    this.done = 0,
    this.total = 0,
    this.semanticsLabel,
    this.chrome,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = state == JourneyNodeState.current;
    final isDone = state == JourneyNodeState.completed;
    final isLocked = state == JourneyNodeState.locked;
    final isSoon = state == JourneyNodeState.soon;
    final a = Appearance.of(context);
    final tone = chrome;
    final ink = tone ?? accent;
    final left = (total - done).clamp(0, total);
    final lit = !isLocked && !isSoon && (isCurrent || tone != null || isDone);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Expanded(
              child: SectionLabel(
                eyebrow,
                size: 10,
                color: isCurrent ? ink : a.textFaint,
              ),
            ),
            if (isCurrent)
              Text(
                context.l10n.journeyNow,
                style: AppTypography.label(size: 11, color: ink),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.display(
            size: isCurrent ? 20 : 18,
            height: 1.1,
            color: isLocked || isSoon ? a.textSecondary : a.text,
          ),
        ),
        const SizedBox(height: 4),
        if (isCurrent && currentSubtitle != null)
          Text(
            currentSubtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w800,
              color: ink,
            ),
          ),
        if (!isCurrent)
          Text(
            statusLine ?? _defaultStatus(context, isLocked, isSoon, isDone),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w700,
              color: isLocked || isSoon ? a.textFaint : ink,
            ),
          ),
        if (isCurrent && total > 0) ...[
          const SizedBox(height: 8),
          AppProgressBar(
            value: done / total,
            color: ink,
            trackColor: a.progressTrack,
            height: 6,
          ),
          const SizedBox(height: 6),
          Text(
            left > 0
                ? context.l10n.journeyScenesLeft(left)
                : (statusLine ?? context.l10n.trailsScenesOf(done, total)),
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
              style: AppTypography.cta(size: 14, color: ink),
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
                  color: (isCurrent ? glow : ink).withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: DecoratedBox(
              decoration: DifficultyVisuals.stationCard(
                accent: ink,
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
                      child: ColoredBox(color: ink),
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

    final tappable = onTap == null
        ? card
        : ActPress(
            onTap: onTap,
            depth: isLocked || isSoon ? 0 : (isCurrent ? 3 : 2),
            child: card,
          );

    return Opacity(
      opacity: isLocked || isSoon ? 0.72 : 1,
      child: Semantics(
        label: semanticsLabel ?? title,
        button: onTap != null,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final preferred = math.min(
              176.0,
              math.max(148.0, constraints.maxWidth * 0.56),
            );
            final width = math.min(preferred, constraints.maxWidth);
            return SizedBox(width: width, child: tappable);
          },
        ),
      ),
    );
  }

  String _defaultStatus(
    BuildContext context,
    bool isLocked,
    bool isSoon,
    bool isDone,
  ) {
    if (isLocked) return context.l10n.journeyBeyondHorizon;
    if (isSoon) return context.l10n.commonComingSoon;
    if (isDone) return context.l10n.trailsCleared;
    if (total > 0) return context.l10n.trailsScenesShort(done, total);
    return '';
  }
}

String journeyRomanNumeral(int n) {
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
