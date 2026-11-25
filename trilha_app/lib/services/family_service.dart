import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'plus_log.dart';

/// Pessoa no plano da família.
class FamilyMember {
  final String uid;
  final String name;
  final DateTime? joinedAt;

  const FamilyMember({required this.uid, required this.name, this.joinedAt});
}

/// `families/{titular}`: escrito só pelo servidor (functions/family.js).
class FamilyPlan {
  final String ownerUid;
  final String ownerName;
  final String productId;

  /// Vagas além do titular (Casal 1, Família 3 → 2, Família 4 → 3).
  final int seats;
  final bool active;
  final DateTime? expiresAt;
  final String inviteCode;

  /// Por ordem de entrada.
  final List<FamilyMember> members;

  const FamilyPlan({
    required this.ownerUid,
    required this.ownerName,
    required this.productId,
    required this.seats,
    required this.active,
    required this.expiresAt,
    required this.inviteCode,
    required this.members,
  });

  int get freeSeats => (seats - members.length).clamp(0, seats);

  /// Pessoas no plano, com o titular.
  int get people => members.length + 1;

  static FamilyPlan? fromDoc(String id, Map<String, dynamic>? data) {
    if (data == null) return null;
    final raw = data['members'];
    final members =
        <FamilyMember>[
          if (raw is Map)
            for (final e in raw.entries)
              if (e.value is Map)
                FamilyMember(
                  uid: '${e.key}',
                  name: ((e.value as Map)['name'] as String?)?.trim() ?? '',
                  joinedAt: switch ((e.value as Map)['joinedAtMs']) {
                    final num ms => DateTime.fromMillisecondsSinceEpoch(
                      ms.toInt(),
                    ),
                    _ => null,
                  },
                ),
        ]..sort(
          (a, b) =>
              (a.joinedAt ?? DateTime(0)).compareTo(b.joinedAt ?? DateTime(0)),
        );
    final expires = data['expiresAtMs'];
    return FamilyPlan(
      ownerUid: (data['ownerUid'] as String?) ?? id,
      ownerName: ((data['ownerName'] as String?) ?? '').trim(),
      productId: (data['productId'] as String?) ?? '',
      seats: (data['seats'] as num?)?.toInt() ?? 0,
      active: data['active'] == true,
      expiresAt: expires is num
          ? DateTime.fromMillisecondsSinceEpoch(expires.toInt())
          : null,
      inviteCode: (data['inviteCode'] as String?) ?? '',
      members: members,
    );
  }
}

/// Resposta da callable `familyAction`.
class FamilyResult {
  final bool ok;

  /// Motivo do servidor: invalid, own, full, other_family, inactive,
  /// has_plus, needs_account, not_member, unavailable, failed.
  final String? reason;
  final Map<String, dynamic> data;

  const FamilyResult.ok([this.data = const {}]) : ok = true, reason = null;
  const FamilyResult.fail(this.reason) : ok = false, data = const {};
}

/// Prévia do convite antes de entrar.
class FamilyInvitePeek {
  final String ownerName;
  final int seats;
  final int taken;
  final bool active;
  final bool own;
  final bool member;

  const FamilyInvitePeek({
    required this.ownerName,
    required this.seats,
    required this.taken,
    required this.active,
    required this.own,
    required this.member,
  });
}

/// Casal e Família: o plano em que esta conta está, como titular ou
/// membro. Lê `families` ao vivo; toda mudança passa pela callable.
class FamilyService extends ChangeNotifier {
  FamilyService._();
  static final instance = FamilyService._();

  String? _uid;
  FamilyPlan? _owned;
  FamilyPlan? _joined;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _ownSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _memberSub;
  bool busy = false;

  /// Plano em que esta conta é titular (comprou Casal ou Família).
  FamilyPlan? get owned => _owned;

  /// Plano de outra pessoa em que esta conta entrou.
  FamilyPlan? get joined => _joined;

  /// O plano a mostrar no perfil: o próprio primeiro.
  FamilyPlan? get plan => _owned ?? _joined;

