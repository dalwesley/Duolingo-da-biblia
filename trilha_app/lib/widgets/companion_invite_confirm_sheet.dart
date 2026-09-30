import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'invite_qr_sheet.dart';
import 'ui_primitives.dart';

/// Confirma entrada na companhia com o código já resolvido (sem digitar).
Future<bool> showCompanionInviteConfirmSheet(
  BuildContext context, {
  required String code,
}) {
  ActHaptics.light();
  return showAppSheet<bool>(
    context,
    builder: (ctx) => _CompanionInviteConfirmSheet(code: code),
  ).then((v) => v == true);
}

class _CompanionInviteConfirmSheet extends StatelessWidget {
  final String code;

  const _CompanionInviteConfirmSheet({required this.code});

  @override
  Widget build(BuildContext context) {
    return AppSheetPanel(
      tint: AppRoles.chrome,
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
              glyph: CinematicGlyph.people,
              size: AppMetrics.leadingIcon,
              accent: AppRoles.chrome,
              glowing: true,
            ),
            title: context.l10n.companionSheetInviteConfirmTitle,
            subtitle: context.l10n.companionSheetInviteConfirmSubtitle,
            center: true,
          ),
          const SizedBox(height: 18),
          InsetPanel(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              code,
              textAlign: TextAlign.center,
              style: inviteCodeStyle(Appearance.of(context)),
            ),
          ),
          const SizedBox(height: 14),
          CopperCta(
            label: context.l10n.inviteAcceptCta,
            onTap: () => Navigator.pop(context, true),
            trailing: null,
            dense: true,
          ),
          const SizedBox(height: 8),
          GhostCta(
            label: context.l10n.commonNotNow,
            expanded: true,
            onTap: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
  }
}
