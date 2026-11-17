import 'room_week.dart';
import 'study_room.dart';

/// Propósito do grupo: o líder escolhe início, fim e dias de descanso; cada
/// dia tem até três coisas (capítulo, cena, pergunta). Não segue a semana
/// de segunda a domingo — o dia é a data local de cada pessoa.

/// "2026-11-14" da data local.
String planYmd(DateTime d) =>
    DateTime(d.year, d.month, d.day).toIso8601String().substring(0, 10);

DateTime? parsePlanYmd(String? raw) {
  if (raw == null || raw.length < 10) return null;
  final d = DateTime.tryParse(raw.substring(0, 10));
  return d == null ? null : DateTime(d.year, d.month, d.day);
}

/// Capítulos do dia: [from]..[to] de um livro (abreviação do leitor).
class PlanReading {
  final String bookAbbrev;
  final String bookName;
  final int from;
  final int to;

  const PlanReading({
    required this.bookAbbrev,
    required this.bookName,
    required this.from,
    required this.to,
  });

  int get chapters => to - from + 1;
  String get label => from == to ? '$bookName $from' : '$bookName $from–$to';
  String get openRef => '$bookName $from';

  Map<String, dynamic> toMap() => {
    'b': bookAbbrev,
    'n': bookName,
    'f': from,
    't': to,
  };

  static PlanReading? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final abbrev = (raw['b'] as String?)?.trim() ?? '';
    final name = (raw['n'] as String?)?.trim() ?? '';
    final from = (raw['f'] as num?)?.toInt() ?? 0;
    final to = (raw['t'] as num?)?.toInt() ?? 0;
    if (abbrev.isEmpty || name.isEmpty || from < 1 || to < from) return null;
    return PlanReading(bookAbbrev: abbrev, bookName: name, from: from, to: to);
  }
}

/// Cena do catálogo marcada para o dia.
class PlanScene {
  final String slug;
  final String title;
  final String? ref;

  const PlanScene({required this.slug, required this.title, this.ref});

  Map<String, dynamic> toMap() => {
    's': slug,
    'ti': title,
    if (ref != null && ref!.isNotEmpty) 'r': ref,
  };

  static PlanScene? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final slug = (raw['s'] as String?)?.trim() ?? '';
    if (slug.isEmpty) return null;
    return PlanScene(
      slug: slug,
      title: (raw['ti'] as String?)?.trim() ?? slug,
      ref: (raw['r'] as String?)?.trim(),
    );
  }
}

/// Um dia do propósito. [n] começa em 1; [date] é a data do dia.
class PlanDay {
  final int n;
  final String date;
  final PlanReading? reading;
  final PlanScene? scene;
  final String? question;
  final String? note;

  /// A pergunta foi escrita ou escolhida pelo líder (não é refeita quando
  /// a cena ou o capítulo mudam).
  final bool customQuestion;

  const PlanDay({
    required this.n,
    required this.date,
    this.reading,
    this.scene,
    this.question,
    this.note,
    this.customQuestion = false,
  });

  bool get hasQuestion => question != null && question!.trim().isNotEmpty;
  bool get hasNote => note != null && note!.trim().isNotEmpty;

  /// Sem capítulo, cena nem pergunta: a pessoa marca o dia à mão.
  bool get isManual => reading == null && scene == null && !hasQuestion;

  PlanDay copyWith({
    String? date,
    int? n,
    String? question,
    bool clearQuestion = false,
    String? note,
    bool clearNote = false,
  }) => PlanDay(
    n: n ?? this.n,
    date: date ?? this.date,
    reading: reading,
    scene: scene,
    question: clearQuestion ? null : (question ?? this.question),
    note: clearNote ? null : (note ?? this.note),
    customQuestion: customQuestion,
  );

  Map<String, dynamic> toMap() => {
    'n': n,
    'd': date,
    if (reading != null) 'rd': reading!.toMap(),
    if (scene != null) 'sc': scene!.toMap(),
    if (hasQuestion) 'q': question!.trim(),
    if (hasNote) 'no': note!.trim(),
    if (customQuestion && hasQuestion) 'qc': true,
  };

  static PlanDay? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final n = (raw['n'] as num?)?.toInt() ?? 0;
    final date = (raw['d'] as String?)?.trim() ?? '';
    if (n < 1 || parsePlanYmd(date) == null) return null;
    return PlanDay(
      n: n,
      date: date,
      reading: PlanReading.fromMap(raw['rd']),
      scene: PlanScene.fromMap(raw['sc']),
      question: (raw['q'] as String?)?.trim(),
      note: (raw['no'] as String?)?.trim(),
      customQuestion: raw['qc'] == true,
    );
  }
}

