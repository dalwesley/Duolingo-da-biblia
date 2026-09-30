import '../l10n/app_language.dart';
import '../l10n/l10n_global.dart';
import '../models/season_walk.dart';
import '../utils/liturgical_calendar.dart';

/// Playlists da Caminhada — só temporadas litúrgicas. Missões já no cânon.
class SeasonWalkCatalog {
  SeasonWalkCatalog._();

  static SeasonWalkDay _day(
    int i,
    String slug,
    String trail,
    String title,
    String insight,
  ) =>
      SeasonWalkDay(
        index: i,
        missionSlug: slug,
        trailSlug: trail,
        title: title,
        insight: insight,
      );

  static SeasonWalkCampaign advent2026(DateTime start) {
    final l = L10n.current;
    return SeasonWalkCampaign(
      id: 'advento-2026',
      kind: SeasonWalkKind.advent,
      title: l.seasonWalkAdvento2026Title,
      subtitle: l.seasonWalkAdvento2026Subtitle,
      start: DateTime(start.year, start.month, start.day),
      days: _adventDays(l),
    );
  }

  static List<SeasonWalkCampaign> all([DateTime? now]) {
    final day = now ?? DateTime.now();
    final adventStart = LiturgicalCalendar.adventStart(day.year);
    return [advent2026(adventStart)];
  }

  /// Campanha visível: janela ativa, senão a próxima.
  static SeasonWalkCampaign current([DateTime? now]) {
    final raw = now ?? DateTime.now();
    final day = DateTime(raw.year, raw.month, raw.day);
    final campaigns = all(day);
    for (final c in campaigns) {
      if (c.contains(day)) return c;
    }
    SeasonWalkCampaign? next;
    for (final c in campaigns) {
      if (c.start.isAfter(day) &&
          (next == null || c.start.isBefore(next.start))) {
        next = c;
      }
    }
    return next ?? campaigns.last;
  }

  static SeasonWalkAccess access({
    required SeasonWalkCampaign campaign,
    required int index,
    required DateTime today,
    required bool proConfigured,
    required bool isPro,
  }) {
    final item = campaign.dayAt(index);
    if (item == null) return SeasonWalkAccess.lockedFuture;
    final day = DateTime(today.year, today.month, today.day);
    final date = item.dateOn(campaign.start);
    if (date.isAfter(day)) return SeasonWalkAccess.lockedFuture;
    if (!campaign.isFreeDay(index) && proConfigured && !isPro) {
      return SeasonWalkAccess.lockedPro;
    }
    return SeasonWalkAccess.open;
  }

  static const _g = 'genesis-1-11';
  static const _g12 = 'genesis-12-50';
  static const _exo = 'exodo';
  static const _evg = 'evangelhos';
  static const _sm = 'sermao-do-monte';
  static const _or = 'oracao';
  static const _sl = 'salmos';
  static const _fp = 'filipenses';

  static List<SeasonWalkDay> _adventDays(AppLocalizations l) => [
        _day(1, 'evg-01-encarnacao', _evg, l.seasonWalkAdvento2026Day01Title,
            l.seasonWalkAdvento2026Day01Insight),
        _day(2, 'gen-01-criador', _g, l.seasonWalkAdvento2026Day02Title,
            l.seasonWalkAdvento2026Day02Insight),
        _day(3, 'gen-03-imagem', _g, l.seasonWalkAdvento2026Day03Title,
            l.seasonWalkAdvento2026Day03Insight),
        _day(4, 'gen12-01-chamado', _g12, l.seasonWalkAdvento2026Day04Title,
            l.seasonWalkAdvento2026Day04Insight),
        _day(5, 'gen12-04-alianca-estrelas', _g12,
            l.seasonWalkAdvento2026Day05Title,
            l.seasonWalkAdvento2026Day05Insight),
        _day(6, 'gen12-09-moria', _g12, l.seasonWalkAdvento2026Day06Title,
            l.seasonWalkAdvento2026Day06Insight),
        _day(7, 'exo-02-moises', _exo, l.seasonWalkAdvento2026Day07Title,
            l.seasonWalkAdvento2026Day07Insight),
        _day(8, 'exo-04-pascoa', _exo, l.seasonWalkAdvento2026Day08Title,
            l.seasonWalkAdvento2026Day08Insight),
        _day(9, 'sm-01-rei-no-monte', _sm, l.seasonWalkAdvento2026Day09Title,
            l.seasonWalkAdvento2026Day09Insight),
        _day(10, 'sm-02-pobres-de-espirito', _sm,
            l.seasonWalkAdvento2026Day10Title,
            l.seasonWalkAdvento2026Day10Insight),
        _day(11, 'sm-03-os-que-choram', _sm, l.seasonWalkAdvento2026Day11Title,
            l.seasonWalkAdvento2026Day11Insight),
        _day(12, 'sm-08-pacificadores', _sm, l.seasonWalkAdvento2026Day12Title,
            l.seasonWalkAdvento2026Day12Insight),
        _day(13, 'evg-02-batismo', _evg, l.seasonWalkAdvento2026Day13Title,
            l.seasonWalkAdvento2026Day13Insight),
        _day(14, 'evg-04-sermao', _evg, l.seasonWalkAdvento2026Day14Title,
            l.seasonWalkAdvento2026Day14Insight),
        _day(15, 'or-01-pai-nosso', _or, l.seasonWalkAdvento2026Day15Title,
            l.seasonWalkAdvento2026Day15Insight),
        _day(16, 'salmos-louvor-02-o-senhor-e-o-meu-pas', _sl,
            l.seasonWalkAdvento2026Day16Title,
            l.seasonWalkAdvento2026Day16Insight),
        _day(17, 'fp-02-humildade', _fp, l.seasonWalkAdvento2026Day17Title,
            l.seasonWalkAdvento2026Day17Insight),
        _day(18, 'evg-05-parabolas', _evg, l.seasonWalkAdvento2026Day18Title,
            l.seasonWalkAdvento2026Day18Insight),
        _day(19, 'evg-06-milagres', _evg, l.seasonWalkAdvento2026Day19Title,
            l.seasonWalkAdvento2026Day19Insight),
        _day(20, 'sm-21-tesouros-e-ansiedade', _sm,
            l.seasonWalkAdvento2026Day20Title,
            l.seasonWalkAdvento2026Day20Insight),
        _day(21, 'evg-07-ceia', _evg, l.seasonWalkAdvento2026Day21Title,
            l.seasonWalkAdvento2026Day21Insight),
        _day(22, 'evg-08-cruz', _evg, l.seasonWalkAdvento2026Day22Title,
            l.seasonWalkAdvento2026Day22Insight),
        _day(23, 'evg-09-ressurreicao', _evg, l.seasonWalkAdvento2026Day23Title,
            l.seasonWalkAdvento2026Day23Insight),
        _day(24, 'gen-04-descanso', _g, l.seasonWalkAdvento2026Day24Title,
            l.seasonWalkAdvento2026Day24Insight),
        _day(25, 'fp-01-alegria', _fp, l.seasonWalkAdvento2026Day25Title,
            l.seasonWalkAdvento2026Day25Insight),
        _day(26, 'sm-05-fome-e-sede-de-justica', _sm,
            l.seasonWalkAdvento2026Day26Title,
            l.seasonWalkAdvento2026Day26Insight),
      ];
}
