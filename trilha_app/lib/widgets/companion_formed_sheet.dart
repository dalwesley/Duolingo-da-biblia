import 'package:flutter/material.dart';
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
          const AppSheetHeader(
            title: 'Companhia formada',
            center: true,
            celebration: true,
          ),
          const SizedBox(height: 10),
          Text(
            hasName
                ? 'Agora você e $name caminham juntos.\nFechem os 7 dias da semana: +${WalkCompanion.weekTogetherBonusSteps} passos na jornada para os dois.'
                : 'Vocês caminham juntos agora.\nFechem os 7 dias da semana: +${WalkCompanion.weekTogetherBonusSteps} passos na jornada para os dois.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              height: 1.45,
              color: a.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          CopperCta(
            label: 'Andar juntos',
            onTap: () => Navigator.pop(context),
            trailing: null,
            dense: true,
          ),
        ],
      ),
    );
  }
}
