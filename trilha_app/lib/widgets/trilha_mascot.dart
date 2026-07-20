import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';

/// Mascote Trilha — pomba iluminada, sem emoji.
class TrilhaMascot extends StatelessWidget {
  final double size;
  final bool glowing;

  const TrilhaMascot({super.key, this.size = 56, this.glowing = true});

  @override
  Widget build(BuildContext context) {
    return CinematicIcon(
      glyph: CinematicGlyph.dove,
      size: size,
      accent: AppColors.accent,
      glowing: glowing,
    );
  }
}
