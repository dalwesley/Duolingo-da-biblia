import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/question_report.dart';
import 'backend_service.dart';

/// Envia relatos de erro em perguntas/respostas para revisão no admin.
/// Coleção: `content_question_reports` — pensada para virar seed de discussões.
class QuestionReportService {
  QuestionReportService._();
  static final QuestionReportService instance = QuestionReportService._();

  static const collection = 'content_question_reports';

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<bool> submit({
    required BackendService backend,
    required QuestionReportDraft draft,
  }) async {
    if (!backend.isFirebaseReady) {
      debugPrint('QuestionReportService: Firebase indisponível');
      return false;
    }
    final uid = backend.uid;
    if (uid == null || uid.isEmpty) {
      debugPrint('QuestionReportService: usuário não autenticado');
      return false;
    }

    final comment = draft.comment.trim();
    try {
      await _db.collection(collection).add({
        'questionId': draft.questionId,
        'questionText': _clip(draft.questionText, 500),
        if (draft.verseRef != null && draft.verseRef!.isNotEmpty)
          'verseRef': draft.verseRef,
        'selectedOptionId': draft.selectedOptionId,
        if (draft.selectedOptionText != null)
          'selectedOptionText': _clip(draft.selectedOptionText!, 300),
        'correctOptionId': draft.correctOptionId,
        if (draft.correctOptionText != null)
          'correctOptionText': _clip(draft.correctOptionText!, 300),
        'userWasCorrect': draft.userWasCorrect,
        'missionSlug': draft.missionSlug,
        if (draft.trailSlug != null) 'trailSlug': draft.trailSlug,
        if (draft.difficulty != null) 'difficulty': draft.difficulty,
        'practiceMode': draft.practiceMode,
        'category': draft.category.id,
        'comment': _clip(comment, 800),
        'uid': uid,
        if (backend.userEmail != null) 'email': backend.userEmail,
        if (backend.userDisplayName != null)
          'displayName': backend.userDisplayName,
        'status': 'open',
        // Reserva para discussões futuras na trilha.
        'discussionEligible': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('QuestionReportService submit failed: $e');
      return false;
    }
  }

  static String _clip(String value, int max) {
    final t = value.trim();
    if (t.length <= max) return t;
    return t.substring(0, max);
  }
}
