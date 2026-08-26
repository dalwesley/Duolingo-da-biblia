/// V/F: pergunta + recorte → afirmação que se pode julgar.

final _askLead = RegExp(
  r'^(à imagem de quem|para onde|aonde|por que|porque|por quê|o que|em qual|em que|de quem|a quem|com quem|para quem|para que|de que|quem|quais|qual|que|como|onde|quando|quantos|quantas)\b',
  caseSensitive: false,
);

final _paren = RegExp(r'\s*\([^)]*\)');
final _space = RegExp(r'\s+');
final _endPunct = RegExp(r'[.!?…]+$');
final _quotes = '“”"«»';
final _copula = RegExp(
  r'^(é|era|foi|são|eram|foram|será|seriam|está|estava|esteve)\b',
  caseSensitive: false,
);
final _complementLead = RegExp(
  r'^(para|por|porque|pois|devido|pela|pelo|pelas|pelos|com|como|em|no|na|nos|nas|de|do|da|dos|das|à|ao|às|aos|sem|só|somente|apenas)\b',
  caseSensitive: false,
);

const _leadLowerWords = {
  'para',
  'por',
  'porque',
  'pois',
  'com',
  'de',
  'em',
  'a',
  'o',
  'os',
  'as',
  'um',
  'uma',
  'pela',
  'pelo',
  'pelas',
  'pelos',
  'ao',
  'à',
  'aos',
  'às',
  'no',
  'na',
  'nos',
  'nas',
  'que',
  'somente',
  'só',
  'apenas',
  'não',
  'nao',
};

const _keepCapital = {
  'Deus',
  'Senhor',
  'Jeová',
  'Jesus',
  'Cristo',
  'Espírito',
  'Pai',
  'Verbo',
  'Haja',
  'Abrão',
  'Abraão',
  'Sarai',
  'Sara',
  'Ló',
  'Moisés',
  'Adão',
  'Eva',
  'Noé',
  'Paulo',
  'Pedro',
  'João',
  'Maria',
  'Israel',
  'Egito',
  'Isaque',
  'Ismael',
  'Jacó',
  'José',
  'Melquisedeque',
  'Agar',
  'Faraó',
};

const _roleWords = {
  'rei',
  'sacerdote',
  'serva',
  'servo',
  'anjo',
  'faraó',
  'planície',
  'túnica',
  'escada',
  'nação',
  'forno',
  'tocha',
  'arca',
};

/// True se o texto é pergunta (O que / Quem / …) ou `Pergunta: recorte`.
/// Afirmações completas (ex.: Gn 1:1–2) não passam — não devem ser reescritas.
bool vfIsAskStem(String text) {
  final t = text.replaceAll(_space, ' ').trim();
  if (t.isEmpty) return false;
  if (_splitStemClaim(t) != null) return true;
  return _isAsk(_cleanStem(t));
}

/// Enunciado de V/F a partir do prompt gravado (`Pergunta: recorte.`).
String vfClaim(String prompt) {
  final text = prompt.replaceAll(_space, ' ').trim();
  if (text.isEmpty) return text;
  final split = _splitStemClaim(text);
  if (split == null) return text;
  return vfClaimFromParts(split.$1, split.$2);
}

/// Enunciado de V/F a partir da pergunta e de um recorte (certo ou distrator).
String vfClaimFromParts(String question, String answer) {
  final stem = _cleanStem(question);
  final piece = answer.replaceAll(_space, ' ').replaceAll(_endPunct, '').trim();
  if (piece.isEmpty) return _asSentence(stem);
  if (_isAsk(stem)) {
    if (_looksIndependentClaim(piece) &&
        !_complementLead.hasMatch(piece) &&
        piece.split(_space).length >= 6) {
      return _asSentence(piece);
    }
    return _asSentence(_joinAsk(stem, piece));
  }
  if (piece.length > 28 || _looksFull(piece)) return _asSentence(piece);
  if (stem.isEmpty) return _asSentence(piece);
  return _asSentence('$stem ${_asComplement(piece)}');
}

(String, String)? _splitStemClaim(String text) {
  var inQuote = false;
  for (var i = 0; i < text.length - 1; i++) {
    final ch = text[i];
    if (_quotes.contains(ch)) inQuote = !inQuote;
    if (inQuote || ch != ':') continue;
    var j = i + 1;
    while (j < text.length && text[j] == ':') {
      j++;
    }
    if (j >= text.length || text[j] != ' ') continue;
    final stem = text.substring(0, i).trim();
    final claim = text.substring(j + 1).trim();
    if (_isAsk(stem) && claim.isNotEmpty) return (stem, claim);
    return null;
  }
  return null;
}

