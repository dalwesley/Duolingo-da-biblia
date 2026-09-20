import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/backend_service.dart';
import '../services/trail_suggestion_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Abre o sheet para sugerir um caminho ainda fora do mapa.
Future<bool> showTrailSuggestionSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
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
    HapticFeedback.lightImpact();

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
            ? 'Não foi possível enviar. Tente de novo.'
            : 'Entre para enviar a sugestão.';
      });
      return;
    }

    Navigator.of(context).pop(true);
  }

  void _pickRealm(TrailSuggestionRealm realm) {
    HapticFeedback.selectionClick();
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
      return 'Escolha um caminho e descreva a trilha.';
    }
    if (!hasRealm) return 'Escolha onde essa trilha encaixa.';
    return 'Escreva a trilha — pelo menos 4 letras.';
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final canSend = _realm != null &&
        TrailSuggestionService.isValidText(_textCtrl.text) &&
        !_sending;
    final paths = TrailSuggestionRealm.values;
    final ranked = paths.take(4).toList();
    final outros = paths.last;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + bottom),
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
              Center(
                child: Container(
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const CinematicIcon(
                    glyph: CinematicGlyph.spark,
                    size: 40,
                    accent: AppColors.accent,
                    glowing: false,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sugerir uma trilha',
                          style: AppTypography.title(size: 18, color: a.text),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'O que ainda falta no mapa?',
                          style: AppTypography.body(
                            size: 13,
                            color: a.textMuted(0.68),
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
                      accent: a.textMuted(0.55),
                      framed: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'ONDE ENCAIXA',
                style: AppTypography.label(
                  size: 11,
                  letterSpacing: 1.6,
                  color: a.textMuted(0.62),
                ),
              ),
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
              Text(
                'A TRILHA',
                style: AppTypography.label(
                  size: 11,
                  letterSpacing: 1.6,
                  color: a.textMuted(0.62),
                ),
              ),
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
                style: AppTypography.body(size: 15, color: a.text, height: 1.4),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: _realm?.hint ??
                      'Escolha um caminho e descreva a trilha…',
                  hintStyle: AppTypography.body(
                    size: 14,
                    color: a.textMuted(0.42),
                  ),
                  filled: true,
                  fillColor: a.text.withValues(alpha: 0.04),
                  counterStyle: AppTypography.body(
                    size: 11,
                    color: a.textMuted(0.4),
                  ),
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
                  style: AppTypography.body(
                    size: 12,
                    color: a.textMuted(0.55),
                  ),
                ),
                const SizedBox(height: 10),
              ] else
                const SizedBox(height: 4),
              CopperCta(
                label: _sending ? 'Enviando…' : 'Enviar sugestão',
                trailing: CinematicGlyph.spark,
                busy: _sending,
                onTap: canSend ? _submit : null,
              ),
            ],
          ),
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
    final a = Appearance.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          alignment: Alignment.center,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppMetrics.accentFill(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: selected
                  ? AppMetrics.accentBorder(alpha: 0.75)
                  : a.cardBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w700,
                color: selected ? AppColors.accent : a.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
