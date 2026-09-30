/// Expande códigos morfológicos STEPBible / OpenScriptures (hebraico e grego).
library;

import '../l10n/l10n_global.dart';

String _cap(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

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
  final l = L10n.current;
  final langs = {
    l.morphLangHebrew.toLowerCase(),
    l.morphLangAramaic.toLowerCase(),
    l.morphLangGreek.toLowerCase(),
  };
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
  final l = L10n.current;
  final pronoun = suffixPronounPt(code);
  final g = gloss.trim();

  if (chips.contains(l.morphPrep)) {
    if (pronoun != null) {
      return g.isNotEmpty
          ? l.morphPhrasePrepSuffixGloss(g)
          : l.morphPhrasePrepSuffix;
    }
    return g.isNotEmpty ? l.morphPhrasePrepGloss(g) : l.morphPhrasePrep;
  }
  if (chips.contains(l.morphConjunction)) {
    return g.isNotEmpty ? l.morphPhraseConjGloss(g) : l.morphPhraseConj;
  }
  if (chips.contains(l.morphVerb)) {
    final stems = {
      l.morphStemQal,
      l.morphStemNifal,
      l.morphStemPiel,
      l.morphStemPual,
      l.morphStemHifil,
      l.morphStemHofal,
      l.morphStemHitpael,
    };
    final tenses = {
      l.morphTensePerfect,
      l.morphTenseImperfectHeb,
      l.morphTenseCohortative,
      l.morphTenseJussive,
      l.morphTenseImperative,
      l.morphTenseParticiple,
      l.morphTenseParticiplePassive,
      l.morphTenseInfConstruct,
      l.morphTenseInfAbsolute,
      l.morphTenseWayyiqtol,
      l.morphTenseWeqatal,
      l.morphTensePresent,
      l.morphTenseAorist,
      l.morphTenseFuture,
      l.morphTenseImperfectGk,
    };
    final bits = <String>[_cap(l.morphVerb)];
    for (final c in chips) {
      if (stems.contains(c) || tenses.contains(c)) bits.add(c);
    }
    final person = chips
        .where((c) =>
            c == l.morphPerson1 || c == l.morphPerson2 || c == l.morphPerson3)
        .toList();
    final number = chips.where(
      (c) => c == l.morphSing || c == l.morphPl || c == l.morphDual,
    );
    if (person.isNotEmpty) {
      if (number.isEmpty) {
        bits.add(person.first);
      } else {
        final label = number.first == l.morphSing
            ? l.morphNumberSingular
            : number.first == l.morphPl
                ? l.morphNumberPlural
                : l.morphNumberDual;
        bits.add(l.morphPhrasePersonOfNumber(person.first, label));
      }
    }
    final s = bits.join(', ');
    return g.isNotEmpty
        ? l.morphPhraseVerbBits(s, g)
        : l.morphPhraseVerbBitsPlain(s);
  }
  if (chips.contains(l.morphNoun)) {
    final bits = <String>[_cap(l.morphNoun)];
    if (chips.contains(l.morphNounProper)) bits.add(l.morphNounProper);
    if (chips.contains(l.morphDivineName)) bits.add(l.morphDivineName);
    if (chips.contains(l.morphMasc)) bits.add(_genderWord(l.morphMasc));
    if (chips.contains(l.morphFem)) bits.add(_genderWord(l.morphFem));
    if (chips.contains(l.morphSing)) bits.add(l.morphNumberSingular);
    if (chips.contains(l.morphPl)) bits.add(l.morphNumberPlural);
    if (chips.contains(l.morphAbsolute)) bits.add(l.morphAbsolute);
    if (chips.contains(l.morphConstruct)) bits.add(l.morphInConstruct);
    final s = bits.join(', ');
    return g.isNotEmpty
        ? l.morphPhraseVerbBits(s, g)
        : l.morphPhraseVerbBitsPlain(s);
  }
  final titled = _cap(chips.first);
  return g.isNotEmpty
      ? l.morphPhraseHeadGloss(titled, g)
      : l.morphPhraseHead(titled);
}

/// "masc." → "masculino" / "masculine" for phrase prose.
String _genderWord(String chip) {
  final l = L10n.current;
  if (chip == l.morphMasc) return l.morphGenderMasculine;
  if (chip == l.morphFem) return l.morphGenderFeminine;
  return chip;
}