String _cleanStem(String raw) {
  return raw
      .replaceAll(_paren, ' ')
      .replaceAll(_space, ' ')
      .replaceAll(_endPunct, '')
      .trim();
}

bool _isAsk(String stem) => _askLead.hasMatch(_cleanStem(stem));

bool _looksFull(String text) {
  final t = text.trim();
  if (t.length < 18) return false;
  if (_isAsk(t)) return false;
  return t.split(_space).length >= 4;
}

bool _looksIndependentClaim(String text) {
  final t = text.trim();
  final words = t.split(_space).where((w) => w.isNotEmpty).toList();
  if (words.length < 5) return false;
  if (_isAsk(t)) return false;
  return words.any((w) {
    final token = w.replaceAll(RegExp(r'[^\p{L}]+$', unicode: true), '');
    return _looksLikeVerb(token);
  });
}

bool _looksLikeVerb(String word) {
  final w = word.toLowerCase();
  if (w.length < 3) return false;
  const known = {
    'passa',
    'passam',
    'dá',
    'dao',
    'dão',
    'vem',
    'vão',
    'sai',
    'saem',
    'faz',
    'fazem',
    'cria',
    'criou',
    'promete',
    'pede',
    'recebe',
    'mostra',
    'conta',
    'revela',
    'une',
    'marca',
    'ocorre',
    'acontece',
    'sucede',
    'viaja',
    'resgata',
    'escolhe',
    'caminham',
    'caminha',
  };
  if (known.contains(w) || w == 'tem' || w == 'têm' || w == 'há') return true;
  return RegExp(r'(ou|eu|iu|aram|eram|iam|ava|avam)$', caseSensitive: false)
      .hasMatch(w);
}

bool _looksLikeName(String text) {
  final t = text.trim();
  final words = t.split(_space).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty || words.length > 3) return false;
  if (RegExp(r'^(não|nao|sim|sem|todos|todas|isso|nenhum|nenhuma)\b', caseSensitive: false)
      .hasMatch(t)) {
    return false;
  }
  final folded = t.toLowerCase();
  if (words.length >= 2 && _roleWords.any(folded.contains)) return false;
  return RegExp(r'^[A-ZÁÉÍÓÚÂÊÔÃÕ]').hasMatch(t);
}

bool _objectQuem(String rest) {
  if (_copula.hasMatch(rest)) return false;
  if (RegExp(r'^[A-ZÁÉÍÓÚÂÊÔÃÕ]').hasMatch(rest)) return true;
  if (RegExp(r'^(o|a|os|as)\s+[A-ZÁÉÍÓÚÂÊÔÃÕ]').hasMatch(rest)) return true;
  return false;
}

String _joinAsk(String stem, String answer) {
  final t = _cleanStem(stem);
  final m = _askLead.firstMatch(t);
  final rest = m == null ? t : t.substring(m.end).trim();
  final key = (m?.group(1) ?? '').toLowerCase().replaceAll('ê', 'e');

  switch (key) {
    case 'por que':
    case 'porque':
      return _because(rest, answer);
    case 'quem':
    case 'de quem':
    case 'a quem':
    case 'com quem':
    case 'para quem':
      return _who(key, rest, answer);
    case 'à imagem de quem':
      return _imageOf(rest, answer);
    case 'qual':
    case 'quais':
    case 'em qual':
      return _which(key, rest, answer);
    case 'o que':
      return _what(rest, answer);
    case 'que':
    case 'em que':
      return _plainQue(key, rest, answer);
    case 'como':
      return _how(rest, answer);
    case 'onde':
    case 'para onde':
    case 'aonde':
      return _place(rest, answer);
    case 'quando':
      return '$rest ${_asComplement(answer)}';
    case 'para que':
      return '$rest ${_para(answer)}';
    case 'de que':
      return '$rest ${_asComplement(answer)}';
    case 'quantos':
    case 'quantas':
      return '$rest ${_asComplement(answer)}';
    default:
      return '$rest ${_asComplement(answer)}';
  }
}

String _because(String rest, String answer) {
  final a = _asComplement(answer);
  if (RegExp(r'^(para|por|porque|pois|devido)\b', caseSensitive: false)
      .hasMatch(a)) {
    return '$rest $a';
  }
  return '$rest porque $a';
}

