import '../l10n/l10n_global.dart';
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

  static List<Trail> get overlay => [_anxiety, _restart];

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
      categoryId: 'discipulado',
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
              bankSection: 'sm-21-tesouros-e-ansiedade',
              bankTrailSlug: 'sermao-do-monte',
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
              bankSection: 'fp-03-contentamento',
              bankTrailSlug: 'filipenses',
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
              bankSection: 'salmos-louvor-02-o-senhor-e-o-meu-pas',
              bankTrailSlug: 'salmos',
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
              bankSection: 'or-01-pai-nosso',
              bankTrailSlug: 'oracao',
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
              bankSection: 'pd-01',
              bankTrailSlug: 'pedro',
            ),
          ],
        ),
      ],
    );
  }

  static Trail get _restart {
    final l = L10n.current;
    return Trail(
      slug: 'recomeco',
      title: l.entryTrailRecomecoTitle,
      description: l.entryTrailRecomecoDescription,
      icon: '🌱',
      order: 1,
      comingSoon: false,
      color: '#2F9E44',
      realmId: 'vida-crista',
      categoryId: 'discipulado',
      modules: [
        TrailModule(
          title: l.entryTrailRecomecoModuleTitle,
          icon: '🌱',
          missions: [
            Mission(
              slug: 'dor-recome-01',
              title: l.entryMissionDorRecome01Title,
              intro: l.entryMissionDorRecome01Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Gênesis 3:8–9',
              hookVerse:
                  'E ouviram a voz do Senhor Deus, que andava no jardim à viração da tarde… E o Senhor Deus chamou o homem e lhe perguntou: Onde você está?',
              hookNote: l.entryMissionDorRecome01HookNote,
              centralInsight: l.entryMissionDorRecome01CentralInsight,
              objective: l.entryMissionDorRecome01Objective,
              bankSection: 'gen-06-queda',
              bankTrailSlug: 'genesis-1-11',
            ),
            Mission(
              slug: 'dor-recome-02',
              title: l.entryMissionDorRecome02Title,
              intro: l.entryMissionDorRecome02Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Gênesis 3:15',
              hookVerse:
                  'Porei inimizade entre ti e a mulher, e entre a tua semente e a semente dela; esta te ferirá a cabeça, e tu lhe ferirás o calcanhar.',
              hookNote: l.entryMissionDorRecome02HookNote,
              centralInsight: l.entryMissionDorRecome02CentralInsight,
              echoQuestion: l.entryMissionDorRecome02EchoQuestion,
              objective: l.entryMissionDorRecome02Objective,
              bankSection: 'gen-07-consequencias',
              bankTrailSlug: 'genesis-1-11',
            ),
            Mission(
              slug: 'dor-recome-03',
              title: l.entryMissionDorRecome03Title,
              intro: l.entryMissionDorRecome03Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Gênesis 9:12–13',
              hookVerse:
                  'Disse Deus: Este é o sinal da aliança que instituo entre mim e vós… O meu arco tenho posto nas nuvens.',
              hookNote: l.entryMissionDorRecome03HookNote,
              centralInsight: l.entryMissionDorRecome03CentralInsight,
              echoQuestion: l.entryMissionDorRecome03EchoQuestion,
              objective: l.entryMissionDorRecome03Objective,
              bankSection: 'gen-09-diluvio',
              bankTrailSlug: 'genesis-1-11',
            ),
            Mission(
              slug: 'dor-recome-04',
              title: l.entryMissionDorRecome04Title,
              intro: l.entryMissionDorRecome04Intro,
              type: 'lesson',
              stepsReward: 60,
              questions: const [],
              hookRef: 'Gênesis 12:1–2',
              hookVerse:
                  'O Senhor disse a Abrão: Saia da sua terra, de sua parentela e da casa de seu pai e vá para a terra que eu lhe mostrarei.',
              hookNote: l.entryMissionDorRecome04HookNote,
              centralInsight: l.entryMissionDorRecome04CentralInsight,
              echoQuestion: l.entryMissionDorRecome04EchoQuestion,
              objective: l.entryMissionDorRecome04Objective,
              bankSection: 'gen-11-abraao',
              bankTrailSlug: 'genesis-1-11',
            ),
            Mission(
              slug: 'dor-recome-05',
              title: l.entryMissionDorRecome05Title,
              intro: l.entryMissionDorRecome05Intro,
              type: 'lesson',
              stepsReward: 70,
              questions: const [],
              hookRef: 'Mateus 5:4',
              hookVerse:
                  'Bem-aventurados os que choram, porque eles serão consolados.',
              hookNote: l.entryMissionDorRecome05HookNote,
              centralInsight: l.entryMissionDorRecome05CentralInsight,
              echoQuestion: l.entryMissionDorRecome05EchoQuestion,
              objective: l.entryMissionDorRecome05Objective,
              bankSection: 'sm-03-os-que-choram',
              bankTrailSlug: 'sermao-do-monte',
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
