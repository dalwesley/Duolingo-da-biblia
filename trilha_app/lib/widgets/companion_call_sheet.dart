import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../models/companion_invite.dart';
import '../services/league_service.dart';
import '../services/companion_service.dart';
import '../services/moderation_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'immersive_background.dart';
import 'room_panels.dart' show CaravanInviteRow;
import 'ui_primitives.dart';
import 'user_avatar.dart';
import 'user_moderation_sheet.dart';

/// Chamar alguém da Caravana para o convite aberto [code] — a mesma lista
/// do Grupos, com uma vaga só: chamar outra pessoa troca o chamado.
Future<void> showCompanionCallSheet(
  BuildContext context, {
  required String code,
  required List<LeagueEntry> people,
  required VoidCallback onShareLink,
}) {
  return showAppSheet<void>(
    context,
    builder: (ctx) => _CompanionCallSheet(
      code: code,
      people: people,
      onShareLink: () {
        Navigator.pop(ctx);
        onShareLink();
      },
    ),
  );
}

class _CompanionCallSheet extends StatefulWidget {
  final String code;
  final List<LeagueEntry> people;
  final VoidCallback onShareLink;

  const _CompanionCallSheet({
    required this.code,
    required this.people,
    required this.onShareLink,
  });

  @override
  State<_CompanionCallSheet> createState() => _CompanionCallSheetState();
}

class _CompanionCallSheetState extends State<_CompanionCallSheet> {
  String? _busy;
  String? _error;

  Future<void> _invite(LeagueEntry person) async {
    final uid = person.uid;
    if (uid == null || _busy != null) return;
    setState(() {
      _busy = uid;
      _error = null;
    });
    final companions = context.read<CompanionService>();
    final ok = await companions.inviteDirect(
      code: widget.code,
      toUid: uid,
      toName: person.name,
      progress: context.read<ProgressService>(),
    );
    if (!mounted) return;
    setState(() {
      _busy = null;
      if (!ok) {
        _error = companions.lastError ?? context.l10n.groupInviteSendFailed;
      }
    });
  }

  Future<void> _cancel() async {
    if (_busy != null) return;
    final pending = context.read<CompanionService>().outgoingFor(widget.code);
    if (pending == null) return;
    setState(() {
      _busy = pending.toUid;
      _error = null;
    });
    final ok = await context.read<CompanionService>().cancelDirect(widget.code);
    if (!mounted) return;
    setState(() {
      _busy = null;
      if (!ok) _error = context.l10n.groupInviteUndoFailed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final companions = context.watch<CompanionService>();
    final moderation = context.watch<ModerationService>();
    final called = companions.outgoingFor(widget.code)?.toUid;
    final people = [
      for (final person in widget.people)
        if (!moderation.isBlocked(person.uid)) person,
    ];
    final maxH = MediaQuery.sizeOf(context).height * 0.72;

    return AppSheetPanel(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetHeader(
              title: context.l10n.companionCallTitle,
              subtitle: context.l10n.companionCallSubtitle,
            ),
            const SizedBox(height: AppSpace.md),
            if (people.isEmpty)
              EmptyState(title: context.l10n.groupCallEmpty)
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    for (final person in people)
                      CaravanInviteRow(
                        person: person,
                        pending: person.uid == called,
                        busy: _busy == person.uid,
                        enabled: _busy == null,
                        onInvite: () => _invite(person),
                        onCancel: _cancel,
                      ),
                  ],
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: AppSpace.sm),
              GlassCard(
                padding: AppMetrics.cardPaddingCompact,
                child: Row(
                  children: [
                    const CloudMascot(face: CloudFace.erro, size: 28),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: Text(
                        _error!,
                        style: AppTypography.body(size: 12, color: a.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpace.md),
            GhostCta(
              label: context.l10n.commonSendWhatsApp,
              leading: CinematicGlyph.share,
              expanded: true,
              onTap: widget.onShareLink,
            ),
          ],
        ),
      ),
    );
  }
}

/// Convite de companhia recebido: quem chamou, aceitar ou agora não, e
/// denunciar/bloquear (App Store 1.2).
class CompanionIncomingInviteCard extends StatelessWidget {
  final CompanionInvite invite;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const CompanionIncomingInviteCard({
    super.key,
    required this.invite,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final from = invite.fromName.trim().split(' ').first;
    return GlassCard(
      glow: 0.7,
      tint: AppRoles.presence,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            label: context.l10n.companionInviteLabel,
            accent: AppRoles.presence,
          ),
          const SizedBox(height: AppSpace.sm),
          Row(
            children: [
              UserAvatar(
                name: invite.fromName,
                photoUrl: invite.fromPhotoUrl,
                seed: invite.fromUid,
                radius: AppMetrics.avatarMd,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.companionInviteBody(from),
                  style: AppTypography.title(size: 15, color: a.text),
                ),
              ),
              UserModerationButton(
                uid: invite.fromUid,
                name: invite.fromName,
                source: UserReportSource.companion,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          CopperCta(
            label: context.l10n.juntosAccept,
            leading: CinematicGlyph.check,
            trailing: null,
            dense: true,
            onTap: onAccept,
          ),
          const SizedBox(height: AppSpace.xs),
          Center(
            child: TextCta(label: context.l10n.commonNotNow, onTap: onDecline),
          ),
        ],
      ),
    );
  }
}
