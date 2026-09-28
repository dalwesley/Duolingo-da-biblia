import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/corner_challenge.dart';
import 'analytics_service.dart';
import 'backend_service.dart';
import 'progress_service.dart';

/// Desafio na aba Juntos (sob Companhia) — duas pessoas, a mesma cena, até domingo.
/// Um desafio aberto por pessoa.
class CornerService extends ChangeNotifier {
  CornerService(this.backend);

  final BackendService backend;

  List<CornerChallenge> mine = const [];
  bool loading = false;
  String? lastError;
  bool _cloudSynced = false;
  bool _loaded = false;

  // Chave antiga mantida: quem já viu a animação não vê de novo.
  static const _acceptSeenKey = 'corner_duel_seen_v1';
  final List<CornerChallenge> _acceptReveals = [];

  bool get isLoaded => _loaded;

  /// Travessia que eu propus e o outro aceitou — animação uma vez só.
  CornerChallenge? takeAcceptReveal() =>
      _acceptReveals.isEmpty ? null : _acceptReveals.removeAt(0);
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

  /// Já houve um desafio (aberto ou encerrado). Antes disso o retângulo não aparece.
  bool get hasChallenge {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return false;
    return !CornerScoreboard.of(mine, uid).isEmpty;
  }

  /// O par do retângulo. Só o desafio aberto — quem já fechou não volta para a foto.
  CornerChallenge? get face => homeCard;

  CornerRecord get record {
    final uid = _uid;
    if (uid == null) return const CornerRecord.empty();
    return CornerRecord.of(mine, uid);
  }