String _hebrew(String code) {
  final l = L10n.current;
  // Exemplos: HVqp3ms, HNcmpa, HTd, HR, HTo, Hc, HD, HAcmsc
  final parts = <String>[];
  var i = 0;
  if (code.startsWith('H') || code.startsWith('A')) {
    parts.add(code[0] == 'A' ? l.morphLangAramaic : l.morphLangHebrew);
    i = 1;
  }
  if (i >= code.length) return parts.join(', ');

  final rest = code.substring(i);

  // Partículas / classes curtas
  final short = {
    'R': l.morphPrep,
    'Td': l.morphArticle,
    'To': l.morphObjectMarker,
    'c': l.morphConjConsecutive,
    'C': l.morphConjunction,
    'D': l.morphAdverb,
    'S': l.morphPronominalSuffix,
    'i': l.morphInterjection,
    'r': l.morphRelativeParticle,
    'n': l.morphNegativeParticle,
    'p': l.morphParticle,
    'Te': l.morphDemonstrativeArticle,
  };
  if (short.containsKey(rest)) {
    parts.add(short[rest]!);
    return parts.join(', ');
  }

  if (rest.startsWith('V')) {
    parts.add(l.morphVerb);
    var j = 1;
    // stem
    final stems = {
      'q': l.morphStemQal,
      'N': l.morphStemNifal,
      'p': l.morphStemPiel,
      'P': l.morphStemPual,
      'h': l.morphStemHifil,
      'H': l.morphStemHofal,
      't': l.morphStemHitpael,
      'o': l.morphStemPolal,
      'O': l.morphStemPolal,
      'u': l.morphStemPulal,
    };
    if (j < rest.length && stems.containsKey(rest[j])) {
      parts.add(stems[rest[j]]!);
      j++;
    }
    // tense
    final tenses = {
      'p': l.morphTensePerfect,
      'q': l.morphTenseWayyiqtol,
      'i': l.morphTenseImperfectHeb,
      'w': l.morphTenseWeqatal,
      'h': l.morphTenseCohortative,
      'j': l.morphTenseJussive,
      'v': l.morphTenseImperative,
      'c': l.morphTenseInfConstruct,
      'a': l.morphTenseInfAbsolute,
      'r': l.morphTenseParticiple,
      's': l.morphTenseParticiplePassive,
    };
    if (j < rest.length && tenses.containsKey(rest[j])) {
      parts.add(tenses[rest[j]]!);
      j++;
    }
    _personNumberGender(rest.substring(j), parts);
    return parts.join(', ');
  }

  if (rest.startsWith('N')) {
    parts.add(l.morphNoun);
    var j = 1;
    if (j < rest.length) {
      final cls = rest[j];
      final next = j + 1 < rest.length ? rest[j + 1] : '';
      final nounClass = {
        'c': l.morphNounCommon,
        'g': l.morphNounGentilic,
        'p': l.morphNounProper,
        't': l.morphNounTitle,
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
          final proper = {
            'm': l.morphMasc,
            'f': l.morphFem,
            'l': l.morphNounPlace,
            't': l.morphDivineName,
          };
          if (j < rest.length && proper.containsKey(rest[j])) {
            parts.add(proper[rest[j]]!);
          }
          return parts.join(', ');
        }
      }
    }
    if (j < rest.length) {
      final gender = {
        'm': l.morphMasc,
        'f': l.morphFem,
        'c': l.morphNounCommon,
        'b': l.morphBoth,
      };
      if (gender.containsKey(rest[j])) {
        parts.add(gender[rest[j]]!);
        j++;
      }
    }
    if (j < rest.length) {
      final number = {
        's': l.morphSing,
        'p': l.morphPl,
        'd': l.morphDual,
      };
      if (number.containsKey(rest[j])) {
        parts.add(number[rest[j]]!);
        j++;
      }
    }
    if (j < rest.length) {
      final state = {
        'a': l.morphAbsolute,
        'c': l.morphConstruct,
        'd': l.morphDetermined,
      };
      if (state.containsKey(rest[j])) {
        parts.add(state[rest[j]]!);
        j++;
      }
    }
    return parts.join(', ');
  }

  if (rest.startsWith('S')) {
    parts.add(l.morphSuffix);
    var j = 1;
    final suffixKind = {
      'p': l.morphSuffixPronominal,
      'd': l.morphSuffixDirectional,
      'h': l.morphSuffixParagogic,
      'n': l.morphSuffixNunParagogic,
    };
    if (j < rest.length && suffixKind.containsKey(rest[j])) {
      parts.add(suffixKind[rest[j]]!);
      j++;
    }
    _personNumberGender(rest.substring(j), parts);
    return parts.join(', ');
  }

  if (rest.startsWith('A')) {
    parts.add(l.morphAdjective);
    _personNumberGender(rest.substring(1), parts);
    return parts.join(', ');
  }

  if (rest.startsWith('Ac')) {
    parts.add(l.morphAdverbConjAc);
    return parts.join(', ');
  }

  parts.add(rest);
  return parts.join(', ');
}

