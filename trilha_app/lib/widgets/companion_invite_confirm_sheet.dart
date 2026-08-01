import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';

/// Confirma entrada na companhia com o código já resolvido (sem digitar).
Future<bool> showCompanionInviteConfirmSheet(
  BuildContext context, {
  required String code,
}) {
  HapticFeedback.lightImpact();
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _CompanionInviteConfirmSheet(code: code),
  ).then((v) => v == true);
}

class _CompanionInviteConfirmSheet extends StatelessWidget {
  final String code;

  const _CompanionInviteConfirmSheet({required this.code});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpace.md, 0, AppSpace.md, AppSpace.md),
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
              glyph: CinematicGlyph.people,
              size: 44,
              accent: AppColors.accent,
              glowing: true,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Convite de companhia',
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 24,
              weight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Alguém te chamou para caminhar junto.\nUm toque — sem digitar código.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 13,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              code,
              textAlign: TextAlign.center,
              style: AppTypography.title(
                size: 22,
                weight: FontWeight.w900,
                color: AppColors.accent,
              ).copyWith(letterSpacing: 6),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: AppGradients.gold,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Text(
                'ACEITAR CONVITE',
                textAlign: TextAlign.center,
                style: AppTypography.cta(size: 13).copyWith(letterSpacing: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Agora não',
              style: AppTypography.title(
                size: 13,
                weight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
