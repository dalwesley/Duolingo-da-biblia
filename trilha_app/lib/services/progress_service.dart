import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_quest.dart';
import '../utils/appearance.dart';

class AppSettings {
  final bool sound;
  final bool notifications;
  final int dailyGoal;
  final AppearanceMode appearanceMode;

  const AppSettings({
    this.sound = true,
    this.notifications = true,
    this.dailyGoal = 1,
    this.appearanceMode = AppearanceMode.automatic,
  });

  /// Compat: true quando o visual preferido é noturno.
  bool get darkMode => appearanceMode == AppearanceMode.night;

  AppSettings copyWith({
    bool? sound,
    bool? notifications,
    int? dailyGoal,
    AppearanceMode? appearanceMode,
  }) {
    return AppSettings(
      sound: sound ?? this.sound,
      notifications: notifications ?? this.notifications,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      appearanceMode: appearanceMode ?? this.appearanceMode,
    );
  }
}

class ProgressService extends ChangeNotifier {
  static const _keySteps = 'xp';
  static const _keyStreak = 'streak';
  static const _keyLastPlayed = 'lastPlayedDate';
  static const _keyCompleted = 'completedMissions';
  static const _keyMissionsToday = 'missionsToday';
  static const _keyHasSeenSplash = 'hasSeenSplash';
  static const _keyHasSeenOnboarding = 'hasSeenOnboarding';
  static const _keyUserName = 'userName';
  static const _keySound = 'sound';
  static const _keyNotifications = 'notifications';
  static const _keyDailyGoal = 'dailyGoal';
  static const _keyDarkMode = 'darkMode';
  static const _keyAppearanceMode = 'appearanceMode';
  static const _keyTrailDifficulty = 'trailDifficultyMap';
  static const _keyUsedQuestions = 'usedQuestionIds';
  static const _keyMistakeIds = 'mistakeQuestionIds';
  static const _keyPlayDates = 'playDates';
  static const _keyStreakFreeze = 'streakFreezeAvailable';
  static const _keyFreezeWeek = 'streakFreezeWeek';
  static const _keyQuestDay = 'questDay';
  static const _keyQuestProgress = 'questProgress';
  static const _keyQuestClaimed = 'questClaimed';
  static const _keyWeeklyWeek = 'weeklyQuestWeek';
  static const _keyWeeklyProgress = 'weeklyQuestProgress';
  static const _keyWeeklyClaimed = 'weeklyQuestClaimed';
  static const _keyClaimedChests = 'claimedChests';
  static const _keyReflections = 'missionReflections';
  // Storage keys keep legacy names so existing installs migrate cleanly.
  static const _keyWeeklySteps = 'weeklyXp';
  static const _keyLastWeekSteps = 'lastWeekXp';
  static const _keyLastWeekKey = 'lastWeekKey';
  static const _keyReadBibleChapters = 'readBibleChapters';
  static const _keyBibleBookmarks = 'bibleBookmarks';
  static const _keyMemoryScores = 'memoryScores';
  static const _keyMemoryMastered = 'memoryMastered';

  static const maxLamps = 5;

  /// Unidade do produto: passos (legado local/cloud ainda usa a chave `xp`).
  int steps = 0;
  int streak = 0;
  String? lastPlayedDate;
  List<String> completedMissions = [];
  int missionsToday = 0;
  bool hasSeenSplash = false;
  bool hasSeenOnboarding = false;
  String userName = 'Peregrino';
  AppSettings settings = const AppSettings();
  Map<String, String> trailDifficulties = {};
  List<String> usedQuestionIds = [];
  List<String> mistakeQuestionIds = [];
  List<String> playDates = [];
  bool streakFreezeAvailable = true;
  String? streakFreezeWeek;
  String? questDay;
  Map<String, int> questProgressMap = {};
  List<String> questClaimed = [];
  String? weeklyWeek;
  Map<String, int> weeklyProgressMap = {};
  List<String> weeklyClaimed = [];
  List<String> claimedChests = [];
  /// Última reflexão por slug de missão.
  Map<String, String> missionReflections = {};

