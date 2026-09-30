import 'dart:math';

import '../l10n/l10n_global.dart';
import 'pilgrim_medal_models.dart';
import '../widgets/cinematic_icon.dart';

export 'pilgrim_medals.dart' show tierColor;

/// Uma recompensa possível do Baú do Dia — cosmética, nunca XP/ranking.
/// Pool pequeno e conhecido (nunca "caixa preta"); piso garantido pelo
/// [PilgrimChestRoll.rollDaily] via pity. Não compete com o Cofre de
/// medalhas: raridade aqui é só apresentação, não conquista.
class PilgrimChestReward {
  final String id;
  final PilgrimMedalTier tier;
  final CinematicGlyph glyph;
  final int weight;

  const PilgrimChestReward({
    required this.id,
    required this.tier,
    required this.glyph,
    required this.weight,
  });

  String get title => switch (id) {
    'chest:grao' => L10n.current.chestGraoTitle,
    'chest:passo' => L10n.current.chestPassoTitle,
    'chest:lampada' => L10n.current.chestLampadaTitle,
    'chest:mapa' => L10n.current.chestMapaTitle,
    'chest:guardada' => L10n.current.chestGuardadaTitle,
    'chest:voz' => L10n.current.chestVozTitle,
    'chest:bencao' => L10n.current.chestBencaoTitle,
    _ => L10n.current.chestGraoTitle,
  };

  String get message => switch (id) {
    'chest:grao' => L10n.current.chestGraoMessage,
    'chest:passo' => L10n.current.chestPassoMessage,
    'chest:lampada' => L10n.current.chestLampadaMessage,
    'chest:mapa' => L10n.current.chestMapaMessage,
    'chest:guardada' => L10n.current.chestGuardadaMessage,
    'chest:voz' => L10n.current.chestVozMessage,
    'chest:bencao' => L10n.current.chestBencaoMessage,
    _ => L10n.current.chestGraoMessage,
  };
}

class PilgrimChestRewardDefs {
  PilgrimChestRewardDefs._();

  /// Piso: sem "mirra" há [pityThreshold] aberturas, a próxima é garantida.
  static const pityThreshold = 10;

  static const List<PilgrimChestReward> all = [
    PilgrimChestReward(
      id: 'chest:grao',
      tier: PilgrimMedalTier.iron,
      glyph: CinematicGlyph.seed,
      weight: 26,
    ),
    PilgrimChestReward(
      id: 'chest:passo',
      tier: PilgrimMedalTier.iron,
      glyph: CinematicGlyph.path,
      weight: 26,
    ),
    PilgrimChestReward(
      id: 'chest:lampada',
      tier: PilgrimMedalTier.bronze,
      glyph: CinematicGlyph.lamp,
      weight: 18,
    ),
    PilgrimChestReward(
      id: 'chest:mapa',
      tier: PilgrimMedalTier.bronze,
      glyph: CinematicGlyph.scroll,
      weight: 18,
    ),
    PilgrimChestReward(
      id: 'chest:guardada',
      tier: PilgrimMedalTier.silver,
      glyph: CinematicGlyph.heart,
      weight: 8,
    ),
    PilgrimChestReward(
      id: 'chest:voz',
      tier: PilgrimMedalTier.gold,
      glyph: CinematicGlyph.share,
      weight: 3,
    ),
    PilgrimChestReward(
      id: 'chest:bencao',
      tier: PilgrimMedalTier.mirra,
      glyph: CinematicGlyph.star,
      weight: 1,
    ),
  ];

  static PilgrimChestReward byId(String id) =>
      all.firstWhere((r) => r.id == id, orElse: () => all.first);
}

class PilgrimChestRoll {
  PilgrimChestRoll._();

  /// Sorteia 1 recompensa. Se [pityCount] já atingiu o piso, força "mirra".
  /// Devolve também o novo contador de pity (zera em mirra/ouro, senão soma 1).
  static ({PilgrimChestReward reward, int nextPity}) rollDaily(int pityCount) {
    final forced = pityCount >= PilgrimChestRewardDefs.pityThreshold;
    final pool = forced
        ? PilgrimChestRewardDefs.all
            .where((r) => r.tier == PilgrimMedalTier.mirra)
            .toList()
        : PilgrimChestRewardDefs.all;

    final totalWeight = pool.fold<int>(0, (sum, r) => sum + r.weight);
    var roll = Random().nextInt(totalWeight);
    var chosen = pool.first;
    for (final reward in pool) {
      if (roll < reward.weight) {
        chosen = reward;
        break;
      }
      roll -= reward.weight;
    }

    final isTopTier = chosen.tier == PilgrimMedalTier.mirra ||
        chosen.tier == PilgrimMedalTier.gold;
    return (reward: chosen, nextPity: isTopTier ? 0 : pityCount + 1);
  }
}
