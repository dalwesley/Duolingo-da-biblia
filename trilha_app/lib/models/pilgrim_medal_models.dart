import 'caravan_pilgrim_profile.dart';
import '../services/progress_service.dart';
import '../widgets/cinematic_icon.dart';

enum PilgrimVaultKind { journey, trail, season, discovery }

enum PilgrimMedalFamily {
  word,
  formation,
  path,
  witness,
  memory,
  season,
  discovery,
}

/// Material da medalha — escada Ferro → Diamante; Mirra para raras.
enum PilgrimMedalTier {
  iron,
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  mirra,
}

/// Um degrau na escada de uma família/trilha.
class PilgrimMedalLevelDef {
  final String id;
  final PilgrimMedalTier tier;
  final String title;
  final String hint;
  final CinematicGlyph glyph;

  const PilgrimMedalLevelDef({
    required this.id,
    required this.tier,
    required this.title,
    required this.hint,
    required this.glyph,
  });
}

/// Emblema evolutivo — uma família (jornada) ou uma trilha.
class PilgrimMedalTrackDef {
  final String id;
  final String title;
  final String subtitle;
  final CinematicGlyph glyph;
  final PilgrimMedalFamily family;
  final PilgrimVaultKind kind;
  final String? trailSlug;
  final List<PilgrimMedalLevelDef> levels;

  const PilgrimMedalTrackDef({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.glyph,
    required this.family,
    required this.kind,
    this.trailSlug,
    required this.levels,
  });

  int get levelCount => levels.length;
}

/// Medalha rara (Mirra) — conquista única, não escada.
class PilgrimMedalDef {
  final String id;
  final String vaultId;
  final String title;
  final String hint;
  final CinematicGlyph glyph;
  final PilgrimMedalFamily family;
  final PilgrimMedalTier tier;
  final bool secret;
  final String? trailSlug;

  const PilgrimMedalDef({
    required this.id,
    required this.vaultId,
    required this.title,
    required this.hint,
    required this.glyph,
    required this.family,
    this.tier = PilgrimMedalTier.mirra,
    this.secret = true,
    this.trailSlug,
  });
}

class PilgrimVaultDef {
  final String id;
  final PilgrimVaultKind kind;
  final String title;
  final String? subtitle;
  final int order;
  final List<PilgrimMedalTrackDef> tracks;
  final List<PilgrimMedalDef> rareMedals;

  const PilgrimVaultDef({
    required this.id,
    required this.kind,
    required this.title,
    this.subtitle,
    this.order = 0,
    this.tracks = const [],
    this.rareMedals = const [],
  });

  int get totalLevels =>
      tracks.fold<int>(0, (sum, t) => sum + t.levelCount) + rareMedals.length;
}

class PilgrimTrackState {
  final PilgrimMedalTrackDef track;
  final int levelIndex;

  const PilgrimTrackState({
    required this.track,
    required this.levelIndex,
  });

  bool get hasStarted => levelIndex >= 0;

  bool get isComplete =>
      track.levels.isNotEmpty && levelIndex >= track.levels.length - 1;

  PilgrimMedalLevelDef? get currentLevel =>
      hasStarted ? track.levels[levelIndex] : null;

  PilgrimMedalLevelDef? get nextLevel {
    final next = levelIndex + 1;
    if (next < 0 || next >= track.levels.length) return null;
    return track.levels[next];
  }

  int get unlockedLevelCount => hasStarted ? levelIndex + 1 : 0;

  double get progress =>
      track.levels.isEmpty ? 0 : unlockedLevelCount / track.levels.length;
}

class PilgrimMedalStatus {
  final PilgrimMedalDef def;
  final bool unlocked;

  const PilgrimMedalStatus({required this.def, required this.unlocked});
}

/// Item unificado para exibição no grid do cofre.
class PilgrimMedalTile {
  final String id;
  final String title;
  final String hint;
  final CinematicGlyph glyph;
  final PilgrimMedalTier tier;
  final bool unlocked;
  final bool secret;
  final String? groupLabel;

  const PilgrimMedalTile({
    required this.id,
    required this.title,
    required this.hint,
    required this.glyph,
    required this.tier,
    required this.unlocked,
    this.secret = false,
    this.groupLabel,
  });

  factory PilgrimMedalTile.fromLevel({
    required PilgrimMedalTrackDef track,
    required PilgrimMedalLevelDef level,
    required bool unlocked,
  }) =>
      PilgrimMedalTile(
        id: level.id,
        title: level.title,
        hint: level.hint,
        glyph: level.glyph,
        tier: level.tier,
        unlocked: unlocked,
        groupLabel: track.title,
      );

