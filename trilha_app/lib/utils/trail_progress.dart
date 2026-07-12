import '../models/trail.dart';

class TrailProgress {
  static List<String> missionSlugs(Trail trail) => trail.missionSlugs;

  static ({int done, int total, int pct}) getProgress(
    Trail trail,
    List<String> completed,
  ) {
    final slugs = missionSlugs(trail);
    final done = slugs.where(completed.contains).length;
    final total = slugs.length;
    final pct = total > 0 ? ((done / total) * 100).round() : 0;
    return (done: done, total: total, pct: pct);
  }

  static bool isTrailCompleted(Trail trail, List<String> completed) {
    final slugs = missionSlugs(trail);
    if (slugs.isEmpty) return false;
    return slugs.every(completed.contains);
  }

  static bool isTrailUnlocked(
    Trail trail,
    List<Trail> allTrails,
    List<String> completed,
  ) {
    if (trail.unlockAfter == null) return true;
    final prereq = allTrails.where((t) => t.slug == trail.unlockAfter).firstOrNull;
    if (prereq == null) return true;
    return isTrailCompleted(prereq, completed);
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

  static Trail? findActiveTrail(List<Trail> trails, List<String> completed) {
    for (final trail in trails) {
      if (trail.comingSoon || trail.missionSlugs.isEmpty) continue;
      if (!isTrailUnlocked(trail, trails, completed)) continue;
      if (!isTrailCompleted(trail, completed)) return trail;
    }
    return trails.where((t) => t.missionSlugs.isNotEmpty).firstOrNull;
  }

  static bool isMissionUnlocked(
    String missionSlug,
    List<String> allSlugs,
    List<String> completed,
  ) {
    final index = allSlugs.indexOf(missionSlug);
    if (index <= 0) return true;
    return completed.contains(allSlugs[index - 1]);
  }
}
