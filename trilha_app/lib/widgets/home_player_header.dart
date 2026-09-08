import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/backend_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import '../utils/liturgical_calendar.dart';
import 'cinematic_icon.dart';
import 'streak_week.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';

/// Saudação do dia — identidade + pulso, sem HUD de lâmpadas (isso é da missão).
class HomePlayerHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;
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
    final streakColor = atRisk ? AppColors.error : AppColors.streak;
    final name = progress.userName.trim().isEmpty
        ? 'Peregrino'
        : progress.userName.trim().split(' ').first;
    final moment = LiturgicalCalendar.momentFor();
    final liturgy = LiturgicalCalendar.accentOf(moment.season);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(a.cardFill, liturgy, 0.08)!,
            a.cardFill,
            Color.lerp(a.cardFill, Colors.black, 0.1)!,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: atRisk
              ? AppColors.error.withValues(alpha: 0.55)
              : a.cardBorder,
          width: AppMetrics.cardBorderWidth,
        ),
        boxShadow: AppMetrics.cardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              if (onProfileTap == null) return;
              HapticFeedback.selectionClick();
              onProfileTap!();
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                UserAvatar(
                  name: progress.userName,
                  photoUrl: backend.userPhotoUrl,
                  radius: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DayPhaseHelper.greeting(),
                        style: AppTypography.label(
                          size: 10,
                          letterSpacing: 0.8,
                          color: a.textMuted(0.55),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.display(
                          size: 22,
                          weight: FontWeight.w800,
                          color: a.text,
                          height: 1.05,
                        ),
                      ),
                    ],
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
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onTapMission,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: _Stat(
                    glyph: CinematicGlyph.flame,
                    accent: streakColor,
                    label: progress.streak > 0 ? '${progress.streak}d' : '0d',
                    hint: atRisk ? 'risco' : 'sequência',
                  ),
                ),
                _VDiv(a: a),
                Expanded(
                  child: _Stat(
                    glyph: CinematicGlyph.check,
                    accent: progress.dailyGoalMet
                        ? AppColors.accent
                        : AppColors.primaryLight,
                    label: '$done/$goal',
                    hint: 'meta',
                  ),
                ),
                _VDiv(a: a),
                Expanded(
                  child: _Stat(
                    glyph: CinematicGlyph.frost,
                    accent: progress.streakFreezeAvailable
                        ? AppColors.ice
                        : a.textMuted(0.45),
                    label: progress.streakFreezeAvailable ? '1' : '0',
                    hint: progress.streakFreezeAvailable ? 'gelo' : 'usado',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const StreakWeek(),
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
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: accent.withValues(alpha: 0.45)),
        ),
        child: Text(
          moment.title,
          style: AppTypography.label(
            size: 10,
            letterSpacing: 0.6,
            color: accent,
          ),
        ),
      ),
    );
  }
}

class _VDiv extends StatelessWidget {
  final AppearanceStyle a;
  const _VDiv({required this.a});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: a.cardBorder,
    );
  }
}

class _Stat extends StatelessWidget {
  final CinematicGlyph glyph;
  final Color accent;
  final String label;
  final String hint;

  const _Stat({
    required this.glyph,
    required this.accent,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CinematicIcon(
              glyph: glyph,
              size: 14,
              accent: accent,
              glowing: false,
              framed: false,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.title(
                size: 14,
                weight: FontWeight.w900,
                color: a.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          hint.toUpperCase(),
          style: AppTypography.label(
            size: 8,
            letterSpacing: 0.8,
            color: a.textMuted(0.55),
          ),
        ),
      ],
    );
  }
}
