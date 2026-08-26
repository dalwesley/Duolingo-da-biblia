/// Expande códigos morfológicos STEPBible / OpenScriptures (hebraico e grego).
library;

String expandMorphology(String? code) {
  if (code == null || code.trim().isEmpty) return '';
  final raw = code.trim();
  if (raw.contains('/')) {
    final segs = raw.split('/');
    final hebrewCompound = raw.startsWith('H') || raw.startsWith('A');
    return segs
        .map((p) {
          if (p.startsWith('H') || p.startsWith('A')) return expandMorphology(p);
          if (hebrewCompound) return _hebrew(p);
          return expandMorphology(p);
        })
        .where((s) => s.isNotEmpty)
        .join(' · ');
  }
  if (raw.startsWith('H') || raw.startsWith('A')) {
    return _hebrew(raw);
  }
  // Grego Robinson / STEP (N-NSF, V-PAI-3S, …)
  return _greek(raw);
}

/// Partes gramaticais para chips — sem a língua (já visível no léxico).
List<String> morphologyChips(String? code) {
  final expanded = expandMorphology(code);
  if (expanded.isEmpty) return const [];
  const langs = {'hebraico', 'aramaico', 'grego'};
  return expanded
      .split(RegExp(r'\s*[·,]\s*'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty && !langs.contains(s.toLowerCase()))
      .toList();
}

/// Uma frase só, no lugar de códigos e chips soltos.
String morphologyPhrase(String? code, {String gloss = ''}) {
  final chips = morphologyChips(code);
  if (chips.isEmpty) return '';
  final pronoun = suffixPronounPt(code);
  final g = gloss.trim();

  if (chips.contains('preposição')) {
    if (pronoun != null) {
      return g.isNotEmpty
          ? 'Preposição com sufixo — $g.'
          : 'Preposição com sufixo pronominal.';
    }
    return g.isNotEmpty ? 'Preposição — $g.' : 'Preposição.';
  }
  if (chips.contains('conjunção')) {
    return g.isNotEmpty ? 'Conjunção — $g.' : 'Conjunção.';
  }
  if (chips.contains('verbo')) {
    const stems = {
      'qal',
      'nifal',
      'piel',
      'pual',
      'hifil',
      'hofal',
      'hitpael',
    };
    const tenses = {
      'perfeito',
      'imperfecto',
      'coortativo',
      'jussivo',
      'imperativo',
      'particípio',
      'particípio passivo',
      'infinitivo construto',
      'infinitivo absoluto',
      'sequencial imperfecto (wayyiqtol)',
      'sequencial perfeito (weqatal)',
      'presente',
      'aoristo',
      'futuro',
      'imperfeito',
    };
    final bits = <String>['Verbo'];
    for (final c in chips) {
      if (stems.contains(c) || tenses.contains(c)) bits.add(c);
    }
    final person = chips.where((c) => c.contains('pessoa')).toList();
    final number = chips.where((c) => c == 'sing.' || c == 'pl.' || c == 'dual');
    if (person.isNotEmpty) {
      final n = number.isEmpty
          ? ''
          : ' do ${number.first == 'sing.' ? 'singular' : number.first == 'pl.' ? 'plural' : 'dual'}';
      bits.add('${person.first}$n');
    }
    var s = bits.join(', ');
    if (g.isNotEmpty) s = '$s — $g';
    return '$s.';
  }
  if (chips.contains('substantivo')) {
    final bits = <String>['Substantivo'];
    if (chips.contains('próprio')) bits.add('próprio');
    if (chips.contains('nome divino')) bits.add('nome divino');
    if (chips.contains('masc.')) bits.add('masculino');
    if (chips.contains('fem.')) bits.add('feminino');
    if (chips.contains('sing.')) bits.add('singular');
    if (chips.contains('pl.')) bits.add('plural');
    if (chips.contains('absoluto')) bits.add('absoluto');
    if (chips.contains('construto')) bits.add('em construto');
    var s = bits.join(', ');
    if (g.isNotEmpty) s = '$s — $g';
    return '$s.';
  }
  final head = chips.first;
  final titled = '${head[0].toUpperCase()}${head.substring(1)}';
  return g.isNotEmpty ? '$titled — $g.' : '$titled.';
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
      final cls = rest[j];
      final next = j + 1 < rest.length ? rest[j + 1] : '';
      const nounClass = {
        'c': 'comum',
        'g': 'gentílico',
        'p': 'próprio',
        't': 'título',
      };
      var takeClass = false;
      if (cls == 'p') {
        // HNpm / HNpl / HNpt — `p` é próprio, não plural.
        takeClass = next.isEmpty || 'mflt'.contains(next);
      } else if (nounClass.containsKey(cls)) {
        takeClass = next.isEmpty || 'mfbcsdpa'.contains(next);
      }
      if (takeClass) {
        if (cls != 'c') {
          parts.add(nounClass[cls]!);
        }
        j++;
        if (cls == 'p') {
          const proper = {
            'm': 'masc.',
            'f': 'fem.',
            'l': 'lugar',
            't': 'nome divino',
          };
          if (j < rest.length && proper.containsKey(rest[j])) {
            parts.add(proper[rest[j]]!);
          }
          return parts.join(', ');
        }
      }
    }
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

  if (rest.startsWith('S')) {
    parts.add('sufixo');
    var j = 1;
    const suffixKind = {
      'p': 'pronominal',
      'd': 'direcional',
      'h': 'paragógico',
      'n': 'nun paragógico',
    };
    if (j < rest.length && suffixKind.containsKey(rest[j])) {
      parts.add(suffixKind[rest[j]]!);
      j++;
    }
    _personNumberGender(rest.substring(j), parts);
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

/// Pronome sufixado em português curto (לְךָ → "ti").
String? suffixPronounPt(String? morph) {
  if (morph == null || morph.isEmpty) return null;
  final m = RegExp(
    r'Sp([123])([mfc])([spd])',
    caseSensitive: false,
  ).firstMatch(morph);
  if (m == null) return null;
  const map = {
    '1cs': 'mim',
    '1cp': 'nós',
    '2ms': 'ti',
    '2fs': 'ti',
    '2mp': 'vós',
    '2fp': 'vós',
    '3ms': 'ele',
    '3fs': 'ela',
    '3mp': 'eles',
    '3fp': 'elas',
  };
  return map['${m.group(1)}${m.group(2)}${m.group(3)}'.toLowerCase()];
}

/// Junta a glosa da partícula ao pronome: "para" + Sp2ms → "para ti".
String attachSuffixGloss(String gloss, String morph) {
  final pn = suffixPronounPt(morph);
  if (pn == null) return gloss;
  final folded = gloss.toLowerCase();
  if (folded.contains(pn) ||
      (pn == 'ti' && (folded.contains('teu') || folded.contains('tua'))) ||
      (pn == 'ele' && folded.contains('dele')) ||
      (pn == 'ela' && folded.contains('dela'))) {
    return gloss;
  }
  if (gloss.isEmpty) return pn;
  return '$gloss $pn';
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
