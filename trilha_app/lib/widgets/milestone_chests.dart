import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/daily_quest.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'relic_panel.dart';
import 'stage_plate.dart';
import 'ui_primitives.dart';

class MilestoneChestsCard extends StatelessWidget {
  final String trailSlug;
  final int done;
  final int total;
  final Color? accent;

  const MilestoneChestsCard({
    super.key,
    required this.trailSlug,
    required this.done,
    required this.total,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);
    final pct = total > 0 ? (done / total * 100) : 0.0;

    final mark = accent ?? AppColors.accent;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.section),
      child: StagePlate(
        accent: mark,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StageEyebrow(label: 'Baús de progresso', accent: mark),
            const SizedBox(height: AppSpace.xs),
            Text(
              'Recompensas ao avançar na trilha',
              style: AppTypography.body(size: 11, color: a.textMuted(0.55)),
            ),
            const SizedBox(height: 14),
            Row(
              children: TrailMilestone.all.map((m) {
                final unlocked = pct >= m.percent;
                final claimed = progress.isChestClaimed(m.chestId(trailSlug));
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _ChestTile(
                      milestone: m,
                      unlocked: unlocked,
                      claimed: claimed,
                      onTap: unlocked && !claimed
                          ? () => _openChest(context, progress, m)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openChest(
    BuildContext context,
    ProgressService progress,
    TrailMilestone m,
  ) async {
    HapticFeedback.mediumImpact();
    final ok = await progress.claimChest(m.chestId(trailSlug), m.stepsReward);
    if (!ok || !context.mounted) return;
    SoundService.instance.playStreak();
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => _ChestOpenDialog(milestone: m),
    );
  }
}

class _ChestTile extends StatelessWidget {
  final TrailMilestone milestone;
  final bool unlocked;
  final bool claimed;
  final VoidCallback? onTap;

  const _ChestTile({
    required this.milestone,
    required this.unlocked,
    required this.claimed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final glow = unlocked && !claimed;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.md),
          gradient: glow
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.accent.withValues(alpha: 0.35),
                    AppColors.accent.withValues(alpha: 0.08),
                  ],
                )
              : null,
          color: glow
              ? null
              : Colors.white.withValues(alpha: claimed ? 0.04 : 0.06),
          border: Border.all(
            color: claimed
                ? AppColors.teal.withValues(alpha: 0.45)
                : glow
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.12),
          ),
          boxShadow: glow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            CinematicIcon(
              glyph: claimed
                  ? CinematicGlyph.gem
                  : unlocked
                  ? CinematicGlyph.crown
                  : CinematicGlyph.lock,
              size: 26,
              accent: claimed
                  ? AppColors.teal
                  : unlocked
                  ? AppColors.accent
                  : Colors.white38,
            ),
            const SizedBox(height: 6),
            Text(
              '${milestone.percent}%',
              style: AppTypography.label(
                size: 11,
                weight: FontWeight.w900,
                color: Colors.white.withValues(alpha: unlocked ? 0.95 : 0.4),
              ),
            ),
            Text(
              claimed
                  ? 'Aberto'
                  : unlocked
                  ? 'Abrir'
                  : 'Trancado',
              style: AppTypography.label(
                size: 9,
                weight: FontWeight.w700,
                color: AppColors.textOnDark.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChestOpenDialog extends StatelessWidget {
  final TrailMilestone milestone;

  const _ChestOpenDialog({required this.milestone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.nightElevated, AppColors.night],
          ),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
          boxShadow: AppMetrics.cardShadow(elevated: true),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.gold,
              ),
              child: const CinematicIcon(
                glyph: CinematicGlyph.gift,
                size: 36,
                accent: AppColors.inkOnAccent,
                framed: false,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              milestone.title,
              textAlign: TextAlign.center,
              style: AppTypography.title(
                size: 22,
                weight: FontWeight.w900,
                color: AppColors.textOnDark,
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              milestone.subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 13,
                color: AppColors.textOnDark.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppGradients.gold,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                '+${milestone.stepsReward} passos',
                style: AppTypography.title(
                  size: 16,
                  weight: FontWeight.w900,
                  color: AppColors.inkOnAccent,
                ),
              ),
            ),
            const SizedBox(height: AppSpace.screen),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Continuar',
                style: AppTypography.title(
                  color: AppColors.textOnDark,
                  weight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyQuestsCard extends StatelessWidget {
  const WeeklyQuestsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();

    return RelicPanel(
      accent: AppColors.primaryLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RelicChapter(
            title: 'Passos da semana',
            accent: AppColors.primaryLight,
            trailing: Text(
              '${progress.weeklyQuestsCompleted} de ${WeeklyQuestDefs.all.length}',
              style: AppTypography.label(
                size: 10,
                letterSpacing: 1.1,
                color: Appearance.of(context).textMuted(0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < WeeklyQuestDefs.all.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(height: 12),
              const RelicHairline(accent: AppColors.primaryLight),
              const SizedBox(height: 12),
            ],
            _WeeklyQuestRow(
              quest: WeeklyQuestDefs.all[i],
              progress: progress,
            ),
          ],
        ],
      ),
    );
  }
}

class _WeeklyQuestRow extends StatelessWidget {
  final DailyQuest quest;
  final ProgressService progress;

  const _WeeklyQuestRow({required this.quest, required this.progress});

  static const _rewardSlot = 56.0;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final value = progress.weeklyQuestProgress(quest.id);
    final claimed = progress.isWeeklyQuestClaimed(quest.id);
    final done = claimed || value >= quest.target;
    final pct = (value / quest.target).clamp(0.0, 1.0);
    final tone = claimed
        ? AppColors.teal
        : CinematicGlyphResolver.accentForQuest(quest.id);
    final bar = claimed ? AppColors.teal : AppColors.accent;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RelicDisc(
          glyph: CinematicGlyphResolver.forQuest(quest.id),
          accent: tone,
          size: 44,
          lit: true,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quest.title,
                style:
                    AppTypography.title(
                      size: 14,
                      weight: FontWeight.w800,
                      color: a.text.withValues(alpha: claimed ? 0.45 : 0.95),
                    ).copyWith(
                      decoration: claimed ? TextDecoration.lineThrough : null,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                '${value.clamp(0, quest.target)} de ${quest.target} · ${quest.subtitle}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body(size: 12, color: a.textMuted(0.5)),
              ),
              const SizedBox(height: 8),
              RelicProgress(value: pct, accent: bar),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: _rewardSlot,
          child: Align(
            alignment: Alignment.centerRight,
            child: done
                ? Text(
                    'feito',
                    style: AppTypography.label(
                      size: 10,
                      letterSpacing: 1.2,
                      color: AppColors.teal.withValues(alpha: 0.85),
                    ),
                  )
                : Text(
                    '+${quest.stepsReward}',
                    style: AppTypography.label(
                      size: 11,
                      letterSpacing: 0.8,
                      color: tone,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
