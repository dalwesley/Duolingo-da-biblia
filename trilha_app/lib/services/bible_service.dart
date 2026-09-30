import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n_global.dart';

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

  /// Leitura e palco: Almeida. TB continua no disco do banco (legado).
  static const defaultTranslationId = 'jfaal';
  static const palcoTranslationId = 'jfaal';
  static const oldTestamentCount = 39;

  static const catalog = <BibleTranslation>[
    BibleTranslation(
      id: 'tb',
      name: 'Tradução Brasileira',
      shortName: 'TB',
      blurb: '1917 · domínio público · usa Jeová',
      assetPath: 'assets/data/bible_tb.json',
      attribution: 'Tradução Brasileira (1917) · domínio público.',
    ),
    BibleTranslation(
      id: 'jfaal',
      name: 'João Ferreira de Almeida Atualizada Livre',
      shortName: 'JFAAL',
      blurb: 'Almeida 1911 atualizada · livre · sem internet',
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
    for (final t in catalog) {
      if (t.id == defaultTranslationId) return t;
    }
    return catalog.first;
  }

  /// Compat: nome da tradução ativa.
  static String get translationName => instance.current.name;

  String _translationId = defaultTranslationId;
  final Map<String, List<BibleBook>> _loaded = {};
  final Map<String, Future<List<BibleBook>>> _loading = {};

  String get translationId => _translationId;
  BibleTranslation get current => byId(_translationId);

  /// Gancho na Home: TB usa Jeová, então o cartão lê Almeida.
  String get readerTranslationId =>
      _translationId == 'tb' ? palcoTranslationId : _translationId;

  /// Troca a tradução ativa. Cache por id — não descarrega as outras.
  Future<void> setTranslation(String id) async {
    final next = byId(id);
    if (!next.available) return;
    if (_translationId == next.id && _loaded.containsKey(next.id)) return;
    _translationId = next.id;
    await books();
  }

  Future<List<BibleBook>> books() async => _booksFor(_translationId);

  Future<List<BibleBook>> _booksFor(String id) async {
    var useId = id;
    if (byId(useId).assetPath == null) {
      useId = defaultTranslationId;
      if (id == _translationId) _translationId = useId;
    }
    final cached = _loaded[useId];
    if (cached != null) return cached;
    // Uma leitura por tradução, mesmo com vários pedidos simultâneos.
    return _loading[useId] ??= _decode(useId).then((list) {
      _loaded[useId] = list;
      return list;
    }).whenComplete(() => _loading.remove(useId));
  }

  Future<List<BibleBook>> _decode(String id) async {
    // rootBundle só no isolate principal; o parse (~4 MB) vai para outro.
    final raw = await rootBundle.loadString(
      byId(id).assetPath!,
      cache: false,
    );
    return compute(_parseBooks, raw);
  }

  static String _norm(String s) => _normalize(s);

  /// Índice de busca por tradução: texto normalizado num bloco só, montado
  /// num isolate na 1ª busca (varrer 31 mil versículos com _norm na UI
  /// thread travava a tela por centenas de ms).
  final Map<String, Future<_SearchIndex>> _searchIndex = {};

  Future<_SearchIndex> _indexFor(String id) {
    return _searchIndex[id] ??= () async {
      final raw = await rootBundle.loadString(
        byId(id).assetPath!,
        cache: false,
      );
      return compute(_buildSearchIndex, raw);
    }();
  }

  /// "livro capítulo[:vIni[–vFim]]"
  static final _refShape = RegExp(
    r'^(.+?)\s+(\d+)(?::(\d+)(?:\s*[-–—]\s*(\d+))?)?',
  );

  /// True se parece citação bíblica ("Gênesis 1:1–2"), não rótulo ("Contexto").
  static bool looksLikeReference(String reference) {
    final compact = _norm(reference);
    return compact.isNotEmpty && _refShape.hasMatch(compact);
  }

  /// Resolve referências como "Gênesis 1:1–2", "Êxodo 3" ou "Gn 12:1-3".
  Future<BibleRef?> resolve(String reference, {String? translationId}) async {
    final list = await _booksFor(translationId ?? _translationId);
    final compact = _norm(reference);

    final m = _refShape.firstMatch(compact);
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
          text: L10n.current.bibleChapterCount(book.chapters.length),
          isBook: true,
        ));
        if (hits.length >= limit) return hits;
      }
    }

    var useId = _translationId;
    if (byId(useId).assetPath == null) useId = defaultTranslationId;
    final index = await _indexFor(useId);
    // indexOf num bloco só: sem alocar string por versículo.
    var from = 0;
    while (hits.length < limit) {
      final at = index.text.indexOf(q, from);
      if (at < 0) break;
      final n = index.verseAt(at);
      final bi = index.book[n];
      final ci = index.chapter[n];
      final vi = index.verse[n];
      if (bi < list.length &&
          ci < list[bi].chapters.length &&
          vi < list[bi].chapters[ci].length) {
        final book = list[bi];
        hits.add(BibleSearchHit(
          bookIndex: bi,
          bookName: book.name,
          abbrev: book.abbrev,
          chapter: ci + 1,
          verse: vi + 1,
          text: book.chapters[ci][vi],
        ));
      }
      // Um acerto por versículo: segue do próximo.
      from = n + 1 < index.starts.length ? index.starts[n + 1] : index.text.length;
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

  /// Texto completo da passagem ("Gênesis 1:1–2"), versículos unidos por espaço.
  Future<String?> passageText(String reference, {String? translationId}) async {
    final id = translationId ?? _translationId;
    final ref = await resolve(reference, translationId: id);
    if (ref == null) return null;
    final list = await _booksFor(id);
    if (ref.bookIndex < 0 || ref.bookIndex >= list.length) return null;
    final chapters = list[ref.bookIndex].chapters;
    if (ref.chapter < 1 || ref.chapter > chapters.length) return null;
    final verses = chapters[ref.chapter - 1];
    final start = ref.verseStart ?? 1;
    final end = ref.verseEnd ?? ref.verseStart ?? verses.length;
    if (start < 1 || start > verses.length) return null;
    final stop = end.clamp(start, verses.length);
    final parts = <String>[];
    for (var v = start; v <= stop; v++) {
      final t = verses[v - 1].trim();
      if (t.isNotEmpty) parts.add(t);
    }
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }
}

