import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'trilha_mascot.dart';

class MascotBubble extends StatelessWidget {
  final String message;
  final bool dark;

  const MascotBubble({super.key, required this.message, this.dark = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const TrilhaMascot(size: 48, glowing: false),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: dark ? Colors.black.withValues(alpha: 0.35) : AppColors.card,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: dark ? AppColors.accent.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.08)),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.35,
                color: dark ? Colors.white.withValues(alpha: 0.9) : AppColors.text,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
