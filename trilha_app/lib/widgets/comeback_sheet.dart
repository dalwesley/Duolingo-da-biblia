import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

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
    final name = progress.userName.trim().isEmpty
        ? 'aprendiz'
        : progress.userName.trim().split(' ').first;
    final daysLabel = days == 1 ? '1 dia' : '$days dias';

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
            eyebrow: 'O peregrino',
            eyebrowColor: AppColors.streak.withValues(alpha: 0.85),
            title: 'Sua sequência te espera',
            subtitle: days >= 2
                ? '$name, faz $daysLabel sem uma cena. Uma só basta — e você ganha +${ProgressService.comebackBonusSteps} passos de boas-vindas.'
                : '$name, a caravana sentiu sua falta. Uma cena retoma a sequência — +${ProgressService.comebackBonusSteps} passos te esperam.',
            center: true,
          ),
          const SizedBox(height: 20),
          CopperCta(
            label: 'Continuar',
            onTap: () async {
              await progress.acknowledgeComeback();
              if (!context.mounted) return;
              Navigator.of(context).pop();
              onContinue();
            },
          ),
          const SizedBox(height: 8),
          TextCta(
            label: 'Agora não',
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
