import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/widgets/portrait_face.dart';

void main() {
  group('PortraitStyle', () {
    test('fromStorage defaults to photo', () {
      expect(PortraitStyleX.fromStorage(null), PortraitStyle.photo);
      expect(PortraitStyleX.fromStorage('nope'), PortraitStyle.photo);
    });

    test('round-trips storage keys', () {
      for (final style in PortraitStyle.values) {
        expect(PortraitStyleX.fromStorage(style.storageKey), style);
      }
    });

    test('tryParse ignores unknown', () {
      expect(PortraitStyleX.tryParse('letter'), PortraitStyle.letter);
      expect(PortraitStyleX.tryParse(''), isNull);
    });

    test('hint names the three faces', () {
      expect(PortraitStyle.photo.hint, contains('foto'));
      expect(PortraitStyle.letter.hint, contains('iniciais'));
      expect(PortraitStyle.avatar.hint, contains('ilustrado'));
    });
  });

  group('PortraitFace.resolve', () {
    test('letter and avatar stay even with photo', () {
      expect(
        PortraitFace.resolve(PortraitStyle.letter, 'https://x'),
        PortraitStyle.letter,
      );
      expect(
        PortraitFace.resolve(PortraitStyle.avatar, 'https://x'),
        PortraitStyle.avatar,
      );
    });

    test('photo falls back to avatar without a real portrait', () {
      expect(PortraitFace.resolve(PortraitStyle.photo, null), PortraitStyle.avatar);
      expect(PortraitFace.resolve(PortraitStyle.photo, ''), PortraitStyle.avatar);
      expect(
        PortraitFace.resolve(
          PortraitStyle.photo,
          'https://lh3.googleusercontent.com/a/default-user=s96-c',
        ),
        PortraitStyle.avatar,
      );
      expect(
        PortraitFace.resolve(
          PortraitStyle.photo,
          'https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg',
        ),
        PortraitStyle.avatar,
      );
      // Retrato real atual do Google usa /a/ACg8oc…, não só /a-/.
      expect(
        PortraitFace.resolve(
          PortraitStyle.photo,
          'https://lh3.googleusercontent.com/a/ACg8ocRealPhoto=s96-c',
        ),
        PortraitStyle.photo,
      );
      expect(
        PortraitFace.resolve(
          PortraitStyle.photo,
          'https://lh3.googleusercontent.com/a-/AOh14RealPhoto=s96-c',
        ),
        PortraitStyle.photo,
      );
    });
  });
}
