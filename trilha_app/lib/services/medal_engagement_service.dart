import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/trail_repository.dart';
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
  String? _lastProximitySnackId;
  List<Trail> _catalog = const [];

  void scheduleCheck(BuildContext context) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (!context.mounted) return;
      unawaited(check(context));
    });
  }

  Future<void> check(BuildContext context) async {
    if (_checking || _showingSheet) return;
    _checking = true;
    try {
      final progress = context.read<ProgressService>();
      if (!progress.isLoaded) return;

      final backend = context.read<BackendService>();
      final bundle = await _buildBundle(progress, backend);
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
      if (tierUps.isNotEmpty && context.mounted) {
        await _celebrateTierUps(context, progress, tierUps);
      }

      if (!context.mounted) return;
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
      if (loudRares.isNotEmpty && context.mounted) {
        await _celebrateRares(context, progress, loudRares);
      }

      if (!context.mounted) return;
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

      if (context.mounted) {
        _maybeProximitySnack(
          context,
          refreshed.profile,
          refreshed.catalog,
          refreshed.ctx,
        );
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

  void _maybeProximitySnack(
    BuildContext context,
    CaravanPilgrimProfile profile,
    List<Trail> catalog,
    PilgrimMedalEvalContext ctx,
  ) {
    final proximity = medals.PilgrimMedals.nearestLocked(
      profile: profile,
      catalog: catalog,
      ctx: ctx,
    );
    if (proximity == null || proximity.remaining > 1) return;
    if (_lastProximitySnackId == proximity.nextLevel.id) return;
    _lastProximitySnackId = proximity.nextLevel.id;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(proximity.shortMessage),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
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

  static Color tierColor(PilgrimMedalTier tier) => medals.tierColor(tier);
}
