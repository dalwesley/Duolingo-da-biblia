import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/corner_challenge.dart';
import 'analytics_service.dart';
import 'backend_service.dart';
import 'progress_service.dart';

/// Desafio de cena na Caravana — uma esquina por pessoa por semana.
class CornerService extends ChangeNotifier {
  CornerService(this.backend);

  final BackendService backend;

  List<CornerChallenge> mine = const [];
  bool loading = false;
  String? lastError;
  bool _cloudSynced = false;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  bool get cloudSynced => _cloudSynced;

  void markCloudUnsynced() {
    _cloudSynced = false;
    mine = const [];
    lastError = null;
    notifyListeners();
  }

  Future<void> init() async {
    await refresh();
    _loaded = true;
    notifyListeners();
  }

  String? get _uid => backend.uid;

  CornerChallenge? get homeCard {
    final uid = _uid;
    if (uid == null) return null;
    return CornerHomePick.of(mine, uid);
  }

  CornerRecord get record {
    final uid = _uid;
    if (uid == null) return const CornerRecord.empty();
    return CornerRecord.of(mine, uid);
  }

  CornerChallenge? withPeer(String uid) {
    for (final c in mine) {
      if (c.involves(uid) && (c.isOpen || c.bothDone || c.isThisWeek)) {
        return c;
      }
    }
    return null;
  }

  bool opensMission(String missionSlug) {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return false;
    return CornerChallenge.authorizes(missionSlug, uid, mine);
  }

  bool get hasOpenThisWeek {
    for (final c in mine) {
      if (c.isOpen) return true;
    }
    return false;
  }

  Future<void> refresh() async {
    if (!backend.isActive) {
      mine = const [];
      _cloudSynced = false;
      notifyListeners();
      return;
    }
    loading = true;
    notifyListeners();
    try {
      final uid = _uid!;
      final snap = await FirebaseFirestore.instance
          .collection('corners')
          .where('participantIds', arrayContains: uid)
          .get();
      mine = [
        for (final doc in snap.docs) _fromDoc(doc),
      ];
      lastError = null;
      _cloudSynced = true;
    } catch (e) {
      debugPrint('CornerService.refresh: $e');
      lastError = null;
    } finally {
      loading = false;
      _loaded = true;
      notifyListeners();
    }
  }

