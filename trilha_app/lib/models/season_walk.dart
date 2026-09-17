/// Caminhada compartilhada — todo mundo no mesmo dia do calendário.
enum SeasonWalkKind { advent, lent }

class SeasonWalkDay {
  final int index;
  final String missionSlug;
  final String trailSlug;
  final String title;
  final String insight;

  const SeasonWalkDay({
    required this.index,
    required this.missionSlug,
    required this.trailSlug,
    required this.title,
    required this.insight,
  });

  DateTime dateOn(DateTime start) =>
      DateTime(start.year, start.month, start.day).add(Duration(days: index - 1));
}

class SeasonWalkCampaign {
  final String id;
  final SeasonWalkKind kind;
  final String title;
  final String subtitle;
  final DateTime start;
  final List<SeasonWalkDay> days;
  static const freeDays = 3;

  const SeasonWalkCampaign({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.start,
    required this.days,
  });

  DateTime get end => days.isEmpty
      ? start
      : DateTime(start.year, start.month, start.day)
          .add(Duration(days: days.length - 1));

  int get length => days.length;

  bool contains(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  /// 1-based. Null se [day] está fora da janela.
  int? dayIndexOn(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    if (d.isBefore(start) || d.isAfter(end)) return null;
    return d.difference(start).inDays + 1;
  }

  SeasonWalkDay? dayAt(int index) {
    if (index < 1 || index > days.length) return null;
    return days[index - 1];
  }

  SeasonWalkDay? dayFor(DateTime day) {
    final i = dayIndexOn(day);
    return i == null ? null : dayAt(i);
  }

  int get weekCount => (days.length / 7).ceil();

  List<SeasonWalkDay> week(int weekIndex) {
    final startAt = weekIndex * 7;
    return days.skip(startAt).take(7).toList();
  }

  bool isFreeDay(int index) => index >= 1 && index <= freeDays;
}

class SeasonWalkAccess {
  final bool playable;
  final bool future;
  final bool needsPro;

  const SeasonWalkAccess({
    required this.playable,
    this.future = false,
    this.needsPro = false,
  });

  static const lockedFuture = SeasonWalkAccess(playable: false, future: true);
  static const lockedPro = SeasonWalkAccess(playable: false, needsPro: true);
  static const open = SeasonWalkAccess(playable: true);

  /// Prefere ato errado da semana; senão um ainda não usado; senão o primeiro.
  static String? pickReviewActId({
    required Iterable<String> poolIds,
    required Iterable<String> mistakeIds,
    required Iterable<String> usedIds,
  }) {
    final pool = poolIds.toList();
    if (pool.isEmpty) return null;
    final mistakes = mistakeIds.toSet();
    final used = usedIds.toSet();
    for (final id in pool) {
      if (mistakes.contains(id)) return id;
    }
    for (final id in pool) {
      if (!used.contains(id)) return id;
    }
    return pool.first;
  }
}
