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
/// Não é duelo: cada um que chega ganha os passos; se os dois chegam,
/// os dois ganham. "Perdeu" é não chegar a tempo, não o outro levar o seu.
/// Vocabulário: "desafio", "chegar", "cena", "convidar", "+N passos",
/// nome da pessoa.
class CornerCopy {
  // Ações.
  static const ctaInvite = 'Convidar';
  static const holdInvite = 'Segure para convidar';
  static const holdAccept = 'Segure para aceitar';
  static const decline = 'Agora não';
  static const walk = 'Fazer a cena';
  static const withdraw = 'Sair do desafio';
  static const withdrawConfirm = 'Sair';
  static const withdrawKeep = 'Continuar';

  // Rótulos.
  static const kicker = 'Desafio';
  static const incomingTitle = 'Convite de desafio';
  static const recordChapter = 'Desafios';
  static const reward = '+$cornerArrivalBonusSteps passos';
  static const deadline = 'Até domingo.';
  static const closesToday = 'Fecha hoje';
  static String daysLeft(int days) => 'Faltam $days dias';
  static const arrivedMark = 'Chegou ✓';
  static const onTheWay = 'A caminho';
  static const leftMark = 'Saiu';

  // Animação.
  static const burstSent = 'Convite enviado';
  static const burstAccepted = 'Desafio aceito';
  static const burstTogether = 'Chegaram juntos';
  static const burstLeft = 'Você saiu do desafio';

  static String acceptedBy(String name) {
    final first = firstName(name);
    if (first.isEmpty) return burstAccepted;
    return '$first aceitou o desafio';
  }

  // Resultado.
  static const togetherHeadline = 'Chegaram juntos';
  static const youArrivedHeadline = 'Você chegou';
  static const noneHeadline = 'Ninguém chegou desta vez';
  static const togetherLine = 'Os dois fizeram a cena a tempo.';
  static const noneLine = 'O desafio fechou no domingo.';
  static const cancelled = 'Desafio cancelado';

  static String theyArrivedHeadline(String name) {
    final first = firstName(name);
    if (first.isEmpty) return 'A outra pessoa chegou';
    return '$first chegou';
  }

  // Bloqueios e erros.
  static const needsCloud = 'Entre com Google para convidar alguém.';
  static const busyWeek = 'Você já tem um desafio nesta semana.';
  static const busyAccept =
      'Você já tem um desafio. Chegue ou saia dele para aceitar.';
  static const sendFailed = 'Não deu para enviar o convite. Tente de novo.';
  static const actionFailed = 'Não deu para concluir agora. Tente de novo.';
  static const differentTrail = 'Vocês não estão na mesma trilha.';
  static const differentScene = 'Vocês não estão na mesma cena.';
  static const noCorner = 'Nenhuma cena em comum para atravessar.';

  static const sameStretch =
      'A mesma cena até domingo. $reward para cada um que chegar.';

  static String inviteTitle(String mission) => 'Desafio: $mission';

  static String inviteBody(String name) {
    final first = firstName(name);
    const stake = '$reward para cada um que chegar.';
    if (first.isEmpty) return 'A mesma cena até domingo.\n$stake';
    return 'Você e $first fazem essa cena até domingo.\n$stake';
  }

  static String firstName(String name) {
    final t = name.trim();
    if (t.isEmpty) return '';
    return t.split(RegExp(r'\s+')).first;
  }

  static String incomingFrom(String name) {
    final first = firstName(name);
    if (first.isEmpty) return 'Alguém te convidou para esta cena.';
    return '$first te convidou para esta cena.';
  }

  static String withPeer(String name) {
    final first = firstName(name);
    if (first.isEmpty) return deadline;
    return 'Com $first · até domingo';
  }

  static String waitingOn(String name) {
    final first = firstName(name);
    if (first.isEmpty) return 'Esperando o aceite.';
    return 'Esperando $first aceitar.';
  }

  static String waitingArrival(String name) {
    final first = firstName(name);
    if (first.isEmpty) return 'Você chegou · esperando a outra pessoa.';
    return 'Você chegou · esperando $first.';
  }

  static String theyAhead(String name) {
    final first = firstName(name);
    if (first.isEmpty) return 'A outra pessoa já chegou. Falta você.';
    return '$first já chegou. Falta você.';
  }

  static String theyLeft(String name) {
    final first = firstName(name);
    if (first.isEmpty) return 'A outra pessoa saiu. Você ainda pode chegar.';
    return '$first saiu. Você ainda pode chegar.';
  }

  static String theyLeftClosed(String name) {
    final first = firstName(name);
    if (first.isEmpty) return 'A outra pessoa saiu do desafio.';
    return '$first saiu do desafio.';
  }

  static const youLeft = 'Você saiu do desafio.';

