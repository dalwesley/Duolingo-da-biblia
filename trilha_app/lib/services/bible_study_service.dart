import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../utils/lexicon_pt_overrides.dart';
import '../utils/morphology.dart';

class StudyToken {
  final int pos;
  final String surface;
  final String translit;
  final String gloss;
  final String strong;
  final String morph;
  final String morphLabel;

  const StudyToken({
    required this.pos,
    required this.surface,
    required this.translit,
    required this.gloss,
    required this.strong,
    required this.morph,
    required this.morphLabel,
  });
}

class StrongEntry {
  final String id;
  final String lang;
  final String lemma;
  final String translit;
  final String morph;
  final String gloss;
  final String definition;

  const StrongEntry({
    required this.id,
    required this.lang,
    required this.lemma,
    required this.translit,
    required this.morph,
    required this.gloss,
    required this.definition,
  });

  bool get isHebrew => lang == 'H' || id.startsWith('H');
}

class CrossRef {
  final int bookIndex;
  final int chapter;
  final int verse;
  final int? verseEnd;
  final int votes;

  const CrossRef({
    required this.bookIndex,
    required this.chapter,
    required this.verse,
    this.verseEnd,
    required this.votes,
  });
}

class ConcordanceHit {
  final int bookIndex;
  final int chapter;
  final int verse;
  final String gloss;
  final String surface;

  const ConcordanceHit({
    required this.bookIndex,
    required this.chapter,
    required this.verse,
    required this.gloss,
    required this.surface,
  });
}

class BookOccurrence {
  final int bookIndex;
  final int count;

  const BookOccurrence({required this.bookIndex, required this.count});
}

/// Léxico + mapa de usos para uma entrada Strong.
class StrongStudy {
  final StrongEntry? entry;
  final int occurrences;
  final ConcordanceHit? first;
  final ConcordanceHit? last;
  final List<BookOccurrence> byBook;
  final List<ConcordanceHit> nearby;
  final List<ConcordanceHit> spread;

  const StrongStudy({
    required this.entry,
    required this.occurrences,
    required this.first,
    required this.last,
    required this.byBook,
    required this.nearby,
    required this.spread,
  });
}

class VerseStudy {
  final List<StudyToken> tokens;
  final List<CrossRef> crossRefs;

  const VerseStudy({required this.tokens, required this.crossRefs});
}

/// Estudo offline: Strong, morfologia, refs cruzadas e concordância.
class BibleStudyService {
  static BibleStudyService? _instance;
  static BibleStudyService get instance => _instance ??= BibleStudyService._();

  BibleStudyService._();

  static const assetPath = 'assets/data/bible_study.sqlite.gz';
  static const attribution =
      'Léxico e texto etiquetado: STEPBible / Tyndale House Cambridge (CC BY 4.0). '
      'Referências cruzadas: openbible.info (CC BY). '
      'Definições traduzidas automaticamente para português.';

  Database? _db;
  Future<Database>? _opening;

