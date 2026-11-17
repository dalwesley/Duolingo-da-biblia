import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/utils/juntos_invite_pace.dart';

void main() {
  // Foto do Advento 2026: 29/11 23:59:59 de Brasília.
  final roster = DateTime.utc(2026, 11, 30, 2, 59, 59);

  JuntosInviteKind? pick({
    required DateTime now,
    DateTime? rosterAt,
    bool adventDone = false,
    bool referralDone = false,
    int adventDeclines = 0,
    int referralDeclines = 0,
    List<DateTime> shown = const [],
  }) => JuntosInvitePace.pick(
    now: now,
    rosterAt: rosterAt,
    adventDone: adventDone,
    referralDone: referralDone,
    adventDeclines: adventDeclines,
    referralDeclines: referralDeclines,
    shownMs: [for (final d in shown) d.millisecondsSinceEpoch],
  );

  group('JuntosInvitePace.pick', () {
    test('Advento antes da foto; indicação depois', () {
      expect(
        pick(now: DateTime(2026, 11, 17, 10), rosterAt: roster),
        JuntosInviteKind.advent,
      );
      expect(
        pick(now: DateTime(2026, 12, 2, 10), rosterAt: roster),
        JuntosInviteKind.referral,
      );
    });

    test('Advento não aparece cedo demais', () {
      expect(
        pick(now: DateTime(2026, 10, 20, 10), rosterAt: roster),
        JuntosInviteKind.referral,
      );
    });

    test('dupla/grupo formado ou 3 recusas passam para a indicação', () {
      final now = DateTime(2026, 11, 17, 10);
      expect(
        pick(now: now, rosterAt: roster, adventDone: true),
        JuntosInviteKind.referral,
      );
      expect(
        pick(now: now, rosterAt: roster, adventDeclines: 3),
        JuntosInviteKind.referral,
      );
    });

    test('para de vez quando compartilhou ou recusou 3 vezes', () {
      final now = DateTime(2026, 12, 2, 10);
      expect(pick(now: now, referralDone: true), isNull);
      expect(pick(now: now, referralDeclines: 3), isNull);
    });

    test('até 2 por semana, com 2 dias entre uma e outra', () {
      // Semana de segunda 16/11.
      final mon = DateTime(2026, 11, 16, 9);
      final tue = DateTime(2026, 11, 17, 9);
      final wed = DateTime(2026, 11, 18, 9);
      final thu = DateTime(2026, 11, 19, 9);
      expect(pick(now: tue, shown: [mon]), isNull);
      expect(pick(now: wed, shown: [mon]), JuntosInviteKind.referral);
      expect(pick(now: DateTime(2026, 11, 21), shown: [mon, wed]), isNull);
      // Semana nova: conta zera, mas o intervalo segue valendo.
      expect(
        pick(now: DateTime(2026, 11, 23, 9), shown: [wed, thu]),
        JuntosInviteKind.referral,
      );
      expect(
        pick(now: DateTime(2026, 11, 23, 9), shown: [DateTime(2026, 11, 22)]),
        isNull,
      );
    });
  });
}
