import '../l10n/l10n_global.dart';

/// Categorias de relato sobre pergunta/resposta nas trilhas.
enum QuestionReportCategory {
  theological,
  interpretation,
  wrongAnswer,
  feedback,
  typo,
  other;

  String get id => switch (this) {
    theological => 'theological',
    interpretation => 'interpretation',
    wrongAnswer => 'wrong_answer',
    feedback => 'feedback',
    typo => 'typo',
    other => 'other',
  };

  String get label => switch (this) {
    theological => L10n.current.reportCategoryTheological,
    interpretation => L10n.current.reportCategoryInterpretation,
    wrongAnswer => L10n.current.reportCategoryWrongAnswer,
    feedback => L10n.current.reportCategoryFeedback,
    typo => L10n.current.reportCategoryTypo,
    other => L10n.current.reportCategoryOther,
  };

  String get hint => switch (this) {
    theological => L10n.current.reportHintTheological,
    interpretation => L10n.current.reportHintInterpretation,
    wrongAnswer => L10n.current.reportHintWrongAnswer,
    feedback => L10n.current.reportHintFeedback,
    typo => L10n.current.reportHintTypo,
    other => L10n.current.reportHintOther,
  };

  static QuestionReportCategory? fromId(String? id) {
    if (id == null) return null;
    for (final c in values) {
      if (c.id == id) return c;
    }
    return null;
  }
}

/// Relato enviado pelo usuário — base futura para discussões de trilha.
class QuestionReportDraft {
  final String questionId;
  final String questionText;
  final String? verseRef;
  final String selectedOptionId;
  final String? selectedOptionText;
  final String correctOptionId;
  final String? correctOptionText;
  final bool userWasCorrect;
  final String missionSlug;
  final String? trailSlug;
  final String? difficulty;
  final bool practiceMode;
  final QuestionReportCategory category;
  final String comment;

  const QuestionReportDraft({
    required this.questionId,
    required this.questionText,
    required this.selectedOptionId,
    required this.correctOptionId,
    required this.userWasCorrect,
    required this.missionSlug,
    required this.category,
    this.verseRef,
    this.selectedOptionText,
    this.correctOptionText,
    this.trailSlug,
    this.difficulty,
    this.practiceMode = false,
    this.comment = '',
  });
}
