import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_quest.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';
import '../l10n/app_language.dart';

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

    // Fundo próprio + sombra: também abre numa folha transparente.
    return GlassCard(
      padding: AppMetrics.cardPadding,
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            label: context.l10n.questDailyTitle,
            glyph: CinematicGlyph.target,
            accent: AppColors.teal,
            trailing: CountBadge('$doneCount/${quests.length}'),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            context.l10n.questDailySubtitle,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w600,
              color: Appearance.of(context).textSecondary,
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          for (var i = 0; i < quests.length; i++) ...[
            if (i > 0) const SizedBox(height: 2),
            _QuestRow(quest: quests[i], progress: progress, onTap: onQuestTap),
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
                ActHaptics.tap();
                onTap!(q);
              }
            : null,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpace.sm,
            horizontal: AppSpace.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CinematicIcon(
                glyph: CinematicGlyphResolver.forQuest(q.id),
                size: AppMetrics.leadingIcon,
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
                        size: 14,
                        color: done ? a.textFaint : a.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      done ? context.l10n.questDone : q.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        size: 12,
                        weight: FontWeight.w700,
                        color: done ? tone : a.textFaint,
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
