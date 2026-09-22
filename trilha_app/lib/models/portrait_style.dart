/// Como o peregrino aparece na caravana, na home e no perfil.
enum PortraitStyle {
  photo,
  letter,
  avatar,
}

extension PortraitStyleX on PortraitStyle {
  String get storageKey => name;

  String get label => switch (this) {
        PortraitStyle.photo => 'Foto',
        PortraitStyle.letter => 'Letra',
        PortraitStyle.avatar => 'Avatar',
      };

  String get hint => switch (this) {
        PortraitStyle.photo => 'A foto da sua conta',
        PortraitStyle.letter => 'As iniciais do nome',
        PortraitStyle.avatar => 'Um peregrino ilustrado',
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
