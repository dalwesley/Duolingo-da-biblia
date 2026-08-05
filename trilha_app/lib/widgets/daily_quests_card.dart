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

  bool _isDone(DailyQuest q) =>
      progress.isQuestClaimed(q.id) ||
      progress.questProgress(q.id) >= q.target;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);

    // Pendentes sobem — o que ainda dá passos fica acima da dobra.
    final ordered = [...quests]
      ..sort((a, b) {
        final da = _isDone(a);
        final db = _isDone(b);
        if (da == db) return 0;
        return da ? 1 : -1;
      });

    DailyQuest? next;
    for (final q in ordered) {
      if (!_isDone(q)) {
        next = q;
        break;
      }
    }
    next ??= ordered.isEmpty ? null : ordered.first;
    final openQuest = next;
    final canOpenHeader =
        meta.headerOpensDest && onQuestTap != null && openQuest != null;

    final doneCount = quests.where(_isDone).length;
    final allDone = doneCount == quests.length && quests.isNotEmpty;

    final subtitle = meta.headerOpensDest
        ? meta.hint
        : allDone
        ? 'Tudo feito · ${meta.hint}'
        : '$doneCount/${quests.length} · ${meta.hint}';

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
                          subtitle,
                          style: AppTypography.body(
                            size: 12,
                            color: allDone
                                ? meta.accent.withValues(alpha: 0.85)
                                : a.textMuted(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (allDone)
                    CinematicIcon(
                      glyph: CinematicGlyph.check,
                      size: 22,
                      accent: meta.accent,
                      framed: false,
                    )
                  else if (canOpenHeader)
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
          const SizedBox(height: AppSpace.xs),
          for (var i = 0; i < ordered.length; i++) ...[
            if (i > 0) const SizedBox(height: 2),
            _QuestRow(
              quest: ordered[i],
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
    final pct = done ? 1.0 : (value / q.target).clamp(0.0, 1.0);
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
                        color: a.text.withValues(alpha: 0.98),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      done
                          ? 'Concluída'
                          : '${value.clamp(0, q.target)}/${q.target} · ${q.subtitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        size: 12,
                        weight: FontWeight.w700,
                        color: done ? tone : a.textMuted(0.55),
                      ),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    AppProgressBar(
                      value: pct,
                      height: 10,
                      color: tone,
                      trackColor: tone.withValues(alpha: 0.18),
                      depthColor: done
                          ? Color.lerp(tone, Colors.black, 0.18)!
                          : null,
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
