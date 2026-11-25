import '../services/progress_service.dart';
import '../utils/reading_growth.dart';
import 'caravan_profile_prefs.dart';

/// O que o perfil mostra além da vitrine clássica — Meu estudo, Na Palavra,
/// tarefas da semana e selos de grupo — para a caravana ver igual.
///
/// Meu estudo e Na Palavra moram no doc privado (`users/{uid}/private/data`).
/// Só com o olho aberto o app publica um **resumo** no doc público: números
/// de acerto e contagens. Notas, favoritos e erros nunca saem do privado.
class CaravanProfileExtras {
  /// Acerto de primeira por `modo.gesto` (cópia de answerCorrect/Total).
  final Map<String, int> studyCorrect;
  final Map<String, int> studyTotal;

  /// Acerto por `SEGUNDA.modo`, só as últimas [studyWeeks] semanas.
  final Map<String, int> studyWeekCorrect;
  final Map<String, int> studyWeekTotal;

  final int bookmarkCount;
  final int noteCount;

  /// Tarefas da semana: valem só se [weeklyWeek] é a semana atual.
  final String? weeklyWeek;
  final Map<String, int> weeklyProgress;
  final List<String> weeklyClaimed;

  final int groupSealCount;

  const CaravanProfileExtras({
    this.studyCorrect = const {},
    this.studyTotal = const {},
    this.studyWeekCorrect = const {},
    this.studyWeekTotal = const {},
    this.bookmarkCount = 0,
    this.noteCount = 0,
    this.weeklyWeek,
    this.weeklyProgress = const {},
    this.weeklyClaimed = const [],
    this.groupSealCount = 0,
  });

  static const studyWeeks = 8;

  /// Campos do resumo no doc público.
  static const studyKeys = [
    'studyCorrect',
    'studyTotal',
    'studyWeekCorrect',
    'studyWeekTotal',
  ];
  static const wordKey = 'wordCounts';

  bool get hasStudy => studyTotal.values.any((v) => v > 0);

  /// Tarefas desta semana (as de outra semana já venceram).
  bool get questsThisWeek =>
      weeklyWeek != null &&
      weeklyWeek == ReadingGrowth.weekKey(DateTime.now()) &&
      (weeklyProgress.isNotEmpty || weeklyClaimed.isNotEmpty);

  factory CaravanProfileExtras.fromProgress(ProgressService p) =>
      CaravanProfileExtras(
        studyCorrect: Map.of(p.answerCorrect),
        studyTotal: Map.of(p.answerTotal),
        studyWeekCorrect: recentWeeks(p.weekAnswerCorrect),
        studyWeekTotal: recentWeeks(p.weekAnswerTotal),
        bookmarkCount: p.parseBookmarks().length,
        noteCount: p.parseNotes().length,
        weeklyWeek: p.weeklyWeek,
        weeklyProgress: Map.of(p.weeklyProgressMap),
        weeklyClaimed: List.of(p.weeklyClaimed),
        groupSealCount: p.groupSealWeeks.length,
      );

  factory CaravanProfileExtras.fromCloudMap(Map<String, dynamic> data) {
    final word = data[wordKey];
    return CaravanProfileExtras(
      studyCorrect: _intMap(data['studyCorrect']),
      studyTotal: _intMap(data['studyTotal']),
      studyWeekCorrect: _intMap(data['studyWeekCorrect']),
      studyWeekTotal: _intMap(data['studyWeekTotal']),
      bookmarkCount: word is Map ? _int(word['bookmarks']) : 0,
      noteCount: word is Map ? _int(word['notes']) : 0,
      weeklyWeek: data['weeklyWeek'] as String?,
      weeklyProgress: _intMap(data['weeklyProgress']),
      weeklyClaimed: [
        if (data['weeklyClaimed'] is List)
          for (final v in data['weeklyClaimed'] as List) v.toString(),
      ],
      groupSealCount: data['groupSealWeeks'] is List
          ? (data['groupSealWeeks'] as List).length
          : 0,
    );
  }

  /// Resumo para o doc público a partir do payload completo do save.
  /// Seção escondida: o campo vai como `null` e o chamador o apaga.
  static Map<String, Object?> publicSummary(Map<String, dynamic> full) {
    final prefs = CaravanProfilePrefs.fromMap(full['caravanProfilePrefs']);
    final study = prefs.isVisible(CaravanProfileSection.study);
    final word = prefs.isVisible(CaravanProfileSection.word);
    int count(Object? v) => v is Map
        ? v.length
        : v is List
        ? v.length
        : 0;
    return {
      'studyCorrect': study ? _intMap(full['answerCorrect']) : null,
      'studyTotal': study ? _intMap(full['answerTotal']) : null,
      'studyWeekCorrect': study
          ? recentWeeks(_intMap(full['weekAnswerCorrect']))
          : null,
      'studyWeekTotal': study
          ? recentWeeks(_intMap(full['weekAnswerTotal']))
          : null,
      wordKey: word
          ? {
              'bookmarks': count(full['bibleBookmarks']),
              'notes': count(full['bibleNotes']),
            }
          : null,
    };
  }

  /// Só as últimas [studyWeeks] semanas (chave `SEGUNDA.modo`).
  static Map<String, int> recentWeeks(Map<String, int> map) {
    final weeks = {for (final k in map.keys) k.split('.').first}.toList()
      ..sort();
    final keep = weeks.length <= studyWeeks
        ? weeks.toSet()
        : weeks.sublist(weeks.length - studyWeeks).toSet();
    return {
      for (final e in map.entries)
        if (keep.contains(e.key.split('.').first)) e.key: e.value,
    };
  }

  static int _int(Object? v) => v is num ? v.toInt() : 0;

  static Map<String, int> _intMap(Object? raw) {
    if (raw is! Map) return {};
    return {
      for (final e in raw.entries)
        if (e.value is num) e.key.toString(): (e.value as num).toInt(),
    };
  }
}
