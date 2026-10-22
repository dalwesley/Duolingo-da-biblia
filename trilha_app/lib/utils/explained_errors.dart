import '../models/difficulty.dart';
import '../models/exercise.dart';

/// Um erro guardado, pronto para a página "Seus erros explicados" do
/// perfil: a pergunta, a resposta certa e o porquê (o `feedbackCorrect`
/// que o banco já traz — a explicação da resposta certa).
class ExplainedMistake {
  final String prompt;
  final String correct;
  final String why;

  /// O que a pessoa marcou. Gravado no erro; no verdadeiro ou falso
  /// antigo, a outra opção.
  final String? yours;
  final String? verseRef;
  final String trailSlug;
  final String section;
  final TrailDifficulty difficulty;

  /// Nulo só em instância antiga, de antes do campo existir (hot reload).
  final ExerciseType? type;

  const ExplainedMistake({
    required this.prompt,
    required this.correct,
    required this.why,
    this.yours,
    this.verseRef,
    this.trailSlug = '',
    this.section = '',
    this.difficulty = TrailDifficulty.semente,
    this.type = ExerciseType.choice,
  });

  ExerciseType get gesture => type ?? ExerciseType.choice;
}

/// Trechos de uma mesma trilha, na ordem em que apareceram.
class ExplainedPassageGroup {
  final String key;
  final List<ExplainedMistake> items;

  const ExplainedPassageGroup({required this.key, required this.items});
}

/// Erros de uma trilha, já reunidos por trecho.
class ExplainedTrailGroup {
  final String trailSlug;
  final List<ExplainedPassageGroup> passages;

  const ExplainedTrailGroup({required this.trailSlug, required this.passages});
}

/// Monta a explicação de uma pergunta do banco. Null quando falta o
/// essencial (enunciado ou resposta certa) — a página pula esses.
/// [yours] é a marcação guardada; se vier vazia, o verdadeiro ou falso
/// ainda infere a outra opção.
ExplainedMistake? explainBankQuestion(BankQuestion q, {String? yours}) {
  final overlay = q.withOverlay();
  final prompt = (overlay.prompt ?? overlay.question).trim();
  if (prompt.isEmpty) return null;

  String textOf(String id) {
    for (final o in overlay.options) {
      if (o.id == id) return o.text;
    }
    return id;
  }

  final String correct;
  if (overlay.correctOrder.isNotEmpty) {
    correct = overlay.correctOrder.map(textOf).join(' → ');
  } else {
    final answer = (overlay.correctAnswer ?? overlay.correctOptionId).trim();
    if (answer.isEmpty) return null;
    correct = textOf(answer);
  }

  return ExplainedMistake(
    prompt: prompt,
    correct: correct,
    yours: _storedOrInferred(overlay, correct, yours),
    why: readingWhy(overlay.feedbackCorrect),
    verseRef: overlay.verseRef,
    trailSlug: overlay.trailSlug,
    section: overlay.section,
    difficulty: overlay.difficulty,
    type: overlay.type,
  );
}

/// Reúne a lista (já na ordem mais recente) por trilha e, dentro dela,
/// por versículo. A trilha aparece uma vez; o trecho, uma vez.
List<ExplainedTrailGroup> groupExplainedMistakes(List<ExplainedMistake> items) {
  final trailOrder = <String>[];
  final byTrail = <String, List<ExplainedMistake>>{};
  for (final item in items) {
    final bucket = byTrail.putIfAbsent(item.trailSlug, () {
      trailOrder.add(item.trailSlug);
      return [];
    });
    bucket.add(item);
  }
  return [
    for (final slug in trailOrder)
      ExplainedTrailGroup(
        trailSlug: slug,
        passages: _passagesOf(byTrail[slug]!),
      ),
  ];
}

List<ExplainedPassageGroup> _passagesOf(List<ExplainedMistake> items) {
  final order = <String>[];
  final byKey = <String, List<ExplainedMistake>>{};
  for (final item in items) {
    final key = _passageKey(item);
    final bucket = byKey.putIfAbsent(key, () {
      order.add(key);
      return [];
    });
    bucket.add(item);
  }
  return [
    for (final key in order)
      ExplainedPassageGroup(key: key, items: byKey[key]!),
  ];
}

String _passageKey(ExplainedMistake item) {
  final ref = (item.verseRef ?? '').trim();
  if (ref.isNotEmpty) return ref;
  final section = item.section.trim();
  if (section.isNotEmpty) return section;
  return item.trailSlug;
}

/// Marcação guardada, ou — só no verdadeiro ou falso antigo — a outra opção.
String? _storedOrInferred(BankQuestion q, String correct, String? stored) {
  final text = stored?.trim() ?? '';
  if (text.isNotEmpty) return text;
  return _yourAnswer(q, correct);
}

/// No verdadeiro ou falso a outra opção é a que a pessoa marcou.
String? _yourAnswer(BankQuestion q, String correct) {
  if (q.type != ExerciseType.trueFalse) return null;
  final others = [
    for (final option in q.options)
      if (option.text.trim().isNotEmpty && option.text.trim() != correct)
        option.text.trim(),
  ];
  if (others.length != 1) return null;
  return others.first;
}

/// O `feedbackCorrect` do banco às vezes abre com "Certo:" ou "Exato:".
/// Na página a resposta já tem o seu lugar; aqui fica só a frase de leitura.
String readingWhy(String why) {
  var text = why.trim();
  if (text.isEmpty) return '';
  final lower = text.toLowerCase();
  const prefixes = [
    'certo:',
    'exato:',
    'correto:',
    'right:',
    'exact:',
    'exactly:',
    'correct:',
    'exacto:',
    'correcto:',
  ];
  var stripped = false;
  for (final prefix in prefixes) {
    if (lower.startsWith(prefix)) {
      text = text.substring(prefix.length).trimLeft();
      stripped = true;
      break;
    }
  }
  if (text.isEmpty) return '';
  if (!stripped) return text;
  final letter = text.indexOf(RegExp(r'[A-Za-zÀ-ÿ]'));
  if (letter < 0) return text;
  return text.replaceRange(letter, letter + 1, text[letter].toUpperCase());
}

/// Explica os erros guardados (mais recentes primeiro), até [cap].
List<ExplainedMistake> explainMistakes({
  required List<String> mistakeIds,
  required BankQuestion? Function(String id) byId,
  Map<String, String> answers = const {},
  int cap = 20,
}) {
  final out = <ExplainedMistake>[];
  for (final id in mistakeIds.reversed) {
    if (out.length >= cap) break;
    final q = byId(id);
    if (q == null) continue;
    final explained = explainBankQuestion(q, yours: answers[id]);
    if (explained != null) out.add(explained);
  }
  return out;
}
