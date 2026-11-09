import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/l10n_global.dart';
import '../models/companion_invite.dart';
import '../models/walk_companion.dart';
import 'backend_service.dart';
import 'moderation_service.dart';
import 'progress_service.dart';
import 'subscription_service.dart';

/// Resultado do sync de presença — referral e/ou bônus da semana junta.
class CompanionSyncResult {
  final List<String> referralCodes;
  final bool weekTogetherBonusGranted;

  const CompanionSyncResult({
    this.referralCodes = const [],
    this.weekTogetherBonusGranted = false,
  });

  bool get hasFeedback => referralCodes.isNotEmpty || weekTogetherBonusGranted;
}

/// Companhia — uma dupla de caminhada (friend streak de passos).
/// Local + sync Firebase quando autenticado.
class CompanionService extends ChangeNotifier {
  static const _keyCodes = 'companionCodes';

  /// Uma dupla só. Extra de instalações antigas continua visível até sair.
  static const maxCompanions = 1;

  final BackendService backend;
  final SubscriptionService? subscription;

  List<WalkCompanion> companions = const [];
  bool loading = false;
  String? lastError;
  bool _loaded = false;
  bool _cloudSynced = false;

  CompanionService(this.backend, [this.subscription]) {
    subscription?.addListener(_onSubscriptionChanged);
    ModerationService.instance.addListener(notifyListeners);
  }

  void _onSubscriptionChanged() => notifyListeners();

  bool get isLoaded => _loaded;

  /// Primeiro aceno pendente — a Home usa para o card e as 👋.
  WalkCompanion? get incomingNudge {
    for (final c in companions) {
      if (c.hasIncomingNudge &&
          !ModerationService.instance.isBlocked(c.partnerUid)) {
        return c;
      }
    }
    return null;
  }

  bool get canAdd => companions.length < maxCompanions;

  // ── Convite direto (chamar alguém da Caravana pelo nome) ──────────────

  /// Convites em que o peregrino é uma das pontas — ao vivo.
  List<CompanionInvite> invites = const [];
  StreamSubscription<List<CompanionInvite>>? _inviteSub;
  String? _inviteUid;

  /// Convites recebidos ainda abertos (sem os de quem foi bloqueado).
  List<CompanionInvite> get incomingInvites {
    final me = backend.uid;
    return [
      for (final i in invites)
        if (i.isPending &&
            i.toUid == me &&
            !ModerationService.instance.isBlocked(i.fromUid))
          i,
    ];
  }

  /// Quem foi chamado para o convite aberto [code] (null = ninguém).
  CompanionInvite? outgoingFor(String code) {
    final me = backend.uid;
    for (final i in invites) {
      if (i.code == code && i.fromUid == me && i.isPending) return i;
    }
    return null;
  }

  /// Ouve os convites em tempo real. Pode ser chamado no build: só
  /// notifica quando a lista muda.
  void ensureInviteListener() {
    final uid = backend.uid;
    if (!backend.isActive || uid == null) {
      _inviteSub?.cancel();
      _inviteSub = null;
      _inviteUid = null;
      if (invites.isNotEmpty) {
        invites = const [];
        scheduleMicrotask(notifyListeners);
      }
      return;
    }
    if (_inviteUid == uid && _inviteSub != null) return;
    _inviteUid = uid;
    _inviteSub?.cancel();
    _inviteSub = backend.watchCompanionInvites().listen(
      (list) {
        invites = list;
        _closeStaleOutgoing();
        notifyListeners();
      },
      onError: (Object e) {
        // Stream do Firestore morre no erro (ex.: PERMISSION_DENIED antes
        // das regras subirem). Solta a assinatura para o próximo
        // ensureInviteListener (retorno ao app, troca de sessão) reabrir.
        debugPrint('Convites da companhia: $e');
        _inviteSub?.cancel();
        _inviteSub = null;
        _inviteUid = null;
      },
    );
  }

  /// Alguém entrou pelo código (QR/link) enquanto outra pessoa estava
  /// chamada: o convite direto dela deixa de valer.
  void _closeStaleOutgoing() {
    final me = backend.uid;
    for (final i in invites) {
      if (!i.isPending || i.fromUid != me) continue;
      final c = companions.where((c) => c.code == i.code).firstOrNull;
      if (c != null && !c.awaitingPartner && c.partnerUid != i.toUid) {
        backend.setCompanionInviteStatus(
          i.code,
          CompanionInviteStatus.cancelled,
        );
      }
    }
  }

