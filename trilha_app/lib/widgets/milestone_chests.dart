import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/daily_quest.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';

class MilestoneChestsCard extends StatelessWidget {
  final String trailSlug;
  final int done;
  final int total;

  const MilestoneChestsCard({
    super.key,
    required this.trailSlug,
    required this.done,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final pct = total > 0 ? (done / total * 100) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Baús da jornada',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Recompensas ao avançar na trilha',
            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
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
    );
  }

  Future<void> _openChest(BuildContext context, ProgressService progress, TrailMilestone m) async {
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
          borderRadius: BorderRadius.circular(16),
          gradient: glow
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.accent.withValues(alpha: 0.35), AppColors.accent.withValues(alpha: 0.08)],
                )
              : null,
          color: glow ? null : Colors.white.withValues(alpha: claimed ? 0.04 : 0.06),
          border: Border.all(
            color: claimed
                ? AppColors.teal.withValues(alpha: 0.45)
                : glow
                    ? AppColors.accent
                    : Colors.white.withValues(alpha: 0.12),
          ),
          boxShadow: glow
              ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 14)]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              claimed
                  ? Icons.inventory_2_rounded
                  : unlocked
                      ? Icons.card_giftcard_rounded
                      : Icons.lock_rounded,
              color: claimed
                  ? AppColors.teal
                  : unlocked
                      ? AppColors.accent
                      : Colors.white38,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              '${milestone.percent}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: unlocked ? 0.95 : 0.4),
              ),
            ),
            Text(
              claimed ? 'Aberto' : unlocked ? 'Abrir' : 'Trancado',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.45),
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
            colors: [Color(0xFF28332C), Color(0xFF121816)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
          boxShadow: AppTheme.glow(AppColors.accent, blur: 28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppGradients.gold),
              child: const Icon(Icons.card_giftcard_rounded, size: 36, color: AppColors.inkOnAccent),
            ),
            const SizedBox(height: 18),
            Text(
              milestone.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              milestone.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.65)),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppGradients.gold,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '+${milestone.stepsReward} passos',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.inkOnAccent),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continuar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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
    final a = Appearance.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PASSOS DA SEMANA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                  color: AppColors.accent.withValues(alpha: 0.9),
                ),
              ),
              const Spacer(),
              Text(
                '${progress.weeklyQuestsCompleted}/${WeeklyQuestDefs.all.length}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: a.textMuted(0.5)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...WeeklyQuestDefs.all.map((q) {
            final value = progress.weeklyQuestProgress(q.id);
            final done = progress.isWeeklyQuestClaimed(q.id) || value >= q.target;
            final claimed = progress.isWeeklyQuestClaimed(q.id);
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
                            color: a.onDark ? Colors.white.withValues(alpha: done ? 0.55 : 1) : a.text.withValues(alpha: done ? 0.55 : 1),
                            decoration: claimed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(q.subtitle, style: TextStyle(fontSize: 11, color: a.textMuted(0.5))),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 5,
                            backgroundColor: a.progressTrack,
                            color: claimed ? AppColors.accent : AppColors.primaryLight,
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
                      onTap: () => progress.claimWeeklyQuest(q.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppGradients.gold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${q.stepsReward}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.inkOnAccent),
                        ),
                      ),
                    )
                  else
                    Text(
                      '$value/${q.target}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: a.textMuted(0.45)),
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
