import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Telemetria de produto + estabilidade.
/// Eventos do funil: abertura → login → home → missão → conclusão (base D1/D7).
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    try {
      _analytics = FirebaseAnalytics.instance;
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode,
      );
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        if (!kDebugMode) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        }
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        if (!kDebugMode) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        }
        return true;
      };
      _ready = true;
    } catch (e) {
      debugPrint('AnalyticsService init failed: $e');
    }
  }

  Future<void> setUserId(String? uid) async {
    if (!_ready) return;
    try {
      await _analytics?.setUserId(id: uid);
      await FirebaseCrashlytics.instance.setUserIdentifier(uid ?? '');
    } catch (_) {}
  }

  Future<void> logAppOpen() => _log('app_open');

  /// Pulso de retenção (D1/D7) — chamar em aberturas autenticadas.
  Future<void> logRetentionPulse({
    required int daysSinceFirstOpen,
    required int? daysSinceFirstLesson,
    String? cohortTrail,
  }) =>
      _log('retention_pulse', {
        'days_since_first_open': daysSinceFirstOpen,
        'days_since_first_lesson': ?daysSinceFirstLesson,
        'cohort_trail': ?(cohortTrail?.isNotEmpty == true ? cohortTrail : null),
      });

  /// Primeira missão concluída da conta (base de TTV / coorte D7).
  Future<void> logFirstLessonComplete({
    required String missionSlug,
    required String trailSlug,
    required int ttvSeconds,
  }) =>
      _log('first_lesson_complete', {
        'mission_slug': missionSlug,
        'trail_slug': trailSlug,
        'ttv_seconds': ttvSeconds,
      });

  Future<void> logLogin({required String method}) => _log(
        'login',
        {'method': method},
      );

  Future<void> logLoginFailed({String? reason}) => _log(
        'login_failed',
        {
          if (reason != null && reason.isNotEmpty)
            'reason': reason.length > 80 ? reason.substring(0, 80) : reason,
        },
      );

  Future<void> logHomeView() => _log('home_view');

  Future<void> logLessonStart({
    required String missionSlug,
    String? trailSlug,
    String? difficulty,
  }) =>
      _log('lesson_start', {
        'mission_slug': missionSlug,
        'trail_slug': ?trailSlug,
        'difficulty': ?difficulty,
      });

  Future<void> logLessonComplete({
    required String missionSlug,
    required String trailSlug,
    required int correct,
    required int total,
    required int steps,
    bool isBoss = false,
    bool isReplay = false,
    bool perfect = false,
  }) =>
      _log('lesson_complete', {
        'mission_slug': missionSlug,
        'trail_slug': trailSlug,
        'correct': correct,
        'total': total,
        'steps': steps,
        'is_boss': isBoss,
        'is_replay': isReplay,
        'perfect': perfect,
      });

  Future<void> logDifficultyPick({
    required String trailSlug,
    required String difficulty,
  }) =>
      _log('difficulty_pick', {
        'trail_slug': trailSlug,
        'difficulty': difficulty,
      });

  Future<void> logQuestionAnswered({
    required String missionSlug,
    required int questionIndex,
    required bool correct,
    required bool hintUsed,
    String? trailSlug,
    String? questionId,
    String? difficulty,
    bool isBoss = false,
  }) =>
      _log('question_answered', {
        'mission_slug': missionSlug,
        'question_index': questionIndex,
        'correct': correct,
        'hint_used': hintUsed,
        'is_boss': isBoss,
        'trail_slug': ?trailSlug,
        'question_id': ?questionId,
        'difficulty': ?difficulty,
      });

  Future<void> logExerciseStart({
    required String missionSlug,
    required String type,
    required String skill,
    required int index,
  }) =>
      _log('exercise_start', {
        'mission_slug': missionSlug,
        'type': type,
        'skill': skill,
        'index': index,
      });

  Future<void> logExerciseComplete({
    required String missionSlug,
    required String type,
    required String skill,
    required int index,
    required bool correct,
  }) =>
      _log('exercise_complete', {
        'mission_slug': missionSlug,
        'type': type,
        'skill': skill,
        'index': index,
        'correct': correct,
      });

  Future<void> _log(String name, [Map<String, Object>? params]) async {
    if (!_ready) return;
    try {
      await _analytics?.logEvent(name: name, parameters: params);
    } catch (e) {
      debugPrint('Analytics log $name failed: $e');
    }
  }
}
