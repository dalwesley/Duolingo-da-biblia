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

    return GlassCard(
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            label: 'Missões diárias',
            trailing: CountBadge('$doneCount/$total'),
          ),
          const SizedBox(height: 12),
          ...DailyQuestDefs.all.map((q) {
            final value = progress.questProgress(q.id);
            final claimed = progress.isQuestClaimed(q.id);
            final done = claimed || value >= q.target;
            final pct = (value / q.target).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  CinematicIcon(
                    glyph: CinematicGlyphResolver.forQuest(q.id),
                    size: 34,
                    glowing: false,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(
                              alpha: claimed ? 0.45 : 0.95,
                            ),
                            decoration:
                                claimed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${value.clamp(0, q.target)}/${q.target} · ${q.subtitle}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
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
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.teal,
                      size: 22,
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
