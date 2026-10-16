import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';

/// Poço circular — fill suave + borda na cor (padrão tipo Duo, cores STWAY).
class IconWell extends StatelessWidget {
  final double size;
  final Color? accent;
  final bool glowing;
  final Widget child;

  /// Papel atrás do poço; nulo = lê de [Appearance].
  final bool? onDark;

  const IconWell({
    super.key,
    required this.size,
    required this.child,
    this.accent,
    this.glowing = false,
    this.onDark,
  });

  static double borderWidth(double size) => (size * 0.06).clamp(1.8, 2.6);

  static BoxDecoration decoration({
    required double size,
    Color? accent,
    bool glowing = false,
    bool onDark = true,
  }) {
    final base = accent ?? AppColors.accent;
    final tone = onDark
        ? AppColors.glyphInk(base)
        : AppColors.glyphInkOnLight(base);

    return BoxDecoration(
      shape: BoxShape.circle,
      color: tone.withValues(alpha: glowing ? 0.32 : 0.22),
      border: Border.all(
        color: tone.withValues(alpha: 0.95),
        width: borderWidth(size),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: decoration(
        size: size,
        accent: accent,
        glowing: glowing,
        onDark: onDark ?? Appearance.of(context).onDark,
      ),
      child: child,
    );
  }
}
