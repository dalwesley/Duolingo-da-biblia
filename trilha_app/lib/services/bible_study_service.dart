import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

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
      for (final r in tokenRows)
        StudyToken(
          pos: r['pos'] as int,
          surface: (r['surface'] as String?) ?? '',
          translit: (r['translit'] as String?) ?? '',
          gloss: (r['gloss'] as String?) ?? '',
          strong: (r['strong'] as String?) ?? '',
          morph: (r['morph'] as String?) ?? '',
          morphLabel: expandMorphology(r['morph'] as String?),
        ),
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
    return StrongEntry(
      id: r['id'] as String,
      lang: (r['lang'] as String?) ?? key[0],
      lemma: (r['lemma'] as String?) ?? '',
      translit: (r['translit'] as String?) ?? '',
      morph: (r['morph'] as String?) ?? '',
      gloss: (r['gloss'] as String?) ?? '',
      definition: (r['definition'] as String?) ?? '',
    );
  }

  Future<List<ConcordanceHit>> concordance(
    String strongId, {
    int limit = 40,
  }) async {
    final db = await _database();
    final key = _normalizeStrong(strongId);
    final rows = await db.rawQuery(
      '''
      SELECT book, chapter, verse, gloss, surface
      FROM tokens
      WHERE strong = ?
      GROUP BY book, chapter, verse
      ORDER BY book, chapter, verse
      LIMIT ?
      ''',
      [key, limit],
    );
    return [
      for (final r in rows)
        ConcordanceHit(
          bookIndex: r['book'] as int,
          chapter: r['chapter'] as int,
          verse: r['verse'] as int,
          gloss: (r['gloss'] as String?) ?? '',
          surface: (r['surface'] as String?) ?? '',
        ),
    ];
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

  static String _normalizeStrong(String raw) {
    final s = raw.trim().toUpperCase();
    final m = RegExp(r'^([HG])0*(\d{1,5})([A-Z]?)$').firstMatch(s);
    if (m == null) return s;
    final letter = m.group(1)!;
    final num = int.parse(m.group(2)!);
    return '$letter${num.toString().padLeft(4, '0')}';
  }
}
