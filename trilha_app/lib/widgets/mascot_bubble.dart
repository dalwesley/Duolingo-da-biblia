import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'ui_primitives.dart';
import 'trilha_mascot.dart';

class MascotBubble extends StatelessWidget {
  final String message;
  final bool dark;
  final bool glowing;

  const MascotBubble({
    super.key,
    required this.message,
    this.dark = true,
    this.glowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TrilhaMascot(size: glowing ? 56 : 48, glowing: glowing),
        const SizedBox(width: 12),
        Expanded(
          // Balão de fala: canto do mascote reto (a “cauda”), demais no
          // raio de card — por isso não é GlassCard.
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: dark
                  ? Colors.black.withValues(alpha: 0.35)
                  : AppColors.card,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppMetrics.cardRadius),
                topRight: Radius.circular(AppMetrics.cardRadius),
                bottomRight: Radius.circular(AppMetrics.cardRadius),
              ),
              border: Border.all(
                color: dark
                    ? AppMetrics.accentBorder(alpha: glowing ? 0.85 : 0.65)
                    : Colors.black.withValues(alpha: 0.08),
                width: AppMetrics.cardBorderWidth,
              ),
              boxShadow: glowing ? AppMetrics.cardShadow(elevated: true) : null,
            ),
            child: Text(
              message,
              style: AppTypography.body(
                size: 14,
                weight: FontWeight.w700,
                height: 1.35,
                color: dark
                    ? AppColors.textOnDark.withValues(alpha: 0.92)
                    : AppColors.text,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
