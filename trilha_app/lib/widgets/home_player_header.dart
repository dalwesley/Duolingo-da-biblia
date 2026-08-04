import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/backend_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/day_phase.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';

/// Header unificado da home: foto + nome + HUD (streak/meta/lâmpadas/gelo).
class HomePlayerHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onTapMission;
  final int? lampsPreview;

  const HomePlayerHeader({
    super.key,
    this.onProfileTap,
    this.onTapMission,
    this.lampsPreview,
  });

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final backend = context.watch<BackendService>();
    final a = Appearance.of(context);
    final goal = progress.settings.dailyGoal;
    final done = progress.missionsToday.clamp(0, goal);
    final lamps = lampsPreview ?? ProgressService.maxLamps;
    final atRisk = progress.isStreakAtRisk;
    final streakColor = atRisk ? AppColors.error : AppColors.streak;
    final name = progress.userName.trim().isEmpty
        ? 'Aprendiz'
        : progress.userName.trim().split(' ').first;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: a.cardFill,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: atRisk
              ? AppColors.error.withValues(alpha: 0.45)
              : a.cardBorder,
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
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DayPhaseHelper.greeting(),
                        style: AppTypography.label(
                          size: 10,
                          letterSpacing: 0.6,
                          color: a.textMuted(0.55),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.display(
                          size: 18,
                          weight: FontWeight.w800,
                          color: a.text,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onProfileTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: a.textMuted(0.4),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
                    hint: atRisk ? 'risco' : 'streak',
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
                    glyph: CinematicGlyph.lamp,
                    accent: AppColors.sand,
                    label: '$lamps',
                    hint: 'lâmpadas',
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
                    hint: 'gelo',
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
