import '../l10n/l10n_global.dart';

/// Como o peregrino aparece na caravana, na home e no perfil.
enum PortraitStyle {
  photo,
  letter,
  avatar,
}

extension PortraitStyleX on PortraitStyle {
  String get storageKey => name;

  String get label => switch (this) {
        PortraitStyle.photo => L10n.current.portraitPhoto,
        PortraitStyle.letter => L10n.current.portraitLetter,
        PortraitStyle.avatar => L10n.current.portraitAvatar,
      };

  String get hint => switch (this) {
        PortraitStyle.photo => L10n.current.portraitPhotoHint,
        PortraitStyle.letter => L10n.current.portraitLetterHint,
        PortraitStyle.avatar => L10n.current.portraitAvatarHint,
      };

  static PortraitStyle fromStorage(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'letter':
        return PortraitStyle.letter;
      case 'avatar':
        return PortraitStyle.avatar;
      default:
        return PortraitStyle.photo;
    }
  }

  static PortraitStyle? tryParse(String? raw) {
    final t = raw?.trim().toLowerCase();
    if (t == 'letter') return PortraitStyle.letter;
    if (t == 'avatar') return PortraitStyle.avatar;
    if (t == 'photo') return PortraitStyle.photo;
    return null;
  }
}
