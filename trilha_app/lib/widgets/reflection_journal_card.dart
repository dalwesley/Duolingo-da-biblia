import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mission_study.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'relic_panel.dart';
import 'ui_primitives.dart';

/// Anotações de estudo — últimas respostas guardadas nas missões.
class ReflectionJournalCard extends StatelessWidget {
  const ReflectionJournalCard({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);
    final items = progress.recentReflections(limit: 3);

    return RelicPanel(
      accent: AppColors.primaryLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RelicChapter(
            title: 'Anotações de estudo',
            accent: AppColors.primaryLight,
            whisper: items.isEmpty
                ? 'Ao fixar uma cena, sua resposta fica registrada aqui.'
                : null,
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...items.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              final study = MissionStudy.forSlug(e.key);
              final title = study?.passageRef ?? e.key;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (i > 0) ...[
                    const RelicHairline(accent: AppColors.primaryLight),
                    const SizedBox(height: 14),
                  ],
                  SectionLabel(
                    title,
                    color: AppColors.accent.withValues(alpha: 0.88),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.value,
                    style: AppTypography.verse(
                      size: 16,
                      height: 1.4,
                      color: a.text,
                    ),
                  ),
                  if (i < items.length - 1) const SizedBox(height: 14),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }
}