  static String declinedBy(String name) {
    final first = firstName(name);
    if (first.isEmpty) return 'O convite não foi aceito.';
    return '$first não aceitou desta vez.';
  }

  // Sair.
  static const withdrawTitle = 'Sair do desafio?';

  static String withdrawBody(String name, {required bool pending}) {
    final first = firstName(name);
    final who = first.isEmpty ? 'A outra pessoa' : first;
    if (pending) {
      return first.isEmpty
          ? 'O convite some para a outra pessoa.'
          : 'O convite some para $first.';
    }
    return '$who continua e ainda pode chegar. Você fica sem os $reward.';
  }

  static String recordLine({required int arrived, required int together}) {
    if (arrived == 0) return '';
    final a = arrived == 1 ? '1 completa' : '$arrived completas';
    if (together == 0) return a;
    return '$a · $together ${together == 1 ? 'junto' : 'juntos'}';
  }

  // Placar da aba Desafio.
  static const tallyWon = 'ganhou';
  static const tallyLost = 'perdeu';
  static const tallyChallenge = 'desafio';
  static const tallyChallenges = 'desafios';
  static const tallyTogether = 'Juntos';
  static const markLeft = 'Saiu';
  static const closedChapter = 'Encerrados';
  static const boardEmptyTitle = 'Nenhum desafio ainda';
  static const boardEmptyBody =
      'Na caravana, abra alguém na mesma cena e convide. Quem chega até domingo ganha $reward.';
  static const boardOpenCaravan = 'Ver a caravana';
  static const boardIdle =
      'Nenhum desafio nesta semana. Convide alguém na caravana.';
  static const stripIdle = 'Nenhum nesta semana';

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
      final name = first.isEmpty ? 'Alguém' : first;
      if (live.status == CornerStatus.pending && live.iAmOpponent(uid)) {
        return '$name te convidou';
      }
      if (live.status == CornerStatus.pending) return 'Esperando $name';
      if (live.iDone(uid)) return 'Você chegou';
      if (live.theyDone(uid)) return '$name chegou';
      if (days <= 1) return closesToday;
      return daysLeft(days);
    }
    if (won == 0 && lost == 0) return stripIdle;
    if (lost == 0) return won == 1 ? '1 ganhou' : '$won ganhou';
    if (won == 0) return lost == 1 ? '1 perdeu' : '$lost perdeu';
    return '$won ganhou · $lost perdeu';
  }

  static const resultLeft =
      'Você saiu · sem os +$cornerArrivalBonusSteps passos';

  static String resultWon(String name) =>
      _withPeer(name, '+$cornerArrivalBonusSteps passos');

  static String resultTogether(String name) =>
      _withPeer(name, 'os dois chegaram');

  static String resultNone(String name) => _withPeer(name, 'ninguém chegou');

  static String resultTheyArrived(String name) {
    final first = firstName(name);
    if (first.isEmpty) return 'A outra pessoa chegou · você não chegou';
    return '$first chegou · você não chegou';
  }

  static String resultTheyLeftMissed(String name) {
    final first = firstName(name);
    if (first.isEmpty) return 'A outra pessoa saiu · você não chegou';
    return '$first saiu · você não chegou';
  }

  static String _withPeer(String name, String tail) {
    final first = firstName(name);
    final who = first.isEmpty ? 'a outra pessoa' : first;
    return 'Com $who · $tail';
  }
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

    String moduleTitle = mine.title;
    for (final mod in mine.modules) {
      if (mod.missions.any((m) => m.slug == myNext.slug)) {
        moduleTitle = mod.title;
        break;
      }
    }

    return CornerProposal(
      trailSlug: mine.slug,
      trailTitle: mine.title,
      missionSlug: myNext.slug,
      missionTitle: myNext.title,
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
      return const CornerProposal(
        trailSlug: 'preview',
        trailTitle: 'Trilha',
        missionSlug: 'preview-cena',
        missionTitle: 'Cena',
        moduleTitle: 'Módulo',
      );
    }
    final next =
        TrailProgress.getCurrentMission(mine, myCompleted) ??
        mine.modules.first.missions.first;
    String moduleTitle = mine.title;
    for (final mod in mine.modules) {
      if (mod.missions.any((m) => m.slug == next.slug)) {
        moduleTitle = mod.title;
        break;
      }
    }
    return CornerProposal(
      trailSlug: mine.slug,
      trailTitle: mine.title,
      missionSlug: next.slug,
      missionTitle: next.title,
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
    if (together == arrived) return 'Cenas feitas lado a lado.';
    return 'Cada cena feita conta.';
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

  static const _months = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];

  static String weekLabel(String weekStart) {
    final parts = weekStart.split('-');
    if (parts.length != 3) return '';
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (month == null || day == null || month < 1 || month > 12) return '';
    return '$day ${_months[month - 1]}';
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
