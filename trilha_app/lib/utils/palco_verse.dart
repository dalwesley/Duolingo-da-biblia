import '../models/trail.dart';
import '../services/bible_service.dart';

/// Palco das perguntas: JFAAL (Almeida), não a TB do banco.
class PalcoVerse {
  PalcoVerse._();

  static String get translationId => BibleService.palcoTranslationId;

  static Future<String?> of(String? ref) async {
    final r = (ref ?? '').trim();
    if (r.isEmpty || !BibleService.looksLikeReference(r)) return null;
    try {
      final text = await BibleService.instance.passageText(
        r,
        translationId: translationId,
      );
      final t = (text ?? '').trim();
      return t.isEmpty ? null : t;
    } catch (_) {
      return null;
    }
  }

  static Future<List<Exercise>> hydrateAll(List<Exercise> acts) async {
    if (acts.isEmpty) return acts;
    final refs = <String>{};
    for (final ex in acts) {
      final r = (ex.reference ?? '').trim();
      if (r.isNotEmpty) refs.add(r);
      final a = (ex.passageA?.ref ?? '').trim();
      if (a.isNotEmpty) refs.add(a);
      final b = (ex.passageB?.ref ?? '').trim();
      if (b.isNotEmpty) refs.add(b);
    }
    final cache = <String, String?>{};
    for (final ref in refs) {
      cache[ref] = await of(ref);
    }
    return [for (final ex in acts) applyCached(ex, cache)];
  }

  static Future<Exercise> hydrate(Exercise ex) async {
    final cache = <String, String?>{
      if ((ex.reference ?? '').trim().isNotEmpty)
        ex.reference!.trim(): await of(ex.reference),
      if ((ex.passageA?.ref ?? '').trim().isNotEmpty)
        ex.passageA!.ref.trim(): await of(ex.passageA!.ref),
      if ((ex.passageB?.ref ?? '').trim().isNotEmpty)
        ex.passageB!.ref.trim(): await of(ex.passageB!.ref),
    };
    return applyCached(ex, cache);
  }

  static Exercise applyCached(Exercise ex, Map<String, String?> cache) {
    final ref = (ex.reference ?? '').trim();
    final live = (cache[ref] ?? '').trim();
    final keep = _keepSnippet(ex);
    return apply(
      ex,
      live: live.isEmpty ? null : live,
      passageA: _livePassage(ex.passageA, cache, keepSnippet: keep),
      passageB: _livePassage(ex.passageB, cache, keepSnippet: keep),
    );
  }

  static bool _keepSnippet(Exercise ex) =>
      ex.type == ExerciseType.connect || ex.type == ExerciseType.match;

  static ExercisePassage? _livePassage(
    ExercisePassage? passage,
    Map<String, String?> cache, {
    bool keepSnippet = false,
  }) {
    if (passage == null) return null;
    final ref = passage.ref.trim();
    final live = (cache[ref] ?? '').trim();
    if (keepSnippet || live.isEmpty) {
      final fitted = fitSnippet(passage.text, live);
      if (fitted == passage.text) return passage;
      return ExercisePassage(ref: passage.ref, text: fitted);
    }
    return ExercisePassage(ref: passage.ref, text: live);
  }

