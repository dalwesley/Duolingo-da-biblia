import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/daily_scripture.dart';

class StreakWeek extends StatelessWidget {
  final int streak;
  final bool playedToday;

  const StreakWeek({super.key, required this.streak, required this.playedToday});

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
        final active = progress.playedOnDate(day) || (isToday && playedToday);

        return Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: active ? AppGradients.gold : null,
                color: active ? null : a.cardFillSoft,
                border: Border.all(
                  color: isToday ? AppColors.accent : a.cardBorder,
                  width: isToday ? 2 : 1,
                ),
                boxShadow: active ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 8)] : null,
              ),
              child: Center(
                child: active
                    ? const Icon(Icons.check_rounded, size: 16, color: Color(0xFF3D2E00))
                    : Text(labels[i], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: a.textMuted(0.4))),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class ScripturePill extends StatelessWidget {
  const ScripturePill({super.key});

  @override
  Widget build(BuildContext context) {
    final q = DailyScripture.today();
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: a.cardGradient,
        color: a.cardGradient == null ? a.cardFill : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: a.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.gold,
              boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 10)],
            ),
            child: const Icon(Icons.format_quote_rounded, size: 18, color: Color(0xFF3D2E00)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.$1,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: a.text.withValues(alpha: a.onDark ? 0.92 : 1),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  q.$2,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent.withValues(alpha: 0.95),
                    letterSpacing: 0.2,
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
