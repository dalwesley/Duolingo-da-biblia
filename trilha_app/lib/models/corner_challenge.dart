import '../utils/trail_progress.dart';
import 'trail.dart';

String cornerWeekStart([DateTime? now]) {
  final d = now ?? DateTime.now();
  final monday = DateTime(d.year, d.month, d.day)
      .subtract(Duration(days: d.weekday - 1));
  return monday.toIso8601String().substring(0, 10);
}

/// Posto do desafio — quem faz a cena combinada ganha isto na caravana.
const cornerArrivalBonusSteps = 10;

/// Textos do desafio — nomes provisórios, trocamos depois.
class CornerCopy {
  static const ctaChallenge = 'Desafiar';
  static const waitingAccept = 'Aguardando aceite';
  static const accept = 'Aceitar';
  static const decline = 'Agora não';
  static const walk = 'Fazer a cena';
  static const deadline = 'Até domingo.';
  static const incomingTitle = 'Você foi desafiado';
  static const kicker = 'Desafio';
  static const winHeadline = 'Vitória de leitura';
  static const lossHeadline = 'Leitura deles à frente';
  static const tieHeadline = 'Empate';
  static const yourReadingLed = 'Sua leitura ficou à frente.';
  static const theirReadingLed = 'A leitura deles ficou à frente.';
  static const tied = 'Vocês leram iguais.';
  static const recordChapter = 'Desafios';
  static const needsCloud = 'Entre com Google para chamar alguém.';
  static const busyWeek = 'Você já tem uma esquina nesta semana.';
  static const sendFailed = 'Não deu para chamar agora.';
  static const sameStretch =
      'A mesma cena até domingo. +$cornerArrivalBonusSteps na caravana.';
  static const differentTrail = 'Não estão na mesma trilha.';
  static const differentScene = 'Não estão na mesma cena.';
  static const noCorner = 'Não há esquina aberta.';

  static String inviteTitle(String mission) => 'Desafiar: $mission';

  static String challengeTitle(String mission) => 'Desafio: $mission';

  static String firstName(String name) {
    final t = name.trim();
    if (t.isEmpty) return '';
    return t.split(RegExp(r'\s+')).first;
  }

  static String incomingFrom(String name) {
    final first = firstName(name);
    if (first.isEmpty) return 'Alguém te chamou para um desafio.';
    return '$first te chamou para um desafio.';
  }

  static String inviteBody(String name) {
    final first = name.trim().split(' ').first;
    final stake = '+$cornerArrivalBonusSteps na caravana se você fizer.';
    if (first.isEmpty) return 'Fazer essa cena até domingo.\n$stake';
    return '$first faz essa cena com você até domingo.\n$stake';
  }

  static String youDid(String mission) => 'Você fez $mission.';

  static String theyDid(String mission) => 'Eles fizeram $mission.';

  static String closedHeadline(int? sign) {
    if (sign == 1) return winHeadline;
    if (sign == -1) return lossHeadline;
    return tieHeadline;
  }

  static String recordLine({
    required int wins,
    required int ties,
    required int losses,
  }) {
    final closed = wins + ties + losses;
    if (closed == 0) return '';
    if (closed == 1) {
      if (wins == 1) return '1 vitória';
      if (ties == 1) return '1 empate';
      return '1 desafio fechado';
    }
    final parts = <String>[];
    if (wins > 0) parts.add('$wins ${wins == 1 ? 'vitória' : 'vitórias'}');
    if (ties > 0) parts.add('$ties ${ties == 1 ? 'empate' : 'empates'}');
    if (parts.isEmpty) return '$closed desafios fechados';
    return parts.join(' · ');
  }

  static String theyOnStretch(String name) => '$name no mesmo trecho.';

  static String stayedThisSide(String mission) => '$mission ficou neste lado.';

  static String incoming(String name, String mission) => incomingTitle;

