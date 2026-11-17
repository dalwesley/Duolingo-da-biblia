import '../l10n/l10n_global.dart';
import '../widgets/cinematic_icon.dart';
import 'portrait_style.dart';
import 'room_plan.dart';

/// Teto de pessoas por grupo (plano grátis). A function
/// `onRoomMemberCreate` também corta quem passar disso.
const int kRoomMemberLimit = 20;

/// Mínimo de pessoas para o grupo existir de verdade. Abaixo disso o grupo
/// está "se formando": só pessoas, convite e saída (sem propósito, semana,
/// fechamento nem prêmio). Dupla é Companhia. O servidor usa o mesmo número
/// (functions/advent.js `GROUP_MIN_MEMBERS`).
const int kRoomMinMembers = 3;

/// O grupo já existe de verdade?
bool roomIsFormed(int members) => members >= kRoomMinMembers;

/// Para que o grupo existe — muda rótulo, ícone e textos.
enum RoomKind {
  celula('celula', CinematicGlyph.home),
  discipulado('discipulado', CinematicGlyph.path),
  ebd('ebd', CinematicGlyph.book),
  familia('familia', CinematicGlyph.heart),
  amigos('amigos', CinematicGlyph.people);

  final String storageKey;
  final CinematicGlyph glyph;

  const RoomKind(this.storageKey, this.glyph);

  String get label => switch (this) {
    RoomKind.celula => L10n.current.roomKindCelula,
    RoomKind.discipulado => L10n.current.roomKindDiscipulado,
    RoomKind.ebd => L10n.current.roomKindEbd,
    RoomKind.familia => L10n.current.roomKindFamilia,
    RoomKind.amigos => L10n.current.roomKindAmigos,
  };

  /// Quem conduz o grupo, no vocabulário de cada tipo.
  String get leaderTitle => switch (this) {
    RoomKind.celula => L10n.current.roomLeaderCelula,
    RoomKind.discipulado => L10n.current.roomLeaderDiscipulado,
    RoomKind.ebd => L10n.current.roomLeaderEbd,
    RoomKind.familia => L10n.current.roomLeaderFamilia,
    RoomKind.amigos => L10n.current.roomLeaderAmigos,
  };

  String get namePlaceholder => switch (this) {
    RoomKind.celula => L10n.current.roomNameHintCelula,
    RoomKind.discipulado => L10n.current.roomNameHintDiscipulado,
    RoomKind.ebd => L10n.current.roomNameHintEbd,
    RoomKind.familia => L10n.current.roomNameHintFamilia,
    RoomKind.amigos => L10n.current.roomNameHintAmigos,
  };

  static RoomKind fromKey(String? raw) {
    for (final k in RoomKind.values) {
      if (k.storageKey == raw) return k;
    }
    return RoomKind.celula;
  }
}

/// Missão do catálogo que o líder marcou para o grupo nesta semana.
class RoomStudy {
  final String missionSlug;
  final String title;
  final String? verseRef;

  /// Trecho do palco da missão (TB), para o card mostrar a Palavra.
  final String? verse;
  final String? note;

  /// Segunda-feira (YYYY-MM-DD) da semana do estudo.
  final String week;

  const RoomStudy({
    required this.missionSlug,
    required this.title,
    required this.week,
    this.verseRef,
    this.verse,
    this.note,
  });

  bool isForWeek(String weekKey) => week == weekKey;

  /// O seletor do propósito devolve a temporada inteira (Advento) como um
  /// estudo com `week` = `season:<id da campanha>`. Nunca é gravado assim.
  static const seasonPrefix = 'season:';

  String? get seasonId => week.startsWith(seasonPrefix)
      ? week.substring(seasonPrefix.length)
      : null;

  Map<String, dynamic> toMap() => {
    'missionSlug': missionSlug,
    'title': title,
    'week': week,
    if (verseRef != null && verseRef!.isNotEmpty) 'verseRef': verseRef,
    if (verse != null && verse!.isNotEmpty) 'verse': verse,
    if (note != null && note!.isNotEmpty) 'note': note,
  };