  Future<Database> _database() async {
    if (_db != null) return _db!;
    _opening ??= _open();
    _db = await _opening!;
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'bible_study_v2.sqlite');
    final file = File(path);
    if (!await file.exists() || await file.length() < 1000000) {
      final data = await rootBundle.load(assetPath);
      final compressed = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final bytes = Uint8List.fromList(gzip.decode(compressed));
      await file.writeAsBytes(bytes, flush: true);
    }
    return openDatabase(path, readOnly: true);
  }

  Future<VerseStudy> studyVerse(int bookIndex, int chapter, int verse) async {
    final db = await _database();
    final tokenRows = await db.query(
      'tokens',
      where: 'book = ? AND chapter = ? AND verse = ?',
      whereArgs: [bookIndex, chapter, verse],
      orderBy: 'pos ASC',
    );
    final tokens = [
      for (final r in tokenRows) _tokenFrom(r),
    ];

    final xrefRows = await db.query(
      'cross_refs',
      where: 'from_book = ? AND from_chapter = ? AND from_verse = ?',
      whereArgs: [bookIndex, chapter, verse],
      orderBy: 'votes DESC',
      limit: 12,
    );
    final crossRefs = [
      for (final r in xrefRows)
        CrossRef(
          bookIndex: r['to_book'] as int,
          chapter: r['to_chapter'] as int,
          verse: r['to_verse'] as int,
          verseEnd: r['to_verse_end'] as int?,
          votes: r['votes'] as int,
        ),
    ];

    return VerseStudy(tokens: tokens, crossRefs: crossRefs);
  }

  Future<StrongEntry?> strong(String id) async {
    final db = await _database();
    final key = _normalizeStrong(id);
    final rows = await db.query(
      'lexicon',
      where: 'id = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final r = rows.first;
    final gloss = (r['gloss'] as String?) ?? '';
    final definition = (r['definition'] as String?) ?? '';
    return StrongEntry(
      id: r['id'] as String,
      lang: (r['lang'] as String?) ?? key[0],
      lemma: (r['lemma'] as String?) ?? '',
      translit: (r['translit'] as String?) ?? '',
      morph: (r['morph'] as String?) ?? '',
      gloss: overlayLexiconGloss(key, gloss),
      definition: overlayLexiconDefinition(key, definition),
    );
  }

  Future<List<ConcordanceHit>> concordance(
    String strongId, {
    int limit = 40,
  }) async {
    return concordanceInBook(strongId, null, limit: limit);
  }

  Future<List<ConcordanceHit>> concordanceInBook(
    String strongId,
    int? bookIndex, {
    int limit = 40,
  }) async {
    final db = await _database();
    final key = _normalizeStrong(strongId);
    final rows = bookIndex == null
        ? await db.rawQuery(
            '''
            SELECT book, chapter, verse, gloss, surface
            FROM tokens
            WHERE strong = ?
            GROUP BY book, chapter, verse
            ORDER BY book, chapter, verse
            LIMIT ?
            ''',
            [key, limit],
          )
        : await db.rawQuery(
            '''
            SELECT book, chapter, verse, gloss, surface
            FROM tokens
            WHERE strong = ? AND book = ?
            GROUP BY book, chapter, verse
            ORDER BY chapter, verse
            LIMIT ?
            ''',
            [key, bookIndex, limit],
          );
    return _hitsFrom(key, rows);
  }

  Future<int> occurrenceCount(String strongId) async {
    final db = await _database();
    final key = _normalizeStrong(strongId);
    final rows = await db.rawQuery(
      'SELECT COUNT(DISTINCT book || \':\' || chapter || \':\' || verse) AS c FROM tokens WHERE strong = ?',
      [key],
    );
    return (rows.first['c'] as int?) ?? 0;
  }

  Future<List<BookOccurrence>> occurrenceByBook(String strongId) async {
    final db = await _database();
    final key = _normalizeStrong(strongId);
    final rows = await db.rawQuery(
      '''
      SELECT book, COUNT(DISTINCT chapter || ':' || verse) AS c
      FROM tokens WHERE strong = ?
      GROUP BY book ORDER BY book
      ''',
      [key],
    );
    return [
      for (final r in rows)
        BookOccurrence(
          bookIndex: r['book'] as int,
          count: (r['c'] as int?) ?? 0,
        ),
    ];
  }

  Future<ConcordanceHit?> _edgeOccurrence(String key, {required bool last}) async {
    final db = await _database();
    final dir = last ? 'DESC' : 'ASC';
    final rows = await db.rawQuery(
      '''
      SELECT book, chapter, verse, gloss, surface
      FROM tokens WHERE strong = ?
      GROUP BY book, chapter, verse
      ORDER BY book $dir, chapter $dir, verse $dir
      LIMIT 1
      ''',
      [key],
    );
    if (rows.isEmpty) return null;
    return _hitsFrom(key, rows).first;
  }

  Future<ConcordanceHit?> _firstInBook(String key, int bookIndex) async {
    final rows = await (await _database()).rawQuery(
      '''
      SELECT book, chapter, verse, gloss, surface
      FROM tokens WHERE strong = ? AND book = ?
      GROUP BY book, chapter, verse
      ORDER BY chapter, verse
      LIMIT 1
      ''',
      [key, bookIndex],
    );
    if (rows.isEmpty) return null;
    return _hitsFrom(key, rows).first;
  }

  /// Léxico + concordância em torno do versículo, não só o prefixo da Bíblia.
  Future<StrongStudy> studyStrong(
    String strongId, {
    required int bookIndex,
    required int chapter,
    required int verse,
  }) async {
    assert(chapter >= 1 && verse >= 1);
    final key = _normalizeStrong(strongId);
    final packed = await Future.wait([
      strong(key),
      occurrenceByBook(key),
      concordanceInBook(key, bookIndex, limit: 48),
      _edgeOccurrence(key, last: false),
      _edgeOccurrence(key, last: true),
    ]);
    final entry = packed[0] as StrongEntry?;
    final byBook = packed[1] as List<BookOccurrence>;
    final nearby = packed[2] as List<ConcordanceHit>;
    final first = packed[3] as ConcordanceHit?;
    final last = packed[4] as ConcordanceHit?;
    final occ = byBook.fold<int>(0, (s, b) => s + b.count);

    final others = [
      ...byBook.where((b) => b.bookIndex != bookIndex),
    ]..sort((a, b) => b.count.compareTo(a.count));
    final spread = <ConcordanceHit>[];
    final samples = await Future.wait([
      for (final b in others.take(8)) _firstInBook(key, b.bookIndex),
    ]);
    for (final h in samples) {
      if (h != null) spread.add(h);
    }

    return StrongStudy(
      entry: entry,
      occurrences: occ,
      first: first,
      last: last,
      byBook: byBook,
      nearby: nearby,
      spread: spread,
    );
  }

  static StudyToken _tokenFrom(Map<String, Object?> r) {
    final strong = (r['strong'] as String?) ?? '';
    final key = _normalizeStrong(strong);
    final morph = r['morph'] as String?;
    return StudyToken(
      pos: r['pos'] as int,
      surface: (r['surface'] as String?) ?? '',
      translit: (r['translit'] as String?) ?? '',
      gloss: overlayLexiconGloss(key, (r['gloss'] as String?) ?? ''),
      strong: strong,
      morph: morph ?? '',
      morphLabel: expandMorphology(morph),
    );
  }

  static List<ConcordanceHit> _hitsFrom(
    String strongId,
    List<Map<String, Object?>> rows,
  ) {
    return [
      for (final r in rows)
        ConcordanceHit(
          bookIndex: r['book'] as int,
          chapter: r['chapter'] as int,
          verse: r['verse'] as int,
          gloss: overlayLexiconGloss(strongId, (r['gloss'] as String?) ?? ''),
          surface: (r['surface'] as String?) ?? '',
        ),
    ];
  }

  static String _normalizeStrong(String raw) {
    final s = raw.trim().toUpperCase();
    final m = RegExp(r'^([HG])0*(\d{1,5})([A-Z]?)$').firstMatch(s);
    if (m == null) return s;
    final letter = m.group(1)!;
    final num = int.parse(m.group(2)!);
    return '$letter${num.toString().padLeft(4, '0')}';
  }
}
