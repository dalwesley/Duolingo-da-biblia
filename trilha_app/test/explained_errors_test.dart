import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/models/difficulty.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/services/subscription_service.dart';
import 'package:trilha_app/utils/explained_errors.dart';

BankQuestion q(
  String id, {
  String correct = 'b',
  List<String> order = const [],
}) => BankQuestion(
  id: id,
  difficulty: TrailDifficulty.semente,
  section: 'gen-01',
  question: 'Pergunta $id?',
  options: const [
    QuestionOption(id: 'a', text: 'Alpha'),
    QuestionOption(id: 'b', text: 'Beta'),
    QuestionOption(id: 'c', text: 'Gama'),
  ],
  correctOptionId: correct,
  feedbackCorrect: 'Beta é a certa porque o texto diz isso.',
  feedbackWrong: const {'a': 'Alpha não.'},
  correctOrder: order,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Erros explicados (página do perfil)', () {
    test('monta pergunta, resposta certa e porquê', () {
      final m = explainBankQuestion(q('q1'));
      expect(m, isNotNull);
      expect(m!.prompt, 'Pergunta q1?');
      expect(m.correct, 'Beta');
      expect(m.why, contains('Beta é a certa'));
    });

    test('gesto de ordenar vira a sequência certa', () {
      final m = explainBankQuestion(q('q2', order: ['b', 'a', 'c']));
      expect(m!.correct, 'Beta → Alpha → Gama');
    });

    test('lista respeita os mais recentes e o teto', () {
      final bank = {'q1': q('q1'), 'q2': q('q2'), 'q3': q('q3')};
      final out = explainMistakes(
        mistakeIds: ['q1', 'q2', 'q3'],
        byId: (id) => bank[id],
        cap: 2,
      );
      expect(out.map((m) => m.prompt), ['Pergunta q3?', 'Pergunta q2?']);
    });

    test('id sem pergunta no banco é pulado', () {
      final out = explainMistakes(mistakeIds: ['sumiu'], byId: (_) => null);
      expect(out, isEmpty);
    });

    test('a mesma trilha vira um grupo e o versículo não se repete', () {
      final groups = groupExplainedMistakes([
        ExplainedMistake(
          prompt: 'primeira',
          correct: 'a',
          why: '',
          verseRef: 'Gênesis 1:1–2',
          trailSlug: 'genesis-1-11',
        ),
        ExplainedMistake(
          prompt: 'outra trilha',
          correct: 'b',
          why: '',
          verseRef: 'Mateus 6:9–10',
          trailSlug: 'mateus',
        ),
        ExplainedMistake(
          prompt: 'de novo',
          correct: 'c',
          why: '',
          verseRef: 'Gênesis 1:1–2',
          trailSlug: 'genesis-1-11',
        ),
      ]);
      expect(groups.map((g) => g.trailSlug), ['genesis-1-11', 'mateus']);
      expect(groups.first.passages, hasLength(1));
      expect(groups.first.passages.single.items.map((m) => m.prompt), [
        'primeira',
        'de novo',
      ]);
      expect(groups.last.passages.single.items.single.prompt, 'outra trilha');
    });

    test('verdadeiro ou falso guarda a outra opção como a sua', () {
      final m = explainBankQuestion(
        BankQuestion(
          id: 'tf',
          difficulty: TrailDifficulty.semente,
          section: 'gen-01',
          question: 'A terra já está ordenada?',
          options: const [
            QuestionOption(id: 'true', text: 'Verdadeiro'),
            QuestionOption(id: 'false', text: 'Falso'),
          ],
          correctOptionId: 'false',
          feedbackCorrect: 'Certo: a terra está sem forma.',
          feedbackWrong: const {},
          type: ExerciseType.trueFalse,
        ),
      );
      expect(m!.correct, 'Falso');
      expect(m.yours, 'Verdadeiro');
      expect(m.why, 'A terra está sem forma.');
    });

    test('marcação guardada aparece em qualquer gesto', () {
      final bank = {
        'gap': BankQuestion(
          id: 'gap',
          difficulty: TrailDifficulty.caminhada,
          section: 'gen-01',
          question: 'Havia ___ sobre a face do abismo.',
          options: const [
            QuestionOption(id: 'a', text: 'luz'),
            QuestionOption(id: 'b', text: 'trevas'),
            QuestionOption(id: 'c', text: 'águas'),
          ],
          correctOptionId: 'b',
          feedbackCorrect: 'Havia trevas sobre a face do abismo.',
          feedbackWrong: const {},
          type: ExerciseType.complete,
        ),
      };
      final out = explainMistakes(
        mistakeIds: ['gap'],
        byId: (id) => bank[id],
        answers: const {'gap': 'luz'},
      );
      expect(out.single.correct, 'trevas');
      expect(out.single.yours, 'luz');
    });

    test('a leitura tira Certo e Exato e deixa a frase', () {
      expect(
        readingWhy('Certo: a terra está sem forma e vazia.'),
        'A terra está sem forma e vazia.',
      );
      expect(
        readingWhy('Exato: Abraão deve sair da sua terra.'),
        'Abraão deve sair da sua terra.',
      );
      expect(
        readingWhy('Quem é chamada de maldita é a terra.'),
        'Quem é chamada de maldita é a terra.',
      );
      expect(readingWhy('Certo:'), isEmpty);
      expect(readingWhy('  '), isEmpty);
    });
  });

  group('Selos separados', () {
    test('Peregrino é só do assinante; Apoiador é só do apoio', () {
      SharedPreferences.setMockInitialValues({});
      final sub = SubscriptionService();
      expect(sub.hasPilgrimBadge, isFalse);
      sub.isPeregrinoPlus = true;
      expect(sub.hasPilgrimBadge, isTrue);
      expect(sub.isSupporter, isFalse);
    });
  });
}
