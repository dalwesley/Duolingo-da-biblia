import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_language.dart';
import '../models/question_report.dart';
import '../services/backend_service.dart';
import '../services/question_report_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Abre o sheet para relatar erro teológico, interpretação, etc.
Future<bool> showQuestionReportSheet(
  BuildContext context, {
  required QuestionReportDraft Function(
    QuestionReportCategory category,
    String comment,
  )
  buildDraft,
}) async {
  final result = await showAppSheet<bool>(
    context,
    isDismissible: true,
    builder: (_) => _QuestionReportSheet(buildDraft: buildDraft),
  );
  return result == true;
}

class _QuestionReportSheet extends StatefulWidget {
  final QuestionReportDraft Function(
    QuestionReportCategory category,
    String comment,
  )
  buildDraft;

  const _QuestionReportSheet({required this.buildDraft});

  @override
  State<_QuestionReportSheet> createState() => _QuestionReportSheetState();
}

class _QuestionReportSheetState extends State<_QuestionReportSheet> {
  QuestionReportCategory? _category;
  final _commentCtrl = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final category = _category;
    if (category == null || _sending) return;

    setState(() {
      _sending = true;
      _error = null;
    });

    final backend = context.read<BackendService>();
    final draft = widget.buildDraft(category, _commentCtrl.text);
    final ok = await QuestionReportService.instance.submit(
      backend: backend,
      draft: draft,
    );

    if (!mounted) return;
    if (!ok) {
      setState(() {
        _sending = false;
        _error = backend.isActive
            ? context.l10n.reportSendError
            : context.l10n.reportSignInRequired;
      });
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final canSend = _category != null && !_sending;

    // Rolagem por fora do painel: AppSheetPanel não limita altura.
    return SingleChildScrollView(
      child: AppSheetPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CinematicIcon(
                  glyph: CinematicGlyph.book,
                  size: AppMetrics.leadingIcon,
                  accent: AppRoles.chrome,
                  glowing: false,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppSheetHeader(title: context.l10n.reportTitle),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: CinematicIcon(
                    glyph: CinematicGlyph.close,
                    size: AppMetrics.iconLg,
                    accent: a.textFaint,
                    framed: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.reportIntro,
              style: AppTypography.body(
                size: 13,
                height: 1.4,
                color: a.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...QuestionReportCategory.values.map((c) {
              final selected = _category == c;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppChoiceTile(
                  selected: selected,
                  onTap: () {
                    ActHaptics.tap();
                    setState(() => _category = c);
                  },
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: AppMetrics.iconMd,
                        color: selected ? AppRoles.selected : a.textFaint,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.label,
                              style: AppTypography.body(
                                size: 14,
                                weight: FontWeight.w700,
                                color: a.text,
                              ),
                            ),
                            Text(
                              c.hint,
                              style: AppTypography.body(
                                size: 12,
                                height: 1.3,
                                color: a.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              maxLines: 3,
              maxLength: 800,
              textCapitalization: TextCapitalization.sentences,
              style: AppTypography.body(size: 14, color: a.text),
              decoration: InputDecoration(
                hintText: context.l10n.reportCommentHint,
                hintStyle: AppTypography.body(size: 14, color: a.textFaint),
                filled: true,
                fillColor: a.text.withValues(alpha: 0.04),
                counterStyle: AppTypography.body(size: 11, color: a.textFaint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  borderSide: BorderSide(color: a.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  borderSide: BorderSide(color: a.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  borderSide: BorderSide(
                    color: AppRoles.selected.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: AppTypography.body(size: 13, color: AppRoles.error),
              ),
            ],
            const SizedBox(height: 12),
            CopperCta(
              label: _sending
                  ? context.l10n.reportSending
                  : context.l10n.reportSend,
              trailing: null,
              busy: _sending,
              onTap: canSend ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