enum PlanPhase { upcoming, active, ended }

class RoomPlan {
  /// Teto de dias com conteúdo (o doc do grupo carrega o plano inteiro).
  static const maxDays = 60;
  static const maxQuestion = 200;
  static const maxNote = 280;
  static const maxTitle = 60;

  final String id;
  final String title;
  final String start;
  final String end;

  /// Dias da semana sem nada (1 = seg … 7 = dom).
  final Set<int> restDays;
  final List<PlanDay> days;

  /// Como os dias foram montados (para o editor reabrir igual): livro
  /// `rb`, capítulo inicial `rf`, por dia `rp`, 1ª cena `ss`, pergunta `q`.
  final Map<String, dynamic> gen;

  /// Estação que gera os dias (`gen.sw`), ou null. Propósito gravado por
  /// cima de outro com merge (até 1.0.49) pode trazer `sw` e `ss` juntos:
  /// vale o que os dias usam — se a cena da trilha está nos dias, não é
  /// estação.
  String? get seasonId {
    final sw = gen['sw'];
    if (sw is! String || sw.isEmpty) return null;
    final ss = gen['ss'];
    if (ss is String && ss.isNotEmpty && days.any((d) => d.scene?.slug == ss)) {
      return null;
    }
    return sw;
  }

  const RoomPlan({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.days,
    this.restDays = const {},
    this.gen = const {},
  });

  int get total => days.length;

  /// Ids dos propósitos que este substituiu ao trocar a trilha com ele em
  /// andamento (`gen.pv`, o mais recente primeiro).
  List<String> get previousIds => [
    if (gen['pv'] is List)
      for (final v in gen['pv'] as List)
        if (v is String) v,
  ];

  /// Progresso de uma pessoa neste propósito. Recomeçou com outra trilha:
  /// quem tinha entrado no anterior continua dentro (dias e respostas zeram).
  PlanProgress? progressOf(PlanProgress? p) {
    if (p == null) return null;
    if (p.planId == id) return p;
    if (previousIds.contains(p.planId)) {
      return PlanProgress(planId: id, joined: p.joined);
    }
    return null;
  }

  PlanPhase phase([DateTime? now]) {
    final today = planYmd(now ?? DateTime.now());
    if (today.compareTo(start) < 0) return PlanPhase.upcoming;
    if (today.compareTo(end) > 0) return PlanPhase.ended;
    return PlanPhase.active;
  }

  /// Dias até o começo (0 = hoje).
  int daysUntilStart([DateTime? now]) {
    final d = now ?? DateTime.now();
    final s = parsePlanYmd(start)!;
    return s.difference(DateTime(d.year, d.month, d.day)).inDays;
  }

  PlanDay? dayOn(String ymd) {
    for (final d in days) {
      if (d.date == ymd) return d;
    }
    return null;
  }

  PlanDay? dayNumber(int n) {
    for (final d in days) {
      if (d.n == n) return d;
    }
    return null;
  }

  /// O dia de hoje (null em dia de descanso ou fora do período).
  PlanDay? today([DateTime? now]) => dayOn(planYmd(now ?? DateTime.now()));

  /// Dias que já abriram (data até hoje).
  List<PlanDay> openDays([DateTime? now]) {
    final today = planYmd(now ?? DateTime.now());
    return [
      for (final d in days)
        if (d.date.compareTo(today) <= 0) d,
    ];
  }

  /// Próximo dia que ainda vai abrir.
  PlanDay? nextDay([DateTime? now]) {
    final today = planYmd(now ?? DateTime.now());
    for (final d in days) {
      if (d.date.compareTo(today) > 0) return d;
    }
    return null;
  }

  RoomPlan copyWith({String? title, String? end, List<PlanDay>? days}) =>
      RoomPlan(
        id: id,
        title: title ?? this.title,
        start: start,
        end: end ?? this.end,
        days: days ?? this.days,
        restDays: restDays,
        gen: gen,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'start': start,
    'end': end,
    'rest': restDays.toList()..sort(),
    'days': [for (final d in days) d.toMap()],
    if (gen.isNotEmpty) 'gen': gen,
  };

