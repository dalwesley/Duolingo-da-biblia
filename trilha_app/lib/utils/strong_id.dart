/// Números Strong clássicos vs. o sistema estendido STEP (H9xxx / G9xxx).
library;

import '../l10n/l10n_global.dart';

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
  final l = L10n.current;
  switch (kind) {
    case StrongKind.prefix:
      return l.strongKindPrefix;
    case StrongKind.suffix:
      return l.strongKindSuffix;
    case StrongKind.conjunction:
      return l.strongKindConjunction;
    case StrongKind.pronoun:
      return l.strongKindPronoun;
    case StrongKind.particle:
      return l.strongKindParticle;
    case StrongKind.punctuation:
      return l.strongKindPunctuation;
    case StrongKind.word:
      return hebrew ? l.strongKindHebrew : l.strongKindGreek;
  }
}

String strongKindNote(StrongKind kind) {
  final l = L10n.current;
  switch (kind) {
    case StrongKind.prefix:
      return l.strongNotePrefix;
    case StrongKind.suffix:
      return l.strongNoteSuffix;
    case StrongKind.conjunction:
      return l.strongNoteConjunction;
    case StrongKind.pronoun:
      return l.strongNotePronoun;
    case StrongKind.particle:
      return l.strongNoteParticle;
    case StrongKind.punctuation:
      return l.strongNotePunctuation;
    case StrongKind.word:
      return '';
  }
}
