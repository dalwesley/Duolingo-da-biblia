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
        theological => 'Erro teológico',
        interpretation => 'Interpretação questionável',
        wrongAnswer => 'Resposta marcada errada',
        feedback => 'Feedback confuso',
        typo => 'Ortografia / texto',
        other => 'Outro',
      };

  String get hint => switch (this) {
        theological => 'Doutrina ou doutrina implícita parece incorreta',
        interpretation => 'Leitura do texto bíblico parece forçada ou imprecisa',
        wrongAnswer => 'A opção marcada como certa parece errada',
        feedback => 'Explicação após a resposta confunde ou erra',
        typo => 'Erro de digitação, referência ou formatação',
        other => 'Algo mais que não se encaixa acima',
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
