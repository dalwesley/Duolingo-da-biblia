import '../widgets/cinematic_icon.dart';

/// Regras das trilhas curtas de entrada, uma por motivo do onboarding —
/// desembocam no cânon. O conteúdo (nome, cenas, entrada) vem do Firestore
/// (`content_trails`), como as outras trilhas; o banco é próprio
/// (trail = slug, section = slug da cena).
class EntryTrails {
  EntryTrails._();

  /// Última missão da trilha de entrada → trilha canônica.
  static const continuesTo = {
    'dor-ansia-05': 'sermao-do-monte',
    'entrada-deus-05': 'evangelhos',
    'entrada-biblia-07': 'genesis-1-11',
  };

  /// Quando o destino de [continuesTo] é do Peregrino+, o caminho grátis
  /// oferecido junto (o texto do Sermão vive em Mateus).
  static const freeContinuesTo = {'dor-ansia-05': 'mateus'};

  /// Todas as trilhas de entrada: grátis inteiras ([PlusAccess]) e sem
  /// pré-requisito de outra área ([TrailProgress]).
  static const slugs = {'ansiedade', 'conhecer-a-deus', 'entender-a-biblia'};

  /// Trilhas de um motivo só: viram a ativa da Home só para quem o escolheu.
  /// Vivem em Temas (card próprio) e ficam sempre abertas.
  static const intentOnly = {'conhecer-a-deus', 'entender-a-biblia'};
}

class CharacterSeal {
  final String id;
  final String name;
  final String trailSlug;
  final String missionSlug;
  final String fact;
  final String verseRef;
  final String verseText;
  final CinematicGlyph glyph;

  const CharacterSeal({
    required this.id,
    required this.name,
    required this.trailSlug,
    required this.missionSlug,
    required this.fact,
    required this.verseRef,
    required this.verseText,
    required this.glyph,
  });
}

/// Selos de personagem — um fato teológico + verso. Sem skin, sem loja.
class CharacterSeals {
  CharacterSeals._();

  static const all = <CharacterSeal>[
    CharacterSeal(
      id: 'seal:imago',
      name: 'Imagem',
      trailSlug: 'genesis-1-11',
      missionSlug: 'gen-03-imagem',
      fact:
          'Homem e mulher são imagem de Deus — não um deles só, nem um ídolo.',
      verseRef: 'Gênesis 1:27',
      verseText:
          'Criou Deus o homem à sua imagem, à imagem de Deus o criou; homem e mulher os criou.',
      glyph: CinematicGlyph.humanity,
    ),
    CharacterSeal(
      id: 'seal:abraao',
      name: 'Abrão',
      trailSlug: 'genesis-12-50',
      missionSlug: 'gen12-01-chamado',
      fact:
          'A fé de Abrão anda porque a promessa é de Deus, não porque ele via o mapa.',
      verseRef: 'Gênesis 12:1',
      verseText:
          'Sai da tua terra, da tua parentela e da casa de teu pai, para a terra que eu te mostrarei.',
      glyph: CinematicGlyph.path,
    ),
    CharacterSeal(
      id: 'seal:moises',
      name: 'Moisés',
      trailSlug: 'exodo',
      missionSlug: 'exo-02-moises',
      fact:
          'O libertador cresce na casa do opressor — Deus escreve êxodo com ironia santa.',
      verseRef: 'Êxodo 3:14',
      verseText: 'Disse Deus a Moisés: EU SOU O QUE SOU.',
      glyph: CinematicGlyph.flame,
    ),
    CharacterSeal(
      id: 'seal:davi',
      name: 'Davi',
      trailSlug: 'salmos',
      missionSlug: 'salmos-louvor-02-o-senhor-e-o-meu-pas',
      fact:
          'O rei-pastor canta cuidado, não invencibilidade. O vale também é do Senhor.',
      verseRef: 'Salmo 23:1',
      verseText: 'O Senhor é o meu pastor; nada me faltará.',
      glyph: CinematicGlyph.heart,
    ),
    CharacterSeal(
      id: 'seal:jesus',
      name: 'Jesus',
      trailSlug: 'evangelhos',
      missionSlug: 'evg-01-encarnacao',
      fact: 'O Verbo não visitou de longe: se fez carne e habitou entre nós.',
      verseRef: 'João 1:14',
      verseText:
          'E o Verbo se fez carne e habitou entre nós, cheio de graça e de verdade.',
      glyph: CinematicGlyph.dove,
    ),
    CharacterSeal(
      id: 'seal:paulo',
      name: 'Paulo',
      trailSlug: 'filipenses',
      missionSlug: 'fp-02-humildade',
      fact:
          'A mente de Cristo é descida: da glória à cruz, sem apegar-se ao privilégio.',
      verseRef: 'Filipenses 2:5–8',
      verseText:
          'Tende em vós o mesmo sentimento que houve também em Cristo Jesus, que… a si mesmo se humilhou, tornando-se obediente até à morte.',
      glyph: CinematicGlyph.scroll,
    ),
  ];

  static List<CharacterSeal> unlocked(Iterable<String> completed) {
    final set = completed.toSet();
    return [
      for (final s in all)
        if (set.contains(s.missionSlug)) s,
    ];
  }

  static CharacterSeal? nextLocked(Iterable<String> completed) {
    final set = completed.toSet();
    for (final s in all) {
      if (!set.contains(s.missionSlug)) return s;
    }
    return null;
  }

  static CharacterSeal? forTrail(String trailSlug) {
    for (final s in all) {
      if (s.trailSlug == trailSlug) return s;
    }
    return null;
  }

  static CharacterSeal? forMission(String missionSlug) {
    for (final s in all) {
      if (s.missionSlug == missionSlug) return s;
    }
    return null;
  }

  /// Primeiro término desta missão-selo — o encontro, não o replay.
  static bool unlocksOn(String missionSlug, Iterable<String> completedBefore) {
    final seal = forMission(missionSlug);
    if (seal == null) return false;
    return !completedBefore.contains(missionSlug);
  }
}
