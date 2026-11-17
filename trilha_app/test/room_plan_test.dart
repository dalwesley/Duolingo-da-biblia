import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/room_plan.dart';
import 'package:trilha_app/models/study_room.dart';
import 'package:trilha_app/utils/plan_questions.dart';

RoomMember member(String uid, {PlanProgress? plan}) =>
    RoomMember(uid: uid, name: uid, steps: 0, plan: plan);

RoomPlan plan5() {
  final dates = RoomPlan.datesBetween(
    DateTime(2026, 11, 16), // segunda
    DateTime(2026, 11, 20),
    const {},
  );
  return RoomPlan(
    id: 'p1',
    title: 'Teste',
    start: dates.first,
    end: dates.last,
    days: RoomPlan.buildDays(dates: dates, questionFor: (_, _, _) => 'Q?'),
  );
}

void main() {
  group('datas', () {
    test('pula os dias de descanso', () {
      final dates = RoomPlan.datesBetween(
        DateTime(2026, 11, 16), // segunda
        DateTime(2026, 11, 29), // domingo
        {6, 7},
      );
      expect(dates.length, 10);
      expect(dates.first, '2026-11-16');
      expect(dates, isNot(contains('2026-11-21')));
      expect(dates, isNot(contains('2026-11-22')));
    });

    test('para em maxDays', () {
      final dates = RoomPlan.datesBetween(
        DateTime(2026, 1, 1),
        DateTime(2026, 12, 31),
        const {},
      );
      expect(dates.length, RoomPlan.maxDays);
    });
  });

  group('dias', () {
    test('capítulos seguidos param no fim do livro', () {
      final days = RoomPlan.buildDays(
        dates: ['2026-11-16', '2026-11-17', '2026-11-18', '2026-11-19'],
        reading: (
          abbrev: 'Rt',
          name: 'Rute',
          from: 2,
          perDay: 2,
          bookChapters: 4,
        ),
      );
      expect(days[0].reading!.label, 'Rute 2–3');
      expect(days[1].reading!.label, 'Rute 4');
      expect(days[2].reading, isNull);
      expect(days[3].isManual, isTrue);
    });

    test('cenas em ordem, perguntas rodando e edição do líder', () {
      final days = RoomPlan.buildDays(
        dates: ['2026-11-16', '2026-11-17', '2026-11-18'],
        scenes: const [PlanScene(slug: 'a', title: 'A')],
        questionFor: (i, r, sc) => sc != null ? 'Da cena' : 'Q${i + 1}',
        edits: {3: (question: 'Minha', note: 'Recado')},
      );
      expect(days[0].scene!.slug, 'a');
      expect(days[1].scene, isNull);
      expect(days[0].question, 'Da cena');
      expect(days[1].question, 'Q2');
      expect(days[1].customQuestion, isFalse);
      expect(days[2].customQuestion, isTrue);
      expect(days[2].question, 'Minha');
      expect(days[2].note, 'Recado');
    });

    test('fonte trocada no meio começa no dia indicado', () {
      final days = RoomPlan.buildDays(
        dates: ['2026-11-16', '2026-11-17', '2026-11-18', '2026-11-19'],
        reading: (
          abbrev: 'At',
          name: 'Atos',
          from: 5,
          perDay: 1,
          bookChapters: 28,
        ),
        scenes: const [
          PlanScene(slug: 'a', title: 'A'),
          PlanScene(slug: 'b', title: 'B'),
        ],
        readingFrom: 2,
        sceneFrom: 3,
      );
      expect(days[0].reading, isNull);
      expect(days[1].reading, isNull);
      expect(days[2].reading!.label, 'Atos 5');
      expect(days[3].reading!.label, 'Atos 6');
      expect(days[2].scene, isNull);
      expect(days[3].scene!.slug, 'a');
    });

    test('temporada: cena pela data, não pela fila', () {
      final days = RoomPlan.buildDays(
        dates: ['2026-11-28', '2026-11-29', '2026-11-30'],
        scenes: const [PlanScene(slug: 'x', title: 'X')],
        sceneOn: (d) =>
            d == '2026-11-28' ? null : PlanScene(slug: 'adv-$d', title: d),
      );
      expect(days[0].scene, isNull);
      expect(days[1].scene!.slug, 'adv-2026-11-29');
      expect(days[2].scene!.slug, 'adv-2026-11-30');
    });

    test('ida e volta pelo mapa', () {
      final p = plan5();
      final back = RoomPlan.fromMap(p.toMap())!;
      expect(back.id, p.id);
      expect(back.total, 5);
      expect(back.days[2].question, 'Q?');
      expect(back.dayOn('2026-11-18')!.n, 3);
    });
  });

  group('fase', () {
    test('antes, durante e depois', () {
      final p = plan5();
      expect(p.phase(DateTime(2026, 11, 15)), PlanPhase.upcoming);
      expect(p.daysUntilStart(DateTime(2026, 11, 15)), 1);
      expect(p.phase(DateTime(2026, 11, 18, 23)), PlanPhase.active);
      expect(p.today(DateTime(2026, 11, 18))!.n, 3);
      expect(p.openDays(DateTime(2026, 11, 18)).length, 3);
      expect(p.phase(DateTime(2026, 11, 21)), PlanPhase.ended);
    });
  });

  group('grupo', () {
    test('corrente: metade no dia certo; hoje pendente não quebra', () {
      final p = plan5();
      final now = DateTime(2026, 11, 19, 10); // dia 4
      final members = [
        member(
          'a',
          plan: const PlanProgress(
            planId: 'p1',
            done: {1: '2026-11-16', 2: '2026-11-17', 3: '2026-11-18'},
          ),
        ),
        member(
          'b',
          plan: const PlanProgress(
            planId: 'p1',
            // Dia 1 recuperado depois: não segura a corrente.
            done: {1: '2026-11-18', 2: '2026-11-17', 3: '2026-11-18'},
          ),
        ),
        member('c'),
        member('d'),
      ];
      final g = PlanGroup(p, members, now);
      expect(g.kept(p.dayNumber(1)!), isFalse);
      expect(g.kept(p.dayNumber(2)!), isTrue);
      expect(g.chain(), 2);
    });

    test('progresso de outro propósito não conta', () {
      final p = plan5();
      final g = PlanGroup(p, [
        member(
          'a',
          plan: const PlanProgress(planId: 'velho', done: {1: '2026-11-16'}),
        ),
      ], DateTime(2026, 11, 17));
      expect(g.doneOn(p.dayNumber(1)!), isEmpty);
    });

    test('fechamento: fiéis fizeram todos, constante no dia certo', () {
      final p = plan5();
      final all = {for (final d in p.days) d.n: d.date};
      final members = [
        member(
          'fiel',
          plan: PlanProgress(planId: 'p1', done: all),
        ),
        member(
          'atrasado',
          plan: PlanProgress(
            planId: 'p1',
            done: {for (final d in p.days) d.n: '2026-11-21'},
          ),
        ),
        member('ausente'),
      ];
      final c = PlanGroup(p, members, DateTime(2026, 11, 21)).close();
      expect(c.isPlan, isTrue);
      expect(c.week, p.end);
      expect(c.planDays, 5);
      expect(c.faithful, unorderedEquals(['fiel', 'atrasado']));
      expect(c.constant, ['fiel']);
      expect(c.groupPct, 67);
    });
  });

  test('progresso do membro: ida e volta', () {
    const p = PlanProgress(
      planId: 'p1',
      done: {2: '2026-11-17'},
      answered: {2},
      joined: true,
    );
    final back = PlanProgress.fromMap(p.toMap())!;
    expect(back.done[2], '2026-11-17');
    expect(back.answered, {2});
    expect(back.joined, isTrue);
  });

  test('nome do livro casa sem acento e espaço', () {
    expect(PlanQuestions.normBook('Gênesis'), 'genesis');
    expect(PlanQuestions.normBook('1 Coríntios'), '1corintios');
    expect(PlanQuestions.normBook('Êxodo'), PlanQuestions.normBook('exodo'));
  });

  test('propósito que recomeçou: quem entrou continua dentro, dias zeram', () {
    final plan = RoomPlan(
      id: 'novo',
      title: 'Advento',
      start: '2026-11-29',
      end: '2026-12-24',
      days: const [PlanDay(n: 1, date: '2026-11-29')],
      gen: const {
        'pv': ['velho'],
      },
    );
    final old = PlanProgress(
      planId: 'velho',
      done: const {1: '2026-11-14'},
      answered: const {1},
      joined: true,
    );
    final carried = plan.progressOf(old)!;
    expect(carried.planId, 'novo');
    expect(carried.joined, isTrue);
    expect(carried.done, isEmpty);
    expect(carried.answered, isEmpty);
    expect(
      plan.progressOf(PlanProgress(planId: 'outro', joined: true)),
      isNull,
    );
  });

  group('RoomPlan.seasonId', () {
    RoomPlan plan(Map<String, dynamic> gen, String slug) => RoomPlan(
      id: 'p',
      title: 't',
      start: '2026-11-16',
      end: '2026-11-16',
      days: [
        PlanDay(
          n: 1,
          date: '2026-11-16',
          scene: PlanScene(slug: slug, title: 'T'),
        ),
      ],
      gen: gen,
    );

    test('estação pura', () {
      expect(plan({'sw': 'advento-2026'}, 'adv-1').seasonId, 'advento-2026');
    });

    test('trilha com sw velho do merge: vale a trilha', () {
      final p = plan({
        'sw': 'advento-2026',
        'ss': 'gen-01-criador',
      }, 'gen-01-criador');
      expect(p.seasonId, isNull);
    });

    test('estação com ss velho: vale a estação', () {
      final p = plan({'sw': 'advento-2026', 'ss': 'gen-01-criador'}, 'adv-1');
      expect(p.seasonId, 'advento-2026');
    });
  });
}
