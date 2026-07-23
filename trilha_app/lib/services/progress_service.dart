import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_quest.dart';
import '../utils/appearance.dart';
import 'bible_service.dart';

class AppSettings {
  final bool sound;
  final bool notifications;
  final int dailyGoal;
  final AppearanceMode appearanceMode;
  final String bibleTranslationId;
  /// Escala tipográfica global do app (0.85–1.35).
  final double fontScale;

  const AppSettings({
    this.sound = true,
    this.notifications = true,
    this.dailyGoal = 1,
    this.appearanceMode = AppearanceMode.automatic,
    this.bibleTranslationId = BibleService.defaultTranslationId,
    this.fontScale = 1.0,
  });

  /// Compat: true quando o visual preferido é noturno.
  bool get darkMode => appearanceMode == AppearanceMode.night;

  AppSettings copyWith({
    bool? sound,
    bool? notifications,
    int? dailyGoal,
    AppearanceMode? appearanceMode,
    String? bibleTranslationId,
    double? fontScale,
  }) {
    return AppSettings(
      sound: sound ?? this.sound,
      notifications: notifications ?? this.notifications,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      appearanceMode: appearanceMode ?? this.appearanceMode,
      bibleTranslationId: bibleTranslationId ?? this.bibleTranslationId,
      fontScale: fontScale ?? this.fontScale,
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
  static const _keyBibleTranslation = 'bibleTranslationId';
  static const _keyFontScale = 'fontScale';
  /// Legado — migrado para [_keyFontScale].
  static const _keyBibleFontScale = 'bibleFontScale';
  static const _keyTrailDifficulty = 'trailDifficultyMap';
  static const _keyClearedTrailModes = 'clearedTrailModes';
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
  static const _keyMonthlySteps = 'monthlySteps';
  static const _keyMonthlyMonth = 'monthlyMonth';
  static const _keyReadBibleChapters = 'readBibleChapters';
  static const _keyBibleBookmarks = 'bibleBookmarks';
  static const _keySharedVerses = 'sharedVerses';
  static const _keyMemoryScores = 'memoryScores';
  static const _keyMemoryMastered = 'memoryMastered';

  static const maxLamps = 5;
  static const comebackBonusSteps = 15;
  static const minStreakForRepair = 3;

  /// Unidade do produto: passos (legado local/cloud ainda usa a chave `xp`).
  int steps = 0;
  int streak = 0;
  String? lastPlayedDate;
  List<String> completedMissions = [];
  int missionsToday = 0;
  bool hasSeenSplash = false;
  bool hasSeenOnboarding = false;
  String userName = 'Aprendiz';
  AppSettings settings = const AppSettings();
  Map<String, String> trailDifficulties = {};
  /// Modos (dificuldades) em que a trilha já foi concluída por completo.
  Map<String, List<String>> clearedTrailModes = {};
  List<String> usedQuestionIds = [];
  List<String> mistakeQuestionIds = [];
  List<String> playDates = [];
  bool streakFreezeAvailable = true;
  String? streakFreezeWeek;
  /// Dias cobertos pelo congelamento (aparecem com gelo na semana).
  List<String> frozenDates = [];
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

  /// Referências compartilhadas ("Lucas 1:1"), mais recentes primeiro.
  List<String> sharedVerses = [];

  /// Pontuação de memorização por id (0–5).
  Map<String, int> memoryScores = {};

  /// Versículos considerados firmes (score alto mantido).
  List<String> memoryMastered = [];

  /// Passos acumulados só nesta semana (comunidade / salas).
  int weeklySteps = 0;

  /// Passos finais da semana anterior.
  int lastWeekSteps = 0;
  String? lastWeekKey;

  /// Passos acumulados no mês atual (ranking mensal).
  int monthlySteps = 0;
  String? monthlyMonth;
  bool _loaded = false;

  /// True when daily goal was just crossed (UI one-shot).
  bool goalJustReached = false;

  /// Reparo de sequência: 1× por mês civil (após faltar exatamente 1 dia).
  bool streakRepairAvailable = true;
  String? streakRepairMonth;
  bool streakRepairPending = false;
  int brokenStreak = 0;

  /// Sheet de retorno — mostra no máx. 1× por dia civil.
  String? lastComebackShownDate;
  /// Bônus leve na 1ª missão após gap (ativado ao reconhecer o retorno).
  bool comebackBonusPending = false;

  bool get isLoaded => _loaded;

  String _todayKey() => DateTime.now().toIso8601String().substring(0, 10);

  String _yesterdayKey() {
    final d = DateTime.now().subtract(const Duration(days: 1));
    return d.toIso8601String().substring(0, 10);
  }

  String _dayAfterKey(String yyyyMmDd) {
    final parts = yyyyMmDd.split('-');
    final d = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    ).add(const Duration(days: 1));
    return d.toIso8601String().substring(0, 10);
  }

  String _weekKey() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    return start.toIso8601String().substring(0, 10);
  }

