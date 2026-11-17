import 'season_walk.dart';
import 'study_room.dart';

/// Nível do prêmio do Advento. Vale o mais alto, nunca soma.
enum AdventTier {
  none,
  solo,
  pair,
  group;

  static AdventTier parse(Object? raw) => switch (raw) {
    'solo' => AdventTier.solo,
    'pair' => AdventTier.pair,
    'group' => AdventTier.group,
    _ => AdventTier.none,
  };
}

/// Regras do prêmio de uma campanha (espelha functions/advent.js).
/// `campaigns/{id}` no Firestore sobrescreve qualquer campo.
class AdventPrizeConfig {
  final String campaignId;

  /// Último instante que conta (24/12 23:59:59 de Brasília).
  final DateTime deadline;

  /// Fim do 1º dia: a foto das duplas e grupos.
  final DateTime rosterAt;
  final int soloMonths;
  final int pairMonths;
  final int groupMonths;
  final int groupMin;

  /// Dias atrasados se recuperam até tantas cenas por dia.
  final int maxPerDay;

  const AdventPrizeConfig({
    required this.campaignId,
    required this.deadline,
    required this.rosterAt,
    this.soloMonths = 1,
    this.pairMonths = 2,
    this.groupMonths = 3,
    this.groupMin = kRoomMinMembers,
    this.maxPerDay = 7,
  });

  /// Campanhas com prêmio. Advento 2026: 29/11 a 24/12.
  static final Map<String, AdventPrizeConfig> defaults = {
    'advento-2026': AdventPrizeConfig(
      campaignId: 'advento-2026',
      deadline: DateTime.utc(2026, 12, 25, 2, 59, 59),
      rosterAt: DateTime.utc(2026, 11, 30, 2, 59, 59),
    ),
  };

  static AdventPrizeConfig? forCampaign(String id) => defaults[id];

  int get maxMonths => groupMonths;

  int monthsFor(AdventTier tier) => switch (tier) {
    AdventTier.group => groupMonths,
    AdventTier.pair => pairMonths,
    AdventTier.solo => soloMonths,
    AdventTier.none => 0,
  };

  bool isOpen(DateTime now) => !now.toUtc().isAfter(deadline);

  AdventPrizeConfig merge(Map<String, dynamic>? o) {
    if (o == null) return this;
    int n(Object? v, int d) => v is num ? v.toInt() : d;
    DateTime t(Object? v, DateTime d) => v is num
        ? DateTime.fromMillisecondsSinceEpoch(v.toInt(), isUtc: true)
        : d;
    final months = o['months'] is Map
        ? Map<String, dynamic>.from(o['months'] as Map)
        : const <String, dynamic>{};
    final min = n(o['groupMin'], groupMin);
    return AdventPrizeConfig(
      campaignId: campaignId,
      deadline: t(o['deadlineMs'], deadline),
      rosterAt: t(o['rosterAtMs'], rosterAt),
      soloMonths: n(months['solo'], soloMonths),
      pairMonths: n(months['pair'], pairMonths),
      groupMonths: n(months['group'], groupMonths),
      groupMin: min < kRoomMinMembers ? kRoomMinMembers : min,
      maxPerDay: n(o['maxPerDay'], maxPerDay),
    );
  }

  /// Dia da campanha que esta cena prova hoje: o primeiro com a cena, já
  /// chegado e ainda sem prova. Null se a cena não é do Advento.
  static int? dayForScene(
    SeasonWalkCampaign campaign,
    String missionSlug,
    DateTime today, {
    Set<int> proven = const {},
  }) {
    final t = DateTime(today.year, today.month, today.day);
    int? fallback;
    for (final d in campaign.days) {
      if (d.missionSlug != missionSlug) continue;
      if (d.dateOn(campaign.start).isAfter(t)) continue;
      if (!proven.contains(d.index)) return d.index;
      fallback ??= d.index;
    }
    return fallback;
  }
}

/// O que o servidor já confirmou para esta pessoa.
class AdventPrizeState {
  final int confirmed;
  final Set<int> provenDays;
  final bool completed;
  final AdventTier tier;
  final int months;
  final bool inPair;
  final bool inGroup;

  const AdventPrizeState({
    this.confirmed = 0,
    this.provenDays = const {},
    this.completed = false,
    this.tier = AdventTier.none,
    this.months = 0,
    this.inPair = false,
    this.inGroup = false,
  });

  static const empty = AdventPrizeState();

  /// Nível que a pessoa pode alcançar pela foto do dia 1.
  AdventTier get reachable => inGroup
      ? AdventTier.group
      : inPair
      ? AdventTier.pair
      : AdventTier.solo;
}
