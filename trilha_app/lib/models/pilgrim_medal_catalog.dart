import '../l10n/l10n_global.dart';
import '../models/trail.dart';
import '../utils/liturgical_calendar.dart';
import '../widgets/cinematic_icon.dart';
import 'pilgrim_medal_models.dart';

/// Catálogo v3.2 — faísca + conquistas; Palavra mede hábito, não título bíblico.
class PilgrimMedalCatalog {
  PilgrimMedalCatalog._();

  static const journeyVaultId = 'journey';
  static const discoveryVaultId = 'discovery';
  static const advent2026VaultId = 'season:advento-2026';
  static const advent2026TrackId = 'track:season:advento-2026';

  static const trackWordId = 'track:word';
  static const trackFormationId = 'track:formation';
  static const trackPathId = 'track:path';
  static const trackWitnessId = 'track:witness';
  static const trackMemoryId = 'track:memory';

  static String trailTrackId(String slug) => 'track:trail:$slug';

  static String levelId(String trackId, int index) => '$trackId:$index';

  static const v1ToV2Ids = <String, String>{
    'word_first_chapter': 'journey:word:first_chapter',
    'word_chapters_25': 'journey:word:chapters_25',
    'word_book': 'journey:word:book',
    'word_gospel': 'journey:word:gospel',
    'word_nt_book': 'journey:word:nt_book',
    'form_first_perfect': 'journey:form:first_perfect',
    'form_perfect_5': 'journey:form:perfect_5',
    'form_perfect_25': 'journey:form:perfect_25',
    'form_accuracy': 'journey:form:accuracy',
    'path_streak_7': 'journey:path:streak_7',
    'path_streak_30': 'journey:path:streak_30',
    'path_leader': 'journey:path:leader',
    'witness_share_1': 'journey:witness:share_1',
    'witness_share_10': 'journey:witness:share_10',
    'memory_5': 'journey:memory:5',
    'memory_20': 'journey:memory:20',
    'discovery:perfect_boss': 'discovery:perfect_boss',
    'discovery:reflection': 'discovery:reflection_deep',
  };

  /// Ids semânticos atuais (e raras) a partir de ids v2.
  static const v2ToSemantic = <String, String>{
    'journey:word:first_chapter': 'track:word:chapters_1',
    'journey:word:chapters_25': 'track:word:chapters_25',
    'journey:word:book': 'track:word:chapters_25',
    'journey:word:gospel': 'track:word:chapters_25',
    'journey:word:nt_book': 'track:word:chapters_1',
    'journey:form:first_perfect': 'track:formation:perfect_1',
    'journey:form:perfect_5': 'track:formation:perfect_1',
    'journey:form:perfect_25': 'track:formation:perfect_25',
    'journey:form:accuracy': 'discovery:andando_na_luz',
    'journey:form:perfect_boss': 'discovery:perfect_boss',
    'journey:path:streak_7': 'track:path:streak_3',
    'journey:path:streak_30': 'track:path:streak_30',
    'journey:path:leader': 'discovery:leader',
    'journey:witness:share_1': 'track:witness:share_1',
    'journey:witness:share_10': 'track:witness:share_10',
    'journey:memory:5': 'track:memory:verse_1',
    'journey:memory:20': 'track:memory:verse_15',
  };

  /// Índices numéricos v3 (pré-v3.1) → id semântico. O significado antigo
  /// (não o novo índice) é o que importa na migração.
  static const legacyNumericToSemantic = <String, String>{
    'track:word:0': 'track:word:chapters_1',
    'track:word:1': 'track:word:chapters_25',
    'track:word:2': 'track:word:chapters_25',
    'track:word:3': 'track:word:chapters_25',
    'track:word:4': 'track:word:chapters_1',
    'track:word:5': 'track:word:chapters_1',
    'track:formation:0': 'track:formation:perfect_1',
    'track:formation:1': 'track:formation:perfect_1',
    'track:formation:2': 'track:formation:perfect_25',
    'track:formation:3': 'discovery:andando_na_luz',
    'track:formation:4': 'discovery:perfect_boss',
    'track:path:0': 'track:path:streak_3',
    'track:path:1': 'track:path:streak_3',
    'track:path:2': 'track:path:streak_3',
    'track:path:3': 'track:path:streak_30',
    'track:path:4': 'track:path:streak_90',
    'track:path:5': 'discovery:leader',
    'track:witness:0': 'track:witness:share_1',
    'track:witness:1': 'track:witness:share_10',
    'track:witness:2': 'track:witness:share_10',
    'track:witness:3': 'track:witness:share_50',
    'track:memory:0': 'track:memory:verse_1',
    'track:memory:1': 'track:memory:verse_15',
    'track:memory:2': 'track:memory:verse_15',
    'track:memory:3': 'track:memory:verse_50',
  };

