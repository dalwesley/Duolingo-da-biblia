import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../services/session_composer.dart';
import '../services/tts_service.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/ui_primitives.dart';

/// Ouvir passagem + insight (~90 s). Mesmo TTS da aba Bíblia.
class MissionListenButton extends StatelessWidget {
  final String? verse;
  final String? insight;
  final Color accent;

  const MissionListenButton({
    super.key,
    this.verse,
    this.insight,
    required this.accent,
  });

  static String script({
    String? verse,
    String? insight,
    required AppLocalizations l10n,
  }) {
    final passage = SessionComposer.clipEntranceVerse(
      (verse ?? '').trim(),
      maxWords: 80,
    );
    final hoje = (insight ?? '').trim();
    final parts = <String>[
      if (passage.isNotEmpty) passage,
      if (hoje.isNotEmpty) l10n.seasonTodayInsight(hoje),
    ];
    return parts.join('. ');
  }

  bool _hasText(AppLocalizations l10n) =>
      script(verse: verse, insight: insight, l10n: l10n).isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!_hasText(l10n)) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: TtsService.instance,
      builder: (context, _) {
        final speaking = TtsService.instance.isSpeaking;
        return GhostCta(
          label: speaking
              ? context.l10n.lessonListenStop
              : context.l10n.lessonListen,
          leading: speaking ? CinematicGlyph.stop : CinematicGlyph.echo,
          expanded: true,
          onTap: () {
            if (speaking) {
              TtsService.instance.stop();
            } else {
              TtsService.instance.speak(
                script(verse: verse, insight: insight, l10n: l10n),
              );
            }
          },
        );
      },
    );
  }
}
