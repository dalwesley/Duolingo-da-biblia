import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'l10n_global.dart';

/// Overlay EN/ES de enunciados/feedback/opções do banco de perguntas.
///
/// PT continua em `assets/data/*_questions.json` / Firestore. Este overlay
/// só sobrescreve strings pedagógicas quando o locale não é `pt`.
/// Não cobre `passageText`, `verseRef`, `evidence`, nem tokens do versículo.
class QuestionOverlay {
  QuestionOverlay._();

  static final QuestionOverlay instance = QuestionOverlay._();

  Map<String, Map<String, dynamic>> _byId = const {};
  String? _loadedLocale;
  Future<void>? _loadJob;

  Future<void> ensureLoaded() {
    final locale = _normalize(L10n.current.localeName);
    if (locale == 'pt') {
      _clear();
      return Future.value();
    }
    if (_loadedLocale == locale && _byId.isNotEmpty) {
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
    _byId = const {};
    _loadedLocale = 'pt';
  }

  Future<void> _load(String locale) async {
    final asset = 'assets/l10n/content/questions_$locale.json';
    try {
      // Decode e mapa fora da UI thread; sem cache do texto cru no bundle.
      final raw = await rootBundle.loadString(asset, cache: false);
      final out = await compute(_decodeEntries, raw);
      if (out == null) {
        debugPrint('QuestionOverlay: $asset não é um objeto JSON');
        return;
      }
      _byId = out;
      _loadedLocale = locale;
      debugPrint('QuestionOverlay: $locale questions=${out.length}');
    } catch (e) {
      debugPrint('QuestionOverlay load failed ($asset): $e');
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

  /// Labels V/F localizados (não dependem do JSON por pergunta).
  String get trueLabel {
    switch (_normalize(L10n.current.localeName)) {
      case 'en':
        return 'True';
      case 'es':
        return 'Verdadero';
      default:
        return 'Verdadeiro';
    }
  }

  String get falseLabel {
    switch (_normalize(L10n.current.localeName)) {
      case 'en':
        return 'False';
      case 'es':
        return 'Falso';
      default:
        return 'Falso';
    }
  }

  Map<String, dynamic>? entryFor(String id) {
    _ensureSyncedLocale();
    return _byId[id];
  }

  String? field(String id, String key) {
    final e = entryFor(id);
    if (e == null) return null;
    final v = e[key];
    if (v is! String) return null;
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  /// Prompt pedagógico: `prompt` → `question` → null.
  String? promptFor(String id) =>
      field(id, 'prompt') ?? field(id, 'question');

  String? cueFor(String id) =>
      field(id, 'cue') ?? field(id, 'prompt') ?? field(id, 'question');

  String? optionText(String id, String optionId) {
    final e = entryFor(id);
    if (e == null) return null;
    final opts = e['options'];
    if (opts is! Map) return null;
    final v = opts[optionId];
    if (v == null) return null;
    final t = v.toString().trim();
    return t.isEmpty ? null : t;
  }

  Map<String, String>? feedbackWrongFor(String id) {
    final e = entryFor(id);
    if (e == null) return null;
    final raw = e['feedbackWrong'];
    if (raw is! Map) return null;
    final out = <String, String>{};
    for (final entry in raw.entries) {
      final t = entry.value?.toString().trim() ?? '';
      if (t.isNotEmpty) out[entry.key.toString()] = t;
    }
    return out.isEmpty ? null : out;
  }
}

Map<String, Map<String, dynamic>>? _decodeEntries(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! Map) return null;
  final out = <String, Map<String, dynamic>>{};
  for (final e in decoded.entries) {
    final v = e.value;
    if (v is! Map) continue;
    out[e.key.toString()] = Map<String, dynamic>.from(v);
  }
  return out;
}
