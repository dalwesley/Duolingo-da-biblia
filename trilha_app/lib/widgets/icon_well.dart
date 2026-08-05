import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Poço circular — fill suave + borda na cor (padrão tipo Duo, cores STWAY).
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
      color: tone.withValues(alpha: 0.2),
      border: Border.all(
        color: tone.withValues(alpha: 0.95),
        width: (size * 0.07).clamp(2.2, 3.2),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          offset: const Offset(0, 2),
          blurRadius: 0,
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
