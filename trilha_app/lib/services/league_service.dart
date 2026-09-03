import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Divisões da caravana semanal — jornada coletiva, tema bíblico.
enum LeagueTier { semente, videira, oliveira, cedro, estrela }

extension LeagueTierX on LeagueTier {
  String get label => switch (this) {
        LeagueTier.semente => 'Caravana da Semente',
        LeagueTier.videira => 'Caravana da Videira',
        LeagueTier.oliveira => 'Caravana da Oliveira',
        LeagueTier.cedro => 'Caravana do Cedro',
        LeagueTier.estrela => 'Caravana da Estrela',
      };

  /// Nome curto para zonas do ranking.
  String get shortLabel => switch (this) {
        LeagueTier.semente => 'Semente',
        LeagueTier.videira => 'Videira',
        LeagueTier.oliveira => 'Oliveira',
        LeagueTier.cedro => 'Cedro',
        LeagueTier.estrela => 'Estrela',
      };
}

/// Resultado da semana anterior, aguardando o usuário ver.
enum LeagueOutcome { promoted, stayed, demoted }

/// Movimento da posição semanal desde o âncora do dia (ontem, ou a 1ª leitura de hoje).
enum RankDrift { up, down, stable }

class WeeklyRankTrend {
  final RankDrift drift;
  final int places;
  final int rank;
  final int baseline;

  const WeeklyRankTrend({
    required this.drift,
    required this.places,
    required this.rank,
    required this.baseline,
  });

  String get label => switch (drift) {
        RankDrift.up => places == 1
            ? 'Subiu 1 posição hoje'
            : 'Subiu $places posições hoje',
        RankDrift.down => places == 1
            ? 'Desceu 1 posição hoje'
            : 'Desceu $places posições hoje',
        RankDrift.stable => 'Posição estável hoje',
      };
}

/// Compara a posição atual com o âncora do dia. Semana nova zera.
class WeeklyRankSnapshot {
  String? weekKey;
  String? dateKey;
  int baseline = 0;
  int last = 0;
  bool anchoredFromPriorDay = false;

  WeeklyRankTrend? trendFor(int liveRank, {required String week}) {
    if (liveRank <= 0 || baseline <= 0) return null;
    if (weekKey != week) return null;
    final delta = baseline - liveRank;
    if (delta > 0) {
      return WeeklyRankTrend(
        drift: RankDrift.up,
        places: delta,
        rank: liveRank,
        baseline: baseline,
      );
    }
    if (delta < 0) {
      return WeeklyRankTrend(
        drift: RankDrift.down,
        places: -delta,
        rank: liveRank,
        baseline: baseline,
      );
    }
    if (!anchoredFromPriorDay) return null;
    return WeeklyRankTrend(
      drift: RankDrift.stable,
      places: 0,
      rank: liveRank,
      baseline: baseline,
    );
  }

  /// Atualiza o âncora. `true` se o estado mudou.
  bool observe(int rank, {required String week, required String today}) {
    if (rank <= 0) return false;

    if (weekKey != week) {
      weekKey = week;
      dateKey = today;
      baseline = rank;
      last = rank;
      anchoredFromPriorDay = false;
      return true;
    }

    if (dateKey != today) {
      baseline = last > 0 ? last : rank;
      last = rank;
      dateKey = today;
      anchoredFromPriorDay = true;
      return true;
    }

    if (last == rank) return false;
    last = rank;
    return true;
  }

  void clear() {
    weekKey = null;
    dateKey = null;
    baseline = 0;
    last = 0;
    anchoredFromPriorDay = false;
  }
}

enum LeaguePillKind { role, walk, online }

class LeagueMetaPill {
  final LeaguePillKind kind;
  final String label;
  final bool emphasis;

  const LeagueMetaPill({
    required this.kind,
    required this.label,
    this.emphasis = false,
  });
}

class LeagueEntry {
  final String? uid;
  final String name;
  final int steps;
  final bool isUser;
  /// Última caminhada (`YYYY-MM-DD`).
  final String? lastWalkDate;
  /// Último dia online (`YYYY-MM-DD`).
  final String? lastSeenDate;