  static RoomStudy? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final slug = (raw['missionSlug'] as String?)?.trim() ?? '';
    final week = (raw['week'] as String?)?.trim() ?? '';
    if (slug.isEmpty || week.isEmpty) return null;
    final title = (raw['title'] as String?)?.trim();
    return RoomStudy(
      missionSlug: slug,
      title: title == null || title.isEmpty
          ? L10n.current.roomStudyFallbackTitle
          : title,
      week: week,
      verseRef: (raw['verseRef'] as String?)?.trim(),
      verse: (raw['verse'] as String?)?.trim(),
      note: (raw['note'] as String?)?.trim(),
    );
  }
}

/// Leitura da Bíblia que o líder marcou para a semana: capítulos
/// [from]..[to] de um livro (abreviação do leitor, ex. "Jo").
class RoomReading {
  final String bookAbbrev;
  final String bookName;
  final int from;
  final int to;

  /// Segunda-feira (YYYY-MM-DD) da semana da leitura.
  final String week;

  const RoomReading({
    required this.bookAbbrev,
    required this.bookName,
    required this.from,
    required this.to,
    required this.week,
  });

  static const maxChapters = 10;

  int get chapters => to - from + 1;

  /// "João 1–3" ou "João 1".
  String get label => from == to ? '$bookName $from' : '$bookName $from–$to';

  /// Referência que o leitor abre (1º capítulo).
  String get openRef => '$bookName $from';

  bool isForWeek(String weekKey) => week == weekKey;

  Map<String, dynamic> toMap() => {
    'bookAbbrev': bookAbbrev,
    'bookName': bookName,
    'from': from,
    'to': to,
    'week': week,
  };

  static RoomReading? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final abbrev = (raw['bookAbbrev'] as String?)?.trim() ?? '';
    final name = (raw['bookName'] as String?)?.trim() ?? '';
    final week = (raw['week'] as String?)?.trim() ?? '';
    final from = (raw['from'] as num?)?.toInt() ?? 0;
    final to = (raw['to'] as num?)?.toInt() ?? 0;
    if (abbrev.isEmpty || name.isEmpty || week.isEmpty) return null;
    if (from < 1 || to < from || to - from >= maxChapters) return null;
    return RoomReading(
      bookAbbrev: abbrev,
      bookName: name,
      from: from,
      to: to,
      week: week,
    );
  }
}

/// Sala privada de caminhada — grupo fechado por código de convite.
class StudyRoom {
  final String code;
  final String name;
  final String ownerId;
  final String ownerName;
  final DateTime? createdAt;
  final RoomKind kind;

  /// Meta semanal de passos somados da sala (definida pelo dono, opcional).
  final int? weeklyGoalSteps;

  /// Estudo marcado pelo líder. Vale só na semana gravada em [RoomStudy.week].
  final RoomStudy? study;

  /// Leitura da Bíblia marcada pelo líder para a semana.
  final RoomReading? reading;

  /// Grupo do piloto de líderes: abre mesmo com `groups_enabled` desligado.
  final bool pilot;

  /// Propósito do grupo (início e fim escolhidos pelo líder). Enquanto
  /// existe, toma o lugar do estudo e da leitura da semana.
  final RoomPlan? plan;

  /// Líder fechou as respostas do propósito: cada membro vê só a própria
  /// (o líder vê todas). Aberto (padrão): vê as dos outros depois de
  /// responder. As rules garantem as duas coisas.
  final bool answersPrivate;

  const StudyRoom({
    required this.code,
    required this.name,
    required this.ownerId,
    required this.ownerName,
    this.createdAt,
    this.kind = RoomKind.celula,
    this.weeklyGoalSteps,
    this.study,
    this.reading,
    this.pilot = false,
    this.plan,
    this.answersPrivate = false,
  });

  bool isOwner(String? uid) => uid != null && uid == ownerId;

  RoomStudy? studyFor(String weekKey) =>
      study != null && study!.isForWeek(weekKey) ? study : null;

  RoomReading? readingFor(String weekKey) =>
      reading != null && reading!.isForWeek(weekKey) ? reading : null;

