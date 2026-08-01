import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';
import 'confetti_overlay.dart';

/// Momento de celebração quando a companhia é formada.
Future<void> showCompanionFormedSheet(
  BuildContext context, {
  String? partnerName,
}) {
  HapticFeedback.mediumImpact();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _CompanionFormedSheet(partnerName: partnerName),
  );
}

class _CompanionFormedSheet extends StatelessWidget {
  final String? partnerName;

  const _CompanionFormedSheet({this.partnerName});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final name = partnerName?.trim();
    final hasName = name != null && name.isNotEmpty && name != 'Companheiro';

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpace.md, 0, AppSpace.md, AppSpace.md),
      decoration: BoxDecoration(
        color: AppColors.night,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(
            child: ConfettiOverlay(active: true, cinematic: true),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpace.xxl,
              AppSpace.screen + 8,
              AppSpace.xxl,
              AppSpace.screen + bottom,
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
                const SizedBox(height: 28),
                const Center(
                  child: CinematicIcon(
                    glyph: CinematicGlyph.people,
                    size: 56,
                    accent: AppColors.accent,
                    glowing: true,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Companhia formada',
                  textAlign: TextAlign.center,
                  style: AppTypography.display(
                    size: 28,
                    weight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  hasName
                      ? 'Agora você e $name caminham juntos.\nQuando os dois dão um passo no dia, a companhia avança.'
                      : 'Vocês caminham juntos agora.\nQuando os dois dão um passo no dia, a companhia avança.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body(
                    size: 14,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      gradient: AppGradients.gold,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Text(
                      'ANDAR JUNTOS',
                      textAlign: TextAlign.center,
                      style: AppTypography.cta(size: 13)
                          .copyWith(letterSpacing: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