  CornerChallenge? withPeer(String uid) {
    for (final c in mine) {
      // Convite cancelado ou travessia de que eu saí liberam convidar de novo.
      if (c.isCancelled && c.isWithdrawn) continue;
      if (_uid != null && c.iLeft(_uid!)) continue;
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

  /// Limite: 1 travessia por pessoa. [except] ignora o próprio convite ao aceitar.
  bool isBusy({String? except}) {
    final uid = _uid;
    if (uid == null) return false;
    for (final c in mine) {
      if (c.id != except && c.occupies(uid)) return true;
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
      mine = [for (final doc in snap.docs) _fromDoc(doc)];
      lastError = null;
      _cloudSynced = true;
      await _collectAcceptReveals(uid);
    } catch (e) {
      debugPrint('CornerService.refresh: $e');
      lastError = null;
    } finally {
      loading = false;
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> _collectAcceptReveals(String uid) async {
    final accepted = [
      for (final c in mine)
        if (c.iAmChallenger(uid) &&
            c.isThisWeek &&
            c.status == CornerStatus.active)
          c,
    ];
    if (accepted.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getStringList(_acceptSeenKey) ?? const <String>[];
    final fresh = [
      for (final c in accepted)
        if (!seen.contains(c.id) && !_acceptReveals.any((r) => r.id == c.id)) c,
    ];
    if (fresh.isEmpty) return;
    _acceptReveals.addAll(fresh);
    final keep = [...seen, for (final c in fresh) c.id];
    await prefs.setStringList(
      _acceptSeenKey,
      keep.length > 40 ? keep.sublist(keep.length - 40) : keep,
    );
  }

  Future<CornerChallenge?> propose({
    required String opponentId,
    required String opponentName,
    required String myName,
    required CornerProposal proposal,
    String? opponentPhotoUrl,
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
    if (isBusy()) {
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
        'challengerPhotoUrl': ?backend.userPhotoUrl,
        'opponentId': opponentId,
        'opponentName': opponentName,
        'opponentPhotoUrl': ?opponentPhotoUrl,
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
        challengerPhotoUrl: backend.userPhotoUrl,
        opponentPhotoUrl: opponentPhotoUrl,
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
    if (isBusy(except: id)) {
      lastError = CornerCopy.busyAccept;
      notifyListeners();
      return false;
    }
    // Quem aceita grava o próprio retrato — o outro lado passa a vê-lo.
    return _setStatus(
      id,
      status: CornerStatus.active,
      event: 'corner_accept',
      extra: {'opponentPhotoUrl': ?backend.userPhotoUrl},
    );
  }

  Future<bool> decline(String id) async {
    return _setStatus(
      id,
      status: CornerStatus.declined,
      event: 'corner_decline',
    );
  }

  /// Quem convidou cancela o convite, ou qualquer um sai da travessia.
  ///
  /// Sair não encerra para o outro: ele segue e ainda pode chegar. Só fecha
  /// se o outro já chegou ou também saiu. Status lido na transação.
  Future<bool> withdraw(String id) async {
    lastError = null;
    final uid = _uid;
    if (!backend.isActive || uid == null) return false;
    final ref = FirebaseFirestore.instance.doc('corners/$id');
    try {
      final next = await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final c = _fromDoc(snap);
        final CornerStatus next;
        if (c.status == CornerStatus.pending) {
          next = CornerStatus.declined;
        } else if (c.status == CornerStatus.active) {
          if (c.theyLeft(uid)) {
            next = CornerStatus.declined;
          } else if (c.theyDone(uid)) {
            next = CornerStatus.settled;
          } else {
            next = CornerStatus.active;
          }
        } else {
          throw StateError('corner $id já fechado');
        }
        tx.set(ref, {
          'status': next.name,
          if (!c.isWithdrawn) 'withdrawnBy': uid,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return next;
      });
      mine = [
        for (final c in mine)
          if (c.id == id)
            c.copyWith(status: next, withdrawnBy: c.isWithdrawn ? null : uid)
          else
            c,
      ];
      notifyListeners();
      unawaited(
        AnalyticsService.instance.logEvent('corner_withdraw', {
          'status': next.name,
        }),
      );
      return true;
    } catch (e) {
      debugPrint('CornerService.withdraw: $e');
      lastError = CornerCopy.actionFailed;
      await refresh();
      return false;
    }
  }

  Future<bool> _setStatus(
    String id, {
    required CornerStatus status,
    required String event,
    Map<String, Object> extra = const {},
  }) async {
    lastError = null;
    final uid = _uid;
    if (!backend.isActive || uid == null) return false;
    try {
      await FirebaseFirestore.instance.doc('corners/$id').set({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
        ...extra,
      }, SetOptions(merge: true));
      mine = [
        for (final c in mine)
          if (c.id == id)
            c.copyWith(
              status: status,
              opponentPhotoUrl: extra['opponentPhotoUrl'] as String?,
            )
          else
            c,
      ];
      notifyListeners();
      unawaited(AnalyticsService.instance.logEvent(event));
      return true;
    } catch (e) {
      debugPrint('CornerService.$event: $e');
      lastError = CornerCopy.actionFailed;
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
      if (c.opensFor(uid, missionSlug)) {
        match = c;
        break;
      }
    }
    if (match == null) {
      await refresh();
      for (final c in mine) {
        if (c.opensFor(uid, missionSlug)) {
          match = c;
          break;
        }
      }
    }
    if (match == null) return;

    final iAmChallenger = match.iAmChallenger(uid);
    final now = DateTime.now().toIso8601String();
    // Fecha quando o outro já se resolveu (chegou ou saiu).
    final theyAlready = match.theyDone(uid) || match.theyLeft(uid);
    final nextStatus = theyAlready ? CornerStatus.settled : CornerStatus.active;
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
              challengerDoneAt: iAmChallenger ? now : c.challengerDoneAt,
              opponentDoneAt: iAmChallenger ? c.opponentDoneAt : now,
              challengerCorrect: iAmChallenger ? correct : c.challengerCorrect,
              challengerTotal: iAmChallenger ? total : c.challengerTotal,
              opponentCorrect: iAmChallenger ? c.opponentCorrect : correct,
              opponentTotal: iAmChallenger ? c.opponentTotal : total,
              challengerPhotoUrl: c.challengerPhotoUrl,
              opponentPhotoUrl: c.opponentPhotoUrl,
              withdrawnBy: c.withdrawnBy,
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
      withdrawnBy: d['withdrawnBy'] as String?,
      challengerPhotoUrl: d['challengerPhotoUrl'] as String?,
      opponentPhotoUrl: d['opponentPhotoUrl'] as String?,
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
