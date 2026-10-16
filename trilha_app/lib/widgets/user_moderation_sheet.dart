import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../l10n/l10n_global.dart';
import '../services/backend_service.dart';
import '../services/moderation_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'ui_primitives.dart';

/// O que aconteceu na folha — quem abriu fecha o perfil se a pessoa sumiu.
enum ModerationOutcome { none, reported, blocked, unblocked }

/// Denunciar ou bloquear outro peregrino (App Store 1.2).
Future<ModerationOutcome> showUserModerationSheet(
  BuildContext context, {
  required String uid,
  required String name,
  required UserReportSource source,
  String? roomCode,
  String? roomName,
}) async {
  ActHaptics.light();
  final displayName = name.trim().isEmpty
      ? context.l10n.moderationUnknownName
      : name.trim();
  final outcome = await showAppSheet<ModerationOutcome>(
    context,
    isDismissible: true,
    builder: (_) => _UserModerationSheet(
      uid: uid,
      name: displayName,
      source: source,
      roomCode: roomCode,
      roomName: roomName,
    ),
  );
  final result = outcome ?? ModerationOutcome.none;
  final l10n = L10n.current;
  final message = switch (result) {
    ModerationOutcome.reported => l10n.moderationReportSent,
    ModerationOutcome.blocked => l10n.moderationBlocked(displayName),
    ModerationOutcome.unblocked => l10n.moderationUnblocked(displayName),
    ModerationOutcome.none => null,
  };
  if (message != null && context.mounted) {
    final face = switch (result) {
      ModerationOutcome.blocked => CloudFace.triste,
      ModerationOutcome.reported ||
      ModerationOutcome.unblocked => CloudFace.sucesso,
      ModerationOutcome.none => CloudFace.sucesso,
    };
    await showAppToastFor(context, message: message, face: face);
  }
  return result;
}

/// Bandeira discreta para pôr ao lado do nome de outra pessoa.
class UserModerationButton extends StatelessWidget {
  final String uid;
  final String name;
  final UserReportSource source;
  final String? roomCode;
  final String? roomName;
  final ValueChanged<ModerationOutcome>? onDone;

  const UserModerationButton({
    super.key,
    required this.uid,
    required this.name,
    required this.source,
    this.roomCode,
    this.roomName,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return IconButton(
      tooltip: context.l10n.moderationMenuLabel,
      onPressed: () async {
        final outcome = await showUserModerationSheet(
          context,
          uid: uid,
          name: name,
          source: source,
          roomCode: roomCode,
          roomName: roomName,
        );
        onDone?.call(outcome);
      },
      icon: CinematicIcon(
        glyph: CinematicGlyph.flag,
        size: AppMetrics.iconMd,
        accent: a.textFaint,
        framed: false,
      ),
    );
  }
}

enum _Step { menu, report, block }

class _UserModerationSheet extends StatefulWidget {
  final String uid;
  final String name;
  final UserReportSource source;
  final String? roomCode;
  final String? roomName;

  const _UserModerationSheet({
    required this.uid,
    required this.name,
    required this.source,
    this.roomCode,
    this.roomName,
  });

