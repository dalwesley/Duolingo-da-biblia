import '../models/difficulty.dart';
import '../models/trail.dart';
import 'trail_progress.dart';
import 'walk_stats.dart';

/// Seu próximo passo: uma sugestão por vez, além da cena que o herói já
/// oferece. A Home sempre segue para a próxima trilha; isto mostra o que
/// ela não mostra.
sealed class NextStep {
  const NextStep();

  /// Chave do "Agora não" (some por [NextStepPicker.snoozeDays]).
  String get key;
}

/// Aprofundar: a trilha recém-concluída, de novo, no modo seguinte.
class DeepenStep extends NextStep {
  final Trail trail;
  final TrailDifficulty mode;

  /// Acerto de primeira na trilha (0–100).
  final int percent;

  const DeepenStep({
    required this.trail,
    required this.mode,
    required this.percent,
  });

  @override
  String get key => 'deepen:${trail.slug}:${mode.id}';
}

/// Reforçar: o gesto que mais escapa, com perguntas das cenas já feitas.
class ReinforceStep extends NextStep {
  final ExerciseType gesture;
  final TrailDifficulty? mode;
  final Accuracy accuracy;

  const ReinforceStep({
    required this.gesture,
    required this.mode,
    required this.accuracy,
  });

  @override
  String get key => 'reinforce:${gesture.wireId}';
}

class NextStepPicker {
  NextStepPicker._();

  /// Antes disso não há caminhada para sugerir nada.
  static const minScenes = 3;

  /// Aprofundar só quando a trilha foi firme.
  static const deepenPercent = 80;
  static const deepenMinAnswers = 8;

  /// Reforçar o gesto abaixo disso, com respostas suficientes para não
  /// ser acaso.
  static const weakPercent = 60;
  static const weakMinAnswers = 10;

  static const snoozeDays = 7;

  /// A sugestão do momento, ou null. Aprofundar vem antes: é o fim de uma
  /// trilha, a hora de escolher. [snoozedUntil] é chave → dia (yyyy-mm-dd)
  /// até o qual a sugestão fica escondida; [today] no mesmo formato.
  static NextStep? pick({
    required List<Trail> trails,
    required List<String> completed,
    required Map<String, List<String>> clearedTrailModes,
    required Map<String, String> trailModes,
    Map<String, String> pinnedModes = const {},
    required Map<String, int> trailAnswerCorrect,
    required Map<String, int> trailAnswerTotal,
    required Map<String, int> answerCorrect,
    required Map<String, int> answerTotal,
    String? lastMissionSlug,
    Iterable<String> borrowed = const [],
    Map<String, String> snoozedUntil = const {},
    required String today,
  }) {
    if (completed.length < minScenes) return null;
    bool snoozed(NextStep s) =>
        (snoozedUntil[s.key] ?? '').compareTo(today) > 0;

    final deepen = _deepen(
      trails: trails,
      completed: completed,
      clearedTrailModes: clearedTrailModes,
      trailModes: trailModes,
      pinnedModes: pinnedModes,
      trailAnswerCorrect: trailAnswerCorrect,
      trailAnswerTotal: trailAnswerTotal,
      lastMissionSlug: lastMissionSlug,
      borrowed: borrowed,
    );
    if (deepen != null && !snoozed(deepen)) return deepen;

    final reinforce = _reinforce(answerCorrect, answerTotal);
    if (reinforce != null && !snoozed(reinforce)) return reinforce;
    return null;
  }

  static DeepenStep? _deepen({
    required List<Trail> trails,
    required List<String> completed,
    required Map<String, List<String>> clearedTrailModes,
    required Map<String, String> trailModes,
    Map<String, String> pinnedModes = const {},
    required Map<String, int> trailAnswerCorrect,
    required Map<String, int> trailAnswerTotal,
    required String? lastMissionSlug,
    required Iterable<String> borrowed,
  }) {
    if (lastMissionSlug == null) return null;
    final trail = trails
        .where((t) => t.missionSlugs.contains(lastMissionSlug))
        .firstOrNull;
    if (trail == null) return null;
    final step = deepenOf(
      trail,
      completed: completed,
      clearedTrailModes: clearedTrailModes,
      trailModes: trailModes,
      pinnedModes: pinnedModes,
      trailAnswerCorrect: trailAnswerCorrect,
      trailAnswerTotal: trailAnswerTotal,
      borrowed: borrowed,
    );
    if (step == null) return null;
    final total = trailAnswerTotal[trail.slug] ?? 0;
    if (total < deepenMinAnswers || step.percent < deepenPercent) return null;
    return step;
  }

  /// O modo seguinte de [trail], se ela tem modo selado e a pessoa ainda
  /// não começou o próximo. Sem olhar o acerto: o herói vazio também usa.
  static DeepenStep? deepenOf(
    Trail trail, {
    required List<String> completed,
    required Map<String, List<String>> clearedTrailModes,
    required Map<String, String> trailModes,
    Map<String, String> pinnedModes = const {},
    required Map<String, int> trailAnswerCorrect,
    required Map<String, int> trailAnswerTotal,
    Iterable<String> borrowed = const [],
  }) {
    if (trail.comingSoon || trail.missionSlugs.isEmpty) return null;
    final next = TrailProgress.nextModeToDeepen(
      clearedTrailModes[trail.slug] ?? const [],
    );
    if (next == null) return null;
    if (TrailProgress.isDeepening(
      trail,
      completed,
      clearedTrailModes: clearedTrailModes,
      trailModes: trailModes,
      pinnedModes: pinnedModes,
      borrowed: borrowed,
    )) {
      return null;
    }
    return DeepenStep(
      trail: trail,
      mode: next,
      percent: Accuracy(
        trailAnswerCorrect[trail.slug] ?? 0,
        trailAnswerTotal[trail.slug] ?? 0,
      ).percent,
    );
  }

  static ReinforceStep? _reinforce(
    Map<String, int> answerCorrect,
    Map<String, int> answerTotal,
  ) {
    final stats = WalkStats.from(
      answerCorrect: answerCorrect,
      answerTotal: answerTotal,
    );
    (ExerciseType, Accuracy)? low;
    for (final g in stats.byGesture) {
      if (g.$2.total < weakMinAnswers || g.$2.percent >= weakPercent) continue;
      if (low == null || g.$2.percent < low.$2.percent) low = g;
    }
    if (low == null) return null;
    return ReinforceStep(
      gesture: low.$1,
      mode: stats.weakestMode,
      accuracy: low.$2,
    );
  }
}
