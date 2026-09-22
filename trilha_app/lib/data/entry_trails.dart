import '../models/trail.dart';
import '../widgets/cinematic_icon.dart';

/// Trilhas curtas de entrada por dor — desembocam no cânon.
/// Atos vêm do banco das missões originais (`bankSection` + `bankTrailSlug`).
class EntryTrails {
  EntryTrails._();

  /// Última missão da trilha de dor → trilha canônica.
  static const continuesTo = {
    'dor-ansia-05': 'sermao-do-monte',
    'dor-recome-05': 'genesis-1-11',
  };

  static List<Trail> overlay = const [_anxiety, _restart];

  static const _anxiety = Trail(
    slug: 'ansiedade',
    title: 'Ansiedade',
    description: 'Cinco missões para lançar o amanhã no Pai — e seguir no cânon.',
    icon: '🌊',
    order: 2,
    comingSoon: false,
    color: '#4C6EF5',
    realmId: 'vida-crista',
    categoryId: 'discipulado',
    modules: [
      TrailModule(
        title: 'Lançar a ansiedade',
        icon: '🌊',
        missions: [
          Mission(
            slug: 'dor-ansia-01',
            title: 'Tesouros e ansiedade',
            intro: 'Onde está o tesouro, está o coração. Jesus une Mamom e o amanhã.',
            type: 'lesson',
            stepsReward: 60,
            questions: [],
            hookRef: 'Mateus 6:25–34',
            hookVerse:
                'Não andeis ansiosos pela vossa vida, quanto ao que haveis de comer ou beber; nem pelo vosso corpo, quanto ao que haveis de vestir.',
            hookNote: 'O cuidado do Pai é o argumento contra a ansiedade — não a ausência de necessidade.',
            centralInsight: 'O tesouro puxa o coração',
            objective: 'Ver como Jesus liga tesouro, senhorio e ansiedade.',
            bankSection: 'sm-21-tesouros-e-ansiedade',
            bankTrailSlug: 'sermao-do-monte',
          ),
          Mission(
            slug: 'dor-ansia-02',
            title: 'Contentamento',
            intro: 'Paulo aprendeu a estar contente em toda a sorte — em Cristo.',
            type: 'lesson',
            stepsReward: 60,
            questions: [],
            hookRef: 'Filipenses 4:12–13',
            hookVerse:
                'Sei ainda viver na penúria e sei também viver na abundância; em tudo e em todas as coisas, sei o que é ter fartura e ter fome. Tudo posso naquele que me fortalece.',
            hookNote: 'O contentamento de Paulo não é estoicismo: é Cristo na fome e na fartura.',
            centralInsight: 'Cristo basta na fome e na fartura',
            objective: 'Trocar a ansiedade do ter pelo contentamento em Cristo.',
            bankSection: 'fp-03-contentamento',
            bankTrailSlug: 'filipenses',
          ),
          Mission(
            slug: 'dor-ansia-03',
            title: 'O Senhor é o meu pastor',
            intro: 'Nada me faltará — o Salmo 23 é confiança, não magia.',
            type: 'lesson',
            stepsReward: 60,
            questions: [],
            hookRef: 'Salmo 23:1–3',
            hookVerse:
                'O Senhor é o meu pastor; nada me faltará. Ele me faz repousar em pastos verdejantes; leva-me para junto das águas de descanso.',
            hookNote: 'O pastor guia — inclusive no vale. O que some não é a luta; é o medo e a sensação de solidão.',
            centralInsight: 'Há pastor no vale',
            objective: 'Ler o Salmo 23 como cuidado, não como amuleto.',
            bankSection: 'salmos-louvor-02-o-senhor-e-o-meu-pas',
            bankTrailSlug: 'salmos',
          ),
          Mission(
            slug: 'dor-ansia-04',
            title: 'Pai nosso',
            intro: 'Pedir o pão de cada dia é o contrário de antecipar o mês inteiro.',
            type: 'lesson',
            stepsReward: 60,
            questions: [],
            hookRef: 'Mateus 6:9–11',
            hookVerse:
                'Pai nosso, que estás nos céus; santificado seja o teu nome; venha o teu reino; seja feita a tua vontade… o pão nosso de cada dia nos dá hoje.',
            hookNote: 'Jesus ensina a pedir o dia — não o estoque. O Reino vem antes do pão.',
            centralInsight: 'O pão é de hoje',
            objective: 'Orar o dia, não o censo do medo.',
            bankSection: 'or-01-pai-nosso',
            bankTrailSlug: 'oracao',
          ),
          Mission(
            slug: 'dor-ansia-05',
            title: 'Esperança viva',
            intro: 'Pedro ancora sofredores numa herança guardada — depois, o cânon.',
            type: 'lesson',
            stepsReward: 70,
            questions: [],
            hookRef: '1 Pedro 1:3–5',
            hookVerse:
                'Bendito o Deus e Pai de nosso Senhor Jesus Cristo, que, segundo a sua grande misericórdia, nos regenerou para uma viva esperança.',
            hookNote: 'A esperança não nega o sofrimento. Ela o ancora na ressurreição. Continue no Sermão do Monte.',
            centralInsight: 'A herança está guardada',
            objective: 'Sair da trilha de dor para o currículo: Sermão do Monte.',
            bankSection: 'pd-01',
            bankTrailSlug: 'pedro',
          ),
        ],
      ),
    ],
  );

