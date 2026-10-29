import 'package:flutter/material.dart';

import '../data/mission_study.dart';
import '../l10n/app_language.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'anan_speech.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'immersive_background.dart';
import 'ui_primitives.dart';
import 'verse_study_sheet.dart';

/// "Para aprofundar" da cena, aberto pelo menu do Anan: a palavra-chave com
/// o sentido dela, a pergunta para pensar e as ligações com outros textos.
/// É estudo da Bíblia, então é grátis.
class SceneStudy {
  SceneStudy._();

  /// Pergunta-foco de molde ("O que este passo ensina sobre altar?"):
  /// não diz nada da cena, fica de fora.
  static bool _templated(String q) =>
      q.startsWith('O que este passo ensina sobre') ||
      q.startsWith('Como o evangelho molda');

  /// A cena tem algo para mostrar (senão o botão nem aparece).
  static bool hasContent(MissionStudy study) =>
      study.localizedKeywordGloss.trim().isNotEmpty ||
      (study.focusQuestion.trim().isNotEmpty &&
          !_templated(study.focusQuestion)) ||
      study.relatedVerses.isNotEmpty;
}

Future<void> showSceneStudySheet(
  BuildContext context, {
  required MissionStudy study,
  required String missionSlug,
}) {
  AnalyticsService.instance.logEvent('scene_study_open', {
    'mission_slug': missionSlug,
    'links': study.relatedVerses.length,
  });
  return showAppSheet<void>(
    context,
    builder: (_) => _SceneStudySheet(study: study, missionSlug: missionSlug),
  );
}

class _SceneStudySheet extends StatelessWidget {
  final MissionStudy study;
  final String missionSlug;

  const _SceneStudySheet({required this.study, required this.missionSlug});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    // Palavra-chave e motivos das ligações só existem em português.
    final pt = Localizations.localeOf(context).languageCode == 'pt';
    final gloss = study.localizedKeywordGloss.trim();
    final keyword = pt ? study.keyword.trim() : '';
    final question = SceneStudy._templated(study.focusQuestion)
        ? ''
        : study.localizedFocusQuestion.trim();
    final links = study.relatedVerses;

    Widget eyebrow(String text) => Text(
      text.toUpperCase(),
      textAlign: TextAlign.center,
      style: AppTypography.body(
        size: 11,
        weight: FontWeight.w800,
        color: a.textSecondary,
      ).copyWith(letterSpacing: 1.2),
    );

    return AppSheetPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sem pergunta, o Anan fica no cabeçalho (toda folha tem o
          // Anan); com ela, é ele quem a faz, no balão.
          AppSheetHeader(
            center: true,
            cloud: question.isEmpty,
            title: l10n.sceneStudyCta,
            subtitle: study.passageRef.isEmpty ? null : study.passageRef,
          ),
          const SizedBox(height: AppSpace.lg),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.6,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (gloss.isNotEmpty)
                      InsetPanel(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                        borderColor: AppRoles.reward.withValues(alpha: 0.45),
                        child: Column(
                          children: [
                            eyebrow(l10n.sceneStudyKeyword),
                            if (keyword.isNotEmpty) ...[
                              const SizedBox(height: AppSpace.sm),
                              Text(
                                keyword,
                                textAlign: TextAlign.center,
                                style: AppTypography.display(
                                  size: 30,
                                  color: AppRoles.reward,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpace.sm),
                            Text(
                              gloss,
                              textAlign: TextAlign.center,
                              style: AppTypography.body(
                                size: 15,
                                color: a.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (question.isNotEmpty) ...[
                      if (gloss.isNotEmpty) const SizedBox(height: AppSpace.xl),
                      AnanSpeech(
                        face: CloudFace.feliz,
                        ananSize: 64,
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.sceneStudyThink.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: AppTypography.body(
                                size: 12,
                                weight: FontWeight.w800,
                                color: AnanSpeechBubble.mark,
                              ),
                            ),
                            const SizedBox(height: AppSpace.sm),
                            Text(
                              question,
                              textAlign: TextAlign.center,
                              style: AppTypography.verse(
                                size: 20,
                                weight: FontWeight.w600,
                                height: 1.4,
                                color: AnanSpeechBubble.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (links.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.xl),
                      eyebrow(l10n.sceneStudyLinks),
                      const SizedBox(height: AppSpace.sm),
                      for (final v in links) ...[
                        _LinkCard(
                          reference: v.reference,
                          reason: pt ? v.reason : '',
                          onTap: () async {
                            AnalyticsService.instance.logEvent(
                              'scene_study_link_open',
                              {'mission_slug': missionSlug, 'ref': v.reference},
                            );
                            // Por cima desta folha: fechar o estudo do
                            // versículo volta para o "Para aprofundar".
                            await showVerseStudyFromReference(
                              context,
                              v.reference,
                              source: 'scene_study_link',
                            );
                          },
                        ),
                        const SizedBox(height: AppSpace.sm),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          CopperCta(
            label: l10n.lessonBackToQuestion,
            trailing: null,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  final String reference;
  final String reason;
  final VoidCallback onTap;

  const _LinkCard({
    required this.reference,
    required this.reason,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      padding: AppMetrics.cardPaddingCompact,
      onTap: onTap,
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.link,
            size: AppMetrics.iconMd,
            accent: a.chrome,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reference,
                  style: AppTypography.title(size: 15, color: a.text),
                ),
                if (reason.isNotEmpty)
                  Text(
                    reason,
                    style: AppTypography.body(size: 13, color: a.textSecondary),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          ListChevron(color: a.textSecondary),
        ],
      ),
    );
  }
}
