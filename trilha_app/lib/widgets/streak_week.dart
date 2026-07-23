import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';

class StreakWeek extends StatelessWidget {
  const StreakWeek({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = DateTime(monday.year, monday.month, monday.day + i);
        final isToday = day.year == today.year && day.month == today.month && day.day == today.day;
        final active = progress.playedOnDate(day);
        final frozen = progress.wasFrozenOnDate(day);

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: active
                    ? AppGradients.gold
                    : frozen
                        ? LinearGradient(
                            colors: [
                              AppColors.iceSoft,
                              AppColors.ice,
                            ],
                          )
                        : null,
                color: active || frozen
                    ? null
                    : Colors.white.withValues(alpha: 0.06),
                border: Border.all(
                  color: isToday
                      ? AppColors.accent
                      : frozen
                          ? AppColors.ice.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: active ? 0 : 0.12),
                  width: isToday ? 2 : 1,
                ),
                boxShadow: active
                    ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 10)]
                    : frozen
                        ? [
                            BoxShadow(
                              color: AppColors.ice.withValues(alpha: 0.35),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
              ),
              child: Center(
                child: active
                    ? const CinematicIcon(
                        glyph: CinematicGlyph.check,
                        size: 16,
                        accent: AppColors.inkOnAccent,
                        framed: false,
                      )
                    : frozen
                        ? const CinematicIcon(
                            glyph: CinematicGlyph.frost,
                            size: 15,
                            accent: AppColors.iceDeep,
                            framed: false,
                          )
                        : Text(
                            labels[i],
                            style: AppTypography.label(
                              size: 10,
                              letterSpacing: 0,
                              weight: FontWeight.w700,
                              color: isToday
                                  ? AppColors.accent.withValues(alpha: 0.95)
                                  : a.textMuted(0.4),
                            ),
                          ),
              ),
            ),
            SizedBox(
              height: 14,
              child: isToday
                  ? Text(
                      'hoje',
                      style: AppTypography.label(
                        size: 9,
                        letterSpacing: 0.2,
                        color: AppColors.accent.withValues(alpha: 0.9),
                      ),
                    )
                  : null,
            ),
          ],
        );
      }),
    );
  }
}
