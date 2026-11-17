import 'answer_phrase.dart';
import 'morphology.dart';

const _skipNeedles = {
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

/// Palavras da tradução que não devem roubar um token (artigos, etc.).
const _skipVerseLink = {
  ..._skipNeedles,
  'um',
  'uma',
  'uns',
  'umas',
  'aos',
  'à',
  'às',
};

/// Grupos de tradução: o original e a TB nem sempre usam a mesma palavra.
const _synonymGroups = <List<String>>[
  ['lingua', 'linguagem', 'fala', 'labio', 'idioma'],
  ['palavra', 'palavras', 'expressao', 'expressoes', 'dito', 'ditos'],
  ['tudo', 'todo', 'toda', 'todos', 'todas'],
  ['um', 'uma', 'unico', 'unica', 'mesmo', 'mesma', 'mesmos', 'mesmas'],
  ['ceu', 'ceus'],
  ['principio', 'comeco', 'inicio'],
  ['deus', 'elohim'],
];

final Map<String, int> _synonymIndex = {
  for (var i = 0; i < _synonymGroups.length; i++)
    for (final w in _synonymGroups[i]) w: i,
};

/// Pedacos de gloss para destacar no versículo em português.
List<String> glossNeedles(String gloss) {
  final parts = gloss
      .split(RegExp(r'[,;/·]| e '))
      .map((s) => s.replaceAll(RegExp(r'[\[\]\(\).:]'), '').trim())
      .where((s) => s.isNotEmpty)
      .toList();
  final out = <String>[];
  for (final s in parts) {
    final k = foldKey(s);
    if (k.isEmpty) continue;
    if (s.length >= 3 && !_skipNeedles.contains(k)) {
      out.add(s);
      continue;
    }
    // Gloss curto que É o sentido (um, ti) — não artigo solto no meio de uma lista.
    if (parts.length == 1 && s.length >= 2 && !_skipNeedles.contains(k)) {
      out.add(s);
    }
  }
  return expandSynonyms(out);
}

/// Inclui equivalentes de tradução (língua/linguagem, palavra/expressões).
List<String> expandSynonyms(List<String> needles) {
  final seen = <String>{};
  final out = <String>[];
  void add(String s) {
    final t = s.trim();
    if (t.length < 2) return;
    if (!seen.add(foldKey(t))) return;
    out.add(t);
  }

  for (final n in needles) {
    add(n);
    final i = _synonymIndex[foldKey(n)];
    if (i == null) continue;
    for (final s in _synonymGroups[i]) {
      add(s);
    }
  }
  return out;
}

String _dedupeCommaList(String line) {
  final t = line.trim();
  if (t.isEmpty || t == '---') return '';
  final prefixRe = RegExp(r'^(\d+[a-z]?[\.\)\-]\s+)');
  final m = prefixRe.firstMatch(t);
  final prefix = m?.group(1) ?? '';
  final rest = prefix.isEmpty ? t : t.substring(prefix.length);
  if (!rest.contains(',')) return t;
  final seen = <String>{};
  final bits = <String>[];
  for (final raw in rest.split(',')) {
    final p = raw.trim();
    if (p.isEmpty) continue;
    final k = foldKey(p.replaceAll(RegExp(r'[().]'), ''));
    if (k.length >= 2 && !seen.add(k)) continue;
    bits.add(p);
  }
  return '$prefix${bits.join(', ')}'.trim();
}

/// Quebra definição de léxico em sentidos legíveis, sem repetir sinônimos.
List<String> definitionSenses(String definition) {
  var t = definition.trim();
  if (t.isEmpty) return const [];
  t = t.replaceFirst(RegExp(r'^:[^\n]*\n+'), '');
  t = t.replaceAll('\r\n', '\n');

  final numbered = t
      .split(RegExp(r'(?:^|\n|\s+)\d+[a-z]?[\.\)\-]\s+'))
      .map(_dedupeCommaList)
      .where((s) => s.isNotEmpty && s != '---')
      .toList();
  if (numbered.length >= 2) return numbered;

  final lines = t
      .split(RegExp(r'\n+'))
      .map(_dedupeCommaList)
      .where((s) => s.isNotEmpty)
      .map((s) => s.replaceFirst(RegExp(r'^\d+[a-z]?[\.\)\-]\s+'), ''))
      .where((s) => s.isNotEmpty)
      .toList();
  if (lines.length >= 2) return lines;

  final semi = t
      .split(';')
      .map(_dedupeCommaList)
      .where((s) => s.length > 18)
      .toList();
  if (semi.length >= 2) return semi;
  final one = _dedupeCommaList(t);
  return one.isEmpty ? const [] : [one];
}

/// Coloca na frente o sentido que casa com o versículo.
List<String> rankDefinitionSenses(List<String> senses, List<String> needles) {
  if (senses.length <= 1 || needles.isEmpty) return senses;
  final scored = <({String sense, int score})>[];
  for (final s in senses) {
    final words = s.split(RegExp(r'[,;/·()]|\s+'));
    var best = 0;
    for (final raw in words) {
      final w = raw.trim();
      if (w.length < 3) continue;
      for (final n in needles) {
        final sc = _needleScore(w, n);
        if (sc > best) best = sc;
      }
    }
    scored.add((sense: s, score: best));
  }
  scored.sort((a, b) => b.score.compareTo(a.score));
  return [for (final s in scored) s.sense];
}

int _needleScore(String word, String needle) {
  final w = foldKey(word);
  final n = foldKey(needle);
  if (n.length < 2 || w.length < 2) return 0;
  if (w == n) return 10;
  if (!wordMatchesNeedle(word, needle)) return 0;
  final wi = _synonymIndex[w];
  final ni = _synonymIndex[n];
  if (wi != null && wi == ni && w != n) return 5;
  if (w.length == n.length + 1 && w.startsWith(n) && w.endsWith('s')) return 9;
  if (n.length == w.length + 1 && n.startsWith(w) && n.endsWith('s')) return 9;
  final ws = _stemPt(w);
  final ns = _stemPt(n);
  if (ws.length >= 3 && ns.length >= 3 && ws == ns) return 8;
  return 7;
}

/// Escolhe o sentido que o versículo em português realmente usa.
String alignGlossToVerse(String verse, String gloss, {String definition = ''}) {
  final candidates = <String>[];
  void add(String raw) {
    final t = raw.trim();
    if (t.length < 2) return;
    if (candidates.any((c) => foldKey(c) == foldKey(t))) return;
    candidates.add(t);
  }

  for (final bit in gloss.split(RegExp(r'[,;/·:]'))) {
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

  final firstSense = candidates.first;
  final firstWords = firstSense
      .split(RegExp(r'\s+'))
      .where((w) => w.length >= 2)
      .toList();
  if (firstWords.length >= 2 &&
      firstWords.length <= 4 &&
      firstWords.any(
        (w) =>
            !_skipVerseLink.contains(foldKey(w)) &&
            highlightRanges(verse, [w]).isNotEmpty,
      )) {
    return firstSense;
  }

  String best = candidates.first;
  var bestScore = -1;
  String? verseWord;
  for (final c in [...candidates, ...expandSynonyms(candidates)]) {
    final ranges = highlightRanges(verse, [c]);
    if (ranges.isEmpty) continue;
    final word = verse.substring(ranges.first.start, ranges.first.end);
    if (_skipVerseLink.contains(foldKey(word))) continue;
    var score = _needleScore(word, c);
    if (word.length >= 5) score += 2;
    if (word.length >= 4) score += 1;
    if (score > bestScore) {
      bestScore = score;
      best = c;
      verseWord = word;
    }
  }
  if (bestScore <= 0) return candidates.first;
  return verseWord ?? best;
}

/// Needles para destacar no versículo, incluindo pronomes curtos (ti, eu).
List<String> studyNeedles(
  String gloss,
  String morph, {
  String verseGloss = '',
}) {
  final out = <String>[...glossNeedles(gloss), ...glossNeedles(verseGloss)];
  final pn = suffixPronounPt(morph);
  if (pn != null && pn.length >= 2) out.add(pn);
  final seen = <String>{};
  return [
    for (final n in expandSynonyms(out))
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

class _LinkCand {
  final int start;
  final int end;
  final int tokenPos;
  final int score;
  const _LinkCand(this.start, this.end, this.tokenPos, this.score);
}

/// Liga cada palavra da tradução a um token original (interlinear reverso).
List<VerseWordLink> linkVerseToTokens(String verse, List<TokenNeedle> tokens) {
  if (verse.isEmpty || tokens.isEmpty) return const [];
  final wordRe = RegExp(r'[\p{L}\p{M}]+', unicode: true);
  final words = wordRe.allMatches(verse).toList();
  if (words.isEmpty) return const [];

  final cands = <_LinkCand>[];
  for (var wi = 0; wi < words.length; wi++) {
    final m = words[wi];
    final word = m.group(0)!;
    if (_skipVerseLink.contains(foldKey(word))) continue;
    for (var ti = 0; ti < tokens.length; ti++) {
      final t = tokens[ti];
      if (t.needles.isEmpty) continue;
      var best = 0;
      for (final n in t.needles) {
        final s = _needleScore(word, n);
        if (s > best) best = s;
      }
      if (best <= 0) continue;
      final wp = words.length == 1 ? 0.0 : wi / (words.length - 1);
      final tp = tokens.length == 1 ? 0.0 : ti / (tokens.length - 1);
      final posBonus = ((1 - (wp - tp).abs()) * 2).round();
      final lenBonus = word.length >= 5 ? 2 : (word.length >= 4 ? 1 : 0);
      cands.add(_LinkCand(m.start, m.end, t.pos, best + posBonus + lenBonus));
    }
  }
  cands.sort((a, b) => b.score.compareTo(a.score));
  final usedToken = <int>{};
  final usedStart = <int>{};
  final out = <VerseWordLink>[];
  for (final c in cands) {
    if (!usedToken.add(c.tokenPos)) continue;
    if (!usedStart.add(c.start)) continue;
    out.add(VerseWordLink(c.start, c.end, c.tokenPos));
  }
  out.sort((a, b) => a.start.compareTo(b.start));
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
  final wi = _synonymIndex[w];
  final ni = _synonymIndex[n];
  if (wi != null && wi == ni) return true;
  if (n.length < 3 || w.length < 3) return false;
  // Plural curto: céu/céus.
  if (w.length == n.length + 1 && w.startsWith(n) && w.endsWith('s')) {
    return true;
  }
  if (n.length == w.length + 1 && n.startsWith(w) && n.endsWith('s')) {
    return true;
  }
  // expressões / expressão
  if (w.endsWith('oes') &&
      n.endsWith('ao') &&
      w.length > 4 &&
      n.length > 3 &&
      w.substring(0, w.length - 3) == n.substring(0, n.length - 2)) {
    return true;
  }
  if (n.endsWith('oes') &&
      w.endsWith('ao') &&
      n.length > 4 &&
      w.length > 3 &&
      n.substring(0, n.length - 3) == w.substring(0, w.length - 2)) {
    return true;
  }
  // Irregulars of the Portuguese Bible (disse/dizer, fez/fazer…).
  final vw = _verbFamily(w);
  final vn = _verbFamily(n);
  if (vw != null && vn != null && vw == vn) return true;
  final verbish = !_notVerbForms.contains(w) && !_notVerbForms.contains(n);
  if (verbish && _regularVerbMatch(w, n)) return true;
  final ws = _stemPt(w);
  final ns = _stemPt(n);
  if (ws.length >= 3 && ns.length >= 3 && ws == ns) {
    return true;
  }
  // Prefix on short verb roots (faz↔façamos, diz↔dizem).
  if (verbish &&
      ws.length >= 3 &&
      ns.length >= 3 &&
      (w.startsWith(ns) || n.startsWith(ws))) {
    final shorter = ws.length <= ns.length ? ws : ns;
    final longer = w.length >= n.length ? w : n;
    if (longer.startsWith(shorter) &&
        _looksLikeVerbEnding(longer.substring(shorter.length))) {
      return true;
    }
  }
  if (ws.length >= 4 &&
      ns.length >= 4 &&
      (w.startsWith(ns) || n.startsWith(ws))) {
    return true;
  }
  return false;
}

/// Famílias verbais irregulares frequentes na TB/NVI.
/// Só formas distintivas — nunca partículas (e, de, da, a…).
/// Chave = foldKey(forma); valor = raiz canônica (≥3 letras).
const _irregularVerbForms = <String, String>{
  // dizer
  'dizer': 'diz', 'disse': 'diz', 'disseram': 'diz', 'dissemos': 'diz',
  'digo': 'diz', 'dizes': 'diz', 'dizem': 'diz', 'diga': 'diz',
  'digamos': 'diz', 'digam': 'diz', 'dizia': 'diz', 'diziam': 'diz',
  'dito': 'diz', 'diriam': 'diz',
  // fazer
  'fazer': 'faz', 'fez': 'faz', 'fizeram': 'faz', 'fizemos': 'faz',
  'faco': 'faz', 'fazes': 'faz', 'fazem': 'faz', 'faca': 'faz',
  'facamos': 'faz', 'facam': 'faz', 'fazia': 'faz', 'faziam': 'faz',
  'feito': 'faz', 'feita': 'faz', 'feitos': 'faz', 'feitas': 'faz',
  'farei': 'faz', 'fara': 'faz',
  // ver
  'ver': 'ver', 'viu': 'ver', 'viram': 'ver', 'vejo': 'ver',
  'veja': 'ver', 'vejamos': 'ver', 'visto': 'ver',
  // vir
  'vir': 'vin', 'veio': 'vin', 'vieram': 'vin', 'venho': 'vin',
  'venha': 'vin', 'viemos': 'vin', 'vindo': 'vin',
  // pôr
  'ponho': 'pon', 'ponha': 'pon', 'puseram': 'pon', 'posto': 'pon',
  // ter
  'ter': 'ter', 'teve': 'ter', 'tiveram': 'ter', 'tenho': 'ter',
  'tenha': 'ter', 'tido': 'ter', 'tinha': 'ter', 'tinham': 'ter',
  // ser (sem "é"/"e" — colide com a conjunção)
  'ser': 'ser', 'foi': 'ser', 'foram': 'ser', 'somos': 'ser',
  'seja': 'ser', 'sendo': 'ser', 'eram': 'ser', 'sido': 'ser',
  // ir (sem "foi" — já em ser; gloss/posição desambiguam)
  'ir': 'ir', 'vou': 'ir', 'vamos': 'ir', 'indo': 'ir',
  // dar (sem "da"/"de")
  'dar': 'dar', 'deu': 'dar', 'deram': 'dar', 'dou': 'dar',
  'demos': 'dar', 'dado': 'dar',
  // haver / estar
  'haver': 'hav', 'havia': 'hav', 'houve': 'hav', 'houveram': 'hav',
  'estar': 'est', 'estive': 'est', 'esteve': 'est', 'estavam': 'est',
  'esteja': 'est',
  // saber / poder / querer / trazer
  'saber': 'sab', 'soube': 'sab', 'saiba': 'sab',
  'poder': 'pod', 'pude': 'pod', 'puderam': 'pod', 'possa': 'pod',
  'possam': 'pod',
  'querer': 'quer', 'quis': 'quer', 'quiseram': 'quer',
  'trazer': 'traz', 'trouxe': 'traz', 'trouxeram': 'traz',
};

/// Palavras frequentes que parecem raiz+desinência mas não são verbo
/// (esta≠estar, como≠comer, para≠parar, casa≠casar).
const _notVerbForms = {
  'este', 'esta', 'estes', 'estas', 'como', 'para', 'pela', 'pelo',
  'pelas', 'pelos', 'casa', 'casas',
};

String? _verbFamily(String folded) => _irregularVerbForms[folded];

bool _isInfinitive(String folded) =>
    folded.length > 3 &&
    (folded.endsWith('ar') || folded.endsWith('er') || folded.endsWith('ir'));

/// Desinências verbais PT depois da raiz (faç+amos, cri+ou, domin+e).
bool _looksLikeVerbEnding(String rest) {
  if (rest.isEmpty) return true;
  const endings = {
    'o', 'a', 'e', 'i', 'as', 'es', 'is', 'am', 'em', 'im',
    'amos', 'emos', 'imos', 'ais', 'eis',
    'ou', 'eu', 'iu', 'ei',
    'aram', 'eram', 'iram',
    'ava', 'avam', 'ia', 'iam',
    'asse', 'esse', 'isse', 'assem', 'essem', 'issem',
    'armos', 'ermos', 'irmos',
    'ado', 'idos', 'ida', 'idas', 'ido',
    'ando', 'endo', 'indo',
    'arei', 'erei', 'irei', 'ara', 'era', 'ira',
    'se', // disse = diz+se
  };
  return endings.contains(rest);
}

bool _regularVerbMatch(String a, String b) {
  final String inf;
  final String form;
  if (_isInfinitive(a) && !_isInfinitive(b)) {
    inf = a;
    form = b;
  } else if (_isInfinitive(b) && !_isInfinitive(a)) {
    inf = b;
    form = a;
  } else {
    return false;
  }
  final root = inf.substring(0, inf.length - 2);
  if (root.length < 3) return false;
  if (form.startsWith(root) &&
      _looksLikeVerbEnding(form.substring(root.length))) {
    return true;
  }
  // Soft mutation: ficar→fiquemos, chegar→cheguemos.
  if (root.endsWith('c')) {
    final mutated = '${root.substring(0, root.length - 1)}qu';
    if (form.startsWith(mutated) &&
        _looksLikeVerbEnding(form.substring(mutated.length))) {
      return true;
    }
  }
  if (root.endsWith('g')) {
    final mutated = '${root.substring(0, root.length - 1)}gu';
    if (form.startsWith(mutated) &&
        _looksLikeVerbEnding(form.substring(mutated.length))) {
      return true;
    }
  }
  return false;
}

String _stemPt(String s) {
  final family = _irregularVerbForms[s];
  if (family != null && family.length >= 3) return family;
  if (s.length >= 5 && (s.endsWith('ou') || s.endsWith('am'))) {
    return s.substring(0, s.length - 2);
  }
  if (s.length > 4 &&
      (s.endsWith('ar') ||
          s.endsWith('er') ||
          s.endsWith('ir') ||
          s.endsWith('ado') ||
          s.endsWith('ido'))) {
    return s.substring(
      0,
      s.length - (s.endsWith('ado') || s.endsWith('ido') ? 3 : 2),
    );
  }
  if (s.length >= 6 &&
      (s.endsWith('amos') ||
          s.endsWith('emos') ||
          s.endsWith('imos') ||
          s.endsWith('aram') ||
          s.endsWith('eram') ||
          s.endsWith('iram'))) {
    return s.substring(0, s.length - 4);
  }
  if (s.length > 4 &&
      (s.endsWith('os') || s.endsWith('as') || s.endsWith('es'))) {
    return s.substring(0, s.length - 1);
  }
  return s;
}

/// Formas da TB que casam com [needles] nos versículos amostrados.
List<({String word, int count})> translationFormsInVerses(
  Iterable<String> verses,
  List<String> needles, {
  int limit = 6,
}) {
  if (needles.isEmpty) return const [];
  final counts = <String, int>{};
  final display = <String, String>{};
  for (final text in verses) {
    if (text.isEmpty) continue;
    for (final r in highlightRanges(text, needles)) {
      final raw = text.substring(r.start, r.end);
      final k = foldKey(raw);
      if (k.length < 2 || _skipVerseLink.contains(k)) continue;
      counts[k] = (counts[k] ?? 0) + 1;
      display.putIfAbsent(k, () => raw);
    }
  }
  final keys = counts.keys.toList()
    ..sort((a, b) {
      final c = counts[b]!.compareTo(counts[a]!);
      return c != 0 ? c : a.compareTo(b);
    });
  return [
    for (final k in keys.take(limit)) (word: display[k]!, count: counts[k]!),
  ];
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
