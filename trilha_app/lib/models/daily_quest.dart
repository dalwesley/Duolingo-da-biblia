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
    this.icon = '',
  });
}

class DailyQuestDefs {
  /// Três gestos. Favoritar e memorizar não treinam formação o bastante
  /// para ocupar o Hoje; 100% já é medalha de Formação.
  static const List<DailyQuest> core = [
    DailyQuest(
      id: 'mission',
      title: 'Um passo',
      subtitle: 'Complete uma cena',
      target: 1,
      stepsReward: 15,
    ),
    DailyQuest(
      id: 'accuracy',
      title: 'Olho firme',
      subtitle: 'Termine uma cena com 80%+',
      target: 1,
      stepsReward: 25,
    ),
    DailyQuest(
      id: 'read',
      title: 'Na Palavra',
      subtitle: 'Leia um capítulo',
      target: 1,
      stepsReward: 20,
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
      title: 'Cinco passos',
      subtitle: 'Complete 5 cenas nesta semana',
      target: 5,
      stepsReward: 80,
    ),
    DailyQuest(
      id: 'w_days',
      title: 'Quatro dias',
      subtitle: 'Caminhe em 4 dias diferentes',
      target: 4,
      stepsReward: 60,
    ),
    DailyQuest(
      id: 'w_perfect',
      title: 'Duas nítidas',
      subtitle: 'Duas cenas com 100% na semana',
      target: 2,
      stepsReward: 100,
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
    TrailMilestone(
      percent: 25,
      stepsReward: 40,
      title: 'Primeiros passos',
      subtitle: '25% da trilha',
    ),
    TrailMilestone(
      percent: 50,
      stepsReward: 70,
      title: 'Meio do caminho',
      subtitle: '50% da trilha',
    ),
    TrailMilestone(
      percent: 75,
      stepsReward: 100,
      title: 'Quase lá',
      subtitle: '75% da trilha',
    ),
    TrailMilestone(
      percent: 100,
      stepsReward: 150,
      title: 'Jornada percorrida',
      subtitle: '100% — continue caminhando',
    ),
  ];
}
