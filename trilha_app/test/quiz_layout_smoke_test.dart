import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/l10n/app_language.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/theme/app_theme.dart';
import 'package:trilha_app/widgets/exercise_feedback_dialog.dart';
import 'package:trilha_app/widgets/exercise_panel.dart';
import 'package:trilha_app/widgets/verse_fill_panel.dart';

/// Em release, um erro de layout não pinta nada (a tela fica vazia). Aqui
/// cada gesto, o retorno e o Bônus passam por telas pequenas e texto grande.
void main() {
  const ref = 'Gênesis 1:1–2';
  const verse =
      'No princípio, Deus criou os céus e a terra. A terra, porém, estava sem '
      'forma e vazia; havia trevas sobre a face do abismo, e o Espírito de '
      'Deus pairava sobre as águas.';
  const abc = [
    QuestionOption(id: 'a', text: 'trevas'),
    QuestionOption(id: 'b', text: 'águas'),
    QuestionOption(id: 'c', text: 'Espírito'),
  ];
  const long = [
    QuestionOption(
      id: 'a',
      text: 'Deus é o centro da criação, não o ser humano nem o caos',
    ),
    QuestionOption(id: 'b', text: 'O caos existia antes de Deus agir'),
    QuestionOption(id: 'c', text: 'A terra foi criada já pronta e cheia'),
    QuestionOption(id: 'd', text: 'O Espírito surge só no Novo Testamento'),
  ];
  const feedbackWrong = {'b': 'O texto diz outra coisa.', 'c': 'Releia.'};

  Exercise ex(ExerciseType type, {List<QuestionOption> options = abc}) =>
      Exercise(
        id: 'smoke-${type.name}',
        type: type,
        prompt: 'O que Gênesis 1:1–2 diz sobre a criação e o Espírito de Deus?',
        correctAnswer: 'a',
        reference: ref,
        passageText: verse,
        options: options,
        feedbackCorrect: 'Isso: Deus age desde o princípio.',
        feedbackWrong: feedbackWrong,
        template: type == ExerciseType.complete || type == ExerciseType.tap
            ? verse.replaceFirst('trevas', '___')
            : null,
        correctOrder: const ['a', 'b', 'c'],
        passageA: const ExercisePassage(ref: ref, text: verse),
        passageB: const ExercisePassage(
          ref: 'Contexto',
          text: 'Deus é o centro, não eu',
        ),
        evidenceSpan: 'havia trevas',
      );

  final exercises = <Exercise>[
    ex(ExerciseType.trueFalse, options: const [
      QuestionOption(id: 'true', text: 'Verdadeiro'),
      QuestionOption(id: 'false', text: 'Falso'),
    ]),
    ex(ExerciseType.tap),
    ex(ExerciseType.choice, options: long),
    ex(ExerciseType.order, options: const [
      QuestionOption(id: 'a', text: 'Deus criou os céus e a terra'),
      QuestionOption(id: 'b', text: 'A terra estava sem forma e vazia'),
      QuestionOption(id: 'c', text: 'O Espírito pairava sobre as águas'),
    ]),
    ex(ExerciseType.complete),
    ex(ExerciseType.connect, options: const [
      QuestionOption(id: 'a', text: 'Deus age primeiro'),
      QuestionOption(id: 'b', text: 'O caos manda'),
      QuestionOption(id: 'c', text: 'O homem cria'),
    ]),
  ];

  const sizes = <(String, Size, double)>[
    ('pequeno', Size(320, 568), 1.0),
    ('redmi', Size(393, 780), 1.0),
    ('texto grande', Size(393, 780), 1.4),
  ];

  Future<void> pump(
    WidgetTester tester,
    Size size,
    double scale,
    Widget child,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(scale),
          ),
          child: Scaffold(body: child),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
  }

  for (final (label, size, scale) in sizes) {
    for (final e in exercises) {
      for (final (state, selected, correct, feedback) in const [
        ('aberto', null, null, false),
        ('certo', 'a', true, true),
        ('errado', 'b', false, true),
      ]) {
        testWidgets('${e.type.name} $state ($label)', (tester) async {
          await pump(
            tester,
            size,
            scale,
            ExercisePanel(
              exercise: e,
              selected: selected,
              isCorrect: correct,
              showFeedback: feedback,
              onSelect: (_) {},
              index: 2,
              total: 6,
              boardText: verse,
              boardRef: ref,
            ),
          );
          expect(tester.takeException(), isNull);
        });
      }

      for (final correct in [true, false]) {
        testWidgets(
          'retorno ${e.type.name} ${correct ? 'certo' : 'errado'} ($label)',
          (tester) async {
            await pump(
              tester,
              size,
              scale,
              ExerciseFeedbackDialog(
                exercise: e,
                selected: correct ? 'a' : 'b',
                isCorrect: correct,
                isLast: false,
                accent: AppRoles.presence,
                onContinue: () {},
                onSkip: () {},
                missionSlug: 'smoke',
              ),
            );
            expect(tester.takeException(), isNull);
          },
        );
      }
    }

    testWidgets('bônus ($label)', (tester) async {
      await pump(
        tester,
        size,
        scale,
        VerseFillPanel(
          reference: ref,
          verseText: verse,
          accent: AppRoles.presence,
          onDone: (_) {},
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
