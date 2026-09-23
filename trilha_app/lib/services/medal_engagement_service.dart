import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/trail_repository.dart';
import '../models/caravan_profile_prefs.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/pilgrim_medal_catalog.dart';
import '../models/pilgrim_medal_models.dart';
import '../models/pilgrim_medals.dart' as medals;
import '../models/trail.dart';
import '../services/backend_service.dart';
import '../services/bible_service.dart';
import '../services/progress_service.dart';
import '../widgets/medal_unlock_sheet.dart';

/// Celebração de tier-ups, raras e proximidade (v3).
class MedalEngagementService {
  MedalEngagementService._();

  static final MedalEngagementService instance = MedalEngagementService._();

  Timer? _debounce;
  bool _checking = false;
  bool _showingSheet = false;
  List<Trail> _catalog = const [];
  int _epoch = 0;

  /// Descarta checagens pendentes (logout). Um check já em curso
  /// também aborta antes de abrir a folha de conquista.
  void cancelPending() {
    _debounce?.cancel();
    _debounce = null;
    _epoch++;
  }

  void scheduleCheck(BuildContext context) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (!context.mounted) return;
      unawaited(check(context));
    });
  }

  bool _sessionOpen(BuildContext context, int epoch) {
    return epoch == _epoch && context.read<BackendService>().isSignedIn;
  }

  Future<void> check(BuildContext context) async {
    if (_checking || _showingSheet) return;
    final epoch = _epoch;
    _checking = true;
    try {
      final progress = context.read<ProgressService>();
      if (!progress.isLoaded) return;
      // Reset de progresso volta à introdução. Sem isso, a folha de
      // conquista abre por cima dos ajustes ou da tela de entrar.
      if (!progress.hasSeenOnboarding) return;

      final backend = context.read<BackendService>();
      if (!backend.isSignedIn || epoch != _epoch) return;
      final bundle = await _buildBundle(progress, backend);
      if (!context.mounted) return;
      if (!_sessionOpen(context, epoch)) return;
      final profile = bundle.profile;
      final catalog = bundle.catalog;
      final ctx = bundle.ctx;
      final vaults = medals.PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: catalog,
        ctx: ctx,
      );

      final unlockedIds = _allCelebrationIds(vaults);
      await progress.seedMedalCelebrationsIfNeeded(
        currentlyUnlockedIds: unlockedIds,
      );

      final celebrated = PilgrimMedalCatalog.expandCelebratedIds(
        progress.celebratedMedalIds,
      );

      final tierUps = medals.PilgrimMedals.newTierUps(
        profile,
        celebrated,
        catalog,
        ctx: ctx,
      );
      if (!context.mounted) return;
      if (tierUps.isNotEmpty && _sessionOpen(context, epoch)) {
        await _celebrateTierUps(context, progress, tierUps);
      }

      if (!context.mounted) return;
      if (!_sessionOpen(context, epoch)) return;
      final refreshedCelebrated = PilgrimMedalCatalog.expandCelebratedIds(
        progress.celebratedMedalIds,
      );
      final rarePending = medals.PilgrimMedals.newRareUnlocks(
        bundle.profile,
        refreshedCelebrated,
        catalog,
        ctx: ctx,
      );
      final silentRares = rarePending.where((m) => m.def.silent).toList();
      for (final silent in silentRares) {
        await progress.markMedalCelebrated(silent.def.id);
      }
      final loudRares = rarePending.where((m) => !m.def.silent).toList();
      if (!context.mounted) return;
      if (loudRares.isNotEmpty && _sessionOpen(context, epoch)) {
        await _celebrateRares(context, progress, loudRares);
      }

      if (!context.mounted) return;
      if (!_sessionOpen(context, epoch)) return;
      final refreshed = await _buildBundle(progress, backend);
      final refreshedVaults = medals.PilgrimMedals.evaluateVaults(
        profile: refreshed.profile,
        catalog: refreshed.catalog,
        ctx: refreshed.ctx,
      );
      final newVaults = medals.PilgrimMedals.newlyCompletedVaultIds(
        vaults: refreshedVaults,
        alreadyCelebratedVaultIds: progress.celebratedVaultIds,
      );
      for (final vaultId in newVaults) {
        if (!context.mounted) break;
        if (!_sessionOpen(context, epoch)) break;
        final state = refreshedVaults.firstWhere((v) => v.vault.id == vaultId);
        _showingSheet = true;
        await showMedalVaultCompleteSheet(
          context,
          vaultTitle: state.vault.title,
          total: state.total,
        );
        _showingSheet = false;
        await progress.markVaultCompleteCelebrated(vaultId);
      }
    } finally {
      _checking = false;
    }
  }

  static List<String> _allCelebrationIds(List<PilgrimVaultState> vaults) => [
        for (final vault in vaults)
          for (final track in vault.tracks)
            if (track.hasStarted)
              for (var i = 0; i <= track.levelIndex; i++)
                track.track.levels[i].id,
        for (final vault in vaults)
          for (final rare in vault.rareMedals)
            if (rare.unlocked) rare.def.id,
      ];

  Future<void> _celebrateTierUps(
    BuildContext context,
    ProgressService progress,
    List<PilgrimTrackTierUp> pending,
  ) async {
    for (final tierUp in medals.PilgrimMedals.collapsedNewTierUps(pending)) {
      if (!context.mounted) break;
      _showingSheet = true;
      await showTrackTierUpSheet(context, tierUp);
      _showingSheet = false;
      for (final up in pending) {
        if (up.track.id == tierUp.track.id) {
          await progress.markMedalCelebrated(up.celebrationId);
        }
      }
    }
  }

  Future<void> _celebrateRares(
    BuildContext context,
    ProgressService progress,
    List<PilgrimMedalStatus> pending,
  ) async {
    for (final medal in pending) {
      if (!context.mounted) break;
      _showingSheet = true;
      await showMedalUnlockSheet(context, medal);
      _showingSheet = false;
      await progress.markMedalCelebrated(medal.def.id);
    }
  }

  Future<({
    CaravanPilgrimProfile profile,
    List<Trail> catalog,
    PilgrimMedalEvalContext ctx,
  })> _buildBundle(
    ProgressService progress,
    BackendService backend,
  ) async {
    _catalog = await TrailRepository().getTrails();
    final base = CaravanPilgrimProfile.fromProgress(
      progress: progress,
      uid: backend.uid ?? '',
    );
    final books = await BibleService.instance.books();
    final profile = await base.enriched(catalog: _catalog, bibleBooks: books);
    final ctx = PilgrimMedalEvalContext.fromProgress(progress);
    return (profile: profile, catalog: _catalog, ctx: ctx);
  }

  static int unlockedCountForProgress(
    ProgressService progress,
    String uid,
    List<Trail> catalog,
  ) {
    return medals.PilgrimMedals.unlockedCount(
      CaravanPilgrimProfile.fromProgress(progress: progress, uid: uid),
      catalog,
      ctx: PilgrimMedalEvalContext.fromProgress(progress),
    );
  }

  static Future<int> unlockedCountCached(ProgressService progress, String uid) {
    return TrailRepository().getTrails().then(
          (catalog) => unlockedCountForProgress(progress, uid, catalog),
        );
  }

  /// Só as medalhas raras "Mirra" já desbloqueadas (não a soma de tudo).
  static List<PilgrimMedalDef> unlockedRareMedalsForProgress(
    ProgressService progress,
    String uid,
    List<Trail> catalog,
  ) {
    final vaults = medals.PilgrimMedals.evaluateVaults(
      profile: CaravanPilgrimProfile.fromProgress(progress: progress, uid: uid),
      catalog: catalog,
      ctx: PilgrimMedalEvalContext.fromProgress(progress),
    );
    return [
      for (final vault in vaults)
        for (final status in vault.rareMedals)
          if (status.unlocked) status.def,
    ];
  }

  static Future<List<PilgrimMedalDef>> unlockedRareMedalsCached(
    ProgressService progress,
    String uid,
  ) {
    return TrailRepository().getTrails().then(
          (catalog) => unlockedRareMedalsForProgress(progress, uid, catalog),
        );
  }

  static final _standingMedals =
      <String, Future<({List<PilgrimMedalDef> rares, int total})>>{};

  /// Medalhas do card do ranking (eu: local; outros: perfil público).
  static Future<({List<PilgrimMedalDef> rares, int total})>
      standingMedalsCached({
    required bool isUser,
    required String uid,
    required String name,
    required ProgressService progress,
    required BackendService backend,
  }) {
    final key = isUser ? 'self:$uid' : uid;
    if (key.isEmpty) {
      return Future.value((rares: <PilgrimMedalDef>[], total: 0));
    }
    return _standingMedals.putIfAbsent(key, () async {
      if (isUser) {
        final catalog = await TrailRepository().getTrails();
        return (
          rares: unlockedRareMedalsForProgress(progress, uid, catalog),
          total: unlockedCountForProgress(progress, uid, catalog),
        );
      }

      final result = await backend.fetchPilgrimProfile(uid);
      if (!result.hasDocument) {
        return (rares: <PilgrimMedalDef>[], total: 0);
      }
      var profile = CaravanPilgrimProfile.fromCloudMap(
        uid: uid,
        data: result.data!,
        fallbackName: name,
      );
      if (!profile.prefs.shouldShow(
        CaravanProfileSection.medals,
        isOwner: false,
      )) {
        return (rares: <PilgrimMedalDef>[], total: 0);
      }
      final catalog = await TrailRepository().getTrails();
      final books = await BibleService.instance.books();
      profile = await profile.enriched(catalog: catalog, bibleBooks: books);
      final ctx = PilgrimMedalEvalContext.fromProfile(profile);
      final vaults = medals.PilgrimMedals.evaluateVaults(
        profile: profile,
        catalog: catalog,
        ctx: ctx,
      );
      return (
        rares: [
          for (final vault in vaults)
            for (final status in vault.rareMedals)
              if (status.unlocked) status.def,
        ],
        total: medals.PilgrimMedals.unlockedCount(
          profile,
          catalog,
          ctx: ctx,
        ),
      );
    });
  }

  static Color tierColor(PilgrimMedalTier tier) => medals.tierColor(tier);
}
