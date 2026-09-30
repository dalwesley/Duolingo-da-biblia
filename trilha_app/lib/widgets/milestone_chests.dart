import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_quest.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'relic_panel.dart';
import 'ui_primitives.dart';
import '../l10n/app_language.dart';

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

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(context.l10n.chestRewards),
          const SizedBox(height: 12),
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

  Future<void> _openChest(
    BuildContext context,
    ProgressService progress,
    TrailMilestone m,
  ) async {
    ActHaptics.confirm();
    final ok = await progress.claimChest(m.chestId(trailSlug), m.stepsReward);
    if (!ok || !context.mounted) return;
    SoundService.instance.playStreak();
    // A sheet abre no Navigator do app, acima do Appearance da tela: leva a
    // aparência atual junto para não cair no automático.
    final scope = context.getInheritedWidgetOfExactType<Appearance>();
    await showAppSheet<void>(
      context,
      builder: (ctx) {
        final sheet = _ChestOpenSheet(milestone: m);
        if (scope == null) return sheet;
        return Appearance(mode: scope.mode, style: scope.style, child: sheet);
      },
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
    final a = Appearance.of(context);
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
                    AppRoles.reward.withValues(alpha: 0.35),
                    AppRoles.reward.withValues(alpha: 0.08),
                  ],
                )
              : null,
          color: glow ? null : a.insetFill,
          border: Border.all(
            color: claimed
                ? AppRoles.success.withValues(alpha: 0.45)
                : glow
                ? AppRoles.reward
                : a.cardBorder,
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
              size: AppMetrics.iconLg,
              accent: claimed
                  ? AppRoles.success
                  : unlocked
                  ? AppRoles.reward
                  : a.textFaint,
            ),
            const SizedBox(height: 6),
            Text(
              '${milestone.percent}%',
              style: AppTypography.label(
                size: 11,
                weight: FontWeight.w900,
                color: unlocked ? a.text : a.textFaint,
              ),
            ),
            Text(
              claimed
                  ? context.l10n.chestOpened
                  : unlocked
                  ? context.l10n.chestOpenShort
                  : context.l10n.chestLockedShort,
              style: AppTypography.label(
                size: 10,
                weight: FontWeight.w700,
                color: a.textFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Baú aberto — recompensa: sheet padrão com o tom da recompensa.
class _ChestOpenSheet extends StatelessWidget {
  final TrailMilestone milestone;

  const _ChestOpenSheet({required this.milestone});

  @override
  Widget build(BuildContext context) {
    return AppSheetPanel(
      tint: AppRoles.reward,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSheetHeader(
            center: true,
            leading: const CinematicIcon(
              glyph: CinematicGlyph.gift,
              size: AppMetrics.iconHero,
              accent: AppRoles.reward,
              glowing: true,
            ),
            title: milestone.title,
            subtitle: milestone.subtitle,
          ),
          const SizedBox(height: 18),
          SoftBadge(
            text: context.l10n.commonPlusSteps(milestone.stepsReward),
            solid: true,
          ),
          const SizedBox(height: AppSpace.screen),
          CopperCta(
            label: context.l10n.commonContinue,
            dense: true,
            trailing: null,
            onTap: () => Navigator.pop(context),
          ),
        ],
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
      accent: AppRoles.chrome,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RelicChapter(
            title: context.l10n.questWeeklyTitle,
            accent: AppRoles.chrome,
            divided: false,
            trailing: Text(
              context.l10n.questCountOf(
                progress.weeklyQuestsCompleted,
                WeeklyQuestDefs.all.length,
              ),
              style: AppTypography.label(
                size: 10,
                letterSpacing: 1.1,
                color: Appearance.of(context).textFaint,
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < WeeklyQuestDefs.all.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(height: 12),
              const RelicHairline(accent: AppRoles.chrome),
              const SizedBox(height: 12),
            ],
            _WeeklyQuestRow(quest: WeeklyQuestDefs.all[i], progress: progress),
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
    // Ícone e barra = chrome; concluída = sucesso; passos = recompensa.
    final tone = claimed ? AppRoles.success : AppRoles.chrome;
    final bar = tone;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CinematicIcon(
          glyph: CinematicGlyphResolver.forQuest(quest.id),
          accent: tone,
          size: AppMetrics.leadingIcon,
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
                      color: claimed ? a.textFaint : a.text,
                    ).copyWith(
                      decoration: claimed ? TextDecoration.lineThrough : null,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.questProgressLine(
                  value.clamp(0, quest.target),
                  quest.target,
                  quest.subtitle,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body(size: 12, color: a.textFaint),
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
                    context.l10n.questDoneLower,
                    style: AppTypography.label(
                      size: 10,
                      letterSpacing: 1.2,
                      color: AppRoles.success.withValues(alpha: 0.85),
                    ),
                  )
                : Text(
                    '+${quest.stepsReward}',
                    style: AppTypography.label(
                      size: 11,
                      letterSpacing: 0.8,
                      color: AppRoles.reward,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
