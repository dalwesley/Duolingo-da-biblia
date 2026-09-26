import 'package:flutter/material.dart';
import '../models/corner_challenge.dart';
import '../theme/app_theme.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

Future<bool> showCornerInviteSheet(
  BuildContext context, {
  required CornerProposal proposal,
  required String peerName,
}) {
  ActHaptics.light();
  return showAppSheet<bool>(
    context,
    builder: (ctx) =>
        _CornerInviteSheet(proposal: proposal, peerName: peerName),
  ).then((v) => v == true);
}

class _CornerInviteSheet extends StatelessWidget {
  final CornerProposal proposal;
  final String peerName;

  const _CornerInviteSheet({required this.proposal, required this.peerName});

  @override
  Widget build(BuildContext context) {
    return AppSheetPanel(
      tint: AppColors.accent,
      padding: const EdgeInsets.fromLTRB(
        AppSpace.xxl,
        AppSpace.md,
        AppSpace.xxl,
        AppSpace.screen,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(
            leading: const CinematicIcon(
              glyph: CinematicGlyph.flag,
              size: 44,
              accent: AppColors.accent,
              glowing: true,
            ),
            title: CornerCopy.inviteTitle(proposal.missionTitle),
            subtitle: CornerCopy.inviteBody(peerName),
            center: true,
          ),
          const SizedBox(height: 22),
          CopperCta(
            label: CornerCopy.ctaInvite,
            leading: CinematicGlyph.flag,
            trailing: null,
            onTap: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 8),
          GhostCta(
            label: 'Agora não',
            expanded: true,
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
