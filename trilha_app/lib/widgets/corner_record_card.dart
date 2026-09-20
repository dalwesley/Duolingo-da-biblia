import 'package:flutter/material.dart';

import '../models/corner_challenge.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Medalha no perfil — o desafio fechado não volta para a Home.
class CornerRecordCard extends StatelessWidget {
  final CornerRecord record;

  const CornerRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    if (record.isEmpty) return const SizedBox.shrink();
    final a = Appearance.of(context);
    final accent = record.wins > 0 ? AppColors.accent : AppColors.teal;

    return GlassCard(
      elevated: true,
      tint: accent,
      padding: AppMetrics.cardPadding,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.16),
              border: Border.all(color: accent.withValues(alpha: 0.55)),
            ),
            alignment: Alignment.center,
            child: Text(
              '${record.closed}',
              style: AppTypography.title(
                size: 20,
                weight: FontWeight.w900,
                color: accent,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CinematicIcon(
                      glyph: CinematicGlyph.flag,
                      size: 16,
                      accent: accent,
                      framed: false,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      CornerCopy.recordChapter.toUpperCase(),
                      style: AppTypography.label(
                        size: 10,
                        letterSpacing: 1.4,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  record.line,
                  style: AppTypography.title(size: 16, color: a.text),
                ),
                const SizedBox(height: 2),
                Text(
                  record.whisper,
                  style: AppTypography.body(
                    size: 13,
                    color: a.textMuted(0.62),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
