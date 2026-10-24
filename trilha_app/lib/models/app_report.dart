import '../l10n/l10n_global.dart';

/// Categorias de relato sobre o app em si (fora das perguntas das trilhas).
enum AppReportCategory {
  bug,
  account,
  subscription,
  suggestion,
  other;

  String get id => name;

  String get label => switch (this) {
    bug => L10n.current.appReportCategoryBug,
    account => L10n.current.appReportCategoryAccount,
    subscription => L10n.current.appReportCategorySubscription,
    suggestion => L10n.current.appReportCategorySuggestion,
    other => L10n.current.appReportCategoryOther,
  };

  String get hint => switch (this) {
    bug => L10n.current.appReportHintBug,
    account => L10n.current.appReportHintAccount,
    subscription => L10n.current.appReportHintSubscription,
    suggestion => L10n.current.appReportHintSuggestion,
    other => L10n.current.appReportHintOther,
  };
}
