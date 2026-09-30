import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../services/author_suggestion_service.dart';
import '../services/backend_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Abre o sheet para indicar um autor ainda fora do mapa.
Future<bool> showAuthorSuggestionSheet(BuildContext context) async {
  final result = await showAppSheet<bool>(
    context,
    isDismissible: true,
    builder: (_) => const _AuthorSuggestionSheet(),
  );
  return result == true;
}

class _AuthorSuggestionSheet extends StatefulWidget {
  const _AuthorSuggestionSheet();

  @override
  State<_AuthorSuggestionSheet> createState() => _AuthorSuggestionSheetState();
}

class _AuthorSuggestionSheetState extends State<_AuthorSuggestionSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _instagramCtrl.dispose();
    super.dispose();
  }

  bool get _ready => AuthorSuggestionService.isReady(
    name: _nameCtrl.text,
    phone: _phoneCtrl.text,
    email: _emailCtrl.text,
    instagram: _instagramCtrl.text,
  );

  String get _ctaHint {
    if (!AuthorSuggestionService.isValidName(_nameCtrl.text)) {
      return context.l10n.suggestionAuthorHintName;
    }
    if (!AuthorSuggestionService.isValidPhone(_phoneCtrl.text)) {
      return context.l10n.suggestionAuthorHintPhone;
    }
    if (!AuthorSuggestionService.isValidEmail(_emailCtrl.text)) {
      return context.l10n.suggestionAuthorHintEmail;
    }
    if (!AuthorSuggestionService.isValidInstagram(_instagramCtrl.text)) {
      return context.l10n.suggestionAuthorHintInstagram;
    }
    if (!AuthorSuggestionService.hasContact(
      phone: _phoneCtrl.text,
      email: _emailCtrl.text,
      instagram: _instagramCtrl.text,
    )) {
      return context.l10n.suggestionAuthorHintContact;
    }
    return '';
  }

  Future<void> _submit() async {
    if (_sending || !_ready) return;

    setState(() {
      _sending = true;
      _error = null;
    });
    ActHaptics.light();

    final backend = context.read<BackendService>();
    final ok = await AuthorSuggestionService.instance.submit(
      backend: backend,
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      email: _emailCtrl.text,
      instagram: _instagramCtrl.text,
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

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final canSend = _ready && !_sending;

    return SingleChildScrollView(
      child: AppSheetPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CinematicIcon(
                  glyph: CinematicGlyph.people,
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
                        context.l10n.suggestionAuthorTitle,
                        style: AppTypography.title(size: 18, color: a.text),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.suggestionAuthorSubtitle,
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
            _Field(
              label: context.l10n.suggestionAuthorName,
              controller: _nameCtrl,
              hint: context.l10n.suggestionAuthorNameHint,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              maxLength: AuthorSuggestionService.maxName,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 12),
            _Field(
              label: context.l10n.suggestionAuthorPhone,
              controller: _phoneCtrl,
              hint: '(11) 90000-0000',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              maxLength: AuthorSuggestionService.maxPhone,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 12),
            _Field(
              label: context.l10n.suggestionAuthorEmail,
              controller: _emailCtrl,
              hint: context.l10n.suggestionAuthorEmailHint,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              maxLength: AuthorSuggestionService.maxEmail,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 12),
            _Field(
              label: 'Instagram',
              controller: _instagramCtrl,
              hint: context.l10n.suggestionAuthorInstagramHint,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              maxLength: 120,
              onChanged: () => setState(() {}),
              onSubmitted: canSend ? _submit : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: AppTypography.body(size: 13, color: AppColors.error),
              ),
              const SizedBox(height: 8),
            ] else if (_ctaHint.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _ctaHint,
                style: AppTypography.body(size: 12, color: a.textFaint),
              ),
              const SizedBox(height: 10),
            ] else
              const SizedBox(height: 14),
            CopperCta(
              label: _sending
                  ? context.l10n.suggestionSending
                  : context.l10n.suggestionSend,
              trailing: CinematicGlyph.people,
              busy: _sending,
              onTap: canSend ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final int maxLength;
  final VoidCallback onChanged;
  final VoidCallback? onSubmitted;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    required this.keyboardType,
    required this.textInputAction,
    required this.maxLength,
    required this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          onChanged: (_) => onChanged(),
          onSubmitted: (_) => onSubmitted?.call(),
          style: AppTypography.body(size: 14, color: a.text, height: 1.3),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body(size: 14, color: a.textFaint),
            filled: true,
            fillColor: a.text.withValues(alpha: 0.04),
            counterText: '',
            contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
      ],
    );
  }
}
