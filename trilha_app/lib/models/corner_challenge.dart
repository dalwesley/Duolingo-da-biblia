import 'package:intl/intl.dart';

import '../l10n/app_language.dart';
import '../l10n/l10n_global.dart';
import '../utils/trail_progress.dart';
import 'trail.dart';

String cornerWeekStart([DateTime? now]) {
  final d = now ?? DateTime.now();
  final monday = DateTime(
    d.year,
    d.month,
    d.day,
  ).subtract(Duration(days: d.weekday - 1));
  return monday.toIso8601String().substring(0, 10);
}

/// Quem chega (faz a cena combinada até domingo) ganha isto na caravana.
const cornerArrivalBonusSteps = 10;

/// Textos do Desafio — duas pessoas, a mesma cena, até domingo.
///
/// Disputa amigável: cada um que chega ganha os passos; se os dois chegam,
/// os dois ganham. "Perdeu" é não chegar a tempo, não o outro levar o seu.
/// Vocabulário: "desafio", "chegar", "cena", "chamar", "+N passos",
/// nome da pessoa.
class CornerCopy {
  static AppLocalizations get _l => L10n.current;

  // Ações.
  static String get ctaInvite => _l.cornerCtaInvite;
  static String get holdInvite => _l.cornerHoldInvite;
  static String get holdAccept => _l.cornerHoldAccept;
  static String get decline => _l.commonNotNow;
  static String get walk => _l.cornerWalk;
  static String get withdraw => _l.cornerWithdraw;
  static String get withdrawConfirm => _l.cornerWithdrawConfirm;
  static String get withdrawKeep => _l.commonCancel;

  // Rótulos.
  static String get kicker => _l.cornerKicker;
  static String get incomingTitle => _l.cornerIncomingTitle;
  static String get recordChapter => _l.cornerRecordChapter;
  static String get reward => _l.commonPlusSteps(cornerArrivalBonusSteps);
  static String get deadline => _l.cornerDeadline;
  static String get closesToday => _l.cornerClosesToday;
  static String daysLeft(int days) => _l.cornerDaysLeft(days);
  static String get arrivedMark => _l.cornerArrivedMark;
  static String get onTheWay => _l.cornerOnTheWay;
  static String get leftMark => _l.cornerLeftMark;

  // Animação.
  static String get burstSent => _l.cornerBurstSent;
  static String get burstAccepted => _l.cornerBurstAccepted;
  static String get burstTogether => _l.cornerTogether;
  static String get burstLeft => _l.cornerBurstLeft;

  static String acceptedBy(String name) {
    final first = firstName(name);
    if (first.isEmpty) return burstAccepted;
    return _l.cornerAcceptedBy(first);
  }

  // Resultado.
  static String get togetherHeadline => _l.cornerTogether;
  static String get youArrivedHeadline => _l.cornerYouArrived;
  static String get noneHeadline => _l.cornerNoneHeadline;
  static String get togetherLine => _l.cornerTogetherLine;
  static String get noneLine => _l.cornerNoneLine;
  static String get cancelled => _l.cornerCancelled;

  /// Primeiro nome, ou "A outra pessoa" (início de frase).
  static String _who(String name) {
    final first = firstName(name);
    return first.isEmpty ? _l.cornerOtherPerson : first;
  }

  /// Primeiro nome, ou "a outra pessoa" (meio de frase).
  static String _whoLower(String name) {
    final first = firstName(name);
    return first.isEmpty ? _l.cornerOtherPersonLower : first;
  }

  static String theyArrivedHeadline(String name) =>
      _l.cornerTheyArrived(_who(name));

  // Bloqueios e erros.
  static String get needsCloud => _l.cornerNeedsCloud;
  static String get busyWeek => _l.cornerBusyWeek;
  static String get busyAccept => _l.cornerBusyAccept;
  static String get sendFailed => _l.cornerSendFailed;
  static String get actionFailed => _l.cornerActionFailed;
  static String get differentTrail => _l.cornerDifferentTrail;
  static String get differentScene => _l.cornerDifferentScene;
  static String get noCorner => _l.cornerNoCorner;

