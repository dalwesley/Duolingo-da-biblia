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
import 'ui_primitives.dart';

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
    final a = Appearance.of(context);
    final pct = total > 0 ? (done / total * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.section),
      child: GlassCard(
        padding: AppMetrics.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CardHeader(label: 'Baús da jornada'),
            const SizedBox(height: AppSpace.xs),
            Text(
              'Recompensas ao avançar na trilha',
              style: AppTypography.body(
                size: 11,
                color: a.textMuted(0.55),
              ),
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
          borderRadius: BorderRadius.circular(AppRadii.md),
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
              framed: false,
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
              claimed ? 'Aberto' : unlocked ? 'Abrir' : 'Trancado',
              style: AppTypography.label(
                size: 9,
                weight: FontWeight.w700,
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
          borderRadius: BorderRadius.circular(AppRadii.xl),
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
              style: AppTypography.title(
                size: 22,
                weight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              milestone.subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 13,
                color: Colors.white.withValues(alpha: 0.65),
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
                  color: Colors.white,
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
    final a = Appearance.of(context);

    return GlassCard(
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            label: 'Passos da semana',
            trailing: CountBadge(
              '${progress.weeklyQuestsCompleted}/${WeeklyQuestDefs.all.length}',
            ),
          ),
          const SizedBox(height: 12),
          ...WeeklyQuestDefs.all.map((q) {
            final value = progress.weeklyQuestProgress(q.id);
            final claimed = progress.isWeeklyQuestClaimed(q.id);
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
                          style: AppTypography.title(
                            size: 13,
                            weight: FontWeight.w800,
                            color: a.text.withValues(alpha: claimed ? 0.45 : 0.95),
                          ).copyWith(
                            decoration: claimed ? TextDecoration.lineThrough : null,
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
                          color: claimed ? AppColors.teal : AppColors.primaryLight,
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
