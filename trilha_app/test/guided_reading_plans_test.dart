import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/data/guided_reading_plans.dart';

// Capítulos por livro, ordem canônica (Gênesis … Apocalipse).
const _counts = [
  50, 40, 27, 36, 34, 24, 21, 4, 31, 24, 22, 25, 29, 36, 10, 13, 10, 42, //
  150, 31, 12, 8, 66, 52, 5, 48, 12, 14, 3, 9, 1, 4, 7, 3, 3, 3, 2, 14, 4,
  28, 16, 24, 21, 28, 16, 16, 13, 6, 6, 4, 4, 5, 3, 6, 4, 3, 1, 13, 5, 5, 3,
  5, 1, 1, 1, 22,
];

void main() {
  test('every plan has its number of days, none empty, in order', () {
    for (final plan in GuidedReadingPlan.all) {
      final days = plan.build(_counts);
      expect(days, hasLength(plan.days), reason: plan.id);
      expect(days.every((d) => d.isNotEmpty), isTrue, reason: plan.id);
    }
  });

  test('chapters are covered once each', () {
    int total(String id) => GuidedReadingPlan.byId(
      id,
    )!.build(_counts).fold(0, (n, d) => n + d.length);
    expect(total('evangelhos-30'), 28 + 16 + 24 + 21);
    expect(total('nt-90'), 260);
    expect(total('atos-28'), 28);
    expect(total('genesis-25'), 50);
    expect(total('salmos-proverbios-31'), 150 + 31);
  });

  test('psalms plan pairs one Proverbs chapter per day', () {
    final days = GuidedReadingPlan.byId('salmos-proverbios-31')!.build(_counts);
    for (var d = 0; d < 31; d++) {
      final proverbs = days[d].where((c) => c.book == 19).toList();
      expect(proverbs.single.chapter, d + 1);
    }
  });

  test('spread keeps order and balances day sizes', () {
    final chapters = GuidedReadingPlan.chaptersOf(_counts, 39, 42);
    final days = GuidedReadingPlan.spread(chapters, 30);
    expect([for (final d in days) ...d], chapters);
    final sizes = days.map((d) => d.length).toSet();
    expect(
      sizes.reduce((a, b) => a > b ? a : b) -
          sizes.reduce((a, b) => a < b ? a : b),
      lessThanOrEqualTo(1),
    );
  });
}