  /// Sobreposição síncrona — testes e fallback sem asset.
  static Exercise apply(
    Exercise ex, {
    String? live,
    ExercisePassage? passageA,
    ExercisePassage? passageB,
  }) {
    final liveText = (live ?? '').trim();
    final passage = liveText.isNotEmpty
        ? liveText
        : swapDivineName(ex.passageText ?? '');

    final options = [
      for (final o in ex.options)
        QuestionOption(
          id: o.id,
          text: _keepSnippet(ex)
              ? swapDivineName(o.text)
              : fitPhrase(o.text, passage),
        ),
    ];
    final targets = [for (final t in ex.targets) fitPhrase(t, passage)];
    final matchLeft = [
      for (final o in ex.matchLeft)
        QuestionOption(id: o.id, text: swapDivineName(o.text)),
    ];
    final matchRight = [
      for (final o in ex.matchRight)
        QuestionOption(id: o.id, text: swapDivineName(o.text)),
    ];

    var template = ex.template;
    if (ex.type == ExerciseType.complete || ex.type == ExerciseType.tap) {
      String? correct;
      for (final o in options) {
        if (o.id == ex.resolvedCorrectAnswer && o.text.trim().isNotEmpty) {
          correct = o.text.trim();
          break;
        }
      }
      final rebuilt = cloze(passage, correct);
      if (rebuilt != null) {
        template = rebuilt;
      } else if (template != null) {
        template = swapDivineName(template);
      }
    } else if (template != null) {
      template = swapDivineName(template);
    }

    final nextPassage = passage.trim().isNotEmpty
        ? passage
        : (ex.passageText == null ? null : swapDivineName(ex.passageText!));

    return Exercise(
      id: ex.id,
      type: ex.type,
      skill: ex.skill,
      prompt: swapDivineName(ex.prompt),
      correctAnswer: ex.correctAnswer,
      cue: ex.cue == null ? null : swapDivineName(ex.cue!),
      reference: ex.reference,
      passageText: nextPassage,
      options: options,
      feedbackCorrect: swapDivineName(ex.feedbackCorrect),
      feedbackWrong: {
        for (final e in ex.feedbackWrong.entries)
          e.key: swapDivineName(e.value),
      },
      retryHint: ex.retryHint == null ? null : swapDivineName(ex.retryHint!),
      targets: targets,
      passageA:
          passageA ??
          _livePassage(ex.passageA, const {}, keepSnippet: _keepSnippet(ex)),
      passageB:
          passageB ??
          _livePassage(ex.passageB, const {}, keepSnippet: _keepSnippet(ex)),
      beat: ex.beat,
      note: ex.note == null ? null : swapDivineName(ex.note!),
      noteLabel: ex.noteLabel,
      instruction: ex.instruction,
      correctOrder: ex.correctOrder,
      template: template,
      correctPairs: ex.correctPairs,
      matchLeft: matchLeft,
      matchRight: matchRight,
    );
  }

  /// Recorte pedagógico: alinha o trecho à Almeida sem estourar o versículo inteiro.
  static String fitSnippet(String authored, String live) {
    final raw = authored.trim();
    if (raw.isEmpty) return authored;
    final swapped = swapDivineName(raw);
    final verse = live.trim();
    if (verse.isEmpty) return swapped;
    final hit = _containedSpan(verse, swapped) ?? _containedSpan(verse, raw);
    if (hit != null) return hit;
    final aligned = _alignSnippet(verse, swapped);
    if (aligned != null) return aligned;
    return swapped;
  }

  static String? _containedSpan(String haystack, String needle) {
    final n = needle.trim();
    if (n.isEmpty) return null;
    final lower = haystack.toLowerCase();
    final want = n.toLowerCase();
    var from = 0;
    while (true) {
      final i = lower.indexOf(want, from);
      if (i < 0) return null;
      final end = i + n.length;
      if (!_isLetterAt(haystack, i - 1) && !_isLetterAt(haystack, end)) {
        return haystack.substring(i, end);
      }
      from = i + 1;
    }
  }

  static final _stop = {
    'o',
    'a',
    'os',
    'as',
    'um',
    'uma',
    'de',
    'da',
    'do',
    'das',
    'dos',
    'e',
    'é',
    'em',
    'no',
    'na',
    'nos',
    'nas',
    'por',
    'para',
    'com',
    'mas',
    'que',
    'se',
    'ao',
    'à',
    'às',
    'aos',
  };

  static String _stemLight(String w) {
    var s = w.toLowerCase();
    if (s.length > 3 && s.endsWith('s')) s = s.substring(0, s.length - 1);
    return s;
  }

  static List<String> _contentWords(String text) {
    return RegExp(r'\p{L}+', unicode: true)
        .allMatches(text)
        .map((m) => _stemLight(m.group(0)!))
        .where((w) => w.length >= 3 && !_stop.contains(w))
        .toList();
  }

