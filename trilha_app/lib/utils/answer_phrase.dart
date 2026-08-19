import '../models/trail.dart';

final _danglingStart = RegExp(r'^(e|mas|porém|porem|ou|nem)\s+', caseSensitive: false);
final _danglingEnd = RegExp(
  r'\s+(e|mas|ou|nem|de|do|da|dos|das|que|para|por|com|os|as|o|a|ao|à)$',
  caseSensitive: false,
);
final _hangingPrep = RegExp(r'^(de|do|da|dos|das|sobre)\s+\S+$', caseSensitive: false);
final _quote = RegExp(r'[“"«]([^”"»]+)[”"»]');
final _det = r'(?:o|os|a|as|um|uma|ao|à|às|aos|do|da|dos|das|de|no|na|nos|nas)';
final _word = r'[\p{L}]+(?:-[\p{L}]+)?';

String foldKey(String s) {
  var t = s.toLowerCase().trim();
  t = t
      .replaceAll(RegExp(r'[áàâãä]'), 'a')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[íìîï]'), 'i')
      .replaceAll(RegExp(r'[óòôõö]'), 'o')
      .replaceAll(RegExp(r'[úùûü]'), 'u')
      .replaceAll('ç', 'c');
  return t.replaceAll(RegExp(r'\s+'), ' ');
}

String answerKey(String s) {
  return foldKey(s)
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) {
        if (w == 'os' || w == 'o') return 'o';
        if (w == 'as' || w == 'a') return 'a';
        if (w.endsWith('s') && w.length > 3) return w.substring(0, w.length - 1);
        return w;
      })
      .join(' ');
}

String extractQuotedAnswer(String feedback) {
  final m = _quote.firstMatch(feedback);
  return (m?.group(1) ?? '').trim();
}

int _words(String s) =>
    s.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

bool isIncompletePhrase(String text) {
  final t = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (t.isEmpty) return true;
  if (t.endsWith('…') && t.length < 36) return true;
  if (_danglingEnd.hasMatch(t)) return true;
  if (_hangingPrep.hasMatch(t)) return true;
  if (_danglingStart.hasMatch(t)) {
    final n = _words(t);
    if (t.contains(':') && n >= 4) return false;
    if (t.contains(',') && n >= 5) return false;
    if (n >= 5) return false;
    if (RegExp(r'^(e|mas|ou|nem)\s+(o|a|os|as|um|uma)\b', caseSensitive: false)
            .hasMatch(t) &&
        n <= 4) {
      return true;
    }
    if (RegExp(r'^(e|mas|ou|nem)\s+\p{L}+$', unicode: true, caseSensitive: false)
        .hasMatch(t)) {
      return false;
    }
    return n <= 3;
  }
  if (RegExp(r'^para\s+\S+$', caseSensitive: false).hasMatch(t)) return true;
  if (RegExp(r'^(não|nao)\s+havia$', caseSensitive: false).hasMatch(t)) {
    return true;
  }
  return false;
}

bool isWeakDistractor(String text) {
  final t = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (t.isEmpty || isIncompletePhrase(t)) return true;
  if (_words(t) == 1) {
    if (RegExp(r'^[A-ZÁÉÍÓÚÂÊÔÃÕ][\p{L}]+$', unicode: true).hasMatch(t) &&
        t.length >= 3) {
      return false;
    }
    return true;
  }
  return false;
}

String? _occurrence(String passage, String needle) {
  final parts = foldKey(needle).split(' ').where((w) => w.isNotEmpty).toList();
  if (parts.isEmpty) return null;
  String accent(String w) {
    final buf = StringBuffer();
    for (final ch in w.split('')) {
      buf.write(switch (ch) {
        'a' => '[aáàâãä]',
        'e' => '[eéêèë]',
        'i' => '[iíìîï]',
        'o' => '[oóôõòö]',
        'u' => '[uúùûü]',
        'c' => '[cç]',
        _ => RegExp.escape(ch),
      });
    }
    return buf.toString();
  }

  final body = parts.map(accent).join(r'\s+');
  final m = RegExp(body, caseSensitive: false).firstMatch(passage);
  return m?[0];
}

String growInPassage(String passage, String option) {
  final found = _occurrence(passage, option);
  if (found == null || found.isEmpty) return '';
  var start = passage.indexOf(found);
  if (start < 0) return '';
  var end = start + found.length;

  bool takeLeft() {
    final left = passage.substring(0, start);
    final m = RegExp(
      '(?:$_det\\s+)?(?!e\\b|mas\\b|ou\\b|nem\\b)($_word)[,;:]?\\s+\$',
      unicode: true,
      caseSensitive: false,
    ).firstMatch(left);
    if (m == null) return false;
    start -= m.group(0)!.length;
    return true;
  }

  var text = found;
  if (_danglingStart.hasMatch(text)) {
    takeLeft();
    text = passage.substring(start, end);
    if (_danglingStart.hasMatch(text.trim()) ||
        RegExp(r',\s+e\b', caseSensitive: false).hasMatch(text)) {
      takeLeft();
    }
  }
  text = passage.substring(start, end);
  if (_hangingPrep.hasMatch(text.trim())) takeLeft();

  text = passage.substring(start, end);
  if (_danglingEnd.hasMatch(text.trim()) || _hangingPrep.hasMatch(text.trim())) {
    final right = passage.substring(end);
    final m = RegExp(
      r'^(?:\s+(?:' + _det + r'\s+)?' + _word + r'){1,7}',
      unicode: true,
      caseSensitive: false,
    ).firstMatch(right);
    if (m != null) end += m.group(0)!.length;
  }

  text = passage.substring(start, end).replaceAll(RegExp(r'^[\s,;:]+|[\s,;:.]+$'), '');
  return text;
}

