import '../l10n/l10n_global.dart';

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
  String get label {
    final l10n = L10n.current;
    return switch (this) {
      CaravanProfileSection.presence => l10n.profileSectionPresence,
      CaravanProfileSection.ranking => l10n.profileSectionRanking,
      CaravanProfileSection.daysAsLeader => l10n.profileSectionDaysOnTop,
      CaravanProfileSection.lastMission => l10n.profileSectionLastScene,
      CaravanProfileSection.accuracy => l10n.profileSectionAccuracy,
      CaravanProfileSection.bible => l10n.navBible,
      CaravanProfileSection.trails => l10n.navTrails,
      CaravanProfileSection.medals => l10n.profileSectionMedals,
    };
  }

  String get subtitle {
    final l10n = L10n.current;
    return switch (this) {
      CaravanProfileSection.presence => l10n.profileSectionPresenceHint,
      CaravanProfileSection.ranking => l10n.profileSectionRankingHint,
      CaravanProfileSection.daysAsLeader => l10n.profileSectionDaysOnTopHint,
      CaravanProfileSection.lastMission => l10n.profileSectionLastSceneHint,
      CaravanProfileSection.accuracy => l10n.profileSectionAccuracyHint,
      CaravanProfileSection.bible => l10n.profileSectionBibleHint,
      CaravanProfileSection.trails => l10n.profileSectionTrailsHint,
      CaravanProfileSection.medals => l10n.profileSectionMedalsHint,
    };
  }
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