  static String get sameStretch =>
      _l.cornerSameStretch(cornerArrivalBonusSteps);

  static String inviteTitle(String mission) => _l.cornerInviteTitle(mission);

  static String inviteBody(String name) {
    final first = firstName(name);
    if (first.isEmpty) return _l.cornerInviteBodyAnon(cornerArrivalBonusSteps);
    return _l.cornerInviteBody(first, cornerArrivalBonusSteps);
  }

  static String firstName(String name) {
    final t = name.trim();
    if (t.isEmpty) return '';
    return t.split(RegExp(r'\s+')).first;
  }

  static String incomingFrom(String name) {
    final first = firstName(name);
    if (first.isEmpty) return _l.cornerIncomingFromAnon;
    return _l.cornerIncomingFrom(first);
  }

  static String withPeer(String name) {
    final first = firstName(name);
    if (first.isEmpty) return deadline;
    return _l.cornerWithPeer(first);
  }

  static String waitingOn(String name) {
    final first = firstName(name);
    if (first.isEmpty) return _l.cornerWaitingOnAnon;
    return _l.cornerWaitingOn(first);
  }

  static String waitingArrival(String name) =>
      _l.cornerWaitingArrival(_whoLower(name));

  static String theyAhead(String name) => _l.cornerTheyAhead(_who(name));

  static String theyLeft(String name) => _l.cornerTheyLeft(_who(name));

  static String theyLeftClosed(String name) =>
      _l.cornerTheyLeftClosed(_who(name));

  static String get youLeft => _l.cornerYouLeft;

  static String declinedBy(String name) {
    final first = firstName(name);
    if (first.isEmpty) return _l.cornerDeclinedAnon;
    return _l.cornerDeclinedBy(first);
  }

  // Sair.
  static String get withdrawTitle => _l.cornerWithdrawTitle;

  static String withdrawBody(String name, {required bool pending}) {
    if (pending) return _l.cornerWithdrawPending(_whoLower(name));
    return _l.cornerWithdrawBody(_who(name), cornerArrivalBonusSteps);
  }

  static String recordLine({required int arrived, required int together}) {
    if (arrived == 0) return '';
    final a = _l.cornerRecordArrived(arrived);
    if (together == 0) return a;
    return '$a · ${_l.cornerRecordTogether(together)}';
  }

  // Placar da aba Desafio.
  static String get tallyWon => _l.cornerTallyWon;
  static String get tallyLost => _l.cornerTallyLost;
  static String get tallyChallenge => _l.cornerKicker;
  static String get tallyChallenges => _l.cornerRecordChapter;
  static String get tallyTogether => _l.cornerTallyTogether;
  static String get markLeft => _l.cornerLeftMark;
  static String get closedChapter => _l.cornerClosedChapter;
  static String get boardEmptyTitle => _l.cornerBoardEmptyTitle;
  static String get boardEmptyBody =>
      _l.cornerBoardEmptyBody(cornerArrivalBonusSteps);
  static String get boardOpenCaravan => _l.cornerBoardOpenCaravan;
  static String get boardIdle => _l.cornerBoardIdle;
  static String get stripIdle => _l.cornerStripIdle;

  /// Uma linha da faixa: o desafio aberto, ou o placar se não houver.
  static String stripLine({
    CornerChallenge? live,
    required String uid,
    required int days,
    required int won,
    required int lost,
  }) {
    if (live != null) {
      final first = firstName(live.peerName(uid));
      final name = first.isEmpty ? _l.cornerSomeone : first;
      if (live.status == CornerStatus.pending && live.iAmOpponent(uid)) {
        return _l.cornerStripInvitedYou(name);
      }
      if (live.status == CornerStatus.pending) {
        return _l.cornerStripWaiting(name);
      }
      if (live.iDone(uid)) return _l.cornerYouArrived;
      if (live.theyDone(uid)) return _l.cornerTheyArrived(name);
      if (days <= 1) return closesToday;
      return daysLeft(days);
    }
    if (won == 0 && lost == 0) return stripIdle;
    if (lost == 0) return _l.cornerStripWon(won);
    if (won == 0) return _l.cornerStripLost(lost);
    return '${_l.cornerStripWon(won)} · ${_l.cornerStripLost(lost)}';
  }

