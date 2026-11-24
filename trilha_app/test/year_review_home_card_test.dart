import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/services/progress_service.dart';
import 'package:trilha_app/widgets/year_review_home_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('resumo conta cenas do ano, dias distintos e uma vez por cena', () async {
    SharedPreferences.setMockInitialValues({});
    final progress = ProgressService();
    progress.missionCompletedOn = {
      'a': '2026-03-01',
      'b': '2026-03-01',
      'c': '2026-12-20',
      'velha': '2025-12-30',
    };
    progress.postcardsOn = {'b': '2026-05-02'};
    final trails = [
      Trail.fromJson({
        'slug': 't',
        'title': 'T',
        'description': '',
        'icon': '✨',
        'modules': [
          {
            'title': 'M',
            'icon': '⭐',
            'missions': [
              {'slug': 'a', 'title': 'A'},
              {'slug': 'b', 'title': 'B'},
              {'slug': 'c', 'title': 'C'},
              {'slug': 'velha', 'title': 'V'},
            ],
          },
        ],
      }),
    ];
    final s = YearReviewHomeCard.summary(progress, trails, 2026);
    expect(s.count, 3);
    expect(s.days, 3);
  });
}