  StudyRoom copyWith({
    String? name,
    String? ownerId,
    String? ownerName,
    RoomKind? kind,
    int? weeklyGoalSteps,
    bool clearGoal = false,
    RoomStudy? study,
    bool clearStudy = false,
    RoomReading? reading,
    bool clearReading = false,
    RoomPlan? plan,
    bool clearPlan = false,
    bool? answersPrivate,
  }) {
    return StudyRoom(
      code: code,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      createdAt: createdAt,
      kind: kind ?? this.kind,
      weeklyGoalSteps: clearGoal
          ? null
          : (weeklyGoalSteps ?? this.weeklyGoalSteps),
      study: clearStudy ? null : (study ?? this.study),
      reading: clearReading ? null : (reading ?? this.reading),
      pilot: pilot,
      plan: clearPlan ? null : (plan ?? this.plan),
      answersPrivate: answersPrivate ?? this.answersPrivate,
    );
  }

  factory StudyRoom.fromMap(String code, Map<String, dynamic> data) {
    DateTime? createdAt;
    final raw = data['createdAt'];
    if (raw is DateTime) {
      createdAt = raw;
    } else {
      try {
        createdAt = (raw as dynamic)?.toDate() as DateTime?;
      } catch (_) {
        createdAt = null;
      }
    }
    return StudyRoom(
      code: code,
      name: (data['name'] as String?)?.trim().isNotEmpty == true
          ? data['name'] as String
          : L10n.current.roomFallbackName,
      ownerId: (data['ownerId'] as String?) ?? '',
      ownerName: (data['ownerName'] as String?)?.trim().isNotEmpty == true
          ? data['ownerName'] as String
          : L10n.current.roomLeaderAmigos,
      createdAt: createdAt,
      kind: RoomKind.fromKey(data['kind'] as String?),
      weeklyGoalSteps: (data['weeklyGoalSteps'] as num?)?.toInt(),
      study: RoomStudy.fromMap(data['study']),
      reading: RoomReading.fromMap(data['reading']),
      pilot: data['pilot'] == true,
      plan: RoomPlan.fromMap(data['plan']),
      answersPrivate: data['answersPrivate'] == true,
    );
  }
}

class RoomMember {
  final String uid;
  final String name;
  final int steps;
  final bool isUser;

  /// YYYY-MM-DD da última caminhada sincronizada (se houver).
  final String? lastWalk;
  final String? photoUrl;
  final PortraitStyle portraitStyle;

  /// Missão do estudo da semana que a pessoa já fez (`slug@semana`).
  final String? studyDone;

  /// Dias (1 = seg … 7 = dom) em que estudou nesta semana.
  final List<int> weekDays;

  /// Capítulos da leitura da semana já lidos (vale com [readingWeek]).
  final int readingDone;
  final String? readingWeek;

  /// Semanas em que ganhou o selo "Fiel na semana" neste grupo.
  final List<String> sealWeeks;

  /// Pontos de acerto acima das semanas anteriores ([growthWeek]). Só a
  /// variação vai para o grupo, nunca o acerto.
  final int? growthPts;
  final String? growthWeek;

  /// O que fez no propósito do grupo (vale com o id do propósito atual).
  final PlanProgress? plan;

  const RoomMember({
    required this.uid,
    required this.name,
    required this.steps,
    this.isUser = false,
    this.lastWalk,
    this.photoUrl,
    this.portraitStyle = PortraitStyle.photo,
    this.studyDone,
    this.weekDays = const [],
    this.readingDone = 0,
    this.readingWeek,
    this.sealWeeks = const [],
    this.growthPts,
    this.growthWeek,
    this.plan,
  });

  /// Crescimento na semana [week] (ou `null`).
  int? growthFor(String week) => growthWeek == week ? growthPts : null;

  /// Capítulos lidos de [reading] (0 se a marca é de outra semana).
  int readingDoneFor(RoomReading? reading) =>
      reading != null && readingWeek == reading.week
      ? readingDone.clamp(0, reading.chapters)
      : 0;

  bool get walkedThisWeek => steps > 0 || weekDays.isNotEmpty;

