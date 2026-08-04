import 'dust_copy.dart';

/// Companion de hábito — marcos da sequência diária (treino, não ritual).
enum GrowthStage {
  seed,
  sprout,
  sapling,
  olive,
  lamp;

  String get label => switch (this) {
        GrowthStage.seed => 'Semente',
        GrowthStage.sprout => 'Broto',
        GrowthStage.sapling => 'Muda',
        GrowthStage.olive => 'Oliveira',
        GrowthStage.lamp => 'Lâmpada',
      };

  /// Dias de streak necessários para alcançar este marco.
  int get unlockAt => switch (this) {
        GrowthStage.seed => 0,
        GrowthStage.sprout => 1,
        GrowthStage.sapling => 3,
        GrowthStage.olive => 7,
        GrowthStage.lamp => 14,
      };

  String get shortHint => switch (this) {
        GrowthStage.seed => 'dia 0',
        GrowthStage.sprout => '1 dia',
        GrowthStage.sapling => '3 dias',
        GrowthStage.olive => '7 dias',
        GrowthStage.lamp => '14 dias',
      };
}

/// Humor reativo do Living Seed — presença de jogo sem pet shop.
enum SeedMood {
  calm,
  thriving,
  atRisk,
  perfectGlow,
  frozen,
}

class SpiritualGrowth {
  final GrowthStage stage;
  final String title;
  final String subtitle;
  final int streak;
  final int nextAt;
  final SeedMood mood;

  const SpiritualGrowth({
    required this.stage,
    required this.title,
    required this.subtitle,
    required this.streak,
    required this.nextAt,
    this.mood = SeedMood.calm,
  });

  static SpiritualGrowth fromStreak(int streak) {
    return fromSignals(streak: streak);
  }

  /// Reage a streak, risco de gelo e missão perfeita recente.
  static SpiritualGrowth fromSignals({
    required int streak,
    bool atRisk = false,
    bool freezeAvailable = true,
    bool perfectRecent = false,
  }) {
    final base = _stageFor(streak);
    final SeedMood mood;
    final String subtitle;
    if (perfectRecent) {
      mood = SeedMood.perfectGlow;
      subtitle = 'Missão perfeita · marco brilhou';
    } else if (atRisk) {
      mood = SeedMood.atRisk;
      subtitle = DustCopy.uiRiskLine(hasFreeze: freezeAvailable);
    } else if (!freezeAvailable && streak > 0) {
      mood = SeedMood.frozen;
      subtitle = '${base.subtitle} · gelo já usado nesta semana';
    } else if (streak >= 3) {
      mood = SeedMood.thriving;
      subtitle = base.subtitle;
    } else {
      mood = SeedMood.calm;
      subtitle = base.subtitle;
    }
    return SpiritualGrowth(
      stage: base.stage,
      title: base.title,
      subtitle: subtitle,
      streak: base.streak,
      nextAt: base.nextAt,
      mood: mood,
    );
  }

  static SpiritualGrowth _stageFor(int streak) {
    final s = streak.clamp(0, 9999);
    if (s <= 0) {
      return SpiritualGrowth(
        stage: GrowthStage.seed,
        title: 'Semente',
        subtitle: 'Faça 1 missão hoje para virar Broto',
        streak: s,
        nextAt: 1,
      );
    }
    if (s < 3) {
      final left = 3 - s;
      return SpiritualGrowth(
        stage: GrowthStage.sprout,
        title: 'Broto',
        subtitle: left == 1
            ? 'Falta 1 dia seguido para Muda'
            : 'Faltam $left dias seguidos para Muda',
        streak: s,
        nextAt: 3,
      );
    }
    if (s < 7) {
      final left = 7 - s;
      return SpiritualGrowth(
        stage: GrowthStage.sapling,
        title: 'Muda',
        subtitle: left == 1
            ? 'Falta 1 dia seguido para Oliveira'
            : 'Faltam $left dias seguidos para Oliveira',
        streak: s,
        nextAt: 7,
      );
    }
    if (s < 14) {
      final left = 14 - s;
      return SpiritualGrowth(
        stage: GrowthStage.olive,
        title: 'Oliveira',
        subtitle: left == 1
            ? 'Falta 1 dia seguido para Lâmpada'
            : 'Faltam $left dias seguidos para Lâmpada',
        streak: s,
        nextAt: 14,
      );
    }
    return SpiritualGrowth(
      stage: GrowthStage.lamp,
      title: 'Lâmpada',
      subtitle: '$s dias seguidos · hábito consolidado',
      streak: s,
      nextAt: s,
    );
  }

  GrowthStage? get nextStage {
    final i = GrowthStage.values.indexOf(stage);
    if (i < 0 || i >= GrowthStage.values.length - 1) return null;
    return GrowthStage.values[i + 1];
  }

  int get daysToNext {
    if (stage == GrowthStage.lamp) return 0;
    return (nextAt - streak).clamp(0, 99);
  }

  double get progressToNext {
    if (stage == GrowthStage.lamp) return 1;
    final prev = stage.unlockAt == 0 && stage == GrowthStage.seed
        ? 0
        : switch (stage) {
            GrowthStage.seed => 0,
            GrowthStage.sprout => 1,
            GrowthStage.sapling => 3,
            GrowthStage.olive => 7,
            GrowthStage.lamp => 14,
          };
    final span = (nextAt - prev).clamp(1, 99);
    return ((streak - prev) / span).clamp(0.0, 1.0);
  }

  bool get glowing =>
      mood == SeedMood.perfectGlow ||
      mood == SeedMood.thriving ||
      mood == SeedMood.atRisk;
}