  Future<CornerChallenge?> propose({
    required String opponentId,
    required String opponentName,
    required String myName,
    required CornerProposal proposal,
  }) async {
    lastError = null;
    final uid = _uid;
    if (!backend.isActive || uid == null) {
      lastError = CornerCopy.needsCloud;
      notifyListeners();
      return null;
    }
    if (opponentId.isEmpty || opponentId == uid) {
      lastError = CornerCopy.sendFailed;
      notifyListeners();
      return null;
    }
    if (hasOpenThisWeek && !CornerMatch.forceOpenForPreview) {
      lastError = CornerCopy.busyWeek;
      notifyListeners();
      return null;
    }
    try {
      final ref = FirebaseFirestore.instance.collection('corners').doc();
      final weekStart = cornerWeekStart();
      await ref.set({
        'challengerId': uid,
        'challengerName': myName,
        'opponentId': opponentId,
        'opponentName': opponentName,
        'participantIds': [uid, opponentId],
        'trailSlug': proposal.trailSlug,
        'trailTitle': proposal.trailTitle,
        'missionSlug': proposal.missionSlug,
        'missionTitle': proposal.missionTitle,
        'moduleTitle': proposal.moduleTitle,
        'weekStart': weekStart,
        'status': CornerStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      final created = CornerChallenge(
        id: ref.id,
        challengerId: uid,
        challengerName: myName,
        opponentId: opponentId,
        opponentName: opponentName,
        trailSlug: proposal.trailSlug,
        trailTitle: proposal.trailTitle,
        missionSlug: proposal.missionSlug,
        missionTitle: proposal.missionTitle,
        moduleTitle: proposal.moduleTitle,
        weekStart: weekStart,
        status: CornerStatus.pending,
      );
      mine = [...mine, created];
      notifyListeners();
      unawaited(
        AnalyticsService.instance.logEvent('corner_propose', {
          'trail_slug': proposal.trailSlug,
          'mission_slug': proposal.missionSlug,
        }),
      );
      return created;
    } catch (e) {
      debugPrint('CornerService.propose: $e');
      lastError = CornerCopy.sendFailed;
      notifyListeners();
      return null;
    }
  }

  Future<bool> accept(String id) async {
    return _setStatus(id, status: CornerStatus.active, event: 'corner_accept');
  }

  Future<bool> decline(String id) async {
    return _setStatus(
      id,
      status: CornerStatus.declined,
      event: 'corner_decline',
    );
  }

  Future<bool> _setStatus(
    String id, {
    required CornerStatus status,
    required String event,
  }) async {
    lastError = null;
    final uid = _uid;
    if (!backend.isActive || uid == null) return false;
    try {
      await FirebaseFirestore.instance.doc('corners/$id').set({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      mine = [
        for (final c in mine)
          if (c.id == id)
            CornerChallenge(
              id: c.id,
              challengerId: c.challengerId,
              challengerName: c.challengerName,
              opponentId: c.opponentId,
              opponentName: c.opponentName,
              trailSlug: c.trailSlug,
              trailTitle: c.trailTitle,
              missionSlug: c.missionSlug,
              missionTitle: c.missionTitle,
              moduleTitle: c.moduleTitle,
              weekStart: c.weekStart,
              status: status,
              challengerDoneAt: c.challengerDoneAt,
              opponentDoneAt: c.opponentDoneAt,
              challengerCorrect: c.challengerCorrect,
              challengerTotal: c.challengerTotal,
              opponentCorrect: c.opponentCorrect,
              opponentTotal: c.opponentTotal,
            )
          else
            c,
      ];
      notifyListeners();
      unawaited(AnalyticsService.instance.logEvent(event));
      return true;
    } catch (e) {
      debugPrint('CornerService.$event: $e');
      lastError = CornerCopy.sendFailed;
      notifyListeners();
      return false;
    }
  }

  Future<void> reportMissionComplete({
    required ProgressService progress,
    required String missionSlug,
    required int correct,
    required int total,
  }) async {
    final uid = _uid;
    if (!backend.isActive || uid == null) return;
    CornerChallenge? match;
    for (final c in mine) {
      if (c.status == CornerStatus.active &&
          c.isThisWeek &&
          c.missionSlug == missionSlug &&
          !c.iDone(uid)) {
        match = c;
        break;
      }
    }
    if (match == null) {
      await refresh();
      for (final c in mine) {
        if (c.status == CornerStatus.active &&
            c.isThisWeek &&
            c.missionSlug == missionSlug &&
            !c.iDone(uid)) {
          match = c;
          break;
        }
      }
    }
    if (match == null) return;

    final iAmChallenger = match.iAmChallenger(uid);
    final now = DateTime.now().toIso8601String();
    final theyAlready = match.theyDone(uid);
    final nextStatus =
        theyAlready ? CornerStatus.settled : CornerStatus.active;
    final payload = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
      'status': nextStatus.name,
      if (iAmChallenger) ...{
        'challengerDoneAt': now,
        'challengerCorrect': correct,
        'challengerTotal': total,
      } else ...{
        'opponentDoneAt': now,
        'opponentCorrect': correct,
        'opponentTotal': total,
      },
    };
    try {
      await FirebaseFirestore.instance
          .doc('corners/${match.id}')
          .set(payload, SetOptions(merge: true));
      mine = [
        for (final c in mine)
          if (c.id == match.id)
            CornerChallenge(
              id: c.id,
              challengerId: c.challengerId,
              challengerName: c.challengerName,
              opponentId: c.opponentId,
              opponentName: c.opponentName,
              trailSlug: c.trailSlug,
              trailTitle: c.trailTitle,
              missionSlug: c.missionSlug,
              missionTitle: c.missionTitle,
              moduleTitle: c.moduleTitle,
              weekStart: c.weekStart,
              status: nextStatus,
              challengerDoneAt:
                  iAmChallenger ? now : c.challengerDoneAt,
              opponentDoneAt: iAmChallenger ? c.opponentDoneAt : now,
              challengerCorrect:
                  iAmChallenger ? correct : c.challengerCorrect,
              challengerTotal: iAmChallenger ? total : c.challengerTotal,
              opponentCorrect: iAmChallenger ? c.opponentCorrect : correct,
              opponentTotal: iAmChallenger ? c.opponentTotal : total,
            )
          else
            c,
      ];
      notifyListeners();
      await progress.claimCornerArrivalBonus(match.id);
      unawaited(
        AnalyticsService.instance.logEvent('corner_complete', {
          'mission_slug': missionSlug,
          'settled': theyAlready ? 1 : 0,
        }),
      );
    } catch (e) {
      debugPrint('CornerService.reportMissionComplete: $e');
    }
  }

  static CornerChallenge _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    return CornerChallenge(
      id: doc.id,
      challengerId: (d['challengerId'] as String?) ?? '',
      challengerName: (d['challengerName'] as String?) ?? '',
      opponentId: (d['opponentId'] as String?) ?? '',
      opponentName: (d['opponentName'] as String?) ?? '',
      trailSlug: (d['trailSlug'] as String?) ?? '',
      trailTitle: (d['trailTitle'] as String?) ?? '',
      missionSlug: (d['missionSlug'] as String?) ?? '',
      missionTitle: (d['missionTitle'] as String?) ?? '',
      moduleTitle: (d['moduleTitle'] as String?) ?? '',
      weekStart: (d['weekStart'] as String?) ?? '',
      status: _statusOf(d['status'] as String?),
      challengerDoneAt: _asStamp(d['challengerDoneAt']),
      opponentDoneAt: _asStamp(d['opponentDoneAt']),
      challengerCorrect: (d['challengerCorrect'] as num?)?.toInt(),
      challengerTotal: (d['challengerTotal'] as num?)?.toInt(),
      opponentCorrect: (d['opponentCorrect'] as num?)?.toInt(),
      opponentTotal: (d['opponentTotal'] as num?)?.toInt(),
    );
  }

  static CornerStatus _statusOf(String? raw) {
    for (final s in CornerStatus.values) {
      if (s.name == raw) return s;
    }
    return CornerStatus.pending;
  }

  static String? _asStamp(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Timestamp) return value.toDate().toIso8601String();
    return value.toString();
  }
}
