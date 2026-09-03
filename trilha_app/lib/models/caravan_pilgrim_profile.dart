import '../services/bible_service.dart';
import '../services/progress_service.dart';
import 'caravan_profile_prefs.dart';
import 'trail.dart';

class CaravanTrailSnapshot {
  final String title;
  final int missionsDone;
  final int missionsTotal;
  final List<String> clearedModes;

  const CaravanTrailSnapshot({
    required this.title,
    required this.missionsDone,
    required this.missionsTotal,
    this.clearedModes = const [],
  });

  double get progress =>
      missionsTotal <= 0 ? 0 : (missionsDone / missionsTotal).clamp(0.0, 1.0);

  bool get isComplete => missionsTotal > 0 && missionsDone >= missionsTotal;
}

/// Perfil público de um peregrino — ranking + jornada (nuvem ou local).
class CaravanPilgrimProfile {
  final String? uid;
  final String name;
  final int steps;
  final int streak;
  final String? lastWalkDate;
  final String? lastSeenDate;
  final List<String> completedMissions;
  final Map<String, List<String>> clearedTrailModes;
  final List<String> readBibleChapters;
  final List<String> perfectMissions;
  final int sharedVerseCount;
  final int memoryMasteredCount;
  final int reflectionCount;
  final String? firstOpenDate;
  final List<String> playDates;

  final int daysAsCaravanLeader;
  final int lifetimeQuestionsCorrect;
  final int lifetimeQuestionsAnswered;
  final String? lastMissionSlug;
  final String? lastMissionCompletedDate;
  final CaravanProfilePrefs prefs;

  final List<CaravanTrailSnapshot> trails;
  final List<String> bibleBooksRead;
  final List<String> completeBibleBooks;
  final List<String> completeNtBooks;
  final int bibleChaptersRead;
  final bool hasDepthsCleared;
  final String? lastMissionTitle;
  final String? lastTrailTitle;

  const CaravanPilgrimProfile({
    this.uid,
    required this.name,
    required this.steps,
    this.streak = 0,
    this.lastWalkDate,
    this.lastSeenDate,
    this.completedMissions = const [],
    this.clearedTrailModes = const {},
    this.readBibleChapters = const [],
    this.perfectMissions = const [],
    this.sharedVerseCount = 0,
    this.memoryMasteredCount = 0,
    this.reflectionCount = 0,
    this.firstOpenDate,
    this.playDates = const [],
    this.daysAsCaravanLeader = 0,
    this.lifetimeQuestionsCorrect = 0,
    this.lifetimeQuestionsAnswered = 0,
    this.lastMissionSlug,
    this.lastMissionCompletedDate,
    this.prefs = const CaravanProfilePrefs(),
    this.trails = const [],
    this.bibleBooksRead = const [],
    this.completeBibleBooks = const [],
    this.completeNtBooks = const [],
    this.bibleChaptersRead = 0,
    this.hasDepthsCleared = false,
    this.lastMissionTitle,
    this.lastTrailTitle,
  });

  int get missionsCompleted => completedMissions.length;

  int? get accuracyPercent {
    if (lifetimeQuestionsAnswered <= 0) return null;
    return ((lifetimeQuestionsCorrect / lifetimeQuestionsAnswered) * 100)
        .round()
        .clamp(0, 100);
  }

  factory CaravanPilgrimProfile.fromProgress({
    required ProgressService progress,
    required String uid,
  }) {
    return CaravanPilgrimProfile(
      uid: uid,
      name: progress.userName,
      steps: progress.steps,
      streak: progress.streak,
      lastWalkDate: progress.lastPlayedDate,
      lastSeenDate: DateTime.now().toIso8601String().substring(0, 10),
      completedMissions: List<String>.from(progress.completedMissions),
      clearedTrailModes: Map<String, List<String>>.from(
        progress.clearedTrailModes.map(
          (k, v) => MapEntry(k, List<String>.from(v)),
        ),
      ),
      readBibleChapters: List<String>.from(progress.readBibleChapters),
      perfectMissions: List<String>.from(progress.perfectMissions),
      sharedVerseCount: progress.sharedVerseCount,
      memoryMasteredCount: progress.memoryMastered.length,
      reflectionCount: progress.missionReflections.length,
      firstOpenDate: progress.firstOpenDate,
      playDates: List<String>.from(progress.playDates),
      daysAsCaravanLeader: progress.daysAsCaravanLeader,
      lifetimeQuestionsCorrect: progress.lifetimeQuestionsCorrect,
      lifetimeQuestionsAnswered: progress.lifetimeQuestionsAnswered,
      lastMissionSlug: progress.lastMissionSlug,
      lastMissionCompletedDate: progress.lastMissionCompletedDate,
      prefs: progress.caravanProfilePrefs,
    );
  }

