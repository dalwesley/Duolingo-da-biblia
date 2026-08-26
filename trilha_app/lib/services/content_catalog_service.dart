import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/difficulty.dart';
import '../models/trail.dart';

/// Currículo via Firestore + cache em disco.
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
  Directory? _cacheDir;

  Future<void>? _diskJob;
  Future<void>? _refreshJob;
  Completer<void>? _trailsReady;
  bool _refreshInFlight = false;

  List<BankQuestion>? get bankQuestionsCache => _bankQuestions;
  Map<String, Map<String, dynamic>>? get studiesCache => _studies;
  Map<String, String>? get versesCache => _verses;

  bool get _hasTrails => _trails != null && _trails!.isNotEmpty;
  /// Shell = trilhas + dificuldades. Banco de atos é sob demanda por trilha.
  bool get _catalogShellReady =>
      _hasTrails && (_difficulties?.isNotEmpty ?? false);

  void _signalTrails() {
    final gate = _trailsReady;
    if (gate != null && !gate.isCompleted) gate.complete();
  }

  Completer<void> _trailsGate() {
    if (_hasTrails) return Completer<void>()..complete();
    final existing = _trailsReady;
    if (existing != null && !existing.isCompleted) return existing;
    final gate = Completer<void>();
    _trailsReady = gate;
    return gate;
  }

  Future<void> _loadDisk() => _diskJob ??= _loadFromPrefs();

  /// Aguarda Firebase.initializeApp (BackendService) — evita corrida no cold start.
  Future<bool> _waitForFirebase({
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (Firebase.apps.isNotEmpty) return true;
    final deadline = DateTime.now().add(timeout);
    while (Firebase.apps.isEmpty && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
    return Firebase.apps.isNotEmpty;
  }

  Future<void> _kickRefresh({bool force = false}) {
    // Reusa job em voo.
    if (_refreshInFlight && _refreshJob != null) {
      return _refreshJob!;
    }
    // Shell pronto e sem force → só confere versão em background.
    if (!force && _catalogShellReady) {
      return _refreshJob ??= _refreshFromFirestore(force: false);
    }
    // Force OU ainda sem trilhas → refetch do shell.
    if (force || !_hasTrails) {
      _refreshInFlight = true;
      final job = _refreshFromFirestore(force: force || !_hasTrails);
      _refreshJob = job;
      job.whenComplete(() {
        _refreshInFlight = false;
      });
      return job;
    }
    return _refreshJob ??= _refreshFromFirestore(force: false);
  }

  /// Shell (trilhas/dificuldades/estudos). Banco de atos = [ensureTrailBank].
  ///
  /// Se a versão do catálogo mudou, **limpa** banco antigo: misturar atos
  /// pré-seed com o currículo novo quebra a sessão (gestos/palco errados).
  Future<void> ensureLoaded({bool forceRefresh = false}) async {
    await _loadDisk();
    await _kickRefresh(force: forceRefresh);
    _trails ??= const [];
    _bankQuestions ??= const [];
    _difficulties ??= const [];
    _studies ??= const {};
    _verses ??= const {};
  }

  /// Garante perguntas da trilha em memória (pull sob demanda se o banco
  /// completo ainda não chegou). Usado ao abrir uma lição.
  Future<bool> ensureTrailBank(String trailSlug) async {
    if (trailSlug.isEmpty) return false;
    await _loadDisk();
    if (_bankQuestions != null &&
        _bankQuestions!.any((q) => q.trailSlug == trailSlug)) {
      return true;
    }

    final ready = await _waitForFirebase();
    if (!ready) return false;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('content_bank_questions')
          .where('trail', isEqualTo: trailSlug)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 40));
      if (snap.docs.isEmpty) {
        debugPrint('ContentCatalog: trail bank vazio ($trailSlug)');
        return false;
      }
      final collected = snap.docs
          .map((d) => BankQuestion.fromJson({...d.data(), 'id': d.id}))
          .toList();
      final byId = <String, BankQuestion>{
        for (final q in _bankQuestions ?? const <BankQuestion>[]) q.id: q,
        for (final q in collected) q.id: q,
      };
      _bankQuestions = byId.values.toList();
      debugPrint(
        'ContentCatalog: trail $trailSlug +${collected.length} '
        '(banco ${_bankQuestions!.length})',
      );
      unawaited(_persistPrefs());
      return true;
    } catch (e) {
      debugPrint('ContentCatalog ensureTrailBank($trailSlug) failed: $e');
      return false;
    }
  }

  /// Só as trilhas — suficiente para splash/home. Banco segue em background.
  Future<List<Trail>> getTrails({bool forceRefresh = false}) async {
    await _loadDisk();
    if (_hasTrails && !forceRefresh) {
      unawaited(_kickRefresh());
      return List.unmodifiable(_trails!);
    }

    final refresh = _kickRefresh(force: forceRefresh);
    // Libera a Home assim que as trilhas chegarem (banco continua no mesmo job).
    await _trailsGate().future.timeout(
      const Duration(seconds: 20),
      onTimeout: () {},
    );
    if (!_hasTrails) {
      // Gate pode ter sido sinalizado vazio (cache miss) — espera o refresh acabar.
      await refresh.timeout(
        const Duration(seconds: 25),
        onTimeout: () {},
      );
    }
    return List.unmodifiable(_trails ?? const []);
  }

  Future<List<DifficultyMeta>> getDifficulties() async {
    await ensureLoaded();
    final items = List<DifficultyMeta>.from(_difficulties ?? const []);
    // Observação → Compreensão → Interpretação (ordem do enum TrailDifficulty).
    items.sort((a, b) => a.difficulty.index.compareTo(b.difficulty.index));
    return List.unmodifiable(items);
  }

  Future<List<BankQuestion>> getBankQuestions() async {
    await ensureLoaded();
    return List.unmodifiable(_bankQuestions ?? const []);
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

  Future<void> _deleteCacheFile(String name) async {
    try {
      final file = File('${(await _dir()).path}/$name');
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('ContentCatalog delete $name failed: $e');
    }
  }

  /// Descarta banco/estudos/versos locais — currículo novo não mistura com o velho.
  Future<void> _clearBankCaches() async {
    _bankQuestions = [];
    _studies = {};
    _verses = {};
    await Future.wait([
      _deleteCacheFile(_fileBank),
      _deleteCacheFile(_fileStudies),
      _deleteCacheFile(_fileVerses),
    ]);
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
      _signalTrails();

      final bankRaw = await _readCacheFile(_fileBank);
      if (bankRaw != null && bankRaw.isNotEmpty) {
        final data = jsonDecode(bankRaw) as Map<String, dynamic>;
        _difficulties = (data['difficulties'] as List? ?? [])
            .map((e) => DifficultyMeta.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        final rawQs = data['questions'] as List? ?? [];
        final hasTypes = rawQs.any(
          (e) => e is Map && (e['type'] as String?)?.trim().isNotEmpty == true,
        );
        if (!hasTypes && rawQs.isNotEmpty) {
          debugPrint('ContentCatalog: cache sem type — buscando Firestore');
        } else {
          _bankQuestions = rawQs
              .whereType<Map>()
              .map((e) => BankQuestion.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
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
    } finally {
      _signalTrails();
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

  Future<void> _refreshFromFirestore({bool force = false}) async {
    try {
      final ready = await _waitForFirebase();
      if (!ready) {
        debugPrint('ContentCatalog: Firebase ainda não pronto — abort refresh');
        return;
      }

      final db = FirebaseFirestore.instance;
      final meta = await db
          .collection('content_meta')
          .doc('catalog')
          .get()
          .timeout(const Duration(seconds: 6));
      final remoteVersion = (meta.data()?['version'] as num?)?.toInt();

      if (!force &&
          remoteVersion != null &&
          _version != null &&
          remoteVersion == _version &&
          _catalogShellReady) {
        debugPrint('ContentCatalog: cache v$remoteVersion — skip network');
        return;
      }

      final versionChanged =
          force ||
          remoteVersion == null ||
          _version == null ||
          remoteVersion != _version;
      if (versionChanged) {
        debugPrint(
          'ContentCatalog: catálogo novo '
          '(local=$_version remote=$remoteVersion) — '
          'limpa banco antigo; atos sob demanda por trilha',
        );
        await _clearBankCaches();
      }

      final trailsSnap = await db
          .collection('content_trails')
          .get()
          .timeout(const Duration(seconds: 12));
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
        debugPrint('ContentCatalog: trails ${list.length}');
      }
      _signalTrails();

      // Sem pull de 8k atos no boot — isso OOMava o Firestore no aparelho.
      await _pullDifficulties(db);
      await _pullStudies(db);
      await _pullVerses(db);

      if (remoteVersion != null) {
        _version = remoteVersion;
      } else if (meta.exists) {
        _version = DateTime.now().millisecondsSinceEpoch;
      }

      unawaited(_persistPrefs());
    } catch (e) {
      debugPrint('ContentCatalog Firestore refresh failed: $e');
    } finally {
      _signalTrails();
    }
  }

  Future<void> _pullDifficulties(FirebaseFirestore db) async {
    try {
      final diffSnap = await db
          .collection('content_difficulties')
          .get()
          .timeout(const Duration(seconds: 12));
      if (diffSnap.docs.isNotEmpty) {
        _difficulties = diffSnap.docs
            .map((d) => DifficultyMeta.fromJson({...d.data(), 'id': d.id}))
            .toList();
      }
    } catch (e) {
      debugPrint('ContentCatalog difficulties failed: $e');
    }
  }

  Future<void> _pullStudies(FirebaseFirestore db) async {
    try {
      const pageSize = 100;
      final map = <String, Map<String, dynamic>>{};
      QueryDocumentSnapshot<Map<String, dynamic>>? last;
      while (true) {
        Query<Map<String, dynamic>> q = db
            .collection('content_mission_studies')
            .orderBy(FieldPath.documentId)
            .limit(pageSize);
        if (last != null) q = q.startAfterDocument(last);
        final snap = await q
            .get(const GetOptions(source: Source.server))
            .timeout(const Duration(seconds: 25));
        if (snap.docs.isEmpty) break;
        for (final d in snap.docs) {
          map[d.id] = Map<String, dynamic>.from(d.data());
        }
        last = snap.docs.last;
        if (snap.docs.length < pageSize) break;
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      if (map.isNotEmpty) {
        _studies = map;
        debugPrint('ContentCatalog: studies ${map.length}');
      }
    } catch (e) {
      debugPrint('ContentCatalog studies failed: $e');
    }
  }

  Future<void> _pullVerses(FirebaseFirestore db) async {
    try {
      final versesDoc = await db
          .collection('content_meta')
          .doc('verses')
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 20));
      final versesData = versesDoc.data()?['verses'];
      if (versesData is Map) {
        _verses = versesData.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        );
      }
    } catch (e) {
      debugPrint('ContentCatalog verses failed: $e');
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
            'questions': _bankQuestions!.map((q) => q.toJson()).toList(),
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
