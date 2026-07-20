import 'dart:convert';
import 'package:flutter/services.dart';

/// Uma tradução bíblica conhecida pelo app.
class BibleTranslation {
  final String id;
  final String name;
  final String shortName;
  final String blurb;
  final String? assetPath;

  /// Crédito/licença a exibir quando a tradução estiver ativa.
  final String? attribution;

  const BibleTranslation({
    required this.id,
    required this.name,
    required this.shortName,
    required this.blurb,
    this.assetPath,
    this.attribution,
  });

  bool get available => assetPath != null;
}

/// Um livro da Bíblia carregado do asset offline.
class BibleBook {
  final String name;
  final String abbrev;
  final List<List<String>> chapters;

  const BibleBook({
    required this.name,
    required this.abbrev,
    required this.chapters,
  });
}

/// Referência resolvida ("Gênesis 1:1–2" → livro/capítulo/versículos).
class BibleRef {
  final int bookIndex;
  final int chapter;
  final int? verseStart;
  final int? verseEnd;

  const BibleRef({
    required this.bookIndex,
    required this.chapter,
    this.verseStart,
    this.verseEnd,
  });
}

/// Resultado de busca: livro (nome/abrev) ou versículo (texto offline).
class BibleSearchHit {
  final int bookIndex;
  final String bookName;
  final String abbrev;
  final int chapter;
  final int verse;
  final String text;

  /// `true` quando o match é o livro em si (nome/abreviação), não um versículo.
  final bool isBook;

  const BibleSearchHit({
    required this.bookIndex,
    required this.bookName,
    required this.abbrev,
    required this.chapter,
    required this.verse,
    required this.text,
    this.isBook = false,
  });

  String get citation =>
      isBook ? bookName : '$bookName $chapter:$verse';
}

/// Bíblia offline — tradução ativa escolhida pelo usuário.
class BibleService {
  static BibleService? _instance;
  static BibleService get instance => _instance ??= BibleService._();

  BibleService._();

  static const defaultTranslationId = 'tb';
  static const oldTestamentCount = 39;

  static const catalog = <BibleTranslation>[
    BibleTranslation(
      id: 'tb',
      name: 'Tradução Brasileira',
      shortName: 'TB',
      blurb: '1917 · domínio público · offline',
      assetPath: 'assets/data/bible_tb.json',
      attribution: 'Tradução Brasileira (1917) · domínio público.',
    ),
    BibleTranslation(
      id: 'jfaal',
      name: 'João Ferreira de Almeida Atualizada Livre',
      shortName: 'JFAAL',
      blurb: 'Almeida 1911 atualizada · livre · offline',
      assetPath: 'assets/data/bible_jfaal.json',
      attribution:
          'Escrituras em português da JFAAL, Copyright © Marcos Cristiano '
          'Alves Ferreira. Setembro de 2024. Licença CC BY 3.0 BR.',
    ),
    BibleTranslation(
      id: 'ara',
      name: 'Almeida Revista e Atualizada',
      shortName: 'ARA',
      blurb: 'Em breve',
    ),
    BibleTranslation(
      id: 'nvi',
      name: 'Nova Versão Internacional',
      shortName: 'NVI',
      blurb: 'Em breve',
    ),
  ];

  static BibleTranslation byId(String id) {
    for (final t in catalog) {
      if (t.id == id) return t;
    }
    return catalog.first;
  }

  /// Compat: nome da tradução ativa.
  static String get translationName => instance.current.name;

  String _translationId = defaultTranslationId;
  List<BibleBook>? _books;

  String get translationId => _translationId;
  BibleTranslation get current => byId(_translationId);

  /// Troca a tradução ativa e limpa o cache de livros.
  Future<void> setTranslation(String id) async {
    final next = byId(id);
    if (!next.available) return;
    if (_translationId == next.id && _books != null) return;
    _translationId = next.id;
    _books = null;
    await books();
  }

