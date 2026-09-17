import '../models/trail.dart';
import '../services/content_catalog_service.dart';
import 'entry_trails.dart';

class TrailRepository {
  Future<List<Trail>> getTrails({bool forceRefresh = false}) async {
    final remote = await ContentCatalogService.instance.getTrails(
      forceRefresh: forceRefresh,
    );
    return _mergeEntry(remote);
  }

  static List<Trail> _mergeEntry(List<Trail> remote) {
    final have = {for (final t in remote) t.slug};
    final extra = [
      for (final t in EntryTrails.overlay)
        if (!have.contains(t.slug)) t,
    ];
    if (extra.isEmpty) return remote;
    return [...extra, ...remote];
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
