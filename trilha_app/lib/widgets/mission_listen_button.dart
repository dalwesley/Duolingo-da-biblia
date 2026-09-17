import 'package:flutter/material.dart';

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

  static String script({String? verse, String? insight}) {
    final passage = SessionComposer.clipEntranceVerse(
      (verse ?? '').trim(),
      maxWords: 80,
    );
    final hoje = (insight ?? '').trim();
    final parts = <String>[
      if (passage.isNotEmpty) passage,
      if (hoje.isNotEmpty) 'Hoje: $hoje',
    ];
    return parts.join('. ');
  }

  bool get _hasText => script(verse: verse, insight: insight).isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasText) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: TtsService.instance,
      builder: (context, _) {
        final speaking = TtsService.instance.isSpeaking;
        return GhostCta(
          label: speaking ? 'Parar' : 'Ouvir o texto',
          leading: speaking ? CinematicGlyph.lamp : CinematicGlyph.echo,
          expanded: true,
          onTap: () {
            if (speaking) {
              TtsService.instance.stop();
            } else {
              TtsService.instance.speak(script(verse: verse, insight: insight));
            }
          },
        );
      },
    );
  }
}
