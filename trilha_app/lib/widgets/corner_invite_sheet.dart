import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/corner_challenge.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

Future<bool> showCornerInviteSheet(
  BuildContext context, {
  required CornerProposal proposal,
  required String peerName,
}) {
  HapticFeedback.lightImpact();
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _CornerInviteSheet(
      proposal: proposal,
      peerName: peerName,
    ),
  ).then((v) => v == true);
}

class _CornerInviteSheet extends StatelessWidget {
  final CornerProposal proposal;
  final String peerName;

  const _CornerInviteSheet({
    required this.proposal,
    required this.peerName,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpace.md,
        0,
        AppSpace.md,
        AppSpace.md,
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpace.xxl,
        AppSpace.screen,
        AppSpace.xxl,
        AppSpace.screen + bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.night,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.65)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: CinematicIcon(
              glyph: CinematicGlyph.flag,
              size: 44,
              accent: AppColors.accent,
              glowing: true,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            CornerCopy.inviteTitle(proposal.missionTitle),
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 24,
              weight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CornerCopy.inviteBody(peerName),
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 22),
            CopperCta(
              label: CornerCopy.ctaChallenge,
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
