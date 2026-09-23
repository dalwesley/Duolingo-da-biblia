import '../models/difficulty.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import 'catalog_access.dart';
import 'difficulty_trails.dart';

class TrailProgress {
  static List<String> missionSlugs(Trail trail) => trail.missionSlugs;

  /// Progresso vivo do modo atual — sem “completar” via modos já limpos.
  static ({int done, int total, int pct}) getLiveProgress(
    Trail trail,
    List<String> completed,
  ) {
    final slugs = missionSlugs(trail);
    final done = slugs.where(completed.contains).length;
    final total = slugs.length;
    final pct = total > 0 ? ((done / total) * 100).round() : 0;
    return (done: done, total: total, pct: pct);
  }

  static ({int done, int total, int pct}) getProgress(
    Trail trail,
    List<String> completed, {
    Map<String, List<String>> clearedTrailModes = const {},
  }) {
    final live = getLiveProgress(trail, completed);
    var done = live.done;
    final total = live.total;
    // Modo já concluído (ex.: Semente→Rota): overview não zera a cena.
    if (done < total &&
        (clearedTrailModes[trail.slug] ?? const []).isNotEmpty) {
      done = total;
    }
    final pct = total > 0 ? ((done / total) * 100).round() : 0;
    return (done: done, total: total, pct: pct);
  }

  /// Completa se todos os passos estão em [completed], ou se a trilha já
  /// foi concluída em algum modo ([clearedTrailModes]) — mesmo após trocar
  /// de dificuldade e zerar o progresso do novo modo.
  static bool isTrailCompleted(
    Trail trail,
    List<String> completed, {
    Map<String, List<String>> clearedTrailModes = const {},
  }) {
    final slugs = missionSlugs(trail);
    if (slugs.isEmpty) return false;
    if (slugs.every(completed.contains)) return true;
    return (clearedTrailModes[trail.slug] ?? const []).isNotEmpty;
  }

  /// Modos limpos na ordem canônica (Observação → Compreensão → Interpretação).
  static List<TrailDifficulty> orderedClearedDifficulties(
    List<String> clearedModes,
  ) {
    return [
      for (final d in TrailDifficulty.values)
        if (clearedModes.contains(d.id)) d,
    ];
  }

  /// Rótulo curto p/ mapa: "Observação concluída".
  static String? clearedModeStatusLabel(List<String> clearedModes) {
    if (clearedModes.isEmpty) return null;
    final labels = [
      for (final d in orderedClearedDifficulties(clearedModes)) d.labelPt,
    ];
    if (labels.isEmpty) return null;
    if (labels.length == 1) return '${labels.first} concluída';
    return '${labels.join(' · ')} concluídas';
  }

  /// Progresso do modo ativo: "Observação concluída" quando já selado.
  static String activeModeProgressLabel({
    required List<String> clearedModes,
    required String? activeDifficultyId,
    required int liveDone,
    required int total,
  }) {
    final label = modeLabel(activeDifficultyId);
    final active = activeDifficultyId ?? TrailDifficulty.semente.id;
    if (total > 0 &&
        clearedModes.contains(active) &&
        liveDone >= total) {
      return '$label concluída';
    }
    return '$label · $liveDone de $total passos';
  }

  /// True quando há modo limpo e o modo ativo ainda não foi concluído
  /// (progresso vivo pode estar zerado — não é bug).
  static bool isReplayingUnclearedMode({
    required List<String> clearedModes,
    required String? activeDifficultyId,
    required int liveDone,
    required int total,
  }) {
    if (clearedModes.isEmpty || total <= 0) return false;
    final active = activeDifficultyId ?? TrailDifficulty.semente.id;
    if (clearedModes.contains(active)) return false;
    return liveDone < total;
  }

  /// Texto explicativo: "Observação concluída · progresso abaixo é do modo Compreensão".
  static String? modeReplayHint({
    required List<String> clearedModes,
    required String? activeDifficultyId,
  }) {
    if (clearedModes.isEmpty) return null;
    final active = activeDifficultyId ?? TrailDifficulty.semente.id;
    if (clearedModes.contains(active)) return null;
    final ordered = orderedClearedDifficulties(clearedModes);
    final clearedLabel = ordered.isNotEmpty
        ? ordered.last.labelPt
        : (TrailDifficulty.fromId(clearedModes.last)?.labelPt ??
            clearedModes.last);
    final activeLabel = TrailDifficulty.fromId(active)?.labelPt ?? active;
    return '$clearedLabel concluída · progresso abaixo é do modo $activeLabel';
  }

