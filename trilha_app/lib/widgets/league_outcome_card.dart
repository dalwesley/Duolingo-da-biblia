import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../services/room_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'confetti_overlay.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Resultado da semana da caravana — mora na Home até coletar / dispensar.
class LeagueOutcomeCard extends StatelessWidget {
  const LeagueOutcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final league = context.watch<LeagueService>();
    final outcome = league.pendingOutcome;
    if (outcome == null) return const SizedBox.shrink();

    final a = Appearance.of(context);
    final promoted = outcome == LeagueOutcome.promoted;
    final (title, message) = switch (outcome) {
      LeagueOutcome.promoted => (
        'Você avançou de caravana',
        'Ficou em ${league.pendingRank}º · agora caminha na ${league.tier.label}. +${LeagueService.promotionBonusXp} passos te esperam.',
      ),
      LeagueOutcome.stayed => (
        'Semana da caravana encerrada',
        'Você ficou em ${league.pendingRank}º na ${league.tier.label}. Nova semana — continue caminhando.',
      ),
      LeagueOutcome.demoted => (
        'Você desceu de caravana',
        'Ficou em ${league.pendingRank}º. Na ${league.tier.label} dá para subir de novo.',
      ),
    };

    final content = Row(
      children: [
        CinematicIcon(
          glyph: promoted
              ? CinematicGlyph.crown
              : outcome == LeagueOutcome.demoted
                  ? CinematicGlyph.demote
                  : CinematicGlyph.path,
          size: 40,
          accent: promoted ? AppColors.inkOnAccent : AppColors.accent,
          glowing: false,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.title(
                  size: 15,
                  weight: FontWeight.w900,
                  color: promoted ? AppColors.inkOnAccent : a.text,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                message,
                style: AppTypography.body(
                  size: 12,
                  height: 1.35,
                  weight: FontWeight.w600,
                  color: promoted
                      ? AppColors.medalInk.withValues(alpha: 0.85)
                      : a.textMuted(0.72),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _CollectButton(
          label: promoted ? 'Coletar' : 'Ok',
          onDarkGold: promoted,
          onTap: () => _claim(context, league, outcome),
        ),
      ],
    );

    if (promoted) {
      return Container(
        padding: AppMetrics.cardPadding,
        decoration: BoxDecoration(
          gradient: AppGradients.gold,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: a.cardBorder),
          boxShadow: AppTheme.cardShadow(elevated: true),
        ),
        child: content,
      );
    }

    return GlassCard(padding: AppMetrics.cardPadding, child: content);
  }

  static Future<void> _claim(
    BuildContext context,
    LeagueService league,
    LeagueOutcome outcome,
  ) async {
    HapticFeedback.mediumImpact();

    if (outcome == LeagueOutcome.promoted) {
      await showLeaguePromotionSheet(
        context,
        tierLabel: league.tier.label,
        rank: league.pendingRank,
        bonusSteps: LeagueService.promotionBonusXp,
      );
      if (!context.mounted) return;
      await context.read<ProgressService>().grantBonusSteps(
        LeagueService.promotionBonusXp,
      );
    }

    await league.dismissOutcome();
    if (!context.mounted) return;

    final progress = context.read<ProgressService>();
    final backend = context.read<BackendService>();
    final rooms = context.read<RoomService>();
    await backend.saveNow(
      progress,
      LeagueService.weekKey(),
      roomCode: rooms.activeCode,
      league: league,
    );
  }
}

class _CollectButton extends StatelessWidget {
  final String label;
  final bool onDarkGold;
  final VoidCallback onTap;

  const _CollectButton({
    required this.label,
    required this.onDarkGold,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            label.toUpperCase(),
            style: AppTypography.cta(
              size: 13,
              color: onDarkGold ? AppColors.inkOnAccent : AppColors.accent,
            ),
          ),
        ),
      ),
    );
  }
}

/// Celebração cinematográfica ao subir de caravana — confete igual ao fim de passo.
Future<void> showLeaguePromotionSheet(
  BuildContext context, {
  required String tierLabel,
  required int rank,
  required int bonusSteps,
}) {
  HapticFeedback.heavyImpact();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _LeaguePromotionSheet(
      tierLabel: tierLabel,
      rank: rank,
      bonusSteps: bonusSteps,
    ),
  );
}

class _LeaguePromotionSheet extends StatelessWidget {
  final String tierLabel;
  final int rank;
  final int bonusSteps;

  const _LeaguePromotionSheet({
    required this.tierLabel,
    required this.rank,
    required this.bonusSteps,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpace.md,
        0,
        AppSpace.md,
        AppSpace.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.night,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(
            child: ConfettiOverlay(active: true, cinematic: true),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.35),
                    radius: 1.1,
                    colors: [
                      AppColors.accent.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpace.xxl,
              AppSpace.screen + 8,
              AppSpace.xxl,
              AppSpace.screen + bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Center(
                  child: CinematicIcon(
                    glyph: CinematicGlyph.crown,
                    size: 56,
                    accent: AppColors.accent,
                    glowing: true,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Caravana avançou',
                  textAlign: TextAlign.center,
                  style: AppTypography.display(
                    size: 28,
                    weight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  rank > 0
                      ? 'Ficou em $rankº · agora caminha na\n$tierLabel'
                      : 'Agora você caminha na\n$tierLabel',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    size: 14,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.lg,
                    vertical: AppSpace.md,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    color: AppColors.accent.withValues(alpha: 0.14),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    '+$bonusSteps passos de encorajamento',
                    textAlign: TextAlign.center,
                    style: AppTypography.title(
                      size: 14,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      gradient: AppGradients.gold,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      'CONTINUAR',
                      textAlign: TextAlign.center,
                      style: AppTypography.cta(size: 13)
                          .copyWith(letterSpacing: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
