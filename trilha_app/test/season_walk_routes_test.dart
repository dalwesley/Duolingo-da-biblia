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
      expect(c.dayAt(26)!.missionSlug, 'sm-05-fome-e-sede-de-justica');
    });

    test('troca o dia 26 com título e frase do idioma, sem mexer nos outros', () {
      SeasonWalkRoutes.instance.debugSet({
        'advento-2026': {
          26: const SeasonDayOverride(
            missionSlug: 'mq-04-belem',
            trailSlug: 'miqueias',
            title: {'pt': 'A pequena Belém', 'en': 'Little Bethlehem'},
            insight: {'pt': 'De ti sairá o Rei'},
          ),
        },
      });
      final c = SeasonWalkCatalog.advent(DateTime(2026, 11, 29));
      final d26 = c.dayAt(26)!;
      expect(d26.missionSlug, 'mq-04-belem');
      expect(d26.trailSlug, 'miqueias');
      expect(d26.index, 26);
      expect(d26.insight, 'De ti sairá o Rei');
      expect(c.dayAt(25)!.missionSlug, 'fp-01-alegria');
      // Outro ano não pega a troca deste.
      final next = SeasonWalkCatalog.advent(DateTime(2027, 11, 28));
      expect(next.dayAt(26)!.missionSlug, 'sm-05-fome-e-sede-de-justica');
    });

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
