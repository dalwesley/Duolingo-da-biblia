import 'package:flutter/material.dart';
import 'portrait_face.dart';

/// Foto, letra ou retrato ilustrado — conforme [PortraitStyle].
class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double radius;
  final VoidCallback? onTap;
  final Color? borderColor;
  final String? seed;
  final PortraitStyle style;

  const UserAvatar({
    super.key,
    this.photoUrl,
    required this.name,
    this.radius = 20,
    this.onTap,
    this.borderColor,
    this.seed,
    this.style = PortraitStyle.photo,
  });

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? Colors.white.withValues(alpha: 0.18);
    final child = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 1.5),
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

    if (onTap == null) return child;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
