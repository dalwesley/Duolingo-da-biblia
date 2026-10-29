import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/curated_trails.dart';
import '../l10n/app_language.dart';
import '../models/trail.dart';
import '../screens/lesson_screen.dart';
import '../services/analytics_service.dart';
import '../services/content_catalog_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';

/// Diagnóstico de A Promessa: depois da Travessia final, o mapa mostra o
/// que ficou firme em cada bloco e o que ainda está na revisão.
class PromiseMapCard extends StatelessWidget {
  const PromiseMapCard({super.key});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return GlassCard(
      tint: AppRoles.reward,
      glow: 0.6,
      onTap: () => showPromiseMapSheet(context),
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.link,
            size: AppMetrics.leadingIcon,
            accent: AppRoles.reward,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.promiseTrailMapTitle,
                  style: AppTypography.title(size: 15, color: a.text),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(
                  l10n.promiseTrailMapCardBody,
                  style: AppTypography.body(size: 13, color: a.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showPromiseMapSheet(BuildContext context) {
  AnalyticsService.instance.logEvent('premium_walk_map_open', {
    'walk': CuratedTrails.promiseSlug,
  });
  return showAppSheet<void>(context, builder: (_) => const _PromiseMapSheet());
}

class _PromiseMapSheet extends StatelessWidget {
  const _PromiseMapSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mistakes = context.select(
      (ProgressService p) => p.mistakeQuestionIds,
    );
    final rows = [
      for (final block in CuratedTrails.promiseBlocks)
        (
          title: block.title,
          scenes: block.scenes,
          ids: CuratedTrails.mistakesFor(mistakes, [
            for (final m in block.scenes) m.resolvedBankSection,
          ]),
        ),
      (
        title: l10n.promiseTrailMapSynthesis,
        scenes: const <Mission>[],
        ids: [
          for (final id in mistakes)
            if (CuratedTrails.synthesisQuestionIds.contains(id)) id,
        ],
      ),
    ];
    return AppSheetPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(
            title: l10n.promiseTrailMapTitle,
            subtitle: l10n.promiseTrailMapSheetBody,
            face: rows.every((r) => r.ids.isEmpty)
                ? CloudFace.sucesso
                : CloudFace.feliz,
            center: true,
          ),
          const SizedBox(height: AppSpace.md),
          for (final row in rows) ...[
            _BlockRow(
              title: row.title,
              mistakes: row.ids.length,
              onReview: row.ids.isEmpty
                  ? null
                  : () => _review(context, row.title, row.scenes, row.ids),
            ),
            const SizedBox(height: AppSpace.sm),
          ],
        ],
      ),
    );
  }

  /// Os erros do bloco, de novo, em modo prática (não mexe no progresso).
  Future<void> _review(
    BuildContext context,
    String title,
    List<Mission> scenes,
    List<String> ids,
  ) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    for (final trail in {for (final m in scenes) m.bankTrailSlug ?? ''}) {
      if (trail.isNotEmpty) {
        await ContentCatalogService.instance.ensureTrailBank(trail);
      }
    }
    await CuratedTrails.prepareQuestions(CuratedTrails.synthesisSlug);
    AnalyticsService.instance.logEvent('premium_walk_review', {
      'walk': CuratedTrails.promiseSlug,
      'questions': ids.length,
    });
    navigator.pop();
    final review = Mission(
      slug: 'promessa-revisao',
      title: l10n.promiseTrailMapReviewTitle(title),
      intro: l10n.promiseTrailMapReviewIntro,
      type: 'lesson',
      stepsReward: 30,
      questions: const [],
    );
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => LessonScreen(
          missionSlug: review.slug,
          practiceMode: true,
          missionOverride: review,
          questionIdsOverride: ids,
          requiresPlus: true,
        ),
      ),
    );
  }
}

class _BlockRow extends StatelessWidget {
  final String title;
  final int mistakes;
  final VoidCallback? onReview;

  const _BlockRow({
    required this.title,
    required this.mistakes,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final firm = mistakes == 0;
    final tone = firm ? AppRoles.reward : a.textSecondary;
    return InsetPanel(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Row(
        children: [
          CinematicIcon(
            glyph: firm ? CinematicGlyph.check : CinematicGlyph.refresh,
            size: AppMetrics.iconSm,
            accent: tone,
            framed: false,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title(size: 14, color: a.text),
                ),
                Text(
                  firm
                      ? l10n.promiseTrailMapFirm
                      : l10n.promiseTrailMapReview(mistakes),
                  style: AppTypography.body(size: 12, color: tone),
                ),
              ],
            ),
          ),
          if (onReview != null)
            TextCta(label: l10n.promiseTrailMapReviewCta, onTap: onReview),
        ],
      ),
    );
  }
}
