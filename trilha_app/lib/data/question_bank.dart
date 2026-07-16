import 'dart:math';

import '../models/difficulty.dart';
import '../models/trail.dart';
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

  /// Seleciona perguntas únicas para uma missão: prioriza a seção do módulo,
  /// evita IDs já usados e completa com outras seções da mesma dificuldade.
  Future<List<Question>> pickForMission({
    required TrailDifficulty difficulty,
    required String? moduleTitle,
    required int count,
    required List<String> usedIds,
    bool isBoss = false,
  }) async {
    final questions = await _questions();
    final section = moduleTitleToSection(moduleTitle);
    final target = isBoss ? count + 1 : count;

    final pool = questions.where((q) => q.difficulty == difficulty).toList();
    final unusedSection = pool.where((q) => q.section == section && !usedIds.contains(q.id)).toList()
      ..shuffle(_rng);
    final unusedOther = pool.where((q) => q.section != section && !usedIds.contains(q.id)).toList()
      ..shuffle(_rng);
    final usedFallback = pool.where((q) => usedIds.contains(q.id)).toList()..shuffle(_rng);

    final picked = <BankQuestion>[];
    void take(List<BankQuestion> from, int need) {
      for (final q in from) {
        if (picked.length >= need) break;
        if (picked.any((p) => p.id == q.id)) continue;
        picked.add(q);
      }
    }

    take(unusedSection, target);
    take(unusedOther, target);
    take(usedFallback, target);

    final unique = <String, BankQuestion>{};
    for (final q in picked) {
      unique[q.id] = q;
    }
    return unique.values.take(target).map((q) => q.toQuestion(shuffleOptions: true, rng: _rng)).toList();
  }

  Future<List<String>> pickIdsForMission({
    required TrailDifficulty difficulty,
    required String? moduleTitle,
    required int count,
    required List<String> usedIds,
    bool isBoss = false,
  }) async {
    final questions = await _questions();
    final section = moduleTitleToSection(moduleTitle);
    final target = isBoss ? count + 1 : count;
    final pool = questions.where((q) => q.difficulty == difficulty).toList();
    final unusedSection = pool.where((q) => q.section == section && !usedIds.contains(q.id)).toList()
      ..shuffle(_rng);
    final unusedOther = pool.where((q) => q.section != section && !usedIds.contains(q.id)).toList()
      ..shuffle(_rng);
    final usedFallback = pool.where((q) => usedIds.contains(q.id)).toList()..shuffle(_rng);

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
