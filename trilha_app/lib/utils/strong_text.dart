import 'answer_phrase.dart';
import 'morphology.dart';

/// Pedacos de gloss para destacar no versículo em português.
List<String> glossNeedles(String gloss) {
  const skip = {
    'obj',
    'o',
    'a',
    'os',
    'as',
    'de',
    'do',
    'da',
    'dos',
    'das',
    'e',
    'em',
    'um',
    'uma',
    'que',
    'para',
    'com',
    'por',
    'se',
    'ao',
    'no',
    'na',
    'nos',
    'nas',
    'the',
    'of',
    'to',
    'and',
  };
  return gloss
      .split(RegExp(r'[,;/·]| e '))
      .map((s) => s.replaceAll(RegExp(r'[\[\]\(\).:]'), '').trim())
      .where((s) => s.length >= 3 && !skip.contains(foldKey(s)))
      .toList();
}

/// Quebra definição de léxico em sentidos legíveis.
List<String> definitionSenses(String definition) {
  final t = definition.trim();
  if (t.isEmpty) return const [];

  final numbered = t
      .split(RegExp(r'(?:^|\s+)\d+[\.\)\-]\s+'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  if (numbered.length >= 2) return numbered;

  final lines = t
      .split(RegExp(r'\n+'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  if (lines.length >= 2) return lines;

  final semi = t
      .split(';')
      .map((s) => s.trim())
      .where((s) => s.length > 18)
      .toList();
  if (semi.length >= 2) return semi;
  return [t];
}

/// Escolhe o sentido que o versículo em português realmente usa.
String alignGlossToVerse(
  String verse,
  String gloss, {
  String definition = '',
}) {
  final candidates = <String>[];
  void add(String raw) {
    final t = raw.trim();
    if (t.length < 2) return;
    if (candidates.any((c) => foldKey(c) == foldKey(t))) return;
    candidates.add(t);
  }

  for (final bit in gloss.split(RegExp(r'[,;/·]'))) {
    add(bit);
    for (final w in bit.trim().split(RegExp(r'\s+'))) {
      if (w.length >= 2) add(w);
    }
  }
  for (final sense in definitionSenses(definition).take(4)) {
    final first = sense.split(RegExp(r'[.,;:]')).first.trim();
    if (first.split(RegExp(r'\s+')).length <= 5) add(first);
    for (final n in glossNeedles(sense).take(3)) {
      add(n);
    }
  }
  if (candidates.isEmpty) return gloss.trim();

  final firstSense = gloss.split(RegExp(r'[,;/·]')).first.trim();
  final firstWords = firstSense.split(RegExp(r'\s+')).where((w) => w.length >= 2);
  if (firstWords.length <= 3 &&
      firstWords.any((w) => highlightRanges(verse, [w]).isNotEmpty)) {
    return firstSense;
  }

  String best = candidates.first;
  var bestScore = -1;
  for (final c in candidates) {
    if (highlightRanges(verse, [c]).isEmpty) continue;
    final score = c.length >= 4 ? 4 : 3;
    if (score > bestScore) {
      bestScore = score;
      best = c;
    }
  }
  return bestScore > 0 ? best : candidates.first;
}

/// Needles para destacar no versículo, incluindo pronomes curtos (ti, eu).
List<String> studyNeedles(
  String gloss,
  String morph, {
  String verseGloss = '',
}) {
  final out = <String>[
    ...glossNeedles(gloss),
    ...glossNeedles(verseGloss),
  ];
  final pn = suffixPronounPt(morph);
  if (pn != null && pn.length >= 2) out.add(pn);
  final seen = <String>{};
  return [
    for (final n in out)
      if (seen.add(foldKey(n))) n,
  ];
}

class TokenNeedle {
  final int pos;
  final List<String> needles;
  const TokenNeedle(this.pos, this.needles);
}

class VerseWordLink {
  final int start;
  final int end;
  final int tokenPos;
  const VerseWordLink(this.start, this.end, this.tokenPos);
}

/// Liga cada palavra da tradução a um token original (interlinear reverso).
List<VerseWordLink> linkVerseToTokens(
  String verse,
  List<TokenNeedle> tokens,
) {
  if (verse.isEmpty || tokens.isEmpty) return const [];
  final wordRe = RegExp(r'[\p{L}\p{M}]+', unicode: true);
  final used = <int>{};
  final out = <VerseWordLink>[];
  for (final m in wordRe.allMatches(verse)) {
    final word = m.group(0)!;
    TokenNeedle? hit;
    for (final t in tokens) {
      if (t.needles.isEmpty || used.contains(t.pos)) continue;
      if (t.needles.any((n) => wordMatchesNeedle(word, n))) {
        hit = t;
        break;
      }
    }
    if (hit == null) continue;
    used.add(hit.pos);
    out.add(VerseWordLink(m.start, m.end, hit.pos));
  }
  return out;
}

class HighlightRange {
  final int start;
  final int end;
  const HighlightRange(this.start, this.end);
}

bool wordMatchesNeedle(String word, String needle) {
  final w = foldKey(word);
  final n = foldKey(needle);
  if (n.length < 2 || w.length < 2) return false;
  if (w == n) return true;
  if (n.length < 3 || w.length < 3) return false;
  // Plural curto: céu/céus, terra não entra (terras já cai no stem).
  if (w.length == n.length + 1 && w.startsWith(n) && w.endsWith('s')) {
    return true;
  }
  if (n.length == w.length + 1 && n.startsWith(w) && n.endsWith('s')) {
    return true;
  }
  final ws = _stemPt(w);
  final ns = _stemPt(n);
  if (ws.length >= 3 && ns.length >= 3 && ws == ns) {
    return true;
  }
  if (ws.length >= 4 && ns.length >= 4 && (w.startsWith(ns) || n.startsWith(ws))) {
    return true;
  }
  return false;
}

String _stemPt(String s) {
  if (s.length >= 5 && (s.endsWith('ou') || s.endsWith('am'))) {
    return s.substring(0, s.length - 2);
  }
  if (s.length > 4 &&
      (s.endsWith('ar') ||
          s.endsWith('er') ||
          s.endsWith('ir') ||
          s.endsWith('ado') ||
          s.endsWith('ido'))) {
    return s.substring(0, s.length - (s.endsWith('ado') || s.endsWith('ido') ? 3 : 2));
  }
  if (s.length > 4 && (s.endsWith('os') || s.endsWith('as') || s.endsWith('es'))) {
    return s.substring(0, s.length - 1);
  }
  return s;
}

/// Intervalos no texto original que coincidem com os needles (palavras).
List<HighlightRange> highlightRanges(String text, List<String> needles) {
  if (text.isEmpty || needles.isEmpty) return const [];
  final wordRe = RegExp(r'[\p{L}\p{M}]+', unicode: true);
  final out = <HighlightRange>[];
  for (final m in wordRe.allMatches(text)) {
    final word = m.group(0)!;
    if (needles.any((n) => wordMatchesNeedle(word, n))) {
      out.add(HighlightRange(m.start, m.end));
    }
  }
  return out;
}