  factory CaravanPilgrimProfile.fromCloudMap({
    required String uid,
    required Map<String, dynamic> data,
    String? fallbackName,
  }) {
    final name = (data['userName'] as String?)?.trim().isNotEmpty == true
        ? data['userName'] as String
        : (data['name'] as String?)?.trim().isNotEmpty == true
            ? data['name'] as String
            : (fallbackName ?? 'Aprendiz');
    return CaravanPilgrimProfile(
      uid: uid,
      name: name,
      steps: (data['steps'] as num?)?.toInt() ??
          (data['xp'] as num?)?.toInt() ??
          0,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      lastWalkDate: (data['lastWalkDate'] as String?) ??
          (data['lastPlayedDate'] as String?),
      lastSeenDate: data['lastSeenDate'] as String?,
      completedMissions: _asStringList(data['completedMissions']),
      clearedTrailModes: _asStringListMap(data['clearedTrailModes']),
      readBibleChapters: _asStringList(data['readBibleChapters']),
      perfectMissions: _asStringList(data['perfectMissions']),
      sharedVerseCount: (data['sharedVerseCount'] as num?)?.toInt() ??
          _asStringList(data['sharedVerses']).length,
      memoryMasteredCount: _asStringList(data['memoryMastered']).length,
      reflectionCount: _asStringMap(data['missionReflections']).length,
      firstOpenDate: data['firstOpenDate'] as String?,
      playDates: _asStringList(data['playDates']),
      daysAsCaravanLeader:
          (data['daysAsCaravanLeader'] as num?)?.toInt() ?? 0,
      lifetimeQuestionsCorrect:
          (data['lifetimeQuestionsCorrect'] as num?)?.toInt() ?? 0,
      lifetimeQuestionsAnswered:
          (data['lifetimeQuestionsAnswered'] as num?)?.toInt() ?? 0,
      lastMissionSlug: data['lastMissionSlug'] as String?,
      lastMissionCompletedDate: data['lastMissionCompletedDate'] as String?,
      prefs: CaravanProfilePrefs.fromMap(data['caravanProfilePrefs']),
    );
  }

  /// Enriquece com nomes de trilhas/livros/cenas a partir do catálogo local.
  Future<CaravanPilgrimProfile> enriched({
    required List<Trail> catalog,
    required List<BibleBook> bibleBooks,
  }) async {
    final trails = <CaravanTrailSnapshot>[];
    String? missionTitle;
    String? trailTitle;

    for (final trail in catalog) {
      if (trail.missionSlugs.isEmpty || trail.comingSoon) continue;

      if (lastMissionSlug != null && missionTitle == null) {
        for (final mod in trail.modules) {
          for (final mission in mod.missions) {
            if (mission.slug == lastMissionSlug) {
              missionTitle = mission.title;
              trailTitle = trail.title;
            }
          }
        }
      }

      final slugs = trail.missionSlugs;
      final done = slugs.where(completedMissions.contains).length;
      if (done == 0 && !(clearedTrailModes[trail.slug]?.isNotEmpty ?? false)) {
        continue;
      }
      trails.add(
        CaravanTrailSnapshot(
          title: trail.title,
          missionsDone: done,
          missionsTotal: slugs.length,
          clearedModes: List<String>.from(
            clearedTrailModes[trail.slug] ?? const [],
          ),
        ),
      );
    }
    trails.sort((a, b) {
      final byProgress = b.progress.compareTo(a.progress);
      if (byProgress != 0) return byProgress;
      return a.title.compareTo(b.title);
    });

    final abbrevToName = {
      for (final b in bibleBooks) b.abbrev.toLowerCase(): b.name,
    };
    final byBook = <String, int>{};
    for (final key in readBibleChapters) {
      final parts = key.split(':');
      if (parts.isEmpty) continue;
      byBook[parts.first.toLowerCase()] =
          (byBook[parts.first.toLowerCase()] ?? 0) + 1;
    }

    final completeBooks = <String>[];
    final completeNt = <String>[];
    for (var i = 0; i < bibleBooks.length; i++) {
      final book = bibleBooks[i];
      final abbrev = book.abbrev.toLowerCase();
      final total = book.chapters.length;
      final read = byBook[abbrev] ?? 0;
      if (total > 0 && read >= total) {
        completeBooks.add(abbrev);
        if (i >= BibleService.oldTestamentCount) {
          completeNt.add(abbrev);
        }
      }
    }

    final books = byBook.entries
        .where((e) => e.value > 0)
        .map((e) => abbrevToName[e.key] ?? e.key.toUpperCase())
        .toList()
      ..sort();

    final depthsCleared = clearedTrailModes.values.any(
      (modes) => modes.contains('profundezas'),
    );

    return CaravanPilgrimProfile(
      uid: uid,
      name: name,
      steps: steps,
      streak: streak,
      lastWalkDate: lastWalkDate,
      lastSeenDate: lastSeenDate,
      completedMissions: completedMissions,
      clearedTrailModes: clearedTrailModes,
      readBibleChapters: readBibleChapters,
      perfectMissions: perfectMissions,
      sharedVerseCount: sharedVerseCount,
      memoryMasteredCount: memoryMasteredCount,
      reflectionCount: reflectionCount,
      firstOpenDate: firstOpenDate,
      playDates: playDates,
      daysAsCaravanLeader: daysAsCaravanLeader,
      lifetimeQuestionsCorrect: lifetimeQuestionsCorrect,
      lifetimeQuestionsAnswered: lifetimeQuestionsAnswered,
      lastMissionSlug: lastMissionSlug,
      lastMissionCompletedDate: lastMissionCompletedDate,
      prefs: prefs,
      trails: trails,
      bibleBooksRead: books,
      completeBibleBooks: completeBooks,
      completeNtBooks: completeNt,
      bibleChaptersRead: readBibleChapters.length,
      hasDepthsCleared: depthsCleared,
      lastMissionTitle: missionTitle,
      lastTrailTitle: trailTitle,
    );
  }

  static Map<String, String> _asStringMap(dynamic raw) {
    if (raw is! Map) return const {};
    return {
      for (final e in raw.entries)
        if (e.value != null) e.key.toString(): e.value.toString(),
    };
  }

  static List<String> _asStringList(dynamic raw) {
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is String && item.trim().isNotEmpty) item.trim(),
    ];
  }

  static Map<String, List<String>> _asStringListMap(dynamic raw) {
    if (raw is! Map) return const {};
    final out = <String, List<String>>{};
    raw.forEach((key, value) {
      if (key is! String) return;
      out[key] = _asStringList(value);
    });
    return out;
  }
}
