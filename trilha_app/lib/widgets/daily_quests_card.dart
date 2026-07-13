import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_quest.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';

class DailyQuestsCard extends StatelessWidget {
  const DailyQuestsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CENAS DO DIA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                  color: AppColors.accent.withValues(alpha: 0.9),
                ),
              ),
              const Spacer(),
              Text(
                '${progress.questsCompletedToday}/${DailyQuestDefs.all.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: a.textMuted(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...DailyQuestDefs.all.map((q) {
            final value = progress.questProgress(q.id);
            final done = progress.isQuestClaimed(q.id) || value >= q.target;
            final claimed = progress.isQuestClaimed(q.id);
            final pct = (value / q.target).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  CinematicIcon(
                    glyph: CinematicGlyphResolver.forQuest(q.id),
                    size: 36,
                    glowing: !done,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha: done ? 0.55 : 1),
                            decoration: claimed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          q.subtitle,
                          style: TextStyle(fontSize: 11, color: a.textMuted(0.5)),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 5,
                            backgroundColor: a.progressTrack,
                            color: claimed ? AppColors.teal : AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (claimed)
                    const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 22)
                  else if (done)
                    GestureDetector(
                      onTap: () => progress.claimQuest(q.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppGradients.gold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${q.xpReward}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF3D2E00),
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      '$value/${q.target}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: a.textMuted(0.45),
                      ),
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
