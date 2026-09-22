import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/utils/tomorrow_hook.dart';

Mission _m({
  required String slug,
  required String title,
  String subtitle = '',
  String intro = '',
  String? hookNote,
  String? hookVerse,
  String? hookRef,
  String? insight,
}) {
  return Mission(
    slug: slug,
    title: title,
    subtitle: subtitle,
    intro: intro,
    type: 'lesson',
    stepsReward: 50,
    questions: const [],
    hookNote: hookNote,
    hookVerse: hookVerse,
    hookRef: hookRef,
    centralInsight: insight,
  );
}

Trail _trail({
  required String slug,
  String? unlockAfter,
  required List<Mission> missions,
}) {
  return Trail(
    slug: slug,
    title: slug,
    description: '',
    icon: '',
    order: 1,
    unlockAfter: unlockAfter,
    comingSoon: false,
    color: '#1B3A5C',
    modules: [
      TrailModule(title: 'M', icon: '', missions: missions),
    ],
  );
}

void main() {
  final genesis = _trail(
    slug: 'genesis-1-11',
    missions: [
      _m(
        slug: 'imagem',
        title: 'A imagem de Deus',
        hookNote: 'O barro ganha fôlego.',
        insight: 'Deus é o centro, não eu',
      ),
      _m(
        slug: 'serpente',
        title: 'A serpente no jardim',
        hookNote: 'Uma pergunta entra entre o homem e o Criador.',
        hookRef: 'Gênesis 3:1–5',
        insight: 'O pecado entra pela dúvida',
      ),
    ],
  );

  test('next unfinished mission is the hook, never the insight', () {
    final hook = TomorrowHook.resolve(
      trails: [genesis],
      completed: ['imagem'],
    );
    expect(hook, isNotNull);
    expect(hook!.title, 'A serpente no jardim');
    expect(hook.tease, contains('pergunta'));
    expect(hook.tease, isNot(contains('pecado')));
    expect(hook.pull, contains('pergunta'));
    expect(hook.hookRef, 'Gênesis 3:1–5');
    expect(hook.trailSlug, 'genesis-1-11');
    expect(hook.promiseLine, 'A cena espera você.');
    expect(hook.cardLine, 'Amanhã: A serpente no jardim');
  });

  test('tease prefers the verse opening, never the insight', () {
    final m = _m(
      slug: 'luz',
      title: 'Haja luz',
      hookVerse:
          'Disse Deus: Haja luz; e houve luz. … Deus chamou à luz Dia.',
      hookNote: 'Deus organiza o caos em seis dias: primeiro os ambientes.',
      insight: 'Deus traz ordem ao caos',
    );
    expect(TomorrowHook.teaseOf(m), 'Disse Deus: Haja luz; e houve luz.');
    expect(TomorrowHook.teaseOf(m), isNot(contains('caos')));
  });

  test('live cinematic verse wins over catalog TB Jeová', () {
    final m = _m(
      slug: 'luz',
      title: 'Haja luz',
      hookVerse: 'Disse Deus: Haja luz; e houve luz.',
    );
    expect(
      TomorrowHook.teaseOf(
        m,
        liveVerse: 'E disse Deus: Haja luz. E houve luz.',
      ),
      'E disse Deus: Haja luz.',
    );
  });

  test('verse that restates the title yields to the note', () {
    final m = _m(
      slug: 'pastor',
      title: 'O Senhor é o meu pastor',
      hookVerse: 'Jeová é o meu pastor; nada me faltará.',
      hookNote: 'O pastor guia — inclusive no vale.',
      hookRef: 'Salmo 23:1–3',
    );
    expect(TomorrowHook.teaseOf(m), 'O pastor guia — inclusive no vale.');
    expect(
      TomorrowHook.teaseOf(
        m,
        liveVerse: 'O Senhor é o meu pastor; nada me faltará.',
      ),
      'O pastor guia — inclusive no vale.',
    );
    expect(TomorrowHook.pullOf(m), 'O pastor guia — inclusive no vale.');
    expect(
      TomorrowHook.restatesTitle(
        m.title,
        'Jeová é o meu pastor; nada me faltará.',
      ),
      isTrue,
    );
  });

  test('celebration pull is the note, not tomorrow\'s opening verse', () {
    final m = _m(
      slug: 'luz',
      title: 'Haja luz',
      hookVerse: 'Disse Deus: Haja luz; e houve luz.',
      hookNote: 'Deus organiza o caos em seis dias: primeiro os ambientes.',
    );
    expect(TomorrowHook.teaseOf(m), 'Disse Deus: Haja luz; e houve luz.');
    expect(
      TomorrowHook.pullOf(m),
      'Deus organiza o caos em seis dias: primeiro os ambientes.',
    );
  });

  test('tease keeps a single sentence from the note', () {
    expect(
      TomorrowHook.teaseOf(genesis.modules.first.missions.first),
      'O barro ganha fôlego.',
    );
  });

  test('commit line only during the pledged window', () {
    expect(TomorrowHook.commitLine(streak: 2, goal: 7), 'Dia 2 de 7');
    expect(
      TomorrowHook.commitLine(streak: 7, goal: 7),
      'Sete dias. O hábito pegou.',
    );
    expect(TomorrowHook.commitLine(streak: 8, goal: 7), isNull);
    expect(TomorrowHook.commitLine(streak: 0, goal: 7), isNull);
  });

  test('today insight sits next to tomorrow without spoiling it', () {
    final hook = TomorrowHook.resolve(
      trails: [genesis],
      completed: ['imagem'],
      justFinishedSlug: 'imagem',
    );
    expect(hook!.todayInsight, 'Deus é o centro, não eu');
    expect(hook.title, 'A serpente no jardim');
    expect(hook.tease, isNot(contains('pecado')));
  });

  test('withToday fills insight when the catalog omitted it', () {
    final hook = TomorrowHook.resolve(
      trails: [genesis],
      completed: ['imagem'],
    );
    final filled = hook!.withToday('Deus é o centro, não eu');
    expect(filled.todayInsight, 'Deus é o centro, não eu');
    expect(filled.title, hook.title);
  });

  test('promised scene becomes today', () {
    expect(
      TomorrowHook.promisedArrived(
        promisedTitle: 'A serpente no jardim',
        currentTitle: 'A serpente no jardim',
      ),
      isTrue,
    );
    expect(
      TomorrowHook.yesterdayLine('Deus é o centro, não eu'),
      'Ontem: Deus é o centro, não eu',
    );
  });

  test('falls forward to the successor trail', () {
    final exodo = _trail(
      slug: 'exodo',
      unlockAfter: 'genesis-1-11',
      missions: [
        _m(slug: 'arbusto', title: 'O arbusto que arde', intro: 'Um nome no fogo.'),
      ],
    );
    final hook = TomorrowHook.resolve(
      trails: [genesis, exodo],
      completed: ['imagem', 'serpente'],
    );
    expect(hook, isNotNull);
    expect(hook!.title, 'O arbusto que arde');
    expect(hook.tease, contains('nome'));
  });
}
