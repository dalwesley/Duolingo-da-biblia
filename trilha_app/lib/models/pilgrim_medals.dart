import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'caravan_pilgrim_profile.dart';
import 'pilgrim_medal_catalog.dart';
import 'pilgrim_medal_models.dart';
import 'trail.dart';

export 'pilgrim_medal_catalog.dart';
export 'pilgrim_medal_models.dart';

/// Avaliação de medalhas v3 — escadas por família + raras Mirra.
class PilgrimMedals {
  PilgrimMedals._();

  static List<PilgrimVaultDef> allVaultDefs(List<Trail> catalog) => [
        PilgrimMedalCatalog.journeyVault(),
        ...PilgrimMedalCatalog.trailVaultsForCatalog(catalog),
        PilgrimMedalCatalog.discoveryVault(),
      ];

  static List<PilgrimVaultState> evaluateVaults({
    required CaravanPilgrimProfile profile,
    required List<Trail> catalog,
    PilgrimMedalEvalContext ctx = const PilgrimMedalEvalContext(),
  }) {
    final vaults = <PilgrimVaultState>[];

    vaults.add(
      PilgrimVaultState(
        vault: PilgrimMedalCatalog.journeyVault(),
        tracks: [
          for (final track in PilgrimMedalCatalog.journeyTracks)
            _evaluateTrack(track, profile, catalog, ctx),
        ],
      ),
    );

    final startedSlugs = _startedTrailSlugs(profile, catalog);
    final trailVaults = PilgrimMedalCatalog.trailVaultsForCatalog(catalog)
        .where((v) => startedSlugs.contains(v.id.replaceFirst('trail:', '')))
        .toList()
      ..sort((a, b) {
        final aSlug = a.id.replaceFirst('trail:', '');
        final bSlug = b.id.replaceFirst('trail:', '');
        final byProgress = _trailProgress(profile, catalog, bSlug)
            .compareTo(_trailProgress(profile, catalog, aSlug));
        if (byProgress != 0) return byProgress;
        return a.order.compareTo(b.order);
      });

    for (final def in trailVaults) {
      vaults.add(
        PilgrimVaultState(
          vault: def,
          tracks: [
            for (final track in def.tracks)
              _evaluateTrack(track, profile, catalog, ctx),
          ],
        ),
      );
    }

    final discovery = PilgrimVaultState(
      vault: PilgrimMedalCatalog.discoveryVault(),
      rareMedals: [
        for (final medal in PilgrimMedalCatalog.rareMedals)
          PilgrimMedalStatus(
            def: medal,
            unlocked: _isRareUnlocked(medal, profile, catalog, ctx),
          ),
      ],
    );
    vaults.add(discovery);

    return vaults;
  }

  static List<PilgrimTrackState> allTrackStates({
    required CaravanPilgrimProfile profile,
    required List<Trail> catalog,
    PilgrimMedalEvalContext ctx = const PilgrimMedalEvalContext(),
  }) =>
      [
        for (final vault in evaluateVaults(
          profile: profile,
          catalog: catalog,
          ctx: ctx,
        ))
          ...vault.tracks,
      ];

  static int unlockedCount(
    CaravanPilgrimProfile profile,
    List<Trail> catalog, {
    PilgrimMedalEvalContext ctx = const PilgrimMedalEvalContext(),
  }) =>
      evaluateVaults(profile: profile, catalog: catalog, ctx: ctx)
          .fold<int>(0, (sum, v) => sum + v.unlockedCount);

  static bool isJourneyVaultComplete(
    CaravanPilgrimProfile profile,
    List<Trail> catalog, {
    PilgrimMedalEvalContext ctx = const PilgrimMedalEvalContext(),
  }) {
    final journey = evaluateVaults(
      profile: profile,
      catalog: catalog,
      ctx: ctx,
    ).firstWhere((v) => v.vault.id == PilgrimMedalCatalog.journeyVaultId);
    return journey.isComplete;
  }

