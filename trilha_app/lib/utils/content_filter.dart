/// Filtro de texto que outras pessoas veem: nome no ranking, nome de grupo e
/// recado do grupo (App Store 1.2). Não é moderação completa — barra o
/// óbvio; o resto chega por denúncia.
///
/// Compara sem acento, sem caixa e desfazendo troca de letra por número
/// (`p0rr4`). Palavra curta só conta inteira ("cu" não barra "curso");
/// palavra longa conta também colada em outras ("filhodaputa").
class ContentFilter {
  ContentFilter._();

  /// Barradas só como palavra inteira — curtas ou que aparecem dentro de
  /// palavras comuns.
  static const _wholeWords = {
    // pt
    'cu', 'cuzao', 'puta', 'puto', 'putas', 'putos', 'retardado', 'retard',
    'fdp', 'pqp', 'vsf', 'tnc', 'bicha', 'viado', 'corno', 'merda', 'bosta',
    'foder', 'foda', 'fode', 'xota', 'xana', 'cacete', 'porra', 'vadia',
    'piranha', 'otario', 'otaria', 'babaca', 'broxa', 'nazi',
    // en
    'fuck', 'shit', 'dick', 'cock', 'cunt', 'fag', 'slut', 'whore', 'bitch',
    'ass', 'tits', 'porn', 'sex', 'rape', 'nigga',
    // es
    'cono', 'verga', 'polla', 'zorra', 'culo', 'chinga', 'joder',
    // Passar-se pela equipe.
    'admin', 'moderador', 'moderator', 'suporte', 'support', 'stway',
  };

  /// Barradas também dentro de outra palavra — longas e sem falso positivo
  /// comum em português, inglês ou espanhol.
  static const _anywhere = {
    // pt
    'caralho', 'buceta', 'boceta', 'piroca', 'arrombad', 'vagabund',
    'putaria', 'punheta', 'xereca', 'xoxota', 'fodase', 'fodido', 'fudido',
    'desgracad', 'filhodaputa', 'filhadaputa', 'viadinho', 'sapatao',
    'traveco', 'estupr', 'pedofil', 'nazista', 'hitler', 'crioulo',
    // en
    'fucker', 'fucking', 'motherfuck', 'bullshit', 'asshole', 'bastard',
    'nigger', 'faggot', 'pussy', 'penis', 'vagina', 'porno',
    // es
    'mierda', 'cabron', 'pendejo', 'maricon', 'gilipollas', 'hijodeputa',
    'chingar', 'culero', 'follar',
  };

  static const _accents = {
    'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c', 'ñ': 'n',
  };

  static const _leet = {
    '0': 'o', '1': 'i', '3': 'e', '4': 'a', '5': 's', '7': 't',
    '@': 'a', r'$': 's', '!': 'i',
  };

  /// `true` se o texto pode ser mostrado a outras pessoas.
  static bool isAllowed(String text) {
    final normalized = _normalize(text);
    if (normalized.trim().isEmpty) return true;

    final words = normalized
        .split(RegExp(r'[^a-z]+'))
        .where((w) => w.isNotEmpty)
        .map(_squeeze)
        .toList();
    for (final word in [...words, ..._spelledOut(words)]) {
      if (_wholeWords.contains(word)) return false;
    }

    // Tudo colado: pega "p.o.r.r.a" e "filho da puta".
    final compact = _squeeze(normalized.replaceAll(RegExp(r'[^a-z]'), ''));
    for (final bad in _anywhere) {
      if (compact.contains(bad)) return false;
    }
    return true;
  }

  /// Letras soltas em sequência viram uma palavra: "f.d.p" → "fdp".
  static List<String> _spelledOut(List<String> words) {
    final joined = <String>[];
    final run = StringBuffer();
    for (final word in [...words, '']) {
      if (word.length == 1) {
        run.write(word);
        continue;
      }
      if (run.length > 1) joined.add(run.toString());
      run.clear();
    }
    return joined;
  }

  static String _normalize(String text) {
    final buffer = StringBuffer();
    for (final rune in text.toLowerCase().runes) {
      final ch = String.fromCharCode(rune);
      buffer.write(_accents[ch] ?? _leet[ch] ?? ch);
    }
    return buffer.toString();
  }

  /// "porraaaa" → "porra": letra repetida 3+ vezes vira uma.
  static String _squeeze(String word) =>
      word.replaceAllMapped(RegExp(r'([a-z])\1{2,}'), (m) => m[1]!);
}
