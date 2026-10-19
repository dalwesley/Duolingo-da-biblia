import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recognition.dart';
import '../services/recognition_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'recognition_history_sheet.dart';
import '../l10n/app_language.dart';
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
    final plus = context.watch<SubscriptionService>().plusFeaturesOpen;
    final groups = groupRecognitionsBySender(items);
    final single = groups.length == 1;
    final l10n = context.l10n;

    return GlassCard(
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plus
                ? (single
                      ? l10n.recognitionHomeTitleSingle(groups.first.name)
                      : l10n.recognitionHomeTitleMany)
                : l10n.recognitionHomeTitleAnonymous,
            style: AppTypography.title(size: 18, height: 1.25, color: a.text),
          ),
          const SizedBox(height: 12),
          _HeartList(groups: groups, showNames: plus && !single, style: a),
          const SizedBox(height: 16),
          CopperCta(
            label: l10n.commonGotIt,
            dense: true,
            leading: null,
            trailing: null,
            onTap: () async {
              final reveal = context
                  .read<SubscriptionService>()
                  .plusFeaturesOpen;
              final service = context.read<RecognitionService>();
              await service.acknowledgeIncoming();
              if (!context.mounted || !reveal) return;
              // O nome fica no histórico — só o Peregrino+ abre a lista.
              await showRecognitionHistorySheet(context);
            },
          ),
          const SizedBox(height: AppSpace.sm),
          GhostCta(
            label: context.l10n.recognitionHomeSeeWho,
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
  final bool showNames;
  final AppearanceStyle style;

  const _HeartList({
    required this.groups,
    required this.showNames,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final labels = <String>[
      for (final group in groups)
        for (final item in group.items)
          showNames
              ? '${group.name} · ${item.subjectLabel}'
              : item.subjectLabel,
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
                  size: AppMetrics.iconSm,
                  accent: AppRoles.success,
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
