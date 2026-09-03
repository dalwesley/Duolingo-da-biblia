/// Seções do perfil público na caravana (bottom sheet ao tocar no ranking).
enum CaravanProfileSection {
  presence,
  ranking,
  daysAsLeader,
  lastMission,
  accuracy,
  bible,
  trails,
  medals,
}

extension CaravanProfileSectionX on CaravanProfileSection {
  String get label => switch (this) {
        CaravanProfileSection.presence => 'Presença',
        CaravanProfileSection.ranking => 'Ranking e passos',
        CaravanProfileSection.daysAsLeader => 'Dias no topo',
        CaravanProfileSection.lastMission => 'Última cena',
        CaravanProfileSection.accuracy => 'Taxa de acertos',
        CaravanProfileSection.bible => 'Bíblia',
        CaravanProfileSection.trails => 'Trilhas',
        CaravanProfileSection.medals => 'Medalhas',
      };

  String get subtitle => switch (this) {
        CaravanProfileSection.presence =>
          'Última caminhada, online e sequência',
        CaravanProfileSection.ranking => 'Posição e passos totais',
        CaravanProfileSection.daysAsLeader =>
          'Quantos dias ficou em 1º no ranking geral',
        CaravanProfileSection.lastMission =>
          'Última missão concluída com nome da cena',
        CaravanProfileSection.accuracy =>
          'Percentual de acertos nas cenas',
        CaravanProfileSection.bible => 'Livros e capítulos lidos',
        CaravanProfileSection.trails => 'Progresso nas trilhas',
        CaravanProfileSection.medals => 'Medalhas e conquistas da jornada',
      };
}

/// O que outros peregrinos veem ao tocar no seu card na caravana.
class CaravanProfilePrefs {
  final Map<CaravanProfileSection, bool> visibility;

  const CaravanProfilePrefs([Map<CaravanProfileSection, bool>? visibility])
      : visibility = visibility ?? const {};

  bool isVisible(CaravanProfileSection section) =>
      visibility[section] ?? true;

  CaravanProfilePrefs copyWithSection(
    CaravanProfileSection section,
    bool visible,
  ) {
    return CaravanProfilePrefs({
      ...{for (final s in CaravanProfileSection.values) s: isVisible(s)},
      section: visible,
    });
  }

  Map<String, dynamic> toMap() => {
        for (final s in CaravanProfileSection.values)
          s.name: isVisible(s),
      };

  factory CaravanProfilePrefs.fromMap(dynamic raw) {
    if (raw is! Map) return const CaravanProfilePrefs();
    final out = <CaravanProfileSection, bool>{};
    for (final s in CaravanProfileSection.values) {
      final v = raw[s.name];
      if (v is bool) out[s] = v;
    }
    return CaravanProfilePrefs(out);
  }

  bool shouldShow(CaravanProfileSection section, {required bool isOwner}) {
    if (isOwner) return true;
    return isVisible(section);
  }
}
