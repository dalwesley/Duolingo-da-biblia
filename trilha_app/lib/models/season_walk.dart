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

  DateTime dateOn(DateTime start) => DateTime(
    start.year,
    start.month,
    start.day,
  ).add(Duration(days: index - 1));
}

class SeasonWalkCampaign {
  final String id;
  final SeasonWalkKind kind;
  final String title;
  final String subtitle;
  final DateTime start;
  final List<SeasonWalkDay> days;

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
      : DateTime(
          start.year,
          start.month,
          start.day,
        ).add(Duration(days: days.length - 1));

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
}

class SeasonWalkAccess {
  final bool playable;
  final bool future;

  /// Dia da temporada que só o Peregrino+ abre. A cena segue livre na trilha.
  final bool needsPlus;

  /// O 1º dia é de todo mundo. Do 2º em diante, o Plus.
  static const freeDays = 1;

  const SeasonWalkAccess({
    required this.playable,
    this.future = false,
    this.needsPlus = false,
  });

  static const lockedFuture = SeasonWalkAccess(playable: false, future: true);
  static const lockedPlus = SeasonWalkAccess(playable: false, needsPlus: true);
  static const open = SeasonWalkAccess(playable: true);

  static bool needsPlusDay(int index) => index > freeDays;

  /// Há fechamento de semana da temporada pendente? (Semana terminou,
  /// metade dos dias feita e a revisão daquela semana ainda não saiu.)
  /// É o topo da hierarquia de revisões do dia: enquanto ele existe,
  /// as ofertas das outras revisões ficam quietas.
  static bool weekReviewPending({
    required SeasonWalkCampaign campaign,
    required DateTime today,
    required bool Function(SeasonWalkDay day) isDayDone,
    required bool Function(int weekIndex) isReviewDone,
  }) {
    final t = DateTime(today.year, today.month, today.day);
    for (var w = 0; w < campaign.weekCount; w++) {
      final days = campaign.week(w);
      if (days.isEmpty || isReviewDone(w)) continue;
      final lastDay = days.last.dateOn(campaign.start);
      if (lastDay.isAfter(t)) continue;
      // Fechamento tem semana de validade: esquecido, ele expira e as
      // outras revisões voltam a ser oferecidas.
      if (t.difference(lastDay).inDays > 6) continue;
      final done = days.where(isDayDone).length;
      if (done >= (days.length / 2).ceil()) return true;
    }
    return false;
  }

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
