import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/invite_deep_link_service.dart';

void main() {
  test('QR de grupo aponta para a sala, não para a companhia', () {
    expect(
      InviteDeepLinkService.extractRoomCode(
        'https://stway-app.web.app/abrir/sala?c=Z4LNGH',
      ),
      'Z4LNGH',
    );
    expect(
      InviteDeepLinkService.extractRoomCode('stway://sala/z4lngh'),
      'Z4LNGH',
    );
    expect(
      InviteDeepLinkService.extractRoomCode('stway://companhia/ABCD12'),
      isNull,
    );
    expect(
      InviteDeepLinkService.roomHttpsUrl('z4lngh'),
      'https://stway-app.web.app/abrir/sala?c=Z4LNGH',
    );
  });

  test('passe de trilha: app, https e não vira código de companhia', () {
    expect(
      InviteDeepLinkService.extractTrailGiftCode('stway://passe/ab23cd45'),
      'AB23CD45',
    );
    expect(
      InviteDeepLinkService.extractTrailGiftCode(
        'https://stway-app.web.app/abrir/passe?c=AB23CD45',
      ),
      'AB23CD45',
    );
    expect(
      InviteDeepLinkService.extractTrailGiftCode('stway://sala/AB23CD45'),
      isNull,
    );
    expect(
      InviteDeepLinkService.extractTrailGiftCode(
        'https://stway-app.web.app/abrir/sala?c=AB23CD45',
      ),
      isNull,
    );
    expect(
      InviteDeepLinkService.trailGiftHttpsUrl('ab23cd45'),
      'https://stway-app.web.app/abrir/passe?c=AB23CD45',
    );
  });

  test('passe de trilha: acha o código na mensagem colada', () {
    expect(
      InviteDeepLinkService.findTrailGiftCode(
        'Liberei pra você a trilha Oração no Stway 🎁 É sua, inteira. '
        'Abre pelo link: https://stway-app.web.app/abrir/passe?c=AB23CD45',
      ),
      'AB23CD45',
    );
    expect(InviteDeepLinkService.findTrailGiftCode(' ab23cd45 '), 'AB23CD45');
    // Palavra solta ou link de grupo não viram passe.
    expect(InviteDeepLinkService.findTrailGiftCode('obrigado'), isNull);
    expect(
      InviteDeepLinkService.findTrailGiftCode(
        'https://stway-app.web.app/abrir/sala?c=AB23CD45',
      ),
      isNull,
    );
  });
}
