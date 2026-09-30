import 'package:flutter/material.dart';
import 'package:trilha_app/l10n/app_language.dart';

/// MaterialApp mínimo com as traduções do app, para testes de widget.
Widget l10nApp(Widget home, {Locale locale = const Locale('pt')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  );
}
