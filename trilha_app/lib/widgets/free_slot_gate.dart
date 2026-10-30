import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/trail_repository.dart';
import '../models/trail.dart';
import '../screens/paywall_screen.dart';
import '../screens/trail_map_screen.dart';
import '../services/backend_service.dart';
import '../services/league_service.dart';
import '../services/plus_log.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import '../utils/trail_progress.dart';
import 'one_trail_sheet.dart';
import 'reset_progress_sheet.dart';

/// Confere a vaga do grátis antes de abrir mapa ou cena de [target].
///
/// `true`: pode seguir. `false`: a rota já saiu (voltou, paywall ou mapa
/// da trilha em andamento). Com Plus, ou sem outra trilha na vaga, passa.
Future<bool> ensureFreeSlotAllows(
  BuildContext context,
  Trail target, {
  List<Trail>? trails,
}) async {
  if (context.read<SubscriptionService>().plusFeaturesOpen) return true;
  final progress = context.read<ProgressService>();
  final backend = context.read<BackendService>();
  final league = context.read<LeagueService>();
  final all = trails ?? await TrailRepository().getTrails();
  if (!context.mounted) return false;
  final walking = TrailProgress.freeSlotBlocker(
    target,
    all,
    progress.completedMissions,
    chosenAt: progress.trailChosenAt,
    seeded: progress.trailChoicesSeeded,
    clearedTrailModes: progress.clearedTrailModes,
    trailModes: progress.activeTrailModes,
    pinnedModes: progress.pinnedTrailDifficulties,
    completedOn: progress.missionCompletedOn,
    borrowed: progress.borrowedMissions,
  );
  if (walking == null) return true;
  PlusLog.log(
    'trava',
    'uma trilha por vez: ${target.slug} espera ${walking.slug}',
  );
  final choice = await showOneTrailSheet(
    context,
    walking: walking,
    target: target,
  );
  if (!context.mounted) return false;
  final nav = Navigator.of(context);
  switch (choice) {
    case OneTrailChoice.leave:
      final leave = await showLeaveTrailSheet(context);
      if (!context.mounted) return false;
      if (!leave) {
        nav.pop();
        return false;
      }
      await progress.leaveTrail(
        trailSlug: walking.slug,
        missionSlugs: walking.missionSlugs,
      );
      await backend.saveNow(
        progress,
        LeagueService.weekKey(),
        league: league,
      );
      return context.mounted;
    case OneTrailChoice.plus:
      unawaited(
        nav.pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const PaywallScreen(source: 'one_trail'),
          ),
        ),
      );
      return false;
    case OneTrailChoice.keepWalking:
      unawaited(
        nav.pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => TrailMapScreen(slug: walking.slug),
          ),
        ),
      );
      return false;
    case null:
      nav.pop();
      return false;
  }
}
