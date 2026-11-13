import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mês de Peregrino+ ganho porque alguém assinou pelo seu convite.
class ReferralReward {
  /// Primeiro nome de quem assinou (pode vir vazio).
  final String name;

  /// O mês ficou guardado (quem convidou já tinha Plus).
  final bool kept;
  final int atMs;

  const ReferralReward({
    required this.name,
    required this.kept,
    required this.atMs,
  });
}

/// Saldo de `referralRewards/{uid}` (functions/referral.js grava; o dono
/// só lê). [banked] = meses guardados para quando o Plus acabar.
class ReferralRewardsService extends ChangeNotifier {
  ReferralRewardsService._();
  static final instance = ReferralRewardsService._();

  int banked = 0;
  int earnedTotal = 0;
  ReferralReward? last;
  String? _uid;

  static String _seenKey(String uid) => 'referral_reward_seen_$uid';

  /// Relê o saldo. Devolve o mês ganho que esta pessoa ainda não viu
  /// (uma vez por mês ganho); null se nada novo.
  Future<ReferralReward?> refresh(String? uid) async {
    if (uid == null || uid.isEmpty) {
      if (_uid != null) {
        _uid = null;
        banked = 0;
        earnedTotal = 0;
        last = null;
        notifyListeners();
      }
      return null;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .doc('referralRewards/$uid')
          .get();
      final data = snap.data() ?? const <String, dynamic>{};
      _uid = uid;
      banked = (data['banked'] as num?)?.toInt() ?? 0;
      earnedTotal = (data['earnedTotal'] as num?)?.toInt() ?? 0;
      final raw = data['lastReward'];
      last = raw is Map && raw['at'] is num
          ? ReferralReward(
              name: (raw['name'] as String?) ?? '',
              kept: raw['kept'] == true,
              atMs: (raw['at'] as num).toInt(),
            )
          : null;
      notifyListeners();
      final reward = last;
      if (reward == null) return null;
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getInt(_seenKey(uid)) ?? 0;
      if (reward.atMs <= seen) return null;
      await prefs.setInt(_seenKey(uid), reward.atMs);
      return reward;
    } catch (e) {
      debugPrint('referralRewards: $e');
      return null;
    }
  }
}
