import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/models/caravan_profile_prefs.dart';
import 'package:trilha_app/services/league_service.dart';
import 'package:trilha_app/services/progress_service.dart';
import 'package:trilha_app/utils/liturgical_calendar.dart';
import 'package:trilha_app/utils/trail_progress.dart';

String _ymd(DateTime d) => d.toIso8601String().substring(0, 10);

// applyFromCloud vira semana/mês para o atual no fim: os testes de merge
// usam o período corrente e o anterior.
final _now = DateTime.now();
String _daysAgo(int n) => _ymd(ProgressService.addCivilDays(_now, -n));
final _thisWeek = _daysAgo(_now.weekday - 1);
final _lastWeek = _daysAgo(_now.weekday - 1 + 7);
String _month(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';
final _thisMonth = _month(_now);
final _lastMonth = _month(DateTime(_now.year, _now.month - 1, 1));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Datas civis (troca de horário)', () {
    // Rode também com TZ=America/New_York: 8/mar e 1/nov de 2026 têm troca.
    test('soma e diferença de dias ignoram o horário de verão', () {
      expect(
        _ymd(ProgressService.addCivilDays(DateTime(2026, 3, 8), 1)),
        '2026-03-09',
      );
      expect(
        _ymd(ProgressService.addCivilDays(DateTime(2026, 3, 9), -1)),
        '2026-03-08',
      );
      expect(
        _ymd(ProgressService.addCivilDays(DateTime(2026, 11, 2), -7)),
        '2026-10-26',
      );
      expect(
        ProgressService.civilDaysBetween(
          DateTime(2026, 3, 7, 23, 30),
          DateTime(2026, 3, 9, 0, 10),
        ),
        2,
      );
      expect(
        ProgressService.civilDaysBetween(
          DateTime(2026, 10, 31),
          DateTime(2026, 11, 2),
        ),
        2,
      );
    });

    test('semana da revisão e da Caravana caem na segunda certa', () {
      final p = ProgressService();
      // Segunda depois da troca: revisão cobre a semana anterior.
      expect(p.weeklyReviewWeekKey(DateTime(2026, 3, 9, 0, 30)), '2026-03-02');
      expect(p.weeklyReviewWeekKey(DateTime(2026, 3, 8, 12)), '2026-03-02');
      expect(LeagueService.weekKey(DateTime(2026, 3, 8, 12)), '2026-03-02');
      expect(LeagueService.weekKey(DateTime(2026, 11, 1, 0, 30)), '2026-10-26');
    });

    test('Pentecostes e Cinzas a partir da Páscoa', () {
      // Páscoa 2026: 5/abr.
      expect(
        LiturgicalCalendar.momentFor(DateTime(2026, 5, 24)).season,
        LiturgicalSeason.pentecost,
      );
      expect(
        LiturgicalCalendar.momentFor(DateTime(2026, 2, 18)).season,
        LiturgicalSeason.lent,
      );
      expect(
        LiturgicalCalendar.momentFor(DateTime(2026, 2, 17)).season,
        LiturgicalSeason.ordinary,
      );
    });
  });

  group('Merge entre aparelhos', () {
    test('chaves de período: mais nova vence, sem chave = mesmo período', () {
      expect(ProgressService.comparePeriodKeys('2026-10-19', '2026-10-26'), 1);
      expect(ProgressService.comparePeriodKeys('2026-10-26', '2026-10-19'), -1);
      expect(ProgressService.comparePeriodKeys('2026-10-26', '2026-10-26'), 0);
      expect(ProgressService.comparePeriodKeys(null, '2026-10-26'), 0);
      expect(ProgressService.comparePeriodKeys('lixo', '2026-10-26'), 0);
      expect(
        ProgressService.comparePeriodKeys('2026-09', '2026-10', month: true),
        1,
      );
    });

    test('semana velha da nuvem não infla a semana atual', () async {
      final p = ProgressService()
        ..weeklyWeek = _thisWeek
        ..weeklySteps = 10
        ..weeklyScenes = 1;
      await p.applyFromCloud({
        'version': 2,
        'weeklyWeek': _lastWeek,
        'weeklySteps': 99,
        'weeklyScenes': 7,
      });
      expect(p.weeklyWeek, _thisWeek);
      expect(p.weeklySteps, 10);
      expect(p.weeklyScenes, 1);
    });

    test('semana nova da nuvem vem com os seus contadores', () async {
      final p = ProgressService()
        ..weeklyWeek = _lastWeek
        ..weeklySteps = 99
        ..weeklyScenes = 7;
      await p.applyFromCloud({
        'version': 2,
        'weeklyWeek': _thisWeek,
        'weeklySteps': 10,
        'weeklyScenes': 1,
        'lastWeekKey': _lastWeek,
        'lastWeekSteps': 40,
        'lastWeekScenes': 2,
      });
      expect(p.weeklyWeek, _thisWeek);
      expect(p.weeklySteps, 10);
      expect(p.weeklyScenes, 1);
      // O que este aparelho caminhou na semana fechada não se perde.
      expect(p.lastWeekKey, _lastWeek);
      expect(p.lastWeekSteps, 99);
      expect(p.lastWeekScenes, 7);
    });

    test('mesma semana: máximo dos dois lados', () async {
      final p = ProgressService()
        ..weeklyWeek = _thisWeek
        ..weeklySteps = 10
        ..weeklyScenes = 3;
      await p.applyFromCloud({
        'version': 2,
        'weeklyWeek': _thisWeek,
        'weeklySteps': 20,
        'weeklyScenes': 1,
      });
      expect(p.weeklySteps, 20);
      expect(p.weeklyScenes, 3);
    });

    test('mês: contadores andam com o mês mais novo', () async {
      final p = ProgressService()
        ..monthlyMonth = _thisMonth
        ..monthlySteps = 30;
      await p.applyFromCloud({
        'version': 2,
        'monthlyMonth': _lastMonth,
        'monthlySteps': 500,
      });
      expect(p.monthlyMonth, _thisMonth);
      expect(p.monthlySteps, 30);

      final q = ProgressService()
        ..monthlyMonth = _lastMonth
        ..monthlySteps = 500;
      await q.applyFromCloud({
        'version': 2,
        'monthlyMonth': _thisMonth,
        'monthlySteps': 5,
      });
      expect(q.monthlyMonth, _thisMonth);
      expect(q.monthlySteps, 5);
    });

    test('sequência vem inteira do último passo mais novo', () async {
      final p = ProgressService()
        ..streak = 10
        ..lastPlayedDate = _daysAgo(10);
      await p.applyFromCloud({
        'version': 2,
        'streak': 1,
        'lastPlayedDate': _daysAgo(8),
        'streakRepairPending': true,
        'brokenStreak': 10,
        'streakRepairMissedDate': _daysAgo(9),
      });
      expect(p.streak, 1);
      expect(p.lastPlayedDate, _daysAgo(8));
      expect(p.streakRepairPending, isTrue);
      expect(p.brokenStreak, 10);
      expect(p.streakRepairMissedDate, _daysAgo(9));
    });

    test('nuvem atrasada não reabre reparo nem sobe a sequência', () async {
      final p = ProgressService()
        ..streak = 1
        ..lastPlayedDate = _daysAgo(8)
        ..streakRepairPending = false;
      await p.applyFromCloud({
        'version': 2,
        'streak': 10,
        'lastPlayedDate': _daysAgo(10),
        'streakRepairPending': true,
        'brokenStreak': 4,
      });
      expect(p.streak, 1);
      expect(p.lastPlayedDate, _daysAgo(8));
      expect(p.streakRepairPending, isFalse);
      expect(p.brokenStreak, 0);
    });

    test('mesmo dia: maior sequência', () async {
      final p = ProgressService()
        ..streak = 4
        ..lastPlayedDate = _daysAgo(8);
      await p.applyFromCloud({
        'version': 2,
        'streak': 6,
        'lastPlayedDate': _daysAgo(8),
      });
      expect(p.streak, 6);
    });

    test('gelo gasto na mesma semana não volta pela nuvem', () async {
      final p = ProgressService()
        ..streakFreezeAvailable = false
        ..streakFreezeWeek = _thisWeek;
      await p.applyFromCloud({
        'version': 2,
        'streakFreezeAvailable': true,
        'streakFreezeWeek': _thisWeek,
      });
      expect(p.streakFreezeAvailable, isFalse);
    });
  });

  group('Caravana e conta', () {
    test('sair da trilha e refazer não paga o ranking de novo', () async {
      final p = ProgressService();
      await p.completeMission('cena-1', 50, mode: 'semente');
      expect(p.currentMonthSteps, 50);
      expect(p.currentWeekScenes, 1);

      await p.leaveTrail(trailSlug: 'genesis-1-11', missionSlugs: ['cena-1']);
      expect(p.rankedScenes, contains('cena-1@semente'));

      await p.completeMission('cena-1', 50, mode: 'semente');
      expect(p.currentMonthSteps, 50);
      expect(p.currentWeekScenes, 1);
      expect(p.completedMissions, contains('cena-1'));
    });

    test('sair da conta zera o que é da conta', () async {
      final p = ProgressService()
        ..lifetimeQuestionsCorrect = 9
        ..lifetimeQuestionsAnswered = 12
        ..daysAsCaravanLeader = 3
        ..lastLeaderRankDay = '2026-10-20'
        ..lastMissionSlug = 'cena-1'
        ..lastMissionCompletedDate = '2026-10-20'
        ..streakRepairMissedDate = '2026-10-19'
        ..caravanProfilePrefs = const CaravanProfilePrefs({
          CaravanProfileSection.accuracy: false,
        })
        // Mantém a jornada "viva": o reset não pode depender da limpeza
        // de estatísticas órfãs.
        ..steps = 10;
      expect(TrailProgress.lastPlayedMissionSlug, 'cena-1');

      await p.resetMemoryToDefaults();

      expect(p.lifetimeQuestionsCorrect, 0);
      expect(p.lifetimeQuestionsAnswered, 0);
      expect(p.daysAsCaravanLeader, 0);
      expect(p.lastLeaderRankDay, isNull);
      expect(p.lastMissionSlug, isNull);
      expect(TrailProgress.lastPlayedMissionSlug, isNull);
      expect(p.lastMissionCompletedDate, isNull);
      expect(p.streakRepairMissedDate, isNull);
      expect(
        p.caravanProfilePrefs.toMap(),
        const CaravanProfilePrefs().toMap(),
      );
    });
  });

  group('Reparo da sequência', () {
    test('a quebra grava o dia em branco de verdade', () async {
      final now = DateTime.now();
      final p = ProgressService()
        ..streak = 5
        ..lastPlayedDate = _ymd(ProgressService.addCivilDays(now, -2))
        // Gelo já gasto nesta semana: a quebra vira oferta de reparo.
        ..streakFreezeAvailable = false
        ..streakFreezeWeek = _ymd(
          ProgressService.addCivilDays(now, -(now.weekday - 1)),
        );
      await p.completeMission('cena-1', 50);

      expect(p.streakRepairPending, isTrue);
      expect(p.brokenStreak, 5);
      final yesterday = _ymd(ProgressService.addCivilDays(now, -1));
      expect(p.streakRepairMissedDate, yesterday);

      // Um gelo depois do recomeço não desloca o dia gravado.
      p
        ..streak = 3
        ..lastPlayedDate = _ymd(now);
      expect(_ymd(p.streakRepairMissedDay!), yesterday);
    });
  });
}