  static String get resultLeft => _l.cornerResultLeft(cornerArrivalBonusSteps);

  static String resultWon(String name) =>
      _l.cornerResultWon(_whoLower(name), cornerArrivalBonusSteps);

  static String resultTogether(String name) =>
      _l.cornerResultTogether(_whoLower(name));

  static String resultNone(String name) => _l.cornerResultNone(_whoLower(name));

  static String resultTheyArrived(String name) =>
      _l.cornerResultTheyArrived(_who(name));

  static String resultTheyLeftMissed(String name) =>
      _l.cornerResultTheyLeftMissed(_who(name));
}

class CornerProposal {
  final String trailSlug;
  final String trailTitle;
  final String missionSlug;
  final String missionTitle;
  final String moduleTitle;

  const CornerProposal({
    required this.trailSlug,
    required this.trailTitle,
    required this.missionSlug,
    required this.missionTitle,
    required this.moduleTitle,
  });
}

/// Porta do desafio: mesma trilha em andamento + a mesma próxima cena.
class CornerMatch {
  /// Ignora a exigência de mesma trilha/cena (o limite de 1 desafio vale sempre).
  /// TODO: desligar depois de validar o fluxo no aparelho.
  static const forceOpenForPreview = true;

  static CornerProposal? propose({
    required List<Trail> catalog,
    required List<String> myCompleted,
    required Map<String, List<String>> myClearedModes,
    required List<String> theirCompleted,
    required Map<String, List<String>> theirClearedModes,
  }) {
    final mine = _walkingTrail(catalog, myCompleted, myClearedModes);
    final theirs = _walkingTrail(catalog, theirCompleted, theirClearedModes);
    if (mine == null || theirs == null) return null;
    if (mine.slug != theirs.slug) return null;

    final myNext = TrailProgress.getCurrentMission(mine, myCompleted);
    final theirNext = TrailProgress.getCurrentMission(theirs, theirCompleted);
    if (myNext == null || theirNext == null) return null;
    if (myNext.slug != theirNext.slug) return null;

    String moduleTitle = mine.localizedTitle;
    for (final mod in mine.modules) {
      if (mod.missions.any((m) => m.slug == myNext.slug)) {
        moduleTitle = mod.localizedTitle;
        break;
      }
    }

    return CornerProposal(
      trailSlug: mine.slug,
      trailTitle: mine.localizedTitle,
      missionSlug: myNext.slug,
      missionTitle: myNext.localizedTitle,
      moduleTitle: moduleTitle,
    );
  }

  static String? blockReason({
    required List<Trail> catalog,
    required List<String> myCompleted,
    required Map<String, List<String>> myClearedModes,
    required List<String> theirCompleted,
    required Map<String, List<String>> theirClearedModes,
  }) {
    if (propose(
          catalog: catalog,
          myCompleted: myCompleted,
          myClearedModes: myClearedModes,
          theirCompleted: theirCompleted,
          theirClearedModes: theirClearedModes,
        ) !=
        null) {
      return null;
    }
    final mine = _walkingTrail(catalog, myCompleted, myClearedModes);
    final theirs = _walkingTrail(catalog, theirCompleted, theirClearedModes);
    if (mine == null || theirs == null) return CornerCopy.noCorner;
    if (mine.slug != theirs.slug) return CornerCopy.differentTrail;
    return CornerCopy.differentScene;
  }

