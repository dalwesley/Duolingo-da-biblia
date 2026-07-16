import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Foto do Google com fallback para iniciais.
class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double radius;
  final VoidCallback? onTap;
  final Color? borderColor;

  const UserAvatar({
    super.key,
    this.photoUrl,
    required this.name,
    this.radius = 20,
    this.onTap,
    this.borderColor,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? AppColors.accent.withValues(alpha: 0.55);
    final child = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius - 1.5,
        backgroundColor: const Color(0xFF1E2A24),
        backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
            ? NetworkImage(photoUrl!)
            : null,
        child: photoUrl == null || photoUrl!.isEmpty
            ? Text(
                _initials,
                style: TextStyle(
                  fontSize: radius * 0.72,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accent,
                ),
              )
            : null,
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
