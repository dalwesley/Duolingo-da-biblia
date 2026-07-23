/// Companion de hábito — marcos da sequência diária (treino, não ritual).
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
        title: 'Iniciante',
        subtitle: 'Complete uma lição para começar a sequência',
        streak: s,
        nextAt: 1,
      );
    }
    if (s < 3) {
      return SpiritualGrowth(
        stage: GrowthStage.sprout,
        title: 'Em ritmo',
        subtitle: '$s dia(s) · meta: 3 dias seguidos',
        streak: s,
        nextAt: 3,
      );
    }
    if (s < 7) {
      return SpiritualGrowth(
        stage: GrowthStage.sapling,
        title: 'Semana em construção',
        subtitle: 'Rumo a 7 dias seguidos',
        streak: s,
        nextAt: 7,
      );
    }
    if (s < 14) {
      return SpiritualGrowth(
        stage: GrowthStage.olive,
        title: 'Duas semanas',
        subtitle: 'Constância firme — próximo marco em 14 dias',
        streak: s,
        nextAt: 14,
      );
    }
    return SpiritualGrowth(
      stage: GrowthStage.lamp,
      title: 'Sequência consolidada',
      subtitle: '$s dias · o hábito está formado',
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
