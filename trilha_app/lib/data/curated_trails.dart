import '../l10n/l10n_global.dart';
import '../models/difficulty.dart';
import '../models/trail.dart';
import '../services/bible_service.dart';
import '../services/content_catalog_service.dart';

/// Trilhas costuradas com cenas que já existem: cada cena usa o banco da
/// cena de origem e, ao terminar, conta também na trilha de origem
/// (`alsoComplete` na celebração). Vivem no app, como as de entrada.
///
/// A Promessa (docs/CAMINHADA_PREMIUM_PROMESSA.md): de Abraão a Cristo em
/// 12 cenas, no card "Promessa e cumprimento" (Peregrino+; a 1ª cena é a
/// amostra, como em toda trilha do Plus).
class CuratedTrails {
  CuratedTrails._();

  static const promiseSlug = 'a-promessa';

  static List<Trail> get overlay => [_promise];

  /// Cena curada → cena de origem (banco, estudo, pintura).
  static const origins = {
    'promessa-01': 'gen12-01-chamado',
    'promessa-02': 'gen12-04-alianca-estrelas',
    'promessa-03': 'gen12-09-moria',
    'promessa-04': 'exo-02-moises',
    'promessa-05': 'exo-07-sinai',
    'promessa-06': 'josue-alianca-jo-02-escolhei-hoje-a-quem',
    'promessa-07': 'samuel-davi-01-davi-ungido',
    'promessa-08': 'isaias-esperanca--02-o-servo-sofredor',
    'promessa-09': 'jeremias-nova-alian-01-lei-no-coracao',
    'promessa-10': 'mt-01-rei-prometido',
    'promessa-11': 'lc-01-salvador-humilde',
    'promessa-12': 'gl-02-fe',
  };

  static String? originOf(String sceneSlug) => origins[sceneSlug];

  /// Travessia final: três pontes promessa → cumprimento, perguntas que
  /// vivem no app ([synthesisQuestionIds]).
  static const synthesisSlug = 'promessa-sintese';

  /// Blocos da jornada (para o mapa): título e cenas com banco de origem
  /// (a síntese fica fora; o mapa a mostra à parte).
  static List<({String title, List<Mission> scenes})> get promiseBlocks => [
    for (final mod in _promise.modules)
      (
        title: mod.title,
        scenes: [
          for (final m in mod.missions)
            if (origins.containsKey(m.slug)) m,
        ],
      ),
  ];

  /// Erros ainda na revisão que vieram das cenas de origem [sections]
  /// (id `trilha-modo-secao-nn`, o formato do banco).
  static List<String> mistakesFor(
    Iterable<String> mistakes,
    Iterable<String> sections,
  ) => [
    for (final id in mistakes)
      if (sections.any((s) => id.contains('-$s-') || id.endsWith('-$s'))) id,
  ];

  static const _synthesisPairs = [
    ('Gênesis 22:8', 'João 1:29', 'a'),
    ('Jeremias 31:31', 'Lucas 22:20', 'b'),
    ('Gênesis 12:3', 'Gálatas 3:8', 'c'),
  ];

  static String _synthesisId(int i) =>
      '$promiseSlug-pro-$synthesisSlug-0${i + 1}';

  static List<String> get synthesisQuestionIds => [
    for (var i = 0; i < _synthesisPairs.length; i++) _synthesisId(i),
  ];

