import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/services/progress_service.dart';
import 'package:trilha_app/widgets/postcard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Postais da caminhada', () {
    test('primeira conclusão revela o postal com a referência', () async {
      final p = ProgressService();
      expect(p.sceneRevealed('rute-04-asas'), isFalse);

      await p.completeMission('rute-04-asas', 50, postcardRef: 'Rute 2:12');

      expect(p.postcardsOn.keys, ['rute-04-asas']);
      expect(p.postcardRefs['rute-04-asas'], 'Rute 2:12');
      expect(p.sceneRevealed('rute-04-asas'), isTrue);
    });

    test('sem referência ainda dá postal, só não marca a Bíblia', () async {
      final p = ProgressService();
      await p.completeMission('hb-boss', 50, postcardRef: '');

      expect(p.postcardsOn.containsKey('hb-boss'), isTrue);
      expect(p.postcardRefs.containsKey('hb-boss'), isFalse);
    });

    test('prática e replay não dão postal', () async {
      final p = ProgressService();
      await p.completeMission('cena-1', 50);
      expect(p.postcardsOn, isEmpty, reason: 'sem postcardRef = prática');

      await p.completeMission('cena-1', 50, postcardRef: 'Gênesis 1:1');
      expect(p.postcardsOn, isEmpty, reason: 'cena já feita = replay');
    });

    test(
      'o postal guarda o primeiro dia, mesmo refeito em outro modo',
      () async {
        final p = ProgressService();
        await p.completeMission('cena-1', 50, postcardRef: 'Gênesis 1:1');
        final first = p.postcardsOn['cena-1'];

        p.completedMissions = [];
        await p.completeMission('cena-1', 50, postcardRef: 'Gênesis 1:2');
        expect(p.postcardsOn['cena-1'], first);
        expect(p.postcardRefs['cena-1'], 'Gênesis 1:1');
      },
    );

    test('sair da trilha apaga o postal e a celebração da medalha', () async {
      final p = ProgressService();
      await p.completeMission('cena-1', 50, postcardRef: 'Gênesis 1:1');
      p.celebratedMedalIds = [
        'track:trail:genesis-1-11:0',
        'track:path:streak_3',
      ];
      p.vaultCompleteCelebratedIds = ['trail:genesis-1-11', 'journey'];

      await p.leaveTrail(trailSlug: 'genesis-1-11', missionSlugs: ['cena-1']);

      expect(p.completedMissions, isNot(contains('cena-1')));
      expect(p.postcardsOn.containsKey('cena-1'), isFalse);
      expect(p.postcardRefs.containsKey('cena-1'), isFalse);
      expect(p.sceneRevealed('cena-1'), isFalse);
      expect(p.celebratedMedalIds, ['track:path:streak_3']);
      expect(p.vaultCompleteCelebratedIds, ['journey']);
    });
  });

  group('Postcard.book', () {
    Postcard card(String ref) => Postcard(
      slug: 's',
      title: 't',
      ref: ref,
      insight: '',
      art: null,
      on: DateTime(2026, 10, 12),
    );

    test('tira o livro da referência', () {
      expect(card('Rute 1:16').book, 'Rute');
      expect(card('1 Samuel 3:10').book, '1 Samuel');
      expect(card('Gênesis 6–9').book, 'Gênesis');
    });
  });
}