/// Pronome sufixado em português curto (לְךָ → "ti").
/// Mantido em PT: glosas e versos TB ficam em português.
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
  final l = L10n.current;
  // 3ms, 1cs, 2mp, …
  final m = RegExp(r'^([123])?([mfc])?([spd])?').firstMatch(s);
  if (m == null) return;
  final person = {
    '1': l.morphPerson1,
    '2': l.morphPerson2,
    '3': l.morphPerson3,
  };
  final gender = {
    'm': l.morphMasc,
    'f': l.morphFem,
    'c': l.morphNounCommon,
  };
  final number = {
    's': l.morphSing,
    'p': l.morphPl,
    'd': l.morphDual,
  };
  if (m.group(1) != null) parts.add(person[m.group(1)]!);
  if (m.group(2) != null) parts.add(gender[m.group(2)]!);
  if (m.group(3) != null) parts.add(number[m.group(3)]!);
}

String _greek(String code) {
  final l = L10n.current;
  // N-NSF, V-AAI-3S, A-NSM, PREP, CONJ, T-NSM, P-NSM, …
  final parts = <String>[];
  final segs = code.split('-');
  if (segs.isEmpty) return code;

  final pos = {
    'N': l.morphNoun,
    'V': l.morphVerb,
    'A': l.morphAdjective,
    'ADV': l.morphAdverb,
    'PREP': l.morphPrep,
    'CONJ': l.morphConjunction,
    'PRT': l.morphParticle,
    'INJ': l.morphInterjection,
    'I': l.morphInterjection,
    'T': l.morphArticle,
    'P': l.morphPronounPersonal,
    'R': l.morphPronounRelative,
    'C': l.morphPronounReciprocal,
    'D': l.morphPronounDemonstrative,
    'K': l.morphConjunction,
    'X': l.morphParticle,
    'Q': l.morphParticleInterrogative,
    'F': l.morphPronounReflexive,
    'S': l.morphPronounPossessive,
  };

  final head = segs.first;
  parts.add(pos[head] ?? head);

  if (segs.length == 1) return parts.join(', ');

  if (head == 'V' && segs.length >= 2) {
    final morph = segs[1];
    if (morph.length >= 3) {
      final tense = {
        'P': l.morphTensePresent,
        'I': l.morphTenseImperfectGk,
        'F': l.morphTenseFuture,
        'A': l.morphTenseAorist,
        'R': l.morphTensePerfect,
        'L': l.morphTensePluperfect,
        'X': l.morphTenseUndefined,
        '2': l.morphTenseSecondAorist,
      };
      final voice = {
        'A': l.morphVoiceActive,
        'M': l.morphVoiceMiddle,
        'P': l.morphVoicePassive,
        'E': l.morphVoiceMiddlePassive,
        'D': l.morphVoiceMiddleDeponent,
        'O': l.morphVoicePassiveDeponent,
        'N': l.morphVoiceMidPassDeponent,
        'Q': l.morphVoiceImpersonal,
      };
      final mood = {
        'I': l.morphMoodIndicative,
        'S': l.morphMoodSubjunctive,
        'O': l.morphMoodOptative,
        'M': l.morphMoodImperative,
        'N': l.morphMoodInfinitive,
        'P': l.morphMoodParticiple,
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
    final extra = {
      'P': l.morphExtraProper,
      'T': l.morphExtraTitle,
      'L': l.morphExtraLocal,
      'G': l.morphExtraGentilic,
    };
    parts.add(extra[segs[2]] ?? segs[2]);
  }
  return parts.where((e) => e.isNotEmpty).join(', ');
}

String _greekPerson(String s) {
  final l = L10n.current;
  final map = {
    '1S': l.morphPerson1s,
    '2S': l.morphPerson2s,
    '3S': l.morphPerson3s,
    '1P': l.morphPerson1p,
    '2P': l.morphPerson2p,
    '3P': l.morphPerson3p,
  };
  return map[s] ?? s;
}

String _greekCng(String s) {
  if (s.length < 3) return s;
  final l = L10n.current;
  final cases = {
    'N': l.morphCaseNominative,
    'G': l.morphCaseGenitive,
    'D': l.morphCaseDative,
    'A': l.morphCaseAccusative,
    'V': l.morphCaseVocative,
  };
  final number = {
    'S': l.morphSing,
    'P': l.morphPl,
    'D': l.morphDual,
  };
  final gender = {
    'M': l.morphMasc,
    'F': l.morphFem,
    'N': l.morphNeuter,
  };
  final out = <String>[];
  out.add(cases[s[0]] ?? s[0]);
  out.add(number[s[1]] ?? s[1]);
  out.add(gender[s[2]] ?? s[2]);
  return out.join(' ');
}