  /// Trilha já começada e ainda aberta. Se ninguém começou, cai na ativa da Home.
  static Trail? _walkingTrail(
    List<Trail> catalog,
    List<String> completed,
    Map<String, List<String>> cleared,
  ) {
    Trail? started;
    for (final trail in catalog) {
      if (trail.comingSoon || trail.missionSlugs.isEmpty) continue;
      if (!TrailProgress.isTrailUnlocked(
        trail,
        catalog,
        completed,
        clearedTrailModes: cleared,
      )) {
        continue;
      }
      if (TrailProgress.isTrailCompleted(
        trail,
        completed,
        clearedTrailModes: cleared,
      )) {
        continue;
      }
      if (!trail.missionSlugs.any(completed.contains)) continue;
      started ??= trail;
    }
    if (started != null) return started;
    final fallback = TrailProgress.findActiveTrail(
      catalog,
      completed,
      clearedTrailModes: cleared,
    );
    if (fallback == null) return null;
    if (TrailProgress.isTrailCompleted(
      fallback,
      completed,
      clearedTrailModes: cleared,
    )) {
      return null;
    }
    return fallback;
  }

  /// Cena qualquer para o preview — não usa o gate real.
  static CornerProposal fallbackProposal({
    required List<Trail> catalog,
    required List<String> myCompleted,
    required Map<String, List<String>> myClearedModes,
  }) {
    final mine =
        _walkingTrail(catalog, myCompleted, myClearedModes) ??
        catalog.where((t) => t.missionSlugs.isNotEmpty).firstOrNull;
    if (mine == null) {
      final l = L10n.current;
      return CornerProposal(
        trailSlug: 'preview',
        trailTitle: l.commonTrail,
        missionSlug: 'preview-cena',
        missionTitle: l.commonScene,
        moduleTitle: l.commonModule,
      );
    }
    final next =
        TrailProgress.getCurrentMission(mine, myCompleted) ??
        mine.modules.first.missions.first;
    String moduleTitle = mine.localizedTitle;
    for (final mod in mine.modules) {
      if (mod.missions.any((m) => m.slug == next.slug)) {
        moduleTitle = mod.localizedTitle;
        break;
      }
    }
    return CornerProposal(
      trailSlug: mine.slug,
      trailTitle: mine.localizedTitle,
      missionSlug: next.slug,
      missionTitle: next.localizedTitle,
      moduleTitle: moduleTitle,
    );
  }
}

enum CornerStatus { pending, active, declined, settled }

/// Como o desafio terminou, do meu ponto de vista.
enum CornerOutcome { together, onlyMe, onlyThem, none }

class CornerChallenge {
  final String id;
  final String challengerId;
  final String challengerName;
  final String opponentId;
  final String opponentName;
  final String trailSlug;
  final String trailTitle;
  final String missionSlug;
  final String missionTitle;
  final String moduleTitle;
  final String weekStart;
  final CornerStatus status;
  final String? challengerDoneAt;
  final String? opponentDoneAt;
  final int? challengerCorrect;
  final int? challengerTotal;
  final int? opponentCorrect;
  final int? opponentTotal;

  /// Quem saiu. Convite cancelado → `declined`; desafio aceito segue
  /// `active` para quem ficou.
  final String? withdrawnBy;

  /// Retratos gravados no convite (quem convida) e no aceite (quem aceita).
  final String? challengerPhotoUrl;
  final String? opponentPhotoUrl;

  const CornerChallenge({
    required this.id,
    required this.challengerId,
    required this.challengerName,
    required this.opponentId,
    required this.opponentName,
    required this.trailSlug,
    required this.trailTitle,
    required this.missionSlug,
    required this.missionTitle,
    required this.moduleTitle,
    required this.weekStart,
    required this.status,
    this.challengerDoneAt,
    this.opponentDoneAt,
    this.challengerCorrect,
    this.challengerTotal,
    this.opponentCorrect,
    this.opponentTotal,
    this.withdrawnBy,
    this.challengerPhotoUrl,
    this.opponentPhotoUrl,
  });

  CornerChallenge copyWith({
    CornerStatus? status,
    String? withdrawnBy,
    String? opponentPhotoUrl,
  }) {
    return CornerChallenge(
      id: id,
      challengerId: challengerId,
      challengerName: challengerName,
      opponentId: opponentId,
      opponentName: opponentName,
      trailSlug: trailSlug,
      trailTitle: trailTitle,
      missionSlug: missionSlug,
      missionTitle: missionTitle,
      moduleTitle: moduleTitle,
      weekStart: weekStart,
      status: status ?? this.status,
      challengerDoneAt: challengerDoneAt,
      opponentDoneAt: opponentDoneAt,
      challengerCorrect: challengerCorrect,
      challengerTotal: challengerTotal,
      opponentCorrect: opponentCorrect,
      opponentTotal: opponentTotal,
      withdrawnBy: withdrawnBy ?? this.withdrawnBy,
      challengerPhotoUrl: challengerPhotoUrl,
      opponentPhotoUrl: opponentPhotoUrl ?? this.opponentPhotoUrl,
    );
  }

