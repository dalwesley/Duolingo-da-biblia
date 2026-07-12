import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mission_study.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';

/// Diário leve — últimas reflexões guardadas nas missões.
class ReflectionJournalCard extends StatelessWidget {
  const ReflectionJournalCard({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final items = progress.recentReflections(limit: 2);
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seu diário',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
            color: AppColors.textOnDark.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 10),
        ...items.map((e) {
          final study = MissionStudy.forSlug(e.key);
          final title = study?.passageRef ?? e.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent.withValues(alpha: 0.95),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '“${e.value}”',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
