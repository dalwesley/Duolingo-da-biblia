import '../data/entry_trails.dart';
import '../l10n/l10n_global.dart';
import '../models/difficulty.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import 'catalog_access.dart';
import 'difficulty_trails.dart';
import 'plus_access.dart';

class TrailProgress {
  /// Trilha do motivo do onboarding ([UserIntent]); o [ProgressService]
  /// atualiza a cada troca de settings. Vem antes da ordem do catálogo.
  static String? preferredTrailSlug;

  /// Última cena nova concluída; o [ProgressService] atualiza. A trilha dela
  /// vem antes de tudo: o CTA fica onde a pessoa está andando.
  static String? lastPlayedMissionSlug;

  static List<String> missionSlugs(Trail trail) => trail.missionSlugs;

  /// Progresso vivo do modo atual — sem “completar” via modos já limpos.
  static ({int done, int total, int pct}) getLiveProgress(
    Trail trail,
    List<String> completed,
  ) {
    final slugs = missionSlugs(trail);
    final done = slugs.where(_doneSet(completed).contains).length;
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
    if (slugs.every(_doneSet(completed).contains)) return true;
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
    if (labels.length == 1) return L10n.current.trailsModeCleared(labels.first);
    return L10n.current.trailsModesCleared(labels.join(' · '));
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
    if (total > 0 && clearedModes.contains(active) && liveDone >= total) {
      return L10n.current.trailsModeCleared(label);
    }
    return L10n.current.trailsLabeledScenesOf(label, liveDone, total);
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
    return L10n.current.trailsModeReplayHint(clearedLabel, activeLabel);
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
      return L10n.current.trailsModeAllSealed(label);
    }
    return L10n.current.trailsModeNextHint(label, next.labelPt);
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
    final start =
        TrailDifficulty.fromId(
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
    if (clearedModes.contains(active)) {
      return L10n.current.trailsModeCleared(label);
    }
    return L10n.current.trailsModeChip(label);
  }

  /// Uma trilha por vez no mesmo caminho.
  ///
  /// A anterior (mesma jornada, na ordem do mapa) precisa estar concluída.
  /// Quem já andou nesta trilha não perde o acesso. Pré-requisito de outro
  /// caminho continua valendo, exceto Novo Testamento e a vitrine de Vida
  /// Cristã — esses não esperam o Antigo Testamento.
  static bool isTrailUnlocked(
    Trail trail,
    List<Trail> allTrails,
    List<String> completed, {
    Map<String, List<String>> clearedTrailModes = const {},
  }) {
    if (CatalogAccess.openAllForTesting) return true;
    // Trilha do motivo do onboarding é porta: nunca espera outra trilha.
    if (EntryTrails.intentOnly.contains(trail.slug)) return true;
    // Passe de trilha: quem liberou deu a trilha inteira, sem fila.
    if (PlusAccess.giftedTrails.contains(trail.slug)) return true;
    if (_alreadyWalked(
      trail,
      completed,
      clearedTrailModes: clearedTrailModes,
    )) {
      return true;
    }
    return blockingTrail(
          trail,
          allTrails,
          completed,
          clearedTrailModes: clearedTrailModes,
        ) ==
        null;
  }

  /// A trilha que falta terminar para abrir [trail] (a anterior no mesmo
  /// caminho, senão o pré-requisito), ou null se nada trava. Não olha o
  /// progresso da própria trilha — isso fica em [isTrailUnlocked].
  static Trail? blockingTrail(
    Trail trail,
    List<Trail> allTrails,
    List<String> completed, {
    Map<String, List<String>> clearedTrailModes = const {},
  }) {
    final previous = _previousContentTrail(trail, allTrails);
    if (previous != null &&
        !isTrailCompleted(
          previous,
          completed,
          clearedTrailModes: clearedTrailModes,
        )) {
      return previous;
    }
    if (trail.unlockAfter == null) return null;
    final prereq = allTrails
        .where((t) => t.slug == trail.unlockAfter)
        .firstOrNull;
    if (prereq == null) return null;
    // Só a ordem do próprio caminho trava. Pré-requisito de outro card
    // (Salmos → Evangelhos, Oração → Salmos) não segura ninguém.
    if (prereq.journey != trail.journey) return null;
    return isTrailCompleted(
          prereq,
          completed,
          clearedTrailModes: clearedTrailModes,
        )
        ? null
        : prereq;
  }

