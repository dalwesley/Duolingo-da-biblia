import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/league_service.dart';

void main() {
  group('LeagueService.fieldIsCompetitive', () {
    test('sozinho não tem tensão', () {
      expect(LeagueService.fieldIsCompetitive(0), isFalse);
    });

    test('um par (2 no campo) já compete', () {
      expect(LeagueService.fieldIsCompetitive(1), isTrue);
      expect(LeagueService.fieldIsCompetitive(19), isTrue);
    });
  });

  group('LeagueService.settleSteadyWeek', () {
    test('semana com menos de 5 cenas não firma nem tira o que já tinha', () {
      final s = LeagueService.settleSteadyWeek(
        scenes: 4,
        tierIndex: 1,
        steadyWeeks: 2,
      );
      expect(s.promoted, isFalse);
      expect(s.tierIndex, 1);
      expect(s.steadyWeeks, 2);
    });

    test('semana firme soma uma semana', () {
      final s = LeagueService.settleSteadyWeek(
        scenes: 5,
        tierIndex: 0,
        steadyWeeks: 0,
      );
      expect(s.promoted, isFalse);
      expect(s.tierIndex, 0);
      expect(s.steadyWeeks, 1);
    });

    test('terceira semana firme sobe um nível e zera a contagem', () {
      final s = LeagueService.settleSteadyWeek(
        scenes: 9,
        tierIndex: 2,
        steadyWeeks: 2,
      );
      expect(s.promoted, isTrue);
      expect(s.tierIndex, 3);
      expect(s.steadyWeeks, 0);
    });

    test('no nível mais alto não sobe mais', () {
      final s = LeagueService.settleSteadyWeek(
        scenes: 9,
        tierIndex: LeagueService.maxTierIndex,
        steadyWeeks: 2,
      );
      expect(s.promoted, isFalse);
      expect(s.tierIndex, LeagueService.maxTierIndex);
    });
  });

  group('LeagueService.placesUpToday', () {
    LeagueEntry e(String name, int steps, {int? dayStart, bool user = false}) =>
        LeagueEntry(
          name: name,
          steps: steps,
          dayStartSteps: dayStart,
          isUser: user,
        );

    test('quem passou alguém hoje ganha seta; quem foi passado não', () {
      // Ontem: Ana 100, Bia 80, Caio 50. Hoje Caio somou 60.
      final sorted = [
        e('Caio', 110, dayStart: 50),
        e('Ana', 100),
        e('Bia', 80),
      ];
      expect(LeagueService.placesUpToday(sorted), [2, 0, 0]);
    });

    test('sem passo hoje ninguém se move', () {
      final sorted = [e('Ana', 100), e('Bia', 80)];
      expect(LeagueService.placesUpToday(sorted), [0, 0]);
    });
  });

}