bool isNamingAsk(String question) {
  final t = question
      .replaceAll(RegExp(r'\s*\([^)]*\)'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'[.!?…]+$'), '')
      .trim();
  return RegExp(
    r'^(como se chama|que nome|qual (?:é )?(?:o |a )?(?:novo |nova )?nome|quem é|quem são|quem foi|de quem)\b',
    caseSensitive: false,
  ).hasMatch(t);
}

bool isNameLikeAnswer(String text) {
  final t = text.trim();
  final words = t.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty || words.length > 3) return false;
  if (RegExp(r'^(não|nao|sim|sem|todos|todas|isso|nenhum|nenhuma)\b',
          caseSensitive: false)
      .hasMatch(t)) {
    return false;
  }
  return RegExp(r'^[A-ZÁÉÍÓÚÂÊÔÃÕ]').hasMatch(t);
}

bool isPassagePrefix(String text, String passage, {int minWords = 4}) {
  final t = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  final p = passage.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (t.isEmpty || p.isEmpty || _words(t) < minWords) return false;
  final tf = foldKey(t);
  final pf = foldKey(p);
  if (tf.length < 10) return false;
  return pf.startsWith(tf);
}

bool isVerseFragmentOption(String text, String passage) {
  if (isPassagePrefix(text, passage)) return true;
  final t = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  final p = passage.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (t.isEmpty || p.isEmpty || _words(t) < 3) return false;
  return foldKey(p).contains(foldKey(t));
}

bool _keepFactualAnswer(String option, String question) {
  return isNameLikeAnswer(option) || isNamingAsk(question);
}

String preferredAnswer({
  required String option,
  String quote = '',
  String passage = '',
  String question = '',
}) {
  final opt = option.replaceAll(RegExp(r'\s+'), ' ').trim();
  final q = quote.replaceAll(RegExp(r'\s+'), ' ').trim();
  final grown = growInPassage(passage, opt);
  if (_keepFactualAnswer(opt, question)) {
    if (grown.isNotEmpty &&
        foldKey(grown).contains(foldKey(opt)) &&
        _words(grown) <= 4 &&
        !isPassagePrefix(grown, passage)) {
      return grown;
    }
    return opt;
  }
  if (grown.isNotEmpty && !isIncompletePhrase(grown) && _words(grown) >= 2) {
    return grown;
  }
  if (q.isNotEmpty &&
      !isIncompletePhrase(q) &&
      _words(q) <= 18 &&
      (isIncompletePhrase(opt) ||
          foldKey(q).contains(foldKey(opt)) &&
              _words(opt) <= 2 &&
              _words(q) <= 10 &&
              !RegExp(r'^[A-ZÁÉÍÓÚÂÊÔÃÕ]').hasMatch(opt))) {
    final inPassage = growInPassage(passage, q);
    if (inPassage.isNotEmpty && !isIncompletePhrase(inPassage)) return inPassage;
    if (isIncompletePhrase(opt) && _words(q) <= 10) return q;
  }
  if (grown.isNotEmpty && !isIncompletePhrase(grown)) return grown;
  return opt;
}

({List<QuestionOption> options, String? template}) repairActOptions({
  required List<QuestionOption> options,
  required String correctId,
  String passage = '',
  String quote = '',
  String question = '',
  String? template,
}) {
  if (options.isEmpty) return (options: options, template: template);
  final current =
      options.where((o) => o.id == correctId).map((o) => o.text).firstOrNull ??
      '';
  final full = preferredAnswer(
    option: current,
    quote: quote,
    passage: passage,
    question: question,
  );

  final seen = <String>{answerKey(full)};
  final next = <QuestionOption>[QuestionOption(id: correctId, text: full)];
  for (final o in options) {
    if (o.id == correctId) continue;
    final t = o.text.trim();
    if (isWeakDistractor(t)) continue;
    if (passage.isNotEmpty &&
        isNamingAsk(question) &&
        isPassagePrefix(t, passage)) {
      continue;
    }
    if (passage.isNotEmpty &&
        isPassagePrefix(t, passage) &&
        !RegExp(
          r'como (começa|inicia)|primeiras palavras|in[ií]cio do (texto|vers)',
          caseSensitive: false,
        ).hasMatch(question)) {
      continue;
    }
    final k = answerKey(t);
    if (k.isEmpty || seen.contains(k)) continue;
    seen.add(k);
    next.add(QuestionOption(id: o.id, text: t));
    if (next.length >= 3) break;
  }
  const fallbacks = [
    'Isso não é o que o trecho diz',
    'Outra leitura do mesmo verso',
  ];
  var i = 0;
  while (next.length < 3 && i < fallbacks.length) {
    final f = fallbacks[i++];
    if (seen.contains(answerKey(f))) continue;
    next.add(QuestionOption(id: String.fromCharCode(97 + next.length), text: f));
  }

  String? tpl = template;
  if (tpl != null && tpl.contains('___') && full.isNotEmpty && passage.isNotEmpty) {
    final hit = _occurrence(passage, full) ?? _occurrence(tpl.replaceAll('___', current), full);
    if (hit != null && hit.isNotEmpty) {
      final source = passage.isNotEmpty ? passage : tpl.replaceAll('___', current);
      tpl = source.replaceFirst(hit, '___');
    }
  }
  return (options: next, template: tpl);
}