  /// Degraus aposentados (v3.1) → o que ainda existe.
  static const retiredToCurrent = <String, String>{
    'track:word:chapters_7': 'track:word:chapters_1',
    'track:word:book': 'track:word:chapters_25',
    'track:word:gospel': 'track:word:chapters_25',
    'discovery:word_ot': 'track:word:chapters_1',
    'discovery:word_nt': 'track:word:chapters_1',
    'track:formation:perfect_5': 'track:formation:perfect_1',
    'track:path:streak_7': 'track:path:streak_3',
    'track:path:streak_90': 'track:path:streak_30',
    'track:witness:share_3': 'track:witness:share_1',
    'track:witness:share_25': 'track:witness:share_10',
    'track:memory:verse_5': 'track:memory:verse_1',
    'track:memory:verse_30': 'track:memory:verse_15',
  };

  static String migrateMedalId(String id) => v1ToV2Ids[id] ?? id;

  static Iterable<String> migrateMedalIds(Iterable<String> ids) =>
      ids.map(migrateMedalId);

  /// Expande ids celebrados (v1/v2/v3 numérico/v3.1) para o prefixo atual.
  static Set<String> expandCelebratedIds(Iterable<String> ids) {
    final result = <String>{};
    for (final raw in ids) {
      final migrated = migrateMedalId(raw);
      if (migrated.startsWith('trail:') &&
          (migrated.contains(':first_step') ||
              migrated.contains(':semente') ||
              migrated.contains(':caminhada') ||
              migrated.contains(':peregrino'))) {
        final slug = _trailSlugFromV2MedalId(migrated);
        if (slug != null) {
          final idx = _v2TrailMedalLevelIndex(migrated);
          if (idx != null) {
            _addTrailLevelsUpTo(result, slug, idx);
            continue;
          }
        }
      }
      var semantic = v2ToSemantic[migrated] ??
          legacyNumericToSemantic[migrated] ??
          migrated;
      semantic = retiredToCurrent[semantic] ?? semantic;
      _addPrefixThrough(result, semantic);
    }
    return result;
  }

  static void _addTrailLevelsUpTo(Set<String> out, String slug, int maxIndex) {
    final trackId = trailTrackId(slug);
    for (var i = 0; i <= maxIndex; i++) {
      out.add(levelId(trackId, i));
    }
  }

  static void _addPrefixThrough(Set<String> out, String levelOrRareId) {
    for (final track in [
      ...journeyTracks,
      adventTrack(2026),
    ]) {
      final idx = track.levels.indexWhere((l) => l.id == levelOrRareId);
      if (idx >= 0) {
        for (var i = 0; i <= idx; i++) {
          out.add(track.levels[i].id);
        }
        return;
      }
    }
    out.add(levelOrRareId);
  }

  static String? _trailSlugFromV2MedalId(String id) {
    final match = RegExp(r'^trail:([^:]+):').firstMatch(id);
    return match?.group(1);
  }

  static int? _v2TrailMedalLevelIndex(String id) {
    if (id.endsWith(':first_step')) return 0;
    if (id.endsWith(':semente')) return 1;
    if (id.endsWith(':caminhada')) return 2;
    if (id.endsWith(':peregrino')) return 3;
    return null;
  }

