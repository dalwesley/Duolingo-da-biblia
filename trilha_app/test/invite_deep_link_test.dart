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
}
