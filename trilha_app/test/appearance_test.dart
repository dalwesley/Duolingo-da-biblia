import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/appearance.dart';
import 'package:trilha_app/utils/day_phase.dart';

void main() {
  test('cada modo pinta o céu que o app realmente usa', () {
    expect(
      AppearanceStyle.resolve(AppearanceMode.morning).phase,
      DayPhase.morning,
    );
    expect(
      AppearanceStyle.resolve(AppearanceMode.afternoon).phase,
      DayPhase.afternoon,
    );
    expect(
      AppearanceStyle.resolve(AppearanceMode.night).phase,
      DayPhase.night,
    );
  });

  test('automático segue o relógio e à noite usa o mesmo céu de Noite', () {
    final morning = AppearanceStyle.resolve(
      AppearanceMode.automatic,
      DateTime(2026, 9, 22, 9),
    );
    final afternoon = AppearanceStyle.resolve(
      AppearanceMode.automatic,
      DateTime(2026, 9, 22, 15),
    );
    final evening = AppearanceStyle.resolve(
      AppearanceMode.automatic,
      DateTime(2026, 9, 22, 19),
    );
    final night = AppearanceStyle.resolve(
      AppearanceMode.automatic,
      DateTime(2026, 9, 22, 23),
    );

    expect(morning.phase, DayPhase.morning);
    expect(morning.look, AppearanceLook.morning);
    expect(afternoon.phase, DayPhase.afternoon);
    expect(afternoon.look, AppearanceLook.afternoon);
    expect(evening.phase, DayPhase.night);
    expect(evening.look, AppearanceLook.night);
    expect(night.phase, DayPhase.night);
    expect(night.look, AppearanceLook.night);
  });

  test('painéis de manhã, tarde e noite não compartilham o mesmo fill', () {
    final morning = AppearanceStyle.resolve(AppearanceMode.morning);
    final afternoon = AppearanceStyle.resolve(AppearanceMode.afternoon);
    final night = AppearanceStyle.resolve(AppearanceMode.night);

    expect(morning.cardFill, isNot(afternoon.cardFill));
    expect(morning.cardFill, isNot(night.cardFill));
    expect(afternoon.cardFill, isNot(night.cardFill));
    expect(morning.navBarFill, isNot(night.navBarFill));
  });
}
