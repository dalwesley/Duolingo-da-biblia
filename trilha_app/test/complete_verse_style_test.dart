import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trilha_app/models/trail.dart';
import 'package:trilha_app/theme/app_theme.dart';
import 'package:trilha_app/widgets/exercise_panel.dart';

void main() {
  const verse =
      'No princípio, Deus criou os céus e a terra. A terra, porém, estava sem forma e vazia; havia trevas sobre a face do abismo, e o Espírito de Deus pairava sobre as águas.';

  const exercise = Exercise(
    id: 'genesis-1-11-sem-gen-01-criador-02',
    type: ExerciseType.tap,
    prompt: 'Complete Gênesis 1:1–2',
    correctAnswer: 'a',
    reference: 'Gênesis 1:1-2',
    passageText: verse,
    template:
        'No princípio, Deus criou os céus e a terra. A terra, porém, estava sem forma e vazia; havia ___ sobre a face do abismo, e o Espírito de Deus pairava sobre as águas.',
    options: [
      QuestionOption(id: 'a', text: 'trevas'),
      QuestionOption(id: 'b', text: 'águas'),
      QuestionOption(id: 'c', text: 'Espírito'),
    ],
  );

  testWidgets('filled cloze word stays in the verse run at the same size', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 800,
            child: ExercisePanel(
              exercise: exercise,
              selected: 'a',
              isCorrect: null,
              showFeedback: false,
              onSelect: (_) {},
              index: 4,
              total: 6,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final rich = tester.widget<RichText>(
      find.byWidgetPredicate((widget) {
        if (widget is! RichText) return false;
        final plain = widget.text.toPlainText();
        return plain.contains('havia trevas sobre');
      }),
    );

    TextStyle? runStyle;
    TextStyle? filledStyle;
    var sawWidgetBlank = false;

    void walk(InlineSpan span) {
      if (span is WidgetSpan) sawWidgetBlank = true;
      if (span is! TextSpan) return;
      final kids = span.children;
      if (kids == null) return;
      for (final child in kids) {
        if (child is TextSpan && child.text == 'trevas') {
          runStyle = span.style;
          filledStyle = child.style;
        }
        walk(child);
      }
    }

    walk(rich.text);

    expect(filledStyle, isNotNull);
    expect(runStyle, isNotNull);
    expect(sawWidgetBlank, isFalse);
    expect(filledStyle!.fontSize, 22);
    expect(filledStyle!.fontSize, runStyle!.fontSize);
    expect(filledStyle!.fontFamily, runStyle!.fontFamily);
    expect(filledStyle!.fontWeight, runStyle!.fontWeight);
    expect(filledStyle!.height, runStyle!.height);
    expect(filledStyle!.color, AppColors.accent);
  });
}
