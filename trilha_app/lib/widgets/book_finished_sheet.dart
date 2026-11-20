import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_language.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'confetti_overlay.dart';
import 'ui_primitives.dart';

/// Festa curta do livro concluído: o Anan, o selo dourado, o nome do livro
/// e o dia. Abre ao ler o último capítulo que faltava ou ao terminar a
/// trilha capítulo a capítulo do livro.
Future<void> showBookFinishedSheet(
  BuildContext context, {
  required String bookName,
  DateTime? on,
}) {
  ActHaptics.success();
  SoundService.instance.playComplete(boss: true);
  return showAppSheet<void>(
    context,
    builder: (_) => _BookFinishedSheet(bookName: bookName, on: on),
  );
}

class _BookFinishedSheet extends StatelessWidget {
  final String bookName;
  final DateTime? on;

  const _BookFinishedSheet({required this.bookName, this.on});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final a = Appearance.of(context);
    final day = DateFormat(
      'd MMM y',
      l10n.localeName,
    ).format(on ?? DateTime.now()).replaceAll('.', '');
    return AppSheetPanel(
      tint: AppRoles.reward,
      background: const IgnorePointer(
        child: ConfettiOverlay(active: true, cinematic: true),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpace.sm),
          AnanBeside(
            size: 70,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppRoles.reward.withValues(alpha: 0.14),
                border: Border.all(color: AppRoles.reward, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppRoles.reward.withValues(alpha: 0.35),
                    blurRadius: 30,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const CinematicIcon(
                glyph: CinematicGlyph.star,
                size: 46,
                accent: AppRoles.reward,
                framed: false,
              ),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          SectionLabel(l10n.bookFinishedEyebrow, color: AppRoles.reward),
          const SizedBox(height: AppSpace.xs),
          Text(
            l10n.bookFinishedTitle(bookName),
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 30, color: a.text, height: 1.15),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            day,
            style: AppTypography.label(size: 13, color: a.textSecondary),
          ),
          const SizedBox(height: AppSpace.md),
          Text(
            l10n.bookFinishedBody,
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 15,
              color: a.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          CopperCta(
            label: l10n.commonContinue,
            expanded: true,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: AppSpace.sm),
        ],
      ),
    );
  }
}
