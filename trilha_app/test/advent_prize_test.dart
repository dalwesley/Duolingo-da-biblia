import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/advent_prize.dart';
import 'package:trilha_app/models/season_walk.dart';
import 'package:trilha_app/models/study_room.dart';

SeasonWalkCampaign _campaign(List<String> slugs) => SeasonWalkCampaign(
  id: 'advento-2026',
  kind: SeasonWalkKind.advent,
  title: 'Advento',
  subtitle: '',
  start: DateTime(2026, 11, 29),
  days: [
    for (var i = 0; i < slugs.length; i++)
      SeasonWalkDay(
        index: i + 1,
        missionSlug: slugs[i],
        trailSlug: 't',
        title: '',
        insight: '',
      ),
  ],
);

void main() {
  final cfg = AdventPrizeConfig.forCampaign('advento-2026')!;

  test('padrão: prazo 24/12 23:59:59 de Brasília, foto no fim do 1º dia', () {
    expect(cfg.deadline, DateTime.parse('2026-12-24T23:59:59-03:00'));
    expect(cfg.rosterAt, DateTime.parse('2026-11-29T23:59:59-03:00'));
    expect(cfg.maxMonths, 3);
    expect(cfg.monthsFor(AdventTier.solo), 1);
    expect(cfg.monthsFor(AdventTier.pair), 2);
    expect(cfg.monthsFor(AdventTier.group), 3);
    expect(cfg.monthsFor(AdventTier.none), 0);
    expect(AdventPrizeConfig.forCampaign('advento-2027'), isNull);
  });

  test('prazo: aberto até o último segundo', () {
    expect(cfg.isOpen(DateTime.parse('2026-12-24T23:59:59-03:00')), isTrue);
    expect(cfg.isOpen(DateTime.parse('2026-12-25T00:00:00-03:00')), isFalse);
  });

  test('config remota sobrescreve; grupo nunca abaixo de 3', () {
    final o = cfg.merge({
      'months': {'group': 4},
      'groupMin': 2,
      'deadlineMs': 1000,
    });
    expect(o.groupMonths, 4);
    expect(o.pairMonths, 2);
    expect(o.groupMin, 3);
    expect(o.deadline.millisecondsSinceEpoch, 1000);
    expect(identical(cfg.merge(null), cfg), isTrue);
  });

  test('dia da cena: só dias já chegados, primeiro sem prova', () {
    final c = _campaign(['a', 'b', 'a', 'c']);
    final dec1 = DateTime(2026, 12, 1, 15);
    expect(AdventPrizeConfig.dayForScene(c, 'a', dec1), 1);
    expect(AdventPrizeConfig.dayForScene(c, 'a', dec1, proven: {1}), 3);
    expect(AdventPrizeConfig.dayForScene(c, 'a', dec1, proven: {1, 3}), 1);
    expect(AdventPrizeConfig.dayForScene(c, 'c', dec1), isNull);
    expect(AdventPrizeConfig.dayForScene(c, 'z', dec1), isNull);
    expect(
      AdventPrizeConfig.dayForScene(c, 'a', DateTime(2026, 11, 29), proven: {1}),
      1,
    );
  });

  test('nível alcançável pela foto do dia 1', () {
    expect(AdventPrizeState.empty.reachable, AdventTier.solo);
    expect(const AdventPrizeState(inPair: true).reachable, AdventTier.pair);
    expect(
      const AdventPrizeState(inPair: true, inGroup: true).reachable,
      AdventTier.group,
    );
    expect(AdventTier.parse('group'), AdventTier.group);
    expect(AdventTier.parse(null), AdventTier.none);
  });

  test('grupo só existe com 3 pessoas', () {
    expect(kRoomMinMembers, 3);
    expect(roomIsFormed(2), isFalse);
    expect(roomIsFormed(3), isTrue);
  });
}
