import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/content_filter.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';
import '../l10n/app_language.dart';

/// Pede o nome a quem ainda está com o nome provisório ("Aprendiz").
/// Aberto pela saudação da Home.
Future<void> showNamePromptSheet(BuildContext context) {
  return showAppSheet<void>(context, builder: (_) => const _NamePromptSheet());
}

class _NamePromptSheet extends StatefulWidget {
  const _NamePromptSheet();

  @override
  State<_NamePromptSheet> createState() => _NamePromptSheetState();
}

class _NamePromptSheetState extends State<_NamePromptSheet> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    if (!ContentFilter.isAllowed(name) ||
        ProgressService.isPlaceholderUserName(name)) {
      showAppToastFor(
        context,
        message: context.l10n.contentNameNotAllowed,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
      return;
    }
    ActHaptics.light();
    await context.read<ProgressService>().setUserName(name);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final ready = _controller.text.trim().isNotEmpty;

    return AppSheetPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSheetHeader(
            center: true,
            title: l10n.nameSheetTitle,
            subtitle: l10n.nameSheetSubtitle,
          ),
          const SizedBox(height: AppSpace.lg),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 24,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            style: AppTypography.display(size: 20, color: a.text),
            cursorColor: a.selected,
            decoration: InputDecoration(
              counterText: '',
              hintText: l10n.onboardingNameHint,
              hintStyle: AppTypography.display(
                size: 20,
                weight: FontWeight.w700,
                color: a.textFaint,
              ),
              filled: false,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: InputBorder.none,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: a.cardBorder),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: a.selected, width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          CopperCta(label: l10n.commonSave, onTap: ready ? _save : null),
          const SizedBox(height: 8),
          TextCta(
            label: l10n.commonNotNow,
            color: a.textFaint,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
