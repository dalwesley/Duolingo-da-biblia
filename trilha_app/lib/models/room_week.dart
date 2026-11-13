import 'study_room.dart';

/// Como cada pessoa foi na semana do grupo (só o líder vê a lista).
class RoomWeekEntry {
  final RoomMember member;
  final bool studied;
  final int readingDone;
  final int days;

  /// 0..1: quanto do que o líder marcou a pessoa fez.
  final double completion;

  const RoomWeekEntry({
    required this.member,
    required this.studied,
    required this.readingDone,
    required this.days,
    required this.completion,
  });

  /// Ordem do líder: quem fez tudo primeiro, depois quem esteve mais dias.
  int get score => (completion * 100).round() * 10 + days;
}

/// Semana do grupo: participação de cada um e o fechamento (revelação).
class RoomWeek {
  final List<RoomWeekEntry> entries;
  final RoomStudy? study;
  final RoomReading? reading;

  /// Segunda-feira da semana (para o crescimento gravado nela).
  final String? week;

  const RoomWeek._(this.entries, this.study, this.reading, this.week);

  /// Pontos mínimos acima das semanas anteriores para "quem mais cresceu".
  static const minGrowthPts = 5;

  /// Sem estudo nem leitura marcados, "fiel" é estudar 3 dias na semana.
  static const daysWhenNothingAssigned = 3;

  factory RoomWeek.of({
    required List<RoomMember> members,
    RoomStudy? study,
    RoomReading? reading,
    String? week,
  }) {
    final list = [
      for (final m in members) _entry(m, study: study, reading: reading),
    ]..sort((a, b) => b.score.compareTo(a.score));
    return RoomWeek._(list, study, reading, week);
  }

  static RoomWeekEntry _entry(
    RoomMember m, {
    RoomStudy? study,
    RoomReading? reading,
  }) {
    final studied = m.didStudy(study);
    final read = m.readingDoneFor(reading);
    final days = m.daysThisWeek;
    final parts = <double>[
      if (study != null) studied ? 1 : 0,
      if (reading != null) read / reading.chapters,
    ];
    final completion = parts.isEmpty
        ? (days / daysWhenNothingAssigned).clamp(0.0, 1.0)
        : parts.reduce((a, b) => a + b) / parts.length;
    return RoomWeekEntry(
      member: m,
      studied: studied,
      readingDone: read,
      days: days,
      completion: completion,
    );
  }

  /// Média de quanto o grupo fez, em %.
  int get groupPct => entries.isEmpty
      ? 0
      : (entries.map((e) => e.completion).reduce((a, b) => a + b) /
                entries.length *
                100)
            .round();

  /// Fez tudo o que o líder marcou: ganha o selo.
  List<RoomWeekEntry> get faithful => [
    for (final e in entries)
      if (e.completion >= 1) e,
  ];

  /// Mais dias na semana (pelo menos 2). Empate: todos.
  List<RoomWeekEntry> get mostConstant {
    if (entries.isEmpty) return const [];
    final top = entries.map((e) => e.days).reduce((a, b) => a > b ? a : b);
    if (top < 2) return const [];
    return [
      for (final e in entries)
        if (e.days == top) e,
    ];
  }

  /// Quem mais subiu o acerto em relação às próprias semanas anteriores
  /// (pelo menos [minGrowthPts]). Empate: todos.
  List<RoomWeekEntry> get mostGrown {
    final w = week;
    if (w == null) return const [];
    int? top;
    for (final e in entries) {
      final g = e.member.growthFor(w);
      if (g != null && g >= minGrowthPts && (top == null || g > top)) top = g;
    }
    if (top == null) return const [];
    return [
      for (final e in entries)
        if (e.member.growthFor(w) == top) e,
    ];
  }

  RoomClosing close({required String week}) => RoomClosing(
    week: week,
    groupPct: groupPct,
    members: entries.length,
    faithful: [for (final e in faithful) e.member.uid],
    constant: [for (final e in mostConstant) e.member.uid],
    grown: [for (final e in mostGrown) e.member.uid],
    names: {for (final e in entries) e.member.uid: e.member.name},
    studyTitle: study?.title,
    readingLabel: reading?.label,
  );
}

/// Fechamento da semana que o líder revela na reunião. Doc em
/// `rooms/{code}/closings/{semana}`.
class RoomClosing {
  final String week;
  final int groupPct;
  final int members;
  final List<String> faithful;
  final List<String> constant;
  final List<String> grown;
  final Map<String, String> names;
  final String? studyTitle;
  final String? readingLabel;

  /// Fechamento de um propósito (não de uma semana): título e nº de dias.
  /// Aí [week] é a data de fim do propósito.
  final String? planTitle;
  final int? planDays;

  bool get isPlan => planTitle != null;

  const RoomClosing({
    required this.week,
    required this.groupPct,
    required this.members,
    required this.faithful,
    required this.constant,
    this.grown = const [],
    required this.names,
    this.studyTitle,
    this.readingLabel,
    this.planTitle,
    this.planDays,
  });

  String nameOf(String uid) => names[uid] ?? '';

  Map<String, dynamic> toMap() => {
    'week': week,
    'groupPct': groupPct,
    'members': members,
    'faithful': faithful,
    'constant': constant,
    'grown': grown,
    'names': names,
    if (studyTitle != null) 'studyTitle': studyTitle,
    if (readingLabel != null) 'readingLabel': readingLabel,
    if (planTitle != null) 'planTitle': planTitle,
    if (planDays != null) 'planDays': planDays,
  };

  static RoomClosing? fromMap(Map<String, dynamic>? raw) {
    if (raw == null) return null;
    final week = (raw['week'] as String?)?.trim() ?? '';
    if (week.isEmpty) return null;
    List<String> ids(Object? v) => [
      if (v is List)
        for (final x in v)
          if (x is String && x.isNotEmpty) x,
    ];
    final names = raw['names'];
    return RoomClosing(
      week: week,
      groupPct: ((raw['groupPct'] as num?)?.toInt() ?? 0).clamp(0, 100),
      members: (raw['members'] as num?)?.toInt() ?? 0,
      faithful: ids(raw['faithful']),
      constant: ids(raw['constant']),
      grown: ids(raw['grown']),
      names: {
        if (names is Map)
          for (final e in names.entries)
            if (e.key is String && e.value is String)
              e.key as String: e.value as String,
      },
      studyTitle: (raw['studyTitle'] as String?)?.trim(),
      readingLabel: (raw['readingLabel'] as String?)?.trim(),
      planTitle: (raw['planTitle'] as String?)?.trim(),
      planDays: (raw['planDays'] as num?)?.toInt(),
    );
  }
}
