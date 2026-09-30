import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/l10n/app_language.dart';

void main() {
  group('AppLanguage', () {
    test('round-trips through storage and defaults to device', () {
      for (final lang in AppLanguage.values) {
        expect(AppLanguageX.fromStorage(lang.storageKey), lang);
      }
      expect(AppLanguageX.fromStorage(null), AppLanguage.device);
      expect(AppLanguageX.fromStorage('xx'), AppLanguage.device);
      expect(AppLanguage.device.locale, isNull);
    });

    test('every fixed language is supported', () {
      final codes = AppLocalizations.supportedLocales
          .map((l) => l.languageCode)
          .toSet();
      for (final lang in AppLanguage.values) {
        final code = lang.locale?.languageCode;
        if (code != null) expect(codes, contains(code));
      }
    });
  });

  group('AppLocalizations', () {
    test('settings strings resolve per locale', () {
      expect(
        lookupAppLocalizations(const Locale('pt')).settingsTitle,
        'Ajustes',
      );
      expect(
        lookupAppLocalizations(const Locale('en')).settingsTitle,
        'Settings',
      );
      expect(
        lookupAppLocalizations(const Locale('es')).settingsTitle,
        'Ajustes',
      );
    });

    test('plurals follow the count', () {
      final pt = lookupAppLocalizations(const Locale('pt'));
      final en = lookupAppLocalizations(const Locale('en'));
      final es = lookupAppLocalizations(const Locale('es'));
      expect(pt.settingsScenes(1), '1 cena');
      expect(pt.settingsScenes(3), '3 cenas');
      expect(en.settingsScenesPerDay(1), '1 scene a day');
      expect(es.settingsDays(14), '14 días');
    });
  });
}
