import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/remote_config_service.dart';

void main() {
  bool open(String day, [String raw = '']) =>
      RemoteConfigService.yearReviewOpenOn(DateTime.parse(day), raw);

  test('padrão abre em 28/12 e fecha depois de 31/01', () {
    expect(open('2026-12-27'), isFalse);
    expect(open('2026-12-28'), isTrue);
    expect(open('2027-01-15'), isTrue);
    expect(open('2027-01-31'), isTrue);
    expect(open('2027-02-01'), isFalse);
    expect(open('2027-12-28'), isTrue);
  });

  test('data do painel vale só para o próprio ano', () {
    expect(open('2026-12-20', '2026-12-20'), isTrue);
    expect(open('2026-12-19', '2026-12-20'), isFalse);
    expect(open('2027-01-10', '2026-12-20'), isTrue);
    expect(open('2027-12-20', '2026-12-20'), isFalse);
    expect(open('2027-12-28', '2026-12-20'), isTrue);
  });

  test('off fecha', () {
    expect(open('2026-12-29', 'off'), isFalse);
  });

  test('em janeiro mostra o ano que acabou', () {
    expect(RemoteConfigService.reviewYearFor(DateTime(2027, 1, 5)), 2026);
    expect(RemoteConfigService.reviewYearFor(DateTime(2026, 12, 30)), 2026);
  });
}
