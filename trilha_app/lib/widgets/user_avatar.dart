import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'cinematic_icon.dart';
import 'portrait_face.dart';

export 'portrait_face.dart';

/// Foto, letra ou retrato ilustrado — conforme [PortraitStyle].
class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double radius;
  final VoidCallback? onTap;
  final Color? borderColor;
  final String? seed;
  final PortraitStyle style;

  /// Selo de lápis — o retrato pode ser alterado.
  final bool editable;

  const UserAvatar({
    super.key,
    this.photoUrl,
    required this.name,
    this.radius = 20,
    this.onTap,
    this.borderColor,
    this.seed,
    this.style = PortraitStyle.photo,
    this.editable = false,
  });

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? Colors.white.withValues(alpha: 0.18);
    final face = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor == Colors.transparent
            ? null
            : Border.all(color: border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: PortraitFace(
        name: name,
        photoUrl: photoUrl,
        seed: seed,
        size: radius * 2,
        style: style,
      ),
    );

    final stamp = (radius * 0.52).clamp(18.0, 26.0);
    final child = editable
        ? SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: Stack(
              children: [
                face,
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _PencilStamp(size: stamp),
                ),
              ],
            ),
          )
        : face;

    if (onTap == null) return child;
    return Semantics(
      button: true,
      label: editable ? 'Alterar retrato' : 'Abrir perfil',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}

class _PencilStamp extends StatelessWidget {
  final double size;

  const _PencilStamp({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent,
        border: Border.all(
          color: AppColors.night.withValues(alpha: 0.88),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: CinematicIcon(
        glyph: CinematicGlyph.pencil,
        size: size * 0.52,
        accent: AppColors.inkOnAccent,
        framed: false,
      ),
    );
  }
}