  bool get isOwner => _owned != null;
  String? get uid => _uid;

  /// Liga à conta. Sem conta (ou sem Firebase nos testes), solta tudo.
  void bind(String? uid) {
    if (uid == _uid) return;
    unawaited(_ownSub?.cancel());
    unawaited(_memberSub?.cancel());
    _ownSub = null;
    _memberSub = null;
    _uid = uid;
    _owned = null;
    _joined = null;
    notifyListeners();
    if (uid == null || uid.isEmpty || Firebase.apps.isEmpty) return;
    final db = FirebaseFirestore.instance;
    _ownSub = db.doc('families/$uid').snapshots().listen((snap) {
      if (_debug) return;
      _owned = snap.exists ? FamilyPlan.fromDoc(snap.id, snap.data()) : null;
      notifyListeners();
    }, onError: (Object e) => PlusLog.log('família', 'titular: $e'));
    _memberSub = db
        .collection('families')
        .where('memberIds', arrayContains: uid)
        .limit(1)
        .snapshots()
        .listen((snap) {
          if (_debug) return;
          final doc = snap.docs.firstOrNull;
          _joined = doc == null ? null : FamilyPlan.fromDoc(doc.id, doc.data());
          notifyListeners();
        }, onError: (Object e) => PlusLog.log('família', 'membro: $e'));
  }

