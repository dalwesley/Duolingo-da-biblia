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

  static SeasonWalkCampaign advent2026(DateTime start) => SeasonWalkCampaign(
        id: 'advento-2026',
        kind: SeasonWalkKind.advent,
        title: 'Advento 2026',
        subtitle: 'Espera do Verbo · um passo por dia',
        start: DateTime(start.year, start.month, start.day),
        days: _advent,
      );

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

  static final _advent = <SeasonWalkDay>[
    _day(1, 'evg-01-encarnacao', _evg, 'O Verbo se fez carne', 'Deus se aproximou'),
    _day(2, 'gen-01-criador', _g, 'No princípio', 'Deus é o centro, não eu'),
    _day(3, 'gen-03-imagem', _g, 'Imagem', 'Fomos feitos para refletir'),
    _day(4, 'gen12-01-chamado', _g12, 'Chamado', 'A fé anda quando Deus chama'),
    _day(5, 'gen12-04-alianca-estrelas', _g12, 'Estrelas', 'A promessa é maior que o medo'),
    _day(6, 'gen12-09-moria', _g12, 'Moriah', 'Deus proverá o cordeiro'),
    _day(7, 'exo-02-moises', _exo, 'Moisés', 'Deus levanta libertador'),
    _day(8, 'exo-04-pascoa', _exo, 'Páscoa', 'O sangue guarda a casa'),
    _day(9, 'sm-01-rei-no-monte', _sm, 'O Rei no monte', 'O Reino tem voz'),
    _day(10, 'sm-02-pobres-de-espirito', _sm, 'Pobres de espírito', 'O Reino cabe no vazio'),
    _day(11, 'sm-03-os-que-choram', _sm, 'Os que choram', 'Há conforto para quem chora'),
    _day(12, 'sm-08-pacificadores', _sm, 'Pacificadores', 'Shalom é missão'),
    _day(13, 'evg-02-batismo', _evg, 'Batismo', 'O céu se abre sobre o Filho'),
    _day(14, 'evg-04-sermao', _evg, 'Sermão', 'O monte ensina o Reino'),
    _day(15, 'or-01-pai-nosso', _or, 'Pai nosso', 'Orar é pedir o Reino'),
    _day(16, 'salmos-louvor-02-o-senhor-e-o-meu-pas', _sl, 'Meu pastor', 'Nada me faltará'),
    _day(17, 'fp-02-humildade', _fp, 'Humildade', 'Cristo desceu até a cruz'),
    _day(18, 'evg-05-parabolas', _evg, 'Parábolas', 'O Reino se escuta em história'),
    _day(19, 'evg-06-milagres', _evg, 'Milagres', 'O Reino toca o corpo'),
    _day(20, 'sm-21-tesouros-e-ansiedade', _sm, 'Ansiedade', 'O tesouro puxa o coração'),
    _day(21, 'evg-07-ceia', _evg, 'Ceia', 'O pão antecipa a entrega'),
    _day(22, 'evg-08-cruz', _evg, 'Cruz', 'O Rei reina pregado'),
    _day(23, 'evg-09-ressurreicao', _evg, 'Ressurreição', 'A espera não foi vã'),
    _day(24, 'gen-04-descanso', _g, 'Descanso', 'O sétimo dia é dádiva'),
    _day(25, 'fp-01-alegria', _fp, 'Alegria', 'Alegrai-vos no Senhor'),
    _day(26, 'sm-05-fome-e-sede-de-justica', _sm, 'Fome de justiça', 'Quem tem fome será farto'),
  ];
}
