import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/companion_service.dart';
import '../services/invite_deep_link_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Convite de um par — no pico da 1ª missão, não na aba vazia.
/// Devolve o código se o convite foi criado (QR fica a cargo de quem chamou).
Future<String?> showCompanionInvitePromptSheet(BuildContext context) {
  final progress = context.read<ProgressService>();
  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (_) => const _CompanionInvitePromptSheet(),
  ).whenComplete(() {
    if (progress.companionInviteOffered) return;
    unawaited(progress.markCompanionInviteOffered());
  });
}

class _CompanionInvitePromptSheet extends StatefulWidget {
  const _CompanionInvitePromptSheet();

  @override
  State<_CompanionInvitePromptSheet> createState() =>
      _CompanionInvitePromptSheetState();
}

class _CompanionInvitePromptSheetState
    extends State<_CompanionInvitePromptSheet> {
  bool _busy = false;

  Future<void> _dismiss() async {
    await context.read<ProgressService>().markCompanionInviteOffered();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _invite() async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.mediumImpact();
    final progress = context.read<ProgressService>();
    final companions = context.read<CompanionService>();
    await progress.markCompanionInviteOffered();
    final created = await companions.createInvite(progress);
    if (!mounted) return;
    if (created == null) {
      setState(() => _busy = false);
      showAppToastFor(
        context,
        message: companions.lastError ?? 'Não foi possível criar o convite',
        glyph: CinematicGlyph.echo,
        tone: AppToastTone.warn,
      );
      Navigator.of(context).pop();
      return;
    }
    await Clipboard.setData(
      ClipboardData(text: InviteDeepLinkService.companionUri(created.code)),
    );
    if (!mounted) return;
    Navigator.of(context).pop(created.code);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(20, 18, 20, 16 + bottom),
      decoration: BoxDecoration(
        color: a.cardFill,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: a.cardBorder),
        boxShadow: AppTheme.cardShadow(elevated: true),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CinematicIcon(
            glyph: CinematicGlyph.people,
            size: 56,
            accent: AppColors.accent,
            glowing: true,
          ),
          const SizedBox(height: 14),
          Text(
            'COMPANHIA',
            style: AppTypography.label(
              letterSpacing: 1.5,
              color: AppColors.accent.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Chame alguém para caminhar',
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 20, color: a.text),
          ),
          const SizedBox(height: 8),
          Text(
            'Um amigo. Um aceno quando a trilha empoeira. Não é ranking — é presença.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              height: 1.4,
              weight: FontWeight.w600,
              color: a.textMuted(0.72),
            ),
          ),
          const SizedBox(height: 20),
          CopperCta(
            label: 'Chamar um companheiro',
            onTap: _busy ? null : _invite,
            leading: CinematicGlyph.people,
            busy: _busy,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _busy ? null : _dismiss,
            child: Text(
              'Agora não',
              style: AppTypography.body(
                weight: FontWeight.w700,
                color: a.textMuted(0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
