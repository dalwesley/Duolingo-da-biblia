import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/home_support.dart';

void main() {
  const week = '2026-11-03';
  final today = DateTime(2026, 11, 5);

  HomeSupportKind? pick({
    bool storeReady = true,
    bool isSupporter = false,
    String thisWeek = week,
    String? lastShownWeek,
    DateTime? todayOverride,
    DateTime? lastSupportedAt,
  }) => HomeSupport.pick(
    storeReady: storeReady,
    isSupporter: isSupporter,
    thisWeek: thisWeek,
    lastShownWeek: lastShownWeek,
    today: todayOverride ?? today,
    lastSupportedAt: lastSupportedAt,
  );

  test('hidden without store or twice in the same week', () {
    expect(pick(storeReady: false), isNull);
    expect(pick(lastShownWeek: week), isNull);
    expect(pick(), HomeSupportKind.ask);
  });

  test('supporter waits the cooldown, then sees again', () {
    expect(
      pick(isSupporter: true, lastSupportedAt: DateTime(2026, 11, 1)),
      isNull,
    );
    expect(pick(isSupporter: true), isNull);
    expect(
      pick(
        isSupporter: true,
        lastSupportedAt: DateTime(2026, 9, 1),
        todayOverride: DateTime(2026, 11, 5),
      ),
      HomeSupportKind.again,
    );
    // Cooldown exato: 8 semanas = 56 dias.
    expect(
      pick(
        isSupporter: true,
        lastSupportedAt: DateTime(2026, 9, 10),
        todayOverride: DateTime(2026, 11, 5),
      ),
      HomeSupportKind.again,
    );
    expect(
      pick(
        isSupporter: true,
        lastSupportedAt: DateTime(2026, 9, 11),
        todayOverride: DateTime(2026, 11, 5),
      ),
      isNull,
    );
  });

  test('again also respects once per week', () {
    expect(
      pick(
        isSupporter: true,
        lastSupportedAt: DateTime(2026, 1, 1),
        lastShownWeek: week,
      ),
      isNull,
    );
  });
}
