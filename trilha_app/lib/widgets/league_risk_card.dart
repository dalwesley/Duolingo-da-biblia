import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Urgência da caravana na home — zona de descida / dias restantes.
class LeagueRiskCard extends StatelessWidget {
  final VoidCallback? onOpenLeague;

  const LeagueRiskCard({super.key, this.onOpenLeague});

  @override
  Widget build(BuildContext context) {
    final league = context.watch<LeagueService>();
    final progress = context.watch<ProgressService>();
    if (!league.isLoaded) return const SizedBox.shrink();

    final entries = league.standings(
      userName: progress.userName,
      userWeeklySteps: progress.weeklySteps,
    );
    final rank = league.userRank(entries);
    if (!league.isNearDemotion(rank)) return const SizedBox.shrink();

    final a = Appearance.of(context);
    final days = LeagueService.daysLeft();
    final inZone = league.isInDemotionZone(rank);
    final closes = days <= 1 ? 'Fecha hoje' : '$days dias';
    final tier = league.tier.shortLabel;

    return GlassCard(
      onTap: onOpenLeague,
      elevated: inZone,
      padding: AppMetrics.cardPadding,
      child: Row(
        children: [
          CinematicIcon(
            glyph: inZone ? CinematicGlyph.demote : CinematicGlyph.rise,
            size: 40,
            accent: inZone ? AppColors.error : AppColors.accent,
            glowing: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inZone
                      ? 'Zona de descida · $closes'
                      : 'Perto da descida · $closes',
                  style: AppTypography.title(size: 14, color: a.text),
                ),
                const SizedBox(height: 2),
                Text(
                  inZone
                      ? 'Você está em $rankº na $tier. Um passo pode segurar o lugar.'
                      : 'Você está em $rankº na $tier. A caravana fecha em breve.',
                  style: AppTypography.body(
                    size: 12,
                    height: 1.35,
                    weight: FontWeight.w600,
                    color: a.textMuted(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: a.textMuted(0.45),
          ),
        ],
      ),
    );
  }
}