  /// Ids das perguntas que a cena [missionSlug] usa no lugar do banco
  /// remoto, já postas no banco em memória. Null para as outras cenas.
  static Future<List<String>?> prepareQuestions(String missionSlug) async {
    if (missionSlug != synthesisSlug) return null;
    final l = L10n.current;
    final texts = [
      (
        q: l.promiseTrailQ1Question,
        opts: [l.promiseTrailQ1A, l.promiseTrailQ1B, l.promiseTrailQ1C],
        ok: l.promiseTrailQ1Correct,
        wrong: {'b': l.promiseTrailQ1WrongB, 'c': l.promiseTrailQ1WrongC},
        hint: l.promiseTrailQ1Hint,
      ),
      (
        q: l.promiseTrailQ2Question,
        opts: [l.promiseTrailQ2A, l.promiseTrailQ2B, l.promiseTrailQ2C],
        ok: l.promiseTrailQ2Correct,
        wrong: {'a': l.promiseTrailQ2WrongA, 'c': l.promiseTrailQ2WrongC},
        hint: l.promiseTrailQ2Hint,
      ),
      (
        q: l.promiseTrailQ3Question,
        opts: [l.promiseTrailQ3A, l.promiseTrailQ3B, l.promiseTrailQ3C],
        ok: l.promiseTrailQ3Correct,
        wrong: {'a': l.promiseTrailQ3WrongA, 'b': l.promiseTrailQ3WrongB},
        hint: l.promiseTrailQ3Hint,
      ),
    ];
    final bible = BibleService.instance;
    final questions = <BankQuestion>[];
    for (var i = 0; i < _synthesisPairs.length; i++) {
      final (refA, refB, correct) = _synthesisPairs[i];
      final textA = await bible.passageText(
        refA,
        translationId: BibleService.palcoTranslationId,
      );
      final textB = await bible.passageText(
        refB,
        translationId: BibleService.palcoTranslationId,
      );
      final t = texts[i];
      questions.add(
        BankQuestion.fromJson({
          'id': _synthesisId(i),
          'trail': promiseSlug,
          'section': synthesisSlug,
          'difficulty': 'profundezas',
          'type': 'connect',
          'skill': 'interpret',
          'question': t.q,
          'prompt': t.q,
          'cue': t.q,
          'verseRef': refA,
          'passageText': textA ?? '',
          'passageA': {'ref': refA, 'text': textA ?? ''},
          'passageB': {'ref': refB, 'text': textB ?? ''},
          'options': [
            for (var o = 0; o < t.opts.length; o++)
              {'id': 'abc'[o], 'text': t.opts[o]},
          ],
          'correctOptionId': correct,
          'correctAnswer': correct,
          'feedbackCorrect': t.ok,
          'feedbackWrong': t.wrong,
          'hint': t.hint,
          'learningObjective': l.promiseTrailSynthObjective,
          'evidence': [refA, refB],
        }),
      );
    }
    ContentCatalogService.instance.mergeLocalQuestions(questions);
    return synthesisQuestionIds;
  }

  /// Cenas que contam junto com [missionSlug]: a origem de uma cena
  /// curada, ou as cenas curadas que usam [missionSlug] como origem.
  static Set<String> linkedScenes(String missionSlug) {
    final origin = origins[missionSlug];
    if (origin != null) return {origin};
    return {
      for (final e in origins.entries)
        if (e.value == missionSlug) e.key,
    };
  }

  static Mission _scene(
    String slug, {
    required String trail,
    required String title,
    required String intro,
    required String ref,
    required String note,
  }) => Mission(
    slug: slug,
    title: title,
    intro: intro,
    type: 'lesson',
    stepsReward: 60,
    questions: const [],
    hookRef: ref,
    hookNote: note,
    bankSection: origins[slug],
    bankTrailSlug: trail,
  );

