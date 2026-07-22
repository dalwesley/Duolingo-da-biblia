import '../models/daily_quest.dart';

/// Estação do calendário cristão ocidental (aproximação gregoriana).
enum LiturgicalSeason {
  advent,
  christmas,
  lent,
  holyWeek,
  easter,
  pentecost,
  ordinary,
}

class LiturgicalMoment {
  final LiturgicalSeason season;
  final String title;
  final String subtitle;
  final String focusRef;
  final String accentHex;

  const LiturgicalMoment({
    required this.season,
    required this.title,
    required this.subtitle,
    required this.focusRef,
    required this.accentHex,
  });
}

/// Sincroniza o app com datas litúrgicas — diferencial vs. Ascend/Manna.
class LiturgicalCalendar {
  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Páscoa ocidental (algoritmo de Meeus/Jones/Butcher).
  static DateTime easterSunday(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }

  static DateTime _adventStart(int year) {
    // Quarto domingo antes do Natal.
    var christmas = DateTime(year, 12, 25);
    var sundays = 0;
    var d = christmas.subtract(const Duration(days: 1));
    while (sundays < 4) {
      if (d.weekday == DateTime.sunday) sundays++;
      if (sundays == 4) return d;
      d = d.subtract(const Duration(days: 1));
    }
    return DateTime(year, 11, 30);
  }

  static LiturgicalMoment momentFor([DateTime? date]) {
    final day = date ?? _today;
    final year = day.year;
    final easter = easterSunday(year);
    final ashWednesday = easter.subtract(const Duration(days: 46));
    final palmSunday = easter.subtract(const Duration(days: 7));
    final pentecost = easter.add(const Duration(days: 49));
    final advent = _adventStart(year);
    final epiphany = DateTime(year, 1, 6);
    final christmasStart = DateTime(year, 12, 25);

    if (!day.isBefore(advent) && day.isBefore(christmasStart)) {
      return const LiturgicalMoment(
        season: LiturgicalSeason.advent,
        title: 'Advento',
        subtitle: 'Tempo de espera e preparação',
        focusRef: 'Isaías 9:6',
        accentHex: '#5B7C99',
      );
    }
    if ((!day.isBefore(christmasStart) && day.year == year) ||
        (!day.isBefore(DateTime(year, 1, 1)) && !day.isAfter(epiphany))) {
      return const LiturgicalMoment(
        season: LiturgicalSeason.christmas,
        title: 'Natal',
        subtitle: 'O Verbo se fez carne',
        focusRef: 'João 1:14',
        accentHex: '#D4A84B',
      );
    }
    if (!day.isBefore(ashWednesday) && day.isBefore(palmSunday)) {
      return const LiturgicalMoment(
        season: LiturgicalSeason.lent,
        title: 'Quaresma',
        subtitle: 'Deserto, jejum e retorno',
        focusRef: 'Joel 2:12',
        accentHex: '#8B5E3C',
      );
    }
    if (!day.isBefore(palmSunday) && day.isBefore(easter)) {
      return const LiturgicalMoment(
        season: LiturgicalSeason.holyWeek,
        title: 'Semana Santa',
        subtitle: 'Da cruz à espera da ressurreição',
        focusRef: 'Isaías 53:5',
        accentHex: '#A63D40',
      );
    }
    if (!day.isBefore(easter) && day.isBefore(pentecost)) {
      return const LiturgicalMoment(
        season: LiturgicalSeason.easter,
        title: 'Páscoa',
        subtitle: 'Cristo ressuscitou',
        focusRef: '1 Coríntios 15:20',
        accentHex: '#E8B84B',
      );
    }
    if (day.year == pentecost.year &&
        day.month == pentecost.month &&
        day.day == pentecost.day) {
      return const LiturgicalMoment(
        season: LiturgicalSeason.pentecost,
        title: 'Pentecostes',
        subtitle: 'O Espírito é derramado',
        focusRef: 'Atos 2:1–4',
        accentHex: '#C45C26',
      );
    }

    return const LiturgicalMoment(
      season: LiturgicalSeason.ordinary,
      title: 'Tempo comum',
      subtitle: 'Crescimento na Palavra, dia a dia',
      focusRef: 'Salmos 119:105',
      accentHex: '#1B3A5C',
    );
  }

  /// Missão extra nos tempos fortes (não no tempo comum).
  static DailyQuest? seasonalQuestToday([DateTime? date]) {
    final m = momentFor(date);
    if (m.season == LiturgicalSeason.ordinary) return null;
    return DailyQuest(
      id: 'seasonal',
      title: 'Tempo de ${m.title}',
      subtitle: 'Leia um capítulo — foco: ${m.focusRef}',
      target: 1,
      stepsReward: 35,
      icon: '✝️',
    );
  }

  static bool get isHighSeason =>
      momentFor().season != LiturgicalSeason.ordinary;
}