  /// Chama [toUid] para o convite aberto [code]. Uma vaga só: quem estava
  /// chamado antes deixa de estar.
  Future<bool> inviteDirect({
    required String code,
    required String toUid,
    required String toName,
    required ProgressService progress,
  }) async {
    lastError = null;
    if (!backend.isActive) {
      lastError = L10n.current.companionErrorSignInCreate;
      notifyListeners();
      return false;
    }
    final ok = await backend.sendCompanionInvite(
      code: code,
      fromName: progress.publicUserName,
      toUid: toUid,
      toName: toName,
    );
    if (!ok) {
      lastError = L10n.current.groupInviteSendFailed;
      notifyListeners();
    }
    return ok;
  }

  Future<bool> cancelDirect(String code) =>
      backend.setCompanionInviteStatus(code, CompanionInviteStatus.cancelled);

  /// Aceita o convite recebido: sai do próprio convite aberto (se houver,
  /// sem ninguém dentro) e entra no código de quem chamou.
  Future<bool> acceptInvite(
    CompanionInvite invite,
    ProgressService progress,
  ) async {
    lastError = null;
    final ownOpen = [
      for (final c in companions)
        if (c.awaitingPartner) c.code,
    ];
    if (companions.any((c) => !c.awaitingPartner)) {
      lastError = L10n.current.companionErrorAlreadyHave;
      notifyListeners();
      return false;
    }
    for (final code in ownOpen) {
      await leave(code, progress: progress);
    }
    final ok = await joinWithCode(invite.code, progress);
    if (!ok) {
      // Vaga já ocupada ou convite desfeito: some da lista de quem recebeu.
      await backend.setCompanionInviteStatus(
        invite.code,
        CompanionInviteStatus.declined,
      );
      lastError = L10n.current.companionInviteGone;
      notifyListeners();
      return false;
    }
    await backend.setCompanionInviteStatus(
      invite.code,
      CompanionInviteStatus.accepted,
    );
    return true;
  }

  Future<bool> declineInvite(CompanionInvite invite) => backend
      .setCompanionInviteStatus(invite.code, CompanionInviteStatus.declined);
  bool get cloudSynced => _cloudSynced;

  void markCloudUnsynced() {
    _cloudSynced = false;
  }

  Future<void> init() async {
    await refresh();
    _loaded = true;
    notifyListeners();
  }

