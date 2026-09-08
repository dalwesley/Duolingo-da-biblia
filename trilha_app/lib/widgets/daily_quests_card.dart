import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/daily_quest.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Três gestos do dia — um card, sem grupos de bônus.
class DailyQuestsCard extends StatelessWidget {
  final void Function(DailyQuest quest)? onQuestTap;

  const DailyQuestsCard({super.key, this.onQuestTap});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final quests = DailyQuestDefs.all;
    final doneCount = quests
        .where(
          (q) =>
              progress.isQuestClaimed(q.id) ||
              progress.questProgress(q.id) >= q.target,
        )
        .length;

    return GlassCard(
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            label: 'Gestos de hoje',
            trailing: CountBadge('$doneCount/${quests.length}'),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < quests.length; i++) ...[
            if (i > 0) const SizedBox(height: 2),
            _QuestRow(
              quest: quests[i],
              progress: progress,
              onTap: onQuestTap,
            ),
          ],
        ],
      ),
    );
  }
}

class _QuestRow extends StatelessWidget {
  final DailyQuest quest;
  final ProgressService progress;
  final void Function(DailyQuest quest)? onTap;

  const _QuestRow({required this.quest, required this.progress, this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final q = quest;
    final value = progress.questProgress(q.id);
    final claimed = progress.isQuestClaimed(q.id);
    final done = claimed || value >= q.target;
    final canTap = onTap != null && !claimed;
    final tone = CinematicGlyphResolver.accentForQuest(q.id);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canTap
            ? () {
                HapticFeedback.selectionClick();
                onTap!(q);
              }
            : null,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CinematicIcon(
                glyph: CinematicGlyphResolver.forQuest(q.id),
                size: 28,
                accent: tone,
                glowing: false,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.title,
                      style: AppTypography.title(
                        size: 15,
                        color: a.text.withValues(alpha: done ? 0.45 : 0.98),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      done ? 'Feito' : q.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        size: 12,
                        weight: FontWeight.w700,
                        color: done ? tone : a.textMuted(0.55),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.md),
              if (done)
                CinematicIcon(
                  glyph: CinematicGlyph.check,
                  size: 22,
                  accent: tone,
                  framed: false,
                )
              else
                CountBadge('+${q.stepsReward}', filled: true, color: tone),
            ],
          ),
        ),
      ),
    );
  }
}