  static List<PilgrimMedalTrackDef> get journeyTracks => [
    PilgrimMedalTrackDef(
      id: trackWordId,
      title: L10n.current.medalTrackWordTitle,
      subtitle: L10n.current.medalTrackWordSubtitle,
      glyph: CinematicGlyph.book,
      family: PilgrimMedalFamily.word,
      kind: PilgrimVaultKind.journey,
      levels: [
        PilgrimMedalLevelDef(
          id: 'track:word:chapters_1',
          tier: PilgrimMedalTier.bronze,
          title: L10n.current.medalWordChapters1Title,
          hint: L10n.current.medalHintReadChapters(1),
          glyph: CinematicGlyph.spark,
          rung: PilgrimMedalRung.spark,
        ),
        PilgrimMedalLevelDef(
          id: 'track:word:chapters_25',
          tier: PilgrimMedalTier.silver,
          title: L10n.current.medalWordChapters25Title,
          hint: L10n.current.medalHintReadChapters(25),
          glyph: CinematicGlyph.scroll,
        ),
        PilgrimMedalLevelDef(
          id: 'track:word:chapters_100',
          tier: PilgrimMedalTier.gold,
          title: L10n.current.medalWordChapters100Title,
          hint: L10n.current.medalHintReadChapters(100),
          glyph: CinematicGlyph.book,
        ),
      ],
    ),
    PilgrimMedalTrackDef(
      id: trackFormationId,
      title: L10n.current.medalTrackFormationTitle,
      subtitle: L10n.current.medalTrackFormationSubtitle,
      glyph: CinematicGlyph.lamp,
      family: PilgrimMedalFamily.formation,
      kind: PilgrimVaultKind.journey,
      levels: [
        PilgrimMedalLevelDef(
          id: 'track:formation:perfect_1',
          tier: PilgrimMedalTier.bronze,
          title: L10n.current.medalFormationPerfect1Title,
          hint: L10n.current.medalHintPerfectScenes(1),
          glyph: CinematicGlyph.check,
          rung: PilgrimMedalRung.spark,
        ),
        PilgrimMedalLevelDef(
          id: 'track:formation:perfect_10',
          tier: PilgrimMedalTier.silver,
          title: L10n.current.medalFormationPerfect10Title,
          hint: L10n.current.medalHintPerfectScenes(10),
          glyph: CinematicGlyph.target,
        ),
        PilgrimMedalLevelDef(
          id: 'track:formation:perfect_25',
          tier: PilgrimMedalTier.gold,
          title: L10n.current.medalFormationPerfect25Title,
          hint: L10n.current.medalFormationPerfect25Hint,
          glyph: CinematicGlyph.lamp,
        ),
      ],
    ),
    PilgrimMedalTrackDef(
      id: trackPathId,
      title: L10n.current.medalTrackPathTitle,
      subtitle: L10n.current.medalTrackPathSubtitle,
      glyph: CinematicGlyph.flame,
      family: PilgrimMedalFamily.path,
      kind: PilgrimVaultKind.journey,
      levels: [
        PilgrimMedalLevelDef(
          id: 'track:path:streak_3',
          tier: PilgrimMedalTier.bronze,
          title: L10n.current.medalPathStreak3Title,
          hint: L10n.current.medalHintStreak(3),
          glyph: CinematicGlyph.spark,
          rung: PilgrimMedalRung.spark,
        ),
        PilgrimMedalLevelDef(
          id: 'track:path:streak_14',
          tier: PilgrimMedalTier.silver,
          title: L10n.current.medalPathStreak14Title,
          hint: L10n.current.medalHintStreak(14),
          glyph: CinematicGlyph.rise,
        ),
        PilgrimMedalLevelDef(
          id: 'track:path:streak_30',
          tier: PilgrimMedalTier.gold,
          title: L10n.current.medalPathStreak30Title,
          hint: L10n.current.medalHintStreak(30),
          glyph: CinematicGlyph.flame,
        ),
      ],
    ),
    PilgrimMedalTrackDef(
      id: trackWitnessId,
      title: L10n.current.medalTrackWitnessTitle,
      subtitle: L10n.current.medalTrackWitnessSubtitle,
      glyph: CinematicGlyph.share,
      family: PilgrimMedalFamily.witness,
      kind: PilgrimVaultKind.journey,
      levels: [
        PilgrimMedalLevelDef(
          id: 'track:witness:share_1',
          tier: PilgrimMedalTier.bronze,
          title: L10n.current.medalWitnessShare1Title,
          hint: L10n.current.medalHintShareVerses(1),
          glyph: CinematicGlyph.share,
          rung: PilgrimMedalRung.spark,
        ),
        PilgrimMedalLevelDef(
          id: 'track:witness:share_10',
          tier: PilgrimMedalTier.silver,
          title: L10n.current.medalWitnessShare10Title,
          hint: L10n.current.medalHintShareVerses(10),
          glyph: CinematicGlyph.qr,
        ),
        PilgrimMedalLevelDef(
          id: 'track:witness:share_50',
          tier: PilgrimMedalTier.gold,
          title: L10n.current.medalWitnessShare50Title,
          hint: L10n.current.medalHintShareVerses(50),
          glyph: CinematicGlyph.star,
        ),
      ],
    ),
    PilgrimMedalTrackDef(
      id: trackMemoryId,
      title: L10n.current.medalTrackMemoryTitle,
      subtitle: L10n.current.medalTrackMemorySubtitle,
      glyph: CinematicGlyph.heart,
      family: PilgrimMedalFamily.memory,
      kind: PilgrimVaultKind.journey,
      levels: [
        PilgrimMedalLevelDef(
          id: 'track:memory:verse_1',
          tier: PilgrimMedalTier.bronze,
          title: L10n.current.medalMemoryVerse1Title,
          hint: L10n.current.medalHintMemorizeVerses(1),
          glyph: CinematicGlyph.spark,
          rung: PilgrimMedalRung.spark,
        ),
        PilgrimMedalLevelDef(
          id: 'track:memory:verse_15',
          tier: PilgrimMedalTier.silver,
          title: L10n.current.medalMemoryVerse15Title,
          hint: L10n.current.medalHintMemorizeVerses(15),
          glyph: CinematicGlyph.scroll,
        ),
        PilgrimMedalLevelDef(
          id: 'track:memory:verse_50',
          tier: PilgrimMedalTier.gold,
          title: L10n.current.medalMemoryVerse50Title,
          hint: L10n.current.medalHintMemorizeVerses(50),
          glyph: CinematicGlyph.star,
        ),
      ],
    ),
  ];

