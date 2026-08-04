import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/difficulty.dart';
import '../models/trail.dart';

/// Carrega currículo (trilhas, banco, estudos) só do Firestore, com cache em disco.
/// Sem assets empacotados: novas trilhas/cenas/perguntas não exigem update do app.
/// Primeira abertura (ou cache vazio) precisa de rede.
class ContentCatalogService {
  ContentCatalogService._();
  static final ContentCatalogService instance = ContentCatalogService._();

  static const _prefsVersionKey = 'content_catalog_version';
  static const _fileTrails = 'content_trails.json';
  static const _fileBank = 'content_bank.json';
  static const _fileStudies = 'content_studies.json';
  static const _fileVerses = 'content_verses.json';

  // Legado SharedPreferences (migrado uma vez e apagado).
  static const _legacyTrailsKey = 'content_trails_json';
  static const _legacyBankKey = 'content_bank_json';
  static const _legacyStudiesKey = 'content_studies_json';
  static const _legacyVersesKey = 'content_verses_json';

  List<Trail>? _trails;
  List<DifficultyMeta>? _difficulties;
  List<BankQuestion>? _bankQuestions;
  Map<String, Map<String, dynamic>>? _studies;
  Map<String, String>? _verses;
  int? _version;
  bool _loading = false;
  Directory? _cacheDir;

  List<Trail>? get trailsCache => _trails;
  List<DifficultyMeta>? get difficultiesCache => _difficulties;
  List<BankQuestion>? get bankQuestionsCache => _bankQuestions;
  Map<String, Map<String, dynamic>>? get studiesCache => _studies;
  Map<String, String>? get versesCache => _verses;

  /// True quando ainda não há currículo em memória nem (após load) em cache/nuvem.
  bool get hasCurriculum =>
      _trails != null &&
      _trails!.isNotEmpty &&
      _bankQuestions != null &&
      _studies != null;

  Future<void> ensureLoaded({bool forceRefresh = false}) async {
    if (_loading) {
      while (_loading) {
        await Future<void>.delayed(const Duration(milliseconds: 40));
      }
      return;
    }
    if (!forceRefresh &&
        _trails != null &&
        _bankQuestions != null &&
        _studies != null) {
      return;
    }

    _loading = true;
    try {
      await _loadFromPrefs();
      await _refreshFromFirestore();
      _trails ??= const [];
      _bankQuestions ??= const [];
      _difficulties ??= const [];
      _studies ??= const {};
      _verses ??= const {};
    } finally {
      _loading = false;
    }
  }

  Future<List<Trail>> getTrails({bool forceRefresh = false}) async {
    await ensureLoaded(forceRefresh: forceRefresh);
    return List.unmodifiable(_trails ?? const []);
  }

  Future<List<DifficultyMeta>> getDifficulties() async {
    await ensureLoaded();
    final items = List<DifficultyMeta>.from(_difficulties ?? const []);
    // Semente → Rota → Profundezas (ordem do enum TrailDifficulty).
    items.sort((a, b) => a.difficulty.index.compareTo(b.difficulty.index));
    return List.unmodifiable(items);
  }

  Future<List<BankQuestion>> getBankQuestions() async {
    await ensureLoaded();
    return List.unmodifiable(_bankQuestions ?? const []);
  }

  Future<Map<String, dynamic>?> getStudy(String slug) async {
    await ensureLoaded();
    return _studies?[slug];
  }

