import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/data/season_walk_catalog.dart';
import 'package:trilha_app/data/season_walk_routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => SeasonWalkRoutes.instance.debugSet({}));

  group('roteiro da Caminhada vindo do banco', () {
    test('sem troca, o Advento é o do código', () {
      SeasonWalkRoutes.instance.debugSet({});
      final c = SeasonWalkCatalog.advent(DateTime(2026, 11, 29));
      expect(c.days.length, 26);
      expect(c.dayAt(26)!.missionSlug, 'mq-04-belem');
    });

    test(
      'troca o dia 22 com título e frase do idioma, sem mexer nos outros',
      () {
        SeasonWalkRoutes.instance.debugSet({
          'advento-2026': {
            22: const SeasonDayOverride(
              missionSlug: 'mtc-02-os-magos-e-a',
              trailSlug: 'mateus-cap',
              title: {'pt': 'Os magos e a estrela', 'en': 'The magi'},
              insight: {'pt': 'Vieram adorar o Rei'},
            ),
          },
        });
        final c = SeasonWalkCatalog.advent(DateTime(2026, 11, 29));
        final d22 = c.dayAt(22)!;
        expect(d22.missionSlug, 'mtc-02-os-magos-e-a');
        expect(d22.trailSlug, 'mateus-cap');
        expect(d22.index, 22);
        expect(d22.insight, 'Vieram adorar o Rei');
        expect(c.dayAt(21)!.missionSlug, 'evg-07-ceia');
        expect(c.dayAt(26)!.missionSlug, 'mq-04-belem');
        // Outro ano não pega a troca deste.
        final next = SeasonWalkCatalog.advent(DateTime(2027, 11, 28));
        expect(next.dayAt(22)!.missionSlug, 'evg-08-cruz');
      },
    );

    test('lê o mapa do banco e descarta o que não serve', () {
      final days = SeasonWalkRoutes.parseDays(
        {
          '26': {
            'slug': 'mq-04-belem',
            'trail': 'miqueias',
            'title': {'pt': 'A pequena Belém', 'en': ''},
          },
          '22': {'slug': 'nao-existe', 'trail': 'x'},
          '0': {'slug': 'mq-04-belem', 'trail': 'miqueias'},
          '41': {'slug': 'mq-04-belem', 'trail': 'miqueias'},
          'abc': {'slug': 'mq-04-belem', 'trail': 'miqueias'},
          '3': {'slug': '', 'trail': 'miqueias'},
          '4': 'texto solto',
        },
        known: {'mq-04-belem'},
      );
      expect(days.keys, [26]);
      expect(days[26]!.title, {'pt': 'A pequena Belém'});
      expect(SeasonWalkRoutes.parseDays(26), isEmpty);
    });
  });
}
