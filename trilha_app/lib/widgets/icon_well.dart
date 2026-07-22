import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Poço circular — contraste alto para glifos sólidos no escuro.
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
    final lift = Color.lerp(tone, const Color(0xFF3A4A40), 0.35)!;
    const deep = Color(0xFF0C100E);

    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        center: const Alignment(-0.32, -0.4),
        radius: 1.1,
        colors: [
          lift,
          deep,
        ],
      ),
      border: Border.all(
        color: Color.lerp(tone, Colors.white, 0.35)!.withValues(alpha: 0.55),
        width: size * 0.035,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: size * 0.16,
          offset: Offset(0, size * 0.05),
        ),
        BoxShadow(
          color: tone.withValues(alpha: glowing ? 0.35 : 0.18),
          blurRadius: size * (glowing ? 0.32 : 0.18),
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
