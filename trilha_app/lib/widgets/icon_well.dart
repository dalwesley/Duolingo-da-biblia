import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Poço circular — fundo navy + borda na cor da seção (alpha estável).
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
    // Mesma regra de AppMetrics.accentBorder (alpha ≥ 0.55).
    final border = tone.withValues(alpha: 0.85);

    return BoxDecoration(
      shape: BoxShape.circle,
      color: Color.lerp(
        AppColors.nightElevated,
        tone,
        0.12,
      )!,
      border: Border.all(
        color: border,
        width: (size * 0.045).clamp(1.4, 2.2),
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