  static String waitingOn(String name) {
    final first = firstName(name);
    if (first.isEmpty) return 'Esperando o aceite.';
    return 'Esperando $first aceitar.';
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
    final mine = _walkingTrail(catalog, myCompleted, myClearedModes) ??
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
    final next = TrailProgress.getCurrentMission(mine, myCompleted) ??
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
  });

  bool get isThisWeek => weekStart == cornerWeekStart();

  bool get isOpen =>
      isThisWeek &&
      (status == CornerStatus.pending || status == CornerStatus.active);

  /// A cena combinada desta semana — abre mesmo fora da ordem da trilha.
  bool opensFor(String uid, String missionSlug) {
    return status == CornerStatus.active &&
        isThisWeek &&
        this.missionSlug == missionSlug &&
        !iDone(uid);
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

  String peerId(String uid) =>
      uid == challengerId ? opponentId : challengerId;

  String peerName(String uid) =>
      uid == challengerId ? opponentName : challengerName;

  bool iAmChallenger(String uid) => uid == challengerId;

  bool iAmOpponent(String uid) => uid == opponentId;

  bool iDone(String uid) => uid == challengerId
      ? (challengerDoneAt != null && challengerDoneAt!.isNotEmpty)
      : (opponentDoneAt != null && opponentDoneAt!.isNotEmpty);

  bool theyDone(String uid) => iDone(peerId(uid));

  bool get bothDone =>
      challengerDoneAt != null &&
      challengerDoneAt!.isNotEmpty &&
      opponentDoneAt != null &&
      opponentDoneAt!.isNotEmpty;

  double? _ratio(int? correct, int? total) {
    if (correct == null || total == null || total <= 0) return null;
    return correct / total;
  }

  double? myRatio(String uid) => uid == challengerId
      ? _ratio(challengerCorrect, challengerTotal)
      : _ratio(opponentCorrect, opponentTotal);

  double? theirRatio(String uid) => myRatio(peerId(uid));

  /// 1 eu, -1 eles, 0 empate, null ainda não dá para decidir.
  int? scoreSign(String uid) {
    if (!bothDone) return null;
    final mine = myRatio(uid);
    final theirs = theirRatio(uid);
    if (mine == null && theirs == null) return 0;
    if (mine == null) return -1;
    if (theirs == null) return 1;
    if (mine > theirs) return 1;
    if (mine < theirs) return -1;
    return 0;
  }

  String headline(String uid) {
    if (status == CornerStatus.pending) {
      if (iAmOpponent(uid)) {
        return CornerCopy.incoming(peerName(uid), missionTitle);
      }
      return CornerCopy.waitingOn(peerName(uid));
    }
    if (status == CornerStatus.declined) {
      return CornerCopy.stayedThisSide(missionTitle);
    }
    if (!isThisWeek && !bothDone) {
      if (iDone(uid) && !theyDone(uid)) {
        return CornerCopy.stayedThisSide(missionTitle);
      }
      if (!iDone(uid) && theyDone(uid)) {
        return CornerCopy.theyDid(missionTitle);
      }
      return CornerCopy.stayedThisSide(missionTitle);
    }
    if (bothDone || status == CornerStatus.settled) {
      return CornerCopy.closedHeadline(scoreSign(uid));
    }
    if (iDone(uid) && !theyDone(uid)) {
      return CornerCopy.youDid(missionTitle);
    }
    if (!iDone(uid) && theyDone(uid)) {
      return CornerCopy.theyDid(missionTitle);
    }
    return CornerCopy.challengeTitle(missionTitle);
  }

  String subline(String uid) {
    if (status == CornerStatus.pending) {
      if (iAmOpponent(uid)) return CornerCopy.incomingFrom(peerName(uid));
      return CornerCopy.deadline;
    }
    if (bothDone || status == CornerStatus.settled) {
      final sign = scoreSign(uid);
      if (sign == 1) return CornerCopy.yourReadingLed;
      if (sign == -1) return CornerCopy.theirReadingLed;
      if (sign == 0) return CornerCopy.tied;
      return CornerCopy.theyOnStretch(peerName(uid));
    }
    if (iDone(uid) && !theyDone(uid)) {
      return CornerCopy.theyOnStretch(peerName(uid));
    }
    if (!iDone(uid) && theyDone(uid)) {
      return CornerCopy.deadline;
    }
    return CornerCopy.sameStretch;
  }

  bool get isClosed => bothDone || status == CornerStatus.settled;
}

/// Placar de leitura — vitórias e empates, sem placar de derrota.
class CornerRecord {
  final int wins;
  final int ties;
  final int losses;

  const CornerRecord({
    required this.wins,
    required this.ties,
    required this.losses,
  });

  const CornerRecord.empty()
      : wins = 0,
        ties = 0,
        losses = 0;

  int get closed => wins + ties + losses;

  bool get isEmpty => closed == 0;

  String get line => CornerCopy.recordLine(
        wins: wins,
        ties: ties,
        losses: losses,
      );

  String get whisper {
    if (closed == 0) return '';
    if (closed == 1) {
      if (wins == 1) return CornerCopy.yourReadingLed;
      if (ties == 1) return CornerCopy.tied;
      return CornerCopy.theirReadingLed;
    }
    return 'Cenas lidas lado a lado.';
  }

  static CornerRecord of(Iterable<CornerChallenge> mine, String uid) {
    var wins = 0;
    var ties = 0;
    var losses = 0;
    for (final c in mine) {
      if (!c.isClosed) continue;
      final sign = c.scoreSign(uid);
      if (sign == 1) {
        wins++;
      } else if (sign == -1) {
        losses++;
      } else {
        ties++;
      }
    }
    return CornerRecord(wins: wins, ties: ties, losses: losses);
  }
}

/// Home só mostra desafio vivo — fechado vai para o perfil.
class CornerHomePick {
  static CornerChallenge? of(Iterable<CornerChallenge> mine, String uid) {
    CornerChallenge? incoming;
    CornerChallenge? active;
    CornerChallenge? outgoing;
    for (final c in mine) {
      if (!c.isThisWeek) continue;
      if (c.isClosed) continue;
      if (c.status == CornerStatus.pending && c.iAmOpponent(uid)) {
        incoming ??= c;
      } else if (c.status == CornerStatus.active && !c.bothDone) {
        active ??= c;
      } else if (c.status == CornerStatus.pending && c.iAmChallenger(uid)) {
        outgoing ??= c;
      }
    }
    return incoming ?? active ?? outgoing;
  }
}
