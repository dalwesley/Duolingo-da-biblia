import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/daily_scripture.dart';
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
                              const Color(0xFFA8D8EA),
                              const Color(0xFF7EC8E3),
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
                          ? const Color(0xFF7EC8E3).withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: active ? 0 : 0.12),
                  width: isToday ? 2 : 1,
                ),
                boxShadow: active
                    ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 10)]
                    : frozen
                        ? [
                            BoxShadow(
                              color: const Color(0xFF7EC8E3).withValues(alpha: 0.35),
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
                            accent: Color(0xFF1A3A4A),
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

/// Escritura do dia — modo cinematográfico como abertura de cena.
class ScripturePill extends StatelessWidget {
  final bool cinematic;

  const ScripturePill({super.key, this.cinematic = false});

  @override
  Widget build(BuildContext context) {
    final q = DailyScripture.today();
    final a = Appearance.of(context);

    if (cinematic) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 1,
                color: AppColors.accent.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 10),
              CinematicIcon(
                glyph: CinematicGlyph.spark,
                size: 28,
                accent: AppColors.accent,
                glowing: false,
              ),
              const SizedBox(width: 10),
              Container(
                width: 28,
                height: 1,
                color: AppColors.accent.withValues(alpha: 0.45),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          Text(
            '"${q.$1}"',
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 22,
              fontStyle: FontStyle.italic,
              height: 1.35,
              weight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.94),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Text(
            q.$2.toUpperCase(),
            style: AppTypography.label(
              size: 11,
              letterSpacing: 1.6,
              color: AppColors.accent.withValues(alpha: 0.95),
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, AppSpace.lg, 14),
      decoration: BoxDecoration(
        gradient: a.cardGradient,
        color: a.cardGradient == null ? a.cardFill : null,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: a.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.spark,
            size: 36,
            accent: AppColors.accent,
            glowing: false,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.$1,
                  style: AppTypography.display(
                    size: 16,
                    fontStyle: FontStyle.italic,
                    height: 1.35,
                    weight: FontWeight.w600,
                    color: a.text.withValues(alpha: 0.92),
                  ),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(
                  q.$2,
                  style: AppTypography.body(
                    size: 11,
                    weight: FontWeight.w800,
                    color: AppColors.accent.withValues(alpha: 0.95),
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
