import '../models/trail.dart';
import '../services/content_catalog_service.dart';

class TrailRepository {
  Future<List<Trail>> getTrails({bool forceRefresh = false}) {
    return ContentCatalogService.instance.getTrails(forceRefresh: forceRefresh);
  }

  Future<Trail?> getTrailBySlug(String slug) async {
    final trails = await getTrails();
    try {
      return trails.firstWhere((t) => t.slug == slug);
    } catch (_) {
      return null;
    }
  }

  Future<Mission?> getMissionBySlug(String slug) async {
    final trails = await getTrails();
    for (final trail in trails) {
      for (final mod in trail.modules) {
        for (final mission in mod.missions) {
          if (mission.slug == slug) return mission;
        }
      }
    }
    return null;
  }

  Future<String?> getTrailSlugForMission(String missionSlug) async {
    final trails = await getTrails();
    for (final trail in trails) {
      if (trail.missionSlugs.contains(missionSlug)) return trail.slug;
    }
    return null;
  }
}
