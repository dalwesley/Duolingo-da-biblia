import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/dust_copy.dart';

void main() {
  test('hero risk line says what the countdown is for', () {
    final line = DustCopy.heroRiskLine(
      countdown: '12h 24min',
      hasFreeze: true,
      streak: 2,
    );
    expect(line, contains('12h 24min'));
    expect(line, contains('sequência de 2 dias'));
    expect(line, contains('cena hoje'));
    expect(line, startsWith('Faltam 12h 24min'));
    expect(line, isNot(contains('postos')));
  });

  test('hero risk line without freeze stays plain', () {
    final line = DustCopy.heroRiskLine(countdown: '40min', hasFreeze: false);
    expect(line, 'Faltam 40min para a sequência cair. Faça a cena hoje.');
  });
}
