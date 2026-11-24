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

  /// Idioma do texto (`pt`, `en`, `es`). O leitor só oferece as do idioma do app.
  final String language;

  /// Crédito/licença a exibir quando a tradução estiver ativa.
  final String? attribution;

  const BibleTranslation({
    required this.id,
    required this.name,
    required this.shortName,
    required this.blurb,
    this.language = 'pt',
    this.assetPath,
    this.attribution,
  });

  bool get available => assetPath != null;
}

/// Um livro da Bíblia carregado do asset offline.
class BibleBook {
  final String name;

  /// Sigla PT em todas as traduções: é chave de progresso (capítulos lidos,
  /// marcadores, notas). Para exibir, use [short].
  final String abbrev;

  /// Sigla no idioma da tradução (EN "Ex", ES "Éx"); PT = [abbrev].
  final String short;
  final List<List<String>> chapters;

  const BibleBook({
    required this.name,
    required this.abbrev,
    String? short,
    required this.chapters,
  }) : short = short ?? abbrev;
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

  String get citation => isBook ? bookName : '$bookName $chapter:$verse';
}

/// Bíblia offline — tradução ativa escolhida pelo usuário.
class BibleService {
  static BibleService? _instance;
  static BibleService get instance => _instance ??= BibleService._();

  BibleService._();

  /// Leitura PT: Almeida. TB continua no disco do banco (legado).
  static const defaultTranslationId = 'jfaal';

  /// Palco das perguntas: sempre JFAAL, em qualquer idioma. Toque, Ordenar e
  /// Completar usam palavras exatas da JFAAL (o overlay EN/ES não traduz os
  /// tokens do versículo); trocar o palco quebraria essas perguntas.
  static const palcoTranslationId = 'jfaal';

