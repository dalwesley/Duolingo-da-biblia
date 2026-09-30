import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/backend_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'immersive_background.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../utils/liturgical_calendar.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'streak_week.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';
import '../l10n/app_language.dart';

/// Saudação do dia — cartão de jogador: identidade + pulso + meta.
///
/// Lâmpadas ficam na cena. Aqui: sequência, meta, gelo, passos e a semana.
/// O CTA da missão vive só no hero — o header não duplica o toque.
class HomePlayerHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;

  /// Mantido por compatibilidade: o pulso não abre mais a missão
  /// (duplicava o CTA do hero).
  final VoidCallback? onTapMission;
  final VoidCallback? onLiturgyTap;

  const HomePlayerHeader({
    super.key,
    this.onProfileTap,
    this.onTapMission,
    this.onLiturgyTap,
  });

  @override
  Widget build(BuildContext context) {
    // Só os campos do cabeçalho: cada resposta notifica o serviço inteiro.
    final p = context.select(
      (ProgressService p) => (
        goal: p.settings.dailyGoal,
        today: p.missionsToday,
        atRisk: p.isStreakAtRisk,
        goalMet: p.dailyGoalMet,
        userName: p.userName,
        streak: p.streak,
        freezeUsed: p.streakFreezeUsedThisWeek,
        freezeAvailable: p.streakFreezeAvailable,
        portraitStyle: p.settings.portraitStyle,
        steps: p.steps,
      ),
    );
    final b = context.select(
      (BackendService b) => (photoUrl: b.userPhotoUrl, uid: b.uid),
    );
    final a = Appearance.of(context);
    final goal = p.goal;
    final done = p.today.clamp(0, goal);
    final atRisk = p.atRisk;
    final goalMet = p.goalMet;
    final left = (goal - done).clamp(0, goal);
    final l10n = context.l10n;
    final name = p.userName.trim().isEmpty
        ? l10n.homeDefaultName
        : p.userName.trim().split(' ').first;
    final moment = LiturgicalCalendar.momentFor();
    final liturgy = LiturgicalCalendar.accentOf(moment.season);
    final streak = p.streak;
    final freezeUsed = p.freezeUsed;
    final freezeCount = freezeUsed || p.freezeAvailable ? 1 : 0;
    final goalFill = goal <= 0 ? 0.0 : done / goal;
    final barColor = goalMet
        ? AppRoles.reward
        : (atRisk ? AppRoles.streak : AppRoles.presence);

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      tint: atRisk ? AppRoles.risk : null,
      glow: goalMet ? 0.45 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  button: onProfileTap != null,
                  label:
                      onProfileTap != null ? l10n.homeOpenProfile(name) : null,
                  child: GestureDetector(
                    onTap: () {
                      if (onProfileTap == null) return;
                      ActHaptics.tap();
                      onProfileTap!();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Row(
                        children: [
                          UserAvatar(
                            name: p.userName,
                            photoUrl: b.photoUrl,
                            seed: b.uid,
                            style: p.portraitStyle,
                            radius: AppMetrics.avatarMd,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DayPhaseHelper.greeting(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.body(
                                    size: 12,
                                    weight: FontWeight.w600,
                                    color: a.textSecondary,
                                  ),
                                ),
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.display(
                                    size: 18,
                                    color: a.text,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Semantics(
                label: l10n.homeStepsSemantics(p.steps),
                child: CountBadge('${p.steps}', color: AppRoles.reward),
              ),
              if (onLiturgyTap != null)
                _SeasonChip(
                  moment: moment,
                  accent: liturgy,
                  onTap: onLiturgyTap!,
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Pulso do dia — uma linha, sem toque (o CTA é o hero).
          MergeSemantics(
            child: Row(
              children: [
                _Stat(
                  glyph: CinematicGlyph.flame,
                  accent: AppRoles.streak,
                  value: l10n.commonDays(streak),
                  hint: atRisk ? l10n.homeStatAtRisk : null,
                  hintColor: AppRoles.risk,
                ),
                const Spacer(),
                _Stat(
                  glyph: CinematicGlyph.check,
                  accent: goalMet ? AppRoles.reward : AppRoles.chrome,
                  value: '$done/$goal',
                  hint: l10n.homeStatGoal,
                ),
                const SizedBox(width: AppSpace.md),
                _Stat(
                  glyph: CinematicGlyph.frost,
                  accent: freezeUsed ? a.textFaint : AppRoles.chrome,
                  value: '$freezeCount',
                  hint:
                      freezeUsed ? l10n.homeStatFreezeUsed : l10n.homeStatFreeze,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Semantics(
            label: goalMet || left <= 0
                ? l10n.homeGoalMet
                : l10n.homeGoalLeft(left),
            child: AppProgressBar(
              value: goalFill,
              color: barColor,
              height: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            goalMet || left <= 0
                ? l10n.homeGoalMet
                : l10n.homeGoalLeft(left),
            style: AppTypography.body(
              size: 11,
              weight: FontWeight.w700,
              color: goalMet || left <= 0
                  ? AppRoles.reward
                  : (atRisk ? AppRoles.streak : a.textFaint),
            ),
          ),
          const SizedBox(height: 10),
          const StreakWeek(orbSize: 28),
        ],
      ),
    );
  }
}

class _SeasonChip extends StatelessWidget {
  final LiturgicalMoment moment;
  final Color accent;
  final VoidCallback onTap;

  const _SeasonChip({
    required this.moment,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.homeSeasonChipSemantics(moment.title),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ActHaptics.tap();
          onTap();
        },
        // Área de toque ≥44dp; o pill continua pequeno visualmente.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          child: Padding(
            padding: const EdgeInsets.only(left: AppSpace.sm),
            child: Center(
              widthFactor: 1,
              child: SoftBadge(
                text: moment.title,
                accent: accent,
                textColor: accent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final CinematicGlyph glyph;
  final Color accent;
  final String value;
  final String? hint;
  final Color? hintColor;

  const _Stat({
    required this.glyph,
    required this.accent,
    required this.value,
    this.hint,
    this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CinematicIcon(
          glyph: glyph,
          size: AppMetrics.iconSm,
          accent: accent,
          glowing: false,
          framed: false,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTypography.title(
            size: 12,
            weight: FontWeight.w900,
            color: a.text,
          ),
        ),
        if (hint != null) ...[
          const SizedBox(width: 4),
          Text(
            hint!,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w600,
              color: hintColor ?? a.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