  Future<List<String>> _loadCodes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyCodes) ?? const [];
  }

  Future<void> _saveCodes(
    List<String> codes, {
    ProgressService? progress,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCodes, codes);
    if (progress != null) {
      await progress.setSyncedCompanionCodes(codes);
    }
  }

  /// Une códigos da nuvem com o aparelho (troca de device).
  Future<void> applyCloudCodes(
    List<String> cloudCodes,
    ProgressService progress,
  ) async {
    final local = await _loadCodes();
    final merged = <String>{
      ...local,
      for (final c in cloudCodes)
        if (c.trim().isNotEmpty) c.trim().toUpperCase(),
    }.toList();
    await _saveCodes(merged, progress: progress);
    await refresh();
  }

  Future<void> refresh() async {
    final codes = await _loadCodes();
    if (codes.isEmpty) {
      companions = const [];
      _cloudSynced = backend.isActive;
      notifyListeners();
      return;
    }
    if (!backend.isActive) {
      companions = [for (final c in codes) _placeholder(c)];
      _cloudSynced = false;
      notifyListeners();
      return;
    }
    loading = true;
    lastError = null;
    notifyListeners();
    final out = <WalkCompanion>[];
    final valid = <String>[];
    var failed = false;
    for (final code in codes) {
      try {
        final c = await backend.fetchCompanion(code);
        if (c == null) continue;
        out.add(c);
      } catch (_) {
        // Rede caiu: mantém o código e o último retrato da dupla.
        failed = true;
        out.add(
          companions.where((c) => c.code == code).firstOrNull ??
              _placeholder(code),
        );
      }
      valid.add(code);
    }
    if (valid.length != codes.length) await _saveCodes(valid);
    companions = out;
    loading = false;
    _cloudSynced = !failed;
    if (failed) lastError = L10n.current.companionErrorLoad;
    notifyListeners();
  }

  static WalkCompanion _placeholder(String code) => WalkCompanion(
    code: code,
    displayName: 'Companheiro',
    sharedDays: 0,
    iWalkedToday: false,
    theyWalkedToday: false,
    awaitingPartner: true,
    isHost: true,
  );

  /// [withTrailGift]: quem chama tem o Peregrino+ — o convite leva o passe
  /// de trilha do mês, aberto (quem aceitar escolhe a trilha).
  Future<WalkCompanion?> createInvite(
    ProgressService progress, {
    bool withTrailGift = false,
  }) async {
    lastError = null;
    if (!canAdd) {
      lastError = L10n.current.companionErrorAlreadyHave;
      notifyListeners();
      return null;
    }
    if (!backend.isActive) {
      lastError = L10n.current.companionErrorSignInCreate;
      notifyListeners();
      return null;
    }
    loading = true;
    notifyListeners();
    final created = await backend.createCompanionInvite(
      userName: progress.publicUserName,
    );
    loading = false;
    if (created == null) {
      lastError = L10n.current.companionErrorCreateInvite;
      notifyListeners();
      return null;
    }
    if (withTrailGift) {
      await backend.attachOpenTrailGift(
        created.code,
        fromName: progress.publicUserName,
      );
    }
    final codes = [...await _loadCodes(), created.code];
    await _saveCodes(codes, progress: progress);
    await refresh();
    for (final c in companions) {
      if (c.code == created.code) return c;
    }
    return created;
  }

  Future<bool> joinWithCode(String rawCode, ProgressService progress) async {
    lastError = null;
    if (!canAdd) {
      lastError = L10n.current.companionErrorAlreadyHave;
      notifyListeners();
      return false;
    }
    if (!backend.isActive) {
      lastError = L10n.current.companionErrorSignInJoin;
      notifyListeners();
      return false;
    }
    loading = true;
    notifyListeners();
    final joined = await backend.joinCompanion(
      code: rawCode,
      userName: progress.publicUserName,
      hadMissionsAtJoin: progress.completedMissions.isNotEmpty,
    );
    loading = false;
    if (joined == null) {
      lastError = L10n.current.companionErrorInvalidCode;
      notifyListeners();
      return false;
    }
    final codes = await _loadCodes();
    if (!codes.contains(joined.code)) {
      await _saveCodes([...codes, joined.code], progress: progress);
    }
    await refresh();
    return true;
  }

  /// Publica presença (visto + passos semanais) e, se caminhou hoje, o passo.
  /// Concede referral (1ª missão do convidado) e o bônus da semana junta.
  Future<CompanionSyncResult> syncPresence(ProgressService progress) async {
    if (!backend.isActive || companions.isEmpty) {
      return const CompanionSyncResult();
    }
    final codes = companions.map((c) => c.code).toList();
    await backend.syncCompanionPresence(
      codes: codes,
      userName: progress.publicUserName,
      weeklySteps: progress.weeklySteps,
      walkedToday: progress.walkedToday,
      completedFirstMission: progress.completedMissions.isNotEmpty,
      walkDates: progress.playDates,
    );
    await refresh();
    final rewarded = <String>[];
    for (final c in companions) {
      if (c.isHost && c.guestFirstMissionDone) {
        final granted = await progress.claimReferralReward(c.code);
        if (granted) rewarded.add(c.code);
      }
    }
    final weekTogether = await progress.claimCompanionWeekTogetherBonus(
      companions,
    );
    return CompanionSyncResult(
      referralCodes: rewarded,
      weekTogetherBonusGranted: weekTogether,
    );
  }

  /// Envia um aceno no app. WhatsApp continua opcional no sheet.
  Future<bool> sendNudge({
    required String code,
    required String fromName,
    required String message,
  }) async {
    lastError = null;
    if (!backend.isActive) {
      lastError = L10n.current.companionErrorSignInWave;
      notifyListeners();
      return false;
    }
    final ok = await backend.sendCompanionNudge(
      code: code,
      fromName: fromName,
      message: message,
    );
    if (!ok) {
      lastError = L10n.current.companionErrorWave;
      notifyListeners();
      return false;
    }
    await refresh();
    return true;
  }

  /// Encerra a dupla para os dois. `false` quando a nuvem não confirmou:
  /// a dupla fica aqui também, para não sumir só de um lado.
  Future<bool> leave(String code, {ProgressService? progress}) async {
    lastError = null;
    // Convite cancelado: quem estava chamado não fica com um aceite morto.
    if (outgoingFor(code) != null) await cancelDirect(code);
    if (backend.isActive && !await backend.leaveCompanion(code)) {
      lastError = L10n.current.companionErrorLeave;
      notifyListeners();
      return false;
    }
    final codes = [
      for (final c in await _loadCodes())
        if (c != code) c,
    ];
    await _saveCodes(codes, progress: progress);
    await refresh();
    return true;
  }

  /// Encerra todas as duplas deste aparelho (e na nuvem, se autenticado).
  /// A que a nuvem não confirmou fica, com aviso.
  Future<void> leaveAll({ProgressService? progress}) async {
    lastError = null;
    final codes = await _loadCodes();
    final kept = <String>[];
    if (backend.isActive) {
      for (final code in codes) {
        if (!await backend.leaveCompanion(code)) kept.add(code);
      }
    }
    await _saveCodes(kept, progress: progress);
    await refresh();
    if (kept.isNotEmpty) {
      lastError = L10n.current.companionErrorLeave;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _inviteSub?.cancel();
    subscription?.removeListener(_onSubscriptionChanged);
    ModerationService.instance.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  String toString() => jsonEncode({
    'companions': companions.length,
    'codes': companions.map((c) => c.code).toList(),
  });
}