  static List<PilgrimMedalTile> tilesForVault(PilgrimVaultState state) {
    if (state.vault.kind == PilgrimVaultKind.discovery) {
      return [
        for (final status in state.rareMedals) PilgrimMedalTile.fromRare(status),
      ];
    }
    final tiles = <PilgrimMedalTile>[];
    for (final trackState in state.tracks) {
      final track = trackState.track;
      for (var i = 0; i < track.levels.length; i++) {
        tiles.add(
          PilgrimMedalTile.fromLevel(
            track: track,
            level: track.levels[i],
            unlocked: i <= trackState.levelIndex,
          ),
        );
      }
    }
    return tiles;
  }

  static List<PilgrimTrackTierUp> newTierUps(
    CaravanPilgrimProfile profile,
    Set<String> celebratedIds,
    List<Trail> catalog, {
    PilgrimMedalEvalContext ctx = const PilgrimMedalEvalContext(),
  }) {
    final celebrated = PilgrimMedalCatalog.expandCelebratedIds(celebratedIds);
    final ups = <PilgrimTrackTierUp>[];

    for (final trackState in allTrackStates(
      profile: profile,
      catalog: catalog,
      ctx: ctx,
    )) {
      if (!trackState.hasStarted) continue;
      for (var i = 0; i <= trackState.levelIndex; i++) {
        final level = trackState.track.levels[i];
        if (!celebrated.contains(level.id)) {
          ups.add(
            PilgrimTrackTierUp(
              track: trackState.track,
              level: level,
              levelIndex: i,
            ),
          );
        }
      }
    }

    ups.sort((a, b) {
      final kind = a.track.kind.index.compareTo(b.track.kind.index);
      if (kind != 0) return kind;
      final title = a.track.title.compareTo(b.track.title);
      if (title != 0) return title;
      return a.levelIndex.compareTo(b.levelIndex);
    });
    return ups;
  }

  static List<PilgrimMedalStatus> newRareUnlocks(
    CaravanPilgrimProfile profile,
    Set<String> celebratedIds,
    List<Trail> catalog, {
    PilgrimMedalEvalContext ctx = const PilgrimMedalEvalContext(),
  }) {
    final celebrated = PilgrimMedalCatalog.expandCelebratedIds(celebratedIds);
    final discovery = evaluateVaults(
      profile: profile,
      catalog: catalog,
      ctx: ctx,
    ).where((v) => v.vault.kind == PilgrimVaultKind.discovery);
    return [
      for (final vault in discovery)
        for (final status in vault.rareMedals)
          if (status.unlocked && !celebrated.contains(status.def.id)) status,
    ];
  }

  /// Compat: tier-ups + raras, em ordem.
  static List<PilgrimMedalStatus> newUnlocks(
    CaravanPilgrimProfile profile,
    Set<String> celebratedIds,
    List<Trail> catalog, {
    PilgrimMedalEvalContext ctx = const PilgrimMedalEvalContext(),
  }) =>
      newRareUnlocks(profile, celebratedIds, catalog, ctx: ctx);

  static List<String> newlyCompletedVaultIds({
    required List<PilgrimVaultState> vaults,
    required Set<String> alreadyCelebratedVaultIds,
  }) =>
      [
        for (final state in vaults)
          if (state.isComplete &&
              !alreadyCelebratedVaultIds.contains(state.vault.id))
            state.vault.id,
      ];

  static PilgrimTrackProximity? nearestLocked({
    required CaravanPilgrimProfile profile,
    required List<Trail> catalog,
    String? priorityTrailSlug,
    PilgrimMedalEvalContext ctx = const PilgrimMedalEvalContext(),
  }) {
    PilgrimTrackProximity? best;

    void consider(PilgrimTrackState trackState, String vaultTitle) {
      final step = _progressTowardTrack(trackState, profile, catalog, ctx);
      if (step == null || step.remaining > step.showWithin) return;
      final next = trackState.nextLevel;
      if (next == null) return;
      final proximity = PilgrimTrackProximity(
        track: trackState.track,
        nextLevel: next,
        vaultTitle: vaultTitle,
        current: step.current,
        target: step.target,
        remaining: step.remaining,
        unitLabel: step.label,
      );
      if (best == null || step.remaining < best!.remaining) {
        best = proximity;
      }
    }

    final vaults = evaluateVaults(
      profile: profile,
      catalog: catalog,
      ctx: ctx,
    );

    for (final state in vaults) {
      if (state.vault.kind == PilgrimVaultKind.discovery) continue;
      if (state.vault.kind == PilgrimVaultKind.trail &&
          priorityTrailSlug != null &&
          state.vault.id != PilgrimMedalCatalog.trailVaultId(priorityTrailSlug)) {
        continue;
      }
      for (final trackState in state.tracks) {
        if (trackState.isComplete) continue;
        consider(trackState, state.vault.title);
      }
    }

    if (best != null || priorityTrailSlug == null) return best;

    for (final state in vaults) {
      if (state.vault.kind == PilgrimVaultKind.discovery) continue;
      for (final trackState in state.tracks) {
        if (trackState.isComplete) continue;
        consider(trackState, state.vault.title);
      }
    }
    return best;
  }