  /// Tradução padrão de leitura por idioma do app.
  static const _defaultByLanguage = {'pt': 'jfaal', 'en': 'bsb', 'es': 'bes'};
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
      id: 'bsb',
      name: 'Berean Standard Bible',
      shortName: 'BSB',
      blurb: 'Modern English · public domain · offline',
      language: 'en',
      assetPath: 'assets/data/bible_bsb.json',
      attribution:
          'The Holy Bible, Berean Standard Bible (BSB). '
          'Dedicated to the public domain.',
    ),
    BibleTranslation(
      id: 'bes',
      name: 'La Biblia en Español Sencillo',
      shortName: 'BES',
      blurb: 'Español actual · dominio público · sin internet',
      language: 'es',
      assetPath: 'assets/data/bible_bes.json',
      attribution:
          'La Biblia en Español Sencillo (2026), AudioBiblia.org. '
          'Dominio público.',
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

  static String _languageOf(String? localeName) {
    final code = (localeName ?? L10n.current.localeName)
        .split(RegExp(r'[_-]'))
        .first
        .toLowerCase();
    return _defaultByLanguage.containsKey(code) ? code : 'pt';
  }

  /// Idiomas de texto bíblico, na ordem em que o leitor os lista.
  static const textLanguages = ['pt', 'en', 'es'];

  /// Traduções de um idioma de texto (inclui as "em breve").
  static List<BibleTranslation> translationsIn(String language) => [
    for (final t in catalog)
      if (t.language == language) t,
  ];

  /// Escolha salva → mapa idioma do app → tradução.
  ///
  /// `settings.bibleTranslationId` guarda `pt=tb;en=jfaal` (cada idioma do app
  /// lembra a sua). Valor antigo sem `=` ("tb") vale para o idioma do próprio
  /// texto. App antigo lê o formato novo como id desconhecido e cai na JFAAL.
  static Map<String, String> _choices(String stored) {
    final out = <String, String>{};
    if (!stored.contains('=')) {
      if (stored.isNotEmpty) out[byId(stored).language] = stored;
      return out;
    }
    for (final part in stored.split(';')) {
      final i = part.indexOf('=');
      if (i <= 0) continue;
      final lang = part.substring(0, i).trim();
      final id = part.substring(i + 1).trim();
      if (lang.isNotEmpty && id.isNotEmpty) out[lang] = id;
    }
    return out;
  }

  /// Grava [id] como escolha do idioma do app, sem mexer nos outros.
  static String withChoice(String stored, String id, [String? localeName]) {
    final map = _choices(stored)..[_languageOf(localeName)] = id;
    return [
      for (final lang in textLanguages)
        if (map[lang] != null) '$lang=${map[lang]}',
    ].join(';');
  }

  /// Tradução que de fato aparece: a escolha salva para o idioma do app (de
  /// qualquer língua de texto — dá para ler a BSB com o app em PT); sem
  /// escolha ou sem texto, a padrão do idioma.
  static String effectiveId(String stored, [String? localeName]) {
    final lang = _languageOf(localeName);
    final id = _choices(stored)[lang];
    if (id != null) {
      final t = byId(id);
      if (t.id == id && t.available) return id;
    }
    return _defaultByLanguage[lang]!;
  }

  /// Compat: nome da tradução ativa.
  static String get translationName => instance.current.name;

  String _translationId = defaultTranslationId;
  final Map<String, List<BibleBook>> _loaded = {};
  final Map<String, Future<List<BibleBook>>> _loading = {};

  /// Tradução em uso no idioma atual (ver [effectiveId]).
  // _translationId guarda a escolha salva crua (pode ser `pt=tb;en=bsb`).
  String get translationId => effectiveId(_translationId);
  BibleTranslation get current => byId(translationId);

  /// Gancho na Home: TB usa Jeová, então o cartão lê Almeida.
  String get readerTranslationId {
    final id = translationId;
    return id == 'tb' ? palcoTranslationId : id;
  }

  /// Aplica a escolha salva (`settings.bibleTranslationId`, ver [effectiveId]).
  Future<void> setTranslation(String stored) async {
    final next = effectiveId(stored);
    debugPrint(
      '[STWAY:Bible] setTranslation($stored) → $next '
      'current=$translationId loaded=${_loaded.keys.toList()}',
    );
    _translationId = stored;
    await books();
  }

  /// Texto de um versículo numa tradução específica (comparar versões).
  Future<String?> verseIn(
    String translationId,
    int bookIndex,
    int chapter,
    int verse,
  ) async {
    final list = await _booksFor(translationId);
    if (bookIndex < 0 || bookIndex >= list.length) return null;
    final chapters = list[bookIndex].chapters;
    if (chapter < 1 || chapter > chapters.length) return null;
    final verses = chapters[chapter - 1];
    if (verse < 1 || verse > verses.length) return null;
    final t = verses[verse - 1].trim();
    return t.isEmpty ? null : t;
  }

  /// Solta da memória as traduções fora de uso (~15 MB cada). A ativa e o
  /// palco ficam.
  void releaseExtras() {
    final keep = {translationId, palcoTranslationId};
    _loaded.removeWhere((id, _) => !keep.contains(id));
    _searchIndex.removeWhere((id, _) => !keep.contains(id));
  }

  Future<List<BibleBook>> books() async => _booksFor(translationId);

  Future<List<BibleBook>> _booksFor(String id) async {
    var useId = id;
    final known = byId(useId);
    if (known.id != useId || known.assetPath == null) {
      useId = effectiveId(useId);
    }
    final cached = _loaded[useId];
    if (cached != null) return cached;
    debugPrint(
      '[STWAY:Bible] books($useId) '
      '${_loading.containsKey(useId) ? 'joins pending load' : 'starts load'}',
    );
    // Uma leitura por tradução, mesmo com vários pedidos simultâneos.
    return _loading[useId] ??= _decode(useId)
        .then(
          (list) {
            _loaded[useId] = list;
            return list;
          },
          onError: (Object e, StackTrace st) {
            debugPrint('[STWAY:Bible] books($useId) failed: $e\n$st');
            throw e;
          },
        )
        .whenComplete(() {
          // Bloco, não arrow: `remove` devolve este mesmo future, e
          // whenComplete esperaria por ele — quem entrou na fila travava.
          _loading.remove(useId);
        });
  }

  Future<List<BibleBook>> _decode(String id) async {
    // rootBundle só no isolate principal; o parse (~4 MB) vai para outro.
    final sw = Stopwatch()..start();
    final raw = await rootBundle.loadString(byId(id).assetPath!, cache: false);
    debugPrint(
      '[STWAY:Bible] decode($id) asset ${raw.length} chars '
      'in ${sw.elapsedMilliseconds}ms',
    );
    final list = await compute(_parseBooks, raw);
    debugPrint(
      '[STWAY:Bible] decode($id) parsed ${list.length} books '
      'in ${sw.elapsedMilliseconds}ms',
    );
    return list;
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
  /// Em EN/ES também aceita o nome PT: o conteúdo cita livros em português.
  Future<BibleRef?> resolve(String reference, {String? translationId}) async {
    final list = await _booksFor(translationId ?? this.translationId);
    final compact = _norm(reference);

    final m = _refShape.firstMatch(compact);
    if (m == null) return null;

    final bookQuery = m.group(1)!.trim();
    var bookIndex = -1;
    for (var i = 0; i < list.length; i++) {
      final name = _norm(list[i].name);
      final abbrev = _norm(list[i].abbrev);
      final short = _norm(list[i].short);
      if (name == bookQuery ||
          abbrev == bookQuery ||
          short == bookQuery ||
          name.startsWith(bookQuery)) {
        bookIndex = i;
        break;
      }
    }
    if (bookIndex < 0 && list.length == _ptBookNames.length) {
      for (var i = 0; i < _ptBookNames.length; i++) {
        final name = _norm(_ptBookNames[i]);
        if (name == bookQuery || name.startsWith(bookQuery)) {
          bookIndex = i;
          break;
        }
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
      final short = _norm(book.short);
      if (name.contains(q) || abbrev.contains(q) || short.contains(q)) {
        hits.add(
          BibleSearchHit(
            bookIndex: bi,
            bookName: book.name,
            abbrev: book.abbrev,
            chapter: 1,
            verse: 0,
            text: L10n.current.bibleChapterCount(book.chapters.length),
            isBook: true,
          ),
        );
        if (hits.length >= limit) return hits;
      }
    }

    final index = await _indexFor(translationId);
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
        hits.add(
          BibleSearchHit(
            bookIndex: bi,
            bookName: book.name,
            abbrev: book.abbrev,
            chapter: ci + 1,
            verse: vi + 1,
            text: book.chapters[ci][vi],
          ),
        );
      }
      // Um acerto por versículo: segue do próximo.
      from = n + 1 < index.starts.length
          ? index.starts[n + 1]
          : index.text.length;
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
    final id = translationId ?? this.translationId;
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
        short: b['short'] as String?,
        chapters: [
          for (final c in b['chapters'] as List<dynamic>)
            [for (final v in c as List<dynamic>) v as String],
        ],
      ),
  ];
}

