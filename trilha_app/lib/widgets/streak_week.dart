import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/daily_scripture.dart';
import 'cinematic_icon.dart';

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
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: active ? AppGradients.gold : null,
                color: active ? null : Colors.white.withValues(alpha: 0.06),
                border: Border.all(
                  color: isToday
                      ? AppColors.accent
                      : Colors.white.withValues(alpha: active ? 0 : 0.12),
                  width: isToday ? 2 : 1,
                ),
                boxShadow: active
                    ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 10)]
                    : null,
              ),
              child: Center(
                child: active
                    ? const Icon(Icons.check_rounded, size: 16, color: Color(0xFF3D2E00))
                    : Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: a.textMuted(0.4),
                        ),
                      ),
              ),
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
          const SizedBox(height: 16),
          Text(
            '"${q.$1}"',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.94),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            q.$2.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
              color: AppColors.accent.withValues(alpha: 0.95),
            ),
          ),
        ],
      );
    }

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
          CinematicIcon(
            glyph: CinematicGlyph.spark,
            size: 36,
            accent: AppColors.accent,
            glowing: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.$1,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: a.text.withValues(alpha: 0.92),
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