  static RoomPlan? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final id = (raw['id'] as String?)?.trim() ?? '';
    final start = (raw['start'] as String?)?.trim() ?? '';
    final end = (raw['end'] as String?)?.trim() ?? '';
    if (id.isEmpty ||
        parsePlanYmd(start) == null ||
        parsePlanYmd(end) == null) {
      return null;
    }
    final days = [
      if (raw['days'] is List)
        for (final d in raw['days'] as List) ?PlanDay.fromMap(d),
    ]..sort((a, b) => a.n.compareTo(b.n));
    if (days.isEmpty) return null;
    return RoomPlan(
      id: id,
      title: (raw['title'] as String?)?.trim() ?? '',
      start: start,
      end: end,
      restDays: {
        if (raw['rest'] is List)
          for (final r in raw['rest'] as List)
            if (r is num && r >= 1 && r <= 7) r.toInt(),
      },
      days: days,
      gen: raw['gen'] is Map
          ? Map<String, dynamic>.from(raw['gen'] as Map)
          : const {},
    );
  }

  /// Datas com conteúdo entre [start] e [end], pulando [rest] (até [maxDays]).
  static List<String> datesBetween(
    DateTime start,
    DateTime end,
    Set<int> rest,
  ) {
    final out = <String>[];
    var d = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!d.isAfter(last) && out.length < maxDays) {
      if (!rest.contains(d.weekday)) out.add(planYmd(d));
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return out;
  }

  /// Monta os dias: capítulos seguidos de um livro e cenas em ordem. A
  /// pergunta de cada dia sai de [questionFor] (índice do dia, capítulos e
  /// cena dele). [edits] guarda pergunta e recado que o líder trocou à mão,
  /// por número do dia. [sceneOn] troca a fila de cenas pela cena da data
  /// (temporada: cada dia do Advento cai no seu dia). [readingFrom] e [sceneFrom] dizem a partir de que
  /// índice de dia cada fonte começa (trocar a fonte com o propósito em
  /// andamento: a nova vale só do dia seguinte em diante).
  static List<PlanDay> buildDays({
    required List<String> dates,
    ({String abbrev, String name, int from, int perDay, int bookChapters})?
    reading,
    List<PlanScene> scenes = const [],
    String? Function(int index, PlanReading? reading, PlanScene? scene)?
    questionFor,
    Map<int, ({String? question, String? note})> edits = const {},
    int readingFrom = 0,
    int sceneFrom = 0,
    PlanScene? Function(String date)? sceneOn,
  }) {
    final out = <PlanDay>[];
    var chapter = reading?.from ?? 0;
    for (var i = 0; i < dates.length; i++) {
      final n = i + 1;
      PlanReading? r;
      if (reading != null &&
          i >= readingFrom &&
          chapter <= reading.bookChapters) {
        final to = (chapter + reading.perDay - 1).clamp(
          chapter,
          reading.bookChapters,
        );
        r = PlanReading(
          bookAbbrev: reading.abbrev,
          bookName: reading.name,
          from: chapter,
          to: to,
        );
        chapter = to + 1;
      }
      final edit = edits[n];
      final si = i - sceneFrom;
      // Temporada (Advento): a cena é a do dia do calendário, não a da fila.
      final scene = sceneOn != null
          ? sceneOn(dates[i])
          : si >= 0 && si < scenes.length
          ? scenes[si]
          : null;
      out.add(
        PlanDay(
          n: n,
          date: dates[i],
          reading: r,
          scene: scene,
          question: edit?.question ?? questionFor?.call(i, r, scene),
          note: edit?.note,
          customQuestion: edit?.question != null,
        ),
      );
    }
    return out;
  }
}

/// O que cada pessoa fez no propósito (guardado no próprio membro, campo
/// `plan`). [done]: número do dia → data em que concluiu.
class PlanProgress {
  final String planId;
  final Map<int, String> done;
  final Set<int> answered;
  final bool joined;

  const PlanProgress({
    required this.planId,
    this.done = const {},
    this.answered = const {},
    this.joined = false,
  });

  bool doneOnTime(PlanDay day) {
    final at = done[day.n];
    return at != null && at.compareTo(day.date) <= 0;
  }

  PlanProgress copyWith({
    Map<int, String>? done,
    Set<int>? answered,
    bool? joined,
  }) => PlanProgress(
    planId: planId,
    done: done ?? this.done,
    answered: answered ?? this.answered,
    joined: joined ?? this.joined,
  );

  Map<String, dynamic> toMap() => {
    'id': planId,
    'done': {for (final e in done.entries) '${e.key}': e.value},
    'ans': answered.toList()..sort(),
    'in': joined,
  };