  factory PilgrimMedalTile.fromRare(PilgrimMedalStatus status) =>
      PilgrimMedalTile(
        id: status.def.id,
        title: status.def.title,
        hint: status.def.hint,
        glyph: status.def.glyph,
        tier: status.def.tier,
        unlocked: status.unlocked,
        secret: status.def.secret,
      );
}

class PilgrimTrackTierUp {
  final PilgrimMedalTrackDef track;
  final PilgrimMedalLevelDef level;
  final int levelIndex;

  const PilgrimTrackTierUp({
    required this.track,
    required this.level,
    required this.levelIndex,
  });

  String get celebrationId => level.id;
}

class PilgrimVaultState {
  final PilgrimVaultDef vault;
  final List<PilgrimTrackState> tracks;
  final List<PilgrimMedalStatus> rareMedals;

  const PilgrimVaultState({
    required this.vault,
    this.tracks = const [],
    this.rareMedals = const [],
  });

  int get unlockedCount =>
      tracks.fold<int>(0, (sum, t) => sum + t.unlockedLevelCount) +
      rareMedals.where((m) => m.unlocked).length;

  int get total => vault.totalLevels;

  bool get isComplete => total > 0 && unlockedCount >= total;

  double get progress => total <= 0 ? 0 : unlockedCount / total;
}

class PilgrimMedalEvalContext {
  final List<String> playDates;
  final int reflectionCount;
  final String? firstOpenDate;
  final int? lastMissionCompletedAtMs;

  const PilgrimMedalEvalContext({
    this.playDates = const [],
    this.reflectionCount = 0,
    this.firstOpenDate,
    this.lastMissionCompletedAtMs,
  });

  factory PilgrimMedalEvalContext.fromProfile(CaravanPilgrimProfile profile) {
    return PilgrimMedalEvalContext(
      playDates: profile.playDates,
      reflectionCount: profile.reflectionCount,
      firstOpenDate: profile.firstOpenDate,
    );
  }

  factory PilgrimMedalEvalContext.fromProgress(ProgressService progress) {
    return PilgrimMedalEvalContext(
      playDates: List<String>.from(progress.playDates),
      reflectionCount: progress.missionReflections.length,
      firstOpenDate: progress.firstOpenDate,
    );
  }
}

class PilgrimTrackProximity {
  final PilgrimMedalTrackDef track;
  final PilgrimMedalLevelDef nextLevel;
  final String vaultTitle;
  final int current;
  final int target;
  final int remaining;
  final String unitLabel;

  const PilgrimTrackProximity({
    required this.track,
    required this.nextLevel,
    required this.vaultTitle,
    required this.current,
    required this.target,
    required this.remaining,
    required this.unitLabel,
  });

  String get message {
    final material = tierLabel(nextLevel.tier);
    if (remaining == 1) {
      return 'Falta 1 $unitLabel para $material em ${track.title}';
    }
    return 'Faltam $remaining $unitLabel para $material em ${track.title}';
  }

  String get shortMessage {
    final material = tierLabel(nextLevel.tier);
    if (remaining == 1) return 'Falta 1 para $material';
    return 'Faltam $remaining para $material';
  }
}

/// Compat: proximidade legada para raras (não usada).
class PilgrimMedalProximity {
  final PilgrimMedalDef def;
  final String vaultTitle;
  final int current;
  final int target;
  final int remaining;
  final String unitLabel;

  const PilgrimMedalProximity({
    required this.def,
    required this.vaultTitle,
    required this.current,
    required this.target,
    required this.remaining,
    required this.unitLabel,
  });

  String get message {
    final title = def.title;
    if (remaining == 1) return 'Falta 1 $unitLabel para «$title»';
    return 'Faltam $remaining $unitLabel para «$title»';
  }

  String get shortMessage {
    if (remaining == 1) return 'Falta 1 para «${def.title}»';
    return 'Faltam $remaining para «${def.title}»';
  }
}

String tierLabel(PilgrimMedalTier tier) => switch (tier) {
      PilgrimMedalTier.iron => 'Ferro',
      PilgrimMedalTier.bronze => 'Bronze',
      PilgrimMedalTier.silver => 'Prata',
      PilgrimMedalTier.gold => 'Ouro',
      PilgrimMedalTier.platinum => 'Platina',
      PilgrimMedalTier.diamond => 'Diamante',
      PilgrimMedalTier.mirra => 'Mirra',
    };