  static PilgrimTrackState _evaluateTrack(
    PilgrimMedalTrackDef track,
    CaravanPilgrimProfile profile,
    List<Trail> catalog,
    PilgrimMedalEvalContext ctx,
  ) {
    var highest = -1;
    for (var i = 0; i < track.levels.length; i++) {
      if (_isLevelUnlocked(track, i, profile, catalog, ctx)) {
        highest = i;
      }
    }
    return PilgrimTrackState(track: track, levelIndex: highest);
  }

  static bool _isLevelUnlocked(
    PilgrimMedalTrackDef track,
    int levelIndex,
    CaravanPilgrimProfile profile,
    List<Trail> catalog,
    PilgrimMedalEvalContext ctx,
  ) {
    if (track.kind == PilgrimVaultKind.trail) {
      return _isTrailLevelUnlocked(track, levelIndex, profile, catalog);
    }
    return switch (track.id) {
      PilgrimMedalCatalog.trackWordId => _wordLevel(levelIndex, profile),
      PilgrimMedalCatalog.trackFormationId =>
        _formationLevel(levelIndex, profile),
      PilgrimMedalCatalog.trackPathId => _pathLevel(levelIndex, profile),
      PilgrimMedalCatalog.trackWitnessId =>
        _witnessLevel(levelIndex, profile),
      PilgrimMedalCatalog.trackMemoryId => _memoryLevel(levelIndex, profile),
      _ => false,
    };
  }

  static bool _wordLevel(int level, CaravanPilgrimProfile profile) =>
      switch (level) {
        0 => profile.bibleChaptersRead >= 1,
        1 => profile.bibleChaptersRead >= 25,
        2 => profile.completeBibleBooks.isNotEmpty,
        3 => profile.completeBibleBooks
            .any((a) => PilgrimMedalCatalog.gospelAbbrevs.contains(a)),
        4 => _hasOtBook(profile),
        5 => profile.completeNtBooks.isNotEmpty,
        _ => false,
      };

  static bool _formationLevel(int level, CaravanPilgrimProfile profile) =>
      switch (level) {
        0 => profile.perfectMissions.isNotEmpty,
        1 => profile.perfectMissions.length >= 5,
        2 => profile.perfectMissions.length >= 25,
        3 =>
          profile.lifetimeQuestionsAnswered >= 50 &&
              (profile.accuracyPercent ?? 0) >= 85,
        4 => profile.perfectMissions.any((s) => s.contains('boss')),
        _ => false,
      };

  static bool _pathLevel(int level, CaravanPilgrimProfile profile) =>
      switch (level) {
        0 => profile.streak >= 3,
        1 => profile.streak >= 7,
        2 => profile.streak >= 14,
        3 => profile.streak >= 30,
        4 => profile.streak >= 90,
        5 => profile.daysAsCaravanLeader >= 1,
        _ => false,
      };

  static bool _witnessLevel(int level, CaravanPilgrimProfile profile) =>
      switch (level) {
        0 => profile.sharedVerseCount >= 1,
        1 => profile.sharedVerseCount >= 10,
        2 => profile.sharedVerseCount >= 25,
        3 => profile.sharedVerseCount >= 50,
        _ => false,
      };

