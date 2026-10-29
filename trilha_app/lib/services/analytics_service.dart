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
        // Devolver true marca o erro como tratado: no debug, sem este print,
        // falhas async somem sem rastro.
        if (kDebugMode) {
          debugPrint('Uncaught async error: $error\n$stack');
        } else {
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
  }) => _log('retention_pulse', {
    'days_since_first_open': daysSinceFirstOpen,
    'days_since_first_lesson': ?daysSinceFirstLesson,
    'cohort_trail': ?(cohortTrail?.isNotEmpty == true ? cohortTrail : null),
  });

  /// Primeira missão concluída da conta (base de TTV / coorte D7).
  Future<void> logFirstLessonComplete({
    required String missionSlug,
    required String trailSlug,
    required int ttvSeconds,
  }) => _log('first_lesson_complete', {
    'mission_slug': missionSlug,
    'trail_slug': trailSlug,
    'ttv_seconds': ttvSeconds,
  });

  Future<void> logLogin({required String method}) =>
      _log('login', {'method': method});

  Future<void> logLoginFailed({String? reason}) => _log('login_failed', {
    if (reason != null && reason.isNotEmpty)
      'reason': reason.length > 80 ? reason.substring(0, 80) : reason,
  });

  Future<void> logHomeView() => _log('home_view');

  Future<void> logLessonStart({
    required String missionSlug,
    String? trailSlug,
    String? difficulty,
  }) => _log('lesson_start', {
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
  }) => _log('lesson_complete', {
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
  }) => _log('difficulty_pick', {
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
  }) => _log('question_answered', {
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
  }) => _log('exercise_start', {
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
    int attempt = 1,
    bool requeued = false,
    bool revealed = false,
    int elapsedMs = 0,
    String? difficulty,
  }) => _log('exercise_complete', {
    'mission_slug': missionSlug,
    'type': type,
    'skill': skill,
    'index': index,
    'correct': correct,
    'attempt': attempt,
    'requeued': requeued,
    'revealed': revealed,
    'elapsed_ms': elapsedMs,
    'difficulty': ?difficulty,
  });

  /// Paywall do Peregrino+ aberto. [state]: paid · promo · offer · unavailable.
  Future<void> logPaywallView({
    required String source,
    required String state,
  }) => _log('paywall_view', {'source': source, 'state': state});

  /// Etapa da compra do Peregrino+: start · success · cancel · fail.
  Future<void> logPurchase({
    required String stage,
    required String productId,
  }) => _log('plus_purchase', {'stage': stage, 'product_id': productId});

  /// Paywall fechado sem comprar (o funil precisa do denominador).
  Future<void> logPaywallDismiss({
    required String source,
    required String state,
  }) => _log('paywall_dismiss', {'source': source, 'state': state});

  /// Plano tocado na lista do paywall (antes de assinar).
  Future<void> logPaywallPlanSelect({
    required String source,
    required String productId,
  }) =>
      _log('paywall_plan_select', {'source': source, 'product_id': productId});

  /// Resultado do Restaurar compra: plus · none · error.
  Future<void> logRestore(String result) =>
      _log('paywall_restore', {'result': result});

  /// Folha/aviso de oferta do Peregrino+: view · cta · dismiss.
  /// Sem isto, a etapa folha → paywall do funil era invisível.
  Future<void> logOfferSheet({required String kind, required String action}) =>
      _log('plus_offer_sheet', {'kind': kind, 'action': action});

  /// Recurso do Peregrino+ aberto (ou bloqueado, com [hasPlus] falso).
  /// Firebase só aceita string ou número no parâmetro.
  Future<void> logPlusFeatureOpen({
    required String feature,
    required bool hasPlus,
  }) => _log('plus_feature_open', {
    'feature': feature,
    'has_plus': hasPlus ? 1 : 0,
  });

  /// Passe de trilha: `send` (quem assina compartilhou) ou `redeem` (quem
  /// recebeu abriu o link), com o resultado.
  Future<void> logTrailGift({
    required String action,
    required String trail,
    required String result,
  }) =>
      _log('trail_gift', {'action': action, 'trail': trail, 'result': result});

  Future<void> logEvent(String name, [Map<String, Object>? params]) =>
      _log(name, params);

  Future<void> _log(String name, [Map<String, Object>? params]) async {
    if (!_ready) return;
    try {
      await _analytics?.logEvent(
        name: name,
        parameters: params == null ? null : _firebaseParams(params),
      );
    } catch (e) {
      debugPrint('Analytics log $name failed: $e');
    }
  }

  /// O SDK rejeita `bool`. Número 1/0 preserva o sim/não.
  Map<String, Object> _firebaseParams(Map<String, Object> params) {
    return {
      for (final entry in params.entries)
        entry.key: entry.value is bool
            ? ((entry.value as bool) ? 1 : 0)
            : entry.value,
    };
  }
}
