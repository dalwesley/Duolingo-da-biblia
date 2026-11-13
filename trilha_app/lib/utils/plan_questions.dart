import '../l10n/study_overlay.dart';
import '../services/content_catalog_service.dart';

/// Perguntas do propósito a partir do banco de cenas: a da própria cena e,
/// para um capítulo sem cena no dia, a da cena que mora naquele capítulo.
///
/// Os estudos não vêm mais todos com o catálogo (passam de 10 MB). Duas
/// fontes: o índice do livro (`content_meta/chapters_<livro>`, só capítulo
/// → cena + perguntas), baixado por [ensureBook], e os estudos em memória,
/// trazidos por trilha ou por [ensureScenes].
class PlanQuestions {
  PlanQuestions._(this._studies, this._byChapter);

  final Map<String, Map<String, dynamic>> _studies;

  /// "genesis:4" → slugs das cenas cujo texto está no capítulo.
  final Map<String, List<String>> _byChapter;

  static PlanQuestions? _cache;
  static Map<String, Map<String, dynamic>>? _cacheSource;

  /// Índices de livro já baixados: livro → "4" → [{s, l, t}].
  static final _books = <String, Map<String, dynamic>>{};

  /// Perguntas das cenas vistas nos índices de livro.
  static final _indexed = <String, ({String? life, String? text})>{};

  static final _ref = RegExp(r'^\s*((?:\d\s*)?\D+?)\s+(\d+)');

  /// Baixa o índice de [bookName] (uma vez por livro).
  static Future<void> ensureBook(String bookName) async {
    final key = normBook(bookName);
    if (_books.containsKey(key)) return;
    final chapters = await ContentCatalogService.instance.chapterIndex(key);
    if (chapters == null) return;
    _books[key] = chapters;
    for (final list in chapters.values) {
      if (list is! List) continue;
      for (final e in list) {
        if (e is! Map || e['s'] is! String) continue;
        _indexed[e['s'] as String] = (
          life: e['l'] as String?,
          text: e['t'] as String?,
        );
      }
    }
  }

  /// Traz os estudos das cenas do propósito.
  static Future<void> ensureScenes(Iterable<String> slugs) =>
      ContentCatalogService.instance.ensureStudies(slugs);

  /// Índice sobre o cache do catálogo (refeito se o cache mudar).
  static PlanQuestions load() {
    final studies = ContentCatalogService.instance.studiesCache ?? const {};
    final cached = _cache;
    if (cached != null && identical(_cacheSource, studies)) return cached;
    final byChapter = <String, List<String>>{};
    final slugs = studies.keys.toList()..sort();
    for (final slug in slugs) {
      final st = studies[slug]!;
      final refs = <String>{
        if (st['passageRef'] is String) st['passageRef'] as String,
        if (st['passages'] is List)
          for (final p in st['passages'] as List)
            if (p is Map && p['ref'] is String) p['ref'] as String,
      };
      for (final ref in refs) {
        final m = _ref.firstMatch(ref);
        if (m == null) continue;
        final key = '${normBook(m.group(1)!)}:${m.group(2)}';
        final list = byChapter.putIfAbsent(key, () => []);
        if (!list.contains(slug)) list.add(slug);
      }
    }
    _cacheSource = studies;
    return _cache = PlanQuestions._(studies, byChapter);
  }

  /// Nome do livro sem acento, espaço nem caixa ("1 Coríntios" → "1corintios").
  static String normBook(String s) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const to = 'aaaaaeeeeiiiiooooouuuuc';
    final out = StringBuffer();
    for (final ch in s.toLowerCase().split('')) {
      if (ch.trim().isEmpty) continue;
      final i = from.indexOf(ch);
      out.write(i < 0 ? ch : to[i]);
    }
    return out.toString();
  }

  /// Pergunta da vida (`focusQuestion`) e do texto (`anchorQuestion`) da cena.
  ({String? life, String? text}) forScene(String slug) {
    final st = _studies[slug];
    final idx = _indexed[slug];
    if (st == null && idx == null) return (life: null, text: null);
    String? pick(String key, String? fromIndex) {
      final v = StudyOverlay.instance.field(slug, key) ?? st?[key] ?? fromIndex;
      return v is String && v.trim().isNotEmpty ? v.trim() : null;
    }

    return (
      life: pick('focusQuestion', idx?.life),
      text: pick('anchorQuestion', idx?.text),
    );
  }

  /// Cena do banco cujo texto está em [bookName] [chapter] (ou `null`).
  /// O índice do livro vem primeiro: põe a cena capítulo a capítulo na
  /// frente das demais.
  String? sceneForChapter(String bookName, int chapter) {
    final key = normBook(bookName);
    final fromIndex = _books[key]?['$chapter'];
    if (fromIndex is List && fromIndex.isNotEmpty) {
      final first = fromIndex.first;
      if (first is Map && first['s'] is String) return first['s'] as String;
    }
    final list = _byChapter['$key:$chapter'];
    return list == null || list.isEmpty ? null : list.first;
  }
}
