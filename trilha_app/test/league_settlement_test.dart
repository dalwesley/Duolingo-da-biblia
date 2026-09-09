import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/services/league_service.dart';

void main() {
  group('LeagueService.fieldIsCompetitive', () {
    test('sozinho ou com 1 par não tem tensão', () {
      expect(LeagueService.fieldIsCompetitive(0), isFalse);
      expect(LeagueService.fieldIsCompetitive(1), isFalse);
    });

    test('dois pares (3 no campo) já competem', () {
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

    test('um par só ainda não promove', () {
      final s = LeagueService.settleClosedWeek(
        userXp: 80,
        peerSteps: const [10],
        tierIndex: 0,
        groupSize: 20,
        maxTierIndex: 4,
      );
      expect(s.outcome, isNull);
      expect(s.tierDelta, 0);
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
}
