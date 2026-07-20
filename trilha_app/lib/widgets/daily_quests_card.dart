import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_quest.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Missões diárias — bloco compacto no estilo quests do Duolingo.
class DailyQuestsCard extends StatelessWidget {
  const DailyQuestsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);
    final doneCount = progress.questsCompletedToday;
    final total = DailyQuestDefs.all.length;
    final quests = DailyQuestDefs.all;

    return GlassCard(
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            label: 'Missões diárias',
            trailing: CountBadge('$doneCount/$total'),
          ),
          const SizedBox(height: AppSpace.md),
          ...quests.asMap().entries.map((entry) {
            final index = entry.key;
            final q = entry.value;
            final isLast = index == quests.length - 1;
            final value = progress.questProgress(q.id);
            final claimed = progress.isQuestClaimed(q.id);
            final done = claimed || value >= q.target;
            final pct = (value / q.target).clamp(0.0, 1.0);

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpace.sm),
              child: Row(
                children: [
                  CinematicIcon(
                    glyph: CinematicGlyphResolver.forQuest(q.id),
                    size: AppMetrics.leadingIcon,
                    glowing: false,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.title,
                          style: AppTypography.title(
                            size: 13,
                            color: a.text.withValues(
                              alpha: claimed ? 0.45 : 0.95,
                            ),
                          ).copyWith(
                            decoration:
                                claimed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${value.clamp(0, q.target)}/${q.target} · ${q.subtitle}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            size: 11,
                            color: a.textMuted(0.5),
                          ),
                        ),
                        const SizedBox(height: 6),
                        AppProgressBar(
                          value: pct,
                          color: claimed
                              ? AppColors.teal
                              : AppColors.primaryLight,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (done)
                    const CinematicIcon(
                      glyph: CinematicGlyph.check,
                      size: 22,
                      accent: AppColors.teal,
                      framed: false,
                    )
                  else
                    CountBadge(
                      '+${q.stepsReward}',
                      filled: false,
                      color: a.textMuted(0.55),
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