  /// Ano do Advento "ativo" a partir de [now] — só vira depois da janela
  /// (24/12) + graça de 7 dias.
  static int currentAdventYear(DateTime now) {
    final day = DateTime(now.year, now.month, now.day);
    final graceEnd = DateTime(now.year, 12, 24).add(const Duration(days: 7));
    return day.isAfter(graceEnd) ? now.year + 1 : now.year;
  }

  /// Ano da Quaresma "ativa" a partir de [now] — só vira depois do Sábado
  /// Santo + graça de 7 dias.
  static int currentLentYear(DateTime now) {
    final day = DateTime(now.year, now.month, now.day);
    final window = lentWindow(now.year);
    final graceEnd = DateTime(
      window.end.year,
      window.end.month,
      window.end.day,
    ).add(const Duration(days: 7));
    return day.isAfter(graceEnd) ? now.year + 1 : now.year;
  }

  static String adventVaultId(int year) => 'season:advento-$year';
  static String adventTrackId(int year) => 'track:season:advento-$year';
  static String lentVaultId(int year) => 'season:quaresma-$year';
  static String lentTrackId(int year) => 'track:season:quaresma-$year';

  static ({DateTime start, DateTime end, int totalDays}) adventWindow(
    int year,
  ) {
    final start = LiturgicalCalendar.adventStart(year);
    final end = DateTime(year, 12, 24);
    return (start: start, end: end, totalDays: end.difference(start).inDays + 1);
  }

