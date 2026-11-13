import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../models/scene_takeaway.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';
import 'verse_study_sheet.dart';

/// "O que você viu no texto": as frases de acerto da cena, cada uma com o
/// versículo de onde vem. Errou de primeira → aparece em "Para rever".
Future<void> showSceneTakeawaysSheet(
  BuildContext context, {
  required List<SceneTakeaway> takeaways,
  String? sceneTitle,
}) {
  return showAppSheet<void>(
    context,
    builder: (_) =>
        _SceneTakeawaysSheet(takeaways: takeaways, sceneTitle: sceneTitle),
  );
}

class _SceneTakeawaysSheet extends StatelessWidget {
  final List<SceneTakeaway> takeaways;
  final String? sceneTitle;

  const _SceneTakeawaysSheet({required this.takeaways, this.sceneTitle});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final seen = takeaways.where((t) => !t.missed).toList();
    final missed = takeaways.where((t) => t.missed).toList();
    final title = (sceneTitle ?? '').trim();
    return AppSheetPanel(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSheetHeader(
              eyebrow: title.isEmpty ? null : title,
              title: l10n.takeawaysTitle,
              subtitle: l10n.takeawaysSubtitle,
            ),
            const SizedBox(height: AppSpace.lg),
            for (final t in seen) _TakeawayTile(item: t),
            if (missed.isNotEmpty) ...[
              const SizedBox(height: AppSpace.md),
              SectionLabel(l10n.takeawaysReviewLabel),
              const SizedBox(height: AppSpace.sm),
              for (final t in missed) _TakeawayTile(item: t),
            ],
          ],
        ),
      ),
    );
  }
}

class _TakeawayTile extends StatelessWidget {
  final SceneTakeaway item;

  const _TakeawayTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final ref = item.reference;
    final accent = item.missed ? a.textSecondary : AppRoles.presence;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: ref == null
              ? null
              : () => showVerseStudyFromReference(
                  context,
                  ref,
                  source: 'celebration_takeaway',
                ),
          child: GlassCard(
            padding: AppMetrics.cardPaddingCompact,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: CinematicIcon(
                    glyph: item.missed
                        ? CinematicGlyph.refresh
                        : CinematicGlyph.check,
                    size: AppMetrics.chipIcon,
                    accent: accent,
                    framed: false,
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.text,
                        style: AppTypography.body(
                          size: 14,
                          height: 1.4,
                          color: a.text,
                        ),
                      ),
                      if (ref != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          ref,
                          style: AppTypography.label(
                            size: 12,
                            weight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
