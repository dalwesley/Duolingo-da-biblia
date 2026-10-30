import '../l10n/l10n_global.dart';
import '../models/trail.dart';
import '../widgets/cinematic_icon.dart';

/// Trilhas curtas de entrada, uma por motivo do onboarding — desembocam no
/// cânon. Cada uma tem banco próprio (`perguntas-v2/<slug>.json`, section =
/// slug da cena).
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

  static List<Trail> get overlay => [_anxiety, _knowGod, _bible];

  /// Banco de origem → cenas de entrada que tocam o mesmo banco.
  static final Map<String, Set<String>> _byBank = () {
    final map = <String, Set<String>>{};
    for (final trail in overlay) {
      for (final mod in trail.modules) {
        for (final m in mod.missions) {
          if (m.resolvedBankSection == m.slug) continue;
          (map[m.resolvedBankSection] ??= {}).add(m.slug);
        }
      }
    }
    return map;
  }();

  /// Cenas que mostram as mesmas perguntas de [missionSlug] (a cena de
  /// origem e as outras entradas no mesmo banco), sem ela mesma.
  static Set<String> linkedScenes(String missionSlug) {
    for (final entry in _byBank.entries) {
      final group = {entry.key, ...entry.value};
      if (group.contains(missionSlug)) return group..remove(missionSlug);
    }
    return const {};
  }

  static Trail get _anxiety {
    final l = L10n.current;
    return Trail(
      slug: 'ansiedade',
      title: l.entryTrailAnsiedadeTitle,
      description: l.entryTrailAnsiedadeDescription,
      icon: '🌊',
      order: 0,
      comingSoon: false,
      color: '#4C6EF5',
      realmId: 'vida-crista',
      categoryId: 'paz-no-dia',
      modules: [
        TrailModule(
          title: l.entryTrailAnsiedadeModuleTitle,
          icon: '🌊',
          missions: [
            Mission(
              slug: 'dor-ansia-01',
              title: l.entryMissionDorAnsia01Title,
              intro: l.entryMissionDorAnsia01Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Mateus 6:25–34',
              hookVerse:
                  'Não andeis ansiosos pela vossa vida, quanto ao que haveis de comer ou beber; nem pelo vosso corpo, quanto ao que haveis de vestir.',
              hookNote: l.entryMissionDorAnsia01HookNote,
              centralInsight: l.entryMissionDorAnsia01CentralInsight,
              objective: l.entryMissionDorAnsia01Objective,
            ),
            Mission(
              slug: 'dor-ansia-02',
              title: l.entryMissionDorAnsia02Title,
              intro: l.entryMissionDorAnsia02Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Filipenses 4:12–13',
              hookVerse:
                  'Sei ainda viver na penúria e sei também viver na abundância; em tudo e em todas as coisas, sei o que é ter fartura e ter fome. Tudo posso naquele que me fortalece.',
              hookNote: l.entryMissionDorAnsia02HookNote,
              centralInsight: l.entryMissionDorAnsia02CentralInsight,
              objective: l.entryMissionDorAnsia02Objective,
            ),
            Mission(
              slug: 'dor-ansia-03',
              title: l.entryMissionDorAnsia03Title,
              intro: l.entryMissionDorAnsia03Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Salmo 23:1–3',
              hookVerse:
                  'O Senhor é o meu pastor; nada me faltará. Ele me faz repousar em pastos verdejantes; leva-me para junto das águas de descanso.',
              hookNote: l.entryMissionDorAnsia03HookNote,
              centralInsight: l.entryMissionDorAnsia03CentralInsight,
              objective: l.entryMissionDorAnsia03Objective,
            ),
            Mission(
              slug: 'dor-ansia-04',
              title: l.entryMissionDorAnsia04Title,
              intro: l.entryMissionDorAnsia04Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Mateus 6:9–11',
              hookVerse:
                  'Pai nosso, que estás nos céus; santificado seja o teu nome; venha o teu reino; seja feita a tua vontade… o pão nosso de cada dia nos dá hoje.',
              hookNote: l.entryMissionDorAnsia04HookNote,
              centralInsight: l.entryMissionDorAnsia04CentralInsight,
              objective: l.entryMissionDorAnsia04Objective,
            ),
            Mission(
              slug: 'dor-ansia-05',
              title: l.entryMissionDorAnsia05Title,
              intro: l.entryMissionDorAnsia05Intro,
              type: 'lesson',
              stepsReward: 70,
              questions: const [],
              hookRef: '1 Pedro 1:3–5',
              hookVerse:
                  'Bendito o Deus e Pai de nosso Senhor Jesus Cristo, que, segundo a sua grande misericórdia, nos regenerou para uma viva esperança.',
              hookNote: l.entryMissionDorAnsia05HookNote,
              centralInsight: l.entryMissionDorAnsia05CentralInsight,
              objective: l.entryMissionDorAnsia05Objective,
            ),
          ],
        ),
      ],
    );
  }

  static Trail get _knowGod {
    final l = L10n.current;
    return Trail(
      slug: 'conhecer-a-deus',
      title: l.entryTrailConhecerADeusTitle,
      description: l.entryTrailConhecerADeusDescription,
      icon: '✨',
      order: 2,
      comingSoon: false,
      color: '#E67700',
      realmId: 'vida-crista',
      categoryId: 'conhecer-a-deus',
      modules: [
        TrailModule(
          title: l.entryTrailConhecerADeusModuleTitle,
          icon: '✨',
          missions: [
            Mission(
              slug: 'entrada-deus-01',
              title: l.entryMissionEntradaDeus01Title,
              intro: l.entryMissionEntradaDeus01Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Gênesis 1:1–3',
              hookVerse: 'No princípio, Deus criou os céus e a terra.',
              hookNote: l.entryMissionEntradaDeus01HookNote,
              centralInsight: l.entryMissionEntradaDeus01CentralInsight,
              objective: l.entryMissionEntradaDeus01Objective,
            ),
            Mission(
              slug: 'entrada-deus-02',
              title: l.entryMissionEntradaDeus02Title,
              intro: l.entryMissionEntradaDeus02Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Êxodo 3:13–14',
              hookVerse: 'E Deus disse a Moisés: “EU SOU O QUE SOU.”',
              hookNote: l.entryMissionEntradaDeus02HookNote,
              centralInsight: l.entryMissionEntradaDeus02CentralInsight,
              objective: l.entryMissionEntradaDeus02Objective,
            ),
            Mission(
              slug: 'entrada-deus-03',
              title: l.entryMissionEntradaDeus03Title,
              intro: l.entryMissionEntradaDeus03Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Isaías 6:1–3',
              hookVerse:
                  'Santo, santo, santo é o SENHOR dos Exércitos; toda a terra está repleta da sua glória.',
              hookNote: l.entryMissionEntradaDeus03HookNote,
              centralInsight: l.entryMissionEntradaDeus03CentralInsight,
              objective: l.entryMissionEntradaDeus03Objective,
            ),
            Mission(
              slug: 'entrada-deus-04',
              title: l.entryMissionEntradaDeus04Title,
              intro: l.entryMissionEntradaDeus04Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Salmo 23:1–3',
              hookVerse:
                  'O Senhor é o meu pastor; nada me faltará. Ele me faz repousar em pastos verdejantes; leva-me para junto das águas de descanso.',
              hookNote: l.entryMissionEntradaDeus04HookNote,
              centralInsight: l.entryMissionEntradaDeus04CentralInsight,
              objective: l.entryMissionEntradaDeus04Objective,
            ),
            Mission(
              slug: 'entrada-deus-05',
              title: l.entryMissionEntradaDeus05Title,
              intro: l.entryMissionEntradaDeus05Intro,
              type: 'lesson',
              stepsReward: 70,
              questions: const [],
              hookRef: 'João 1:1–14',
              hookVerse:
                  'E o Verbo se fez carne e habitou entre nós, cheio de graça e de verdade.',
              hookNote: l.entryMissionEntradaDeus05HookNote,
              centralInsight: l.entryMissionEntradaDeus05CentralInsight,
              objective: l.entryMissionEntradaDeus05Objective,
            ),
          ],
        ),
      ],
    );
  }

  static Trail get _bible {
    final l = L10n.current;
    return Trail(
      slug: 'entender-a-biblia',
      title: l.entryTrailEntenderABibliaTitle,
      description: l.entryTrailEntenderABibliaDescription,
      icon: '📜',
      order: 3,
      comingSoon: false,
      color: '#1971C2',
      realmId: 'vida-crista',
      categoryId: 'entender-a-biblia',
      modules: [
        TrailModule(
          title: l.entryTrailEntenderABibliaModuleTitle,
          icon: '📜',
          missions: [
            Mission(
              slug: 'entrada-biblia-01',
              title: l.entryMissionEntradaBiblia01Title,
              intro: l.entryMissionEntradaBiblia01Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Gênesis 1:1–3',
              hookVerse: 'No princípio, Deus criou os céus e a terra.',
              hookNote: l.entryMissionEntradaBiblia01HookNote,
              centralInsight: l.entryMissionEntradaBiblia01CentralInsight,
              objective: l.entryMissionEntradaBiblia01Objective,
            ),
            Mission(
              slug: 'entrada-biblia-02',
              title: l.entryMissionEntradaBiblia02Title,
              intro: l.entryMissionEntradaBiblia02Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Gênesis 3:1–6',
              hookVerse:
                  'Então, a serpente disse à mulher: É certo que vocês não morrerão.',
              hookNote: l.entryMissionEntradaBiblia02HookNote,
              centralInsight: l.entryMissionEntradaBiblia02CentralInsight,
              objective: l.entryMissionEntradaBiblia02Objective,
            ),
            Mission(
              slug: 'entrada-biblia-03',
              title: l.entryMissionEntradaBiblia03Title,
              intro: l.entryMissionEntradaBiblia03Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Gênesis 12:1–3',
              hookVerse:
                  'Farei de você uma grande nação… e em você todas as famílias da terra serão benditas.',
              hookNote: l.entryMissionEntradaBiblia03HookNote,
              centralInsight: l.entryMissionEntradaBiblia03CentralInsight,
              objective: l.entryMissionEntradaBiblia03Objective,
            ),
            Mission(
              slug: 'entrada-biblia-04',
              title: l.entryMissionEntradaBiblia04Title,
              intro: l.entryMissionEntradaBiblia04Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Êxodo 14:13–14',
              hookVerse: 'O Senhor lutará por vocês, e vocês se calarão.',
              hookNote: l.entryMissionEntradaBiblia04HookNote,
              centralInsight: l.entryMissionEntradaBiblia04CentralInsight,
              objective: l.entryMissionEntradaBiblia04Objective,
            ),
            Mission(
              slug: 'entrada-biblia-05',
              title: l.entryMissionEntradaBiblia05Title,
              intro: l.entryMissionEntradaBiblia05Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Isaías 53:5–6',
              hookVerse:
                  'Ele, porém, foi traspassado por nossas transgressões e moído por nossas iniquidades; o castigo que nos trouxe paz estava sobre ele, e pelas suas feridas fomos curados.',
              hookNote: l.entryMissionEntradaBiblia05HookNote,
              centralInsight: l.entryMissionEntradaBiblia05CentralInsight,
              objective: l.entryMissionEntradaBiblia05Objective,
            ),
            Mission(
              slug: 'entrada-biblia-06',
              title: l.entryMissionEntradaBiblia06Title,
              intro: l.entryMissionEntradaBiblia06Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Mateus 28:5–6',
              hookVerse:
                  'Não está aqui, pois já ressuscitou, como ele havia dito. Venham ver onde ele estava.',
              hookNote: l.entryMissionEntradaBiblia06HookNote,
              centralInsight: l.entryMissionEntradaBiblia06CentralInsight,
              objective: l.entryMissionEntradaBiblia06Objective,
            ),
            Mission(
              slug: 'entrada-biblia-07',
              title: l.entryMissionEntradaBiblia07Title,
              intro: l.entryMissionEntradaBiblia07Intro,
              type: 'lesson',
              stepsReward: 70,
              questions: const [],
              hookRef: 'Apocalipse 21:3–5',
              hookVerse:
                  'Eis o tabernáculo de Deus com os homens. Ele habitará com eles, e eles serão o Seu povo.',
              hookNote: l.entryMissionEntradaBiblia07HookNote,
              centralInsight: l.entryMissionEntradaBiblia07CentralInsight,
              objective: l.entryMissionEntradaBiblia07Objective,
            ),
          ],
        ),
      ],
    );
  }
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
