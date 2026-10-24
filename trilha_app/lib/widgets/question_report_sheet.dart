import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_language.dart';
import '../models/question_report.dart';
import '../services/backend_service.dart';
import '../services/question_report_service.dart';
import 'report_sheet.dart';

/// Abre o sheet para relatar erro teológico, interpretação, etc.
Future<bool> showQuestionReportSheet(
  BuildContext context, {
  required QuestionReportDraft Function(
    QuestionReportCategory category,
    String comment,
  )
  buildDraft,
}) {
  final backend = context.read<BackendService>();
  final l10n = context.l10n;
  return showReportSheet<QuestionReportCategory>(
    context,
    title: l10n.reportTitle,
    intro: l10n.reportIntro,
    choices: [
      for (final c in QuestionReportCategory.values)
        ReportChoice(value: c, label: c.label, hint: c.hint),
    ],
    onSubmit: (category, comment) => QuestionReportService.instance.submit(
      backend: backend,
      draft: buildDraft(category, comment),
    ),
    onSubmitError: () =>
        backend.isActive ? l10n.reportSendError : l10n.reportSignInRequired,
  );
}