  /// Dias estudados na semana (ao menos 1 se houve passos).
  int get daysThisWeek =>
      weekDays.isNotEmpty ? weekDays.length : (steps > 0 ? 1 : 0);

  bool walkedToday([DateTime? now]) {
    final d = now ?? DateTime.now();
    final key = d.toIso8601String().substring(0, 10);
    return lastWalk == key;
  }

  bool didStudy(RoomStudy? study) =>
      study != null && studyDone == studyDoneKey(study);

  /// Dias desde a última caminhada; `null` quando nunca caminhou.
  int? daysSinceWalk([DateTime? now]) {
    final raw = lastWalk;
    if (raw == null || raw.length < 10) return null;
    final last = DateTime.tryParse(raw.substring(0, 10));
    if (last == null) return null;
    final d = now ?? DateTime.now();
    final today = DateTime(d.year, d.month, d.day);
    return today.difference(last).inDays;
  }

  static String studyDoneKey(RoomStudy study) =>
      '${study.missionSlug}@${study.week}';
}

/// Convite de grupo dentro do app — a pessoa aceita ou recusa em Grupos.
enum RoomInviteStatus {
  pending,
  accepted,
  declined,
  cancelled;

  static RoomInviteStatus? fromKey(String? raw) {
    for (final s in RoomInviteStatus.values) {
      if (s.name == raw) return s;
    }
    return null;
  }
}

class RoomInvite {
  final String id;
  final String roomCode;
  final String roomName;
  final RoomKind kind;
  final String fromUid;
  final String fromName;
  final String? fromPhotoUrl;
  final String toUid;
  final String toName;
  final String? toPhotoUrl;
  final RoomInviteStatus status;

  /// Convite de um grupo do piloto (abre Grupos para quem recebe).
  final bool pilot;

  const RoomInvite({
    required this.id,
    required this.roomCode,
    required this.roomName,
    required this.kind,
    required this.fromUid,
    required this.fromName,
    required this.toUid,
    required this.toName,
    required this.status,
    this.fromPhotoUrl,
    this.toPhotoUrl,
    this.pilot = false,
  });

  bool get isPending => status == RoomInviteStatus.pending;

  static String docId(String roomCode, String toUid) =>
      '${roomCode.trim().toUpperCase()}_$toUid';

  RoomInvite copyWith({RoomInviteStatus? status}) => RoomInvite(
    id: id,
    roomCode: roomCode,
    roomName: roomName,
    kind: kind,
    fromUid: fromUid,
    fromName: fromName,
    toUid: toUid,
    toName: toName,
    status: status ?? this.status,
    fromPhotoUrl: fromPhotoUrl,
    toPhotoUrl: toPhotoUrl,
    pilot: pilot,
  );

  static RoomInvite? fromDoc(String id, Map<String, dynamic> data) {
    final status = RoomInviteStatus.fromKey(data['status'] as String?);
    final roomCode = (data['roomCode'] as String?)?.trim().toUpperCase() ?? '';
    final fromUid = (data['fromUid'] as String?)?.trim() ?? '';
    final toUid = (data['toUid'] as String?)?.trim() ?? '';
    final roomName = (data['roomName'] as String?)?.trim() ?? '';
    final fromName = (data['fromName'] as String?)?.trim() ?? '';
    final toName = (data['toName'] as String?)?.trim() ?? '';
    if (status == null ||
        roomCode.isEmpty ||
        fromUid.isEmpty ||
        toUid.isEmpty ||
        roomName.isEmpty ||
        fromName.isEmpty) {
      return null;
    }
    return RoomInvite(
      id: id,
      roomCode: roomCode,
      roomName: roomName,
      kind: RoomKind.fromKey(data['kind'] as String?),
      fromUid: fromUid,
      fromName: fromName,
      fromPhotoUrl: (data['fromPhotoUrl'] as String?)?.trim(),
      toUid: toUid,
      toName: toName.isEmpty ? L10n.current.cornerSomeone : toName,
      toPhotoUrl: (data['toPhotoUrl'] as String?)?.trim(),
      status: status,
      pilot: data['pilot'] == true,
    );
  }
}
