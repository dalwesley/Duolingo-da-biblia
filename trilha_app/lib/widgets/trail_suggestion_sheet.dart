import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../services/backend_service.dart';
import '../services/trail_suggestion_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Abre o sheet para sugerir um caminho ainda fora do mapa.
Future<bool> showTrailSuggestionSheet(BuildContext context) async {
  final result = await showAppSheet<bool>(
    context,
    isDismissible: true,
    builder: (_) => const _TrailSuggestionSheet(),
  );
  return result == true;
}

class _TrailSuggestionSheet extends StatefulWidget {
  const _TrailSuggestionSheet();

  @override
  State<_TrailSuggestionSheet> createState() => _TrailSuggestionSheetState();
}

class _TrailSuggestionSheetState extends State<_TrailSuggestionSheet> {
  final _textCtrl = TextEditingController();
  final _textFocus = FocusNode();
  TrailSuggestionRealm? _realm;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _textCtrl.dispose();
    _textFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final realm = _realm;
    if (_sending ||
        realm == null ||
        !TrailSuggestionService.isValidText(_textCtrl.text)) {
      return;
    }

    setState(() {
      _sending = true;
      _error = null;
    });
    ActHaptics.light();

    final backend = context.read<BackendService>();
    final ok = await TrailSuggestionService.instance.submit(
      backend: backend,
      text: _textCtrl.text,
      realmId: realm.id,
    );

    if (!mounted) return;
    if (!ok) {
      setState(() {
        _sending = false;
        _error = backend.isActive
            ? context.l10n.suggestionSendError
            : context.l10n.suggestionSignInToSend;
      });
      return;
    }

    Navigator.of(context).pop(true);
  }

  void _pickRealm(TrailSuggestionRealm realm) {
    ActHaptics.tap();
    setState(() => _realm = realm);
    if (!_textFocus.hasFocus) {
      _textFocus.requestFocus();
    }
  }

  String get _ctaHint {
    final hasRealm = _realm != null;
    final hasText = TrailSuggestionService.isValidText(_textCtrl.text);
    if (hasRealm && hasText) return '';
    if (!hasRealm && !hasText) {
      return context.l10n.suggestionTrailHintBoth;
    }
    if (!hasRealm) return context.l10n.suggestionTrailHintRealm;
    return context.l10n.suggestionTrailHintText;
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final canSend =
        _realm != null &&
        TrailSuggestionService.isValidText(_textCtrl.text) &&
        !_sending;
    final paths = TrailSuggestionRealm.values;
    final ranked = paths.take(4).toList();
    final outros = paths.last;

    // Rolagem por fora do painel: AppSheetPanel não limita altura.
    return SingleChildScrollView(
      child: AppSheetPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CinematicIcon(
                  glyph: CinematicGlyph.spark,
                  size: AppMetrics.leadingIcon,
                  accent: AppColors.accent,
                  glowing: false,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.suggestionTrailTitle,
                        style: AppTypography.title(size: 18, color: a.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.suggestionTrailSubtitle,
                        style: AppTypography.body(
                          size: 13,
                          color: a.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: CinematicIcon(
                    glyph: CinematicGlyph.close,
                    size: 22,
                    accent: a.textFaint,
                    framed: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SectionLabel(context.l10n.suggestionTrailRealmLabel),
            const SizedBox(height: 10),
            for (var i = 0; i < ranked.length; i += 2) ...[
              Row(
                children: [
                  Expanded(
                    child: _ChoiceButton(
                      label: ranked[i].label,
                      selected: _realm == ranked[i],
                      onTap: () => _pickRealm(ranked[i]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ChoiceButton(
                      label: ranked[i + 1].label,
                      selected: _realm == ranked[i + 1],
                      onTap: () => _pickRealm(ranked[i + 1]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            _ChoiceButton(
              label: outros.label,
              selected: _realm == outros,
              onTap: () => _pickRealm(outros),
            ),
            const SizedBox(height: 18),
            SectionLabel(context.l10n.suggestionTrailTextLabel),
            const SizedBox(height: 10),
            TextField(
              controller: _textCtrl,
              focusNode: _textFocus,
              maxLines: 3,
              minLines: 3,
              maxLength: TrailSuggestionService.maxText,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (canSend) _submit();
              },
              style: AppTypography.body(size: 14, color: a.text, height: 1.4),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText:
                    _realm?.hint ?? context.l10n.suggestionTrailPlaceholder,
                hintStyle: AppTypography.body(size: 14, color: a.textFaint),
                filled: true,
                fillColor: a.text.withValues(alpha: 0.04),
                counterStyle: AppTypography.body(size: 11, color: a.textFaint),
                contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
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
              Text(
                _error!,
                style: AppTypography.body(size: 13, color: AppColors.error),
              ),
              const SizedBox(height: 8),
            ] else if (_ctaHint.isNotEmpty) ...[
              Text(
                _ctaHint,
                style: AppTypography.body(size: 12, color: a.textFaint),
              ),
              const SizedBox(height: 10),
            ] else
              const SizedBox(height: 4),
            CopperCta(
              label: _sending
                  ? context.l10n.suggestionSending
                  : context.l10n.suggestionSend,
              trailing: CinematicGlyph.spark,
              busy: _sending,
              onTap: canSend ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppSelectChip(
      label: label,
      selected: selected,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
    );
  }
}
