import '../models/trail.dart';
import '../widgets/cinematic_icon.dart';
import 'pilgrim_medal_models.dart';

/// Catálogo v3 — escadas por família (Ferro→Diamante) + raras Mirra.
class PilgrimMedalCatalog {
  PilgrimMedalCatalog._();

  static const gospelAbbrevs = {'mt', 'mc', 'lc', 'jo'};
  static const journeyVaultId = 'journey';
  static const discoveryVaultId = 'discovery';

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
    'discovery:perfect_boss': 'journey:form:perfect_boss',
    'discovery:reflection': 'discovery:reflection_deep',
  };

  /// v2 medal id → (trackId, highest level index achieved).
  static const v2ToV3TrackLevel = <String, (String, int)>{
    'journey:word:first_chapter': (trackWordId, 0),
    'journey:word:chapters_25': (trackWordId, 1),
    'journey:word:book': (trackWordId, 2),
    'journey:word:gospel': (trackWordId, 3),
    'journey:word:nt_book': (trackWordId, 5),
    'journey:form:first_perfect': (trackFormationId, 0),
    'journey:form:perfect_5': (trackFormationId, 1),
    'journey:form:perfect_25': (trackFormationId, 2),
    'journey:form:accuracy': (trackFormationId, 3),
    'journey:form:perfect_boss': (trackFormationId, 4),
    'journey:path:streak_7': (trackPathId, 1),
    'journey:path:streak_30': (trackPathId, 3),
    'journey:path:leader': (trackPathId, 5),
    'journey:witness:share_1': (trackWitnessId, 0),
    'journey:witness:share_10': (trackWitnessId, 1),
    'journey:memory:5': (trackMemoryId, 0),
    'journey:memory:20': (trackMemoryId, 2),
  };

  static String migrateMedalId(String id) => v1ToV2Ids[id] ?? id;

  static Iterable<String> migrateMedalIds(Iterable<String> ids) =>
      ids.map(migrateMedalId);

  /// Expande ids celebrados (v1/v2/v3) para níveis v3 já vistos.
  static Set<String> expandCelebratedIds(Iterable<String> ids) {
    final result = <String>{};
    for (final raw in ids) {
      final migrated = migrateMedalId(raw);
      if (migrated.startsWith('trail:') && migrated.contains(':first_step')) {
        final slug = _trailSlugFromV2MedalId(migrated);
        if (slug != null) {
          final idx = _v2TrailMedalLevelIndex(migrated);
          if (idx != null) {
            _addLevelsUpTo(result, trailTrackId(slug), idx);
            continue;
          }
        }
      }
      final mapping = v2ToV3TrackLevel[migrated];
      if (mapping != null) {
        _addLevelsUpTo(result, mapping.$1, mapping.$2);
        continue;
      }
      if (_isV3LevelId(migrated)) {
        final parts = migrated.split(':');
        if (parts.length >= 3) {
          final trackId = parts.sublist(0, parts.length - 1).join(':');
          final idx = int.tryParse(parts.last);
          if (idx != null) _addLevelsUpTo(result, trackId, idx);
          continue;
        }
      }
      result.add(migrated);
    }
    return result;
  }

  static void _addLevelsUpTo(Set<String> out, String trackId, int maxIndex) {
    for (var i = 0; i <= maxIndex; i++) {
      out.add(levelId(trackId, i));
    }
  }

  static bool _isV3LevelId(String id) =>
      id.startsWith('track:') && RegExp(r':\d+$').hasMatch(id);

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
          id: 'track:word:0',
          tier: PilgrimMedalTier.iron,
          title: 'Primeira Palavra',
          hint: 'Leia 1 capítulo na Bíblia',
          glyph: CinematicGlyph.spark,
        ),
        PilgrimMedalLevelDef(
          id: 'track:word:1',
          tier: PilgrimMedalTier.bronze,
          title: 'Leitor atento',
          hint: 'Leia 25 capítulos',
          glyph: CinematicGlyph.book,
        ),
        PilgrimMedalLevelDef(
          id: 'track:word:2',
          tier: PilgrimMedalTier.silver,
          title: 'Livro completo',
          hint: 'Conclua um livro inteiro da Bíblia',
          glyph: CinematicGlyph.scroll,
        ),
        PilgrimMedalLevelDef(
          id: 'track:word:3',
          tier: PilgrimMedalTier.gold,
          title: 'Evangelho percorrido',
          hint: 'Conclua um evangelho inteiro',
          glyph: CinematicGlyph.dove,
        ),
        PilgrimMedalLevelDef(
          id: 'track:word:4',
          tier: PilgrimMedalTier.platinum,
          title: 'Antigo Testamento',
          hint: 'Conclua um livro do Antigo Testamento',
          glyph: CinematicGlyph.scales,
        ),
        PilgrimMedalLevelDef(
          id: 'track:word:5',
          tier: PilgrimMedalTier.diamond,
          title: 'Novo Testamento',
          hint: 'Conclua um livro do Novo Testamento',
          glyph: CinematicGlyph.gem,
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
          id: 'track:formation:0',
          tier: PilgrimMedalTier.bronze,
          title: 'Passo firme',
          hint: 'Termine uma cena com 100% de acertos',
          glyph: CinematicGlyph.check,
        ),
        PilgrimMedalLevelDef(
          id: 'track:formation:1',
          tier: PilgrimMedalTier.silver,
          title: 'Passos firmes',
          hint: '5 cenas com 100% de acertos',
          glyph: CinematicGlyph.lamp,
        ),
        PilgrimMedalLevelDef(
          id: 'track:formation:2',
          tier: PilgrimMedalTier.gold,
          title: 'Clareza total',
          hint: '25 cenas com 100% de acertos',
          glyph: CinematicGlyph.target,
        ),
        PilgrimMedalLevelDef(
          id: 'track:formation:3',
          tier: PilgrimMedalTier.platinum,
          title: 'Andando na luz',
          hint: 'Mantenha 85%+ de acertos (mín. 50 questões)',
          glyph: CinematicGlyph.shield,
        ),
        PilgrimMedalLevelDef(
          id: 'track:formation:4',
          tier: PilgrimMedalTier.diamond,
          title: 'Prova impecável',
          hint: 'Vença um desafio final com 100% de acertos',
          glyph: CinematicGlyph.crown,
        ),
      ],
    ),
    PilgrimMedalTrackDef(
      id: trackPathId,
      title: 'Caminho',
      subtitle: 'Constância e liderança na caravana',
      glyph: CinematicGlyph.flame,
      family: PilgrimMedalFamily.path,
      kind: PilgrimVaultKind.journey,
      levels: [
        PilgrimMedalLevelDef(
          id: 'track:path:0',
          tier: PilgrimMedalTier.iron,
          title: 'Três dias firmes',
          hint: 'Mantenha 3 dias de sequência',
          glyph: CinematicGlyph.spark,
        ),
        PilgrimMedalLevelDef(
          id: 'track:path:1',
          tier: PilgrimMedalTier.bronze,
          title: 'Semana firme',
          hint: 'Mantenha 7 dias de sequência',
          glyph: CinematicGlyph.flame,
        ),
        PilgrimMedalLevelDef(
          id: 'track:path:2',
          tier: PilgrimMedalTier.silver,
          title: 'Duas semanas',
          hint: 'Mantenha 14 dias de sequência',
          glyph: CinematicGlyph.calendar,
        ),
        PilgrimMedalLevelDef(
          id: 'track:path:3',
          tier: PilgrimMedalTier.gold,
          title: 'Mês constante',
          hint: 'Mantenha 30 dias de sequência',
          glyph: CinematicGlyph.rise,
        ),
        PilgrimMedalLevelDef(
          id: 'track:path:4',
          tier: PilgrimMedalTier.platinum,
          title: 'Temporada fiel',
          hint: 'Mantenha 90 dias de sequência',
          glyph: CinematicGlyph.mountain,
        ),
        PilgrimMedalLevelDef(
          id: 'track:path:5',
          tier: PilgrimMedalTier.diamond,
          title: 'Líder da caravana',
          hint: 'Fique em 1º no ranking geral por um dia',
          glyph: CinematicGlyph.podium,
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
          id: 'track:witness:0',
          tier: PilgrimMedalTier.bronze,
          title: 'Palavra levada',
          hint: 'Compartilhe 1 versículo',
          glyph: CinematicGlyph.share,
        ),
        PilgrimMedalLevelDef(
          id: 'track:witness:1',
          tier: PilgrimMedalTier.silver,
          title: 'Semeador',
          hint: 'Compartilhe 10 versículos',
          glyph: CinematicGlyph.echo,
        ),
        PilgrimMedalLevelDef(
          id: 'track:witness:2',
          tier: PilgrimMedalTier.gold,
          title: 'Portador',
          hint: 'Compartilhe 25 versículos',
          glyph: CinematicGlyph.qr,
        ),
        PilgrimMedalLevelDef(
          id: 'track:witness:3',
          tier: PilgrimMedalTier.platinum,
          title: 'Voz na caravana',
          hint: 'Compartilhe 50 versículos',
          glyph: CinematicGlyph.people,
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
          id: 'track:memory:0',
          tier: PilgrimMedalTier.bronze,
          title: 'No coração',
          hint: 'Firme 5 versículos na memorização',
          glyph: CinematicGlyph.heart,
        ),
        PilgrimMedalLevelDef(
          id: 'track:memory:1',
          tier: PilgrimMedalTier.silver,
          title: 'Palavra guardada',
          hint: 'Firme 15 versículos na memorização',
          glyph: CinematicGlyph.scroll,
        ),
        PilgrimMedalLevelDef(
          id: 'track:memory:2',
          tier: PilgrimMedalTier.gold,
          title: 'Tesouro oculto',
          hint: 'Firme 30 versículos na memorização',
          glyph: CinematicGlyph.gem,
        ),
        PilgrimMedalLevelDef(
          id: 'track:memory:3',
          tier: PilgrimMedalTier.platinum,
          title: 'Escritura viva',
          hint: 'Firme 50 versículos na memorização',
          glyph: CinematicGlyph.star,
        ),
      ],
    ),
  ];

  static const rareMedals = <PilgrimMedalDef>[
    PilgrimMedalDef(
      id: 'discovery:founder',
      vaultId: discoveryVaultId,
      title: 'Pioneiro',
      hint: 'Entrou no app durante o período de testes',
      glyph: CinematicGlyph.star,
      family: PilgrimMedalFamily.discovery,
    ),
    PilgrimMedalDef(
      id: 'discovery:comeback',
      vaultId: discoveryVaultId,
      title: 'Volta firme',
      hint: 'Retornou à trilha após 21 dias ou mais afastado',
      glyph: CinematicGlyph.path,
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
  ];

  static PilgrimVaultDef journeyVault() => const PilgrimVaultDef(
        id: journeyVaultId,
        kind: PilgrimVaultKind.journey,
        title: 'Cofre da Jornada',
        subtitle: 'Cinco emblemas que evoluem com você',
        order: 0,
        tracks: journeyTracks,
      );

  static PilgrimVaultDef discoveryVault() => const PilgrimVaultDef(
        id: discoveryVaultId,
        kind: PilgrimVaultKind.discovery,
        title: 'Raras',
        subtitle: 'Conquistas excepcionais — só aparecem quando ganhas',
        order: 9000,
        rareMedals: rareMedals,
      );

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
