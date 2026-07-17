/// Expande códigos morfológicos STEPBible / OpenScriptures (hebraico e grego).
library;

String expandMorphology(String? code) {
  if (code == null || code.trim().isEmpty) return '';
  final raw = code.trim();
  if (raw.contains('/')) {
    return raw
        .split('/')
        .map((p) => expandMorphology(p))
        .where((s) => s.isNotEmpty)
        .join(' · ');
  }
  if (raw.startsWith('H') || raw.startsWith('A')) {
    return _hebrew(raw);
  }
  // Grego Robinson / STEP (N-NSF, V-PAI-3S, …)
  return _greek(raw);
}

String _hebrew(String code) {
  // Exemplos: HVqp3ms, HNcmpa, HTd, HR, HTo, Hc, HD, HAcmsc
  final parts = <String>[];
  var i = 0;
  if (code.startsWith('H') || code.startsWith('A')) {
    parts.add(code[0] == 'A' ? 'aramaico' : 'hebraico');
    i = 1;
  }
  if (i >= code.length) return parts.join(', ');

  final rest = code.substring(i);

  // Partículas / classes curtas
  const short = {
    'R': 'preposição',
    'Td': 'artigo',
    'To': 'marcador de objeto',
    'c': 'conjunção consecut./conj.',
    'C': 'conjunção',
    'D': 'advérbio',
    'S': 'sufixo pronominal',
    'i': 'interjeição',
    'r': 'partícula relativa',
    'n': 'partícula negativa',
    'p': 'partícula',
    'Te': 'artigo demonstrativo',
  };
  if (short.containsKey(rest)) {
    parts.add(short[rest]!);
    return parts.join(', ');
  }

  if (rest.startsWith('V')) {
    parts.add('verbo');
    var j = 1;
    // stem
    const stems = {
      'q': 'qal',
      'N': 'nifal',
      'p': 'piel',
      'P': 'pual',
      'h': 'hifil',
      'H': 'hofal',
      't': 'hitpael',
      'o': 'polal',
      'O': 'polal',
      'u': 'pulal',
    };
    if (j < rest.length && stems.containsKey(rest[j])) {
      parts.add(stems[rest[j]]!);
      j++;
    }
    // tense
    const tenses = {
      'p': 'perfeito',
      'q': 'sequencial imperfecto (wayyiqtol)',
      'i': 'imperfecto',
      'w': 'sequencial perfeito (weqatal)',
      'h': 'coortativo',
      'j': 'jussivo',
      'v': 'imperativo',
      'c': 'infinitivo construto',
      'a': 'infinitivo absoluto',
      'r': 'particípio',
      's': 'particípio passivo',
    };
    if (j < rest.length && tenses.containsKey(rest[j])) {
      parts.add(tenses[rest[j]]!);
      j++;
    }
    _personNumberGender(rest.substring(j), parts);
    return parts.join(', ');
  }

  if (rest.startsWith('N')) {
    parts.add('substantivo');
    var j = 1;
    if (j < rest.length) {
      const gender = {'m': 'masc.', 'f': 'fem.', 'c': 'comum', 'b': 'ambos'};
      if (gender.containsKey(rest[j])) {
        parts.add(gender[rest[j]]!);
        j++;
      }
    }
    if (j < rest.length) {
      const number = {'s': 'sing.', 'p': 'pl.', 'd': 'dual'};
      if (number.containsKey(rest[j])) {
        parts.add(number[rest[j]]!);
        j++;
      }
    }
    if (j < rest.length) {
      const state = {'a': 'absoluto', 'c': 'construto', 'd': 'determinado'};
      if (state.containsKey(rest[j])) {
        parts.add(state[rest[j]]!);
        j++;
      }
    }
    return parts.join(', ');
  }

  if (rest.startsWith('A')) {
    parts.add('adjetivo');
    _personNumberGender(rest.substring(1), parts);
    return parts.join(', ');
  }

  if (rest.startsWith('Ac')) {
    parts.add('advérbio/conj. (ac)');
    return parts.join(', ');
  }

  parts.add(rest);
  return parts.join(', ');
}

