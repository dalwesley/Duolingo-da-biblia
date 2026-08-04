import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/question_report.dart';
import '../services/backend_service.dart';
import '../services/question_report_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Abre o sheet para relatar erro teológico, interpretação, etc.
Future<bool> showQuestionReportSheet(
  BuildContext context, {
  required QuestionReportDraft Function(QuestionReportCategory category, String comment)
      buildDraft,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (_) => _QuestionReportSheet(buildDraft: buildDraft),
  );
  return result == true;
}

class _QuestionReportSheet extends StatefulWidget {
  final QuestionReportDraft Function(QuestionReportCategory category, String comment)
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
    HapticFeedback.lightImpact();

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
            ? 'Não foi possível enviar. Tente de novo.'
            : 'Entre com Google para enviar o relato.';
      });
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final canSend = _category != null && !_sending;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: EdgeInsets.fromLTRB(20, 18, 20, 16 + bottom),
        decoration: BoxDecoration(
          color: a.cardFill,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: a.cardBorder),
          boxShadow: AppTheme.cardShadow(elevated: true),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CinematicIcon(
                    glyph: CinematicGlyph.book,
                    size: 40,
                    accent: AppColors.accent,
                    glowing: false,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Relatar problema',
                      style: AppTypography.title(size: 18, color: a.text),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: Icon(Icons.close, color: a.textMuted(0.55)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Ajude a melhorar a trilha — erro teológico, interpretação, resposta ou texto.',
                style: AppTypography.body(
                  size: 13,
                  height: 1.4,
                  color: a.textMuted(0.72),
                ),
              ),
              const SizedBox(height: 16),
              ...QuestionReportCategory.values.map((c) {
                final selected = _category == c;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _category = c);
                      },
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppMetrics.accentFill(alpha: 0.18)
                              : a.text.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          border: Border.all(
                            color: selected
                                ? AppMetrics.accentBorder(alpha: 0.75)
                                : a.cardBorder,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              size: 20,
                              color: selected
                                  ? AppColors.accent
                                  : a.textMuted(0.45),
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
                                      color: a.textMuted(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  hintText: 'Opcional: conte o que parece errado…',
                  hintStyle: AppTypography.body(
                    size: 14,
                    color: a.textMuted(0.45),
                  ),
                  filled: true,
                  fillColor: a.text.withValues(alpha: 0.04),
                  counterStyle: AppTypography.body(
                    size: 11,
                    color: a.textMuted(0.4),
                  ),
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
                      color: AppColors.accent.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: AppTypography.body(
                    size: 13,
                    color: AppColors.error,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Opacity(
                opacity: canSend ? 1 : 0.45,
                child: CopperCta(
                  label: _sending ? 'Enviando…' : 'Enviar relato',
                  trailing: null,
                  onTap: canSend ? _submit : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
