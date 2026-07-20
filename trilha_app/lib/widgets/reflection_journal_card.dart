import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mission_study.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Diário leve — últimas reflexões guardadas nas missões.
class ReflectionJournalCard extends StatelessWidget {
  const ReflectionJournalCard({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);
    final items = progress.recentReflections(limit: 3);

    return GlassCard(
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(label: 'Seu diário'),
          const SizedBox(height: AppSpace.md),
          if (items.isEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CinematicIcon(
                  glyph: CinematicGlyph.scroll,
                  size: 22,
                  accent: AppColors.primaryLight.withValues(alpha: 0.95),
                  framed: false,
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nenhuma reflexão ainda',
                        style: AppTypography.title(size: 14, color: a.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ao terminar um passo da trilha, sua resposta fica registrada aqui.',
                        style: AppTypography.body(
                          size: 12,
                          color: a.textMuted(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            ...items.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              final study = MissionStudy.forSlug(e.key);
              final title = study?.passageRef ?? e.key;
              final isLast = i == items.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpace.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (i > 0) ...[
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: a.cardBorder.withValues(alpha: 0.55),
                      ),
                      const SizedBox(height: AppSpace.md),
                    ],
                    Text(
                      title,
                      style: AppTypography.body(
                        size: 11,
                        weight: FontWeight.w800,
                        color: AppColors.accent.withValues(alpha: 0.95),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '“${e.value}”',
                      style: AppTypography.body(
                        size: 14,
                        height: 1.4,
                        weight: FontWeight.w600,
                        color: a.text.withValues(alpha: 0.9),
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
