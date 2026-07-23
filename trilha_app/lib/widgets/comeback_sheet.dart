import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

/// Sheet de retorno — a caravana te espera + CTA para o próximo passo.
Future<void> showComebackSheet(
  BuildContext context, {
  required VoidCallback onContinue,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
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
    final bottom = MediaQuery.paddingOf(context).bottom;
    final days = progress.daysSinceLastPlayed;
    final name = progress.userName.trim().isEmpty
        ? 'peregrino'
        : progress.userName.trim().split(' ').first;
    final daysLabel = days == 1 ? '1 dia' : '$days dias';

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(20, 18, 20, 16 + bottom),
      decoration: BoxDecoration(
        color: a.cardFill,
        gradient: a.cardGradient,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: a.cardBorder),
        boxShadow: AppTheme.cardShadow(elevated: true),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.flame,
            size: 56,
            accent: AppColors.streak,
            glowing: false,
          ),
          const SizedBox(height: 14),
          Text(
            'A caravana te espera',
            textAlign: TextAlign.center,
            style: AppTypography.title(size: 20, color: a.text),
          ),
          const SizedBox(height: 8),
          Text(
            days >= 2
                ? '$name, faz $daysLabel que a chama esfriou. Um passo basta — e você ganha +${ProgressService.comebackBonusSteps} passos de boas-vindas.'
                : '$name, a caravana sentiu sua falta. Um passo reacende a chama — +${ProgressService.comebackBonusSteps} passos te esperam.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              height: 1.4,
              weight: FontWeight.w600,
              color: a.textMuted(0.72),
            ),
          ),
          const SizedBox(height: 20),
          CopperCta(
            label: 'Continuar a caminhada',
            onTap: () async {
              HapticFeedback.lightImpact();
              await progress.acknowledgeComeback();
              if (!context.mounted) return;
              Navigator.of(context).pop();
              onContinue();
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              await progress.acknowledgeComeback();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(
              'Agora não',
              style: AppTypography.body(
                weight: FontWeight.w700,
                color: a.textMuted(0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
