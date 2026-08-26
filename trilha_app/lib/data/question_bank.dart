import '../models/difficulty.dart';
import '../services/content_catalog_service.dart';

class QuestionBank {
  static QuestionBank? _instance;
  static QuestionBank get instance => _instance ??= QuestionBank._();

  QuestionBank._();

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
    // IDs no formato genesis--sem-gen-01-criador-01 (seed atual)
    // ou genesis-1-11-sem-… / exodo-sem-exo-01-opressao-01
    return q.id.contains('-$section-') || q.id.endsWith('-$section');
  }

  /// Todas as perguntas do passo × dificuldade (para o composer montar a mixagem).
  Future<List<BankQuestion>> listForMission({
    required TrailDifficulty difficulty,
    required String? moduleTitle,
    String? trailSlug,
    String? section,
  }) async {
    final questions = await _questions();
    final trail = trailSlug ?? 'genesis-1-11';
    final resolvedSection =
        (section != null && section.isNotEmpty)
            ? section
            : moduleTitleToSection(moduleTitle, trailSlug: trail);
    return questions
        .where(
          (q) =>
              q.difficulty == difficulty &&
              q.trailSlug == trail &&
              matchesMissionSection(q, resolvedSection),
        )
        .toList();
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

  List<BankQuestion> get bankQuestionsCacheOrEmpty =>
      ContentCatalogService.instance.bankQuestionsCache ?? const [];
}