  static ({DateTime start, DateTime end, int totalDays}) lentWindow(
    int year,
  ) {
    final easter = LiturgicalCalendar.easterSunday(year);
    final start = easter.subtract(const Duration(days: 46));
    final end = easter.subtract(const Duration(days: 1));
    return (start: start, end: end, totalDays: end.difference(start).inDays + 1);
  }

  static int adventDayCount(int year) => adventWindow(year).totalDays;
  static int adventHalfDays(int year) => (adventDayCount(year) / 2).ceil();
  static int adventDiamondDays(int year) =>
      (adventDayCount(year) - 4).clamp(1, adventDayCount(year));

  static int lentDayCount(int year) => lentWindow(year).totalDays;
  static int lentHalfDays(int year) => (lentDayCount(year) / 2).ceil();
  static int lentDiamondDays(int year) =>
      (lentDayCount(year) - 4).clamp(1, lentDayCount(year));

  static PilgrimMedalTrackDef adventTrack(int year) {
    final trackId = adventTrackId(year);
    return PilgrimMedalTrackDef(
      id: trackId,
      title: L10n.current.medalAdventTitle,
      subtitle: L10n.current.medalAdventTrackSubtitle('$year'),
      glyph: CinematicGlyph.star,
      family: PilgrimMedalFamily.season,
      kind: PilgrimVaultKind.season,
      levels: [
        PilgrimMedalLevelDef(
          id: '$trackId:0',
          tier: PilgrimMedalTier.bronze,
          title: L10n.current.medalAdventDoorTitle,
          hint: L10n.current.medalHintAdventDays(1),
          glyph: CinematicGlyph.spark,
          rung: PilgrimMedalRung.spark,
        ),
        PilgrimMedalLevelDef(
          id: '$trackId:1',
          tier: PilgrimMedalTier.silver,
          title: L10n.current.medalSeasonFirstWeekTitle,
          hint: L10n.current.medalHintAdventDays(7),
          glyph: CinematicGlyph.calendar,
        ),
        PilgrimMedalLevelDef(
          id: '$trackId:2',
          tier: PilgrimMedalTier.gold,
          title: L10n.current.medalAdventHalfTitle,
          hint: L10n.current.medalAdventHalfHint,
          glyph: CinematicGlyph.path,
        ),
        PilgrimMedalLevelDef(
          id: '$trackId:3',
          tier: PilgrimMedalTier.diamond,
          title: L10n.current.medalAdventLivedTitle,
          hint: L10n.current.medalHintAdventDays(adventDiamondDays(year)),
          glyph: CinematicGlyph.crown,
        ),
      ],
    );
  }

  static PilgrimMedalTrackDef lentTrack(int year) {
    final trackId = lentTrackId(year);
    return PilgrimMedalTrackDef(
      id: trackId,
      title: L10n.current.medalLentTitle,
      subtitle: L10n.current.medalLentTrackSubtitle('$year'),
      glyph: CinematicGlyph.path,
      family: PilgrimMedalFamily.season,
      kind: PilgrimVaultKind.season,
      levels: [
        PilgrimMedalLevelDef(
          id: '$trackId:0',
          tier: PilgrimMedalTier.bronze,
          title: L10n.current.medalLentFirstStepTitle,
          hint: L10n.current.medalHintLentDays(1),
          glyph: CinematicGlyph.spark,
          rung: PilgrimMedalRung.spark,
        ),
        PilgrimMedalLevelDef(
          id: '$trackId:1',
          tier: PilgrimMedalTier.silver,
          title: L10n.current.medalSeasonFirstWeekTitle,
          hint: L10n.current.medalHintLentDays(7),
          glyph: CinematicGlyph.calendar,
        ),
        PilgrimMedalLevelDef(
          id: '$trackId:2',
          tier: PilgrimMedalTier.gold,
          title: L10n.current.medalLentHalfTitle,
          hint: L10n.current.medalLentHalfHint,
          glyph: CinematicGlyph.path,
        ),
        PilgrimMedalLevelDef(
          id: '$trackId:3',
          tier: PilgrimMedalTier.diamond,
          title: L10n.current.medalLentLivedTitle,
          hint: L10n.current.medalHintLentDays(lentDiamondDays(year)),
          glyph: CinematicGlyph.crown,
        ),
      ],
    );
  }

