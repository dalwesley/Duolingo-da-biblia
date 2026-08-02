import '../models/trail.dart';

/// Resolve feedback de erro que ensina (não só "revise o texto").
class QuestionFeedback {
  QuestionFeedback._();

  static bool isGenericWrong(String? text) {
    if (text == null) return true;
    final t = text.trim().toLowerCase();
    if (t.isEmpty) return true;
    return t.startsWith('resposta incorreta') ||
        t == 'volte ao versículo — o texto responde.';
  }

  static String? optionText(Question question, String optionId) {
    for (final o in question.options) {
      if (o.id == optionId) return o.text;
    }
    return null;
  }

  static String? correctOptionText(Question question) =>
      optionText(question, question.correctOptionId);

  /// Mensagem de erro: prioriza feedback por opção; senão explica a certa + verso.
  static String wrongMessage(Question question, String selectedId) {
    final specific = question.feedbackWrong[selectedId];
    if (!isGenericWrong(specific)) return specific!.trim();

    final correctText = correctOptionText(question);
    final ref = question.verseRef?.trim();

    if (correctText != null && ref != null && ref.isNotEmpty) {
      return 'A resposta certa é “$correctText”. Relê $ref.';
    }
    if (correctText != null) {
      return 'A resposta certa é “$correctText”. Volte ao texto e compare.';
    }
    if (ref != null && ref.isNotEmpty) {
      return 'Relê $ref — o texto responde.';
    }
    return 'Volte ao texto — ele responde.';
  }
}