String _para(String answer) {
  final a = _asComplement(answer);
  if (RegExp(r'^para\b', caseSensitive: false).hasMatch(a)) return a;
  return 'para $a';
}

String _imageOf(String rest, String answer) {
  final a = _asComplement(answer);
  final img = RegExp(r'^de\b', caseSensitive: false).hasMatch(a)
      ? 'à imagem $a'
      : 'à imagem de $a';
  return '$rest $img';
}

String _who(String key, String rest, String answer) {
  if (key == 'de quem') {
    return '$rest ${_asComplement(answer)}';
  }
  final ser = RegExp(
    r'^(é|era|foi|são|eram|foram|será|seriam)\s+(.+)$',
    caseSensitive: false,
  ).firstMatch(rest);
  if (ser != null) {
    final verb = ser.group(1)!;
    final topic = ser.group(2)!;
    if (_looksLikeName(topic) && !_looksLikeName(answer)) {
      return '${_asSubject(topic)} $verb ${_asComplement(answer)}';
    }
    if (_looksLikeName(answer) && !_looksLikeName(topic)) {
      return '${_asSubject(answer)} $verb ${_asComplement(topic)}';
    }
    return '${_asSubject(topic)} $verb ${_asComplement(answer)}';
  }
  if (_objectQuem(rest)) {
    return '$rest ${_asComplement(answer)}';
  }
  return '${_asSubject(answer)} ${_asComplement(rest)}';
}

String _which(String key, String rest, String answer) {
  var topicRest = rest;
  if (key == 'em qual') {
    final day = RegExp(r'^(\S+)\s+(.+)$').firstMatch(rest);
    if (day != null) {
      return '${day.group(2)} ${_asComplement(answer)}';
    }
  }
  final ser = RegExp(
    r'^(foi|é|era|eram|são|foram|será|seriam)\s+(.+)$',
    caseSensitive: false,
  ).firstMatch(topicRest);
  if (ser != null) {
    final verb = ser.group(1)!;
    final topic = ser.group(2)!;
    if (_isCommand(answer)) return '$topic $verb “$answer”';
    if (_looksLikeName(answer) && !_looksLikeName(topic)) {
      return '${_asSubject(answer)} $verb ${_asComplement(topic)}';
    }
    return '$topic $verb ${_asComplement(answer)}';
  }
  final det = RegExp(r'^(o|a|os|as)\s+(.+)$', caseSensitive: false)
      .firstMatch(topicRest);
  if (det != null) {
    return '${_asSubject(det.group(0)!)} é ${_asComplement(answer)}';
  }
  final noun = RegExp(r'^(\S+)\s+(.+)$').firstMatch(topicRest);
  if (noun != null) {
    final tail = noun.group(2)!;
    if (_objectQuem(tail) ||
        RegExp(r'^(deus|o senhor)\b', caseSensitive: false).hasMatch(tail)) {
      final art = _feminineNoun(noun.group(1)!) ? 'A' : 'O';
      return '$art ${noun.group(1)} que $tail é ${_asComplement(answer)}';
    }
    return '${_asSubject(answer)} $tail';
  }
  return '${_asSubject(answer)} $topicRest';
}

String _place(String rest, String answer) {
  final a = _asComplement(answer);
  if (RegExp(
    r'^(em|no|na|nos|nas|para|a|ao|à|junto|perante|diante|de|do|da)\b',
    caseSensitive: false,
  ).hasMatch(a)) {
    return '$rest $a';
  }
  final prep = RegExp(r'\b(fugiu|foi|viajou|manda|vai|partiu|desceu)\b',
          caseSensitive: false)
      .hasMatch(rest)
      ? 'para'
      : 'em';
  return '$rest $prep $a';
}

String _what(String rest, String answer) {
  final after = RegExp(
    r'^(acontece|ocorre|sucede)\s+(logo após|depois de|quando|ao)\s+(.+)$',
    caseSensitive: false,
  ).firstMatch(rest);
  if (after != null) {
    final circ = '${after.group(2)} ${after.group(3)}';
    return '${_asSubject(circ)}, ${_asComplement(answer)}';
  }
  final happ = RegExp(
    r'^(acontece|ocorre|sucede)(?:\s+(?:a|ao|à|às|com))\s+(.+)$',
    caseSensitive: false,
  ).firstMatch(rest);
  if (happ != null) {
    return '${happ.group(2)} ${_asComplement(answer)}';
  }
  final first = rest.split(_space).first;
  if (!_objectQuem(rest) && _looksLikeVerb(first)) {
    return _subjectThenRest(answer, rest);
  }
  return '$rest ${_asComplement(answer)}';
}

