import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recognition.dart';
import 'backend_service.dart';

/// Reconhecimentos recebidos e o que este aparelho já enviou.
class RecognitionService extends ChangeNotifier {
  static const _givenKey = 'recognitionGivenIds';
  static const _givenCap = 200;

  final BackendService backend;

  RecognitionService(this.backend);

  List<Recognition> incoming = const [];
  List<Recognition> recent = const [];
  bool recentLoading = false;
  StreamSubscription<List<Recognition>>? _sub;
  String? _boundUid;
  Set<String> _given = {};
  bool _givenLoaded = false;

  bool alreadyGiven({
    required String toUid,
    required RecognitionKind kind,
    required String subjectKey,
  }) {
    final from = backend.uid;
    if (from == null || from.isEmpty) return false;
    return _given.contains(
      Recognition.docId(
        fromUid: from,
        toUid: toUid,
        kind: kind,
        subjectKey: subjectKey,
      ),
    );
  }

  Future<void> bind() async {
    await _loadGiven();
    if (!backend.isActive || backend.uid == null) {
      await _sub?.cancel();
      _sub = null;
      _boundUid = null;
      if (incoming.isNotEmpty || recent.isNotEmpty) {
        incoming = const [];
        recent = const [];
        notifyListeners();
      }
      return;
    }
    final uid = backend.uid!;
    if (_boundUid == uid && _sub != null) {
      unawaited(refreshRecent());
      return;
    }
    await _sub?.cancel();
    _boundUid = uid;
    _sub = backend.watchIncomingRecognitions().listen(
      (list) {
        incoming = list;
        notifyListeners();
      },
      onError: (Object e) {
        debugPrint('Falha ao ouvir reconhecimentos: $e');
      },
    );
    unawaited(refreshRecent());
  }

  Future<void> refreshRecent() async {
    if (!backend.isActive) {
      recent = const [];
      recentLoading = false;
      notifyListeners();
      return;
    }
    recentLoading = true;
    notifyListeners();
    try {
      recent = await backend.fetchRecentRecognitions();
    } catch (e) {
      debugPrint('Falha ao carregar histórico de reconhecimentos: $e');
    } finally {
      recentLoading = false;
      notifyListeners();
    }
  }

  Future<RecognitionGiveStatus> give({
    required String toUid,
    required String fromName,
    required RecognitionKind kind,
    required String subjectKey,
  }) async {
    final from = backend.uid;
    if (from == null || from.isEmpty || from == toUid) {
      return RecognitionGiveStatus.failed;
    }
    if (!Recognition.validSubject(kind, subjectKey)) {
      return RecognitionGiveStatus.failed;
    }
    final id = Recognition.docId(
      fromUid: from,
      toUid: toUid,
      kind: kind,
      subjectKey: subjectKey,
    );
    if (_given.contains(id)) {
      final ok = await backend.revokeRecognition(
        toUid: toUid,
        kind: kind,
        subjectKey: subjectKey,
      );
      if (!ok) return RecognitionGiveStatus.failed;
      await _forget(id);
      return RecognitionGiveStatus.removed;
    }

    final status = await backend.giveRecognition(
      toUid: toUid,
      fromName: recognitionFromName(fromName),
      kind: kind,
      subjectKey: subjectKey,
    );
    if (status == RecognitionGiveStatus.given ||
        status == RecognitionGiveStatus.already) {
      await _remember(id);
    }
    return status;
  }

  Future<void> acknowledgeIncoming() async {
    final ids = [for (final item in incoming) item.id];
    if (ids.isEmpty) return;
    final ok = await backend.acknowledgeRecognitions(ids);
    if (!ok) return;
    // Mantém o que acabou de receber no topo do histórico local.
    final merged = <String, Recognition>{
      for (final item in [...incoming, ...recent]) item.id: item,
    };
    recent = merged.values.toList()
      ..sort((a, b) {
        final ad = a.createdAt;
        final bd = b.createdAt;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
    incoming = const [];
    notifyListeners();
    unawaited(refreshRecent());
  }

  Future<void> _loadGiven() async {
    if (_givenLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    _given = (prefs.getStringList(_givenKey) ?? const []).toSet();
    _givenLoaded = true;
  }

  Future<void> _remember(String id) async {
    if (!_given.add(id)) return;
    final list = _given.toList();
    final capped = list.length > _givenCap
        ? list.sublist(list.length - _givenCap)
        : list;
    _given = capped.toSet();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_givenKey, capped);
    notifyListeners();
  }

  Future<void> _forget(String id) async {
    if (!_given.remove(id)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_givenKey, _given.toList());
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    super.dispose();
  }
}
