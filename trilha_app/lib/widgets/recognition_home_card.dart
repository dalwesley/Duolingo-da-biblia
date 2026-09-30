import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recognition.dart';
import '../services/recognition_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'recognition_history_sheet.dart';
import 'ui_primitives.dart';

/// Nota na Home quando alguém reconheceu a caminhada ou uma medalha.
///
/// Cada reconhecimento é uma linha com um coração. Entendi é o botão do app.
class RecognitionHomeCard extends StatelessWidget {
  final List<Recognition> items;

  const RecognitionHomeCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final a = Appearance.of(context);
    final groups = groupRecognitionsBySender(items);
    final single = groups.length == 1;

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            single
                ? '${groups.first.name} reconheceu sua jornada'
                : 'Reconheceram sua jornada',
            style: AppTypography.title(size: 18, height: 1.25, color: a.text),
          ),
          const SizedBox(height: 12),
          _HeartList(groups: groups, single: single, style: a),
          const SizedBox(height: 16),
          CopperCta(
            label: 'Entendi',
            dense: true,
            leading: null,
            trailing: null,
            onTap: () async {
              final service = context.read<RecognitionService>();
              await service.acknowledgeIncoming();
              if (!context.mounted) return;
              // Mantém o rastro — quem reconheceu o quê fica no histórico.
              await showRecognitionHistorySheet(context);
            },
          ),
          const SizedBox(height: AppSpace.sm),
          GhostCta(
            label: 'Ver quem reconheceu',
            expanded: true,
            onTap: () => showRecognitionHistorySheet(context),
          ),
        ],
      ),
    );
  }
}

class _HeartList extends StatelessWidget {
  final List<RecognitionSenderGroup> groups;
  final bool single;
  final AppearanceStyle style;

  const _HeartList({
    required this.groups,
    required this.single,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      if (single)
        for (final item in groups.first.items) item.subjectLabel
      else
        for (final group in groups)
          for (final item in group.items)
            '${group.name} · ${item.subjectLabel}',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: CinematicIcon(
                  glyph: CinematicGlyph.heart,
                  size: 16,
                  accent: AppColors.clay,
                  framed: false,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  labels[i],
                  style: AppTypography.body(
                    size: 14,
                    weight: FontWeight.w600,
                    height: 1.3,
                    color: style.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
