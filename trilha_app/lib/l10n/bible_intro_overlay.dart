import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'l10n_global.dart';

/// Overlay EN/ES para intros de livros bíblicos (PT fica no Dart).
class BibleIntroOverlay {
  BibleIntroOverlay._();
  static final BibleIntroOverlay instance = BibleIntroOverlay._();

  Map<String, Map<String, String>> _byAbbrev = const {};
  String? _loadedLocale;
  Future<void>? _loadJob;

  Future<void> ensureLoaded() {
    final locale = _normalize(L10n.current.localeName);
    if (locale == 'pt') {
      _clear();
      return Future.value();
    }
    if (_loadedLocale == locale && _byAbbrev.isNotEmpty) {
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
    _byAbbrev = const {};
    _loadedLocale = 'pt';
  }

  Future<void> _load(String locale) async {
    final asset = 'assets/l10n/content/bible_intros_$locale.json';
    try {
      final raw = await rootBundle.loadString(asset);
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final out = <String, Map<String, String>>{};
      for (final e in decoded.entries) {
        final v = e.value;
        if (v is! Map) continue;
        out[e.key.toString()] = {
          for (final f in v.entries)
            if (f.value != null) f.key.toString(): f.value.toString(),
        };
      }
      _byAbbrev = out;
      _loadedLocale = locale;
      debugPrint('BibleIntroOverlay: $locale books=${out.length}');
    } catch (e) {
      debugPrint('BibleIntroOverlay load failed ($asset): $e');
      _clear();
    }
  }

  static String _normalize(String localeName) {
    final code = localeName.split(RegExp(r'[_-]')).first.toLowerCase();
    if (code == 'en' || code == 'es') return code;
    return 'pt';
  }

  Map<String, String>? fieldsFor(String abbrevKey) {
    final locale = _normalize(L10n.current.localeName);
    if (locale != _loadedLocale) {
      if (locale == 'pt') {
        _clear();
      } else {
        unawaited(ensureLoaded());
      }
    }
    return _byAbbrev[abbrevKey];
  }
}