  const LeagueEntry({
    this.uid,
    required this.name,
    required this.steps,
    this.isUser = false,
    this.lastWalkDate,
    this.lastSeenDate,
  });

  static String? formatShortBrDate(String? yyyyMmDd) {
    if (yyyyMmDd == null || yyyyMmDd.isEmpty) return null;
    final parts = yyyyMmDd.split('-');
    if (parts.length != 3) return null;
    return '${parts[2]}/${parts[1]}';
  }

  static String? formatBrDate(String? yyyyMmDd) {
    if (yyyyMmDd == null || yyyyMmDd.isEmpty) return null;
    final parts = yyyyMmDd.split('-');
    if (parts.length != 3) return null;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  bool get isOnlineToday => _daysSince(lastSeenDate) == 0;

  bool get walkedToday => _daysSince(lastWalkDate) == 0;

  int? get daysSinceActivity {
    final walk = _daysSince(lastWalkDate);
    final seen = _daysSince(lastSeenDate);
    if (walk == null && seen == null) return null;
    if (walk == null) return seen;
    if (seen == null) return walk;
    return walk < seen ? walk : seen;
  }

  /// Pílulas curtas para o card — papel, caminhada e presença.
  List<LeagueMetaPill> metaPills({int? rank}) {
    final pills = <LeagueMetaPill>[];

    if (rank != null && rank <= 3) {
      pills.add(
        LeagueMetaPill(
          kind: LeaguePillKind.role,
          label: switch (rank) {
            1 => 'Líder',
            2 => 'Vice',
            _ => 'Pódio',
          },
          emphasis: true,
        ),
      );
    }

    final walkBr = formatShortBrDate(lastWalkDate);
    final seenBr = formatShortBrDate(lastSeenDate);
    final walkedToday = this.walkedToday;
    final onlineToday = isOnlineToday;

    if (walkedToday) {
      pills.add(
        const LeagueMetaPill(
          kind: LeaguePillKind.walk,
          label: 'Caminhou hoje',
          emphasis: true,
        ),
      );
    } else if (walkBr != null) {
      pills.add(LeagueMetaPill(kind: LeaguePillKind.walk, label: walkBr));
    }

    if (onlineToday && !walkedToday) {
      pills.add(
        const LeagueMetaPill(
          kind: LeaguePillKind.online,
          label: 'Online',
          emphasis: true,
        ),
      );
    } else if (seenBr != null &&
        !onlineToday &&
        lastSeenDate != lastWalkDate) {
      pills.add(
        LeagueMetaPill(kind: LeaguePillKind.online, label: 'Online $seenBr'),
      );
    }

    return pills;
  }

  /// Uma linha curta para o card do ranking.
  String? get activitySummary {
    final walkDays = _daysSince(lastWalkDate);
    final seenDays = _daysSince(lastSeenDate);
    final walkBr = formatShortBrDate(lastWalkDate);
    final seenBr = formatShortBrDate(lastSeenDate);

    if (walkDays == null && seenDays == null) return null;

    final walkedToday = walkDays == 0;
    final onlineToday = seenDays == 0;

    if (walkedToday && onlineToday) return 'Ativo hoje';
    if (walkedToday) return 'Caminhou hoje';
    if (onlineToday && walkBr != null) return 'Online hoje · caminhou $walkBr';
    if (onlineToday) return 'Online hoje';
    if (walkBr != null && seenBr != null && lastWalkDate != lastSeenDate) {
      return 'Caminhou $walkBr · online $seenBr';
    }
    if (walkBr != null) return 'Caminhou $walkBr';
    if (seenBr != null) return 'Online $seenBr';
    return null;
  }

  String? get lastWalkLabel {
    final br = formatBrDate(lastWalkDate);
    return br != null ? 'Última caminhada $br' : null;
  }

  String? get lastOnlineLabel {
    if (lastSeenDate == null || lastSeenDate!.isEmpty) return null;
    if (_daysSince(lastSeenDate) == 0) return 'Online hoje';
    final br = formatBrDate(lastSeenDate);
    return br != null ? 'Online em $br' : null;
  }

  static int? _daysSince(String? yyyyMmDd) {
    if (yyyyMmDd == null || yyyyMmDd.isEmpty) return null;
    final parts = yyyyMmDd.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    final last = DateTime(y, m, d);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(last).inDays.clamp(0, 999);
  }
}

/// Caravana semanal: jogadores reais do Firestore + o usuário, ranqueados
/// por passos. Tier e settlement sincronizam em users/{uid}.
class LeagueService extends ChangeNotifier {
  static const _keyTier = 'leagueTier';
  static const _keyProcessedWeek = 'leagueProcessedWeek';
  static const _keyOutcome = 'leaguePendingOutcome';
  static const _keyOutcomeRank = 'leaguePendingRank';
  static const _keyTrendWeek = 'leagueTrendWeek';
  static const _keyTrendDate = 'leagueTrendDate';
  static const _keyTrendBaseline = 'leagueTrendBaseline';
  static const _keyTrendLast = 'leagueTrendLast';
  static const _keyTrendAnchored = 'leagueTrendAnchored';