  Future<List<BibleBook>> books() async {
    if (_books != null) return _books!;
    final path = current.assetPath;
    if (path == null) {
      // Fallback seguro caso a preferência aponte para algo indisponível.
      _translationId = defaultTranslationId;
    }
    final raw = await rootBundle.loadString(
      byId(_translationId).assetPath!,
    );
    final data = jsonDecode(raw) as List<dynamic>;
    _books = [
      for (final b in data)
        BibleBook(
          name: (b as Map<String, dynamic>)['name'] as String,
          abbrev: b['abbrev'] as String,
          chapters: [
            for (final c in b['chapters'] as List<dynamic>)
              [for (final v in c as List<dynamic>) v as String],
          ],
        ),
    ];
    return _books!;
  }

  static String _norm(String s) => s
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[êéè]'), 'e')
      .replaceAll(RegExp(r'[áàãâ]'), 'a')
      .replaceAll(RegExp(r'[íî]'), 'i')
      .replaceAll(RegExp(r'[óôõ]'), 'o')
      .replaceAll(RegExp(r'[úû]'), 'u')
      .replaceAll('ç', 'c')
      .replaceAll(RegExp(r'\s+'), ' ');

  /// Resolve referências como "Gênesis 1:1–2", "Êxodo 3" ou "Gn 12:1-3".
  Future<BibleRef?> resolve(String reference) async {
    final list = await books();
    final compact = _norm(reference);

    // "livro capítulo[:vIni[–vFim]]"
    final m = RegExp(r'^(.+?)\s+(\d+)(?::(\d+)(?:\s*[-–—]\s*(\d+))?)?')
        .firstMatch(compact);
    if (m == null) return null;

    final bookQuery = m.group(1)!.trim();
    var bookIndex = -1;
    for (var i = 0; i < list.length; i++) {
      final name = _norm(list[i].name);
      final abbrev = _norm(list[i].abbrev);
      if (name == bookQuery || abbrev == bookQuery || name.startsWith(bookQuery)) {
        bookIndex = i;
        break;
      }
    }
    if (bookIndex < 0) return null;

    final chapter = int.parse(m.group(2)!);
    if (chapter < 1 || chapter > list[bookIndex].chapters.length) return null;

    return BibleRef(
      bookIndex: bookIndex,
      chapter: chapter,
      verseStart: m.group(3) != null ? int.parse(m.group(3)!) : null,
      verseEnd: m.group(4) != null ? int.parse(m.group(4)!) : null,
    );
  }

  /// Busca livros (nome/abrev) e versículos no texto bíblico (offline).
  Future<List<BibleSearchHit>> search(String query, {int limit = 40}) async {
    final q = _norm(query);
    if (q.length < 2) return const [];
    final list = await books();
    final hits = <BibleSearchHit>[];

    // Livros primeiro — "apocali" → Apocalipse, "gn" → Gênesis, etc.
    for (var bi = 0; bi < list.length; bi++) {
      final book = list[bi];
      final name = _norm(book.name);
      final abbrev = _norm(book.abbrev);
      if (name.contains(q) || abbrev.contains(q)) {
        hits.add(BibleSearchHit(
          bookIndex: bi,
          bookName: book.name,
          abbrev: book.abbrev,
          chapter: 1,
          verse: 0,
          text: '${book.chapters.length} capítulos',
          isBook: true,
        ));
        if (hits.length >= limit) return hits;
      }
    }

    for (var bi = 0; bi < list.length; bi++) {
      final book = list[bi];
      for (var ci = 0; ci < book.chapters.length; ci++) {
        final chapter = book.chapters[ci];
        for (var vi = 0; vi < chapter.length; vi++) {
          if (_norm(chapter[vi]).contains(q)) {
            hits.add(BibleSearchHit(
              bookIndex: bi,
              bookName: book.name,
              abbrev: book.abbrev,
              chapter: ci + 1,
              verse: vi + 1,
              text: chapter[vi],
            ));
            if (hits.length >= limit) return hits;
          }
        }
      }
    }
    return hits;
  }

  Future<String?> verseText(String abbrev, int chapter, int verse) async {
    final list = await books();
    final i = list.indexWhere((b) => _norm(b.abbrev) == _norm(abbrev));
    if (i < 0) return null;
    final chapters = list[i].chapters;
    if (chapter < 1 || chapter > chapters.length) return null;
    final verses = chapters[chapter - 1];
    if (verse < 1 || verse > verses.length) return null;
    return verses[verse - 1];
  }
}
