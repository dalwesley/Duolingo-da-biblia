import '../l10n/l10n_global.dart';

/// Plano de leitura: canônico ou cronológico.
/// Navegação da aba Bíblia também oferece alfabética.
enum BibleReadingOrder {
  canonical,
  chronological,
  alphabetical;

  String get storageKey => name;

  String get label => switch (this) {
    BibleReadingOrder.canonical => L10n.current.planOrderCanonical,
    BibleReadingOrder.chronological => L10n.current.planOrderChronological,
    BibleReadingOrder.alphabetical => L10n.current.planOrderAlphabetical,
  };

  String get shortLabel => switch (this) {
    BibleReadingOrder.canonical => L10n.current.planOrderCanonicalShort,
    BibleReadingOrder.chronological => L10n.current.planOrderChronologicalShort,
    BibleReadingOrder.alphabetical => L10n.current.planOrderAlphabeticalShort,
  };

  /// Plano de leitura — A–Z não é um percurso de estudo.
  static const planOrders = [
    BibleReadingOrder.canonical,
    BibleReadingOrder.chronological,
  ];

  static BibleReadingOrder fromStorage(String? raw) {
    if (raw == 'chronological') return BibleReadingOrder.chronological;
    if (raw == 'alphabetical') return BibleReadingOrder.alphabetical;
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

  /// Plano guiado ([GuidedReadingPlan.id]); null = Bíblia inteira no ritmo.
  /// No guiado, [cursor] é o índice do próximo dia.
  final String? guidedId;

  /// Hora do lembrete diário (0–23); null = sem lembrete.
  final int? reminderHour;

  bool get isGuided => guidedId != null;

  const BibleReadingPlan({
    required this.active,
    required this.order,
    required this.minutesPerDay,
    required this.cursor,
    required this.lastCompletedDay,
    required this.completedDays,
    required this.startedAt,
    this.guidedId,
    this.reminderHour,
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

  /// Dias iniciais de todo plano guiado, para qualquer pessoa: dá para
  /// começar e provar antes de o Peregrino+ entrar (como a Caminhada).
  static const guidedFreeDays = 3;

  /// Hoje a leitura está travada: plano guiado, amostra usada e sem
  /// Peregrino+ (por exemplo, a assinatura acabou no meio). Quem ainda
  /// está nos [guidedFreeDays] — ou já leu hoje — não trava.
  /// A Bíblia inteira nunca trava.
  bool lockedToday({required bool plusOpen}) =>
      active &&
      isGuided &&
      !plusOpen &&
      !doneToday &&
      completedDays >= guidedFreeDays;

  BibleReadingPlan copyWith({
    bool? active,
    BibleReadingOrder? order,
    int? minutesPerDay,
    int? cursor,
    String? lastCompletedDay,
    bool clearLastCompletedDay = false,
    int? completedDays,
    String? startedAt,
    int? reminderHour,
    bool clearReminder = false,
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
      guidedId: guidedId,
      reminderHour: clearReminder ? null : (reminderHour ?? this.reminderHour),
    );
  }

  /// Versão do formato salvo. Plano de versão anterior é lido como inativo:
  /// quando os guiados viraram Peregrino+ (com 3 dias grátis no começo),
  /// todos os planos existentes foram zerados, no aparelho e na nuvem.
  static const schema = 2;

  Map<String, dynamic> toMap() => {
    'v': schema,
    'active': active,
    'order': order.storageKey,
    'minutesPerDay': minutesPerDay,
    'cursor': cursor,
    'lastCompletedDay': lastCompletedDay,
    'completedDays': completedDays,
    'startedAt': startedAt,
    'guidedId': guidedId,
    'reminderHour': reminderHour,
  };

  static BibleReadingPlan fromMap(dynamic raw) {
    if (raw is! Map) return inactive;
    if ((raw['v'] as num?)?.toInt() != schema) return inactive;
    return BibleReadingPlan(
      active: raw['active'] == true,
      order: BibleReadingOrder.fromStorage(raw['order']?.toString()),
      minutesPerDay:
          (raw['minutesPerDay'] as num?)?.toInt().clamp(5, 120) ?? 15,
      cursor: (raw['cursor'] as num?)?.toInt().clamp(0, 100000) ?? 0,
      lastCompletedDay: raw['lastCompletedDay']?.toString(),
      completedDays:
          (raw['completedDays'] as num?)?.toInt().clamp(0, 100000) ?? 0,
      startedAt: raw['startedAt']?.toString() ?? '',
      guidedId: raw['guidedId']?.toString(),
      reminderHour: (raw['reminderHour'] as num?)?.toInt().clamp(0, 23),
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
    if (chapters.isEmpty) return L10n.current.planFinished;
    if (chapters.length == 1) return chapters.first.label;
    return '${chapters.first.label} → ${chapters.last.label}';
  }
}
