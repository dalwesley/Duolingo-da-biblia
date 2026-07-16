import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';

class DailyGoalBar extends StatelessWidget {
  const DailyGoalBar({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final goal = progress.settings.dailyGoal;
    final done = progress.missionsToday >= goal;
    final pct = goal > 0 ? ((progress.missionsToday / goal) * 100).clamp(0, 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CinematicIcon(
                glyph: done ? CinematicGlyph.check : CinematicGlyph.path,
                size: 36,
                accent: AppColors.accent,
                glowing: !done,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Passos de hoje', style: TextStyle(fontWeight: FontWeight.w800)),
                    Text(
                      '${progress.missionsToday}/$goal passo${goal > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              if (done)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('✓ Feito!', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.success)),
                )
              else
                Text('$pct%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 10,
              backgroundColor: Colors.black.withValues(alpha: 0.05),
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
