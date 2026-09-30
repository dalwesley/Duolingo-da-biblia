import 'package:flutter/widgets.dart';

import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

/// Idioma da interface escolhido nos Ajustes. [device] segue o aparelho.
enum AppLanguage { device, pt, en, es }

extension AppLanguageX on AppLanguage {
  String get storageKey => name;

  /// `null` deixa o Flutter resolver pelo idioma do aparelho.
  Locale? get locale => switch (this) {
    AppLanguage.device => null,
    AppLanguage.pt => const Locale('pt'),
    AppLanguage.en => const Locale('en'),
    AppLanguage.es => const Locale('es'),
  };

  /// Nome do idioma escrito nele mesmo; [device] vem traduzido.
  String label(AppLocalizations l10n) => switch (this) {
    AppLanguage.device => l10n.languageDevice,
    AppLanguage.pt => 'Português',
    AppLanguage.en => 'English',
    AppLanguage.es => 'Español',
  };

  static AppLanguage fromStorage(String? raw) {
    for (final lang in AppLanguage.values) {
      if (lang.name == raw) return lang;
    }
    return AppLanguage.device;
  }
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