  bool get isThisWeek => weekStart == cornerWeekStart();

  bool get isWithdrawn => withdrawnBy != null && withdrawnBy!.isNotEmpty;

  /// Convite cancelado antes do aceite (ou recusado).
  bool get isCancelled => status == CornerStatus.declined && !wasAccepted;

  /// Chegou a valer: alguém fez a cena ou alguém saiu depois do aceite.
  bool get wasAccepted =>
      status == CornerStatus.active ||
      status == CornerStatus.settled ||
      _done(challengerDoneAt) ||
      _done(opponentDoneAt);

  bool iLeft(String uid) => withdrawnBy == uid;

  bool theyLeft(String uid) => isWithdrawn && withdrawnBy != uid;

  bool get isOpen =>
      isThisWeek &&
      (status == CornerStatus.pending || status == CornerStatus.active);

  /// A cena combinada desta semana — abre mesmo fora da ordem da trilha.
  bool opensFor(String uid, String missionSlug) {
    return status == CornerStatus.active &&
        isThisWeek &&
        this.missionSlug == missionSlug &&
        !iDone(uid) &&
        !iLeft(uid);
  }

  static bool authorizes(
    String missionSlug,
    String uid,
    Iterable<CornerChallenge> mine,
  ) {
    for (final c in mine) {
      if (c.opensFor(uid, missionSlug)) return true;
    }
    return false;
  }

  bool involves(String uid) => uid == challengerId || uid == opponentId;

  String peerId(String uid) => uid == challengerId ? opponentId : challengerId;

  String peerName(String uid) =>
      uid == challengerId ? opponentName : challengerName;

  String? peerPhoto(String uid) {
    final url = uid == challengerId ? opponentPhotoUrl : challengerPhotoUrl;
    return url == null || url.isEmpty ? null : url;
  }

  bool iAmChallenger(String uid) => uid == challengerId;

  bool iAmOpponent(String uid) => uid == opponentId;

  static bool _done(String? at) => at != null && at.isNotEmpty;

  /// Chegou = fez a cena a tempo.
  bool iDone(String uid) =>
      uid == challengerId ? _done(challengerDoneAt) : _done(opponentDoneAt);

  bool theyDone(String uid) => iDone(peerId(uid));

  bool get bothDone => _done(challengerDoneAt) && _done(opponentDoneAt);

  /// Cada lado já se resolveu (chegou ou saiu) ou o domingo passou.
  bool get isClosed {
    if (status == CornerStatus.settled) return true;
    if (status == CornerStatus.declined) return true;
    if (status == CornerStatus.pending) return false;
    if (!isThisWeek) return true;
    bool resolved(String id, String? at) => _done(at) || withdrawnBy == id;
    return resolved(challengerId, challengerDoneAt) &&
        resolved(opponentId, opponentDoneAt);
  }

  /// Resultado final; null enquanto alguém ainda pode chegar.
  CornerOutcome? outcome(String uid) {
    if (!isClosed || isCancelled) return null;
    final me = iDone(uid);
    final them = theyDone(uid);
    if (me && them) return CornerOutcome.together;
    if (me) return CornerOutcome.onlyMe;
    if (them) return CornerOutcome.onlyThem;
    return CornerOutcome.none;
  }

  /// Ainda dá para sair: convite meu aberto, ou desafio rolando e eu não
  /// cheguei nem saí.
  bool canWithdraw(String uid) {
    if (!isThisWeek || isClosed) return false;
    if (status == CornerStatus.pending) return iAmChallenger(uid);
    return status == CornerStatus.active && !iDone(uid) && !iLeft(uid);
  }