  static bool _memoryLevel(int level, CaravanPilgrimProfile profile) =>
      switch (level) {
        0 => profile.memoryMasteredCount >= 5,
        1 => profile.memoryMasteredCount >= 15,
        2 => profile.memoryMasteredCount >= 30,
        3 => profile.memoryMasteredCount >= 50,
        _ => false,
      };

  static bool _isTrailLevelUnlocked(
    PilgrimMedalTrackDef track,
    int levelIndex,
    CaravanPilgrimProfile profile,
    List<Trail> catalog,
  ) {
    final slug = track.trailSlug;
    if (slug == null) return false;
    final trail = _trailBySlug(catalog, slug);
    if (trail == null) return false;
    final slugs = trail.missionSlugs.toSet();
    final done = slugs.where(profile.completedMissions.contains).length;
    final modes = profile.clearedTrailModes[slug] ?? const <String>[];

    return switch (levelIndex) {
      0 => done >= 1,
      1 => modes.contains('semente'),
      2 => modes.contains('caminhada'),
      3 => done >= slugs.length && modes.contains('profundezas'),
      _ => false,
    };
  }

  static bool _isRareUnlocked(
    PilgrimMedalDef def,
    CaravanPilgrimProfile profile,
    List<Trail> catalog,
    PilgrimMedalEvalContext ctx,
  ) =>
      switch (def.id) {
        'discovery:founder' => _isFounder(ctx.firstOpenDate),
        'discovery:comeback' => _hasComeback(ctx.playDates, minDays: 21),
        'discovery:accuracy_elite' => _hasAccuracyElite(profile),
        'discovery:trail_flawless' => _hasFlawlessTrail(profile, catalog),
        'discovery:reflection_deep' => ctx.reflectionCount >= 40,
        _ => false,
      };

  static bool _hasOtBook(CaravanPilgrimProfile profile) =>
      profile.completeBibleBooks.any((a) => !profile.completeNtBooks.contains(a));

  static bool _isFounder(String? firstOpenDate) {
    if (firstOpenDate == null || firstOpenDate.isEmpty) return false;
    final parsed = DateTime.tryParse(firstOpenDate);
    if (parsed == null) return false;
    return parsed.year <= 2026;
  }

