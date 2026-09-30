import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'l10n_global.dart';

/// Overlay EN/ES de estudos de missão (context / focus / gloss / prompts).
///
/// `passageText` permanece em PT.
class StudyOverlay {
  StudyOverlay._();

  static final StudyOverlay instance = StudyOverlay._();

  Map<String, Map<String, dynamic>> _bySlug = const {};
  String? _loadedLocale;
  Future<void>? _loadJob;

  Future<void> ensureLoaded() {
    final locale = _normalize(L10n.current.localeName);
    if (locale == 'pt') {
      _clear();
      return Future.value();
    }
    if (_loadedLocale == locale && _bySlug.isNotEmpty) {
      return Future.value();
    }
    return _loadJob ??= _load(locale).whenComplete(() => _loadJob = null);
  }

  Future<void> reloadForLocale(String localeName) {
    final locale = _normalize(localeName);
    if (_loadedLocale == locale) return Future.value();
    _clear();
    if (locale == 'pt') return Future.value();
    return ensureLoaded();
  }

  void _clear() {
    _bySlug = const {};
    _loadedLocale = 'pt';
  }

  Future<void> _load(String locale) async {
    final asset = 'assets/l10n/content/studies_$locale.json';
    try {
      final raw = await rootBundle.loadString(asset);
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        debugPrint('StudyOverlay: $asset não é um objeto JSON');
        return;
      }
      final out = <String, Map<String, dynamic>>{};
      for (final e in decoded.entries) {
        final v = e.value;
        if (v is! Map) continue;
        out[e.key.toString()] = Map<String, dynamic>.from(v);
      }
      _bySlug = out;
      _loadedLocale = locale;
      debugPrint('StudyOverlay: $locale studies=${out.length}');
    } catch (e) {
      debugPrint('StudyOverlay load failed ($asset): $e');
      _clear();
    }
  }

  static String _normalize(String localeName) {
    final code = localeName.split(RegExp(r'[_-]')).first.toLowerCase();
    if (code == 'en' || code == 'es') return code;
    return 'pt';
  }

  void _ensureSyncedLocale() {
    final locale = _normalize(L10n.current.localeName);
    if (locale == _loadedLocale) return;
    if (locale == 'pt') {
      _clear();
      return;
    }
    unawaited(ensureLoaded());
  }

  Map<String, dynamic>? entryFor(String slug) {
    _ensureSyncedLocale();
    return _bySlug[slug];
  }

  String? field(String slug, String key) {
    final e = entryFor(slug);
    if (e == null) return null;
    final v = e[key];
    if (v is! String) return null;
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  List<String>? reflectionPrompts(String slug) {
    final e = entryFor(slug);
    if (e == null) return null;
    final raw = e['reflectionPrompts'];
    if (raw is! List) return null;
    final out = raw
        .map((e) => e.toString().trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return out.isEmpty ? null : out;
  }
}
