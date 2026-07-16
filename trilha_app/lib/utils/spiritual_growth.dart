/// Companion de hábito — a semente cresce com a sequência (vs. pet genérico).
enum GrowthStage {
  seed,
  sprout,
  sapling,
  olive,
  lamp,
}

class SpiritualGrowth {
  final GrowthStage stage;
  final String title;
  final String subtitle;
  final int streak;
  final int nextAt;

  const SpiritualGrowth({
    required this.stage,
    required this.title,
    required this.subtitle,
    required this.streak,
    required this.nextAt,
  });

  static SpiritualGrowth fromStreak(int streak) {
    final s = streak.clamp(0, 9999);
    if (s <= 0) {
      return SpiritualGrowth(
        stage: GrowthStage.seed,
        title: 'Semente',
        subtitle: 'Dê um passo para germinar',
        streak: s,
        nextAt: 1,
      );
    }
    if (s < 3) {
      return SpiritualGrowth(
        stage: GrowthStage.sprout,
        title: 'Broto',
        subtitle: 'A luz começa a aparecer — $s dia(s)',
        streak: s,
        nextAt: 3,
      );
    }
    if (s < 7) {
      return SpiritualGrowth(
        stage: GrowthStage.sapling,
        title: 'Muda',
        subtitle: 'Raízes firmes — rumo a 7 dias',
        streak: s,
        nextAt: 7,
      );
    }
    if (s < 14) {
      return SpiritualGrowth(
        stage: GrowthStage.olive,
        title: 'Oliveira',
        subtitle: 'Fruto da constância — 14 dias acendem a lâmpada',
        streak: s,
        nextAt: 14,
      );
    }
    return SpiritualGrowth(
      stage: GrowthStage.lamp,
      title: 'Lâmpada acesa',
      subtitle: '“Lâmpada para os meus pés é a tua palavra”',
      streak: s,
      nextAt: s,
    );
  }

  double get progressToNext {
    if (stage == GrowthStage.lamp) return 1;
    final prev = switch (stage) {
      GrowthStage.seed => 0,
      GrowthStage.sprout => 1,
      GrowthStage.sapling => 3,
      GrowthStage.olive => 7,
      GrowthStage.lamp => 14,
    };
    final span = (nextAt - prev).clamp(1, 99);
    return ((streak - prev) / span).clamp(0.0, 1.0);
  }
}