  static String? _alignSnippet(String live, String snippet) {
    final needles = _contentWords(snippet).toSet();
    if (needles.length < 2) return null;
    final tokens = <({String key, int start, int end})>[];
    for (final m in RegExp(r'\p{L}+', unicode: true).allMatches(live)) {
      tokens.add((
        key: _stemLight(m.group(0)!),
        start: m.start,
        end: m.end,
      ));
    }
    if (tokens.isEmpty) return null;

    bool hits(String token, Set<String> pool) {
      for (final n in pool) {
        if (token == n) return true;
        if (token.length >= 4 && (n.startsWith(token) || token.startsWith(n))) {
          return true;
        }
      }
      return false;
    }

    final present = needles
        .where((n) => tokens.any((t) => hits(t.key, {n})))
        .toSet();
    if (present.length < 2) return null;
    final need = present.length;
    var bestLo = 0;
    var bestHi = tokens.length - 1;
    var best = tokens.length + 1;
    for (var lo = 0; lo < tokens.length; lo++) {
      final seen = <String>{};
      for (var hi = lo; hi < tokens.length; hi++) {
        for (final n in present) {
          if (hits(tokens[hi].key, {n})) seen.add(n);
        }
        if (seen.length >= need) {
          final span = hi - lo;
          if (span < best) {
            best = span;
            bestLo = lo;
            bestHi = hi;
          }
          break;
        }
      }
    }
    if (best > tokens.length) return null;
    var start = tokens[bestLo].start;
    final end = tokens[bestHi].end;
    final lead = snippet.trim().toLowerCase();
    if (start > 0 &&
        (lead.startsWith('o ') ||
            lead.startsWith('a ') ||
            lead.startsWith('e '))) {
      final prefix = live.substring(0, start);
      final m = RegExp(r'([oae])\s*$', caseSensitive: false).firstMatch(prefix);
      if (m != null && lead.startsWith('${m[1]!.toLowerCase()} ')) {
        start = m.start;
      }
    }
    final out = live.substring(start, end);
    if (out.length > snippet.length * 3 && out.length > live.length * 0.55) {
      return null;
    }
    return out;
  }

  static String fitPhrase(String text, String live) {
    final raw = text.trim();
    if (raw.isEmpty) return text;
    if (live.isNotEmpty && containsPhrase(live, raw)) return raw;
    if (raw == 'Jeová' &&
        live.isNotEmpty &&
        containsPhrase(live, 'Senhor')) {
      return 'Senhor';
    }
    final swapped = swapDivineName(raw);
    if (swapped != raw &&
        (live.isEmpty || containsPhrase(live, swapped))) {
      return swapped;
    }
    return swapped;
  }

  static String? cloze(String passage, String? word) {
    final verse = passage.trim();
    final needle = (word ?? '').trim();
    if (verse.isEmpty || needle.isEmpty) return null;
    final lower = verse.toLowerCase();
    final n = needle.toLowerCase();
    var from = 0;
    while (true) {
      final i = lower.indexOf(n, from);
      if (i < 0) return null;
      final end = i + n.length;
      if (!_isLetterAt(verse, i - 1) && !_isLetterAt(verse, end)) {
        return '${verse.substring(0, i)}___${verse.substring(end)}';
      }
      from = i + 1;
    }
  }

  static bool containsPhrase(String haystack, String needle) {
    final n = needle.trim();
    if (n.isEmpty) return false;
    final lower = haystack.toLowerCase();
    final want = n.toLowerCase();
    var from = 0;
    while (true) {
      final i = lower.indexOf(want, from);
      if (i < 0) return false;
      final end = i + want.length;
      if (!_isLetterAt(haystack, i - 1) && !_isLetterAt(haystack, end)) {
        return true;
      }
      from = i + 1;
    }
  }

  /// TB usa Jeová; Almeida lê Senhor.
  static String swapDivineName(String text) {
    if (!text.contains('Jeová')) return text;
    var out = text
        .replaceAll('Senhor Jeová', 'Senhor')
        .replaceAll('Jeová Deus', 'Senhor Deus')
        .replaceAll('Deus Jeová', 'Senhor Deus')
        .replaceAll('Jeová-Jiré', 'O Senhor Proverá')
        .replaceAll(' a Jeová', ' ao Senhor')
        .replaceAll(' de Jeová', ' do Senhor')
        .replaceAll(' em Jeová', ' no Senhor');
    out = out.replaceAllMapped(
      RegExp(r'(^|[.!?…]\s*)Jeová'),
      (m) => '${m[1]}O Senhor',
    );
    out = out.replaceAll('Jeová', 'o Senhor');
    out = out.replaceAll('O o Senhor', 'O Senhor');
    out = out.replaceAll('o o Senhor', 'o Senhor');
    return out;
  }

  static final _letter = RegExp(r'\p{L}', unicode: true);

  static bool _isLetterAt(String text, int i) {
    if (i < 0 || i >= text.length) return false;
    return _letter.hasMatch(text[i]);
  }
}
