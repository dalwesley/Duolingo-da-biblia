import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../l10n/l10n_global.dart';
import '../services/progress_service.dart';
import 'choice_portal.dart';
import 'language_flag.dart';

/// Idioma — mesma forma do motivo e do tema: linha em Ajustes abre
/// [showLanguageSheet], com um portal por idioma.

extension LanguageChoiceX on AppLanguage {
  /// Idioma que de fato aparece (Auto → o do aparelho).
  AppLanguage get shown {
    if (this != AppLanguage.device) return this;
    return switch (L10n.resolve(AppLanguage.device).languageCode) {
      'en' => AppLanguage.en,
      'es' => AppLanguage.es,
      _ => AppLanguage.pt,
    };
  }

  /// Tom da bandeira, claro o bastante para o céu escuro do portal.
  Color get accent => switch (LanguageFlagIdX.forAppLanguage(this)) {
    LanguageFlagId.br => const Color(0xFF2EAD5B),
    LanguageFlagId.us => const Color(0xFF5B7BE0),
    LanguageFlagId.es => const Color(0xFFE0484D),
  };

  String shortLabel(AppLocalizations l10n) => switch (this) {
    AppLanguage.device => l10n.languageShortDevice,
    AppLanguage.pt => l10n.languageShortPt,
    AppLanguage.en => l10n.languageShortEn,
    AppLanguage.es => l10n.languageShortEs,
  };

  /// Linha curta do portal — sem o ponto final das legendas.
  String caption(AppLocalizations l10n) {
    String bare(String s) => s.endsWith('.') ? s.substring(0, s.length - 1) : s;
    return switch (this) {
      AppLanguage.device =>
        '${bare(l10n.languageCaptionDevice)} · ${shown.label(l10n)}',
      AppLanguage.pt => bare(l10n.languageCaptionPt),
      AppLanguage.en => bare(l10n.languageCaptionEn),
      AppLanguage.es => bare(l10n.languageCaptionEs),
    };
  }

  /// Nome no botão: "Auto" no lugar de "Do aparelho".
  String ctaName(AppLocalizations l10n) =>
      this == AppLanguage.device ? shortLabel(l10n) : label(l10n);

  /// Amostra escrita no próprio idioma — o portal já fala a língua.
  String get sample => switch (shown) {
    AppLanguage.en => 'One step a day, back to the Word.',
    AppLanguage.es => 'Un paso al día, de vuelta a la Palabra.',
    _ => 'Um passo por dia, de volta à Palavra.',
  };
}

/// Sheet "Idioma" — o portal em foco já troca a língua do app (prévia ao
/// vivo, sheet aberta); o botão fica com ela. Fechar sem o botão volta à
/// de antes.
Future<void> showLanguageSheet(BuildContext context) async {
  final progress = context.read<ProgressService>();
  final current = progress.settings.language;
  var committed = false;
  void speak(AppLanguage lang) {
    if (progress.settings.language == lang) return;
    progress.updateSettings(progress.settings.copyWith(language: lang));
  }

  await showChoiceSheet(
    context,
    eyebrow: (l10n) => l10n.languageTitle,
    title: (l10n) => l10n.languageSheetTitle,
    tint: current.accent,
    carousel: (sheetContext) => LanguageCarousel(
      selected: current,
      onFocused: speak,
      onCommitted: (lang) {
        committed = true;
        speak(lang);
        Navigator.of(sheetContext).maybePop();
      },
    ),
  );
  if (!committed) speak(current);
}

/// Um portal por idioma: bandeira no horizonte, amostra no idioma.
class LanguageCarousel extends StatelessWidget {
  final AppLanguage selected;
  final ValueChanged<AppLanguage> onCommitted;

  /// Portal em foco (prévia ao vivo).
  final ValueChanged<AppLanguage>? onFocused;

  const LanguageCarousel({
    super.key,
    required this.selected,
    required this.onCommitted,
    this.onFocused,
  });

  static const _langs = AppLanguage.values;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ChoiceCarousel(
      selected: _langs.indexOf(selected),
      footnote: l10n.languageHint,
      ctaLabel: (i, current) => current
          ? l10n.intentCtaContinue(_langs[i].ctaName(l10n))
          : l10n.intentCtaChoose(_langs[i].ctaName(l10n)),
      onCommitted: (i) => onCommitted(_langs[i]),
      onFocused: onFocused == null ? null : (i) => onFocused!(_langs[i]),
      portals: [
        for (final lang in _langs)
          ChoicePortal(
            eyebrow: lang.shortLabel(l10n).toUpperCase(),
            title: lang.label(l10n),
            tagline: lang.caption(l10n),
            blurb: '“${lang.sample}”',
            accent: lang.accent,
            emblem: (size, ink) => LanguageFlag.forAppLanguage(
              lang,
              width: size * 1.2,
              height: size * 0.84,
            ),
            scene: (context, t, focus, parallax) => CustomPaint(
              painter: GlowScenePainter(
                color: lang.accent,
                t: t,
                intensity: 0.35 + 0.65 * focus,
                parallax: parallax,
              ),
            ),
          ),
      ],
    );
  }
}
