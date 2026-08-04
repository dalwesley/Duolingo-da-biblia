import '../services/content_catalog_service.dart';

/// Conteúdo de estudo por missão — profundidade além do quiz.
/// Fonte: Firestore → cache em disco
/// (via [ContentCatalogService]).
class RelatedVerse {
  final String reference;
  final String reason;

  const RelatedVerse({required this.reference, required this.reason});

  factory RelatedVerse.fromMap(Map<String, dynamic> map) {
    return RelatedVerse(
      reference: map['reference'] as String? ?? '',
      reason: map['reason'] as String? ?? '',
    );
  }
}

class MissionStudy {
  final String passageRef;
  final String passageText;
  final String context;
  final String keyword;
  final String keywordGloss;
  final String focusQuestion;
  final List<String> reflectionPrompts;
  final List<RelatedVerse> relatedVerses;

  const MissionStudy({
    required this.passageRef,
    required this.passageText,
    required this.context,
    required this.keyword,
    required this.keywordGloss,
    required this.focusQuestion,
    required this.reflectionPrompts,
    this.relatedVerses = const [],
  });

  factory MissionStudy.fromMap(Map<String, dynamic> remote) {
    return MissionStudy(
      passageRef: remote['passageRef'] as String? ?? '',
      passageText: remote['passageText'] as String? ?? '',
      context: remote['context'] as String? ?? '',
      keyword: remote['keyword'] as String? ?? '',
      keywordGloss: remote['keywordGloss'] as String? ?? '',
      focusQuestion: remote['focusQuestion'] as String? ?? '',
      reflectionPrompts: (remote['reflectionPrompts'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      relatedVerses: (remote['relatedVerses'] as List? ?? [])
          .whereType<Map>()
          .map((e) => RelatedVerse.fromMap(Map<String, dynamic>.from(e)))
          .where((v) => v.reference.isNotEmpty)
          .toList(),
    );
  }

  /// Síncrono: usa o cache já carregado pelo catálogo.
  static MissionStudy? forSlug(String slug) {
    final remote = ContentCatalogService.instance.studiesCache?[slug];
    if (remote == null) return null;
    return MissionStudy.fromMap(remote);
  }


  /// Texto do versículo para releitura no erro (por referência).
  static String? verseText(String? ref) {
    if (ref == null || ref.trim().isEmpty) return null;
    final verses = ContentCatalogService.instance.versesCache;
    if (verses == null || verses.isEmpty) return null;

    String norm(String s) => s
        .trim()
        .toLowerCase()
        .replaceAll('ê', 'e')
        .replaceAll('é', 'e')
        .replaceAll('á', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ô', 'o')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'\s+'), ' ');

    final compact = norm(ref);
    for (final e in verses.entries) {
      final ek = norm(e.key);
      if (compact.contains(ek) || ek.contains(compact)) return e.value;
    }

    final m = RegExp(r'genesis\s+(\d+:\d+)').firstMatch(compact);
    if (m != null) {
      final cite = 'genesis ${m.group(1)}';
      for (final e in verses.entries) {
        final ek = norm(e.key);
        if (ek.startsWith(cite) || cite.startsWith(ek)) return e.value;
      }
    }
    return null;
  }
}
