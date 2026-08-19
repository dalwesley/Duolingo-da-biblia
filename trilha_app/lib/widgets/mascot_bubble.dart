import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: dark ? Colors.black.withValues(alpha: 0.35) : AppColors.card,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: dark
                    ? AppColors.accent.withValues(alpha: glowing ? 0.85 : 0.65)
                    : Colors.black.withValues(alpha: 0.08),
              ),
              boxShadow: glowing
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.22),
                        blurRadius: 18,
                      ),
                    ]
                  : null,
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
