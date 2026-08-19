import 'answer_phrase.dart';

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

class HighlightRange {
  final int start;
  final int end;
  const HighlightRange(this.start, this.end);
}

bool wordMatchesNeedle(String word, String needle) {
  final w = foldKey(word);
  final n = foldKey(needle);
  if (n.length < 3 || w.length < 3) return false;
  if (w == n) return true;
  final ws = _stemPt(w);
  final ns = _stemPt(n);
  if (ws.length >= 4 && ns.length >= 4 && (ws == ns || w.startsWith(ns))) {
    return true;
  }
  return false;
}

String _stemPt(String s) {
  if (s.length > 5 && (s.endsWith('ou') || s.endsWith('am'))) {
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
