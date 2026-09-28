import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/league_service.dart';

void main() {
  group('LeagueService.fieldIsCompetitive', () {
    test('sozinho não tem tensão', () {
      expect(LeagueService.fieldIsCompetitive(0), isFalse);
    });

    test('um par (2 no campo) já compete', () {
      expect(LeagueService.fieldIsCompetitive(1), isTrue);
      expect(LeagueService.fieldIsCompetitive(2), isTrue);
      expect(LeagueService.fieldIsCompetitive(19), isTrue);
    });
  });

  group('LeagueService.settleClosedWeek', () {
    test('sem XP não mostra resultado nem muda de divisão', () {
      final s = LeagueService.settleClosedWeek(
        userXp: 0,
        peerSteps: const [40, 30, 20],
        tierIndex: 1,
        groupSize: 20,
        maxTierIndex: 4,
      );
      expect(s.outcome, isNull);
      expect(s.tierDelta, 0);
      expect(s.rank, 0);
    });

    test('campo vazio não promove', () {
      final s = LeagueService.settleClosedWeek(
        userXp: 80,
        peerSteps: const [],
        tierIndex: 0,
        groupSize: 20,
        maxTierIndex: 4,
      );
      expect(s.outcome, isNull);
      expect(s.tierDelta, 0);
    });

    test('um par + liderança promove', () {
      final s = LeagueService.settleClosedWeek(
        userXp: 80,
        peerSteps: const [10],
        tierIndex: 0,
        groupSize: 20,
        maxTierIndex: 4,
      );
      expect(s.outcome, LeagueOutcome.promoted);
      expect(s.tierDelta, 1);
      expect(s.rank, 1);
    });

    test('liderando campo real promove', () {
      final s = LeagueService.settleClosedWeek(
        userXp: 100,
        peerSteps: const [40, 30, 20],
        tierIndex: 0,
        groupSize: 20,
        maxTierIndex: 4,
      );
      expect(s.outcome, LeagueOutcome.promoted);
      expect(s.tierDelta, 1);
      expect(s.rank, 1);
    });

    test('último de 20 desce', () {
      final peers = List<int>.generate(19, (i) => 100 - i);
      final s = LeagueService.settleClosedWeek(
        userXp: 1,
        peerSteps: peers,
        tierIndex: 2,
        groupSize: 20,
        maxTierIndex: 4,
      );
      expect(s.outcome, LeagueOutcome.demoted);
      expect(s.tierDelta, -1);
      expect(s.rank, 20);
    });

    test('meio da tabela permanece', () {
      final peers = [
        ...List<int>.filled(8, 90),
        ...List<int>.filled(11, 40),
      ];
      final s = LeagueService.settleClosedWeek(
        userXp: 70,
        peerSteps: peers,
        tierIndex: 1,
        groupSize: 20,
        maxTierIndex: 4,
      );
      expect(s.outcome, LeagueOutcome.stayed);
      expect(s.tierDelta, 0);
      expect(s.rank, 9);
    });
  });
  group('LeagueService zonas proporcionais', () {
    test('sobe ~25% e desce ~15% do campo', () {
      expect(LeagueService.promoteCountFor(20), 5);
      expect(LeagueService.demoteCountFor(20), 3);
      expect(LeagueService.promoteCountFor(10), 3);
      expect(LeagueService.demoteCountFor(10), 2);
      expect(LeagueService.promoteCountFor(5), 1);
      expect(LeagueService.demoteCountFor(5), 1);
    });

    test('campo pequeno: 1 sobe, ninguém desce', () {
      expect(LeagueService.promoteCountFor(2), 1);
      expect(LeagueService.promoteCountFor(4), 1);
      expect(LeagueService.demoteCountFor(4), 0);
    });

    test('2º de 3 permanece (não sobe todo mundo)', () {
      final s = LeagueService.settleClosedWeek(
        userXp: 50,
        peerSteps: const [80, 10],
        tierIndex: 0,
        groupSize: 20,
        maxTierIndex: 4,
      );
      expect(s.outcome, LeagueOutcome.stayed);
      expect(s.rank, 2);
    });

    test('último de 8 desce mesmo com grupo configurado em 20', () {
      final peers = List<int>.generate(7, (i) => 100 - i);
      final s = LeagueService.settleClosedWeek(
        userXp: 5,
        peerSteps: peers,
        tierIndex: 2,
        groupSize: 20,
        maxTierIndex: 4,
      );
      expect(s.outcome, LeagueOutcome.demoted);
      expect(s.rank, 8);
    });

    test('último de 4 não desce', () {
      final s = LeagueService.settleClosedWeek(
        userXp: 5,
        peerSteps: const [90, 80, 70],
        tierIndex: 2,
        groupSize: 20,
        maxTierIndex: 4,
      );
      expect(s.outcome, LeagueOutcome.stayed);
    });

    test('7º de 20 não sobe mais (antes: top 7)', () {
      final peers = List<int>.generate(19, (i) => 200 - i * 10);
      final s = LeagueService.settleClosedWeek(
        userXp: 145,
        peerSteps: peers,
        tierIndex: 1,
        groupSize: 20,
        maxTierIndex: 4,
      );
      expect(s.rank, 7);
      expect(s.outcome, LeagueOutcome.stayed);
    });
  });
}
