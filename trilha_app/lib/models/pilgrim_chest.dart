import 'dart:math';

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
  final String title;
  final String message;
  final CinematicGlyph glyph;
  final int weight;

  const PilgrimChestReward({
    required this.id,
    required this.tier,
    required this.title,
    required this.message,
    required this.glyph,
    required this.weight,
  });
}

class PilgrimChestRewardDefs {
  PilgrimChestRewardDefs._();

  /// Piso: sem "mirra" há [pityThreshold] aberturas, a próxima é garantida.
  static const pityThreshold = 10;

  static const List<PilgrimChestReward> all = [
    PilgrimChestReward(
      id: 'chest:grao',
      tier: PilgrimMedalTier.iron,
      title: 'Grão de trigo',
      message: 'Pequeno hoje, semente de algo maior amanhã.',
      glyph: CinematicGlyph.seed,
      weight: 26,
    ),
    PilgrimChestReward(
      id: 'chest:passo',
      tier: PilgrimMedalTier.iron,
      title: 'Passo firme',
      message: 'Mais um dia caminhando — é isso que forma um peregrino.',
      glyph: CinematicGlyph.path,
      weight: 26,
    ),
    PilgrimChestReward(
      id: 'chest:lampada',
      tier: PilgrimMedalTier.bronze,
      title: 'Lâmpada acesa',
      message: '"Lâmpada para os meus pés é a tua palavra" — Salmos 119:105.',
      glyph: CinematicGlyph.lamp,
      weight: 18,
    ),
    PilgrimChestReward(
      id: 'chest:mapa',
      tier: PilgrimMedalTier.bronze,
      title: 'Mapa do dia',
      message: 'Uma curiosidade guardada: cada capítulo lido soma na sua trilha.',
      glyph: CinematicGlyph.scroll,
      weight: 18,
    ),
    PilgrimChestReward(
      id: 'chest:guardada',
      tier: PilgrimMedalTier.silver,
      title: 'Palavra guardada',
      message: 'Este momento vale um versículo guardado no coração hoje.',
      glyph: CinematicGlyph.heart,
      weight: 8,
    ),
    PilgrimChestReward(
      id: 'chest:voz',
      tier: PilgrimMedalTier.gold,
      title: 'Voz da caravana',
      message: 'Sua constância já fala mais alto que qualquer palavra.',
      glyph: CinematicGlyph.share,
      weight: 3,
    ),
    PilgrimChestReward(
      id: 'chest:bencao',
      tier: PilgrimMedalTier.mirra,
      title: 'Bênção rara',
      message: '"O Senhor te abençoe e te guarde" — Números 6:24.',
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
