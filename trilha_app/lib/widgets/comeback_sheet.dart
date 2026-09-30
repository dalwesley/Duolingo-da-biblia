import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';
import '../l10n/app_language.dart';

/// Sheet de retorno — sequência em espera + CTA para a próxima cena.
Future<void> showComebackSheet(
  BuildContext context, {
  required VoidCallback onContinue,
}) {
  return showAppSheet<void>(
    context,
    isDismissible: true,
    builder: (_) => _ComebackSheet(onContinue: onContinue),
  );
}

class _ComebackSheet extends StatelessWidget {
  final VoidCallback onContinue;

  const _ComebackSheet({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final a = Appearance.of(context);
    final days = progress.daysSinceLastPlayed;
    final l10n = context.l10n;
    final name = progress.userName.trim().isEmpty
        ? l10n.homeDefaultName
        : progress.userName.trim().split(' ').first;

    return AppSheetPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSheetHeader(
            leading: const CinematicIcon(
              glyph: CinematicGlyph.flame,
              size: 56,
              accent: AppColors.streak,
              glowing: false,
            ),
            eyebrow: l10n.comebackEyebrow,
            eyebrowColor: AppColors.streak.withValues(alpha: 0.85),
            title: l10n.comebackTitle,
            subtitle: days >= 2
                ? l10n.comebackSubtitleGap(
                    name,
                    days,
                    ProgressService.comebackBonusSteps,
                  )
                : l10n.comebackSubtitle(
                    name,
                    ProgressService.comebackBonusSteps,
                  ),
            center: true,
          ),
          const SizedBox(height: 20),
          CopperCta(
            label: l10n.commonContinue,
            onTap: () async {
              await progress.acknowledgeComeback();
              if (!context.mounted) return;
              Navigator.of(context).pop();
              onContinue();
            },
          ),
          const SizedBox(height: 8),
          TextCta(
            label: l10n.commonNotNow,
            color: a.textFaint,
            onTap: () async {
              await progress.acknowledgeComeback();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
