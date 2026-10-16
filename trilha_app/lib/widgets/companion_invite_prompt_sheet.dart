import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_language.dart';
import '../models/walk_companion.dart';
import '../services/companion_service.dart';
import '../services/invite_deep_link_service.dart';
import '../services/progress_service.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Convite de um par — no pico da 1ª missão, não na aba vazia.
/// Devolve o código se o convite foi criado (QR fica a cargo de quem chamou).
Future<String?> showCompanionInvitePromptSheet(
  BuildContext context, {
  String? tomorrowTitle,
  bool dayTwo = false,
}) {
  final progress = context.read<ProgressService>();
  return showAppSheet<String?>(
    context,
    isDismissible: true,
    builder: (_) => _CompanionInvitePromptSheet(
      tomorrowTitle: tomorrowTitle,
      dayTwo: dayTwo,
    ),
  ).whenComplete(() {
    if (progress.companionInviteOffered) return;
    unawaited(progress.markCompanionInviteOffered());
  });
}

class _CompanionInvitePromptSheet extends StatefulWidget {
  final String? tomorrowTitle;
  final bool dayTwo;

  const _CompanionInvitePromptSheet({this.tomorrowTitle, this.dayTwo = false});

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
    final progress = context.read<ProgressService>();
    final companions = context.read<CompanionService>();
    await progress.markCompanionInviteOffered();
    final created = await companions.createInvite(progress);
    if (!mounted) return;
    if (created == null) {
      setState(() => _busy = false);
      await showAppToastFor(
        context,
        message: companions.lastError ?? context.l10n.inviteCreateFailed,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
      if (!mounted) return;
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
    final scene = widget.tomorrowTitle?.trim() ?? '';
    final steps = WalkCompanion.weekTogetherBonusSteps;
    final String body;
    final String title;
    if (widget.dayTwo) {
      title = context.l10n.companionSheetPromptTitleDay2;
      body = context.l10n.companionSheetPromptBodyDay2(steps);
    } else if (scene.isEmpty) {
      title = context.l10n.companionSheetPromptTitle;
      body = context.l10n.companionSheetPromptBody(steps);
    } else {
      title = context.l10n.companionSheetPromptTitle;
      body = context.l10n.companionSheetPromptBodyTomorrow(scene);
    }

    return AppSheetPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSheetHeader(
            eyebrow: context.l10n.companionSheetEyebrow,
            title: title,
            subtitle: body,
            center: true,
          ),
          const SizedBox(height: 20),
          CopperCta(
            label: context.l10n.companionSheetInviteCta,
            onTap: _busy ? null : _invite,
            leading: CinematicGlyph.people,
            busy: _busy,
          ),
          const SizedBox(height: 8),
          GhostCta(
            label: context.l10n.commonNotNow,
            expanded: true,
            onTap: _busy ? null : _dismiss,
          ),
        ],
      ),
    );
  }
}
