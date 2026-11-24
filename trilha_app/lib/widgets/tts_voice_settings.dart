import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../services/bible_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Ajustes do "Ouvir" na leitura: velocidade e voz da língua do texto aberto.
///
/// As vozes são do aparelho (Google, Samsung, Xiaomi, iOS…) — mudam de um
/// celular para outro, então a escolha fica salva só neste aparelho.
class TtsVoiceSettings extends StatefulWidget {
  /// Língua do texto aberto (`pt`, `en`, `es`).
  final String language;
  final Color labelColor;

  const TtsVoiceSettings({
    super.key,
    required this.language,
    required this.labelColor,
  });

  @override
  State<TtsVoiceSettings> createState() => _TtsVoiceSettingsState();
}

class _TtsVoiceSettingsState extends State<TtsVoiceSettings> {
  late Future<List<TtsVoice>> _voices = TtsService.instance.voicesFor(
    widget.language,
  );
  bool _testing = false;

  @override
  void didUpdateWidget(covariant TtsVoiceSettings old) {
    super.didUpdateWidget(old);
    if (old.language != widget.language) {
      _voices = TtsService.instance.voicesFor(widget.language);
    }
  }

  @override
  void dispose() {
    if (_testing) unawaited(TtsService.instance.stop());
    super.dispose();
  }

  String _languageName(BuildContext context) => switch (widget.language) {
    'en' => context.l10n.bibleVoiceEnglish,
    'es' => context.l10n.bibleVoiceSpanish,
    _ => context.l10n.bibleVoicePortuguese,
  };

  /// "Voz 2 · US · feminina" — nomes do motor ("en-us-x-iob-local") não
  /// dizem nada para a pessoa.
  String _label(BuildContext context, TtsVoice v, int number) {
    final region = v.locale.split('-').length > 1
        ? v.locale.split('-').last.toUpperCase()
        : '';
    final gender = switch (v.gender?.toLowerCase()) {
      'female' => context.l10n.ttsVoiceFemale,
      'male' => context.l10n.ttsVoiceMale,
      _ => null,
    };
    return [
      context.l10n.ttsVoiceNumbered(number),
      if (region.isNotEmpty) region,
      ?gender,
    ].join(' · ');
  }

  Future<void> _test() async {
    final tts = TtsService.instance;
    if (_testing) {
      await tts.stop();
      if (mounted) setState(() => _testing = false);
      return;
    }
    ActHaptics.tap();
    // Amostra: João 3:16 na tradução aberta.
    final id = BibleService.instance.translationId;
    final sample = await BibleService.instance.verseIn(id, 42, 3, 16) ?? '';
    if (!mounted || sample.isEmpty) return;
    setState(() => _testing = true);
    await tts.speak(sample, language: widget.language);
    // speak não espera o fim: acompanha pelo isSpeaking.
    void done() {
      if (!tts.isSpeaking) {
        tts.removeListener(done);
        if (mounted) setState(() => _testing = false);
      }
    }

    tts.addListener(done);
  }

  Future<void> _pickVoice(TtsVoice? v) async {
    ActHaptics.tap();
    await TtsService.instance.setVoice(widget.language, v);
    if (_testing) {
      await TtsService.instance.stop();
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final tts = TtsService.instance;
    Widget chip(String label, bool selected, VoidCallback onTap) {
      return AppSelectChip(
        label: label,
        selected: selected,
        fill: true,
        fontSize: 12,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
        onTap: onTap,
      );
    }

    return ListenableBuilder(
      listenable: tts,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(context.l10n.ttsSectionVoice, color: widget.labelColor),
          const SizedBox(height: AppSpace.sm),
          AppChipGrid(
            columns: 3,
            children: [
              for (final s in TtsSpeed.values)
                chip(
                  switch (s) {
                    TtsSpeed.slow => context.l10n.ttsSpeedSlow,
                    TtsSpeed.normal => context.l10n.ttsSpeedNormal,
                    TtsSpeed.fast => context.l10n.ttsSpeedFast,
                  },
                  tts.speed == s,
                  () {
                    ActHaptics.tap();
                    unawaited(tts.setSpeed(s));
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          FutureBuilder<List<TtsVoice>>(
            future: _voices,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpace.sm),
                  child: AppSpinner(inline: true),
                );
              }
              final voices = (snap.data ?? const <TtsVoice>[]).take(8).toList();
              if (voices.isEmpty) {
                return Text(
                  context.l10n.ttsNoVoices(_languageName(context)),
                  style: AppTypography.body(
                    size: 12,
                    height: 1.35,
                    color: a.textFaint,
                  ),
                );
              }
              final chosen = tts.chosenVoice(widget.language);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppChipGrid(
                    columns: 3,
                    children: [
                      chip(
                        context.l10n.ttsVoiceAuto,
                        chosen == null || !voices.contains(chosen),
                        () => _pickVoice(null),
                      ),
                      for (var i = 0; i < voices.length; i++)
                        chip(
                          _label(context, voices[i], i + 1),
                          chosen == voices[i],
                          () => _pickVoice(voices[i]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.ttsVoiceHint(_languageName(context)),
                    style: AppTypography.body(size: 11, color: a.textFaint),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpace.md),
          GhostCta(
            label: _testing ? context.l10n.ttsTestStop : context.l10n.ttsTest,
            leading: _testing ? CinematicGlyph.stop : CinematicGlyph.echo,
            expanded: true,
            onTap: _test,
          ),
        ],
      ),
    );
  }
}
