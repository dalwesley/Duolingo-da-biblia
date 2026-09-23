import 'package:flutter/material.dart';

import '../models/portrait_style.dart';
import '../theme/app_theme.dart';
import 'pilgrim_mark.dart';

export '../models/portrait_style.dart';

/// Rosto circular: foto, letra ou retrato ilustrado.
class PortraitFace extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final String? seed;
  final double size;
  final PortraitStyle style;
  final Color letterColor;

  const PortraitFace({
    super.key,
    required this.name,
    this.photoUrl,
    this.seed,
    required this.size,
    this.style = PortraitStyle.photo,
    this.letterColor = AppColors.accent,
  });

  String get _seed {
    final id = seed?.trim();
    if (id != null && id.isNotEmpty) return id;
    return name;
  }

  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Foto da conta. Ignora URL vazia e os placeholders conhecidos
  /// (`default-user`, silhueta `AAAAAAAAAAI`).
  ///
  /// O Google passou a servir retrato real em `/a/ACg8oc…`, o mesmo
  /// prefixo da letra colorida antiga. A URL sozinha não separa os dois;
  /// esconder todo `/a/` sem hífen ocultava a foto de verdade.
  static bool isUsablePhotoUrl(String? url) {
    if (url == null) return false;
    final u = url.trim();
    if (u.isEmpty) return false;
    final lower = u.toLowerCase();
    if (lower.contains('default-user') ||
        lower.contains('default-avatar') ||
        lower.contains('avatar/empty') ||
        lower.contains('aaaaaaaaaai')) {
      return false;
    }
    return true;
  }

  static PortraitStyle resolve(PortraitStyle style, String? photoUrl) {
    switch (style) {
      case PortraitStyle.letter:
        return PortraitStyle.letter;
      case PortraitStyle.avatar:
        return PortraitStyle.avatar;
      case PortraitStyle.photo:
        return isUsablePhotoUrl(photoUrl)
            ? PortraitStyle.photo
            : PortraitStyle.avatar;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shown = resolve(style, photoUrl);
    final mark = PilgrimMark(seed: _seed, size: size);
    switch (shown) {
      case PortraitStyle.letter:
        return _LetterFace(
          initials: initialsOf(name),
          size: size,
          color: letterColor,
        );
      case PortraitStyle.avatar:
        return mark;
      case PortraitStyle.photo:
        return Image.network(
          photoUrl!.trim(),
          fit: BoxFit.cover,
          width: size,
          height: size,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => mark,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return mark;
          },
        );
    }
  }
}

class _LetterFace extends StatelessWidget {
  final String initials;
  final double size;
  final Color color;

  const _LetterFace({
    required this.initials,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.nightLight,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * (initials.length > 1 ? 0.36 : 0.42),
            fontWeight: FontWeight.w900,
            color: color,
            height: 1,
          ),
        ),
      ),
    );
  }
}
