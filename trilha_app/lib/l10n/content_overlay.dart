import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'l10n_global.dart';

/// Overlay de metadados de trilhas/missões por idioma (EN/ES).
///
/// Fonte PT continua no Firestore / [Trail.fromJson]. Este overlay só
/// sobrescreve strings de UI quando o locale não é `pt`.
class ContentOverlay {
  ContentOverlay._();

  static final ContentOverlay instance = ContentOverlay._();

  Map<String, Map<String, String>> _trails = const {};
  Map<String, Map<String, String>> _modules = const {};
  Map<String, Map<String, String>> _missions = const {};
  String? _loadedLocale;
  Future<void>? _loadJob;

  /// Carrega (ou recarrega) o JSON do locale atual. Idempotente.
  Future<void> ensureLoaded() {
    final locale = _normalize(L10n.current.localeName);
    if (locale == 'pt') {
      _clear();
      return Future.value();
    }
    if (_loadedLocale == locale && _trails.isNotEmpty) {
      return Future.value();
    }
    return _loadJob ??= _load(locale).whenComplete(() => _loadJob = null);
  }

  /// Força reload quando o idioma muda (MaterialApp / Ajustes).
  Future<void> reloadForLocale(String localeName) {
    final locale = _normalize(localeName);
    if (_loadedLocale == locale) return Future.value();
    _clear();
    if (locale == 'pt') return Future.value();
    return ensureLoaded();
  }

  void _clear() {
    _trails = const {};
    _modules = const {};
    _missions = const {};
    _loadedLocale = 'pt';
  }

  Future<void> _load(String locale) async {
    final asset = 'assets/l10n/content/trails_$locale.json';
    try {
      final raw = await rootBundle.loadString(asset);
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        debugPrint('ContentOverlay: $asset não é um objeto JSON');
        return;
      }
      final map = Map<String, dynamic>.from(decoded);
      _trails = _stringMapMap(map['trails']);
      _modules = _stringMapMap(map['modules']);
      _missions = _stringMapMap(map['missions']);
      _loadedLocale = locale;
      debugPrint(
        'ContentOverlay: $locale '
        'trails=${_trails.length} modules=${_modules.length} '
        'missions=${_missions.length}',
      );
    } catch (e) {
      debugPrint('ContentOverlay load failed ($asset): $e');
      _clear();
    }
  }

  static Map<String, Map<String, String>> _stringMapMap(Object? raw) {
    if (raw is! Map) return const {};
    final out = <String, Map<String, String>>{};
    for (final e in raw.entries) {
      final v = e.value;
      if (v is! Map) continue;
      out[e.key.toString()] = {
        for (final f in v.entries)
          if (f.value != null) f.key.toString(): f.value.toString(),
      };
    }
    return out;
  }

  static String _normalize(String localeName) {
    final code = localeName.split(RegExp(r'[_-]')).first.toLowerCase();
    if (code == 'en' || code == 'es') return code;
    return 'pt';
  }

  String? trailField(String slug, String field) {
    _ensureSyncedLocale();
    final v = _trails[slug]?[field];
    if (v == null || v.trim().isEmpty) return null;
    return v;
  }

  String? missionField(String missionSlug, String field) {
    _ensureSyncedLocale();
    final v = _missions[missionSlug]?[field];
    if (v == null || v.trim().isEmpty) return null;
    return v;
  }

  String? moduleTitle(String trailSlug, int moduleIndex) {
    _ensureSyncedLocale();
    final v = _modules['$trailSlug:$moduleIndex']?['title'];
    if (v == null || v.trim().isEmpty) return null;
    return v;
  }

  /// Se o locale mudou depois do load (ex.: Ajustes), limpa/recarrega sync
  /// no próximo ensureLoaded; getters caem no PT até o reload terminar.
  void _ensureSyncedLocale() {
    final locale = _normalize(L10n.current.localeName);
    if (locale == _loadedLocale) return;
    if (locale == 'pt') {
      _clear();
      return;
    }
    // Dispara reload em background; getters usam PT até chegar.
    unawaited(ensureLoaded());
  }
}
