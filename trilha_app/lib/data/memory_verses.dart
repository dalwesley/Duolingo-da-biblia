/// Versículos para o loop de memorização (SRS leve).
class MemoryVerse {
  final String id;
  final String reference;
  final String text;
  final String? abbrev;
  final int? chapter;
  final int? verse;

  const MemoryVerse({
    required this.id,
    required this.reference,
    required this.text,
    this.abbrev,
    this.chapter,
    this.verse,
  });
}

class MemoryVerseCatalog {
  static const curated = <MemoryVerse>[
    MemoryVerse(
      id: 'sl119_105',
      reference: 'Salmos 119:105',
      text: 'Lâmpada para os meus pés é a tua palavra e luz para o meu caminho.',
      abbrev: 'sl',
      chapter: 119,
      verse: 105,
    ),
    MemoryVerse(
      id: 'jo3_16',
      reference: 'João 3:16',
      text:
          'Porque Deus amou o mundo de tal maneira que deu o seu Filho unigênito, para que todo aquele que nele crê não pereça, mas tenha a vida eterna.',
      abbrev: 'jo',
      chapter: 3,
      verse: 16,
    ),
    MemoryVerse(
      id: 'fp4_13',
      reference: 'Filipenses 4:13',
      text: 'Tudo posso naquele que me fortalece.',
      abbrev: 'fp',
      chapter: 4,
      verse: 13,
    ),
    MemoryVerse(
      id: 'pv3_5',
      reference: 'Provérbios 3:5',
      text: 'Confia no Senhor de todo o teu coração e não te estribes no teu próprio entendimento.',
      abbrev: 'pv',
      chapter: 3,
      verse: 5,
    ),
    MemoryVerse(
      id: 'mt28_19',
      reference: 'Mateus 28:19',
      text: 'Ide, portanto, fazei discípulos de todas as nações, batizando-os em nome do Pai, e do Filho, e do Espírito Santo.',
      abbrev: 'mt',
      chapter: 28,
      verse: 19,
    ),
    MemoryVerse(
      id: 'rm8_28',
      reference: 'Romanos 8:28',
      text:
          'Sabemos que todas as coisas cooperam para o bem daqueles que amam a Deus, daqueles que são chamados segundo o seu propósito.',
      abbrev: 'rm',
      chapter: 8,
      verse: 28,
    ),
    MemoryVerse(
      id: 'is41_10',
      reference: 'Isaías 41:10',
      text: 'Não temas, porque eu sou contigo; não te assombres, porque eu sou o teu Deus.',
      abbrev: 'is',
      chapter: 41,
      verse: 10,
    ),
    MemoryVerse(
      id: 'sl23_1',
      reference: 'Salmos 23:1',
      text: 'O Senhor é o meu pastor; nada me faltará.',
      abbrev: 'sl',
      chapter: 23,
      verse: 1,
    ),
    MemoryVerse(
      id: 'jo1_1',
      reference: 'João 1:1',
      text: 'No princípio era o Verbo, e o Verbo estava com Deus, e o Verbo era Deus.',
      abbrev: 'jo',
      chapter: 1,
      verse: 1,
    ),
    MemoryVerse(
      id: 'gn1_1',
      reference: 'Gênesis 1:1',
      text: 'No princípio, Deus criou os céus e a terra.',
      abbrev: 'gn',
      chapter: 1,
      verse: 1,
    ),
    MemoryVerse(
      id: 'at1_8',
      reference: 'Atos 1:8',
      text:
          'Mas recebereis poder, ao descer sobre vós o Espírito Santo, e sereis minhas testemunhas… até aos confins da terra.',
      abbrev: 'at',
      chapter: 1,
      verse: 8,
    ),
    MemoryVerse(
      id: 'ap21_4',
      reference: 'Apocalipse 21:4',
      text: 'E lhes enxugará dos olhos toda lágrima, e não haverá mais morte…',
      abbrev: 'ap',
      chapter: 21,
      verse: 4,
    ),
  ];

  static MemoryVerse? byId(String id) {
    for (final v in curated) {
      if (v.id == id) return v;
    }
    return null;
  }
}
