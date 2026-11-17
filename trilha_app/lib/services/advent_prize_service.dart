import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/curated_trails.dart';
import '../data/season_walk_catalog.dart';
import '../models/advent_prize.dart';
import '../models/season_walk.dart';

/// Prêmio do Advento no app (o servidor decide; ver functions/advent.js).
///
/// A cena do dia vira prova assim: ao abrir, cria
/// `seasonWalks/{c}/scenes/{uid}_{dia}` ("start"); ao terminar, marca
/// "done". O servidor confere os horários e grava `proof/{uid}`; o nível e
/// os meses saem em `rewards/{uid}`. Aqui só se lê o que ele confirmou.
class AdventPrizeService extends ChangeNotifier {
  AdventPrizeService._();
  static final instance = AdventPrizeService._();

  final Map<String, AdventPrizeConfig> _configs = {};
  final Map<String, AdventPrizeState> _states = {};
  final Set<String> _configLoaded = {};

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Só conta com login de verdade (o servidor recusa conta anônima).
  String? get _uid {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null || u.isAnonymous) return null;
    return u.uid;
  }

  bool get canEarn => _uid != null;

  AdventPrizeConfig? configFor(String campaignId) =>
      _configs[campaignId] ?? AdventPrizeConfig.forCampaign(campaignId);

  AdventPrizeState stateFor(String campaignId) =>
      _states[campaignId] ?? AdventPrizeState.empty;

  /// Campanha cuja foto do 1º dia ainda vem (dupla/grupo ainda contam), ou
  /// null. Para o convite da aba Juntos.
  AdventPrizeConfig? upcomingRoster([DateTime? now]) {
    final n = (now ?? DateTime.now()).toUtc();
    AdventPrizeConfig? best;
    for (final id in AdventPrizeConfig.defaults.keys) {
      final cfg = configFor(id);
      if (cfg == null || cfg.rosterAt.isBefore(n)) continue;
      if (best == null || cfg.rosterAt.isBefore(best.rosterAt)) best = cfg;
    }
    return best;
  }

  /// Campanha com prêmio ainda aberta agora (ou null).
  SeasonWalkCampaign? _openCampaign([DateTime? now]) {
    final n = now ?? DateTime.now();
    final c = SeasonWalkCatalog.current(DateTime(n.year, n.month, n.day));
    final cfg = configFor(c.id);
    if (cfg == null || !cfg.isOpen(n)) return null;
    return c;
  }

  Future<void> _loadConfig(String id) async {
    if (_configLoaded.contains(id)) return;
    final base = AdventPrizeConfig.forCampaign(id);
    if (base == null) return;
    try {
      final snap = await _db.doc('campaigns/$id').get();
      _configs[id] = base.merge(snap.data());
      _configLoaded.add(id);
    } catch (e) {
      debugPrint('advento: config $e');
    }
  }

  /// Relê prova, prêmio e foto do dia 1.
  Future<void> refresh(String campaignId) async {
    final uid = _uid;
    if (uid == null || AdventPrizeConfig.forCampaign(campaignId) == null) {
      return;
    }
    await _loadConfig(campaignId);
    try {
      final base = 'seasonWalks/$campaignId';
      final results = await Future.wait([
        _db.doc('$base/proof/$uid').get(),
        _db.doc('$base/rewards/$uid').get(),
        _db.doc('$base/roster/$uid').get(),
      ]);
      final proof = results[0].data() ?? const <String, dynamic>{};
      final reward = results[1].data() ?? const <String, dynamic>{};
      final roster = results[2].data() ?? const <String, dynamic>{};
      final days = proof['days'] is Map
          ? (proof['days'] as Map).keys
                .map((k) => int.tryParse('$k'))
                .whereType<int>()
                .toSet()
          : <int>{};
      _states[campaignId] = AdventPrizeState(
        confirmed: days.length,
        provenDays: days,
        completed: proof['completedAtMs'] != null,
        tier: AdventTier.parse(reward['tier']),
        months: (reward['grantedMonths'] as num?)?.toInt() ?? 0,
        inPair: (roster['pairs'] as List?)?.isNotEmpty ?? false,
        inGroup: (roster['groups'] as List?)?.isNotEmpty ?? false,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('advento: leitura $e');
    }
  }

  DocumentReference<Map<String, dynamic>> _scene(
    String campaignId,
    String uid,
    int day,
  ) => _db.doc('seasonWalks/$campaignId/scenes/${uid}_$day');

  /// Dia do Advento que a cena prova hoje. A mesma cena emprestada por uma
  /// trilha curada (A Promessa) tem outro slug: vale pelo da origem.
  int? _dayFor(SeasonWalkCampaign campaign, String missionSlug) {
    final proven = stateFor(campaign.id).provenDays;
    for (final slug in {
      missionSlug,
      ...CuratedTrails.linkedScenes(missionSlug),
    }) {
      final day = AdventPrizeConfig.dayForScene(
        campaign,
        slug,
        DateTime.now(),
        proven: proven,
      );
      if (day != null) return day;
    }
    return null;
  }

  /// Cena aberta: se é um dia do Advento já chegado, marca o começo.
  Future<void> sceneOpened(String missionSlug) async {
    final uid = _uid;
    final campaign = _openCampaign();
    if (uid == null || campaign == null) return;
    final day = _dayFor(campaign, missionSlug);
    if (day == null || stateFor(campaign.id).provenDays.contains(day)) return;
    final ref = _scene(campaign.id, uid, day);
    try {
      final snap = await ref.get();
      if (snap.exists) return; // já começou (vale o começo antigo) ou terminou
      await ref.set({
        'uid': uid,
        'day': day,
        'state': 'start',
        'at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('advento: começo da cena $e');
    }
  }

  /// Cena terminada (não falhada): pede a prova e relê depois.
  Future<void> sceneFinished(String missionSlug) async {
    final uid = _uid;
    final campaign = _openCampaign();
    if (uid == null || campaign == null) return;
    final day = _dayFor(campaign, missionSlug);
    if (day == null) return;
    final ref = _scene(campaign.id, uid, day);
    try {
      // O começo precisa ter chegado ao servidor: começo e fim subindo
      // juntos (cena feita sem internet) seriam recusados como rápidos e a
      // cena apagada. Sem o começo lá, deixa como está; ao refazer com
      // conexão, vale o começo que subir.
      DocumentSnapshot<Map<String, dynamic>> snap;
      try {
        snap = await ref.get(const GetOptions(source: Source.server));
      } catch (_) {
        snap = await ref.get(const GetOptions(source: Source.cache));
      }
      if (snap.data()?['state'] != 'start') return;
      if (snap.metadata.hasPendingWrites) return;
      await ref.update({
        'state': 'done',
        'doneAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('advento: fim da cena $e');
      return;
    }
    // O servidor leva alguns segundos para conferir.
    for (final wait in const [Duration(seconds: 4), Duration(seconds: 12)]) {
      await Future<void>.delayed(wait);
      await refresh(campaign.id);
    }
  }

  static String _seenKey(String campaignId, String uid) =>
      'advent_prize_seen_${campaignId}_$uid';

  /// Meses ainda não celebrados (uma vez por subida de nível).
  Future<int> unseenMonths(String campaignId) async {
    final uid = _uid;
    if (uid == null) return 0;
    final months = stateFor(campaignId).months;
    if (months <= 0) return 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getInt(_seenKey(campaignId, uid)) ?? 0;
      return months > seen ? months : 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> markSeen(String campaignId) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _seenKey(campaignId, uid),
        stateFor(campaignId).months,
      );
    } catch (_) {}
  }
}
