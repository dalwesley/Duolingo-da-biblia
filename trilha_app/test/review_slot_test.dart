import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/models/season_walk.dart';
import 'package:trilha_app/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Um fluxo de revisão por dia', () {
    test('revisão da semana concluída ocupa o dia das outras', () async {
      final p = ProgressService();
      final week = p.weeklyReviewWeekKey();
      await p.completeMission(
        '${ProgressService.weeklyReviewSlugPrefix}$week',
        30,
      );
      expect(p.isWeeklyReviewDone(week), isTrue);
      expect(p.isReviewDoneToday, isTrue);
      // Não finge que a Revisão do Dia foi feita — só ocupou o dia.
      expect(p.isDailyReviewDoneToday, isFalse);
    });

    test('fechamento da temporada ocupa o dia e marca a semana', () async {
      final p = ProgressService();
      await p.completeMission('walk-review-advento-2026-0', 30);
      expect(p.isSeasonReviewDone('advento-2026', 0), isTrue);
      expect(p.isSeasonReviewDone('advento-2026', 1), isFalse);
      expect(p.isReviewDoneToday, isTrue);
    });

    test('cena comum não ocupa o dia de revisão', () async {
      final p = ProgressService();
      await p.completeMission('gen-test-01', 40, correct: 3, total: 6);
      expect(p.isReviewDoneToday, isFalse);
    });
  });

  group('Fechamento da temporada pendente', () {
    SeasonWalkCampaign campaign() => SeasonWalkCampaign(
      id: 'advento-2026',
      kind: SeasonWalkKind.advent,
      title: 'Advento',
      subtitle: '',
      start: DateTime(2026, 11, 30),
      days: [
        for (var i = 1; i <= 7; i++)
          SeasonWalkDay(
            index: i,
            missionSlug: 'cena-$i',
            trailSlug: 'mateus',
            title: 'Dia $i',
            insight: '',
          ),
      ],
    );

    test('semana terminada com metade feita e sem revisão: pendente', () {
      expect(
        SeasonWalkAccess.weekReviewPending(
          campaign: campaign(),
          today: DateTime(2026, 12, 10),
          isDayDone: (d) => d.index <= 4,
          isReviewDone: (_) => false,
        ),
        isTrue,
      );
    });

    test('fechamento esquecido expira em uma semana', () {
      expect(
        SeasonWalkAccess.weekReviewPending(
          campaign: campaign(),
          today: DateTime(2026, 12, 20),
          isDayDone: (d) => d.index <= 4,
          isReviewDone: (_) => false,
        ),
        isFalse,
      );
    });

    test('já fechada ou com poucos dias: não pendente', () {
      expect(
        SeasonWalkAccess.weekReviewPending(
          campaign: campaign(),
          today: DateTime(2026, 12, 10),
          isDayDone: (d) => d.index <= 4,
          isReviewDone: (_) => true,
        ),
        isFalse,
      );
      expect(
        SeasonWalkAccess.weekReviewPending(
          campaign: campaign(),
          today: DateTime(2026, 12, 10),
          isDayDone: (d) => d.index <= 3,
          isReviewDone: (_) => false,
        ),
        isFalse,
      );
    });
  });
}