  /// Progresso vivo ou modo já selado — a trilha não volta a sumir.
  static bool _alreadyWalked(
    Trail trail,
    List<String> completed, {
    Map<String, List<String>> clearedTrailModes = const {},
  }) {
    if (isTrailCompleted(
      trail,
      completed,
      clearedTrailModes: clearedTrailModes,
    )) {
      return true;
    }
    return getLiveProgress(trail, completed).done > 0;
  }

  /// Trilha anterior com cenas, na mesma ordem do mapa do caminho.
  static Trail? _previousContentTrail(Trail trail, List<Trail> allTrails) {
    final peers = allTrails.where((t) => t.journey == trail.journey).toList()
      ..sort(_journeyOrder);
    Trail? previous;
    for (final peer in peers) {
      if (peer.slug == trail.slug) return previous;
      if (peer.comingSoon || peer.missionSlugs.isEmpty) continue;
      if (EntryTrails.intentOnly.contains(peer.slug)) continue;
      previous = peer;
    }
    return null;
  }

  /// Para onde [trail] segue quando acaba: o destino da trilha de entrada
  /// ([EntryTrails.continuesTo]), depois a seguinte no mesmo caminho. Sem
  /// isto, quem fechava Gênesis 1–11 caía no começo do catálogo (Ansiedade).
  static List<Trail> successorsOf(Trail trail, List<Trail> allTrails) {
    final target = trail.missionSlugs.isEmpty
        ? null
        : EntryTrails.continuesTo[trail.missionSlugs.last];
    return [
      if (target != null) ...allTrails.where((t) => t.slug == target),
      for (final peer in allTrails)
        if (peer.journey == trail.journey &&
            _previousContentTrail(peer, allTrails)?.slug == trail.slug)
          peer,
    ];
  }

  static int _journeyOrder(Trail a, Trail b) {
    final category = TrailCategory.fromId(
      a.categoryId,
    ).order.compareTo(TrailCategory.fromId(b.categoryId).order);
    if (category != 0) return category;
    final order = a.order.compareTo(b.order);
    if (order != 0) return order;
    return a.slug.compareTo(b.slug);
  }

  /// A próxima cena desta trilha pede o Peregrino+? Falso quando a trilha
  /// é grátis, quando a próxima é a 1ª (amostra) ou quando não falta cena.
  static bool nextSceneNeedsPlus(Trail trail, List<String> completed) {
    if (!PlusAccess.trailIsPlus(trail)) return false;
    final next = getCurrentMission(trail, completed);
    if (next == null) return false;
    return PlusAccess.missionNeedsPlus(trail, next.slug);
  }

  static Mission? getCurrentMission(Trail trail, List<String> completed) {
    final allSlugs = missionSlugs(trail);
    for (final mod in trail.modules) {
      for (final mission in mod.missions) {
        if (_doneSet(completed).contains(mission.slug)) continue;
        final index = allSlugs.indexOf(mission.slug);
        if (index <= 0 || _doneSet(completed).contains(allSlugs[index - 1])) {
          return mission;
        }
      }
    }
    return null;
  }

