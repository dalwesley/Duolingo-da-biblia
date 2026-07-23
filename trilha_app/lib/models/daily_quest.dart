import '../utils/liturgical_calendar.dart';

/// Missões diárias — loop de retenção além da meta.
class DailyQuest {
  final String id;
  final String title;
  final String subtitle;
  final int target;
  final int stepsReward;
  final String icon;

  const DailyQuest({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.target,
    required this.stepsReward,
    required this.icon,
  });
}

class DailyQuestDefs {
  static const List<DailyQuest> core = [
    DailyQuest(
      id: 'mission',
      title: 'Um passo hoje',
      subtitle: 'Avance em qualquer trecho',
      target: 1,
      stepsReward: 15,
      icon: '👣',
    ),
    DailyQuest(
      id: 'accuracy',
      title: 'Andando na Luz',
      subtitle: 'Termine com 80%+ de clareza',
      target: 1,
      stepsReward: 25,
      icon: '✨',
    ),
    DailyQuest(
      id: 'perfect',
      title: 'Passo firme',
      subtitle: 'Um passo sem tropeços (100%)',
      target: 1,
      stepsReward: 40,
      icon: '🪔',
    ),
    DailyQuest(
      id: 'read',
      title: 'Palavra viva',
      subtitle: 'Leia um capítulo da Bíblia',
      target: 1,
      stepsReward: 20,
      icon: '📜',
    ),
    DailyQuest(
      id: 'bookmark',
      title: 'Sedento pela Palavra',
      subtitle: 'Favorite um versículo',
      target: 1,
      stepsReward: 15,
      icon: '⭐',
    ),
    DailyQuest(
      id: 'memory',
      title: 'No coração',
      subtitle: 'Revise 3 versículos na memorização',
      target: 3,
      stepsReward: 25,
      icon: '🧠',
    ),
  ];

  /// Inclui missão litúrgica nos tempos fortes.
  static List<DailyQuest> get all {
    final seasonal = LiturgicalCalendar.seasonalQuestToday();
    if (seasonal == null) return core;
    return [...core, seasonal];
  }
}

/// Passos semanais — ritmo de médio prazo.
class WeeklyQuestDefs {
  static const List<DailyQuest> all = [
    DailyQuest(
      id: 'w_missions',
      title: 'Sequência constante',
      subtitle: 'Dê 5 passos esta semana',
      target: 5,
      stepsReward: 80,
      icon: '🗓️',
    ),
    DailyQuest(
      id: 'w_days',
      title: 'Perseverança',
      subtitle: 'Caminhe em 4 dias diferentes',
      target: 4,
      stepsReward: 60,
      icon: '🔥',
    ),
    DailyQuest(
      id: 'w_perfect',
      title: 'Passos firmes',
      subtitle: '2 passos sem tropeços na semana',
      target: 2,
      stepsReward: 100,
      icon: '💎',
    ),
  ];
}

/// Baús de marco na jornada (25 / 50 / 75 / 100%).
class TrailMilestone {
  final int percent;
  final int stepsReward;
  final String title;
  final String subtitle;

  const TrailMilestone({
    required this.percent,
    required this.stepsReward,
    required this.title,
    required this.subtitle,
  });

  String chestId(String trailSlug) => '$trailSlug:$percent';

  static const List<TrailMilestone> all = [
    TrailMilestone(percent: 25, stepsReward: 40, title: 'Primeiros passos', subtitle: '25% da trilha'),
    TrailMilestone(percent: 50, stepsReward: 70, title: 'Meio do caminho', subtitle: '50% da trilha'),
    TrailMilestone(percent: 75, stepsReward: 100, title: 'Quase lá', subtitle: '75% da trilha'),
    TrailMilestone(percent: 100, stepsReward: 150, title: 'Jornada percorrida', subtitle: '100% — continue caminhando'),
  ];
}
