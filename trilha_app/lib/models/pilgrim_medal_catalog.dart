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
    'track:path:streak_14': 'track:path:streak_3',
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
      advent2026Track,
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

  static const journeyTracks = <PilgrimMedalTrackDef>[
    PilgrimMedalTrackDef(
      id: trackWordId,
      title: 'Palavra',
      subtitle: 'Leitura bíblica na jornada',
      glyph: CinematicGlyph.book,
      family: PilgrimMedalFamily.word,
      kind: PilgrimVaultKind.journey,
      levels: [
        PilgrimMedalLevelDef(
          id: 'track:word:chapters_1',
          tier: PilgrimMedalTier.iron,
          title: 'Primeira Palavra',
          hint: 'Leia 1 capítulo na Bíblia',
          glyph: CinematicGlyph.spark,
          rung: PilgrimMedalRung.spark,
        ),
        PilgrimMedalLevelDef(
          id: 'track:word:chapters_25',
          tier: PilgrimMedalTier.silver,
          title: 'Leitor atento',
          hint: 'Leia 25 capítulos',
          glyph: CinematicGlyph.scroll,
        ),
        PilgrimMedalLevelDef(
          id: 'track:word:chapters_100',
          tier: PilgrimMedalTier.gold,
          title: 'Leitor constante',
          hint: 'Leia 100 capítulos',
          glyph: CinematicGlyph.book,
        ),
      ],
    ),
    PilgrimMedalTrackDef(
      id: trackFormationId,
      title: 'Formação',
      subtitle: 'Precisão e domínio nas cenas',
      glyph: CinematicGlyph.lamp,
      family: PilgrimMedalFamily.formation,
      kind: PilgrimVaultKind.journey,
      levels: [
        PilgrimMedalLevelDef(
          id: 'track:formation:perfect_1',
          tier: PilgrimMedalTier.bronze,
          title: 'Cena nítida',
          hint: 'Termine uma cena com 100% de acertos',
          glyph: CinematicGlyph.check,
          rung: PilgrimMedalRung.spark,
        ),
        PilgrimMedalLevelDef(
          id: 'track:formation:perfect_25',
          tier: PilgrimMedalTier.gold,
          title: 'Clareza total',
          hint: '25 cenas com 100% de acertos',
          glyph: CinematicGlyph.target,
        ),
      ],
    ),
    PilgrimMedalTrackDef(
      id: trackPathId,
      title: 'Caminho',
      subtitle: 'Constância na jornada',
      glyph: CinematicGlyph.flame,
      family: PilgrimMedalFamily.path,
      kind: PilgrimVaultKind.journey,
      levels: [
        PilgrimMedalLevelDef(
          id: 'track:path:streak_3',
          tier: PilgrimMedalTier.iron,
          title: 'Três dias firmes',
          hint: 'Mantenha 3 dias de sequência',
          glyph: CinematicGlyph.spark,
          rung: PilgrimMedalRung.spark,
        ),
        PilgrimMedalLevelDef(
          id: 'track:path:streak_30',
          tier: PilgrimMedalTier.gold,
          title: 'Mês constante',
          hint: 'Mantenha 30 dias de sequência',
          glyph: CinematicGlyph.rise,
        ),
        PilgrimMedalLevelDef(
          id: 'track:path:streak_90',
          tier: PilgrimMedalTier.platinum,
          title: 'Temporada fiel',
          hint: 'Mantenha 90 dias de sequência',
          glyph: CinematicGlyph.mountain,
        ),
      ],
    ),
    PilgrimMedalTrackDef(
      id: trackWitnessId,
      title: 'Testemunho',
      subtitle: 'Compartilhar a Palavra',
      glyph: CinematicGlyph.share,
      family: PilgrimMedalFamily.witness,
      kind: PilgrimVaultKind.journey,
      levels: [
        PilgrimMedalLevelDef(
          id: 'track:witness:share_1',
          tier: PilgrimMedalTier.bronze,
          title: 'Palavra levada',
          hint: 'Compartilhe 1 versículo',
          glyph: CinematicGlyph.share,
          rung: PilgrimMedalRung.spark,
        ),
        PilgrimMedalLevelDef(
          id: 'track:witness:share_10',
          tier: PilgrimMedalTier.gold,
          title: 'Semeador',
          hint: 'Compartilhe 10 versículos',
          glyph: CinematicGlyph.qr,
        ),
        PilgrimMedalLevelDef(
          id: 'track:witness:share_50',
          tier: PilgrimMedalTier.diamond,
          title: 'Voz na caravana',
          hint: 'Compartilhe 50 versículos',
          glyph: CinematicGlyph.star,
        ),
      ],
    ),
    PilgrimMedalTrackDef(
      id: trackMemoryId,
      title: 'Memória',
      subtitle: 'Versículos guardados no coração',
      glyph: CinematicGlyph.heart,
      family: PilgrimMedalFamily.memory,
      kind: PilgrimVaultKind.journey,
      levels: [
        PilgrimMedalLevelDef(
          id: 'track:memory:verse_1',
          tier: PilgrimMedalTier.iron,
          title: 'Primeiro verso',
          hint: 'Firme 1 versículo na memorização',
          glyph: CinematicGlyph.spark,
          rung: PilgrimMedalRung.spark,
        ),
        PilgrimMedalLevelDef(
          id: 'track:memory:verse_15',
          tier: PilgrimMedalTier.silver,
          title: 'Palavra guardada',
          hint: 'Firme 15 versículos na memorização',
          glyph: CinematicGlyph.scroll,
        ),
        PilgrimMedalLevelDef(
          id: 'track:memory:verse_50',
          tier: PilgrimMedalTier.platinum,
          title: 'Escritura viva',
          hint: 'Firme 50 versículos na memorização',
          glyph: CinematicGlyph.star,
        ),
      ],
    ),
  ];

  static final advent2026Track = PilgrimMedalTrackDef(
    id: advent2026TrackId,
    title: 'Advento',
    subtitle: 'Espera e preparação — 2026',
    glyph: CinematicGlyph.star,
    family: PilgrimMedalFamily.season,
    kind: PilgrimVaultKind.season,
    levels: const [
      PilgrimMedalLevelDef(
        id: 'track:season:advento-2026:0',
        tier: PilgrimMedalTier.bronze,
        title: 'Porta aberta',
        hint: 'Caminhe 1 dia no Advento',
        glyph: CinematicGlyph.spark,
        rung: PilgrimMedalRung.spark,
      ),
      PilgrimMedalLevelDef(
        id: 'track:season:advento-2026:1',
        tier: PilgrimMedalTier.silver,
        title: 'Primeira semana',
        hint: 'Caminhe 7 dias no Advento',
        glyph: CinematicGlyph.calendar,
      ),
      PilgrimMedalLevelDef(
        id: 'track:season:advento-2026:2',
        tier: PilgrimMedalTier.gold,
        title: 'Meio do caminho',
        hint: 'Caminhe metade dos dias do Advento',
        glyph: CinematicGlyph.path,
      ),
      PilgrimMedalLevelDef(
        id: 'track:season:advento-2026:3',
        tier: PilgrimMedalTier.diamond,
        title: 'Temporada vivida',
        hint: 'Caminhe 22 dias no Advento',
        glyph: CinematicGlyph.crown,
      ),
    ],
  );

  static const rareMedals = <PilgrimMedalDef>[
    PilgrimMedalDef(
      id: 'discovery:founder',
      vaultId: discoveryVaultId,
      title: 'Pioneiro',
      hint: 'Entrou no app durante o período de testes',
      glyph: CinematicGlyph.star,
      family: PilgrimMedalFamily.discovery,
      silent: true,
    ),
    PilgrimMedalDef(
      id: 'discovery:comeback',
      vaultId: discoveryVaultId,
      title: 'Volta firme',
      hint: 'A porta estava aberta — voltou após 21 dias ou mais',
      glyph: CinematicGlyph.path,
      family: PilgrimMedalFamily.discovery,
    ),
    PilgrimMedalDef(
      id: 'discovery:bible_before',
      vaultId: discoveryVaultId,
      title: 'Palavra antes',
      hint: 'Leu um capítulo no mesmo dia, antes da missão',
      glyph: CinematicGlyph.book,
      family: PilgrimMedalFamily.discovery,
    ),
    PilgrimMedalDef(
      id: 'discovery:andando_na_luz',
      vaultId: discoveryVaultId,
      title: 'Andando na luz',
      hint: 'Manteve 85%+ de acertos (mín. 50 questões)',
      glyph: CinematicGlyph.shield,
      family: PilgrimMedalFamily.discovery,
    ),
    PilgrimMedalDef(
      id: 'discovery:perfect_boss',
      vaultId: discoveryVaultId,
      title: 'Prova impecável',
      hint: 'Venceu um desafio final com 100% de acertos',
      glyph: CinematicGlyph.crown,
      family: PilgrimMedalFamily.discovery,
    ),
    PilgrimMedalDef(
      id: 'discovery:leader',
      vaultId: discoveryVaultId,
      title: 'Líder da caravana',
      hint: 'Ficou em 1º no ranking geral por um dia',
      glyph: CinematicGlyph.podium,
      family: PilgrimMedalFamily.discovery,
    ),
    PilgrimMedalDef(
      id: 'discovery:accuracy_elite',
      vaultId: discoveryVaultId,
      title: 'Mira certeira',
      hint: 'Manteve 95%+ de acertos em 150 questões ou mais',
      glyph: CinematicGlyph.target,
      family: PilgrimMedalFamily.discovery,
    ),
    PilgrimMedalDef(
      id: 'discovery:trail_flawless',
      vaultId: discoveryVaultId,
      title: 'Trilha impecável',
      hint: 'Concluiu uma trilha inteira com 100% em todas as cenas',
      glyph: CinematicGlyph.depths,
      family: PilgrimMedalFamily.discovery,
    ),
    PilgrimMedalDef(
      id: 'discovery:reflection_deep',
      vaultId: discoveryVaultId,
      title: 'Diário profundo',
      hint: 'Registrou 40 reflexões no diário de missões',
      glyph: CinematicGlyph.scroll,
      family: PilgrimMedalFamily.discovery,
    ),
    PilgrimMedalDef(
      id: 'discovery:advent_week',
      vaultId: advent2026VaultId,
      title: 'Semana de espera',
      hint: 'Sete dias seguidos durante o Advento',
      glyph: CinematicGlyph.flame,
      family: PilgrimMedalFamily.season,
    ),
  ];

  static PilgrimVaultDef journeyVault() => const PilgrimVaultDef(
        id: journeyVaultId,
        kind: PilgrimVaultKind.journey,
        title: 'Cofre da Jornada',
        subtitle: 'Faísca acende; conquista fica',
        order: 0,
        tracks: journeyTracks,
      );

  static PilgrimVaultDef discoveryVault() => PilgrimVaultDef(
        id: discoveryVaultId,
        kind: PilgrimVaultKind.discovery,
        title: 'Raras',
        subtitle: 'Conquistas excepcionais — só aparecem quando ganhas',
        order: 9000,
        rareMedals:
            rareMedals.where((m) => m.vaultId == discoveryVaultId).toList(),
      );

  static PilgrimVaultDef advent2026Vault() {
    final start = LiturgicalCalendar.adventStart(2026);
    final end = DateTime(2026, 12, 24);
    return PilgrimVaultDef(
      id: advent2026VaultId,
      kind: PilgrimVaultKind.season,
      title: 'Advento 2026',
      subtitle: 'Espera e preparação',
      order: 50,
      tracks: [advent2026Track],
      rareMedals: rareMedals
          .where((m) => m.id == 'discovery:advent_week')
          .toList(),
      activeFrom: start,
      activeUntil: end,
      graceDays: 7,
    );
  }

  static int advent2026DayCount() {
    final start = LiturgicalCalendar.adventStart(2026);
    final end = DateTime(2026, 12, 24);
    return end.difference(start).inDays + 1;
  }

  static int advent2026HalfDays() => (advent2026DayCount() / 2).ceil();

  static String trailVaultId(String slug) => 'trail:$slug';

  static PilgrimMedalTrackDef trailTrack(Trail trail) {
    final trackId = trailTrackId(trail.slug);
    return PilgrimMedalTrackDef(
      id: trackId,
      title: trail.title,
      subtitle: 'Progresso nesta trilha',
      glyph: CinematicGlyph.seed,
      family: PilgrimMedalFamily.formation,
      kind: PilgrimVaultKind.trail,
      trailSlug: trail.slug,
      levels: [
        PilgrimMedalLevelDef(
          id: levelId(trackId, 0),
          tier: PilgrimMedalTier.bronze,
          title: 'Primeiro passo',
          hint: 'Conclua 1 missão nesta trilha',
          glyph: CinematicGlyph.seed,
          rung: PilgrimMedalRung.spark,
        ),
        PilgrimMedalLevelDef(
          id: levelId(trackId, 1),
          tier: PilgrimMedalTier.silver,
          title: 'Semente',
          hint: 'Conclua o modo Observação',
          glyph: CinematicGlyph.scroll,
        ),
        PilgrimMedalLevelDef(
          id: levelId(trackId, 2),
          tier: PilgrimMedalTier.gold,
          title: 'Caminhada',
          hint: 'Conclua o modo Compreensão',
          glyph: CinematicGlyph.path,
        ),
        PilgrimMedalLevelDef(
          id: levelId(trackId, 3),
          tier: PilgrimMedalTier.diamond,
          title: 'Peregrino',
          hint: 'Conclua a trilha no modo Interpretação',
          glyph: CinematicGlyph.depths,
        ),
      ],
    );
  }

  static PilgrimVaultDef trailVault(Trail trail) => PilgrimVaultDef(
        id: trailVaultId(trail.slug),
        kind: PilgrimVaultKind.trail,
        title: trail.title,
        order: trail.order,
        tracks: [trailTrack(trail)],
      );

  static List<PilgrimVaultDef> trailVaultsForCatalog(List<Trail> catalog) => [
        for (final trail in catalog)
          if (!trail.comingSoon && trail.missionSlugs.isNotEmpty)
            trailVault(trail),
      ];
}
