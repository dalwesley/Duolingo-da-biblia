import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/trail.dart';

class TrailRepository {
  List<Trail>? _cache;

  Future<List<Trail>> getTrails() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/trails.json');
    final list = jsonDecode(raw) as List;
    _cache = list.map((e) => Trail.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return _cache!;
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
