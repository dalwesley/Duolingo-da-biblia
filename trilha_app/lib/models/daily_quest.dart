import '../l10n/l10n_global.dart';
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
  static List<DailyQuest> get core => [
    DailyQuest(
      id: 'mission',
      title: L10n.current.questMissionTitle,
      subtitle: L10n.current.questMissionSubtitle,
      target: 1,
      stepsReward: 15,
    ),
    DailyQuest(
      id: 'accuracy',
      title: L10n.current.questAccuracyTitle,
      subtitle: L10n.current.questAccuracySubtitle,
      target: 1,
      stepsReward: 25,
    ),
    DailyQuest(
      id: 'read',
      title: L10n.current.questReadTitle,
      subtitle: L10n.current.questReadSubtitle,
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
  static List<DailyQuest> get all => [
    DailyQuest(
      id: 'w_missions',
      title: L10n.current.questWeeklyScenesTitle,
      subtitle: L10n.current.questWeeklyScenesSubtitle,
      target: 5,
      stepsReward: 80,
    ),
    DailyQuest(
      id: 'w_days',
      title: L10n.current.questWeeklyDaysTitle,
      subtitle: L10n.current.questWeeklyDaysSubtitle,
      target: 4,
      stepsReward: 60,
    ),
    DailyQuest(
      id: 'w_perfect',
      title: L10n.current.questWeeklyPerfectTitle,
      subtitle: L10n.current.questWeeklyPerfectSubtitle,
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

  static List<TrailMilestone> get all => [
    TrailMilestone(
      percent: 25,
      stepsReward: 40,
      title: L10n.current.questMilestone25Title,
      subtitle: L10n.current.questMilestone25Subtitle,
    ),
    TrailMilestone(
      percent: 50,
      stepsReward: 70,
      title: L10n.current.questMilestone50Title,
      subtitle: L10n.current.questMilestone50Subtitle,
    ),
    TrailMilestone(
      percent: 75,
      stepsReward: 100,
      title: L10n.current.questMilestone75Title,
      subtitle: L10n.current.questMilestone75Subtitle,
    ),
    TrailMilestone(
      percent: 100,
      stepsReward: 150,
      title: L10n.current.questMilestone100Title,
      subtitle: L10n.current.questMilestone100Subtitle,
    ),
  ];
}
