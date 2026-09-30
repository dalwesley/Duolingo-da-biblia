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

/// Saudação do dia — identidade + pulso, sem HUD de lâmpadas (isso é da cena).
///
/// Compacto: uma linha de pulso (sequência · meta · gelo) + a semana em orbs.
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
    final progress = context.watch<ProgressService>();
    final backend = context.watch<BackendService>();
    final a = Appearance.of(context);
    final goal = progress.settings.dailyGoal;
    final done = progress.missionsToday.clamp(0, goal);
    final atRisk = progress.isStreakAtRisk;
    final l10n = context.l10n;
    final name = progress.userName.trim().isEmpty
        ? l10n.homeDefaultName
        : progress.userName.trim().split(' ').first;
    final moment = LiturgicalCalendar.momentFor();
    final liturgy = LiturgicalCalendar.accentOf(moment.season);
    final streak = progress.streak;
    final freezeUsed = progress.streakFreezeUsedThisWeek;
    final freezeCount = freezeUsed || progress.streakFreezeAvailable ? 1 : 0;

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      tint: atRisk ? AppRoles.risk : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  button: onProfileTap != null,
                  label: onProfileTap != null ? l10n.homeOpenProfile(name) : null,
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
                            name: progress.userName,
                            photoUrl: backend.userPhotoUrl,
                            seed: backend.uid,
                            style: progress.settings.portraitStyle,
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
              if (onLiturgyTap != null)
                _SeasonChip(
                  moment: moment,
                  accent: liturgy,
                  onTap: onLiturgyTap!,
                ),
            ],
          ),
          const SizedBox(height: 10),
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
                  accent: progress.dailyGoalMet
                      ? AppRoles.reward
                      : AppRoles.chrome,
                  value: '$done/$goal',
                  hint: l10n.homeStatGoal,
                ),
                const SizedBox(width: AppSpace.md),
                _Stat(
                  glyph: CinematicGlyph.frost,
                  accent: freezeUsed ? a.textFaint : AppRoles.chrome,
                  value: '$freezeCount',
                  hint: freezeUsed ? l10n.homeStatFreezeUsed : l10n.homeStatFreeze,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
