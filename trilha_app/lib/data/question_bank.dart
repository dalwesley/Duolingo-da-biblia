import 'dart:math';

import '../models/difficulty.dart';
import '../services/content_catalog_service.dart';

class QuestionBank {
  static QuestionBank? _instance;
  static QuestionBank get instance => _instance ??= QuestionBank._();

  QuestionBank._();

  final _rng = Random();

  Future<void> ensureLoaded() => ContentCatalogService.instance.ensureLoaded();

  Future<List<DifficultyMeta>> getDifficulties() {
    return ContentCatalogService.instance.getDifficulties();
  }

  Future<DifficultyMeta?> metaFor(TrailDifficulty d) async {
    final difficulties = await getDifficulties();
    try {
      return difficulties.firstWhere((m) => m.difficulty == d);
    } catch (_) {
      return null;
    }
  }

  Future<List<BankQuestion>> _questions() {
    return ContentCatalogService.instance.getBankQuestions();
  }

  bool hasBankForTrail(String? trailSlug) {
    if (trailSlug == null) return false;
    final cached = ContentCatalogService.instance.bankQuestionsCache;
    if (cached == null || cached.isEmpty) return false;
    return cached.any((q) => q.trailSlug == trailSlug);
  }

  /// Perguntas do banco pertencentes ao passo [section] (slug da missão).
  /// Aceita match exato em `section` ou id que contenha o slug (legado/Firestore).
  static bool matchesMissionSection(BankQuestion q, String section) {
    if (section.isEmpty) return false;
    if (q.section == section) return true;
    // IDs no formato genesis--sem-gen-01-criador-01 / exodo-sem-exo-01-opressao-01
    return q.id.contains('-$section-') || q.id.endsWith('-$section');
  }

  Future<List<String>> pickIdsForMission({
    required TrailDifficulty difficulty,
    required String? moduleTitle,
    required int count,
    required List<String> usedIds,
    String? trailSlug,
    String? section,
    @Deprecated('Contagem fixa via count; mantido por compatibilidade')
    bool isBoss = false,
  }) async {
    final questions = await _questions();
    final trail = trailSlug ?? 'genesis-1-11';
    final resolvedSection =
        (section != null && section.isNotEmpty)
            ? section
            : moduleTitleToSection(moduleTitle, trailSlug: trail);
    final target = count;
    final pool = questions
        .where((q) => q.difficulty == difficulty && q.trailSlug == trail)
        .toList();

    // Só o passo atual — nunca misturar capítulos/missões da mesma trilha.
    final sectionPool =
        pool.where((q) => matchesMissionSection(q, resolvedSection)).toList();

    final unused = sectionPool
        .where((q) => !usedIds.contains(q.id))
        .toList()
      ..shuffle(_rng);
    final usedInSection = sectionPool
        .where((q) => usedIds.contains(q.id))
        .toList()
      ..shuffle(_rng);

    final ids = <String>[];
    void take(List<BankQuestion> from) {
      for (final q in from) {
        if (ids.length >= target) break;
        if (ids.contains(q.id)) continue;
        ids.add(q.id);
      }
    }

    take(unused);
    // Replay / pool esgotado: reutiliza só perguntas deste passo.
    take(usedInSection);
    return ids;
  }

  BankQuestion? byId(String id) {
    final questions = ContentCatalogService.instance.bankQuestionsCache;
    if (questions == null) return null;
    try {
      return questions.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }
}
