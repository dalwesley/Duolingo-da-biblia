import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n_global.dart';
import '../models/season_walk.dart';
import 'trail_repository.dart';

/// Um dia da Caminhada trocado pelo banco: outra cena, com título e frase
/// por idioma (pt/en/es; o que faltar cai no pt e depois no do código).
@immutable
class SeasonDayOverride {
  final String missionSlug;
  final String trailSlug;
  final Map<String, String> title;
  final Map<String, String> insight;

  const SeasonDayOverride({
    required this.missionSlug,
    required this.trailSlug,
    this.title = const {},
    this.insight = const {},
  });

  static Map<String, String> _texts(Object? raw) => {
    if (raw is Map)
      for (final e in raw.entries)
        if (e.value is String && (e.value as String).trim().isNotEmpty)
          '${e.key}': (e.value as String).trim(),
  };

  static SeasonDayOverride? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final slug = '${raw['slug'] ?? ''}'.trim();
    final trail = '${raw['trail'] ?? ''}'.trim();
    if (slug.isEmpty || trail.isEmpty) return null;
    return SeasonDayOverride(
      missionSlug: slug,
      trailSlug: trail,
      title: _texts(raw['title']),
      insight: _texts(raw['insight']),
    );
  }

  Map<String, Object> toMap() => {
    'slug': missionSlug,
    'trail': trailSlug,
    'title': title,
    'insight': insight,
  };

  String? _pick(Map<String, String> texts, String lang) =>
      texts[lang] ?? texts['pt'];

  SeasonWalkDay apply(SeasonWalkDay base, String lang) => SeasonWalkDay(
    index: base.index,
    missionSlug: missionSlug,
    trailSlug: trailSlug,
    title: _pick(title, lang) ?? base.title,
    insight: _pick(insight, lang) ?? base.insight,
  );
}

/// Roteiro da Caminhada vindo do banco: `campaigns/{id}.route` troca a cena
/// de um dia sem versão nova do app. Formato:
///
/// ```json
/// "route": { "26": { "slug": "mq-04-belem", "trail": "miqueias",
///   "title": {"pt": "A pequena Belém"}, "insight": {"pt": "…"} } }
/// ```
///
/// Sem rede, vale o último roteiro guardado; sem nada, o do código. Cena que
/// não existe no catálogo é ignorada (o dia fica com a do código).
class SeasonWalkRoutes {
  SeasonWalkRoutes._();
  static final SeasonWalkRoutes instance = SeasonWalkRoutes._();

  static const _prefsKey = 'seasonWalkRoutes.v1';

  final Map<String, Map<int, SeasonDayOverride>> _byCampaign = {};
  bool _cacheRead = false;

  /// Testes: começa vazio.
  @visibleForTesting
  void debugSet(Map<String, Map<int, SeasonDayOverride>> value) {
    _byCampaign
      ..clear()
      ..addAll(value);
    _cacheRead = true;
  }

  /// Aplica as trocas do banco em [days] da campanha [campaignId].
  List<SeasonWalkDay> apply(String campaignId, List<SeasonWalkDay> days) {
    final over = _byCampaign[campaignId];
    if (over == null || over.isEmpty) return days;
    final lang = L10n.current.localeName.split('_').first;
    return [
      for (final d in days)
        if (over[d.index] case final o?) o.apply(d, lang) else d,
    ];
  }

  /// Lê o roteiro guardado (rápido, antes de a rede responder).
  Future<void> loadCache() async {
    if (_cacheRead) return;
    _cacheRead = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;
      _byCampaign.addAll(_decode(jsonDecode(raw)));
    } catch (e) {
      debugPrint('Roteiro da Caminhada: cache $e');
    }
  }

  /// Busca o roteiro de [campaignIds] no banco e guarda. Falha calada.
  Future<void> refresh(Iterable<String> campaignIds) async {
    await loadCache();
    try {
      final db = FirebaseFirestore.instance;
      final known = await _knownSlugs();
      var changed = false;
      for (final id in campaignIds.toSet()) {
        final snap = await db
            .doc('campaigns/$id')
            .get()
            .timeout(const Duration(seconds: 8));
        final days = parseDays(snap.data()?['route'], known: known);
        final before = _byCampaign[id] ?? const {};
        if (!mapEquals(
          before.map((k, v) => MapEntry(k, jsonEncode(v.toMap()))),
          days.map((k, v) => MapEntry(k, jsonEncode(v.toMap()))),
        )) {
          changed = true;
        }
        if (days.isEmpty) {
          _byCampaign.remove(id);
        } else {
          _byCampaign[id] = days;
        }
      }
      if (!changed) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(_encode()));
    } catch (e) {
      debugPrint('Roteiro da Caminhada: banco $e');
    }
  }

  Future<Set<String>?> _knownSlugs() async {
    try {
      final trails = await TrailRepository().getTrails();
      return {
        for (final t in trails)
          for (final m in t.modules)
            for (final s in m.missions) s.slug,
      };
    } catch (_) {
      return null;
    }
  }

  /// `route` do doc da campanha → dia (1..40) → troca. Com [known], descarta
  /// cena que não existe no catálogo.
  static Map<int, SeasonDayOverride> parseDays(
    Object? raw, {
    Set<String>? known,
  }) {
    if (raw is! Map) return const {};
    final out = <int, SeasonDayOverride>{};
    for (final e in raw.entries) {
      final day = int.tryParse('${e.key}');
      if (day == null || day < 1 || day > 40) continue;
      final o = SeasonDayOverride.fromMap(e.value);
      if (o == null) continue;
      if (known != null && !known.contains(o.missionSlug)) continue;
      out[day] = o;
    }
    return out;
  }

  Map<String, Map<int, SeasonDayOverride>> _decode(Object? raw) => {
    if (raw is Map)
      for (final e in raw.entries) '${e.key}': parseDays(e.value),
  };

  Map<String, Object> _encode() => {
    for (final e in _byCampaign.entries)
      e.key: {for (final d in e.value.entries) '${d.key}': d.value.toMap()},
  };
}
