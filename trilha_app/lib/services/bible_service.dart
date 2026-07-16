import 'dart:convert';
import 'package:flutter/services.dart';

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

/// Resultado de busca full-text no texto offline.
class BibleSearchHit {
  final int bookIndex;
  final String bookName;
  final String abbrev;
  final int chapter;
  final int verse;
  final String text;

  const BibleSearchHit({
    required this.bookIndex,
    required this.bookName,
    required this.abbrev,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  String get citation => '$bookName $chapter:$verse';
}

/// Bíblia offline — Tradução Brasileira (1917, domínio público),
/// carregada de assets/data/bible_tb.json.
class BibleService {
  static BibleService? _instance;
  static BibleService get instance => _instance ??= BibleService._();

  BibleService._();

  static const translationName = 'Tradução Brasileira';
  static const oldTestamentCount = 39;

  List<BibleBook>? _books;

  Future<List<BibleBook>> books() async {
    if (_books != null) return _books!;
    final raw = await rootBundle.loadString('assets/data/bible_tb.json');
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

  /// Busca por palavra/frase no texto bíblico (offline).
  Future<List<BibleSearchHit>> search(String query, {int limit = 40}) async {
    final q = _norm(query);
    if (q.length < 2) return const [];
    final list = await books();
    final hits = <BibleSearchHit>[];
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
