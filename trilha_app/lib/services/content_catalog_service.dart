import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/difficulty.dart';
import '../models/trail.dart';

/// Carrega currículo (trilhas, banco, estudos) do Firestore com cache local
/// e fallback para assets empacotados — assim novas trilhas não exigem update do app.
class ContentCatalogService {
  ContentCatalogService._();
  static final ContentCatalogService instance = ContentCatalogService._();

  static const _prefsVersionKey = 'content_catalog_version';
  static const _prefsTrailsKey = 'content_trails_json';
  static const _prefsBankKey = 'content_bank_json';
  static const _prefsStudiesKey = 'content_studies_json';
  static const _prefsVersesKey = 'content_verses_json';

  List<Trail>? _trails;
  List<DifficultyMeta>? _difficulties;
  List<BankQuestion>? _bankQuestions;
  Map<String, Map<String, dynamic>>? _studies;
  Map<String, String>? _verses;
  int? _version;
  bool _loading = false;

  List<Trail>? get trailsCache => _trails;
  List<DifficultyMeta>? get difficultiesCache => _difficulties;
  List<BankQuestion>? get bankQuestionsCache => _bankQuestions;
  Map<String, Map<String, dynamic>>? get studiesCache => _studies;
  Map<String, String>? get versesCache => _verses;

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
      if (_trails == null || _trails!.isEmpty) {
        await _loadTrailsFromAsset();
      }
      if (_bankQuestions == null || _bankQuestions!.isEmpty) {
        await _loadBankFromAsset();
      }
      if (_studies == null || _studies!.isEmpty) {
        await _loadStudiesFromAsset();
      }
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
    return List.unmodifiable(_difficulties ?? const []);
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

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _version = prefs.getInt(_prefsVersionKey);
      final trailsRaw = prefs.getString(_prefsTrailsKey);
      if (trailsRaw != null && trailsRaw.isNotEmpty) {
        final list = jsonDecode(trailsRaw) as List;
        _trails = list
            .map((e) => Trail.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
      }
      final bankRaw = prefs.getString(_prefsBankKey);
      if (bankRaw != null && bankRaw.isNotEmpty) {
        final data = jsonDecode(bankRaw) as Map<String, dynamic>;
        _difficulties = (data['difficulties'] as List? ?? [])
            .map((e) => DifficultyMeta.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        _bankQuestions = (data['questions'] as List? ?? [])
            .map((e) => BankQuestion.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      final studiesRaw = prefs.getString(_prefsStudiesKey);
      if (studiesRaw != null && studiesRaw.isNotEmpty) {
        final map = jsonDecode(studiesRaw) as Map<String, dynamic>;
        _studies = map.map(
          (k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)),
        );
      }
      final versesRaw = prefs.getString(_prefsVersesKey);
      if (versesRaw != null && versesRaw.isNotEmpty) {
        final map = jsonDecode(versesRaw) as Map<String, dynamic>;
        _verses = map.map((k, v) => MapEntry(k, v as String));
      }
    } catch (e) {
      debugPrint('ContentCatalog prefs load failed: $e');
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
          _bankQuestions!.isNotEmpty) {
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
      final bankSnap = await db.collection('content_bank_questions').get();
      if (bankSnap.docs.isNotEmpty) {
        _difficulties = diffSnap.docs
            .map((d) => DifficultyMeta.fromJson({...d.data(), 'id': d.id}))
            .toList();
        _bankQuestions = bankSnap.docs
            .map((d) => BankQuestion.fromJson({...d.data(), 'id': d.id}))
            .toList();
        await _mergeMissingTrailBanksFromAssets();
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
        await prefs.setString(_prefsTrailsKey, encoded);
      }
      if (_bankQuestions != null) {
        await prefs.setString(
          _prefsBankKey,
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
        await prefs.setString(_prefsStudiesKey, jsonEncode(_studies));
      }
      if (_verses != null) {
        await prefs.setString(_prefsVersesKey, jsonEncode(_verses));
      }
    } catch (e) {
      debugPrint('ContentCatalog prefs persist failed: $e');
    }
  }

  Future<void> _loadTrailsFromAsset() async {
    final raw = await rootBundle.loadString('assets/data/trails.json');
    final list = jsonDecode(raw) as List;
    _trails = list.map((e) => Trail.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<void> _loadBankFromAsset() async {
    final genesisRaw =
        await rootBundle.loadString('assets/data/genesis_questions.json');
    final genesis = jsonDecode(genesisRaw) as Map<String, dynamic>;
    _difficulties = (genesis['difficulties'] as List)
        .map((e) => DifficultyMeta.fromJson(e as Map<String, dynamic>))
        .toList();

    final questions = <BankQuestion>[];
    void addQuestions(Map<String, dynamic> data, String defaultTrail) {
      for (final e in data['questions'] as List? ?? const []) {
        final map = Map<String, dynamic>.from(e as Map);
        map['trail'] ??= map['trailSlug'] ?? defaultTrail;
        questions.add(BankQuestion.fromJson(map));
      }
    }

    addQuestions(genesis, 'genesis-1-11');

    try {
      final exodoRaw =
          await rootBundle.loadString('assets/data/exodo_questions.json');
      final exodo = jsonDecode(exodoRaw) as Map<String, dynamic>;
      addQuestions(exodo, 'exodo');
    } catch (e) {
      debugPrint('ContentCatalog exodo bank missing: $e');
    }

    try {
      final otRaw =
          await rootBundle.loadString('assets/data/ot_questions.json');
      final ot = jsonDecode(otRaw) as Map<String, dynamic>;
      for (final e in ot['questions'] as List? ?? const []) {
        final map = Map<String, dynamic>.from(e as Map);
        final trail = map['trail'] as String? ?? map['trailSlug'] as String?;
        if (trail != null) map['trail'] = trail;
        questions.add(BankQuestion.fromJson(map));
      }
    } catch (e) {
      debugPrint('ContentCatalog OT bank missing: $e');
    }

    _bankQuestions = questions;
  }

  /// Se o Firestore só tem Gênesis, ainda assim carrega Êxodo (e futuros) dos assets.
  Future<void> _mergeMissingTrailBanksFromAssets() async {
    final current = _bankQuestions ?? [];
    final haveTrails = current.map((q) => q.trailSlug).toSet();
    final existingIds = current.map((q) => q.id).toSet();
    final merged = [...current];

    Future<void> mergeFile(String assetPath, String trail) async {
      if (haveTrails.contains(trail)) return;
      try {
        final raw = await rootBundle.loadString(assetPath);
        final data = jsonDecode(raw) as Map<String, dynamic>;
        for (final e in data['questions'] as List? ?? const []) {
          final map = Map<String, dynamic>.from(e as Map);
          map['trail'] ??= trail;
          final q = BankQuestion.fromJson(map);
          if (existingIds.contains(q.id)) continue;
          merged.add(q);
          existingIds.add(q.id);
        }
        haveTrails.add(trail);
      } catch (e) {
        debugPrint('ContentCatalog merge $trail failed: $e');
      }
    }

    await mergeFile('assets/data/exodo_questions.json', 'exodo');

    try {
      final raw = await rootBundle.loadString('assets/data/ot_questions.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      for (final e in data['questions'] as List? ?? const []) {
        final map = Map<String, dynamic>.from(e as Map);
        final q = BankQuestion.fromJson(map);
        if (haveTrails.contains(q.trailSlug) || existingIds.contains(q.id)) {
          continue;
        }
        merged.add(q);
        existingIds.add(q.id);
      }
      for (final q in merged) {
        haveTrails.add(q.trailSlug);
      }
    } catch (e) {
      debugPrint('ContentCatalog merge OT bank failed: $e');
    }

    _bankQuestions = merged;
  }

  Future<void> _loadStudiesFromAsset() async {
    try {
      final raw = await rootBundle.loadString('assets/data/mission_studies.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final studies = data['studies'] as Map<String, dynamic>? ?? {};
      _studies = studies.map(
        (k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)),
      );
      final verses = data['verses'] as Map<String, dynamic>? ?? {};
      _verses = verses.map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      // asset opcional enquanto migra
    }
  }
}
