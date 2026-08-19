import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/mascot_messages.dart';

void main() {
  group('CelebrationCopy', () {
    test('headline is a clear beat, not scoreboard jargon', () {
      expect(
        CelebrationCopy.headline(
          perfect: false,
          isReplay: false,
          isBoss: false,
        ),
        'Missão cumprida',
      );
      expect(
        CelebrationCopy.headline(
          perfect: true,
          isReplay: false,
          isBoss: false,
        ),
        'Clareza total',
      );
      expect(
        CelebrationCopy.headline(
          perfect: false,
          isReplay: true,
          isBoss: false,
        ),
        'Memória reforçada',
      );
      expect(
        CelebrationCopy.headline(
          perfect: false,
          isReplay: false,
          isBoss: true,
        ),
        'Boss vencido',
      );
    });

    test('promotion zone copy names the zone, not "quase promove"', () {
      expect(
        CelebrationCopy.caravanaTitle(rank: 3, inPromotionZone: true),
        'Zona de subida',
      );
      expect(
        CelebrationCopy.caravanaDetail(rank: 3, inPromotionZone: true),
        contains('7 primeiros'),
      );
      expect(
        CelebrationCopy.caravanaTitle(rank: 1, inPromotionZone: true),
        'Você lidera a caravana',
      );
      expect(
        CelebrationCopy.caravanaTitle(rank: 12, inPromotionZone: false),
        '12º na caravana',
      );
    });
  });

  group('MascotMessages.celebration', () {
    test('speaks about the step, not the scoreboard', () {
      expect(
        MascotMessages.celebration(isBoss: false, pct: 80),
        'Bom passo. A trilha te espera amanhã.',
      );
      expect(
        MascotMessages.celebration(isBoss: false, pct: 50),
        contains('Reforce o que faltou'),
      );
      expect(
        MascotMessages.celebration(isBoss: false, pct: 100, perfect: true),
        'Nenhuma lâmpada perdida. Isso fica.',
      );
      expect(
        MascotMessages.celebration(isBoss: false, pct: 90, isReplay: true),
        contains('Voltar ao texto'),
      );
    });
  });
}
