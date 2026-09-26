import '../widgets/cinematic_icon.dart';
import 'portrait_style.dart';

/// Teto de pessoas por grupo (plano grátis). A function
/// `onRoomMemberCreate` também corta quem passar disso.
const int kRoomMemberLimit = 20;

/// Para que o grupo existe — muda rótulo, ícone e textos.
enum RoomKind {
  celula('celula', 'Célula', CinematicGlyph.home),
  discipulado('discipulado', 'Discipulado', CinematicGlyph.path),
  ebd('ebd', 'EBD', CinematicGlyph.book),
  familia('familia', 'Família', CinematicGlyph.heart),
  amigos('amigos', 'Amigos', CinematicGlyph.people);

  final String storageKey;
  final String label;
  final CinematicGlyph glyph;

  const RoomKind(this.storageKey, this.label, this.glyph);

  /// Quem conduz o grupo, no vocabulário de cada tipo.
  String get leaderTitle => switch (this) {
    RoomKind.celula => 'Líder',
    RoomKind.discipulado => 'Discipulador',
    RoomKind.ebd => 'Professor',
    RoomKind.familia => 'Responsável',
    RoomKind.amigos => 'Anfitrião',
  };

  String get namePlaceholder => switch (this) {
    RoomKind.celula => 'Ex.: Célula Norte',
    RoomKind.discipulado => 'Ex.: Discipulado de quinta',
    RoomKind.ebd => 'Ex.: EBD Jovens',
    RoomKind.familia => 'Ex.: Família Souza',
    RoomKind.amigos => 'Ex.: Amigos da facul',
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
      title: title == null || title.isEmpty ? 'Estudo da semana' : title,
      week: week,
      verseRef: (raw['verseRef'] as String?)?.trim(),
      verse: (raw['verse'] as String?)?.trim(),
      note: (raw['note'] as String?)?.trim(),
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

  const StudyRoom({
    required this.code,
    required this.name,
    required this.ownerId,
    required this.ownerName,
    this.createdAt,
    this.kind = RoomKind.celula,
    this.weeklyGoalSteps,
    this.study,
  });

  bool isOwner(String? uid) => uid != null && uid == ownerId;

  RoomStudy? studyFor(String weekKey) =>
      study != null && study!.isForWeek(weekKey) ? study : null;

  StudyRoom copyWith({
    String? name,
    String? ownerId,
    String? ownerName,
    RoomKind? kind,
    int? weeklyGoalSteps,
    bool clearGoal = false,
    RoomStudy? study,
    bool clearStudy = false,
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
          : 'Grupo',
      ownerId: (data['ownerId'] as String?) ?? '',
      ownerName: (data['ownerName'] as String?)?.trim().isNotEmpty == true
          ? data['ownerName'] as String
          : 'Anfitrião',
      createdAt: createdAt,
      kind: RoomKind.fromKey(data['kind'] as String?),
      weeklyGoalSteps: (data['weeklyGoalSteps'] as num?)?.toInt(),
      study: RoomStudy.fromMap(data['study']),
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
  });

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
      toName: toName.isEmpty ? 'Alguém' : toName,
      toPhotoUrl: (data['toPhotoUrl'] as String?)?.trim(),
      status: status,
    );
  }
}