void _personNumberGender(String s, List<String> parts) {
  // 3ms, 1cs, 2mp, …
  final m = RegExp(r'^([123])?([mfc])?([spd])?').firstMatch(s);
  if (m == null) return;
  const person = {'1': '1ª pessoa', '2': '2ª pessoa', '3': '3ª pessoa'};
  const gender = {'m': 'masc.', 'f': 'fem.', 'c': 'comum'};
  const number = {'s': 'sing.', 'p': 'pl.', 'd': 'dual'};
  if (m.group(1) != null) parts.add(person[m.group(1)]!);
  if (m.group(2) != null) parts.add(gender[m.group(2)]!);
  if (m.group(3) != null) parts.add(number[m.group(3)]!);
}

String _greek(String code) {
  // N-NSF, V-AAI-3S, A-NSM, PREP, CONJ, T-NSM, P-NSM, …
  final parts = <String>[];
  final segs = code.split('-');
  if (segs.isEmpty) return code;

  const pos = {
    'N': 'substantivo',
    'V': 'verbo',
    'A': 'adjetivo',
    'ADV': 'advérbio',
    'PREP': 'preposição',
    'CONJ': 'conjunção',
    'PRT': 'partícula',
    'INJ': 'interjeição',
    'I': 'interjeição',
    'T': 'artigo',
    'P': 'pronome pessoal',
    'R': 'pronome relativo',
    'C': 'pronome reciproc./correl.',
    'D': 'pronome demonstrativo',
    'K': 'conjunção',
    'X': 'partícula',
    'Q': 'partícula interrogativa',
    'F': 'pronome reflexivo',
    'S': 'pronome possessivo',
  };

  final head = segs.first;
  parts.add(pos[head] ?? head);

  if (segs.length == 1) return parts.join(', ');

  if (head == 'V' && segs.length >= 2) {
    final morph = segs[1];
    if (morph.length >= 3) {
      const tense = {
        'P': 'presente',
        'I': 'imperfeito',
        'F': 'futuro',
        'A': 'aoristo',
        'R': 'perfeito',
        'L': 'mais-que-perfeito',
        'X': 'tempo indefinido',
        '2': '2º aoristo/futuro',
      };
      const voice = {
        'A': 'ativa',
        'M': 'média',
        'P': 'passiva',
        'E': 'médio-passiva',
        'D': 'média deponente',
        'O': 'passiva deponente',
        'N': 'médio-passiva deponente',
        'Q': 'impessoal',
      };
      const mood = {
        'I': 'indicativo',
        'S': 'subjuntivo',
        'O': 'optativo',
        'M': 'imperativo',
        'N': 'infinitivo',
        'P': 'particípio',
      };
      parts.add(tense[morph[0]] ?? morph[0]);
      parts.add(voice[morph[1]] ?? morph[1]);
      parts.add(mood[morph[2]] ?? morph[2]);
    }
    if (segs.length >= 3) {
      parts.add(_greekPerson(segs[2]));
    }
    if (segs.length >= 4) {
      // case/number/gender for participles sometimes in extra segments
      parts.add(_greekCng(segs[3]));
    }
    return parts.where((e) => e.isNotEmpty).join(', ');
  }

  // Nominal: N-NSF → case number gender (+P/T)
  if (segs.length >= 2) {
    parts.add(_greekCng(segs[1]));
  }
  if (segs.length >= 3) {
    const extra = {'P': 'nome próprio', 'T': 'título', 'L': 'local', 'G': 'gentílico'};
    parts.add(extra[segs[2]] ?? segs[2]);
  }
  return parts.where((e) => e.isNotEmpty).join(', ');
}

String _greekPerson(String s) {
  const map = {
    '1S': '1ª sing.',
    '2S': '2ª sing.',
    '3S': '3ª sing.',
    '1P': '1ª pl.',
    '2P': '2ª pl.',
    '3P': '3ª pl.',
  };
  return map[s] ?? s;
}

String _greekCng(String s) {
  if (s.length < 3) return s;
  const cases = {
    'N': 'nominativo',
    'G': 'genitivo',
    'D': 'dativo',
    'A': 'acusativo',
    'V': 'vocativo',
  };
  const number = {'S': 'sing.', 'P': 'pl.', 'D': 'dual'};
  const gender = {'M': 'masc.', 'F': 'fem.', 'N': 'neutro'};
  final out = <String>[];
  out.add(cases[s[0]] ?? s[0]);
  out.add(number[s[1]] ?? s[1]);
  out.add(gender[s[2]] ?? s[2]);
  return out.join(' ');
}
