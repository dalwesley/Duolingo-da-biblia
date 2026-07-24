import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Poço circular — fundo navy + borda no amarelo do CTA (sem gradiente dourado).
class IconWell extends StatelessWidget {
  final double size;
  final Color? accent;
  final bool glowing;
  final Widget child;

  const IconWell({
    super.key,
    required this.size,
    required this.child,
    this.accent,
    this.glowing = false,
  });

  static BoxDecoration decoration({
    required double size,
    Color? accent,
    bool glowing = false,
  }) {
    final tone = accent ?? AppColors.accent;

    return BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.nightElevated,
      border: Border.all(
        color: tone,
        width: (size * 0.04).clamp(1.2, 2.0),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: size * 0.16,
          offset: Offset(0, size * 0.05),
        ),
        if (glowing)
          BoxShadow(
            color: tone.withValues(alpha: 0.32),
            blurRadius: size * 0.32,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: decoration(size: size, accent: accent, glowing: glowing),
      child: child,
    );
  }
}