  /// Ocupa a vaga da semana: desafio aberto em que eu não saí, ou convite
  /// meu esperando aceite. Convite recebido e não aceito não ocupa.
  bool occupies(String uid) {
    if (!isThisWeek || isClosed || iLeft(uid)) return false;
    if (status == CornerStatus.active) return true;
    return status == CornerStatus.pending && iAmChallenger(uid);
  }

  String headline(String uid) {
    if (status == CornerStatus.pending) {
      if (iAmOpponent(uid)) return CornerCopy.incomingTitle;
      return CornerCopy.waitingOn(peerName(uid));
    }
    if (isCancelled) return CornerCopy.cancelled;
    switch (outcome(uid)) {
      case CornerOutcome.together:
        return CornerCopy.togetherHeadline;
      case CornerOutcome.onlyMe:
        return CornerCopy.youArrivedHeadline;
      case CornerOutcome.onlyThem:
        return CornerCopy.theyArrivedHeadline(peerName(uid));
      case CornerOutcome.none:
        return CornerCopy.noneHeadline;
      case null:
        return CornerCopy.inviteTitle(missionTitle);
    }
  }

  String subline(String uid) {
    if (status == CornerStatus.pending) {
      if (iAmOpponent(uid)) return CornerCopy.incomingFrom(peerName(uid));
      return CornerCopy.deadline;
    }
    if (isCancelled) {
      if (iLeft(uid)) return CornerCopy.youLeft;
      return iAmChallenger(uid)
          ? CornerCopy.declinedBy(peerName(uid))
          : CornerCopy.theyLeftClosed(peerName(uid));
    }
    final result = outcome(uid);
    if (result != null) {
      if (result == CornerOutcome.together) return CornerCopy.togetherLine;
      if (iLeft(uid)) return CornerCopy.youLeft;
      if (theyLeft(uid)) return CornerCopy.theyLeftClosed(peerName(uid));
      return CornerCopy.noneLine;
    }
    if (iDone(uid)) return CornerCopy.waitingArrival(peerName(uid));
    if (theyLeft(uid)) return CornerCopy.theyLeft(peerName(uid));
    if (theyDone(uid)) return CornerCopy.theyAhead(peerName(uid));
    return CornerCopy.sameStretch;
  }
}

/// Placar curto de chegadas — o que fechou sem eu chegar fica na aba Desafio.
class CornerRecord {
  /// Desafios em que eu cheguei.
  final int arrived;

  /// Dessas, em quantas os dois chegaram.
  final int together;

  const CornerRecord({required this.arrived, required this.together});

  const CornerRecord.empty() : arrived = 0, together = 0;

  bool get isEmpty => arrived == 0;

  String get line =>
      CornerCopy.recordLine(arrived: arrived, together: together);

  String get whisper {
    if (arrived == 0) return '';
    if (together == arrived) return L10n.current.cornerWhisperTogether;
    return L10n.current.cornerWhisperEach;
  }

  static CornerRecord of(Iterable<CornerChallenge> mine, String uid) {
    var arrived = 0;
    var together = 0;
    for (final c in mine) {
      if (!c.iDone(uid)) continue;
      arrived++;
      if (c.bothDone) together++;
    }
    return CornerRecord(arrived: arrived, together: together);
  }
}

/// Como um desafio aceito fechou, do meu ponto de vista.
enum CornerResultMark { won, together, lost, left }

class CornerResult {
  final CornerChallenge challenge;
  final CornerResultMark mark;

  const CornerResult(this.challenge, this.mark);

  String get badge => switch (mark) {
    CornerResultMark.won => CornerCopy.tallyWon,
    CornerResultMark.together => CornerCopy.tallyTogether,
    CornerResultMark.lost => CornerCopy.tallyLost,
    CornerResultMark.left => CornerCopy.markLeft,
  };

