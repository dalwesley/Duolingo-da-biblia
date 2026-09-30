import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';

import 'app_language.dart';
import 'bible_intro_overlay.dart';
import 'content_overlay.dart';
import 'question_overlay.dart';
import 'study_overlay.dart';

/// Acesso às traduções fora da árvore de widgets (models, utils, serviços,
/// notificações). Em widget, prefira `context.l10n`: ele reconstrói quando o
/// idioma muda; [L10n.current] não avisa ninguém.
class L10n {
  L10n._();

  static AppLocalizations _current = lookupAppLocalizations(const Locale('pt'));

  static AppLocalizations get current => _current;

  /// Chamado pelo `MaterialApp.builder` com o idioma já resolvido.
  static void setLocale(Locale locale) {
    if (_current.localeName == locale.languageCode) return;
    _current = lookupAppLocalizations(locale);
    // Overlays de conteúdo (trilhas / intros / perguntas) acompanham o idioma.
    // ignore: discarded_futures
    ContentOverlay.instance.reloadForLocale(locale.languageCode);
    // ignore: discarded_futures
    BibleIntroOverlay.instance.reloadForLocale(locale.languageCode);
    // ignore: discarded_futures
    QuestionOverlay.instance.reloadForLocale(locale.languageCode);
    // ignore: discarded_futures
    StudyOverlay.instance.reloadForLocale(locale.languageCode);
  }

  /// Resolve a escolha dos Ajustes para um idioma suportado — útil antes da
  /// UI existir (notificações agendadas, isolates).
  static Locale resolve(AppLanguage language) {
    final fixed = language.locale;
    if (fixed != null) return fixed;
    final device = PlatformDispatcher.instance.locale.languageCode;
    for (final l in AppLocalizations.supportedLocales) {
      if (l.languageCode == device) return l;
    }
    return const Locale('pt');
  }
}