String _plainQue(String key, String rest, String answer) {
  if (key == 'em que') {
    final trans = RegExp(
      r'^se transforma(?:\s+(.+))?$',
      caseSensitive: false,
    ).firstMatch(rest);
    if (trans != null) {
      final who = (trans.group(1) ?? '').trim();
      final a = _asComplement(answer);
      final into = RegExp(r'^em\b', caseSensitive: false).hasMatch(a) ? a : 'em $a';
      if (who.isEmpty) return 'Se transforma $into';
      return '$who se transforma $into';
    }
  }
  final noun = RegExp(r'^(\S+)\s+(.+)$').firstMatch(rest);
  if (noun != null) {
    final word = noun.group(1)!;
    final art = _feminineNoun(word) ? 'A' : 'O';
    return '$art $word que ${noun.group(2)} é ${_asComplement(answer)}';
  }
  return '${_asSubject(answer)} $rest';
}

bool _feminineNoun(String word) {
  final w = word.toLowerCase();
  return RegExp(r'(ção|são|gem|dade|tude|ice|a)$').hasMatch(w) &&
      !RegExp(r'(ema|ista|ista)$').hasMatch(w);
}

String _how(String rest, String answer) {
  final called = RegExp(r'^se chama\s+(.+)$', caseSensitive: false).firstMatch(rest);
  if (called != null) {
    return '${called.group(1)} se chama ${_asComplement(answer)}';
  }
  final a = _asComplement(answer);
  if (RegExp(
        r'\b(é|foi|era|são|eram)\s+(descrit[oa]s?|chamad[oa]s?|declarad[oa]s?|apresentad[oa]s?)\b',
        caseSensitive: false,
      ).hasMatch(rest) &&
      !_complementLead.hasMatch(a)) {
    return '$rest como $a';
  }
  return '$rest $a';
}

String _subjectThenRest(String subject, String rest) {
  var r = rest;
  if (RegExp(r'\be\b', caseSensitive: false).hasMatch(subject) &&
      RegExp(r'^passa\b', caseSensitive: false).hasMatch(r)) {
    r = r.replaceFirst(RegExp(r'^passa\b', caseSensitive: false), 'passam');
  }
  return '${_asSubject(subject)} $r';
}

bool _isCommand(String text) =>
    RegExp(r'^(haja|faça|faze|venha|sê|seja|amai)\b', caseSensitive: false)
        .hasMatch(text);

String _asSubject(String text) {
  final t = text.trim();
  if (t.isEmpty) return t;
  return t[0].toUpperCase() + t.substring(1);
}

String _asComplement(String text) {
  final t = text.trim();
  if (t.isEmpty) return t;
  final first = t
      .split(_space)
      .first
      .replaceAll(RegExp(r'[^\p{L}]+$', unicode: true), '');
  if (_keepCapital.contains(first)) return t;
  final lower = first.toLowerCase();
  if (_leadLowerWords.contains(lower) || _roleWords.contains(lower)) {
    return t[0].toLowerCase() + t.substring(1);
  }
  if (first.contains('-')) return t[0].toLowerCase() + t.substring(1);
  if (RegExp(r'(ou|eu|iu|ava|iam|am)$', caseSensitive: false).hasMatch(first)) {
    return t[0].toLowerCase() + t.substring(1);
  }
  if (RegExp(r'^[a-záéíóúãõâêôç]').hasMatch(t)) return t;
  if (RegExp(r'^[A-ZÁÉÍÓÚÂÊÔÃÕ][a-záéíóúãõâêôç]+$', unicode: true)
          .hasMatch(first) &&
      first.length >= 3) {
    return t;
  }
  return t[0].toLowerCase() + t.substring(1);
}

String _asSentence(String raw) {
  var t = raw.replaceAll(_space, ' ').trim();
  t = t.replaceAll(RegExp(r'\s+,'), ',').replaceAll(RegExp(r'\s+\.'), '.');
  if (t.isEmpty) return t;
  t = t[0].toUpperCase() + t.substring(1);
  if (!_endPunct.hasMatch(t)) t = '$t.';
  return t.replaceAll(RegExp(r'\.+$'), '.');
}
