import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mission_study.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Diário leve — últimas reflexões guardadas nas missões.
class ReflectionJournalCard extends StatelessWidget {
  const ReflectionJournalCard({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);
    final items = progress.recentReflections(limit: 3);
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Seu diário'),
        const SizedBox(height: 10),
        ...items.map((e) {
          final study = MissionStudy.forSlug(e.key);
          final title = study?.passageRef ?? e.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              padding: AppMetrics.cardPadding,
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
                      color: a.text.withValues(alpha: 0.9),
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
