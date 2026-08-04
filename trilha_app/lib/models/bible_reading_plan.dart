/// Plano de leitura bíblica persistido (canônico ou cronológico).
enum BibleReadingOrder {
  canonical,
  chronological;

  String get storageKey => name;

  String get label => switch (this) {
        BibleReadingOrder.canonical => 'Ordem da Bíblia',
        BibleReadingOrder.chronological => 'Ordem cronológica',
      };

  String get shortLabel => switch (this) {
        BibleReadingOrder.canonical => 'Canônica',
        BibleReadingOrder.chronological => 'Cronológica',
      };

  static BibleReadingOrder fromStorage(String? raw) {
    if (raw == 'chronological') return BibleReadingOrder.chronological;
    return BibleReadingOrder.canonical;
  }
}

class BibleReadingPlan {
  final bool active;
  final BibleReadingOrder order;
  final int minutesPerDay;

  /// Próximo capítulo na sequência flattenada do plano.
  final int cursor;

  /// Dia (yyyy-mm-dd) em que a porção diária foi concluída.
  final String? lastCompletedDay;

  final int completedDays;
  final String startedAt;

  const BibleReadingPlan({
    required this.active,
    required this.order,
    required this.minutesPerDay,
    required this.cursor,
    required this.lastCompletedDay,
    required this.completedDays,
    required this.startedAt,
  });

  static const inactive = BibleReadingPlan(
    active: false,
    order: BibleReadingOrder.canonical,
    minutesPerDay: 15,
    cursor: 0,
    lastCompletedDay: null,
    completedDays: 0,
    startedAt: '',
  );

  bool get doneToday {
    if (!active) return false;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return lastCompletedDay == today;
  }

  BibleReadingPlan copyWith({
    bool? active,
    BibleReadingOrder? order,
    int? minutesPerDay,
    int? cursor,
    String? lastCompletedDay,
    bool clearLastCompletedDay = false,
    int? completedDays,
    String? startedAt,
  }) {
    return BibleReadingPlan(
      active: active ?? this.active,
      order: order ?? this.order,
      minutesPerDay: minutesPerDay ?? this.minutesPerDay,
      cursor: cursor ?? this.cursor,
      lastCompletedDay: clearLastCompletedDay
          ? null
          : (lastCompletedDay ?? this.lastCompletedDay),
      completedDays: completedDays ?? this.completedDays,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'active': active,
        'order': order.storageKey,
        'minutesPerDay': minutesPerDay,
        'cursor': cursor,
        'lastCompletedDay': lastCompletedDay,
        'completedDays': completedDays,
        'startedAt': startedAt,
      };

  static BibleReadingPlan fromMap(dynamic raw) {
    if (raw is! Map) return inactive;
    return BibleReadingPlan(
      active: raw['active'] == true,
      order: BibleReadingOrder.fromStorage(raw['order']?.toString()),
      minutesPerDay: (raw['minutesPerDay'] as num?)?.toInt().clamp(5, 120) ?? 15,
      cursor: (raw['cursor'] as num?)?.toInt().clamp(0, 100000) ?? 0,
      lastCompletedDay: raw['lastCompletedDay']?.toString(),
      completedDays: (raw['completedDays'] as num?)?.toInt().clamp(0, 100000) ?? 0,
      startedAt: raw['startedAt']?.toString() ?? '',
    );
  }
}

/// Um capítulo na sequência do plano.
class PlanChapterRef {
  final int bookIndex;
  final String bookName;
  final String abbrev;
  final int chapter;
  final int verseCount;
  final int charCount;

  const PlanChapterRef({
    required this.bookIndex,
    required this.bookName,
    required this.abbrev,
    required this.chapter,
    required this.verseCount,
    required this.charCount,
  });

  String get label => '$bookName $chapter';

  /// Minutos estimados (leitura contemplativa ~900 chars/min).
  double get estimatedMinutes {
    final byChars = charCount / 900.0;
    final byVerses = verseCount * 0.12; // ~7s/verso
    final m = (byChars + byVerses) / 2;
    if (m < 0.4) return 0.4;
    return m;
  }
}

/// Porção de um dia no plano.
class DailyReadingPortion {
  final List<PlanChapterRef> chapters;
  final double estimatedMinutes;
  final int fromCursor;
  final int toCursor;
  final bool finished;

  /// Capítulos já lidos pulados antes desta porção (desde o cursor salvo).
  final int skippedAlreadyRead;

  const DailyReadingPortion({
    required this.chapters,
    required this.estimatedMinutes,
    required this.fromCursor,
    required this.toCursor,
    required this.finished,
    this.skippedAlreadyRead = 0,
  });

  String get summary {
    if (chapters.isEmpty) return 'Plano concluído';
    if (chapters.length == 1) return chapters.first.label;
    return '${chapters.first.label} → ${chapters.last.label}';
  }
}