  /// Capítulos lidos na Bíblia ("abbrev:capítulo", ex.: "gn:1").
  List<String> readBibleChapters = [];

  /// Favoritos ("abbrev:capítulo:versículo", ex.: "gn:1:1").
  List<String> bibleBookmarks = [];

  /// Pontuação de memorização por id (0–5).
  Map<String, int> memoryScores = {};

  /// Versículos considerados firmes (score alto mantido).
  List<String> memoryMastered = [];

  /// Passos acumulados só nesta semana (comunidade / salas).
  int weeklySteps = 0;

  /// Passos finais da semana anterior.
  int lastWeekSteps = 0;
  String? lastWeekKey;
  bool _loaded = false;

  /// True when daily goal was just crossed (UI one-shot).
  bool goalJustReached = false;

  bool get isLoaded => _loaded;

  String _todayKey() => DateTime.now().toIso8601String().substring(0, 10);

  String _yesterdayKey() {
    final d = DateTime.now().subtract(const Duration(days: 1));
    return d.toIso8601String().substring(0, 10);
  }

  String _weekKey() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    return start.toIso8601String().substring(0, 10);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    steps = prefs.getInt(_keySteps) ?? 0;
    streak = prefs.getInt(_keyStreak) ?? 0;
    lastPlayedDate = prefs.getString(_keyLastPlayed);
    completedMissions = prefs.getStringList(_keyCompleted) ?? [];
    missionsToday = prefs.getInt(_keyMissionsToday) ?? 0;
    hasSeenSplash = prefs.getBool(_keyHasSeenSplash) ?? false;
    hasSeenOnboarding = prefs.getBool(_keyHasSeenOnboarding) ?? false;
    userName = prefs.getString(_keyUserName) ?? 'Peregrino';
    settings = AppSettings(
      sound: prefs.getBool(_keySound) ?? true,
      notifications: prefs.getBool(_keyNotifications) ?? true,
      dailyGoal: prefs.getInt(_keyDailyGoal) ?? 1,
      appearanceMode: AppearanceModeX.fromStorage(
        prefs.getString(_keyAppearanceMode),
        legacyDarkMode: prefs.getBool(_keyDarkMode),
      ),
    );
    final diffRaw = prefs.getString(_keyTrailDifficulty);
    if (diffRaw != null && diffRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(diffRaw) as Map<String, dynamic>;
        trailDifficulties = decoded.map((k, v) => MapEntry(k, v.toString()));
      } catch (_) {
        trailDifficulties = {};
      }
    }
    usedQuestionIds = prefs.getStringList(_keyUsedQuestions) ?? [];
    mistakeQuestionIds = prefs.getStringList(_keyMistakeIds) ?? [];
    playDates = prefs.getStringList(_keyPlayDates) ?? [];
    streakFreezeWeek = prefs.getString(_keyFreezeWeek);
    final week = _weekKey();
    if (streakFreezeWeek != week) {
      streakFreezeAvailable = true;
      streakFreezeWeek = week;
    } else {
      streakFreezeAvailable = prefs.getBool(_keyStreakFreeze) ?? true;
    }
    questDay = prefs.getString(_keyQuestDay);
    final qp = prefs.getString(_keyQuestProgress);
    if (qp != null && qp.isNotEmpty) {
      try {
        final decoded = jsonDecode(qp) as Map<String, dynamic>;
        questProgressMap = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      } catch (_) {}
    }
    questClaimed = prefs.getStringList(_keyQuestClaimed) ?? [];
    _ensureQuestDay();

    weeklyWeek = prefs.getString(_keyWeeklyWeek);
    final wp = prefs.getString(_keyWeeklyProgress);
    if (wp != null && wp.isNotEmpty) {
      try {
        final decoded = jsonDecode(wp) as Map<String, dynamic>;
        weeklyProgressMap = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      } catch (_) {}
    }
    weeklyClaimed = prefs.getStringList(_keyWeeklyClaimed) ?? [];
    weeklySteps = prefs.getInt(_keyWeeklySteps) ?? 0;
    lastWeekSteps = prefs.getInt(_keyLastWeekSteps) ?? 0;
    lastWeekKey = prefs.getString(_keyLastWeekKey);
    _ensureWeeklyWeek();

    claimedChests = prefs.getStringList(_keyClaimedChests) ?? [];
    readBibleChapters = prefs.getStringList(_keyReadBibleChapters) ?? [];
    bibleBookmarks = prefs.getStringList(_keyBibleBookmarks) ?? [];
    final memRaw = prefs.getString(_keyMemoryScores);
    if (memRaw != null && memRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(memRaw) as Map<String, dynamic>;
        memoryScores = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      } catch (_) {
        memoryScores = {};
      }
    }
    memoryMastered = prefs.getStringList(_keyMemoryMastered) ?? [];
    final reflRaw = prefs.getString(_keyReflections);
    if (reflRaw != null && reflRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(reflRaw) as Map<String, dynamic>;
        missionReflections = decoded.map((k, v) => MapEntry(k, v.toString()));
      } catch (_) {
        missionReflections = {};
      }
    }
    _loaded = true;
    notifyListeners();
  }

  void _ensureQuestDay() {
    final today = _todayKey();
    if (questDay != today) {
      questDay = today;
      questProgressMap = {};
      questClaimed = [];
    }
  }

  void _ensureWeeklyWeek() {
    final week = _weekKey();
    if (weeklyWeek != week) {
      // Fecha a semana anterior guardando o XP final (usado pela liga).
      if (weeklyWeek != null) {
        lastWeekSteps = weeklySteps;
        lastWeekKey = weeklyWeek;
      }
      weeklyWeek = week;
      weeklyProgressMap = {};
      weeklyClaimed = [];
      weeklySteps = 0;
    }
  }

  /// Soma passos totais + passos semanais de uma vez.
  void _gainSteps(int amount) {
    _ensureWeeklyWeek();
    steps += amount;
    weeklySteps += amount;
  }

  /// Bônus avulso (ex.: prêmio de promoção na liga).
  Future<void> grantBonusSteps(int amount) async {
    _gainSteps(amount);
    await _save();
    notifyListeners();
  }

  /// Registra a leitura de um capítulo da Bíblia (missão diária "Palavra viva").
  Future<void> recordBibleReading(String bookAbbrev, int chapter) async {
    final key = bibleChapterKey(bookAbbrev, chapter);
    if (!readBibleChapters.contains(key)) {
      readBibleChapters = [...readBibleChapters, key];
    }
    await _bumpQuest('read');
    await _bumpQuest('seasonal');
  }

  static String bibleChapterKey(String bookAbbrev, int chapter) =>
      '${bookAbbrev.toLowerCase()}:$chapter';

  static String bibleBookmarkKey(String bookAbbrev, int chapter, int verse) =>
      '${bookAbbrev.toLowerCase()}:$chapter:$verse';

  bool hasReadBibleChapter(String bookAbbrev, int chapter) =>
      readBibleChapters.contains(bibleChapterKey(bookAbbrev, chapter));

  int readChaptersInBook(String bookAbbrev) {
    final prefix = '${bookAbbrev.toLowerCase()}:';
    return readBibleChapters.where((k) => k.startsWith(prefix) && k.split(':').length == 2).length;
  }

  bool isVerseBookmarked(String bookAbbrev, int chapter, int verse) =>
      bibleBookmarks.contains(bibleBookmarkKey(bookAbbrev, chapter, verse));

  Future<bool> toggleBibleBookmark(String bookAbbrev, int chapter, int verse) async {
    final key = bibleBookmarkKey(bookAbbrev, chapter, verse);
    if (bibleBookmarks.contains(key)) {
      bibleBookmarks = [for (final k in bibleBookmarks) if (k != key) k];
      await _save();
      notifyListeners();
      return false;
    }
    bibleBookmarks = [key, ...bibleBookmarks];
    await _bumpQuest('bookmark');
    await _save();
    notifyListeners();
    return true;
  }

  /// Favoritos recentes primeiro (já ordenados).
  List<({String abbrev, int chapter, int verse})> parseBookmarks() {
    final out = <({String abbrev, int chapter, int verse})>[];
    for (final k in bibleBookmarks) {
      final parts = k.split(':');
      if (parts.length != 3) continue;
      final chapter = int.tryParse(parts[1]);
      final verse = int.tryParse(parts[2]);
      if (chapter == null || verse == null) continue;
      out.add((abbrev: parts[0], chapter: chapter, verse: verse));
    }
    return out;
  }

  int memoryScore(String id) => memoryScores[id] ?? 0;

  bool isMemoryMastered(String id) =>
      memoryMastered.contains(id) || memoryScore(id) >= 5;

  Future<void> recordMemoryReview(String id, {required bool knew}) async {
    final current = memoryScore(id);
    final next = knew ? (current + 1).clamp(0, 5) : (current - 1).clamp(0, 5);
    memoryScores = {...memoryScores, id: next};
    if (next >= 5) {
      if (!memoryMastered.contains(id)) {
        memoryMastered = [...memoryMastered, id];
      }
    } else {
      memoryMastered = [for (final m in memoryMastered) if (m != id) m];
    }
    await _bumpQuest('memory');
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySteps, steps);
    await prefs.setInt(_keyStreak, streak);
    if (lastPlayedDate != null) {
      await prefs.setString(_keyLastPlayed, lastPlayedDate!);
    }
    await prefs.setStringList(_keyCompleted, completedMissions);
    await prefs.setInt(_keyMissionsToday, missionsToday);
    await prefs.setBool(_keyHasSeenSplash, hasSeenSplash);
    await prefs.setBool(_keyHasSeenOnboarding, hasSeenOnboarding);
    await prefs.setString(_keyUserName, userName);
    await prefs.setBool(_keySound, settings.sound);
    await prefs.setBool(_keyNotifications, settings.notifications);
    await prefs.setInt(_keyDailyGoal, settings.dailyGoal);
    await prefs.setString(_keyAppearanceMode, settings.appearanceMode.storageKey);
    await prefs.setBool(_keyDarkMode, settings.appearanceMode == AppearanceMode.night);
    await prefs.setString(_keyTrailDifficulty, jsonEncode(trailDifficulties));
    await prefs.setStringList(_keyUsedQuestions, usedQuestionIds);
    await prefs.setStringList(_keyMistakeIds, mistakeQuestionIds);
    await prefs.setStringList(_keyPlayDates, playDates);
    await prefs.setBool(_keyStreakFreeze, streakFreezeAvailable);
    if (streakFreezeWeek != null) await prefs.setString(_keyFreezeWeek, streakFreezeWeek!);
    if (questDay != null) await prefs.setString(_keyQuestDay, questDay!);
    await prefs.setString(_keyQuestProgress, jsonEncode(questProgressMap));
    await prefs.setStringList(_keyQuestClaimed, questClaimed);
    if (weeklyWeek != null) await prefs.setString(_keyWeeklyWeek, weeklyWeek!);
    await prefs.setString(_keyWeeklyProgress, jsonEncode(weeklyProgressMap));
    await prefs.setStringList(_keyWeeklyClaimed, weeklyClaimed);
    await prefs.setStringList(_keyClaimedChests, claimedChests);
    await prefs.setStringList(_keyReadBibleChapters, readBibleChapters);
    await prefs.setStringList(_keyBibleBookmarks, bibleBookmarks);
    await prefs.setString(_keyMemoryScores, jsonEncode(memoryScores));
    await prefs.setStringList(_keyMemoryMastered, memoryMastered);
    await prefs.setString(_keyReflections, jsonEncode(missionReflections));
    await prefs.setInt(_keyWeeklySteps, weeklySteps);
    await prefs.setInt(_keyLastWeekSteps, lastWeekSteps);
    if (lastWeekKey != null) await prefs.setString(_keyLastWeekKey, lastWeekKey!);
  }

  String? reflectionFor(String missionSlug) => missionReflections[missionSlug];

  Future<void> saveReflection(String missionSlug, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    missionReflections = {...missionReflections, missionSlug: trimmed};
    await _save();
    notifyListeners();
  }

  /// Reflexões recentes (mais novas primeiro), até [limit].
  List<MapEntry<String, String>> recentReflections({int limit = 3}) {
    final entries = missionReflections.entries.toList();
    if (entries.length <= limit) return entries.reversed.toList();
    return entries.sublist(entries.length - limit).reversed.toList();
  }

  void _recordSession() {
    final today = _todayKey();
    if (lastPlayedDate == today) return;

    if (lastPlayedDate == _yesterdayKey()) {
      streak = streak + 1;
    } else if (lastPlayedDate != null && streakFreezeAvailable) {
      // Perdeu 1 dia — protege com congelamento (estilo streak freeze).
      streakFreezeAvailable = false;
      // streak permanece
    } else {
      streak = 1;
    }

    lastPlayedDate = today;
    missionsToday = 0;
    if (!playDates.contains(today)) {
      playDates = [...playDates, today];
      if (playDates.length > 60) playDates = playDates.sublist(playDates.length - 60);
    }
  }

  bool playedOnDate(DateTime date) {
    final key = date.toIso8601String().substring(0, 10);
    return playDates.contains(key) || lastPlayedDate == key;
  }

  bool get walkedToday => missionsToday > 0;

  /// Ausente por mais de um dia (a graça não funciona como streak).
  bool get isReturningAfterGap {
    if (lastPlayedDate == null) return false;
    final today = _todayKey();
    if (lastPlayedDate == today || lastPlayedDate == _yesterdayKey()) return false;
    return true;
  }

  String? difficultyForTrail(String trailSlug) => trailDifficulties[trailSlug];

  bool hasDifficultyForTrail(String trailSlug) => trailDifficulties.containsKey(trailSlug);

  Future<void> setTrailDifficulty(String trailSlug, String difficultyId) async {
    trailDifficulties = {...trailDifficulties, trailSlug: difficultyId};
    await _save();
    notifyListeners();
  }

  Future<void> markQuestionsUsed(List<String> ids) async {
    final next = {...usedQuestionIds, ...ids}.toList();
    usedQuestionIds = next.length > 120 ? next.sublist(next.length - 120) : next;
    await _save();
    notifyListeners();
  }

  Future<void> recordMistake(String questionId) async {
    if (mistakeQuestionIds.contains(questionId)) return;
    mistakeQuestionIds = [...mistakeQuestionIds, questionId];
    if (mistakeQuestionIds.length > 80) {
      mistakeQuestionIds = mistakeQuestionIds.sublist(mistakeQuestionIds.length - 80);
    }
    await _save();
    notifyListeners();
  }

  Future<void> clearMistake(String questionId) async {
    mistakeQuestionIds = mistakeQuestionIds.where((id) => id != questionId).toList();
    await _save();
    notifyListeners();
  }

  int questProgress(String id) => questProgressMap[id] ?? 0;

  bool isQuestClaimed(String id) => questClaimed.contains(id);

  int get questsCompletedToday =>
      DailyQuestDefs.all.where((q) => questProgress(q.id) >= q.target || isQuestClaimed(q.id)).length;

  int weeklyQuestProgress(String id) => weeklyProgressMap[id] ?? 0;

  bool isWeeklyQuestClaimed(String id) => weeklyClaimed.contains(id);

  int get weeklyQuestsCompleted =>
      WeeklyQuestDefs.all.where((q) => weeklyQuestProgress(q.id) >= q.target || isWeeklyQuestClaimed(q.id)).length;

  int get daysPlayedThisWeek {
    _ensureWeeklyWeek();
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    var count = 0;
    for (var i = 0; i < 7; i++) {
      if (playedOnDate(monday.add(Duration(days: i)))) count++;
    }
    return count;
  }

  bool isChestClaimed(String chestId) => claimedChests.contains(chestId);

  Future<bool> claimChest(String chestId, int stepsReward) async {
    if (claimedChests.contains(chestId)) return false;
    claimedChests = [...claimedChests, chestId];
    _gainSteps(stepsReward);
    await _save();
    notifyListeners();
    return true;
  }

  Future<void> _bumpQuest(String id, {int by = 1}) async {
    _ensureQuestDay();
    DailyQuest? q;
    for (final item in DailyQuestDefs.all) {
      if (item.id == id) q = item;
    }
    if (q == null) return;
    final next = (questProgressMap[id] ?? 0) + by;
    questProgressMap = {...questProgressMap, id: next.clamp(0, q.target)};
    await _save();
    notifyListeners();
  }

  Future<void> _bumpWeekly(String id, {int by = 1, int? absolute}) async {
    _ensureWeeklyWeek();
    DailyQuest? q;
    for (final item in WeeklyQuestDefs.all) {
      if (item.id == id) q = item;
    }
    if (q == null) return;
    final current = weeklyProgressMap[id] ?? 0;
    final next = absolute ?? (current + by);
    weeklyProgressMap = {...weeklyProgressMap, id: next.clamp(0, q.target)};
    await _save();
    notifyListeners();
  }

  Future<void> claimQuest(String id) async {
    _ensureQuestDay();
    DailyQuest? q;
    for (final item in DailyQuestDefs.all) {
      if (item.id == id) q = item;
    }
    if (q == null) return;
    if (isQuestClaimed(id)) return;
    if (questProgress(id) < q.target) return;
    questClaimed = [...questClaimed, id];
    _gainSteps(q.stepsReward);
    await _save();
    notifyListeners();
  }

  Future<void> claimWeeklyQuest(String id) async {
    _ensureWeeklyWeek();
    DailyQuest? q;
    for (final item in WeeklyQuestDefs.all) {
      if (item.id == id) q = item;
    }
    if (q == null) return;
    if (isWeeklyQuestClaimed(id)) return;
    if (weeklyQuestProgress(id) < q.target) return;
    weeklyClaimed = [...weeklyClaimed, id];
    _gainSteps(q.stepsReward);
    await _save();
    notifyListeners();
  }

  /// Calcula passos da lição: base × precisão × bônus perfeito × bônus lâmpadas.
  static int computeLessonSteps({
    required int baseSteps,
    required int correct,
    required int total,
    required int lampsLeft,
    required int maxLamps,
  }) {
    if (total <= 0) return baseSteps;
    final accuracy = correct / total;
    var reward = baseSteps * accuracy;
    if (accuracy >= 1) reward *= 1.25; // perfeito
    if (lampsLeft >= maxLamps) reward *= 1.1; // sem erros de lâmpada
    return reward.round().clamp(10, baseSteps * 2);
  }

  Future<void> completeMission(
    String slug,
    int rewardSteps, {
    bool isReplay = false,
    int correct = 0,
    int total = 0,
  }) async {
    _ensureQuestDay();
    final today = _todayKey();
    final alreadyToday = lastPlayedDate == today;
    final wasGoalMet = missionsToday >= settings.dailyGoal;

    if (!isReplay) {
      if (completedMissions.contains(slug)) {
        // Já completa: trata como revisão (XP reduzido)
        isReplay = true;
      } else {
        completedMissions = [...completedMissions, slug];
      }
    }

    final award = isReplay ? (rewardSteps * 0.35).round().clamp(5, rewardSteps) : rewardSteps;
    _gainSteps(award);

    if (!alreadyToday) {
      _recordSession();
      missionsToday = 1;
    } else {
      missionsToday = missionsToday + 1;
      if (!playDates.contains(today)) {
        playDates = [...playDates, today];
      }
    }

    goalJustReached = !wasGoalMet && missionsToday >= settings.dailyGoal;

    await _bumpQuest('mission');
    if (total > 0 && correct / total >= 0.8) await _bumpQuest('accuracy');
    if (total > 0 && correct >= total) await _bumpQuest('perfect');

    // Semanais
    await _bumpWeekly('w_missions');
    await _bumpWeekly('w_days', absolute: daysPlayedThisWeek);
    if (total > 0 && correct >= total) await _bumpWeekly('w_perfect');

    await _save();
    notifyListeners();
  }

  void clearGoalJustReached() {
    goalJustReached = false;
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    hasSeenOnboarding = value;
    await _save();
    notifyListeners();
  }

  Future<void> importProgress({
    required int steps,
    required int streak,
    required String? lastPlayedDate,
    required List<String> completedMissions,
    required int missionsToday,
    required String userName,
  }) async {
    this.steps = steps;
    this.streak = streak;
    this.lastPlayedDate = lastPlayedDate;
    this.completedMissions = completedMissions;
    this.missionsToday = missionsToday;
    this.userName = userName;
    await _save();
    notifyListeners();
  }

  /// Snapshot completo para Firebase (fonte da verdade).
  Map<String, dynamic> toCloudMap() {
    return {
      'version': 2,
      'userName': userName,
      'xp': steps,
      'steps': steps,
      'streak': streak,
      'lastPlayedDate': lastPlayedDate,
      'completedMissions': completedMissions,
      'missionsToday': missionsToday,
      'hasSeenOnboarding': hasSeenOnboarding,
      'weeklyXp': weeklySteps,
      'weeklySteps': weeklySteps,
      'lastWeekXp': lastWeekSteps,
      'lastWeekSteps': lastWeekSteps,
      'lastWeekKey': lastWeekKey,
      'weeklyWeek': weeklyWeek,
      'streakFreezeAvailable': streakFreezeAvailable,
      'streakFreezeWeek': streakFreezeWeek,
      'questDay': questDay,
      'questProgress': questProgressMap,
      'questClaimed': questClaimed,
      'weeklyProgress': weeklyProgressMap,
      'weeklyClaimed': weeklyClaimed,
      'claimedChests': claimedChests,
      'readBibleChapters': readBibleChapters,
      'bibleBookmarks': bibleBookmarks,
      'memoryScores': memoryScores,
      'memoryMastered': memoryMastered,
      'usedQuestionIds': usedQuestionIds,
      'mistakeQuestionIds': mistakeQuestionIds,
      'playDates': playDates,
      'trailDifficulties': trailDifficulties,
      'missionReflections': missionReflections,
      'settings': {
        'sound': settings.sound,
        'notifications': settings.notifications,
        'dailyGoal': settings.dailyGoal,
        'appearanceMode': settings.appearanceMode.storageKey,
      },
    };
  }

  static List<String> _asStringList(dynamic v) => [
        for (final e in (v as List? ?? const [])) e.toString(),
      ];

  static Map<String, int> _asIntMap(dynamic v) {
    if (v is! Map) return {};
    return v.map((k, val) => MapEntry(k.toString(), (val as num).toInt()));
  }

  static Map<String, String> _asStringMap(dynamic v) {
    if (v is! Map) return {};
    return v.map((k, val) => MapEntry(k.toString(), val.toString()));
  }

  /// Aplica documento da nuvem (v1 parcial ou v2 completo) e grava cache local.
  Future<void> applyFromCloud(Map<String, dynamic> data) async {
    final version = (data['version'] as num?)?.toInt() ?? 1;

    if (data.containsKey('xp') || data.containsKey('steps')) {
      steps = (data['steps'] as num?)?.toInt() ??
          (data['xp'] as num?)?.toInt() ??
          steps;
    }
    if (data.containsKey('streak')) {
      streak = (data['streak'] as num?)?.toInt() ?? streak;
    }
    if (data.containsKey('lastPlayedDate')) {
      lastPlayedDate = data['lastPlayedDate'] as String?;
    }
    if (data.containsKey('completedMissions')) {
      completedMissions = _asStringList(data['completedMissions']);
    }
    if (data.containsKey('missionsToday')) {
      missionsToday = (data['missionsToday'] as num?)?.toInt() ?? missionsToday;
    }
    if (data.containsKey('userName')) {
      final name = (data['userName'] as String?)?.trim();
      if (name != null && name.isNotEmpty) userName = name;
    }
    if (data.containsKey('weeklySteps') || data.containsKey('weeklyXp')) {
      weeklySteps = (data['weeklySteps'] as num?)?.toInt() ??
          (data['weeklyXp'] as num?)?.toInt() ??
          weeklySteps;
    }

    if (version >= 2) {
      if (data.containsKey('hasSeenOnboarding')) {
        hasSeenOnboarding = data['hasSeenOnboarding'] == true;
      }
      lastWeekSteps = (data['lastWeekSteps'] as num?)?.toInt() ??
          (data['lastWeekXp'] as num?)?.toInt() ??
          lastWeekSteps;
      lastWeekKey = data['lastWeekKey'] as String? ?? lastWeekKey;
      weeklyWeek = data['weeklyWeek'] as String? ?? weeklyWeek;
      streakFreezeAvailable =
          data['streakFreezeAvailable'] as bool? ?? streakFreezeAvailable;
      streakFreezeWeek =
          data['streakFreezeWeek'] as String? ?? streakFreezeWeek;
      questDay = data['questDay'] as String? ?? questDay;
      if (data.containsKey('questProgress')) {
        questProgressMap = _asIntMap(data['questProgress']);
      }
      if (data.containsKey('questClaimed')) {
        questClaimed = _asStringList(data['questClaimed']);
      }
      if (data.containsKey('weeklyProgress')) {
        weeklyProgressMap = _asIntMap(data['weeklyProgress']);
      }
      if (data.containsKey('weeklyClaimed')) {
        weeklyClaimed = _asStringList(data['weeklyClaimed']);
      }
      if (data.containsKey('claimedChests')) {
        claimedChests = _asStringList(data['claimedChests']);
      }
      if (data.containsKey('readBibleChapters')) {
        readBibleChapters = _asStringList(data['readBibleChapters']);
      }
      if (data.containsKey('bibleBookmarks')) {
        bibleBookmarks = _asStringList(data['bibleBookmarks']);
      }
      if (data.containsKey('memoryScores')) {
        memoryScores = _asIntMap(data['memoryScores']);
      }
      if (data.containsKey('memoryMastered')) {
        memoryMastered = _asStringList(data['memoryMastered']);
      }
      if (data.containsKey('usedQuestionIds')) {
        usedQuestionIds = _asStringList(data['usedQuestionIds']);
      }
      if (data.containsKey('mistakeQuestionIds')) {
        mistakeQuestionIds = _asStringList(data['mistakeQuestionIds']);
      }
      if (data.containsKey('playDates')) {
        playDates = _asStringList(data['playDates']);
      }
      if (data.containsKey('trailDifficulties')) {
        trailDifficulties = _asStringMap(data['trailDifficulties']);
      }
      if (data.containsKey('missionReflections')) {
        missionReflections = _asStringMap(data['missionReflections']);
      }
      final s = data['settings'];
      if (s is Map) {
        settings = AppSettings(
          sound: s['sound'] as bool? ?? settings.sound,
          notifications: s['notifications'] as bool? ?? settings.notifications,
          dailyGoal: (s['dailyGoal'] as num?)?.toInt() ?? settings.dailyGoal,
          appearanceMode: AppearanceModeX.fromStorage(
            s['appearanceMode'] as String?,
          ),
        );
      }
    }

    _ensureQuestDay();
    _ensureWeeklyWeek();
    await _save();
    notifyListeners();
  }

  bool isMissionCompleted(String slug) => completedMissions.contains(slug);

  Future<void> setHasSeenSplash(bool value) async {
    hasSeenSplash = value;
    await _save();
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    userName = name.trim().isEmpty ? 'Peregrino' : name.trim();
    await _save();
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    settings = newSettings;
    await _save();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    steps = 0;
    streak = 0;
    lastPlayedDate = null;
    completedMissions = [];
    missionsToday = 0;
    usedQuestionIds = [];
    mistakeQuestionIds = [];
    playDates = [];
    questProgressMap = {};
    questClaimed = [];
    weeklyProgressMap = {};
    weeklyClaimed = [];
    claimedChests = [];
    missionReflections = {};
    readBibleChapters = [];
    bibleBookmarks = [];
    memoryScores = {};
    memoryMastered = [];
    weeklySteps = 0;
    lastWeekSteps = 0;
    lastWeekKey = null;
    await _save();
    notifyListeners();
  }
}
