import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Poço circular para ícones — limpo, sem aro metálico dourado.
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
    final tone = accent ?? AppColors.primaryLight;
    final lift = Color.lerp(tone, const Color(0xFF2A3832), 0.55)!;
    const deep = Color(0xFF101614);

    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        center: const Alignment(-0.35, -0.42),
        radius: 1.15,
        colors: [
          lift.withValues(alpha: 0.95),
          deep.withValues(alpha: 0.98),
        ],
      ),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.14),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: size * 0.14,
          offset: Offset(0, size * 0.05),
        ),
        if (glowing)
          BoxShadow(
            color: tone.withValues(alpha: 0.2),
            blurRadius: size * 0.3,
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
