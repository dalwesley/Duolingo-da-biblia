import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_language.dart';
import '../models/app_report.dart';
import '../services/backend_service.dart';
import '../services/app_report_service.dart';
import 'report_sheet.dart';
import 'ui_primitives.dart';

/// Abre o sheet para relatar um problema do app (fora das perguntas) e
/// agradece quando o relato sai.
Future<void> showAppReportSheet(BuildContext context) async {
  final backend = context.read<BackendService>();
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).languageCode;
  final ok = await showReportSheet<AppReportCategory>(
    context,
    title: l10n.appReportTitle,
    intro: l10n.appReportIntro,
    commentHint: l10n.appReportCommentHint,
    choices: [
      for (final c in AppReportCategory.values)
        ReportChoice(value: c, label: c.label, hint: c.hint),
    ],
    onSubmit: (category, comment) => AppReportService.instance.submit(
      backend: backend,
      category: category,
      comment: comment,
      locale: locale,
    ),
    onSubmitError: () =>
        backend.isActive ? l10n.reportSendError : l10n.reportSignInRequired,
  );
  if (!context.mounted || !ok) return;
  showAppToastFor(context, message: l10n.appReportSent);
}