  @override
  State<_UserModerationSheet> createState() => _UserModerationSheetState();
}

class _UserModerationSheetState extends State<_UserModerationSheet> {
  final _commentCtrl = TextEditingController();
  _Step _step = _Step.menu;
  UserReportReason? _reason;
  bool _alsoBlock = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReport() async {
    final reason = _reason;
    if (reason == null || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final moderation = ModerationService.instance;
    final ok = await moderation.report(
      backend: context.read<BackendService>(),
      targetUid: widget.uid,
      targetName: widget.name,
      reason: reason,
      source: widget.source,
      comment: _commentCtrl.text,
      roomCode: widget.roomCode,
      roomName: widget.roomName,
    );
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _busy = false;
        _error = context.l10n.moderationReportFailed;
      });
      return;
    }
    if (_alsoBlock && !moderation.isBlocked(widget.uid)) {
      await moderation.block(uid: widget.uid, name: widget.name);
    }
    if (!mounted) return;
    ActHaptics.confirm();
    Navigator.of(context).pop(ModerationOutcome.reported);
  }

  Future<void> _toggleBlock() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final moderation = ModerationService.instance;
    final wasBlocked = moderation.isBlocked(widget.uid);
    final ok = wasBlocked
        ? await moderation.unblock(widget.uid)
        : await moderation.block(uid: widget.uid, name: widget.name);
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _busy = false;
        _error = context.l10n.moderationBlockFailed;
      });
      return;
    }
    ActHaptics.confirm();
    Navigator.of(
      context,
    ).pop(wasBlocked ? ModerationOutcome.unblocked : ModerationOutcome.blocked);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final blocked = context.watch<ModerationService>().isBlocked(widget.uid);

    final (title, subtitle, body) = switch (_step) {
      _Step.menu => (widget.name, l10n.moderationMenuSubtitle, _menu(blocked)),
      _Step.report => (
        l10n.moderationReportTitle(widget.name),
        l10n.moderationReportHint,
        _report(),
      ),
      _Step.block => (
        blocked
            ? l10n.moderationUnblock
            : l10n.moderationBlockConfirm(widget.name),
        blocked
            ? l10n.moderationUnblockHint(widget.name)
            : l10n.moderationBlockHint(widget.name),
        _block(blocked),
      ),
    };

    // Rolagem por fora do painel: AppSheetPanel não limita altura.
    return SingleChildScrollView(
      child: AppSheetPanel(
        tint: _step == _Step.menu ? null : AppRoles.risk,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetHeader(
              face: CloudFace.triste,
              title: title,
              subtitle: subtitle,
            ),
            const SizedBox(height: AppSpace.lg),
            body,
            if (_error != null) ...[
              const SizedBox(height: AppSpace.sm),
              Text(
                _error!,
                style: AppTypography.body(size: 13, color: a.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _menu(bool blocked) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ActionTile(
          glyph: CinematicGlyph.flag,
          label: l10n.moderationReport,
          hint: l10n.moderationReportHint,
          onTap: () => setState(() => _step = _Step.report),
        ),
        const SizedBox(height: AppSpace.sm),
        _ActionTile(
          glyph: CinematicGlyph.lock,
          label: blocked ? l10n.moderationUnblock : l10n.moderationBlock,
          hint: blocked
              ? l10n.moderationUnblockHint(widget.name)
              : l10n.moderationBlockHint(widget.name),
          onTap: () => setState(() => _step = _Step.block),
        ),
        const SizedBox(height: AppSpace.md),
        GhostCta(
          label: l10n.commonCancel,
          expanded: true,
          onTap: () => Navigator.of(context).pop(ModerationOutcome.none),
        ),
      ],
    );
  }

  Widget _report() {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final labels = {
      UserReportReason.offensiveName: l10n.moderationReasonOffensiveName,
      UserReportReason.offensivePhoto: l10n.moderationReasonOffensivePhoto,
      UserReportReason.harassment: l10n.moderationReasonHarassment,
      UserReportReason.spam: l10n.moderationReasonSpam,
      UserReportReason.other: l10n.moderationReasonOther,
    };
    final alreadyBlocked = ModerationService.instance.isBlocked(widget.uid);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final reason in UserReportReason.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.sm),
            child: AppChoiceTile(
              selected: _reason == reason,
              onTap: () {
                ActHaptics.tap();
                setState(() => _reason = reason);
              },
              child: Row(
                children: [
                  Icon(
                    _reason == reason
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: AppMetrics.iconMd,
                    color: _reason == reason ? a.selected : a.textFaint,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      labels[reason]!,
                      style: AppTypography.body(
                        size: 14,
                        weight: FontWeight.w700,
                        color: a.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpace.xs),
        TextField(
          controller: _commentCtrl,
          maxLines: 3,
          maxLength: 800,
          textCapitalization: TextCapitalization.sentences,
          style: AppTypography.body(size: 14, color: a.text),
          decoration: InputDecoration(
            hintText: l10n.moderationCommentHint,
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
              borderSide: BorderSide(color: a.selected.withValues(alpha: 0.7)),
            ),
          ),
        ),
        if (!alreadyBlocked)
          CheckboxListTile(
            value: _alsoBlock,
            onChanged: (v) => setState(() => _alsoBlock = v ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppRoles.risk,
            title: Text(
              l10n.moderationAlsoBlock,
              style: AppTypography.body(
                size: 14,
                weight: FontWeight.w700,
                color: a.text,
              ),
            ),
          ),
        const SizedBox(height: AppSpace.sm),
        CopperCta(
          label: _busy ? l10n.reportSending : l10n.moderationSend,
          trailing: null,
          busy: _busy,
          onTap: _reason != null && !_busy ? _sendReport : null,
        ),
        const SizedBox(height: AppSpace.sm),
        GhostCta(
          label: l10n.commonCancel,
          expanded: true,
          onTap: () => Navigator.of(context).pop(ModerationOutcome.none),
        ),
      ],
    );
  }

  Widget _block(bool blocked) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GhostCta(
          label: blocked
              ? l10n.moderationUnblock
              : l10n.moderationBlockConfirm(widget.name),
          leading: CinematicGlyph.lock,
          danger: !blocked,
          expanded: true,
          onTap: _busy ? null : _toggleBlock,
        ),
        const SizedBox(height: AppSpace.sm),
        GhostCta(
          label: l10n.commonCancel,
          expanded: true,
          onTap: () => Navigator.of(context).pop(ModerationOutcome.none),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final CinematicGlyph glyph;
  final String label;
  final String hint;
  final VoidCallback onTap;

  const _ActionTile({
    required this.glyph,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return AppChoiceTile(
      selected: false,
      onTap: () {
        ActHaptics.tap();
        onTap();
      },
      child: Row(
        children: [
          CinematicIcon(
            glyph: glyph,
            size: AppMetrics.iconLg,
            accent: AppRoles.risk,
            framed: false,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.body(
                    size: 14,
                    weight: FontWeight.w800,
                    color: a.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
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
    );
  }
}