  /// Trilha do CTA da Home e da faixa da aba Trilhas. Sem Peregrino+
  /// ([plusOpen] falso), pula a trilha Plus cuja próxima cena pede o Plus:
  /// o CTA sempre abre uma cena jogável, nunca o paywall.
  ///
  /// Com [trailModes] (modo gravado por trilha), a trilha que a pessoa está
  /// aprofundando ([isDeepening]) continua no herói.
  static Trail? findActiveTrail(
    List<Trail> trails,
    List<String> completed, {
    Map<String, List<String>> clearedTrailModes = const {},
    Map<String, String> trailModes = const {},
    Map<String, String> pinnedModes = const {},
    Iterable<String> borrowed = const [],
    bool plusOpen = true,
  }) {
    bool playable(Trail trail) =>
        plusOpen || !nextSceneNeedsPlus(trail, completed);
    bool open(Trail? trail) =>
        trail != null &&
        playable(trail) &&
        !trail.comingSoon &&
        trail.missionSlugs.isNotEmpty &&
        isTrailUnlocked(
          trail,
          trails,
          completed,
          clearedTrailModes: clearedTrailModes,
        ) &&
        (!isTrailCompleted(
              trail,
              completed,
              clearedTrailModes: clearedTrailModes,
            ) ||
            isDeepening(
              trail,
              completed,
              clearedTrailModes: clearedTrailModes,
              trailModes: trailModes,
              pinnedModes: pinnedModes,
              borrowed: borrowed,
            ));
    Trail? bySlug(String? slug) =>
        slug == null ? null : trails.where((t) => t.slug == slug).firstOrNull;

    // 1. A trilha da última cena; terminada, a que ela continua.
    final lastSlug = lastPlayedMissionSlug;
    final last = lastSlug == null
        ? null
        : trails.where((t) => t.missionSlugs.contains(lastSlug)).firstOrNull;
    if (open(last)) return last;
    if (last != null) {
      for (final next in successorsOf(last, trails)) {
        if (open(next)) return next;
      }
    }
    // 2. A do motivo do onboarding.
    final preferred = preferredTrailSlug;
    final chosen = bySlug(preferred);
    if (open(chosen)) return chosen;
    // 3. A ordem do catálogo.
    for (final trail in trails) {
      if (trail.comingSoon || trail.missionSlugs.isEmpty) continue;
      if (!playable(trail)) continue;
      // Trilhas de um motivo só entram quando são a escolha da pessoa.
      if (EntryTrails.intentOnly.contains(trail.slug) &&
          trail.slug != preferred) {
        continue;
      }
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
    return trails
        .where((t) => t.missionSlugs.isNotEmpty && playable(t))
        .firstOrNull;
  }

  /// A trilha já tem um modo selado e a pessoa voltou a ela no modo
  /// seguinte: gravou um modo ainda não selado e o escolheu ([pinnedModes])
  /// ou já fez cena nele (trocar de modo zera as cenas, então cena feita =
  /// cena do modo novo). Cena só emprestada ([borrowed]) não conta.
  static bool isDeepening(
    Trail trail,
    List<String> completed, {
    Map<String, List<String>> clearedTrailModes = const {},
    Map<String, String> trailModes = const {},
    Map<String, String> pinnedModes = const {},
    Iterable<String> borrowed = const [],
  }) {
    final cleared = clearedTrailModes[trail.slug] ?? const [];
    if (cleared.isEmpty) return false;
    final mode = trailModes[trail.slug];
    if (mode == null || cleared.contains(mode)) return false;
    final skip = borrowed.toSet();
    final done = _doneSet(completed);
    final slugs = missionSlugs(trail);
    if (slugs.every(done.contains)) return false;
    return pinnedModes[trail.slug] == mode ||
        slugs.any((s) => done.contains(s) && !skip.contains(s));
  }

  /// O modo seguinte ao último selado na trilha, ou null se nenhum foi
  /// selado ou todos já foram.
  static TrailDifficulty? nextModeToDeepen(List<String> clearedModes) {
    if (clearedModes.isEmpty) return null;
    for (final d in TrailDifficulty.values) {
      if (!clearedModes.contains(d.id)) return d;
    }
    return null;
  }

  /// Trilhas do carrossel do herói: todas em que a pessoa pode dar a
  /// próxima cena agora. Ordem: a ativa ([findActiveTrail]), as que está
  /// aprofundando, as começadas (a mais recente primeiro), depois as
  /// abertas e ainda não começadas, na ordem do catálogo. Sem Peregrino+
  /// ([plusOpen] falso), fica de fora a trilha cuja próxima cena pede o Plus.
  static List<Trail> availableTrails(
    List<Trail> trails,
    List<String> completed, {
    Map<String, List<String>> clearedTrailModes = const {},
    Map<String, String> trailModes = const {},
    Map<String, String> pinnedModes = const {},
    Map<String, String> completedOn = const {},
    Iterable<String> borrowed = const [],
    bool plusOpen = true,
  }) {
    bool fits(Trail t) =>
        !t.comingSoon &&
        t.missionSlugs.isNotEmpty &&
        (plusOpen || !nextSceneNeedsPlus(t, completed)) &&
        getCurrentMission(t, completed) != null;
    bool walking(Trail t) =>
        !isTrailCompleted(t, completed, clearedTrailModes: clearedTrailModes) ||
        isDeepening(
          t,
          completed,
          clearedTrailModes: clearedTrailModes,
          trailModes: trailModes,
          pinnedModes: pinnedModes,
          borrowed: borrowed,
        );
    final preferred = preferredTrailSlug;
    final active = findActiveTrail(
      trails,
      completed,
      clearedTrailModes: clearedTrailModes,
      trailModes: trailModes,
      pinnedModes: pinnedModes,
      borrowed: borrowed,
      plusOpen: plusOpen,
    );
    final out = <Trail>[];
    final seen = <String>{};
    void add(Trail t) {
      if (fits(t) && walking(t) && seen.add(t.slug)) out.add(t);
    }

    if (active != null) add(active);
    for (final t in trails) {
      if (isDeepening(
        t,
        completed,
        clearedTrailModes: clearedTrailModes,
        trailModes: trailModes,
        pinnedModes: pinnedModes,
        borrowed: borrowed,
      )) {
        add(t);
      }
    }
    for (final t in startedTrails(
      trails,
      completed,
      completedOn: completedOn,
      borrowed: borrowed,
      clearedTrailModes: clearedTrailModes,
    )) {
      add(t);
    }
    for (final t in trails) {
      // Trilha de um motivo só entra quando é a escolha da pessoa.
      if (EntryTrails.intentOnly.contains(t.slug) && t.slug != preferred) {
        continue;
      }
      if (isTrailUnlocked(
        t,
        trails,
        completed,
        clearedTrailModes: clearedTrailModes,
      )) {
        add(t);
      }
    }
    return out;
  }

  /// Trilhas começadas e não terminadas, a mais recente primeiro: a da
  /// última cena, depois pelo dia da última cena feita ([completedOn]).
  /// Cena só emprestada ([borrowed]) não abre a trilha.
  static List<Trail> startedTrails(
    List<Trail> trails,
    List<String> completed, {
    Map<String, String> completedOn = const {},
    Iterable<String> borrowed = const [],
    Map<String, List<String>> clearedTrailModes = const {},
  }) {
    final lastSlug = lastPlayedMissionSlug;
    String lastDay(Trail t) {
      var day = '';
      for (final slug in t.missionSlugs) {
        final d = completedOn[slug] ?? '';
        if (d.compareTo(day) > 0) day = d;
      }
      return day;
    }

    final skip = borrowed.toSet();
    final played = _doneSet(completed).difference(skip);
    final started = [
      for (final t in trails)
        if (!t.comingSoon &&
            t.missionSlugs.any(played.contains) &&
            !isTrailCompleted(
              t,
              completed,
              clearedTrailModes: clearedTrailModes,
            ))
          (trail: t, day: lastDay(t), last: t.missionSlugs.contains(lastSlug)),
    ];
    started.sort((x, y) {
      if (x.last != y.last) return x.last ? -1 : 1;
      return y.day.compareTo(x.day);
    });
    return [for (final s in started) s.trail];
  }

  static bool isMissionUnlocked(
    String missionSlug,
    List<String> allSlugs,
    List<String> completed,
  ) {
    if (CatalogAccess.openAllForTesting) return true;
    final index = allSlugs.indexOf(missionSlug);
    if (index <= 0) return true;
    return _doneSet(completed).contains(allSlugs[index - 1]);
  }
}

/// Busca O(1) nos passos concluídos. Home e Trilhas cruzam o catálogo
/// inteiro com esta lista a cada build; o ProgressService troca a instância
/// quando ela muda, então basta um cache de 1 entrada por identidade.
List<String>? _doneFor;
int _doneLen = -1;
Set<String> _done = const {};

Set<String> _doneSet(List<String> completed) {
  if (!identical(_doneFor, completed) || _doneLen != completed.length) {
    _doneFor = completed;
    _doneLen = completed.length;
    _done = completed.toSet();
  }
  return _done;
}