  /// Aceito e encerrado, ou eu saí antes do domingo. Convite recusado fica de fora.
  static CornerResult? settle(CornerChallenge c, String uid) {
    if (!c.wasAccepted || c.isCancelled) return null;
    if (c.iLeft(uid) && !c.iDone(uid)) {
      return CornerResult(c, CornerResultMark.left);
    }
    if (!c.isClosed) return null;
    return switch (c.outcome(uid)) {
      CornerOutcome.together => CornerResult(c, CornerResultMark.together),
      CornerOutcome.onlyMe => CornerResult(c, CornerResultMark.won),
      CornerOutcome.onlyThem ||
      CornerOutcome.none => CornerResult(c, CornerResultMark.lost),
      null => null,
    };
  }

  String caption(String uid) {
    final c = challenge;
    final name = c.peerName(uid);
    final rest = switch (mark) {
      CornerResultMark.won => CornerCopy.resultWon(name),
      CornerResultMark.together => CornerCopy.resultTogether(name),
      CornerResultMark.left => CornerCopy.resultLeft,
      CornerResultMark.lost =>
        c.theyLeft(uid)
            ? CornerCopy.resultTheyLeftMissed(name)
            : c.theyDone(uid)
            ? CornerCopy.resultTheyArrived(name)
            : CornerCopy.resultNone(name),
    };
    final when = weekLabel(c.weekStart);
    if (when.isEmpty) return rest;
    return '$when · $rest';
  }

  static String weekLabel(String weekStart) {
    final parts = weekStart.split('-');
    if (parts.length != 3) return '';
    final year = int.tryParse(parts[0]) ?? 2000;
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (month == null || day == null || month < 1 || month > 12) return '';
    return DateFormat(
      'd MMM',
      L10n.current.localeName,
    ).format(DateTime(year, month, day)).replaceAll('.', '');
  }
}

/// Aba Desafio: o que está valendo agora e o que já fechou.
class CornerScoreboard {
  final List<CornerChallenge> open;
  final List<CornerResult> closed;
  final int won;
  final int together;
  final int lost;

  const CornerScoreboard({
    required this.open,
    required this.closed,
    required this.won,
    required this.together,
    required this.lost,
  });

  bool get isEmpty => open.isEmpty && closed.isEmpty;

  static CornerScoreboard of(Iterable<CornerChallenge> mine, String uid) {
    final home = CornerHomePick.of(mine, uid);
    final open = <CornerChallenge>[];
    if (home != null) open.add(home);
    for (final c in mine) {
      if (!c.isOpen || c.iLeft(uid)) continue;
      if (home != null && c.id == home.id) continue;
      open.add(c);
    }

    final closed = <CornerResult>[];
    for (final c in mine) {
      final result = CornerResult.settle(c, uid);
      if (result != null) closed.add(result);
    }
    closed.sort((a, b) {
      final byWeek = b.challenge.weekStart.compareTo(a.challenge.weekStart);
      if (byWeek != 0) return byWeek;
      return b.challenge.id.compareTo(a.challenge.id);
    });

    var won = 0;
    var together = 0;
    var lost = 0;
    for (final r in closed) {
      switch (r.mark) {
        case CornerResultMark.together:
          won++;
          together++;
        case CornerResultMark.won:
          won++;
        case CornerResultMark.lost:
        case CornerResultMark.left:
          lost++;
      }
    }
    return CornerScoreboard(
      open: open,
      closed: closed,
      won: won,
      together: together,
      lost: lost,
    );
  }
}

/// Home só mostra o desafio vivo — o que fechou fica na aba Desafio.
class CornerHomePick {
  static CornerChallenge? of(Iterable<CornerChallenge> mine, String uid) {
    CornerChallenge? incoming;
    CornerChallenge? active;
    CornerChallenge? outgoing;
    for (final c in mine) {
      if (!c.isThisWeek || c.isClosed || c.iLeft(uid)) continue;
      if (c.status == CornerStatus.pending && c.iAmOpponent(uid)) {
        incoming ??= c;
      } else if (c.status == CornerStatus.active) {
        active ??= c;
      } else if (c.status == CornerStatus.pending && c.iAmChallenger(uid)) {
        outgoing ??= c;
      }
    }
    // O desafio valendo vem antes: com ele, convites novos nem podem ser aceitos.
    return active ?? incoming ?? outgoing;
  }
}