  static PlanProgress? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final id = (raw['id'] as String?)?.trim() ?? '';
    if (id.isEmpty) return null;
    final done = <int, String>{};
    final rawDone = raw['done'];
    if (rawDone is Map) {
      for (final e in rawDone.entries) {
        final n = int.tryParse('${e.key}');
        if (n != null && e.value is String) done[n] = e.value as String;
      }
    }
    return PlanProgress(
      planId: id,
      done: done,
      answered: {
        if (raw['ans'] is List)
          for (final a in raw['ans'] as List)
            if (a is num) a.toInt(),
      },
      joined: raw['in'] == true,
    );
  }
}

/// Resposta de alguém à pergunta do dia. Doc em
/// `rooms/{code}/answers/{planId}_{dia}/by/{uid}`.
class PlanAnswer {
  final String uid;
  final String name;
  final String text;
  final String? photoUrl;
  final DateTime? at;

  const PlanAnswer({
    required this.uid,
    required this.name,
    required this.text,
    this.photoUrl,
    this.at,
  });

  static String dayKey(String planId, int n) => '${planId}_$n';
}

/// Como uma pessoa foi no propósito (lista do líder e fechamento).
class PlanEntry {
  final RoomMember member;
  final int done;
  final int onTime;
  final bool doneToday;
  final bool joined;
  final double completion;

  const PlanEntry({
    required this.member,
    required this.done,
    required this.onTime,
    required this.doneToday,
    required this.joined,
    required this.completion,
  });
}

/// Contas do grupo no propósito: quem fez hoje, a corrente e o fechamento.
class PlanGroup {
  final RoomPlan plan;
  final List<RoomMember> members;
  final DateTime now;

  PlanGroup(this.plan, this.members, [DateTime? now])
    : now = now ?? DateTime.now();

  PlanProgress? _of(RoomMember m) {
    return plan.progressOf(m.plan);
  }

  int joinedCount() => members.where((m) => _of(m)?.joined ?? false).length;

  /// Quem já concluiu [day].
  List<RoomMember> doneOn(PlanDay day) => [
    for (final m in members)
      if (_of(m)?.done.containsKey(day.n) ?? false) m,
  ];

  /// Dia "segurado" pela corrente: pelo menos metade do grupo no dia certo.
  bool kept(PlanDay day) {
    if (members.isEmpty) return false;
    final onTime = members.where((m) => _of(m)?.doneOnTime(day) ?? false);
    return onTime.length * 2 >= members.length;
  }

  /// Dias seguidos em que metade do grupo cumpriu. Hoje só conta se já
  /// segurou; ainda não segurar hoje não quebra.
  int chain() {
    final open = plan.openDays(now);
    final today = planYmd(now);
    var count = 0;
    for (final d in open.reversed) {
      if (kept(d)) {
        count++;
      } else if (d.date == today) {
        continue;
      } else {
        break;
      }
    }
    return count;
  }

  List<PlanEntry> entries() {
    final today = plan.today(now);
    final list = [
      for (final m in members)
        () {
          final p = _of(m);
          final done = p == null
              ? 0
              : plan.days.where((d) => p.done.containsKey(d.n)).length;
          final onTime = p == null
              ? 0
              : plan.days.where((d) => p.doneOnTime(d)).length;
          return PlanEntry(
            member: m,
            done: done,
            onTime: onTime,
            doneToday: today != null && (p?.done.containsKey(today.n) ?? false),
            joined: p?.joined ?? false,
            completion: plan.total == 0 ? 0 : done / plan.total,
          );
        }(),
    ];
    list.sort((a, b) {
      final c = b.done.compareTo(a.done);
      return c != 0 ? c : b.onTime.compareTo(a.onTime);
    });
    return list;
  }

  /// Fechamento do propósito (revelação). Id = data de fim.
  RoomClosing close() {
    final list = entries();
    final pct = list.isEmpty
        ? 0
        : (list.map((e) => e.completion).reduce((a, b) => a + b) /
                  list.length *
                  100)
              .round();
    final topOnTime = list.isEmpty
        ? 0
        : list.map((e) => e.onTime).reduce((a, b) => a > b ? a : b);
    return RoomClosing(
      week: plan.end,
      groupPct: pct.clamp(0, 100),
      members: list.length,
      faithful: [
        for (final e in list)
          if (plan.total > 0 && e.done >= plan.total) e.member.uid,
      ],
      constant: [
        if (topOnTime >= 2)
          for (final e in list)
            if (e.onTime == topOnTime) e.member.uid,
      ],
      names: {for (final e in list) e.member.uid: e.member.name},
      planTitle: plan.title,
      planDays: plan.total,
    );
  }
}