  static bool _hasComeback(List<String> playDates, {required int minDays}) {
    if (playDates.length < 2) return false;
    final sorted = playDates.map(DateTime.tryParse).whereType<DateTime>().toList()
      ..sort();
    if (sorted.length < 2) return false;
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i].difference(sorted[i - 1]).inDays >= minDays) return true;
    }
    return false;
  }

  static bool _hasAccuracyElite(CaravanPilgrimProfile profile) =>
      profile.lifetimeQuestionsAnswered >= 150 &&
      (profile.accuracyPercent ?? 0) >= 95;

  static bool _hasFlawlessTrail(
    CaravanPilgrimProfile profile,
    List<Trail> catalog,
  ) {
    for (final trail in catalog) {
      if (trail.comingSoon || trail.missionSlugs.isEmpty) continue;
      final slugs = trail.missionSlugs;
      if (!slugs.every(profile.completedMissions.contains)) continue;
      if (slugs.every(profile.perfectMissions.contains)) return true;
    }
    return false;
  }

  static Set<String> _startedTrailSlugs(
    CaravanPilgrimProfile profile,
    List<Trail> catalog,
  ) {
    final out = <String>{};
    for (final trail in catalog) {
      if (trail.comingSoon || trail.missionSlugs.isEmpty) continue;
      final done = trail.missionSlugs
          .where(profile.completedMissions.contains)
          .length;
      if (done > 0) out.add(trail.slug);
    }
    return out;
  }

  static Trail? _trailBySlug(List<Trail> catalog, String slug) {
    for (final trail in catalog) {
      if (trail.slug == slug) return trail;
    }
    return null;
  }

  static double _trailProgress(
    CaravanPilgrimProfile profile,
    List<Trail> catalog,
    String slug,
  ) {
    final trail = _trailBySlug(catalog, slug);
    if (trail == null || trail.missionSlugs.isEmpty) return 0;
    final done =
        trail.missionSlugs.where(profile.completedMissions.contains).length;
    return done / trail.missionSlugs.length;
  }

  static _MedalStep? _progressTowardTrack(
    PilgrimTrackState trackState,
    CaravanPilgrimProfile profile,
    List<Trail> catalog,
    PilgrimMedalEvalContext ctx,
  ) {
    final nextIndex = trackState.levelIndex + 1;
    if (nextIndex < 0 || nextIndex >= trackState.track.levels.length) {
      return null;
    }
    return _progressTowardLevel(
      trackState.track,
      nextIndex,
      profile,
      catalog,
      ctx,
    );
  }

  static _MedalStep? _progressTowardLevel(
    PilgrimMedalTrackDef track,
    int levelIndex,
    CaravanPilgrimProfile profile,
    List<Trail> catalog,
    PilgrimMedalEvalContext ctx,
  ) {
    if (track.kind == PilgrimVaultKind.trail) {
      return _trailLevelProgress(track, levelIndex, profile, catalog);
    }
    return switch (track.id) {
      PilgrimMedalCatalog.trackWordId =>
        _wordProgress(levelIndex, profile),
      PilgrimMedalCatalog.trackFormationId =>
        _formationProgress(levelIndex, profile),
      PilgrimMedalCatalog.trackPathId => _pathProgress(levelIndex, profile),
      PilgrimMedalCatalog.trackWitnessId =>
        _witnessProgress(levelIndex, profile),
      PilgrimMedalCatalog.trackMemoryId =>
        _memoryProgress(levelIndex, profile),
      _ => null,
    };
  }

  static _MedalStep? _wordProgress(int level, CaravanPilgrimProfile profile) =>
      switch (level) {
        0 => _step(
            current: profile.bibleChaptersRead,
            target: 1,
            unit: 'capítulo',
            unitPlural: 'capítulos',
          ),
        1 => _step(
            current: profile.bibleChaptersRead,
            target: 25,
            unit: 'capítulo',
            unitPlural: 'capítulos',
          ),
        _ => null,
      };

  static _MedalStep? _formationProgress(
    int level,
    CaravanPilgrimProfile profile,
  ) =>
      switch (level) {
        0 => _step(
            current: profile.perfectMissions.length,
            target: 1,
            unit: 'cena perfeita',
            unitPlural: 'cenas perfeitas',
          ),
        1 => _step(
            current: profile.perfectMissions.length,
            target: 5,
            unit: 'cena perfeita',
            unitPlural: 'cenas perfeitas',
          ),
        2 => _step(
            current: profile.perfectMissions.length,
            target: 25,
            unit: 'cena perfeita',
            unitPlural: 'cenas perfeitas',
          ),
        3 => _accuracyStep(profile, minQuestions: 50, minPercent: 85),
        _ => null,
      };

  static _MedalStep? _pathProgress(int level, CaravanPilgrimProfile profile) =>
      switch (level) {
        0 => _step(
            current: profile.streak,
            target: 3,
            unit: 'dia de sequência',
            unitPlural: 'dias de sequência',
          ),
        1 => _step(
            current: profile.streak,
            target: 7,
            unit: 'dia de sequência',
            unitPlural: 'dias de sequência',
          ),
        2 => _step(
            current: profile.streak,
            target: 14,
            unit: 'dia de sequência',
            unitPlural: 'dias de sequência',
          ),
        3 => _step(
            current: profile.streak,
            target: 30,
            unit: 'dia de sequência',
            unitPlural: 'dias de sequência',
          ),
        4 => _step(
            current: profile.streak,
            target: 90,
            unit: 'dia de sequência',
            unitPlural: 'dias de sequência',
          ),
        _ => null,
      };

  static _MedalStep? _witnessProgress(
    int level,
    CaravanPilgrimProfile profile,
  ) =>
      switch (level) {
        0 => _step(
            current: profile.sharedVerseCount,
            target: 1,
            unit: 'versículo compartilhado',
            unitPlural: 'versículos compartilhados',
          ),
        1 => _step(
            current: profile.sharedVerseCount,
            target: 10,
            unit: 'versículo compartilhado',
            unitPlural: 'versículos compartilhados',
          ),
        2 => _step(
            current: profile.sharedVerseCount,
            target: 25,
            unit: 'versículo compartilhado',
            unitPlural: 'versículos compartilhados',
          ),
        3 => _step(
            current: profile.sharedVerseCount,
            target: 50,
            unit: 'versículo compartilhado',
            unitPlural: 'versículos compartilhados',
          ),
        _ => null,
      };

  static _MedalStep? _memoryProgress(
    int level,
    CaravanPilgrimProfile profile,
  ) =>
      switch (level) {
        0 => _step(
            current: profile.memoryMasteredCount,
            target: 5,
            unit: 'versículo memorizado',
            unitPlural: 'versículos memorizados',
          ),
        1 => _step(
            current: profile.memoryMasteredCount,
            target: 15,
            unit: 'versículo memorizado',
            unitPlural: 'versículos memorizados',
          ),
        2 => _step(
            current: profile.memoryMasteredCount,
            target: 30,
            unit: 'versículo memorizado',
            unitPlural: 'versículos memorizados',
          ),
        3 => _step(
            current: profile.memoryMasteredCount,
            target: 50,
            unit: 'versículo memorizado',
            unitPlural: 'versículos memorizados',
          ),
        _ => null,
      };

  static _MedalStep? _trailLevelProgress(
    PilgrimMedalTrackDef track,
    int levelIndex,
    CaravanPilgrimProfile profile,
    List<Trail> catalog,
  ) {
    final slug = track.trailSlug;
    if (slug == null) return null;
    final trail = _trailBySlug(catalog, slug);
    if (trail == null) return null;
    final total = trail.missionSlugs.length;
    final done = trail.missionSlugs
        .where(profile.completedMissions.contains)
        .length;

    if (levelIndex == 0 || levelIndex == 3) {
      return _step(
        current: done,
        target: levelIndex == 0 ? 1 : total,
        unit: 'cena',
        unitPlural: 'cenas',
      );
    }
    return null;
  }

  static _MedalStep? _step({
    required int current,
    required int target,
    required String unit,
    required String unitPlural,
  }) {
    if (target <= 0 || current >= target) return null;
    final remaining = target - current;
    final label = remaining == 1 ? unit : unitPlural;
    final showWithin = target <= 5 ? target : (target * 0.2).ceil().clamp(3, 10);
    return _MedalStep(
      current: current,
      target: target,
      remaining: remaining,
      label: label,
      showWithin: showWithin,
    );
  }

  static _MedalStep? _accuracyStep(
    CaravanPilgrimProfile profile, {
    required int minQuestions,
    required int minPercent,
  }) {
    final answered = profile.lifetimeQuestionsAnswered;
    final percent = profile.accuracyPercent ?? 0;
    if (answered >= minQuestions && percent >= minPercent) return null;

    if (answered < minQuestions) {
      final remaining = minQuestions - answered;
      return _MedalStep(
        current: answered,
        target: minQuestions,
        remaining: remaining,
        label: remaining == 1 ? 'questão respondida' : 'questões respondidas',
        showWithin: 8,
      );
    }
    final remaining = minPercent - percent;
    if (remaining <= 0) return null;
    return _MedalStep(
      current: percent,
      target: minPercent,
      remaining: remaining,
      label: remaining == 1 ? 'ponto de acerto' : 'pontos de acerto',
      showWithin: 5,
    );
  }
}

class _MedalStep {
  final int current;
  final int target;
  final int remaining;
  final String label;
  final int showWithin;

  const _MedalStep({
    required this.current,
    required this.target,
    required this.remaining,
    required this.label,
    required this.showWithin,
  });
}

Color tierColor(PilgrimMedalTier tier) => switch (tier) {
      PilgrimMedalTier.iron => AppColors.medalIron,
      PilgrimMedalTier.bronze => AppColors.medalBronze,
      PilgrimMedalTier.silver => AppColors.medalSilver,
      PilgrimMedalTier.gold => AppColors.medalGold,
      PilgrimMedalTier.platinum => AppColors.medalPlatinum,
      PilgrimMedalTier.diamond => AppColors.medalDiamond,
      PilgrimMedalTier.mirra => AppColors.medalMirra,
    };