  String _weekMondayKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    final monday = DateTime(d.year, d.month, d.day)
        .subtract(Duration(days: d.weekday - 1));
    return monday.toIso8601String().substring(0, 10);
  }

  String _monthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<void> load() async {
    // Progresso vive no Firebase após o login. Cold start usa defaults em memória.
    // Splash visto: preferência de aparelho (não é progresso do usuário).
    final prefs = await SharedPreferences.getInstance();
    hasSeenSplash = prefs.getBool(_keyHasSeenSplash) ?? false;
    _loaded = true;
    notifyListeners();
  }

  /// Lê snapshot legado em SharedPreferences (migração única → nuvem).
  Future<Map<String, dynamic>?> readLegacyLocalSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final steps = prefs.getInt(_keySteps) ?? 0;
    final completed = prefs.getStringList(_keyCompleted) ?? const <String>[];
    final streak = prefs.getInt(_keyStreak) ?? 0;
    final name = prefs.getString(_keyUserName);
    final hasSeenOnboarding = prefs.getBool(_keyHasSeenOnboarding) ?? false;
    final hasAnything = steps > 0 ||
        completed.isNotEmpty ||
        streak > 0 ||
        hasSeenOnboarding ||
        (name != null &&
            name.isNotEmpty &&
            name != 'Aprendiz' &&
            name != 'Peregrino');
    if (!hasAnything) return null;

    AppearanceMode appearance = AppearanceMode.automatic;
    appearance = AppearanceModeX.fromStorage(
      prefs.getString(_keyAppearanceMode),
      legacyDarkMode: prefs.getBool(_keyDarkMode),
    );

    Map<String, String> diffs = {};
    final diffRaw = prefs.getString(_keyTrailDifficulty);
    if (diffRaw != null && diffRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(diffRaw) as Map<String, dynamic>;
        diffs = decoded.map((k, v) => MapEntry(k, v.toString()));
      } catch (_) {}
    }

    Map<String, List<String>> clearedModes = {};
    final clearedRaw = prefs.getString(_keyClearedTrailModes);
    if (clearedRaw != null && clearedRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(clearedRaw) as Map<String, dynamic>;
        clearedModes = decoded.map(
          (k, v) => MapEntry(
            k,
            [for (final e in (v as List? ?? const [])) e.toString()],
          ),
        );
      } catch (_) {}
    }

    Map<String, int> questProgress = {};
    final qp = prefs.getString(_keyQuestProgress);
    if (qp != null && qp.isNotEmpty) {
      try {
        final decoded = jsonDecode(qp) as Map<String, dynamic>;
        questProgress =
            decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      } catch (_) {}
    }

    Map<String, int> weeklyProgress = {};
    final wp = prefs.getString(_keyWeeklyProgress);
    if (wp != null && wp.isNotEmpty) {
      try {
        final decoded = jsonDecode(wp) as Map<String, dynamic>;
        weeklyProgress =
            decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      } catch (_) {}
    }

    Map<String, int> memScores = {};
    final memRaw = prefs.getString(_keyMemoryScores);
    if (memRaw != null && memRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(memRaw) as Map<String, dynamic>;
        memScores = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      } catch (_) {}
    }

    Map<String, String> reflections = {};
    final reflRaw = prefs.getString(_keyReflections);
    if (reflRaw != null && reflRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(reflRaw) as Map<String, dynamic>;
        reflections = decoded.map((k, v) => MapEntry(k, v.toString()));
      } catch (_) {}
    }

    return {
      'version': 2,
      'userName': name ?? 'Aprendiz',
      'xp': steps,
      'steps': steps,
      'streak': streak,
      'lastPlayedDate': prefs.getString(_keyLastPlayed),
      'completedMissions': completed,
      'missionsToday': prefs.getInt(_keyMissionsToday) ?? 0,
      'hasSeenOnboarding': hasSeenOnboarding,
      'weeklyXp': prefs.getInt(_keyWeeklySteps) ?? 0,
      'weeklySteps': prefs.getInt(_keyWeeklySteps) ?? 0,
      'lastWeekXp': prefs.getInt(_keyLastWeekSteps) ?? 0,
      'lastWeekSteps': prefs.getInt(_keyLastWeekSteps) ?? 0,
      'lastWeekKey': prefs.getString(_keyLastWeekKey),
      'weeklyWeek': prefs.getString(_keyWeeklyWeek),
      'monthlySteps': prefs.getInt(_keyMonthlySteps) ?? 0,
      'monthlyMonth': prefs.getString(_keyMonthlyMonth),
      'streakFreezeAvailable': prefs.getBool(_keyStreakFreeze) ?? true,
      'streakFreezeWeek': prefs.getString(_keyFreezeWeek),
      'questDay': prefs.getString(_keyQuestDay),
      'questProgress': questProgress,
      'questClaimed': prefs.getStringList(_keyQuestClaimed) ?? const <String>[],
      'weeklyProgress': weeklyProgress,
      'weeklyClaimed': prefs.getStringList(_keyWeeklyClaimed) ?? const <String>[],
      'claimedChests': prefs.getStringList(_keyClaimedChests) ?? const <String>[],
      'readBibleChapters':
          prefs.getStringList(_keyReadBibleChapters) ?? const <String>[],
      'bibleBookmarks':
          prefs.getStringList(_keyBibleBookmarks) ?? const <String>[],
      'sharedVerses':
          prefs.getStringList(_keySharedVerses) ?? const <String>[],
      'memoryScores': memScores,
      'memoryMastered':
          prefs.getStringList(_keyMemoryMastered) ?? const <String>[],
      'usedQuestionIds':
          prefs.getStringList(_keyUsedQuestions) ?? const <String>[],
      'mistakeQuestionIds':
          prefs.getStringList(_keyMistakeIds) ?? const <String>[],
      'playDates': prefs.getStringList(_keyPlayDates) ?? const <String>[],
      'trailDifficulties': diffs,
      'clearedTrailModes': clearedModes,
      'missionReflections': reflections,
      'settings': {
        'sound': prefs.getBool(_keySound) ?? true,
        'notifications': prefs.getBool(_keyNotifications) ?? true,
        'dailyGoal': prefs.getInt(_keyDailyGoal) ?? 1,
        'appearanceMode': appearance.storageKey,
        'bibleTranslationId': prefs.getString(_keyBibleTranslation) ??
            BibleService.defaultTranslationId,
        'fontScale': prefs.getDouble(_keyFontScale) ??
            prefs.getDouble(_keyBibleFontScale) ??
            1.0,
      },
    };
  }

  /// Remove chaves de progresso locais (após migrar/hidratar da nuvem).
  Future<void> clearLegacyLocalPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    const keys = [
      _keySteps,
      _keyStreak,
      _keyLastPlayed,
      _keyCompleted,
      _keyMissionsToday,
      _keyHasSeenOnboarding,
      _keyUserName,
      _keySound,
      _keyNotifications,
      _keyDailyGoal,
      _keyDarkMode,
      _keyAppearanceMode,
      _keyBibleTranslation,
      _keyFontScale,
      _keyBibleFontScale,
      _keyTrailDifficulty,
      _keyClearedTrailModes,
      _keyUsedQuestions,
      _keyMistakeIds,
      _keyPlayDates,
      _keyStreakFreeze,
      _keyFreezeWeek,
      _keyQuestDay,
      _keyQuestProgress,
      _keyQuestClaimed,
      _keyWeeklyWeek,
      _keyWeeklyProgress,
      _keyWeeklyClaimed,
      _keyClaimedChests,
      _keyReflections,
      _keyWeeklySteps,
      _keyLastWeekSteps,
      _keyLastWeekKey,
      _keyMonthlySteps,
      _keyMonthlyMonth,
      _keyReadBibleChapters,
      _keyBibleBookmarks,
      _keyMemoryScores,
      _keyMemoryMastered,
    ];
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Zera memória da sessão (logout) — não toca na nuvem.
  void resetMemoryToDefaults() {
    steps = 0;
    streak = 0;
    lastPlayedDate = null;
    completedMissions = [];
    missionsToday = 0;
    hasSeenOnboarding = false;
    userName = 'Aprendiz';
    settings = const AppSettings();
    trailDifficulties = {};
    clearedTrailModes = {};
    usedQuestionIds = [];
    mistakeQuestionIds = [];
    playDates = [];
    frozenDates = [];
    streakFreezeAvailable = true;
    streakFreezeWeek = null;
    questDay = null;
    questProgressMap = {};
    questClaimed = [];
    weeklyWeek = null;
    weeklyProgressMap = {};
    weeklyClaimed = [];
    claimedChests = [];
    missionReflections = {};
    readBibleChapters = [];
    bibleBookmarks = [];
    sharedVerses = [];
    memoryScores = {};
    memoryMastered = [];
    weeklySteps = 0;
    lastWeekSteps = 0;
    lastWeekKey = null;
    monthlySteps = 0;
    monthlyMonth = null;
    goalJustReached = false;
    streakRepairAvailable = true;
    streakRepairMonth = null;
    streakRepairPending = false;
    brokenStreak = 0;
    lastComebackShownDate = null;
    comebackBonusPending = false;
    notifyListeners();
  }

  /// Zera a meta do dia quando o calendário virou e ainda não houve passo hoje.
  void _ensureMissionsDay() {
    if (lastPlayedDate == _todayKey()) return;
    if (missionsToday == 0) return;
    missionsToday = 0;
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
    _ensureStreakFreezeWeek();
  }

  /// 1 congelamento por semana civil (estilo Duolingo).
  void _ensureStreakFreezeWeek() {
    final week = _weekMondayKey();
    if (streakFreezeAvailable) return;
    // Sem registro de consumo, ou consumo de outra semana → concede de novo.
    // Evita “Gelo usado” preso quando streakFreezeWeek veio null da nuvem.
    if (streakFreezeWeek == null || streakFreezeWeek != week) {
      streakFreezeAvailable = true;
    }
  }

  /// 1 reparo de sequência por mês civil.
  void _ensureStreakRepairMonth() {
    final month = _monthKey();
    if (streakRepairAvailable) return;
    if (streakRepairMonth == null || streakRepairMonth != month) {
      streakRepairAvailable = true;
    }
  }

  /// Faltou exatamente 1 dia civil (ontem sem passo, último jogo anteontem).
  bool get missedExactlyOneDay {
    if (lastPlayedDate == null) return false;
    return _dayAfterKey(lastPlayedDate!) == _yesterdayKey();
  }

  /// Dias civis desde o último passo (0 = hoje).
  int get daysSinceLastPlayed {
    if (lastPlayedDate == null) return 999;
    final parts = lastPlayedDate!.split('-');
    if (parts.length != 3) return 999;
    final last = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(last).inDays.clamp(0, 999);
  }

  void _ensureMonthlyMonth() {
    final month = _monthKey();
    if (monthlyMonth != month) {
      monthlyMonth = month;
      monthlySteps = 0;
    }
  }

  /// Soma passos totais + contadores semanal e mensal de uma vez.
  void _gainSteps(int amount) {
    _ensureWeeklyWeek();
    _ensureMonthlyMonth();
    steps += amount;
    weeklySteps += amount;
    monthlySteps += amount;
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

  /// Registra um versículo compartilhado (ex.: "Lucas 1:1"). Mais recente primeiro.
  Future<void> recordSharedVerse(String reference) async {
    final ref = reference.trim();
    if (ref.isEmpty) return;
    sharedVerses = [
      ref,
      for (final r in sharedVerses)
        if (r.toLowerCase() != ref.toLowerCase()) r,
    ];
    if (sharedVerses.length > 24) {
      sharedVerses = sharedVerses.sublist(0, 24);
    }
    await _save();
    notifyListeners();
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

  /// Persiste na nuvem via listeners (MainShell / saveNow). Sem disco local.
  bool _batching = false;

  @override
  void notifyListeners() {
    if (_batching) return;
    super.notifyListeners();
  }

  Future<void> _save({bool notify = true}) async {
    if (notify) notifyListeners();
  }

  /// Agrupa várias mutações num único [notifyListeners].
  Future<T> _batch<T>(Future<T> Function() fn) async {
    _batching = true;
    try {
      return await fn();
    } finally {
      _batching = false;
      super.notifyListeners();
    }
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

    _ensureStreakFreezeWeek();
    _ensureStreakRepairMonth();

    if (lastPlayedDate == _yesterdayKey()) {
      streak = streak + 1;
      streakRepairPending = false;
      brokenStreak = 0;
    } else if (lastPlayedDate != null && streakFreezeAvailable) {
      // Perdeu 1 dia — protege com congelamento.
      streakFreezeAvailable = false;
      streakFreezeWeek = _weekMondayKey();
      final gap = _dayAfterKey(lastPlayedDate!);
      if (gap != today && !frozenDates.contains(gap)) {
        frozenDates = [...frozenDates, gap];
        if (frozenDates.length > 30) {
          frozenDates = frozenDates.sublist(frozenDates.length - 30);
        }
      }
      streak = streak + 1; // continua a sequência após o dia protegido
      streakRepairPending = false;
      brokenStreak = 0;
    } else if (lastPlayedDate != null &&
        missedExactlyOneDay &&
        streak >= minStreakForRepair &&
        streakRepairAvailable) {
      // Sem gelo: oferece reparo 1×/mês em vez de zerar na cara.
      brokenStreak = streak;
      streakRepairPending = true;
      streak = 1;
    } else {
      streak = 1;
      streakRepairPending = false;
      brokenStreak = 0;
    }

    if (comebackBonusPending) {
      _gainSteps(comebackBonusSteps);
      comebackBonusPending = false;
    }

    lastPlayedDate = today;
    missionsToday = 0;
    if (!playDates.contains(today)) {
      playDates = [...playDates, today];
      if (playDates.length > 60) {
        playDates = playDates.sublist(playDates.length - 60);
      }
    }
  }

  bool playedOnDate(DateTime date) {
    final key = date.toIso8601String().substring(0, 10);
    return playDates.contains(key) || lastPlayedDate == key;
  }

  bool wasFrozenOnDate(DateTime date) {
    final key = date.toIso8601String().substring(0, 10);
    return frozenDates.contains(key);
  }

  /// De fato caminhou neste dia civil (não usa missionsToday residual de ontem).
  bool get walkedToday {
    _ensureMissionsDay();
    return lastPlayedDate == _todayKey();
  }

  bool get dailyGoalMet {
    _ensureMissionsDay();
    return walkedToday && missionsToday >= settings.dailyGoal;
  }

  /// Sequência viva, mas ainda sem passo hoje — risco de quebrar à meia-noite.
  bool get isStreakAtRisk {
    if (streak <= 0) return false;
    if (walkedToday) return false;
    return lastPlayedDate == _yesterdayKey();
  }

  /// Banner de urgência (a partir das 17h).
  bool get showStreakRiskBanner {
    if (!isStreakAtRisk) return false;
    return DateTime.now().hour >= 17;
  }

  /// Tempo restante até a sequência quebrar (meia-noite local).
  Duration get timeUntilStreakBreak {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  String get streakRiskCountdown {
    final d = timeUntilStreakBreak;
    if (d.isNegative) return '0min';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h <= 0) return '${m}min';
    return '${h}h ${m.toString().padLeft(2, '0')}min';
  }

  /// Congelamento disponível nesta semana.
  bool get hasStreakFreeze {
    _ensureStreakFreezeWeek();
    return streakFreezeAvailable;
  }

  /// Só é “usado” se consumiu de fato nesta semana (protegeu 1 falta).
  bool get streakFreezeUsedThisWeek {
    _ensureStreakFreezeWeek();
    return !streakFreezeAvailable && streakFreezeWeek == _weekMondayKey();
  }

  /// Ausente por mais de um dia (a graça não funciona como streak).
  bool get isReturningAfterGap {
    if (lastPlayedDate == null) return false;
    final today = _todayKey();
    if (lastPlayedDate == today || lastPlayedDate == _yesterdayKey()) {
      return false;
    }
    return true;
  }

  /// Mostrar sheet de retorno (no máx. 1× por dia).
  bool get shouldShowComeback {
    if (!isReturningAfterGap) return false;
    return lastComebackShownDate != _todayKey();
  }

  /// Oferta de reparo ativa após a missão que “reiniciou” a sequência.
  bool get showStreakRepairOffer =>
      streakRepairPending && brokenStreak >= minStreakForRepair;

  /// Marca o retorno como visto e agenda bônus na próxima missão do dia.
  Future<void> acknowledgeComeback() async {
    lastComebackShownDate = _todayKey();
    if (isReturningAfterGap && !walkedToday) {
      comebackBonusPending = true;
    }
    await _save();
  }

  /// Restaura a sequência quebrada (+ o dia de hoje). Consome o reparo do mês.
  Future<bool> claimStreakRepair() async {
    _ensureStreakRepairMonth();
    if (!streakRepairPending || brokenStreak < minStreakForRepair) return false;
    if (!walkedToday) return false;
    streak = brokenStreak + 1;
    streakRepairPending = false;
    streakRepairAvailable = false;
    streakRepairMonth = _monthKey();
    brokenStreak = 0;
    await _save();
    return true;
  }

  Future<void> dismissStreakRepair() async {
    if (!streakRepairPending) return;
    streakRepairPending = false;
    brokenStreak = 0;
    await _save();
  }

  String? difficultyForTrail(String trailSlug) => trailDifficulties[trailSlug];

  bool hasDifficultyForTrail(String trailSlug) => trailDifficulties.containsKey(trailSlug);

  Future<void> setTrailDifficulty(String trailSlug, String difficultyId) async {
    trailDifficulties = {...trailDifficulties, trailSlug: difficultyId};
    await _save();
    notifyListeners();
  }

  List<String> clearedModesFor(String trailSlug) =>
      List<String>.from(clearedTrailModes[trailSlug] ?? const []);

  bool hasClearedMode(String trailSlug, String difficultyId) =>
      clearedModesFor(trailSlug).contains(difficultyId);

  Future<void> markTrailModeCleared(String trailSlug, String difficultyId) async {
    final current = clearedModesFor(trailSlug);
    if (current.contains(difficultyId)) return;
    clearedTrailModes = {
      ...clearedTrailModes,
      trailSlug: [...current, difficultyId],
    };
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
    // Recompensa automática ao atingir a meta — sem “coletar”.
    if ((questProgressMap[id] ?? 0) >= q.target && !isQuestClaimed(id)) {
      questClaimed = [...questClaimed, id];
      _gainSteps(q.stepsReward);
    }
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
    if ((weeklyProgressMap[id] ?? 0) >= q.target && !isWeeklyQuestClaimed(id)) {
      weeklyClaimed = [...weeklyClaimed, id];
      _gainSteps(q.stepsReward);
    }
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

  /// Concede passos de missões já concluídas sem claim manual.
  Future<void> _autoClaimCompletedQuests() async {
    _ensureQuestDay();
    _ensureWeeklyWeek();
    var changed = false;
    for (final q in DailyQuestDefs.all) {
      if (isQuestClaimed(q.id)) continue;
      if (questProgress(q.id) < q.target) continue;
      questClaimed = [...questClaimed, q.id];
      _gainSteps(q.stepsReward);
      changed = true;
    }
    for (final q in WeeklyQuestDefs.all) {
      if (isWeeklyQuestClaimed(q.id)) continue;
      if (weeklyQuestProgress(q.id) < q.target) continue;
      weeklyClaimed = [...weeklyClaimed, q.id];
      _gainSteps(q.stepsReward);
      changed = true;
    }
    if (changed) await _save();
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
    await _batch(() async {
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

      final award =
          isReplay ? (rewardSteps * 0.35).round().clamp(5, rewardSteps) : rewardSteps;
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
    });
  }

  void clearGoalJustReached() {
    goalJustReached = false;
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    hasSeenOnboarding = value;
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
      'monthlySteps': monthlySteps,
      'monthlyMonth': monthlyMonth,
      'streakFreezeAvailable': streakFreezeAvailable,
      'streakFreezeWeek': streakFreezeWeek,
      'frozenDates': frozenDates,
      'streakRepairAvailable': streakRepairAvailable,
      'streakRepairMonth': streakRepairMonth,
      'streakRepairPending': streakRepairPending,
      'brokenStreak': brokenStreak,
      'lastComebackShownDate': lastComebackShownDate,
      'comebackBonusPending': comebackBonusPending,
      'questDay': questDay,
      'questProgress': questProgressMap,
      'questClaimed': questClaimed,
      'weeklyProgress': weeklyProgressMap,
      'weeklyClaimed': weeklyClaimed,
      'claimedChests': claimedChests,
      'readBibleChapters': readBibleChapters,
      'bibleBookmarks': bibleBookmarks,
      'sharedVerses': sharedVerses,
      'memoryScores': memoryScores,
      'memoryMastered': memoryMastered,
      'usedQuestionIds': usedQuestionIds,
      'mistakeQuestionIds': mistakeQuestionIds,
      'playDates': playDates,
      'trailDifficulties': trailDifficulties,
      'clearedTrailModes': clearedTrailModes,
      'missionReflections': missionReflections,
      'settings': {
        'sound': settings.sound,
        'notifications': settings.notifications,
        'dailyGoal': settings.dailyGoal,
        'appearanceMode': settings.appearanceMode.storageKey,
        'bibleTranslationId': settings.bibleTranslationId,
        'fontScale': settings.fontScale,
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

  static Map<String, List<String>> _asStringListMap(dynamic v) {
    if (v is! Map) return {};
    return v.map(
      (k, val) => MapEntry(
        k.toString(),
        [for (final e in (val as List? ?? const [])) e.toString()],
      ),
    );
  }

  /// Aplica documento da nuvem (v1 parcial ou v2 completo) na memória da sessão.
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
      monthlySteps =
          (data['monthlySteps'] as num?)?.toInt() ?? monthlySteps;
      monthlyMonth = data['monthlyMonth'] as String? ?? monthlyMonth;
      streakFreezeAvailable =
          data['streakFreezeAvailable'] as bool? ?? streakFreezeAvailable;
      streakFreezeWeek =
          data['streakFreezeWeek'] as String? ?? streakFreezeWeek;
      if (data.containsKey('frozenDates')) {
        frozenDates = _asStringList(data['frozenDates']);
      }
      streakRepairAvailable =
          data['streakRepairAvailable'] as bool? ?? streakRepairAvailable;
      streakRepairMonth =
          data['streakRepairMonth'] as String? ?? streakRepairMonth;
      streakRepairPending =
          data['streakRepairPending'] as bool? ?? streakRepairPending;
      brokenStreak =
          (data['brokenStreak'] as num?)?.toInt() ?? brokenStreak;
      lastComebackShownDate =
          data['lastComebackShownDate'] as String? ?? lastComebackShownDate;
      comebackBonusPending =
          data['comebackBonusPending'] as bool? ?? comebackBonusPending;
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
      if (data.containsKey('sharedVerses')) {
        sharedVerses = _asStringList(data['sharedVerses']);
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
      if (data.containsKey('clearedTrailModes')) {
        clearedTrailModes = _asStringListMap(data['clearedTrailModes']);
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
          bibleTranslationId:
              s['bibleTranslationId'] as String? ?? settings.bibleTranslationId,
          fontScale: ((s['fontScale'] as num?)?.toDouble() ??
                  (s['bibleFontScale'] as num?)?.toDouble() ??
                  settings.fontScale)
              .clamp(0.85, 1.35),
        );
      }
    }

    _ensureMissionsDay();
    _ensureQuestDay();
    _ensureWeeklyWeek();
    _ensureMonthlyMonth();
    // Repara gelo preso (false sem semana) e persiste se mudou.
    final freezeBefore = streakFreezeAvailable;
    _ensureStreakFreezeWeek();
    final repairBefore = streakRepairAvailable;
    _ensureStreakRepairMonth();
    await _autoClaimCompletedQuests();
    await BibleService.instance.setTranslation(settings.bibleTranslationId);
    _loaded = true;
    if (freezeBefore != streakFreezeAvailable ||
        repairBefore != streakRepairAvailable) {
      await _save();
    }
    notifyListeners();
  }

  bool isMissionCompleted(String slug) => completedMissions.contains(slug);

  Future<void> setHasSeenSplash(bool value) async {
    hasSeenSplash = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenSplash, value);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    userName = name.trim().isEmpty ? 'Aprendiz' : name.trim();
    await _save();
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    final translationChanged =
        newSettings.bibleTranslationId != settings.bibleTranslationId;
    settings = newSettings;
    if (translationChanged) {
      await BibleService.instance.setTranslation(settings.bibleTranslationId);
    }
    await _save();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    steps = 0;
    streak = 0;
    lastPlayedDate = null;
    completedMissions = [];
    missionsToday = 0;
    hasSeenOnboarding = false;
    usedQuestionIds = [];
    mistakeQuestionIds = [];
    playDates = [];
    frozenDates = [];
    streakFreezeAvailable = true;
    streakFreezeWeek = null;
    streakRepairAvailable = true;
    streakRepairMonth = null;
    streakRepairPending = false;
    brokenStreak = 0;
    lastComebackShownDate = null;
    comebackBonusPending = false;
    questProgressMap = {};
    questClaimed = [];
    weeklyProgressMap = {};
    weeklyClaimed = [];
    claimedChests = [];
    missionReflections = {};
    readBibleChapters = [];
    bibleBookmarks = [];
    sharedVerses = [];
    memoryScores = {};
    memoryMastered = [];
    weeklySteps = 0;
    lastWeekSteps = 0;
    lastWeekKey = null;
    monthlySteps = 0;
    monthlyMonth = _monthKey();
    await _save();
    notifyListeners();
  }
}
