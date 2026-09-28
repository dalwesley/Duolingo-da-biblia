import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/services/league_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Segunda 2026-09-28; semana fechada 2026-09-21.
  final now = DateTime(2026, 9, 29, 10);

  Future<LeagueService> leagueAt({
    required String processedWeek,
    int tier = 1,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final league = LeagueService();
    await league.applyFromCloud({
      'leagueTier': tier,
      'leagueProcessedWeek': processedWeek,
    });
    return league;
  }

  test('resultado da semana fechada vale divisão e card', () async {
    final league = await leagueAt(processedWeek: '2026-09-21');
    final applied = await league.applyServerResult(
      {'week': '2026-09-21', 'tier': 2, 'outcome': 'promoted', 'rank': 3},
      hadStepsInClosedWeek: true,
      now: now,
    );
    expect(applied, isTrue);
    expect(league.tierIndex, 2);
    expect(league.pendingOutcome, LeagueOutcome.promoted);
    expect(league.pendingRank, 3);
    expect(league.processedWeek, '2026-09-28');
  });

  test('com passos e sem resultado: espera o servidor', () async {
    final league = await leagueAt(processedWeek: '2026-09-21');
    final applied = await league.applyServerResult(
      null,
      hadStepsInClosedWeek: true,
      now: now,
    );
    expect(applied, isFalse);
    expect(league.processedWeek, '2026-09-21');
    expect(league.tierIndex, 1);
  });

  test('resultado antigo (já aplicado) não conta de novo', () async {
    final league = await leagueAt(processedWeek: '2026-09-21');
    await league.applyServerResult(
      {'week': '2026-09-14', 'tier': 3, 'outcome': 'promoted'},
      hadStepsInClosedWeek: true,
      now: now,
    );
    expect(league.tierIndex, 1);
  });

  test('sem passos na semana: avança sem card', () async {
    final league = await leagueAt(processedWeek: '2026-09-21');
    final applied = await league.applyServerResult(
      null,
      hadStepsInClosedWeek: false,
      now: now,
    );
    expect(applied, isTrue);
    expect(league.pendingOutcome, isNull);
    expect(league.processedWeek, '2026-09-28');
  });

  test('descida por ausência (resultado mais novo) é aplicada', () async {
    final league = await leagueAt(processedWeek: '2026-09-07', tier: 2);
    await league.applyServerResult(
      {
        'week': '2026-09-21',
        'tier': 1,
        'outcome': 'demoted',
        'reason': 'inactive',
      },
      hadStepsInClosedWeek: false,
      now: now,
    );
    expect(league.tierIndex, 1);
    expect(league.pendingOutcome, LeagueOutcome.demoted);
  });

  test('servidor mudo por 2 semanas: desiste e avança', () async {
    final league = await leagueAt(processedWeek: '2026-09-14');
    final applied = await league.applyServerResult(
      null,
      hadStepsInClosedWeek: true,
      now: now,
    );
    expect(applied, isTrue);
    expect(league.processedWeek, '2026-09-28');
  });
}
