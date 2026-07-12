import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/difficulty.dart';
import '../models/trail.dart';

class QuestionBank {
  static QuestionBank? _instance;
  static QuestionBank get instance => _instance ??= QuestionBank._();

  QuestionBank._();

  List<DifficultyMeta>? _difficulties;
  List<BankQuestion>? _questions;
  final _rng = Random();

  Future<void> ensureLoaded() async {
    if (_questions != null) return;
    final raw = await rootBundle.loadString('assets/data/genesis_questions.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    _difficulties = (data['difficulties'] as List)
        .map((e) => DifficultyMeta.fromJson(e as Map<String, dynamic>))
        .toList();
    _questions = (data['questions'] as List)
        .map((e) => BankQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DifficultyMeta>> getDifficulties() async {
    await ensureLoaded();
    return _difficulties!;
  }

  Future<DifficultyMeta?> metaFor(TrailDifficulty d) async {
    await ensureLoaded();
    try {
      return _difficulties!.firstWhere((m) => m.difficulty == d);
    } catch (_) {
      return null;
    }
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
    await ensureLoaded();
    final section = moduleTitleToSection(moduleTitle);
    final target = isBoss ? count + 1 : count;

    final pool = _questions!.where((q) => q.difficulty == difficulty).toList();
    final unusedSection = pool.where((q) => q.section == section && !usedIds.contains(q.id)).toList()..shuffle(_rng);
    final unusedOther = pool.where((q) => q.section != section && !usedIds.contains(q.id)).toList()..shuffle(_rng);
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

    // Garantir variedade: nunca repetir a mesma pergunta no mesmo set
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
    await ensureLoaded();
    final section = moduleTitleToSection(moduleTitle);
    final target = isBoss ? count + 1 : count;
    final pool = _questions!.where((q) => q.difficulty == difficulty).toList();
    final unusedSection = pool.where((q) => q.section == section && !usedIds.contains(q.id)).toList()..shuffle(_rng);
    final unusedOther = pool.where((q) => q.section != section && !usedIds.contains(q.id)).toList()..shuffle(_rng);
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
    try {
      return _questions?.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }
}
