/// Missões diárias — loop de retenção além da meta.
class DailyQuest {
  final String id;
  final String title;
  final String subtitle;
  final int target;
  final int xpReward;
  final String icon;

  const DailyQuest({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.target,
    required this.xpReward,
    required this.icon,
  });
}

class DailyQuestDefs {
  static const List<DailyQuest> all = [
    DailyQuest(
      id: 'mission',
      title: 'Uma missão hoje',
      subtitle: 'Complete qualquer missão',
      target: 1,
      xpReward: 15,
      icon: '📖',
    ),
    DailyQuest(
      id: 'accuracy',
      title: 'Fiel ao texto',
      subtitle: 'Termine com 80%+ de acertos',
      target: 1,
      xpReward: 25,
      icon: '✨',
    ),
    DailyQuest(
      id: 'perfect',
      title: 'Sem mancha',
      subtitle: 'Missão perfeita (100%)',
      target: 1,
      xpReward: 40,
      icon: '👑',
    ),
  ];
}

/// Missões semanais — retenção de médio prazo.
class WeeklyQuestDefs {
  static const List<DailyQuest> all = [
    DailyQuest(
      id: 'w_missions',
      title: 'Semana fiel',
      subtitle: 'Complete 5 missões esta semana',
      target: 5,
      xpReward: 80,
      icon: '🗓️',
    ),
    DailyQuest(
      id: 'w_days',
      title: 'Ritmo constante',
      subtitle: 'Estude em 4 dias diferentes',
      target: 4,
      xpReward: 60,
      icon: '🔥',
    ),
    DailyQuest(
      id: 'w_perfect',
      title: 'Excelência',
      subtitle: '2 missões perfeitas na semana',
      target: 2,
      xpReward: 100,
      icon: '💎',
    ),
  ];
}

/// Baús de marco na trilha (25 / 50 / 75 / 100%).
class TrailMilestone {
  final int percent;
  final int xpReward;
  final String title;
  final String subtitle;

  const TrailMilestone({
    required this.percent,
    required this.xpReward,
    required this.title,
    required this.subtitle,
  });

  String chestId(String trailSlug) => '$trailSlug:$percent';

  static const List<TrailMilestone> all = [
    TrailMilestone(percent: 25, xpReward: 40, title: 'Primeiros passos', subtitle: '25% da trilha'),
    TrailMilestone(percent: 50, xpReward: 70, title: 'Meio do caminho', subtitle: '50% da trilha'),
    TrailMilestone(percent: 75, xpReward: 100, title: 'Quase lá', subtitle: '75% da trilha'),
    TrailMilestone(percent: 100, xpReward: 150, title: 'Trilha concluída', subtitle: '100% — baú final'),
  ];
}
