import 'package:flutter/material.dart';

import '../models/corner_challenge.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'relic_panel.dart';

/// Medalha no perfil — o desafio fechado não volta para a Home.
class CornerRecordCard extends StatelessWidget {
  final CornerRecord record;

  const CornerRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    if (record.isEmpty) return const SizedBox.shrink();
    final a = Appearance.of(context);
    final accent = record.wins > 0 ? AppColors.accent : AppColors.teal;

    return RelicPanel(
      accent: accent,
      elevated: true,
      child: Row(
        children: [
          RelicDisc(
            glyph: CinematicGlyph.flag,
            accent: accent,
            size: 52,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CornerCopy.recordChapter.toUpperCase(),
                  style: AppTypography.label(
                    size: 10,
                    letterSpacing: 1.4,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  record.line,
                  style: AppTypography.display(
                    size: 18,
                    weight: FontWeight.w900,
                    color: a.text,
                  ),
                ),
                const SizedBox(height: 4),
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
