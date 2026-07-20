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
    final unusedSection = pool
        .where((q) => q.section == resolvedSection && !usedIds.contains(q.id))
        .toList()
      ..shuffle(_rng);
    final unusedOther = pool
        .where((q) => q.section != resolvedSection && !usedIds.contains(q.id))
        .toList()
      ..shuffle(_rng);
    final usedFallback =
        pool.where((q) => usedIds.contains(q.id)).toList()..shuffle(_rng);

    final ids = <String>[];
    void take(List<BankQuestion> from) {
      for (final q in from) {
        if (ids.length >= target) break;
        if (ids.contains(q.id)) continue;
        ids.add(q.id);
      }
    }

    take(unusedSection);
    take(unusedOther);
    take(usedFallback);
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