List<BibleBook> _parseBooks(String raw) {
  final data = jsonDecode(raw) as List<dynamic>;
  return [
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
}

bool _isSpace(int c) =>
    c == 0x20 ||
    (c >= 0x09 && c <= 0x0D) ||
    c == 0xA0 ||
    c == 0x1680 ||
    (c >= 0x2000 && c <= 0x200A) ||
    c == 0x2028 ||
    c == 0x2029 ||
    c == 0x202F ||
    c == 0x205F ||
    c == 0x3000 ||
    c == 0xFEFF;

/// Minúsculas, sem acento (êéè áàãâ íî óôõ úû ç) e espaços colapsados.
/// Um passe por código em vez de sete RegExp.
String _normalize(String s) {
  final lower = s.trim().toLowerCase();
  final out = Uint16List(lower.length);
  var n = 0;
  var space = false;
  for (final c in lower.codeUnits) {
    if (_isSpace(c)) {
      if (!space) out[n++] = 0x20;
      space = true;
      continue;
    }
    space = false;
    out[n++] = switch (c) {
      0xEA || 0xE9 || 0xE8 => 0x65, // e
      0xE1 || 0xE0 || 0xE3 || 0xE2 => 0x61, // a
      0xED || 0xEE => 0x69, // i
      0xF3 || 0xF4 || 0xF5 => 0x6F, // o
      0xFA || 0xFB => 0x75, // u
      0xE7 => 0x63, // c
      _ => c,
    };
  }
  return String.fromCharCodes(out, 0, n);
}

class _SearchIndex {
  /// Versículos normalizados, separados por '\n' (a busca nunca tem '\n').
  final String text;
  final Int32List starts;
  final Uint8List book;
  final Uint8List chapter;
  final Uint8List verse;

  _SearchIndex(this.text, this.starts, this.book, this.chapter, this.verse);

  /// Versículo que contém a posição [at] (busca binária em [starts]).
  int verseAt(int at) {
    var lo = 0;
    var hi = starts.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (starts[mid] <= at) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo;
  }
}

_SearchIndex _buildSearchIndex(String raw) {
  final books = _parseBooks(raw);
  final text = StringBuffer();
  final starts = <int>[];
  final book = <int>[];
  final chapter = <int>[];
  final verse = <int>[];
  var offset = 0;
  for (var bi = 0; bi < books.length; bi++) {
    final chapters = books[bi].chapters;
    for (var ci = 0; ci < chapters.length; ci++) {
      final verses = chapters[ci];
      for (var vi = 0; vi < verses.length; vi++) {
        final v = _normalize(verses[vi]);
        starts.add(offset);
        book.add(bi);
        chapter.add(ci);
        verse.add(vi);
        text
          ..write(v)
          ..write('\n');
        offset += v.length + 1;
      }
    }
  }
  return _SearchIndex(
    text.toString(),
    Int32List.fromList(starts),
    Uint8List.fromList(book),
    Uint8List.fromList(chapter),
    Uint8List.fromList(verse),
  );
}