  static const groupSize = 20;
  static const promoteCount = 7;
  static const demoteCount = 5;
  static const promotionBonusXp = 50;

  int tierIndex = 0;
  LeagueOutcome? pendingOutcome;
  int pendingRank = 0;
  String? _processedWeek;
  bool _loaded = false;
  bool _cloudHydrated = false;
  final WeeklyRankSnapshot _weeklyTrend = WeeklyRankSnapshot();

  bool get isLoaded => _loaded;
  LeagueTier get tier => LeagueTier.values[tierIndex];

  static String weekKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    final monday = DateTime(d.year, d.month, d.day)
        .subtract(Duration(days: d.weekday - 1));
    return monday.toIso8601String().substring(0, 10);
  }

  static String monthKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}';
  }

  /// Dias restantes até a caravana fechar (domingo inclui hoje).
  static int daysLeft([DateTime? now]) {
    final d = now ?? DateTime.now();
    return 8 - d.weekday;
  }

  /// Zona de descida (últimos [demoteCount]).
  bool isInDemotionZone(int rank) {
    if (tierIndex <= 0 || rank <= 0) return false;
    return rank > groupSize - demoteCount;
  }

  /// Perto da zona de descida (2 posições acima + a zona).
  bool isNearDemotion(int rank) {
    if (tierIndex <= 0 || rank <= 0) return false;
    return rank > groupSize - demoteCount - 2;
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _readTrend(prefs);
      // Cloud (hydrate) tem prioridade se ja chegou enquanto o prefs carregava.
      if (_cloudHydrated) return;
      tierIndex = (prefs.getInt(_keyTier) ?? 0).clamp(0, LeagueTier.values.length - 1);
      _processedWeek = prefs.getString(_keyProcessedWeek);
      final rawOutcome = prefs.getString(_keyOutcome);
      if (rawOutcome != null) {
        for (final o in LeagueOutcome.values) {
          if (o.name == rawOutcome) pendingOutcome = o;
        }
        pendingRank = prefs.getInt(_keyOutcomeRank) ?? 0;
      }
      if (_cloudHydrated) return;
    } catch (e) {
      debugPrint('LeagueService.init falhou: $e');
    } finally {
      // Nunca deixar a aba Caravana em spinner eterno.
      if (!_loaded && !_cloudHydrated) {
        _loaded = true;
        notifyListeners();
      }
    }
  }

  /// Campos persistidos em users/{uid} junto com o progresso.
  Map<String, dynamic> toCloudMap() {
    return {
      'leagueTier': tierIndex,
      'leagueProcessedWeek': _processedWeek,
      'leaguePendingOutcome': pendingOutcome?.name,
      'leaguePendingRank': pendingRank,
    };
  }

  /// Aplica estado da nuvem (fonte da verdade entre dispositivos).
  Future<void> applyFromCloud(Map<String, dynamic> data) async {
    if (data.containsKey('leagueTier')) {
      tierIndex = ((data['leagueTier'] as num?)?.toInt() ?? tierIndex)
          .clamp(0, LeagueTier.values.length - 1);
    }
    if (data.containsKey('leagueProcessedWeek')) {
      _processedWeek = data['leagueProcessedWeek'] as String? ?? _processedWeek;
    }
    if (data.containsKey('leaguePendingOutcome')) {
      final raw = data['leaguePendingOutcome'] as String?;
      pendingOutcome = null;
      if (raw != null) {
        for (final o in LeagueOutcome.values) {
          if (o.name == raw) pendingOutcome = o;
        }
      }
    }
    if (data.containsKey('leaguePendingRank')) {
      pendingRank = (data['leaguePendingRank'] as num?)?.toInt() ?? pendingRank;
    }
    _cloudHydrated = true;
    _loaded = true;
    await _persist();
    notifyListeners();
  }

  String? get processedWeek => _processedWeek;

  /// Fecha a semana anterior se virou a semana. [lastWeekSteps] é o XP final do
  /// usuário na semana [lastWeekKey] (vindos do ProgressService).
  /// [peerSteps] = XP dos outros jogadores reais daquela semana/tier.
  Future<void> settleWeekIfNeeded({
    required int lastWeekSteps,
    required String? lastWeekKey,
    List<int> peerSteps = const [],
  }) async {
    final current = weekKey();
    if (_processedWeek == current) return;

    // Primeira vez: só marca a semana atual, sem resultado.
    if (_processedWeek == null) {
      _processedWeek = current;
      await _persist();
      notifyListeners();
      return;
    }

    final closedWeek = _processedWeek!;
    // XP do usuário na semana fechada (0 se o registro não bate).
    final userXp = (lastWeekKey == closedWeek) ? lastWeekSteps : 0;

    final peer = peerSteps.take(groupSize - 1).toList();
    final finalXp = <int>[
      ...peer,
      userXp,
    ]..sort((a, b) => b.compareTo(a));
    final rank = finalXp.indexOf(userXp) + 1;

    var outcome = LeagueOutcome.stayed;
    if (rank <= promoteCount && tierIndex < LeagueTier.values.length - 1) {
      outcome = LeagueOutcome.promoted;
      tierIndex += 1;
    } else if (rank > groupSize - demoteCount && tierIndex > 0) {
      outcome = LeagueOutcome.demoted;
      tierIndex -= 1;
    }

    // Só mostra resultado se o usuário participou (jogou na semana fechada).
    pendingOutcome = userXp > 0 ? outcome : null;
    pendingRank = rank;
    _processedWeek = current;
    await _persist();
    notifyListeners();
  }

  Future<void> dismissOutcome() async {
    pendingOutcome = null;
    await _persist();
    notifyListeners();
  }

  /// Limpa estado local (logout / troca de conta).
  Future<void> resetForLogout() async {
    tierIndex = 0;
    pendingOutcome = null;
    pendingRank = 0;
    _processedWeek = null;
    _cloudHydrated = false;
    _loaded = true;
    _weeklyTrend.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTier);
    await prefs.remove(_keyProcessedWeek);
    await prefs.remove(_keyOutcome);
    await prefs.remove(_keyOutcomeRank);
    await prefs.remove(_keyTrendWeek);
    await prefs.remove(_keyTrendDate);
    await prefs.remove(_keyTrendBaseline);
    await prefs.remove(_keyTrendLast);
    await prefs.remove(_keyTrendAnchored);
    notifyListeners();
  }

  /// Posição na caravana semanal vs. o âncora do dia. Só para o próprio usuário.
  WeeklyRankTrend? weeklyTrendFor(int liveRank, {DateTime? now}) {
    final d = now ?? DateTime.now();
    return _weeklyTrend.trendFor(liveRank, week: weekKey(d));
  }

  /// Grava a posição atual. No 1º olhar da semana não há tendência.
  Future<WeeklyRankTrend?> observeWeeklyRank(int rank, {DateTime? now}) async {
    final d = now ?? DateTime.now();
    final changed = _weeklyTrend.observe(
      rank,
      week: weekKey(d),
      today: d.toIso8601String().substring(0, 10),
    );
    if (changed) {
      await _persistTrend();
      notifyListeners();
    }
    return weeklyTrendFor(rank, now: d);
  }

  void _readTrend(SharedPreferences prefs) {
    _weeklyTrend.weekKey = prefs.getString(_keyTrendWeek);
    _weeklyTrend.dateKey = prefs.getString(_keyTrendDate);
    _weeklyTrend.baseline = prefs.getInt(_keyTrendBaseline) ?? 0;
    _weeklyTrend.last = prefs.getInt(_keyTrendLast) ?? 0;
    _weeklyTrend.anchoredFromPriorDay =
        prefs.getBool(_keyTrendAnchored) ?? false;
  }

  Future<void> _persistTrend() async {
    final prefs = await SharedPreferences.getInstance();
    if (_weeklyTrend.weekKey == null) {
      await prefs.remove(_keyTrendWeek);
      await prefs.remove(_keyTrendDate);
      await prefs.remove(_keyTrendBaseline);
      await prefs.remove(_keyTrendLast);
      await prefs.remove(_keyTrendAnchored);
      return;
    }
    await prefs.setString(_keyTrendWeek, _weeklyTrend.weekKey!);
    if (_weeklyTrend.dateKey != null) {
      await prefs.setString(_keyTrendDate, _weeklyTrend.dateKey!);
    }
    await prefs.setInt(_keyTrendBaseline, _weeklyTrend.baseline);
    await prefs.setInt(_keyTrendLast, _weeklyTrend.last);
    await prefs.setBool(_keyTrendAnchored, _weeklyTrend.anchoredFromPriorDay);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTier, tierIndex);
    if (_processedWeek != null) {
      await prefs.setString(_keyProcessedWeek, _processedWeek!);
    }
    if (pendingOutcome != null) {
      await prefs.setString(_keyOutcome, pendingOutcome!.name);
      await prefs.setInt(_keyOutcomeRank, pendingRank);
    } else {
      await prefs.remove(_keyOutcome);
      await prefs.remove(_keyOutcomeRank);
    }
  }

  /// Classificação da semana: só jogadores reais da nuvem + o usuário.
  List<LeagueEntry> standings({
    required String userName,
    required int userWeeklySteps,
    String? userUid,
    String? userLastWalkDate,
    String? userLastSeenDate,
    List<LeagueEntry> realPlayers = const [],
  }) {
    final real = realPlayers.take(groupSize - 1).toList();
    final entries = [
      ...real,
      LeagueEntry(
        uid: userUid,
        name: userName,
        steps: userWeeklySteps,
        isUser: true,
        lastWalkDate: userLastWalkDate,
        lastSeenDate: userLastSeenDate,
      ),
    ]..sort(_compareEntries);
    return entries;
  }

  /// Classificação geral (passos totais). Só pessoas reais do Firebase.
  List<LeagueEntry> overallStandings({
    required String userName,
    required int userTotalSteps,
    String? userUid,
    String? userLastWalkDate,
    String? userLastSeenDate,
    List<LeagueEntry> realPlayers = const [],
  }) {
    final entries = [
      ...realPlayers,
      LeagueEntry(
        uid: userUid,
        name: userName,
        steps: userTotalSteps,
        isUser: true,
        lastWalkDate: userLastWalkDate,
        lastSeenDate: userLastSeenDate,
      ),
    ]..sort(_compareEntries);
    return entries;
  }

  int userRank(List<LeagueEntry> entries) =>
      entries.indexWhere((e) => e.isUser) + 1;

  static int _compareEntries(LeagueEntry a, LeagueEntry b) {
    if (b.steps != a.steps) return b.steps.compareTo(a.steps);
    // Empate: usuário fica na frente (gentileza de produto).
    if (a.isUser) return -1;
    if (b.isUser) return 1;
    return a.name.compareTo(b.name);
  }
}
