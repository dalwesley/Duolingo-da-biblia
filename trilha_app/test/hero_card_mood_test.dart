import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/widgets/hero_card_atmosphere.dart';

void main() {
  test('walked today stays alive even if ice was used', () {
    expect(
      resolveHeroCardMood(
        atRisk: false,
        yesterdayFrozen: true,
        walkedToday: true,
        returningAfterGap: false,
      ),
      HeroCardMood.alive,
    );
  });

  test('ice covering yesterday freezes the card until today is walked', () {
    expect(
      resolveHeroCardMood(
        atRisk: true,
        yesterdayFrozen: true,
        walkedToday: false,
        returningAfterGap: false,
      ),
      HeroCardMood.frozen,
    );
  });

  test('at-risk today without ice cover is dusty', () {
    expect(
      resolveHeroCardMood(
        atRisk: true,
        yesterdayFrozen: false,
        walkedToday: false,
        returningAfterGap: false,
      ),
      HeroCardMood.dusty,
    );
  });

  test('ice used earlier this week does not protect a new gap', () {
    expect(
      resolveHeroCardMood(
        atRisk: false,
        yesterdayFrozen: false,
        walkedToday: false,
        returningAfterGap: true,
      ),
      HeroCardMood.dusty,
    );
  });
}