  static List<PilgrimMedalDef> get rareMedals => [
    PilgrimMedalDef(
      id: 'discovery:founder',
      vaultId: discoveryVaultId,
      title: L10n.current.medalFounderTitle,
      hint: L10n.current.medalFounderHint,
      glyph: CinematicGlyph.star,
      family: PilgrimMedalFamily.discovery,
      tier: PilgrimMedalTier.aurora,
      silent: true,
    ),
    PilgrimMedalDef(
      id: 'discovery:comeback',
      vaultId: discoveryVaultId,
      title: L10n.current.medalComebackTitle,
      hint: L10n.current.medalComebackHint,
      glyph: CinematicGlyph.path,
      family: PilgrimMedalFamily.discovery,
    ),
    PilgrimMedalDef(
      id: 'discovery:bible_before',
      vaultId: discoveryVaultId,
      title: L10n.current.medalBibleBeforeTitle,
      hint: L10n.current.medalBibleBeforeHint,
      glyph: CinematicGlyph.book,
      family: PilgrimMedalFamily.discovery,
    ),
    PilgrimMedalDef(
      id: 'discovery:andando_na_luz',
      vaultId: discoveryVaultId,
      title: L10n.current.medalWalkingInLightTitle,
      hint: L10n.current.medalWalkingInLightHint,
      glyph: CinematicGlyph.shield,
      family: PilgrimMedalFamily.discovery,
    ),
    PilgrimMedalDef(
      id: 'discovery:perfect_boss',
      vaultId: discoveryVaultId,
      title: L10n.current.medalPerfectBossTitle,
      hint: L10n.current.medalPerfectBossHint,
      glyph: CinematicGlyph.crown,
      family: PilgrimMedalFamily.discovery,
    ),
    PilgrimMedalDef(
      id: 'discovery:leader',
      vaultId: discoveryVaultId,
      title: L10n.current.medalLeaderTitle,
      hint: L10n.current.medalLeaderHint,
      glyph: CinematicGlyph.podium,
      family: PilgrimMedalFamily.discovery,
    ),
    PilgrimMedalDef(
      id: 'discovery:accuracy_elite',
      vaultId: discoveryVaultId,
      title: L10n.current.medalAccuracyEliteTitle,
      hint: L10n.current.medalAccuracyEliteHint,
      glyph: CinematicGlyph.target,
      family: PilgrimMedalFamily.discovery,
    ),
    PilgrimMedalDef(
      id: 'discovery:trail_flawless',
      vaultId: discoveryVaultId,
      title: L10n.current.medalTrailFlawlessTitle,
      hint: L10n.current.medalTrailFlawlessHint,
      glyph: CinematicGlyph.depths,
      family: PilgrimMedalFamily.discovery,
    ),
    PilgrimMedalDef(
      id: 'discovery:reflection_deep',
      vaultId: discoveryVaultId,
      title: L10n.current.medalReflectionDeepTitle,
      hint: L10n.current.medalReflectionDeepHint,
      glyph: CinematicGlyph.scroll,
      family: PilgrimMedalFamily.discovery,
    ),
  ];

  static PilgrimMedalDef adventWeekMedal(int year) => PilgrimMedalDef(
        id: 'discovery:advent_week',
        vaultId: adventVaultId(year),
        title: L10n.current.medalAdventWeekTitle,
        hint: L10n.current.medalAdventWeekHint,
        glyph: CinematicGlyph.flame,
        family: PilgrimMedalFamily.season,
      );

  static PilgrimVaultDef journeyVault() => PilgrimVaultDef(
        id: journeyVaultId,
        kind: PilgrimVaultKind.journey,
        title: L10n.current.medalJourneyVaultTitle,
        subtitle: L10n.current.medalJourneyVaultSubtitle,
        order: 0,
        tracks: journeyTracks,
      );

  static PilgrimVaultDef discoveryVault() => PilgrimVaultDef(
        id: discoveryVaultId,
        kind: PilgrimVaultKind.discovery,
        title: L10n.current.medalRareVaultTitle,
        subtitle: L10n.current.medalRareVaultSubtitle,
        order: 9000,
        rareMedals:
            rareMedals.where((m) => m.vaultId == discoveryVaultId).toList(),
      );

