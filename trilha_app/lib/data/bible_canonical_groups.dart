/// Divisões canônicas (ordem protestante) — Pentateuco, Históricos, etc.
library;

class BibleCanonGroup {
  final String id;
  final String title;
  final String blurb;

  /// Índices inclusivos no cânon de 66 livros (0-based).
  final int startIndex;
  final int endIndex;

  const BibleCanonGroup({
    required this.id,
    required this.title,
    required this.blurb,
    required this.startIndex,
    required this.endIndex,
  });

  int get count => endIndex - startIndex + 1;
}

class BibleCanonicalGroups {
  BibleCanonicalGroups._();

  static const groups = <BibleCanonGroup>[
    // Antigo Testamento (0–38)
    BibleCanonGroup(
      id: 'pentateuco',
      title: 'Pentateuco',
      blurb: 'A Lei — Gênesis a Deuteronômio',
      startIndex: 0,
      endIndex: 4,
    ),
    BibleCanonGroup(
      id: 'historicos',
      title: 'Históricos',
      blurb: 'Josué a Ester — a história de Israel',
      startIndex: 5,
      endIndex: 16,
    ),
    BibleCanonGroup(
      id: 'poeticos',
      title: 'Poéticos e Sabedoria',
      blurb: 'Jó a Cantares',
      startIndex: 17,
      endIndex: 21,
    ),
    BibleCanonGroup(
      id: 'profetas-maiores',
      title: 'Profetas Maiores',
      blurb: 'Isaías a Daniel',
      startIndex: 22,
      endIndex: 26,
    ),
    BibleCanonGroup(
      id: 'profetas-menores',
      title: 'Profetas Menores',
      blurb: 'Oséias a Malaquias',
      startIndex: 27,
      endIndex: 38,
    ),
    // Novo Testamento (39–65)
    BibleCanonGroup(
      id: 'evangelhos',
      title: 'Evangelhos',
      blurb: 'Mateus a João — a vida de Jesus',
      startIndex: 39,
      endIndex: 42,
    ),
    BibleCanonGroup(
      id: 'historia-nt',
      title: 'História',
      blurb: 'Atos dos Apóstolos',
      startIndex: 43,
      endIndex: 43,
    ),
    BibleCanonGroup(
      id: 'paulinas',
      title: 'Cartas Paulinas',
      blurb: 'Romanos a Filemom',
      startIndex: 44,
      endIndex: 56,
    ),
    BibleCanonGroup(
      id: 'gerais',
      title: 'Cartas Gerais',
      blurb: 'Hebreus a Judas',
      startIndex: 57,
      endIndex: 64,
    ),
    BibleCanonGroup(
      id: 'profecia',
      title: 'Profecia',
      blurb: 'Apocalipse',
      startIndex: 65,
      endIndex: 65,
    ),
  ];
}
