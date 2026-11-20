import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trilha_app/data/year_review.dart';
import 'package:trilha_app/screens/year_review_screen.dart';
import 'package:trilha_app/services/progress_service.dart';
import 'package:trilha_app/services/subscription_service.dart';
import 'package:trilha_app/widgets/postcard.dart';
import 'package:trilha_app/widgets/year_review_video.dart';

import 'helpers/l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Postcard card(int i, String ref, DateTime on) => Postcard(
    slug: 'c$i',
    title: 'Cena $i',
    ref: ref,
    insight: 'Deus guia o povo no deserto, passo a passo.',
    art: null,
    on: on,
  );

  final review = YearReview.sample(
    postcards: [
      card(1, 'Êxodo 13:21', DateTime(2026, 11, 3)),
      card(2, 'Êxodo 14:1', DateTime(2026, 12, 1)),
      card(3, 'Êxodo 16:4', DateTime(2026, 12, 2)),
      card(4, 'Rute 1:16', DateTime(2026, 12, 5)),
    ],
  );

  Future<void> pump(WidgetTester tester, {required bool plus}) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final sub = SubscriptionService()..debugSetFakeStore(true);
    if (plus) sub.debugSetPlus(true);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SubscriptionService>.value(value: sub),
          ChangeNotifierProvider<ProgressService>.value(
            value: ProgressService(),
          ),
        ],
        child: l10nApp(YearReviewScreen(review: review)),
      ),
    );
    await tester.pump();
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Toca à direita até o último slide (o do card), conferindo cada um.
  Future<int> walkAll(WidgetTester tester) async {
    await settle(tester);
    var slides = 1;
    while (find.text('Compartilhar meu ano').evaluate().isEmpty) {
      await tester.tapAt(const Offset(300, 320));
      await settle(tester);
      expect(tester.takeException(), isNull);
      slides++;
      expect(slides, lessThan(15));
    }
    return slides;
  }

  testWidgets('Plus: todos os slides abrem sem estourar e terminam no card', (
    tester,
  ) async {
    await pump(tester, plus: true);
    expect(await walkAll(tester), 13);
    expect(tester.takeException(), isNull);
    expect(find.text('Compartilhar meu ano'), findsOneWidget);
    expect(find.text('O livro onde você mais esteve: Êxodo'), findsOneWidget);
    expect(find.text('Fiel do grupo'), findsOneWidget);
    expect(find.text('14 livros acesos de 66'), findsOneWidget);
  });

  testWidgets('cada slide tem o botão de compartilhar, menos o convite', (
    tester,
  ) async {
    await pump(tester, plus: true);
    await settle(tester);
    expect(find.text('Compartilhar'), findsOneWidget);
  });

  testWidgets('sem Plus: o convite não tem botão de compartilhar', (
    tester,
  ) async {
    await pump(tester, plus: false);
    await settle(tester);
    await tester.tapAt(const Offset(300, 320));
    await settle(tester);
    expect(find.text('Compartilhar'), findsNothing);
  });

  testWidgets('sem Plus: o card não mostra o livro do Plus', (tester) async {
    await pump(tester, plus: false);
    await walkAll(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Compartilhar meu ano'), findsOneWidget);
    expect(find.textContaining('O livro onde você mais esteve'), findsNothing);
  });

  testWidgets('vídeo do ano: todos os quadros desenham sem estourar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final t = ValueNotifier<double>(0);
    await tester.pumpWidget(
      l10nApp(
        Center(
          child: ValueListenableBuilder<double>(
            valueListenable: t,
            builder: (_, v, _) => YearVideoFrame(review: review, t: v),
          ),
        ),
      ),
    );
    for (var i = 0; i <= 40; i++) {
      t.value = i / 40;
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 't=${t.value}');
    }
    expect(find.text('Fiel do grupo'), findsOneWidget);
  });

  group('cálculos do ano', () {
    test('Caravana: melhor mês com gente suficiente e só quando orgulha', () {
      expect(
        YearStanding.best({
          3: (ahead: 0, total: 5),
          5: (ahead: 9, total: 100),
          9: (ahead: 30, total: 200),
        })?.month,
        5,
      );
      expect(YearStanding.best({5: (ahead: 9, total: 100)})?.topPct, 10);
      expect(YearStanding.best({5: (ahead: 80, total: 100)}), isNull);
      expect(YearStanding.best({5: (ahead: 0, total: 9)}), isNull);
    });

    test('livro concluído: último capítulo fecha o livro uma vez só', () async {
      final p = ProgressService();
      expect(await p.recordBibleReading('rt', 1, bookChapters: 4), isFalse);
      await p.recordBibleReading('rt', 2, bookChapters: 4);
      await p.recordBibleReading('rt', 4, bookChapters: 4);
      expect(await p.recordBibleReading('rt', 3, bookChapters: 4), isTrue);
      expect(p.isBookFinished('Rt'), isTrue);
      expect(p.booksFinishedOn['rt'], isNotEmpty);
      expect(await p.recordBibleReading('rt', 3, bookChapters: 4), isFalse);
      expect(await p.markBookFinished('rt'), isFalse);
    });

    test('selo retroativo para livro já lido inteiro, sem repetir', () async {
      final p = ProgressService()
        ..readBibleChapters = ['jn:1', 'jn:2', 'jn:3', 'jn:4', 'ob:1'];
      p.bibleChapterReadOn = {'jn:3': '2026-05-02', 'jn:4': '2026-05-09'};
      await p.backfillFinishedBooks([
        (abbrev: 'Jn', chapters: 4),
        (abbrev: 'Ob', chapters: 1),
        (abbrev: 'Mq', chapters: 7),
      ]);
      expect(p.booksFinishedOn, {'jn': '2026-05-09', 'ob': ''});
    });

    test('maior sequência conta só dias seguidos', () {
      expect(
        YearReview.longestRun({
          '2026-03-01',
          '2026-03-02',
          '2026-03-03',
          '2026-03-05',
          '2026-10-31',
          '2026-11-01',
        }),
        3,
      );
      expect(YearReview.longestRun(const {}), 0);
    });

    test('parte do dia precisa de cenas suficientes e do ano certo', () {
      expect(YearReview.daypartOf({'2026.07': 3}, 2026), isNull);
      expect(
        YearReview.daypartOf({'2026.07': 6, '2026.21': 3, '2025.22': 40}, 2026),
        YearDaypart.morning,
      );
    });

    test('perfil segue a ordem do que mais pesa', () {
      YearPersona of({
        int seals = 0,
        int advent = 0,
        int chapters = 0,
        int books = 0,
        int streak = 0,
        int days = 0,
        int growth = 0,
      }) => YearReview.personaOf(
        groupSeals: seals,
        adventDays: advent,
        adventLength: 26,
        chapters: chapters,
        litBooks: books,
        yearStreak: streak,
        daysWalked: days,
        growth: growth,
      );
      expect(of(seals: 3, chapters: 90), YearPersona.group);
      expect(of(advent: 20), YearPersona.advent);
      expect(of(chapters: 30, books: 20), YearPersona.reader);
      expect(of(books: 10), YearPersona.explorer);
      expect(of(streak: 14), YearPersona.constant);
      expect(of(growth: 12), YearPersona.grower);
      expect(of(), YearPersona.pilgrim);
    });
  });
}