/// Nomes PT na ordem canônica — referências do conteúdo em qualquer idioma.
const _ptBookNames = <String>[
  'Gênesis', 'Êxodo', 'Levítico', 'Números', 'Deuteronômio', 'Josué', //
  'Juízes', 'Rute', '1 Samuel', '2 Samuel', '1 Reis', '2 Reis', //
  '1 Crônicas', '2 Crônicas', 'Esdras', 'Neemias', 'Ester', 'Jó', //
  'Salmos', 'Provérbios', 'Eclesiastes', 'Cânticos', 'Isaías', //
  'Jeremias', 'Lamentações de Jeremias', 'Ezequiel', 'Daniel', 'Oséias', //
  'Joel', 'Amós', 'Obadias', 'Jonas', 'Miquéias', 'Naum', 'Habacuque', //
  'Sofonias', 'Ageu', 'Zacarias', 'Malaquias', 'Mateus', 'Marcos', //
  'Lucas', 'João', 'Atos', 'Romanos', '1 Coríntios', '2 Coríntios', //
  'Gálatas', 'Efésios', 'Filipenses', 'Colossenses', //
  '1 Tessalonicenses', '2 Tessalonicenses', '1 Timóteo', '2 Timóteo', //
  'Tito', 'Filemom', 'Hebreus', 'Tiago', '1 Pedro', '2 Pedro', '1 João', //
  '2 João', '3 João', 'Judas', 'Apocalipse', //
];

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
