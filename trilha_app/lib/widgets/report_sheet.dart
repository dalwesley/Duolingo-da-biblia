import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'ui_primitives.dart';

/// Uma categoria escolhível no sheet de relato.
class ReportChoice<T> {
  final T value;
  final String label;
  final String hint;

  const ReportChoice({
    required this.value,
    required this.label,
    required this.hint,
  });
}

/// Sheet de relato: escolhe a categoria, comenta (opcional) e envia.
/// [onSubmit] devolve se foi enviado; em falha o sheet fica aberto com o
/// erro de [onSubmitError].
Future<bool> showReportSheet<T>(
  BuildContext context, {
  required String title,
  required String intro,
  required List<ReportChoice<T>> choices,
  required Future<bool> Function(T value, String comment) onSubmit,
  required String Function() onSubmitError,
  String? commentHint,
  CloudFace face = CloudFace.triste,
}) async {
  final result = await showAppSheet<bool>(
    context,
    isDismissible: true,
    builder: (_) => _ReportSheet<T>(
      title: title,
      intro: intro,
      choices: choices,
      onSubmit: onSubmit,
      onSubmitError: onSubmitError,
      commentHint: commentHint,
      face: face,
    ),
  );
  return result == true;
}

class _ReportSheet<T> extends StatefulWidget {
  final String title;
  final String intro;
  final List<ReportChoice<T>> choices;
  final Future<bool> Function(T value, String comment) onSubmit;
  final String Function() onSubmitError;
  final String? commentHint;
  final CloudFace face;

  const _ReportSheet({
    required this.title,
    required this.intro,
    required this.choices,
    required this.onSubmit,
    required this.onSubmitError,
    required this.commentHint,
    required this.face,
  });

  @override
  State<_ReportSheet<T>> createState() => _ReportSheetState<T>();
}

class _ReportSheetState<T> extends State<_ReportSheet<T>> {
  T? _selected;
  final _commentCtrl = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final selected = _selected;
    if (selected == null || _sending) return;

    setState(() {
      _sending = true;
      _error = null;
    });

    final ok = await widget.onSubmit(selected, _commentCtrl.text);

    if (!mounted) return;
    if (!ok) {
      setState(() {
        _sending = false;
        _error = widget.onSubmitError();
      });
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final canSend = _selected != null && !_sending;

    // Rolagem por fora do painel: AppSheetPanel não limita altura.
    return SingleChildScrollView(
      child: AppSheetPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppSheetHeader(face: widget.face, title: widget.title),
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
              widget.intro,
              style: AppTypography.body(
                size: 13,
                height: 1.4,
                color: a.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.choices.map((c) {
              final selected = _selected == c.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppChoiceTile(
                  selected: selected,
                  onTap: () {
                    ActHaptics.tap();
                    setState(() => _selected = c.value);
                  },
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: AppMetrics.iconMd,
                        color: selected ? a.selected : a.textFaint,
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
                hintText: widget.commentHint ?? context.l10n.reportCommentHint,
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
                    color: a.selected.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: AppTypography.body(size: 13, color: a.textSecondary),
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
