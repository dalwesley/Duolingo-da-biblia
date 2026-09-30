/// Ordem cronológica da Bíblia (eventos narrados), agrupada por eras.
///
/// Usa abreviações normalizadas (sem acento, minúsculas) para casar com
/// [BibleBook.abbrev] de qualquer tradução offline.
library;

import '../l10n/l10n_global.dart';

class BibleEra {
  final String id;

  const BibleEra({required this.id});

  String get title => switch (id) {
    'origins' => L10n.current.eraOriginsTitle,
    'exodus' => L10n.current.eraExodusTitle,
    'conquest' => L10n.current.eraConquestTitle,
    'united' => L10n.current.eraUnitedTitle,
    'divided' => L10n.current.eraDividedTitle,
    'exile' => L10n.current.eraExileTitle,
    'return' => L10n.current.eraReturnTitle,
    'gospels' => L10n.current.eraGospelsTitle,
    'church' => L10n.current.eraChurchTitle,
    _ => L10n.current.eraOriginsTitle,
  };

  String get blurb => switch (id) {
    'origins' => L10n.current.eraOriginsBlurb,
    'exodus' => L10n.current.eraExodusBlurb,
    'conquest' => L10n.current.eraConquestBlurb,
    'united' => L10n.current.eraUnitedBlurb,
    'divided' => L10n.current.eraDividedBlurb,
    'exile' => L10n.current.eraExileBlurb,
    'return' => L10n.current.eraReturnBlurb,
    'gospels' => L10n.current.eraGospelsBlurb,
    'church' => L10n.current.eraChurchBlurb,
    _ => L10n.current.eraOriginsBlurb,
  };
}

class BibleChronology {
  BibleChronology._();

  static const eras = <BibleEra>[
    BibleEra(id: 'origins'),
    BibleEra(id: 'exodus'),
    BibleEra(id: 'conquest'),
    BibleEra(id: 'united'),
    BibleEra(id: 'divided'),
    BibleEra(id: 'exile'),
    BibleEra(id: 'return'),
    BibleEra(id: 'gospels'),
    BibleEra(id: 'church'),
  ];

  /// Ordem dos livros pelos eventos (não pela data de composição).
  /// Cada entrada: (abbrev normalizada, era id).
  static const orderedBooks = <(String, String)>[
    // Origens
    ('gn', 'origins'),
    ('jo', 'origins'), // Jó — era patriarcal
    // Êxodo
    ('ex', 'exodus'),
    ('lv', 'exodus'),
    ('nm', 'exodus'),
    ('dt', 'exodus'),
    // Conquista
    ('js', 'conquest'),
    ('jz', 'conquest'),
    ('rt', 'conquest'),
    // Monarquia unida
    ('1sm', 'united'),
    ('2sm', 'united'),
    ('1cr', 'united'),
    ('sl', 'united'),
    ('1rs', 'united'), // começa com Salomão; reinos divididos seguem
    ('2cr', 'united'),
    ('pv', 'united'),
    ('ec', 'united'),
    ('ct', 'united'),
    // Reinos / pré-exílio
    ('2rs', 'divided'),
    ('jn', 'divided'),
    ('am', 'divided'),
    ('os', 'divided'),
    ('is', 'divided'),
    ('mq', 'divided'),
    ('jl', 'divided'),
    ('na', 'divided'),
    ('sf', 'divided'),
    ('hc', 'divided'),
    ('jr', 'divided'),
    ('ob', 'divided'),
    // Exílio
    ('lm', 'exile'),
    ('ez', 'exile'),
    ('dn', 'exile'),
    // Retorno
    ('ed', 'return'),
    ('ag', 'return'),
    ('zc', 'return'),
    ('et', 'return'),
    ('ne', 'return'),
    ('ml', 'return'),
    // Evangelhos
    ('mt', 'gospels'),
    ('mc', 'gospels'),
    ('lc', 'gospels'),
    ('joao', 'gospels'), // João evangelho — ver normalize
    // Igreja
    ('at', 'church'),
    ('tg', 'church'),
    ('gl', 'church'),
    ('1ts', 'church'),
    ('2ts', 'church'),
    ('1co', 'church'),
    ('2co', 'church'),
    ('rm', 'church'),
    ('cl', 'church'),
    ('fm', 'church'),
    ('ef', 'church'),
    ('fp', 'church'),
    ('1tm', 'church'),
    ('tt', 'church'),
    ('1pe', 'church'),
    ('2tm', 'church'),
    ('hb', 'church'),
    ('jd', 'church'),
    ('2pe', 'church'),
    ('1jo', 'church'),
    ('2jo', 'church'),
    ('3jo', 'church'),
    ('ap', 'church'),
  ];

  /// Normaliza abreviação para chave estável.
  /// Distingue Jó (`jo`) de João (`joao`) e Josué (`js`).
  static String normalizeAbbrev(String abbrev, {String? bookName}) {
    final raw = abbrev.trim().toLowerCase();
    var s = raw
        .replaceAll(RegExp(r'[êéè]'), 'e')
        .replaceAll(RegExp(r'[áàãâ]'), 'a')
        .replaceAll(RegExp(r'[íî]'), 'i')
        .replaceAll(RegExp(r'[óôõ]'), 'o')
        .replaceAll(RegExp(r'[úû]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll('.', '');

    // "Jo" no JSON da TB/JFAAL = Jó; João evangelho = "Jo" no NT — desambiguar pelo nome.
    if (s == 'jo' && bookName != null) {
      final n = bookName.toLowerCase();
      if (n.contains('joão') || n.contains('joao')) {
        if (n.startsWith('1') || n.contains('1 ')) return '1jo';
        if (n.startsWith('2') || n.contains('2 ')) return '2jo';
        if (n.startsWith('3') || n.contains('3 ')) return '3jo';
        return 'joao';
      }
      // Jó
      return 'jo';
    }

    // Algumas traduções usam "Jo" só para João (NT) — se abbrev for Jo e nome for João.
    if (s == 'jo' && bookName == null) return 'jo';

    return s;
  }

  /// Índices canônicos dos livros na ordem cronológica.
  /// Livros sem match caem no fim (não deveriam existir nos 66).
  static List<({int bookIndex, String eraId})> chronologicalIndices(
    List<({String abbrev, String name})> books,
  ) {
    final byKey = <String, int>{};
    for (var i = 0; i < books.length; i++) {
      final key = normalizeAbbrev(books[i].abbrev, bookName: books[i].name);
      byKey[key] = i;
    }

    final out = <({int bookIndex, String eraId})>[];
    final used = <int>{};
    for (final (key, eraId) in orderedBooks) {
      final idx = byKey[key];
      if (idx == null) continue;
      out.add((bookIndex: idx, eraId: eraId));
      used.add(idx);
    }
    // Qualquer livro fora da lista (não deveria) — anexa no fim.
    for (var i = 0; i < books.length; i++) {
      if (!used.contains(i)) {
        out.add((bookIndex: i, eraId: eras.last.id));
      }
    }
    return out;
  }
}