  Future<String?> verseText(String? ref) async {
    await ensureLoaded();
    if (ref == null || ref.trim().isEmpty) return null;
    final verses = _verses;
    if (verses == null || verses.isEmpty) return null;

    String norm(String s) => s
        .trim()
        .toLowerCase()
        .replaceAll('ê', 'e')
        .replaceAll('é', 'e')
        .replaceAll('á', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ô', 'o')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'\s+'), ' ');

    final compact = norm(ref);
    for (final e in verses.entries) {
      final ek = norm(e.key);
      if (compact.contains(ek) || ek.contains(compact)) return e.value;
    }
    return null;
  }

  Future<Directory> _dir() async {
    if (_cacheDir != null) return _cacheDir!;
    final root = await getApplicationSupportDirectory();
    final dir = Directory('${root.path}/content_catalog');
    if (!await dir.exists()) await dir.create(recursive: true);
    _cacheDir = dir;
    return dir;
  }

  Future<String?> _readCacheFile(String name) async {
    try {
      final file = File('${(await _dir()).path}/$name');
      if (!await file.exists()) return null;
      return file.readAsString();
    } catch (e) {
      debugPrint('ContentCatalog read $name failed: $e');
      return null;
    }
  }

  Future<void> _writeCacheFile(String name, String contents) async {
    try {
      final file = File('${(await _dir()).path}/$name');
      await file.writeAsString(contents, flush: true);
    } catch (e) {
      debugPrint('ContentCatalog write $name failed: $e');
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _version = prefs.getInt(_prefsVersionKey);

      // Migração one-shot: prefs antigos → disco (evita SharedPreferences >1–2MB).
      await _migrateLegacyPrefs(prefs);

      final trailsRaw = await _readCacheFile(_fileTrails);
      if (trailsRaw != null && trailsRaw.isNotEmpty) {
        final list = jsonDecode(trailsRaw) as List;
        _trails = list
            .map((e) => Trail.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
      }
      final bankRaw = await _readCacheFile(_fileBank);
      if (bankRaw != null && bankRaw.isNotEmpty) {
        final data = jsonDecode(bankRaw) as Map<String, dynamic>;
        _difficulties = (data['difficulties'] as List? ?? [])
            .map((e) => DifficultyMeta.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        _bankQuestions = (data['questions'] as List? ?? [])
            .map((e) => BankQuestion.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      final studiesRaw = await _readCacheFile(_fileStudies);
      if (studiesRaw != null && studiesRaw.isNotEmpty) {
        final map = jsonDecode(studiesRaw) as Map<String, dynamic>;
        _studies = map.map(
          (k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)),
        );
      }
      final versesRaw = await _readCacheFile(_fileVerses);
      if (versesRaw != null && versesRaw.isNotEmpty) {
        final map = jsonDecode(versesRaw) as Map<String, dynamic>;
        _verses = map.map((k, v) => MapEntry(k, v as String));
      }
    } catch (e) {
      debugPrint('ContentCatalog cache load failed: $e');
    }
  }

  Future<void> _migrateLegacyPrefs(SharedPreferences prefs) async {
    try {
      final trails = prefs.getString(_legacyTrailsKey);
      final bank = prefs.getString(_legacyBankKey);
      final studies = prefs.getString(_legacyStudiesKey);
      final verses = prefs.getString(_legacyVersesKey);
      if (trails == null && bank == null && studies == null && verses == null) {
        return;
      }
      if (trails != null) await _writeCacheFile(_fileTrails, trails);
      if (bank != null) await _writeCacheFile(_fileBank, bank);
      if (studies != null) await _writeCacheFile(_fileStudies, studies);
      if (verses != null) await _writeCacheFile(_fileVerses, verses);
      await prefs.remove(_legacyTrailsKey);
      await prefs.remove(_legacyBankKey);
      await prefs.remove(_legacyStudiesKey);
      await prefs.remove(_legacyVersesKey);
      debugPrint('ContentCatalog migrated prefs → disk cache');
    } catch (e) {
      debugPrint('ContentCatalog prefs migration failed: $e');
    }
  }

  Future<void> _refreshFromFirestore() async {
    try {
      final db = FirebaseFirestore.instance;
      final meta = await db.collection('content_meta').doc('catalog').get();
      final remoteVersion = (meta.data()?['version'] as num?)?.toInt();

      if (remoteVersion != null &&
          _version != null &&
          remoteVersion == _version &&
          _trails != null &&
          _trails!.isNotEmpty &&
          _bankQuestions != null &&
          _bankQuestions!.isNotEmpty &&
          _studies != null &&
          _studies!.isNotEmpty) {
        return;
      }

      final trailsSnap = await db.collection('content_trails').get();
      if (trailsSnap.docs.isNotEmpty) {
        final list = trailsSnap.docs.map((d) {
          final data = Map<String, dynamic>.from(d.data());
          data['slug'] ??= d.id;
          data['realm'] ??= data['realmId'];
          data['category'] ??= data['categoryId'];
          return Trail.fromJson(data);
        }).toList()
          ..sort((a, b) => a.order.compareTo(b.order));
        _trails = list;
      }

      final diffSnap = await db.collection('content_difficulties').get();
      if (diffSnap.docs.isNotEmpty) {
        _difficulties = diffSnap.docs
            .map((d) => DifficultyMeta.fromJson({...d.data(), 'id': d.id}))
            .toList();
      }

      final bankSnap = await db.collection('content_bank_questions').get();
      if (bankSnap.docs.isNotEmpty) {
        _bankQuestions = bankSnap.docs
            .map((d) => BankQuestion.fromJson({...d.data(), 'id': d.id}))
            .toList();
      }

      final studiesSnap = await db.collection('content_mission_studies').get();
      if (studiesSnap.docs.isNotEmpty) {
        _studies = {
          for (final d in studiesSnap.docs)
            d.id: Map<String, dynamic>.from(d.data()),
        };
      }

      final versesDoc = await db.collection('content_meta').doc('verses').get();
      final versesData = versesDoc.data()?['verses'];
      if (versesData is Map) {
        _verses = versesData.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        );
      }

      if (remoteVersion != null) {
        _version = remoteVersion;
      } else if (meta.exists) {
        _version = DateTime.now().millisecondsSinceEpoch;
      }

      await _persistPrefs();
    } catch (e) {
      debugPrint('ContentCatalog Firestore refresh failed: $e');
    }
  }

  Future<void> _persistPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_version != null) await prefs.setInt(_prefsVersionKey, _version!);
      if (_trails != null) {
        final encoded = jsonEncode(
          _trails!
              .map(
                (t) => {
                  'slug': t.slug,
                  'title': t.title,
                  'description': t.description,
                  'icon': t.icon,
                  'order': t.order,
                  'unlockAfter': t.unlockAfter,
                  'comingSoon': t.comingSoon,
                  'color': t.color,
                  'realm': t.realmId,
                  'category': t.categoryId,
                  'modules': t.modules
                      .map(
                        (m) => {
                          'title': m.title,
                          'icon': m.icon,
                          'section': m.section,
                          'missions': m.missions
                              .map(
                                (ms) => {
                                  'slug': ms.slug,
                                  'title': ms.title,
                                  'subtitle': ms.subtitle,
                                  'intro': ms.intro,
                                  'type': ms.type,
                                  'xpReward': ms.stepsReward,
                                  'questions': ms.questions
                                      .map(
                                        (q) => {
                                          'question': q.question,
                                          'options': q.options
                                              .map(
                                                (o) => {
                                                  'id': o.id,
                                                  'text': o.text,
                                                },
                                              )
                                              .toList(),
                                          'correctOptionId': q.correctOptionId,
                                          'feedbackCorrect': q.feedbackCorrect,
                                          'feedbackWrong': q.feedbackWrong,
                                          'verseRef': q.verseRef,
                                        },
                                      )
                                      .toList(),
                                },
                              )
                              .toList(),
                        },
                      )
                      .toList(),
                },
              )
              .toList(),
        );
        await _writeCacheFile(_fileTrails, encoded);
      }
      if (_bankQuestions != null) {
        await _writeCacheFile(
          _fileBank,
          jsonEncode({
            'difficulties': (_difficulties ?? [])
                .map(
                  (d) => {
                    'id': d.difficulty.id,
                    'label': d.label,
                    'subtitle': d.subtitle,
                    'description': d.description,
                    'xpMultiplier': d.stepsMultiplier,
                    'accent': d.accent,
                    'icon': d.icon,
                  },
                )
                .toList(),
            'questions': _bankQuestions!
                .map(
                  (q) => {
                    'id': q.id,
                    'trail': q.trailSlug,
                    'difficulty': q.difficulty.id,
                    'section': q.section,
                    'question': q.question,
                    'options': q.options
                        .map((o) => {'id': o.id, 'text': o.text})
                        .toList(),
                    'correctOptionId': q.correctOptionId,
                    'feedbackCorrect': q.feedbackCorrect,
                    'feedbackWrong': q.feedbackWrong,
                    'verseRef': q.verseRef,
                    'reveal': q.reveal,
                  },
                )
                .toList(),
          }),
        );
      }
      if (_studies != null) {
        await _writeCacheFile(_fileStudies, jsonEncode(_studies));
      }
      if (_verses != null) {
        await _writeCacheFile(_fileVerses, jsonEncode(_verses));
      }
    } catch (e) {
      debugPrint('ContentCatalog cache persist failed: $e');
    }
  }
}
