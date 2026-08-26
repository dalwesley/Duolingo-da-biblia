/// Números Strong clássicos vs. o sistema estendido STEP (H9xxx / G9xxx).
library;

final _strongRe = RegExp(r'^([HG])0*(\d{1,5})([A-Z]?)$', caseSensitive: false);

class ParsedStrong {
  final String lang;
  final int number;
  final String suffix;

  const ParsedStrong({
    required this.lang,
    required this.number,
    required this.suffix,
  });

  bool get isHebrew => lang == 'H';
}

ParsedStrong? parseStrong(String raw) {
  final m = _strongRe.firstMatch(raw.trim());
  if (m == null) return null;
  return ParsedStrong(
    lang: m.group(1)!.toUpperCase(),
    number: int.parse(m.group(2)!),
    suffix: (m.group(3) ?? '').toUpperCase(),
  );
}

bool isExtendedStrong(String id) {
  final p = parseStrong(id);
  return p != null && p.number >= 9000 && p.number <= 9999;
}

bool isPunctuationStrong(String id) {
  final p = parseStrong(id);
  return p != null && p.number >= 9014 && p.number <= 9019;
}

/// Classe gramatical das partículas STEP (não entram no Strong impresso).
enum StrongKind {
  word,
  prefix,
  suffix,
  conjunction,
  pronoun,
  particle,
  punctuation,
}

StrongKind strongKind(String id) {
  final p = parseStrong(id);
  if (p == null || p.number < 9000 || p.number > 9999) {
    return StrongKind.word;
  }
  final n = p.number;
  if (n >= 9014 && n <= 9019) return StrongKind.punctuation;
  if (n == 9001 || n == 9002) return StrongKind.conjunction;
  if (n >= 9003 && n <= 9009) return StrongKind.prefix;
  if (n >= 9010 && n <= 9013) return StrongKind.suffix;
  if (n >= 9020 && n <= 9075) return StrongKind.pronoun;
  return StrongKind.particle;
}

String strongKindLabel(StrongKind kind, {required bool hebrew}) {
  switch (kind) {
    case StrongKind.prefix:
      return 'PREFIXO';
    case StrongKind.suffix:
      return 'SUFIXO';
    case StrongKind.conjunction:
      return 'CONJUNÇÃO';
    case StrongKind.pronoun:
      return 'PRONOME';
    case StrongKind.particle:
      return 'PARTÍCULA';
    case StrongKind.punctuation:
      return 'PONTUAÇÃO';
    case StrongKind.word:
      return hebrew ? 'HEBRAICO' : 'GREGO';
  }
}

String strongKindNote(StrongKind kind) {
  switch (kind) {
    case StrongKind.prefix:
      return 'Preposição ou artigo inseparável — cola-se à palavra seguinte. Não é verbete do Strong clássico.';
    case StrongKind.suffix:
      return 'Terminação gramatical, não um verbete de dicionário.';
    case StrongKind.conjunction:
      return 'Conjunção prefixada (vav). O sentido está no verbo ou no nome que ela liga.';
    case StrongKind.pronoun:
      return 'Pronome sufixado: quem recebe ou possui o que a palavra diz.';
    case StrongKind.particle:
      return 'Partícula gramatical do sistema STEP, não um número Strong clássico.';
    case StrongKind.punctuation:
      return 'Marca de leitura do texto hebraico, não uma palavra.';
    case StrongKind.word:
      return '';
  }
}