  Future<FamilyResult> _call(Map<String, dynamic> input) async {
    if (_debug) return _debugCall(input);
    busy = true;
    notifyListeners();
    try {
      final res = await FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ).httpsCallable('familyAction').call<Map<String, dynamic>>(input);
      PlusLog.log('família', '${input['action']} ok');
      return FamilyResult.ok(Map<String, dynamic>.from(res.data));
    } on FirebaseFunctionsException catch (e) {
      final details = e.details;
      final reason = details is Map && details['reason'] is String
          ? details['reason'] as String
          : 'failed';
      PlusLog.log('família', '${input['action']} falhou: $reason ${e.code}');
      return FamilyResult.fail(reason);
    } catch (e) {
      PlusLog.log('família', '${input['action']} falhou: $e');
      return const FamilyResult.fail('failed');
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<FamilyInvitePeek?> peek(String code) async {
    final r = await _call({'action': 'peek', 'code': code});
    if (!r.ok) return null;
    final d = r.data;
    return FamilyInvitePeek(
      ownerName: (d['ownerName'] as String?)?.trim() ?? '',
      seats: (d['seats'] as num?)?.toInt() ?? 0,
      taken: (d['taken'] as num?)?.toInt() ?? 0,
      active: d['active'] == true,
      own: d['own'] == true,
      member: d['member'] == true,
    );
  }

  Future<FamilyResult> join(String code) =>
      _call({'action': 'join', 'code': code});

  Future<FamilyResult> leave() => _call({'action': 'leave'});

  Future<FamilyResult> remove(String memberUid) =>
      _call({'action': 'remove', 'uid': memberUid});

  Future<FamilyResult> rotateCode() => _call({'action': 'rotate'});

  // --- Laboratório (só debug): família de mentira, sem servidor. ---

  bool _debug = false;

  /// O laboratório está simulando a família (o Firestore fica ignorado).
  bool get debugActive => _debug;

  /// Código do convite de teste que [_debugCall] reconhece.
  static const debugInviteCode = 'LAB4F';

  static FamilyPlan debugPlan({
    required String ownerUid,
    required String ownerName,
    required String productId,
    bool active = true,
    List<FamilyMember> members = const [],
    String inviteCode = 'LABTIT',
  }) => FamilyPlan(
    ownerUid: ownerUid,
    ownerName: ownerName,
    productId: productId,
    seats: switch (productId) {
      'plus_casal_annual' => 1,
      'plus_familia3_annual' => 2,
      _ => 3,
    },
    active: active,
    expiresAt: DateTime.now().add(const Duration(days: 300)),
    inviteCode: inviteCode,
    members: members,
  );

  /// Troca o plano por um simulado. Os dois nulos = sem família.
  void debugSet({FamilyPlan? owned, FamilyPlan? joined}) {
    if (!kDebugMode) return;
    _debug = true;
    _owned = owned;
    _joined = joined;
    PlusLog.log('laboratório', 'família simulada');
    notifyListeners();
  }

  /// Volta a ler o plano real do Firestore.
  void debugClear() {
    if (!_debug) return;
    _debug = false;
    final uid = _uid;
    _uid = null;
    bind(uid);
  }

  FamilyPlan _debugInvitePlan() => debugPlan(
    ownerUid: 'lab-marta',
    ownerName: 'Marta',
    productId: 'plus_familia4_annual',
    inviteCode: debugInviteCode,
    members: [
      FamilyMember(
        uid: 'lab-pedro',
        name: 'Pedro',
        joinedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ],
  );

  /// Mesmas respostas da callable, feitas aqui.
  Future<FamilyResult> _debugCall(Map<String, dynamic> input) async {
    busy = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final me = _uid ?? 'lab-me';
    final code = '${input['code'] ?? ''}'.trim().toUpperCase();
    FamilyResult result;
    switch (input['action']) {
      case 'peek':
        if (code == _owned?.inviteCode) {
          result = FamilyResult.ok({
            'ownerName': _owned!.ownerName,
            'seats': _owned!.seats,
            'taken': _owned!.members.length,
            'active': _owned!.active,
            'own': true,
          });
        } else if (code == debugInviteCode) {
          final p = _debugInvitePlan();
          result = FamilyResult.ok({
            'ownerName': p.ownerName,
            'seats': p.seats,
            'taken': p.members.length,
            'active': true,
            'member': _joined?.ownerUid == p.ownerUid,
          });
        } else {
          result = const FamilyResult.fail('invalid');
        }
      case 'join':
        if (code != debugInviteCode) {
          result = const FamilyResult.fail('invalid');
        } else if (_owned != null) {
          result = const FamilyResult.fail('has_plus');
        } else if (_joined != null && _joined!.ownerUid != 'lab-marta') {
          result = const FamilyResult.fail('other_family');
        } else {
          final p = _debugInvitePlan();
          _joined = debugPlan(
            ownerUid: p.ownerUid,
            ownerName: p.ownerName,
            productId: p.productId,
            inviteCode: p.inviteCode,
            members: [
              ...p.members,
              FamilyMember(uid: me, name: '', joinedAt: DateTime.now()),
            ],
          );
          result = const FamilyResult.ok();
        }
      case 'leave':
        if (_joined == null) {
          result = const FamilyResult.fail('not_member');
        } else {
          _joined = null;
          result = const FamilyResult.ok();
        }
      case 'remove':
        final owned = _owned;
        if (owned == null) {
          result = const FamilyResult.fail('failed');
        } else {
          _owned = debugPlan(
            ownerUid: owned.ownerUid,
            ownerName: owned.ownerName,
            productId: owned.productId,
            active: owned.active,
            inviteCode: owned.inviteCode,
            members: [
              for (final m in owned.members)
                if (m.uid != input['uid']) m,
            ],
          );
          result = const FamilyResult.ok();
        }
      case 'rotate':
        final owned = _owned;
        if (owned == null) {
          result = const FamilyResult.fail('failed');
        } else {
          _owned = debugPlan(
            ownerUid: owned.ownerUid,
            ownerName: owned.ownerName,
            productId: owned.productId,
            active: owned.active,
            inviteCode: 'LAB${DateTime.now().millisecond}',
            members: owned.members,
          );
          result = const FamilyResult.ok();
        }
      default:
        result = const FamilyResult.fail('failed');
    }
    PlusLog.log(
      'família',
      '${input['action']} (simulado) ${result.ok ? 'ok' : result.reason}',
    );
    busy = false;
    notifyListeners();
    return result;
  }
}
