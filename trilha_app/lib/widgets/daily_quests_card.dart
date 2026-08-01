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

enum _QuestDest { mission, bible, memory }

class _QuestGroupMeta {
  final _QuestDest dest;
  final String label;
  final String hint;
  final Color accent;
  /// Header abre o destino (Bíblia / Memorizar). Missões = só checklist.
  final bool headerOpensDest;

  const _QuestGroupMeta({
    required this.dest,
    required this.label,
    required this.hint,
    required this.accent,
    this.headerOpensDest = true,
  });
}

/// Bônus diários — mesmo padrão GlassCard + CardHeader das outras abas.
class DailyQuestsCard extends StatelessWidget {
  final void Function(DailyQuest quest)? onQuestTap;

  const DailyQuestsCard({super.key, this.onQuestTap});

  static _QuestDest _destFor(String id) {
    return switch (id) {
      'read' || 'bookmark' || 'seasonal' => _QuestDest.bible,
      'memory' => _QuestDest.memory,
      _ => _QuestDest.mission,
    };
  }

  static const _groups = <_QuestGroupMeta>[
    _QuestGroupMeta(
      dest: _QuestDest.mission,
      label: 'Bônus na trilha',
      hint: '+passos extras ao caminhar',
      accent: AppColors.accent,
      headerOpensDest: false,
    ),
    _QuestGroupMeta(
      dest: _QuestDest.bible,
      label: 'Bíblia',
      hint: 'Abre a Bíblia',
      accent: AppColors.cedar,
    ),
    _QuestGroupMeta(
      dest: _QuestDest.memory,
      label: 'Memorizar',
      hint: 'Abre memorizar',
      accent: AppColors.clay,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final quests = DailyQuestDefs.all;

    final byDest = <_QuestDest, List<DailyQuest>>{
      for (final g in _groups) g.dest: [],
    };
    for (final q in quests) {
      byDest[_destFor(q.id)]!.add(q);
    }

    final visible = _groups.where((g) => byDest[g.dest]!.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpace.section),
          _QuestGroupPanel(
            meta: visible[i],
            quests: byDest[visible[i].dest]!,
            progress: progress,
            onQuestTap: onQuestTap,
          ),
        ],
      ],
    );
  }
}

class _QuestGroupPanel extends StatelessWidget {
  final _QuestGroupMeta meta;
  final List<DailyQuest> quests;
  final ProgressService progress;
  final void Function(DailyQuest quest)? onQuestTap;

  const _QuestGroupPanel({
    required this.meta,
    required this.quests,
    required this.progress,
    this.onQuestTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    DailyQuest? next;
    for (final q in quests) {
      if (!progress.isQuestClaimed(q.id) &&
          progress.questProgress(q.id) < q.target) {
        next = q;
        break;
      }
    }
    next ??= quests.isEmpty ? null : quests.first;
    final openQuest = next;
    final canOpenHeader =
        meta.headerOpensDest && onQuestTap != null && openQuest != null;

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
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canOpenHeader
                  ? () {
                      HapticFeedback.selectionClick();
                      onQuestTap!(openQuest);
                    }
                  : null,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meta.label,
                          style: AppTypography.title(size: 14, color: a.text),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meta.headerOpensDest
                              ? meta.hint
                              : '$doneCount/${quests.length} · ${meta.hint}',
                          style: AppTypography.body(
                            size: 12,
                            color: a.textMuted(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (canOpenHeader)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: a.textMuted(0.45),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Divider(
            height: 1,
            thickness: 1,
            color: a.cardBorder.withValues(alpha: 0.45),
          ),
          const SizedBox(height: AppSpace.sm),
          for (var i = 0; i < quests.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpace.xs),
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

  const _QuestRow({
    required this.quest,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final q = quest;
    final value = progress.questProgress(q.id);
    final claimed = progress.isQuestClaimed(q.id);
    final done = claimed || value >= q.target;
    final pct = (value / q.target).clamp(0.0, 1.0);
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
          padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
          child: Row(
            children: [
              CinematicIcon(
                glyph: CinematicGlyphResolver.forQuest(q.id),
                size: AppMetrics.leadingIcon,
                accent: tone,
                glowing: false,
              ),
              const SizedBox(width: AppSpace.sm + 2),
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
                      claimed
                          ? 'Concluída'
                          : '${value.clamp(0, q.target)}/${q.target} · ${q.subtitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        size: 11,
                        color: a.textMuted(0.5),
                      ),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    AppProgressBar(
                      value: pct,
                      height: AppMetrics.progressHeight,
                      color: tone,
                      trackColor: tone.withValues(alpha: 0.14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              if (done)
                CinematicIcon(
                  glyph: CinematicGlyph.check,
                  size: 20,
                  accent: tone,
                  framed: false,
                )
              else
                CountBadge(
                  '+${q.stepsReward}',
                  filled: true,
                  color: tone,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