  /// Quando o modo ativo já está selado — convite ao próximo, sem zerar a cena.
  static String? modeSealedHint({
    required List<String> clearedModes,
    required String? activeDifficultyId,
  }) {
    if (clearedModes.isEmpty) return null;
    final active = activeDifficultyId ?? TrailDifficulty.semente.id;
    if (!clearedModes.contains(active)) return null;
    final current = TrailDifficulty.fromId(active);
    final next = current?.next;
    final label = current?.labelPt ?? active;
    if (next == null) {
      return '$label concluída · os três modos desta trilha estão selados';
    }
    return '$label concluída · o próximo modo é ${next.labelPt}';
  }

  static String modeLabel(String? difficultyId) {
    final id = difficultyId ?? TrailDifficulty.semente.id;
    return TrailDifficulty.fromId(id)?.labelPt ?? id;
  }

  /// Modo efetivo da trilha: o gravado, ou Observação se a trilha usa os 3 modos.
  static String? resolvedDifficultyId(String trailSlug, String? stored) {
    if (stored != null && stored.isNotEmpty) return stored;
    if (trailUsesDifficultyBank(trailSlug)) return TrailDifficulty.semente.id;
    return null;
  }

  /// Modo que o cartão deve mostrar: se o gravado já foi selado, o próximo.
  /// Gênesis 1-11 com Observação concluída aponta para Compreensão.
  static String? openDifficultyId({
    required String? activeDifficultyId,
    required List<String> clearedModes,
  }) {
    final start = TrailDifficulty.fromId(
          activeDifficultyId ?? TrailDifficulty.semente.id,
        ) ??
        TrailDifficulty.semente;
    if (!clearedModes.contains(start.id)) return start.id;
    var next = start.next;
    while (next != null && clearedModes.contains(next.id)) {
      next = next.next;
    }
    return next?.id ?? start.id;
  }

  /// Chip curto: "Modo Observação" / "Observação concluída".
  static String modeChipLabel({
    required String? difficultyId,
    required List<String> clearedModes,
  }) {
    final label = modeLabel(difficultyId);
    final active = difficultyId ?? TrailDifficulty.semente.id;
    if (clearedModes.contains(active)) return '$label concluída';
    return 'Modo $label';
  }

  /// Trilha liberada se não há pré-requisito, se a pré-requisito está
  /// completa em [completed], ou se já foi concluída em algum modo
  /// ([clearedTrailModes]) — evita re-bloquear ao trocar dificuldade.
  static bool isTrailUnlocked(
    Trail trail,
    List<Trail> allTrails,
    List<String> completed, {
    Map<String, List<String>> clearedTrailModes = const {},
  }) {
    if (CatalogAccess.openAllForTesting) return true;
    // Vitrine D7 + NT: abertos sem exigir o caminho do AT.
    if (trail.slug == 'sermao-do-monte') return true;
    if (trail.slug == 'ansiedade' || trail.slug == 'recomeco') return true;
    if (trail.realmId == TrailRealm.novoTestamento.id) return true;
    if (trail.unlockAfter == null) return true;
    final prereq =
        allTrails.where((t) => t.slug == trail.unlockAfter).firstOrNull;
    if (prereq == null) return true;
    if (isTrailCompleted(
      prereq,
      completed,
      clearedTrailModes: clearedTrailModes,
    )) {
      return true;
    }
    return false;
  }

  static Mission? getCurrentMission(Trail trail, List<String> completed) {
    final allSlugs = missionSlugs(trail);
    for (final mod in trail.modules) {
      for (final mission in mod.missions) {
        if (completed.contains(mission.slug)) continue;
        final index = allSlugs.indexOf(mission.slug);
        if (index <= 0 || completed.contains(allSlugs[index - 1])) {
          return mission;
        }
      }
    }
    return null;
  }

  static Trail? findActiveTrail(
    List<Trail> trails,
    List<String> completed, {
    Map<String, List<String>> clearedTrailModes = const {},
  }) {
    for (final trail in trails) {
      if (trail.comingSoon || trail.missionSlugs.isEmpty) continue;
      if (!isTrailUnlocked(
        trail,
        trails,
        completed,
        clearedTrailModes: clearedTrailModes,
      )) {
        continue;
      }
      if (!isTrailCompleted(
        trail,
        completed,
        clearedTrailModes: clearedTrailModes,
      )) {
        return trail;
      }
    }
    return trails.where((t) => t.missionSlugs.isNotEmpty).firstOrNull;
  }

  static bool isMissionUnlocked(
    String missionSlug,
    List<String> allSlugs,
    List<String> completed,
  ) {
    if (CatalogAccess.openAllForTesting) return true;
    final index = allSlugs.indexOf(missionSlug);
    if (index <= 0) return true;
    return completed.contains(allSlugs[index - 1]);
  }
}
