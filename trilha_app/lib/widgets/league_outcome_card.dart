import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_language.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../services/room_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'confetti_overlay.dart';
import 'ui_primitives.dart';
import 'medal_art.dart';

/// Subida de nível da caravana — mora na Home até coletar.
class LeagueOutcomeCard extends StatelessWidget {
  const LeagueOutcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final league = context.watch<LeagueService>();
    final outcome = league.pendingOutcome;
    if (outcome == null) return const SizedBox.shrink();

    return _PromotionBanner(
      tierLabel: league.tier.label,
      bonusSteps: LeagueService.promotionBonusXp,
      onCollect: () => _claim(context, league),
    );
  }

  static Future<void> _claim(BuildContext context, LeagueService league) async {
    await showLeaguePromotionSheet(
      context,
      tierLabel: league.tier.label,
      bonusSteps: LeagueService.promotionBonusXp,
    );
    if (!context.mounted) return;
    await context.read<ProgressService>().grantBonusSteps(
      LeagueService.promotionBonusXp,
    );

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

/// Banner de promoção — medalha dourada + confete, sem poço preto.
class _PromotionBanner extends StatefulWidget {
  final String tierLabel;
  final int bonusSteps;
  final VoidCallback onCollect;

  const _PromotionBanner({
    required this.tierLabel,
    required this.bonusSteps,
    required this.onCollect,
  });

  @override
  State<_PromotionBanner> createState() => _PromotionBannerState();
}

class _PromotionBannerState extends State<_PromotionBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathe;

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rankLine = l10n.leaguePromotedLevelOnly(widget.tierLabel);

    // Só a medalha respira; o cartão (gradientes, confete, textos) não é
    // reconstruído a cada frame.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.dropShadow,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: AppGradients.gold),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppRoles.chrome.withValues(alpha: 0.06),
                        Colors.transparent,
                        AppRoles.onReward.withValues(alpha: 0.16),
                      ],
                      stops: const [0, 0.42, 1],
                    ),
                  ),
                ),
              ),
            ),
            const Positioned.fill(child: ConfettiOverlay(active: true)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
              child: Row(
                children: [
                  RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _breathe,
                      builder: (context, _) => _PromotionMedal(
                        pulse: AppMotion.move.transform(_breathe.value),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.leaguePromotedTitle(widget.tierLabel),
                          style: AppTypography.title(
                            size: 16,
                            color: AppRoles.onReward,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          rankLine,
                          style: AppTypography.body(
                            size: 12,
                            height: 1.35,
                            weight: FontWeight.w700,
                            color: AppColors.medalInk.withValues(alpha: 0.88),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _BonusChip(steps: widget.bonusSteps),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CollectButton(
                    label: l10n.commonCollect,
                    onDarkGold: true,
                    onTap: widget.onCollect,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionMedal extends StatelessWidget {
  final double pulse;

  const _PromotionMedal({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.0 + pulse * 0.05,
      child: SizedBox(
        width: 52,
        height: 52,
        child: const MedalArt(
          metal: AppColors.accent,
          size: 50,
          glyph: CinematicGlyph.crown,
        ),
      ),
    );
  }
}

class _BonusChip extends StatelessWidget {
  final int steps;

  const _BonusChip({required this.steps});

  @override
  Widget build(BuildContext context) {
    return SoftBadge(
      text: context.l10n.commonPlusSteps(steps),
      accent: AppRoles.onReward,
      textColor: AppRoles.onReward,
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
    // Sobre o banner dourado, o fantasma escuro faz contraste; no card
    // neutro, o mesmo CTA secundário.
    return IntrinsicWidth(
      child: GhostCta(
        label: label,
        padding: EdgeInsets.symmetric(
          horizontal: onDarkGold ? 14 : 12,
          vertical: 10,
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Celebração cinematográfica ao subir de caravana — confete igual ao fim de passo.
Future<void> showLeaguePromotionSheet(
  BuildContext context, {
  required String tierLabel,
  required int bonusSteps,
}) {
  ActHaptics.success();
  return showAppSheet<void>(
    context,
    builder: (ctx) =>
        _LeaguePromotionSheet(tierLabel: tierLabel, bonusSteps: bonusSteps),
  );
}

class _LeaguePromotionSheet extends StatelessWidget {
  final String tierLabel;
  final int bonusSteps;

  const _LeaguePromotionSheet({
    required this.tierLabel,
    required this.bonusSteps,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return AppSheetPanel(
      tint: AppRoles.reward,
      padding: const EdgeInsets.fromLTRB(
        AppSpace.xxl,
        AppSpace.md,
        AppSpace.xxl,
        AppSpace.screen,
      ),
      background: Stack(
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
                      AppRoles.reward.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpace.md),
          const Center(child: CloudMascot(face: CloudFace.sucesso, size: 120)),
          const SizedBox(height: 20),
          AppSheetHeader(
            cloud: false,
            title: l10n.leagueLevelUpTitle,
            center: true,
            celebration: true,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.leagueLevelUpBodyOnly(tierLabel),
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              height: 1.45,
              color: a.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          InsetPanel(
            borderColor: AppRoles.reward.withValues(alpha: 0.45),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.lg,
              vertical: AppSpace.md,
            ),
            child: Text(
              l10n.leagueBonusEncourage(bonusSteps),
              textAlign: TextAlign.center,
              style: AppTypography.title(size: 14, color: AppRoles.reward),
            ),
          ),
          const SizedBox(height: 28),
          CopperCta(
            label: l10n.commonContinue,
            onTap: () => Navigator.pop(context),
            trailing: null,
            dense: true,
          ),
        ],
      ),
    );
  }
}
