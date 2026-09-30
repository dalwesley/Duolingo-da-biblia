import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../models/walk_companion.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';
import 'confetti_overlay.dart';

/// Momento de celebração quando a companhia é formada.
Future<void> showCompanionFormedSheet(
  BuildContext context, {
  String? partnerName,
}) {
  ActHaptics.confirm();
  return showAppSheet<void>(
    context,
    builder: (ctx) => _CompanionFormedSheet(partnerName: partnerName),
  );
}

class _CompanionFormedSheet extends StatelessWidget {
  final String? partnerName;

  const _CompanionFormedSheet({this.partnerName});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final name = partnerName?.trim();
    final hasName = name != null && name.isNotEmpty && name != 'Companheiro';

    return AppSheetPanel(
      tint: AppColors.accent,
      background: const ConfettiOverlay(active: true, cinematic: true),
      padding: const EdgeInsets.fromLTRB(
        AppSpace.xxl,
        AppSpace.screen + 8,
        AppSpace.xxl,
        AppSpace.screen,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          const Center(
            child: CinematicIcon(
              glyph: CinematicGlyph.people,
              size: 56,
              accent: AppColors.accent,
              glowing: true,
            ),
          ),
          const SizedBox(height: 20),
          AppSheetHeader(
            title: context.l10n.companionSheetFormedTitle,
            center: true,
            celebration: true,
          ),
          const SizedBox(height: 10),
          Text(
            hasName
                ? context.l10n.companionSheetFormedBodyNamed(
                    name,
                    WalkCompanion.weekTogetherBonusSteps,
                  )
                : context.l10n.companionSheetFormedBody(
                    WalkCompanion.weekTogetherBonusSteps,
                  ),
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              height: 1.45,
              color: a.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          CopperCta(
            label: context.l10n.companionSheetFormedCta,
            onTap: () => Navigator.pop(context),
            trailing: null,
            dense: true,
          ),
        ],
      ),
    );
  }
}
