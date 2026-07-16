import 'dart:math';
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

  String get verse => switch (this) {
        LeagueTier.semente => '“A semente é a palavra de Deus.” — Lc 8:11',
        LeagueTier.videira => '“Eu sou a videira, vós as varas.” — Jo 15:5',
        LeagueTier.oliveira => '“Sou como a oliveira verde na casa de Deus.” — Sl 52:8',
        LeagueTier.cedro => '“O justo crescerá como o cedro no Líbano.” — Sl 92:12',
        LeagueTier.estrela => '“Os que ensinam brilharão como as estrelas.” — Dn 12:3',
      };
}

/// Resultado da semana anterior, aguardando o usuário ver.
enum LeagueOutcome { promoted, stayed, demoted }

class LeagueEntry {
  final String name;
  final int steps;
  final bool isUser;

  const LeagueEntry({required this.name, required this.steps, this.isUser = false});
}

class _LeagueBot {
  final String name;

  /// XP que o bot terá ao fim da semana.
  final int weeklyTarget;

  /// Expoente do ritmo: <1 começa rápido, >1 acelera no fim.
  final double pace;

  const _LeagueBot(this.name, this.weeklyTarget, this.pace);
}

/// Caravana semanal: 19 companheiros determinísticos por semana + o
/// usuário, ranqueados por passos ganhos na semana. Sem backend — a mesma
/// semana gera sempre a mesma caravana.
class LeagueService extends ChangeNotifier {
  static const _keyTier = 'leagueTier';
  static const _keyProcessedWeek = 'leagueProcessedWeek';
  static const _keyOutcome = 'leaguePendingOutcome';
  static const _keyOutcomeRank = 'leaguePendingRank';

  static const groupSize = 20;
  static const promoteCount = 7;
  static const demoteCount = 5;
  static const promotionBonusXp = 50;

  static const _names = [
    'Ana Beatriz', 'Samuel R.', 'Débora', 'Lucas M.', 'Rebeca',
    'Ester L.', 'Davi Luiz', 'Joana P.', 'Miguel', 'Sarah C.',
    'Calebe', 'Isabela', 'Pedro H.', 'Lídia', 'Mateus V.',
    'Raquel S.', 'Tiago N.', 'Priscila', 'Elias J.', 'Marta',
    'Rute A.', 'Abner', 'Noemi', 'Otniel', 'Talita F.',
    'Bruno E.', 'Carol D.', 'Felipe G.', 'Vitória', 'Gabriel T.',
  ];

  int tierIndex = 0;
  LeagueOutcome? pendingOutcome;
  int pendingRank = 0;
  String? _processedWeek;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  LeagueTier get tier => LeagueTier.values[tierIndex];

  static String weekKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    final monday = DateTime(d.year, d.month, d.day)
        .subtract(Duration(days: d.weekday - 1));
    return monday.toIso8601String().substring(0, 10);
  }

  static DateTime _weekStart(String key) => DateTime.parse(key);

  /// Dias restantes até a caravana fechar (domingo inclui hoje).
  static int daysLeft([DateTime? now]) {
    final d = now ?? DateTime.now();
    return 8 - d.weekday;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    tierIndex = (prefs.getInt(_keyTier) ?? 0).clamp(0, LeagueTier.values.length - 1);
    _processedWeek = prefs.getString(_keyProcessedWeek);
    final rawOutcome = prefs.getString(_keyOutcome);
    if (rawOutcome != null) {
      for (final o in LeagueOutcome.values) {
        if (o.name == rawOutcome) pendingOutcome = o;
      }
      pendingRank = prefs.getInt(_keyOutcomeRank) ?? 0;
    }
    _loaded = true;
    notifyListeners();
  }

  /// Fecha a semana anterior se virou a semana. [lastWeekSteps] é o XP final do
  /// usuário na semana [lastWeekKey] (vindos do ProgressService).
  Future<void> settleWeekIfNeeded({
    required int lastWeekSteps,
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
    // XP do usuário na semana fechada (0 se o registro não bate).
    final userXp = (lastWeekKey == closedWeek) ? lastWeekSteps : 0;

    // Ranking final da semana fechada, com os mesmos bots daquela semana.
    final weekEnd = _weekStart(closedWeek).add(const Duration(days: 7));
    final bots = _botsForWeek(closedWeek, tierIndex);
    final finalXp = bots.map((b) => _botXpAt(b, closedWeek, weekEnd)).toList()
      ..add(userXp);
    finalXp.sort((a, b) => b.compareTo(a));
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

  /// Classificação atual da semana: usuário + jogadores reais da nuvem (se
  /// houver) + bots completando o grupo de 20, XP decrescente.
  List<LeagueEntry> standings({
    required String userName,
    required int userWeeklySteps,
    List<LeagueEntry> realPlayers = const [],
    DateTime? now,
  }) {
    final week = weekKey(now);
    final at = now ?? DateTime.now();
    final real = realPlayers.take(groupSize - 1).toList();
    final botsNeeded = groupSize - 1 - real.length;
    final bots = _botsForWeek(week, tierIndex).take(botsNeeded);
    final entries = [
      ...real,
      for (final b in bots)
        LeagueEntry(name: b.name, steps: _botXpAt(b, week, at)),
      LeagueEntry(name: userName, steps: userWeeklySteps, isUser: true),
    ]..sort((a, b) {
        if (b.steps != a.steps) return b.steps.compareTo(a.steps);
        // Empate: usuário fica na frente (gentileza de produto).
        if (a.isUser) return -1;
        if (b.isUser) return 1;
        return a.name.compareTo(b.name);
      });
    return entries;
  }

  int userRank(List<LeagueEntry> entries) =>
      entries.indexWhere((e) => e.isUser) + 1;

  // ---- Simulação determinística -------------------------------------------

  static int _seedFor(String week, int tier) =>
      week.hashCode ^ (tier * 0x9E3779B9);

  static List<_LeagueBot> _botsForWeek(String week, int tier) {
    final rng = Random(_seedFor(week, tier));
    final pool = [..._names]..shuffle(rng);
    final picked = pool.take(groupSize - 1).toList();
    final tierBoost = 1.0 + tier * 0.45;

    return List.generate(picked.length, (i) {
      // Distribuição: poucos muito ativos, maioria moderada, alguns quase parados.
      final roll = rng.nextDouble();
      final double target;
      if (roll < 0.15) {
        target = (420 + rng.nextInt(320)) * tierBoost; // grinders
      } else if (roll < 0.65) {
        target = (140 + rng.nextInt(220)) * tierBoost; // regulares
      } else {
        target = (25 + rng.nextInt(90)) * tierBoost; // casuais
      }
      final pace = 0.75 + rng.nextDouble() * 0.6;
      return _LeagueBot(picked[i], target.round(), pace);
    });
  }

  /// XP do bot em um instante da semana (curva de ritmo + variação diária).
  static int _botXpAt(_LeagueBot bot, String week, DateTime at) {
    final start = _weekStart(week);
    final total = const Duration(days: 7).inMinutes;
    final elapsed = at.difference(start).inMinutes.clamp(0, total);
    final fraction = elapsed / total;
    if (fraction <= 0) return 0;

    var xp = bot.weeklyTarget * pow(fraction, bot.pace);
    // Passos diários: bots "jogam" em blocos, não continuamente.
    final daySeed = Random(bot.name.hashCode ^ at.day);
    xp *= 0.92 + daySeed.nextDouble() * 0.08;
    return xp.round();
  }
}