  static const _restart = Trail(
    slug: 'recomeco',
    title: 'Recomeço',
    description: 'Cinco missões da queda ao chamado — e de volta a Gênesis 1–11.',
    icon: '🌱',
    order: 3,
    comingSoon: false,
    color: '#2F9E44',
    realmId: 'vida-crista',
    categoryId: 'discipulado',
    modules: [
      TrailModule(
        title: 'Do rompimento ao chamado',
        icon: '🌱',
        missions: [
          Mission(
            slug: 'dor-recome-01',
            title: 'A queda',
            intro: 'A desconfiança rompe a comunhão — e ainda assim Deus pergunta.',
            type: 'lesson',
            stepsReward: 60,
            questions: [],
            hookRef: 'Gênesis 3:8–9',
            hookVerse:
                'E ouviram a voz do Senhor Deus, que andava no jardim à viração da tarde… E o Senhor Deus chamou o homem e lhe perguntou: Onde você está?',
            hookNote: 'O primeiro movimento depois da queda é Deus procurando — não o humano se escondendo com sucesso.',
            centralInsight: 'Deus ainda pergunta onde estás',
            objective: 'Ver a queda como ruptura, não como o fim da conversa.',
            bankSection: 'gen-06-queda',
            bankTrailSlug: 'genesis-1-11',
          ),
          Mission(
            slug: 'dor-recome-02',
            title: 'Consequências',
            intro: 'O pecado tem custo. A promessa não some.',
            type: 'lesson',
            stepsReward: 60,
            questions: [],
            hookRef: 'Gênesis 3:15',
            hookVerse:
                'Porei inimizade entre ti e a mulher, e entre a tua semente e a semente dela; esta te ferirá a cabeça, e tu lhe ferirás o calcanhar.',
            hookNote: 'No mesmo capítulo da expulsão, Deus fala de uma semente. O juízo não cancela a história.',
            centralInsight: 'Há semente depois da porta',
            objective: 'Ler consequência e promessa no mesmo texto.',
            bankSection: 'gen-07-consequencias',
            bankTrailSlug: 'genesis-1-11',
          ),
          Mission(
            slug: 'dor-recome-03',
            title: 'Dilúvio',
            intro: 'Juízo e recomeço cabem no mesmo Deus.',
            type: 'lesson',
            stepsReward: 60,
            questions: [],
            hookRef: 'Gênesis 9:12–13',
            hookVerse:
                'Disse Deus: Este é o sinal da aliança que instituo entre mim e vós… O meu arco tenho posto nas nuvens.',
            hookNote: 'O mundo recomeça sob aliança, não sob amnésia. O arco lembra a Deus — e a nós.',
            centralInsight: 'Recomeçar é aliança, não apagar',
            objective: 'Ver o dilúvio como juízo que guarda um resto.',
            bankSection: 'gen-09-diluvio',
            bankTrailSlug: 'genesis-1-11',
          ),
          Mission(
            slug: 'dor-recome-04',
            title: 'Chamado de Abrão',
            intro: 'Sair da terra é o gesto do recomeço que abençoa outros.',
            type: 'lesson',
            stepsReward: 60,
            questions: [],
            hookRef: 'Gênesis 12:1–2',
            hookVerse:
                'O Senhor disse a Abrão: Saia da sua terra, de sua parentela e da casa de seu pai e vá para a terra que eu lhe mostrarei.',
            hookNote: 'Deus não conserta Babel com outra torre. Chama uma família para ser bênção.',
            centralInsight: 'O recomeço caminha para fora',
            objective: 'Ligar recomeço a chamado, não a isolamento.',
            bankSection: 'gen-11-abraao',
            bankTrailSlug: 'genesis-1-11',
          ),
          Mission(
            slug: 'dor-recome-05',
            title: 'Os que choram',
            intro: 'Quem chora o que morreu é bem-aventurado. Continue em Gênesis 1–11.',
            type: 'lesson',
            stepsReward: 70,
            questions: [],
            hookRef: 'Mateus 5:4',
            hookVerse: 'Bem-aventurados os que choram, porque eles serão consolados.',
            hookNote: 'O Reino não apressa o luto. Consola. A trilha canônica começa em Gênesis 1–11.',
            centralInsight: 'Há conforto para quem chora de verdade',
            objective: 'Sair da trilha de dor para o currículo: Gênesis 1–11.',
            bankSection: 'sm-03-os-que-choram',
            bankTrailSlug: 'sermao-do-monte',
          ),
        ],
      ),
    ],
  );
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
      fact: 'Homem e mulher são imagem de Deus — não um deles só, nem um ídolo.',
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
      fact: 'A fé de Abrão anda porque a promessa é de Deus, não porque ele via o mapa.',
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
      fact: 'O libertador cresce na casa do opressor — Deus escreve êxodo com ironia santa.',
      verseRef: 'Êxodo 3:14',
      verseText: 'Disse Deus a Moisés: EU SOU O QUE SOU.',
      glyph: CinematicGlyph.flame,
    ),
    CharacterSeal(
      id: 'seal:davi',
      name: 'Davi',
      trailSlug: 'salmos',
      missionSlug: 'salmos-louvor-02-o-senhor-e-o-meu-pas',
      fact: 'O rei-pastor canta cuidado, não invencibilidade. O vale também é do Senhor.',
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
      verseText: 'E o Verbo se fez carne e habitou entre nós, cheio de graça e de verdade.',
      glyph: CinematicGlyph.dove,
    ),
    CharacterSeal(
      id: 'seal:paulo',
      name: 'Paulo',
      trailSlug: 'filipenses',
      missionSlug: 'fp-02-humildade',
      fact: 'A mente de Cristo é descida: da glória à cruz, sem apegar-se ao privilégio.',
      verseRef: 'Filipenses 2:5–8',
      verseText:
          'Tende em vós o mesmo sentimento que houve também em Cristo Jesus, que… a si mesmo se humilhou, tornando-se obediente até à morte.',
      glyph: CinematicGlyph.scroll,
    ),
  ];

  static List<CharacterSeal> unlocked(Iterable<String> completed) {
    final set = completed.toSet();
    return [for (final s in all) if (set.contains(s.missionSlug)) s];
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
  static bool unlocksOn(
    String missionSlug,
    Iterable<String> completedBefore,
  ) {
    final seal = forMission(missionSlug);
    if (seal == null) return false;
    return !completedBefore.contains(missionSlug);
  }
}
