import 'exercise.dart';

/// O que a pessoa viu no texto numa cena: a frase de acerto de cada
/// pergunta que ela acertou de primeira (e a das que errou, para rever).
///
/// Sai só do banco (feedback de acerto + referência) — nada inventado.
class SceneTakeaway {
  final String text;
  final String? reference;

  /// Errou de primeira: a frase é o que ficou para rever.
  final bool missed;

  const SceneTakeaway({
    required this.text,
    this.reference,
    this.missed = false,
  });

  static const maxSeen = 3;
  static const maxMissed = 2;

  /// Frases curtas ou genéricas ("Correto.", "Isso!") não ensinam nada.
  static const _minLength = 24;

  /// Monta a lista a partir dos resultados da sessão.
  ///
  /// [results] é o acerto de primeira por posição; [requeued] são as
  /// posições repetidas no fim (cópias — não contam).
  static List<SceneTakeaway> fromSession({
    required List<Exercise> exercises,
    required Map<int, bool> results,
    required Set<int> requeued,
  }) {
    final seen = <SceneTakeaway>[];
    final missed = <SceneTakeaway>[];
    final texts = <String>{};
    for (var i = 0; i < exercises.length; i++) {
      final correct = results[i];
      if (correct == null || requeued.contains(i)) continue;
      final ex = exercises[i];
      if (ex.type.isRevealOnly) continue;
      final text = ex.feedbackCorrect.trim();
      if (text.length < _minLength || !texts.add(text.toLowerCase())) continue;
      final ref = (ex.reference ?? '').trim();
      final item = SceneTakeaway(
        text: text,
        reference: ref.isEmpty ? null : ref,
        missed: !correct,
      );
      if (correct && seen.length < maxSeen) seen.add(item);
      if (!correct && missed.length < maxMissed) missed.add(item);
    }
    return [...seen, ...missed];
  }
}
