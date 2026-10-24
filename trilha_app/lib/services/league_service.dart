import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n_global.dart';
import '../models/portrait_style.dart';

/// Níveis da caravana — sobem com semanas firmes, nunca descem.
enum LeagueTier { semente, videira, oliveira, cedro, estrela }

extension LeagueTierX on LeagueTier {
  String get label => switch (this) {
    LeagueTier.semente => L10n.current.leagueTierSemente,
    LeagueTier.videira => L10n.current.leagueTierVideira,
    LeagueTier.oliveira => L10n.current.leagueTierOliveira,
    LeagueTier.cedro => L10n.current.leagueTierCedro,
    LeagueTier.estrela => L10n.current.leagueTierEstrela,
  };

  /// Nome curto para zonas do ranking.
  String get shortLabel => label;
}

/// Resultado da semana anterior, aguardando o usuário ver.
enum LeagueOutcome { promoted }

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
  final String? photoUrl;
  final PortraitStyle portraitStyle;

  /// Passos de cenas novas nesta semana.
  final int weekSteps;

  /// Passos do mês no começo de hoje (`null` = sem passo hoje = [steps]).
  final int? dayStartSteps;

  const LeagueEntry({
    this.uid,
    required this.name,
    required this.steps,
    this.isUser = false,
    this.lastWalkDate,
    this.lastSeenDate,
    this.photoUrl,
    this.portraitStyle = PortraitStyle.photo,
    this.weekSteps = 0,
    this.dayStartSteps,
  });

  int get stepsAtDayStart => dayStartSteps ?? steps;

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
    final l = L10n.current;
    final pills = <LeagueMetaPill>[];

    if (rank != null && rank <= 3) {
      pills.add(
        LeagueMetaPill(
          kind: LeaguePillKind.role,
          label: switch (rank) {
            1 => l.leagueRoleLeader,
            2 => l.leagueRoleVice,
            _ => l.leagueRolePodium,
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
        LeagueMetaPill(
          kind: LeaguePillKind.walk,
          label: l.leagueWalkedToday,
          emphasis: true,
        ),
      );
    } else if (walkBr != null) {
      pills.add(LeagueMetaPill(kind: LeaguePillKind.walk, label: walkBr));
    }

    if (onlineToday && !walkedToday) {
      pills.add(
        LeagueMetaPill(
          kind: LeaguePillKind.online,
          label: l.leagueSeenToday,
          emphasis: true,
        ),
      );
    } else if (seenBr != null && !onlineToday && lastSeenDate != lastWalkDate) {
      pills.add(
        LeagueMetaPill(
          kind: LeaguePillKind.online,
          label: l.leagueSeenDate(seenBr),
        ),
      );
    }

    return pills;
  }

  /// Uma linha curta para o card do ranking.
  String? get activitySummary {
    final l = L10n.current;
    final walkDays = _daysSince(lastWalkDate);
    final seenDays = _daysSince(lastSeenDate);
    final walkBr = formatShortBrDate(lastWalkDate);
    final seenBr = formatShortBrDate(lastSeenDate);

    if (walkDays == null && seenDays == null) return null;

    final walkedToday = walkDays == 0;
    final onlineToday = seenDays == 0;

    if (walkedToday && onlineToday) return l.leagueActiveToday;
    if (walkedToday) return l.leagueWalkedToday;
    if (onlineToday && walkBr != null) {
      return l.leagueSeenTodayWalked(walkBr);
    }
    if (onlineToday) return l.leagueSeenToday;
    if (walkBr != null && seenBr != null && lastWalkDate != lastSeenDate) {
      return l.leagueWalkedSeen(walkBr, seenBr);
    }
    if (walkBr != null) return l.leagueWalkedDate(walkBr);
    if (seenBr != null) return l.leagueSeenDate(seenBr);
    return null;
  }

  String? get lastWalkLabel {
    final br = formatBrDate(lastWalkDate);
    return br != null ? L10n.current.leagueWalkedOn(br) : null;
  }

  String? get lastOnlineLabel {
    if (lastSeenDate == null || lastSeenDate!.isEmpty) return null;
    if (_daysSince(lastSeenDate) == 0) return L10n.current.leagueSeenToday;
    final br = formatBrDate(lastSeenDate);
    return br != null ? L10n.current.leagueSeenOn(br) : null;
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

/// Caravana: um ranking só, o do mês (jogadores reais do Firestore + o
/// usuário). O nível sobe com semanas firmes e sincroniza em users/{uid}.
class LeagueService extends ChangeNotifier {
  static const _keyTier = 'leagueTier';
  static const _keySteadyWeeks = 'leagueSteadyWeeks';
  static const _keyProcessedWeek = 'leagueProcessedWeek';
  static const _keyOutcome = 'leaguePendingOutcome';

  static const promotionBonusXp = 50;

  /// Cenas novas que firmam uma semana.
  static const steadyWeekScenes = 5;

  /// Semanas firmes (seguidas ou não) para subir um nível.
  static const steadyWeeksToRise = 3;

  static int get maxTierIndex => LeagueTier.values.length - 1;

  /// Outros peregrinos mínimos para o ranking ter tensão (você + 1).
  static const minPeerCount = 1;

  /// Campo competitivo: pelo menos [minPeerCount] par real.
  static bool fieldIsCompetitive(int peerCount) => peerCount >= minPeerCount;

  /// Peregrinos vistos hoje, na ordem do ranking (posição original).
  static List<({LeagueEntry entry, int rank})> onlineNow(
    List<LeagueEntry> entries,
  ) {
    return [
      for (var i = 0; i < entries.length; i++)
        if (entries[i].isOnlineToday) (entry: entries[i], rank: i + 1),
    ];
  }

  static String onlineCountLabel(int n) => L10n.current.leagueStudying(n);

  /// Posições ganhas hoje por linha de [sorted] (já ordenada pelo placar):
  /// compara com a ordem pelos passos do começo do dia. Só subida — quem
  /// ficou para trás não ganha seta.
  static List<int> placesUpToday(List<LeagueEntry> sorted) {
    final before = [...sorted]
      ..sort((a, b) => _compareBy(a, b, (e) => e.stepsAtDayStart));
    return [
      for (var i = 0; i < sorted.length; i++)
        (before.indexOf(sorted[i]) - i).clamp(0, sorted.length),
    ];
  }

  /// Fecha uma semana: [scenes] cenas novas nela. Puro, testável.
  static ({int tierIndex, int steadyWeeks, bool promoted}) settleSteadyWeek({
    required int scenes,
    required int tierIndex,
    required int steadyWeeks,
  }) {
    if (scenes < steadyWeekScenes || tierIndex >= maxTierIndex) {
      return (tierIndex: tierIndex, steadyWeeks: steadyWeeks, promoted: false);
    }
    final firm = steadyWeeks + 1;
    if (firm < steadyWeeksToRise) {
      return (tierIndex: tierIndex, steadyWeeks: firm, promoted: false);
    }
    return (tierIndex: tierIndex + 1, steadyWeeks: 0, promoted: true);
  }

  int tierIndex = 0;

  /// Semanas firmes acumuladas no nível atual (0…[steadyWeeksToRise] − 1).
  int steadyWeeks = 0;
  LeagueOutcome? pendingOutcome;
  String? _processedWeek;
  bool _loaded = false;
  bool _cloudHydrated = false;

  bool get isLoaded => _loaded;
  LeagueTier get tier => LeagueTier.values[tierIndex];
  bool get isMaxTier => tierIndex >= maxTierIndex;

  static String weekKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    final monday = DateTime(
      d.year,
      d.month,
      d.day,
    ).subtract(Duration(days: d.weekday - 1));
    return monday.toIso8601String().substring(0, 10);
  }

  static String monthKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}';
  }

  /// Dias restantes até a semana fechar (domingo inclui hoje).
  static int daysLeft([DateTime? now]) {
    final d = now ?? DateTime.now();
    return 8 - d.weekday;
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Cloud (hydrate) tem prioridade se ja chegou enquanto o prefs carregava.
      if (_cloudHydrated) return;
      tierIndex = (prefs.getInt(_keyTier) ?? 0).clamp(0, maxTierIndex);
      steadyWeeks = prefs.getInt(_keySteadyWeeks) ?? 0;
      _processedWeek = prefs.getString(_keyProcessedWeek);
      final rawOutcome = prefs.getString(_keyOutcome);
      if (rawOutcome != null) {
        for (final o in LeagueOutcome.values) {
          if (o.name == rawOutcome) pendingOutcome = o;
        }
      }
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
      'leagueSteadyWeeks': steadyWeeks,
      'leagueProcessedWeek': _processedWeek,
      'leaguePendingOutcome': pendingOutcome?.name,
    };
  }

  /// Aplica estado da nuvem (fonte da verdade entre dispositivos).
  Future<void> applyFromCloud(Map<String, dynamic> data) async {
    if (data.containsKey('leagueTier')) {
      tierIndex = ((data['leagueTier'] as num?)?.toInt() ?? tierIndex).clamp(
        0,
        maxTierIndex,
      );
    }
    if (data.containsKey('leagueSteadyWeeks')) {
      steadyWeeks = (data['leagueSteadyWeeks'] as num?)?.toInt() ?? steadyWeeks;
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
    _cloudHydrated = true;
    _loaded = true;
    await _persist();
    notifyListeners();
  }

  String? get processedWeek => _processedWeek;

  /// Fecha a semana anterior se virou a semana. [lastWeekScenes] são as
  /// cenas novas da semana [lastWeekKey] (vindas do ProgressService).
  Future<void> settleWeekIfNeeded({
    required int lastWeekScenes,
    required String? lastWeekKey,
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
    final settled = settleSteadyWeek(
      scenes: lastWeekKey == closedWeek ? lastWeekScenes : 0,
      tierIndex: tierIndex,
      steadyWeeks: steadyWeeks,
    );
    tierIndex = settled.tierIndex;
    steadyWeeks = settled.steadyWeeks;
    if (settled.promoted) pendingOutcome = LeagueOutcome.promoted;
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
    steadyWeeks = 0;
    pendingOutcome = null;
    _processedWeek = null;
    _cloudHydrated = false;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTier);
    await prefs.remove(_keySteadyWeeks);
    await prefs.remove(_keyProcessedWeek);
    await prefs.remove(_keyOutcome);
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTier, tierIndex);
    await prefs.setInt(_keySteadyWeeks, steadyWeeks);
    if (_processedWeek != null) {
      await prefs.setString(_keyProcessedWeek, _processedWeek!);
    }
    if (pendingOutcome != null) {
      await prefs.setString(_keyOutcome, pendingOutcome!.name);
    } else {
      await prefs.remove(_keyOutcome);
    }
  }

  /// Classificação do mês. Só pessoas reais do Firebase + o usuário.
  List<LeagueEntry> monthStandings({
    required String userName,
    required int userMonthSteps,
    required int userWeekSteps,
    required int userDayStartSteps,
    String? userUid,
    String? userLastWalkDate,
    String? userLastSeenDate,
    String? userPhotoUrl,
    PortraitStyle userPortraitStyle = PortraitStyle.photo,
    List<LeagueEntry> realPlayers = const [],
  }) {
    final entries = [
      ...realPlayers,
      LeagueEntry(
        uid: userUid,
        name: userName,
        steps: userMonthSteps,
        isUser: true,
        lastWalkDate: userLastWalkDate,
        lastSeenDate: userLastSeenDate,
        photoUrl: userPhotoUrl,
        portraitStyle: userPortraitStyle,
        weekSteps: userWeekSteps,
        dayStartSteps: userDayStartSteps,
      ),
    ]..sort(_compareEntries);
    return entries;
  }

  int userRank(List<LeagueEntry> entries) =>
      entries.indexWhere((e) => e.isUser) + 1;

  static int _compareEntries(LeagueEntry a, LeagueEntry b) =>
      _compareBy(a, b, (e) => e.steps);

  static int _compareBy(
    LeagueEntry a,
    LeagueEntry b,
    int Function(LeagueEntry) score,
  ) {
    final sa = score(a);
    final sb = score(b);
    if (sb != sa) return sb.compareTo(sa);
    // Empate: usuário fica na frente (gentileza de produto).
    if (a.isUser) return -1;
    if (b.isUser) return 1;
    return a.name.compareTo(b.name);
  }
}