  static PilgrimVaultDef adventVault(int year) {
    final window = adventWindow(year);
    return PilgrimVaultDef(
      id: adventVaultId(year),
      kind: PilgrimVaultKind.season,
      title: L10n.current.medalAdventVaultTitle('$year'),
      subtitle: L10n.current.medalAdventSubtitle,
      order: 50,
      tracks: [adventTrack(year)],
      rareMedals: [adventWeekMedal(year)],
      activeFrom: window.start,
      activeUntil: window.end,
      graceDays: 7,
    );
  }

  /// Cofre de Advento do ano corrente/próximo a partir de [now].
  static PilgrimVaultDef adventVaultFor(DateTime now) =>
      adventVault(currentAdventYear(now));

  static PilgrimVaultDef lentVault(int year) {
    final window = lentWindow(year);
    return PilgrimVaultDef(
      id: lentVaultId(year),
      kind: PilgrimVaultKind.season,
      title: L10n.current.medalLentVaultTitle('$year'),
      subtitle: L10n.current.medalLentSubtitle,
      order: 51,
      tracks: [lentTrack(year)],
      activeFrom: window.start,
      activeUntil: window.end,
      graceDays: 7,
    );
  }

  /// Cofre de Quaresma do ano corrente/próximo a partir de [now].
  static PilgrimVaultDef lentVaultFor(DateTime now) =>
      lentVault(currentLentYear(now));

  static String trailVaultId(String slug) => 'trail:$slug';

  static PilgrimMedalTrackDef trailTrack(Trail trail) {
    final trackId = trailTrackId(trail.slug);
    return PilgrimMedalTrackDef(
      id: trackId,
      title: trail.localizedTitle,
      subtitle: L10n.current.medalTrailTrackSubtitle,
      glyph: CinematicGlyph.seed,
      family: PilgrimMedalFamily.formation,
      kind: PilgrimVaultKind.trail,
      trailSlug: trail.slug,
      levels: [
        PilgrimMedalLevelDef(
          id: levelId(trackId, 0),
          tier: PilgrimMedalTier.bronze,
          title: L10n.current.medalTrailFirstSceneTitle,
          hint: L10n.current.medalTrailFirstSceneHint,
          glyph: CinematicGlyph.seed,
          rung: PilgrimMedalRung.spark,
        ),
        PilgrimMedalLevelDef(
          id: levelId(trackId, 1),
          tier: PilgrimMedalTier.silver,
          title: L10n.current.modeSementeLabel,
          hint: L10n.current.medalTrailModeHint(L10n.current.modeSementeLabel),
          glyph: CinematicGlyph.scroll,
        ),
        PilgrimMedalLevelDef(
          id: levelId(trackId, 2),
          tier: PilgrimMedalTier.gold,
          title: L10n.current.modeCaminhadaLabel,
          hint: L10n.current.medalTrailModeHint(L10n.current.modeCaminhadaLabel),
          glyph: CinematicGlyph.path,
        ),
        PilgrimMedalLevelDef(
          id: levelId(trackId, 3),
          tier: PilgrimMedalTier.diamond,
          title: L10n.current.modeProfundezasLabel,
          hint: L10n.current.medalTrailFinalModeHint(
            L10n.current.modeProfundezasLabel,
          ),
          glyph: CinematicGlyph.depths,
        ),
      ],
    );
  }

  static PilgrimVaultDef trailVault(Trail trail) => PilgrimVaultDef(
        id: trailVaultId(trail.slug),
        kind: PilgrimVaultKind.trail,
        title: trail.localizedTitle,
        order: trail.order,
        tracks: [trailTrack(trail)],
      );

  static List<PilgrimVaultDef> trailVaultsForCatalog(List<Trail> catalog) => [
        for (final trail in catalog)
          if (!trail.comingSoon && trail.missionSlugs.isNotEmpty)
            trailVault(trail),
      ];
}
