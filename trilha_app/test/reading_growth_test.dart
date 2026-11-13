import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/difficulty.dart';
import 'package:trilha_app/utils/reading_growth.dart';

void main() {
  test('weekKey é a segunda-feira local', () {
    expect(ReadingGrowth.weekKey(DateTime(2026, 11, 12)), '2026-11-09');
    expect(ReadingGrowth.weekKey(DateTime(2026, 11, 15)), '2026-11-09');
    expect(ReadingGrowth.weekKey(DateTime(2026, 11, 16)), '2026-11-16');
  });

  test('compara o começo com agora no mesmo modo', () {
    final total = {
      '2026-10-12.profundezas': 6,
      '2026-10-19.profundezas': 6,
      '2026-11-02.profundezas': 5,
      '2026-11-09.profundezas': 7,
      '2026-11-09.semente': 30,
    };
    final correct = {
      '2026-10-12.profundezas': 2,
      '2026-10-19.profundezas': 3, // começo: 5/12 = 42%
      '2026-11-02.profundezas': 4,
      '2026-11-09.profundezas': 5, // agora: 9/12 = 75%
      '2026-11-09.semente': 27,
    };
    final g = ReadingGrowth.best(correct: correct, total: total)!;
    expect(g.mode, TrailDifficulty.profundezas);
    expect(g.fromPct, 42);
    expect(g.toPct, 75);
    // Semente tem uma semana só: não compara.
    expect(
      ReadingGrowth.forMode(
        TrailDifficulty.semente,
        correct: correct,
        total: total,
      ),
      isNull,
    );
  });

  test('sem respostas suficientes nas duas pontas, nada', () {
    final total = {'2026-11-02.caminhada': 8, '2026-11-09.caminhada': 8};
    final correct = {'2026-11-02.caminhada': 2, '2026-11-09.caminhada': 8};
    expect(ReadingGrowth.best(correct: correct, total: total), isNull);
  });

  test('prune guarda as 26 semanas mais recentes', () {
    final map = {
      for (var i = 0; i < 30; i++)
        '${ReadingGrowth.weekKey(DateTime(2026, 1, 5).add(Duration(days: 7 * i)))}.semente':
            1,
    };
    final pruned = ReadingGrowth.prune(map);
    expect(pruned.length, 26);
    expect(pruned.keys.first.startsWith('2026-02-02'), isTrue);
  });

  test('weekDelta: semana atual contra as 4 anteriores', () {
    final total = {
      '2026-10-19.semente': 10,
      '2026-10-26.caminhada': 10, // base: 10/20 = 50%
      '2026-11-09.semente': 6,
      '2026-11-09.profundezas': 4, // semana: 8/10 = 80%
    };
    final correct = {
      '2026-10-19.semente': 6,
      '2026-10-26.caminhada': 4,
      '2026-11-09.semente': 5,
      '2026-11-09.profundezas': 3,
    };
    expect(
      ReadingGrowth.weekDelta(
        correct: correct,
        total: total,
        week: '2026-11-09',
      ),
      30,
    );
    // Poucas respostas na semana: nada.
    expect(
      ReadingGrowth.weekDelta(
        correct: correct,
        total: {...total, '2026-11-09.profundezas': 1},
        week: '2026-11-09',
      ),
      isNull,
    );
  });
}