  static Trail get _promise {
    final l = L10n.current;
    return Trail(
      slug: promiseSlug,
      title: l.promiseTrailTrailTitle,
      description: l.promiseTrailTrailDescription,
      icon: '✨',
      order: 1,
      comingSoon: false,
      color: '#C9A227',
      realmId: 'antigo-testamento',
      categoryId: 'promessa-cumprimento',
      modules: [
        TrailModule(
          title: l.promiseTrailModule1,
          icon: '⭐',
          trailSlug: promiseSlug,
          index: 0,
          missions: [
            _scene(
              'promessa-01',
              trail: 'genesis-12-50',
              title: l.promiseTrail01Title,
              intro: l.promiseTrail01Intro,
              ref: 'Gênesis 12:1–3',
              note: l.promiseTrail01Note,
            ),
            _scene(
              'promessa-02',
              trail: 'genesis-12-50',
              title: l.promiseTrail02Title,
              intro: l.promiseTrail02Intro,
              ref: 'Gênesis 15:5–6',
              note: l.promiseTrail02Note,
            ),
            _scene(
              'promessa-03',
              trail: 'genesis-12-50',
              title: l.promiseTrail03Title,
              intro: l.promiseTrail03Intro,
              ref: 'Gênesis 22:12–14',
              note: l.promiseTrail03Note,
            ),
          ],
        ),
        TrailModule(
          title: l.promiseTrailModule2,
          icon: '🔥',
          trailSlug: promiseSlug,
          index: 1,
          missions: [
            _scene(
              'promessa-04',
              trail: 'exodo',
              title: l.promiseTrail04Title,
              intro: l.promiseTrail04Intro,
              ref: 'Êxodo 3:4–9',
              note: l.promiseTrail04Note,
            ),
            _scene(
              'promessa-05',
              trail: 'exodo',
              title: l.promiseTrail05Title,
              intro: l.promiseTrail05Intro,
              ref: 'Êxodo 19:3–8',
              note: l.promiseTrail05Note,
            ),
            _scene(
              'promessa-06',
              trail: 'josue',
              title: l.promiseTrail06Title,
              intro: l.promiseTrail06Intro,
              ref: 'Josué 24:15',
              note: l.promiseTrail06Note,
            ),
          ],
        ),
        TrailModule(
          title: l.promiseTrailModule3,
          icon: '👑',
          trailSlug: promiseSlug,
          index: 2,
          missions: [
            _scene(
              'promessa-07',
              trail: 'samuel',
              title: l.promiseTrail07Title,
              intro: l.promiseTrail07Intro,
              ref: '1 Samuel 16:12–13',
              note: l.promiseTrail07Note,
            ),
            _scene(
              'promessa-08',
              trail: 'isaias',
              title: l.promiseTrail08Title,
              intro: l.promiseTrail08Intro,
              ref: 'Isaías 53:5–6',
              note: l.promiseTrail08Note,
            ),
            _scene(
              'promessa-09',
              trail: 'jeremias',
              title: l.promiseTrail09Title,
              intro: l.promiseTrail09Intro,
              ref: 'Jeremias 31:31–34',
              note: l.promiseTrail09Note,
            ),
          ],
        ),
        TrailModule(
          title: l.promiseTrailModule4,
          icon: '✝️',
          trailSlug: promiseSlug,
          index: 3,
          missions: [
            _scene(
              'promessa-10',
              trail: 'mateus',
              title: l.promiseTrail10Title,
              intro: l.promiseTrail10Intro,
              ref: 'Mateus 1:20–23',
              note: l.promiseTrail10Note,
            ),
            _scene(
              'promessa-11',
              trail: 'lucas',
              title: l.promiseTrail11Title,
              intro: l.promiseTrail11Intro,
              ref: 'Lucas 2:7–12',
              note: l.promiseTrail11Note,
            ),
            _scene(
              'promessa-12',
              trail: 'galatas',
              title: l.promiseTrail12Title,
              intro: l.promiseTrail12Intro,
              ref: 'Gálatas 3:11–14',
              note: l.promiseTrail12Note,
            ),
            Mission(
              slug: synthesisSlug,
              title: l.promiseTrailSynthTitle,
              intro: l.promiseTrailSynthIntro,
              type: 'boss',
              stepsReward: 90,
              questions: const [],
              hookRef: 'Gálatas 3:8',
              hookNote: l.promiseTrailSynthNote,
              bankSection: synthesisSlug,
              bankTrailSlug: promiseSlug,
            ),
          ],
        ),
      ],
    );
  }
}
