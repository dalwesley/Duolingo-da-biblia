import '../l10n/l10n_global.dart';
import '../services/invite_deep_link_service.dart';

/// Um companheiro de caminhada (accountability 1:1, não ranking).
class WalkCompanion {
  final String code;
  final String displayName;
  final int sharedDays;
  final String? lastSharedDate;
  final bool iWalkedToday;
  final bool theyWalkedToday;
  final bool awaitingPartner;
  final bool isHost;

  /// True quando o convidado já completou a 1ª missão (dispara recompensa ao host).
  final bool guestFirstMissionDone;

  /// Último dia em que o parceiro publicou um passo (`YYYY-MM-DD`).
  final String? theyLastWalkDate;

  /// Último dia em que o parceiro abriu/sincronizou a companhia.
  final String? theyLastSeenDate;

  /// Passos semanais denormalizados no doc da companhia.
  final int myWeeklySteps;
  final int theirWeeklySteps;

  /// Aceno recebido do parceiro (ele te chamou de volta).
  final String? incomingNudgeFromName;
  final String? incomingNudgeMessage;
  final String? incomingNudgeDay;

  /// Já acenei hoje neste par.
  final bool iNudgedToday;

  /// Uid do parceiro, para reconhecer a caminhada dele.
  final String? partnerUid;

  /// Dias (`YYYY-MM-DD`) em que eu caminhei nesta semana.
  final List<String> myWalkDates;

  /// Dias (`YYYY-MM-DD`) em que o parceiro caminhou nesta semana.
  final List<String> theirWalkDates;

  static const milestones = [3, 7, 14, 30, 60, 100];

  /// Os dois ganham na jornada só se a dupla fechar os 7 dias (seg–dom).
  static const weekTogetherBonusSteps = 50;

  const WalkCompanion({
    required this.code,
    required this.displayName,
    required this.sharedDays,
    this.lastSharedDate,
    required this.iWalkedToday,
    required this.theyWalkedToday,
    required this.awaitingPartner,
    required this.isHost,
    this.theyLastWalkDate,
    this.theyLastSeenDate,
    this.myWeeklySteps = 0,
    this.theirWeeklySteps = 0,
    this.guestFirstMissionDone = false,
    this.incomingNudgeFromName,
    this.incomingNudgeMessage,
    this.incomingNudgeDay,
    this.iNudgedToday = false,
    this.partnerUid,
    this.myWalkDates = const [],
    this.theirWalkDates = const [],
  });

  /// Ambos caminharam hoje — a companhia está viva.
  bool get bothWalkedToday => iWalkedToday && theyWalkedToday;

  /// Eu caminhei; ainda espero o outro.
  bool get waitingOnThem =>
      iWalkedToday && !theyWalkedToday && !awaitingPartner;

  /// Eles caminharam; eu ainda não.
  bool get waitingOnMe => !iWalkedToday && theyWalkedToday && !awaitingPartner;

  /// Dias desde o último passo do parceiro (null se nunca caminhou).
  int? get theyDaysSinceWalk => _daysSince(theyLastWalkDate);

  /// Dias desde a última visita/sync do parceiro (null se nunca).
  int? get theyDaysSinceSeen => _daysSince(theyLastSeenDate);

  /// Melhor proxy de “não entra”: seen, senão last walk.
  int? get theyDaysAway {
    final seen = theyDaysSinceSeen;
    final walk = theyDaysSinceWalk;
    if (seen == null && walk == null) return null;
    if (seen == null) return walk;
    if (walk == null) return seen;
    return seen < walk ? seen : walk;
  }

  /// Diferença de passos na semana (positivo = você à frente).
  int get weeklyStepsDelta => myWeeklySteps - theirWeeklySteps;

  bool get hasWeeklyStepsCompare =>
      !awaitingPartner && (myWeeklySteps > 0 || theirWeeklySteps > 0);

  /// Quem caminhou num dia civil: esquerda = eu, direita = o parceiro.
  ///
  /// Dias futuros ficam vazios. A sequência de dias juntos marca os dois,
  /// mesmo quando a lista da semana ainda não foi gravada.
  CompanionDayPresence presenceOn(
    DateTime day, {
    DateTime? now,
    Iterable<String> alsoMine = const [],
  }) {
    if (awaitingPartner) return CompanionDayPresence.empty;
    final clock = now ?? DateTime.now();
    final today = DateTime(clock.year, clock.month, clock.day);
    final date = DateTime(day.year, day.month, day.day);
    if (date.isAfter(today)) return CompanionDayPresence.empty;

    final key = _dateKey(date);
    final mine = {...myWalkDates, ...alsoMine};
    final theirs = {...theirWalkDates};
    final theirLast = theyLastWalkDate;
    if (theirLast != null && theirLast.isNotEmpty) theirs.add(theirLast);
    if (key == _dateKey(today)) {
      if (iWalkedToday) mine.add(key);
      if (theyWalkedToday) theirs.add(key);
    }
    if (_sharedDateKeys().contains(key)) {
      mine.add(key);
      theirs.add(key);
    }
    return CompanionDayPresence(
      me: mine.contains(key),
      them: theirs.contains(key),
    );
  }

  /// Dias desta semana (seg–dom, até hoje) em que a bolinha fecha inteira.
  int bothWalkedThisWeek({
    DateTime? now,
    Iterable<String> alsoMine = const [],
  }) {
    final clock = now ?? DateTime.now();
    final monday = DateTime(
      clock.year,
      clock.month,
      clock.day,
    ).subtract(Duration(days: clock.weekday - 1));
    var n = 0;
    for (var i = 0; i < 7; i++) {
      final mark = presenceOn(
        monday.add(Duration(days: i)),
        now: clock,
        alsoMine: alsoMine,
      );
      if (mark.both) n++;
    }
    return n;
  }

  Set<String> _sharedDateKeys() {
    if (sharedDays <= 0) return const {};
    final last = _parseYmd(lastSharedDate ?? '');
    if (last == null) return const {};
    return {
      for (var i = 0; i < sharedDays; i++)
        _dateKey(last.subtract(Duration(days: i))),
    };
  }

  /// Dias da semana da caravana (seg–dom) em que os dois caminharam juntos.
  int togetherDaysThisWeek([DateTime? now]) {
    if (awaitingPartner || sharedDays <= 0) return 0;
    final d = now ?? DateTime.now();
    final today = _dateKey(d);
    final lastRaw = lastSharedDate ?? (bothWalkedToday ? today : null);
    if (lastRaw == null || lastRaw.isEmpty) return 0;
    final last = _parseYmd(lastRaw);
    if (last == null) return 0;
    final monday = DateTime(
      d.year,
      d.month,
      d.day,
    ).subtract(Duration(days: d.weekday - 1));
    if (last.isBefore(monday)) return 0;
    final spanned = last.difference(monday).inDays + 1;
    final n = sharedDays < spanned ? sharedDays : spanned;
    return n.clamp(0, 7);
  }

  /// Domingo: os dois caminharam e a dupla cobriu seg–dom.
  bool coveredLeagueWeekTogether([DateTime? now]) {
    if (awaitingPartner || !bothWalkedToday) return false;
    final d = now ?? DateTime.now();
    if (d.weekday != DateTime.sunday) return false;
    return togetherDaysThisWeek(d) >= 7;
  }

  /// Próximo marco de dias juntos (3, 7, 14…).
  int get nextMilestone {
    for (final m in milestones) {
      if (sharedDays < m) return m;
    }
    return ((sharedDays ~/ 50) + 1) * 50;
  }

  /// Progresso 0–1 até o próximo marco.
  double get milestoneProgress {
    final target = nextMilestone;
    if (target <= 0) return 0;
    return (sharedDays / target).clamp(0.0, 1.0);
  }

  String get statusLine {
    final l = L10n.current;
    if (awaitingPartner) return l.companionAwaitingCode;
    if (bothWalkedToday) {
      return sharedDays <= 1
          ? l.companionWalkedTogetherToday
          : l.companionDaysTogether(sharedDays);
    }
    if (waitingOnThem) {
      final delay = delayCopy;
      if (delay != null) return delay.statusLine;
      return l.companionWaveFor(displayName);
    }
    if (waitingOnMe) return l.companionYourTurn(displayName);
    final delay = delayCopy;
    if (delay != null) return delay.statusLine;
    return l.companionNextStepTogether;
  }

  /// Linha curta sob o status — presença, não ranking de passos.
  String? get insightLine {
    if (awaitingPartner) return null;
    final delay = delayCopy;
    if (delay != null) return delay.insight;
    if (bothWalkedToday) {
      final n = togetherDaysThisWeek();
      if (n > 0 && n < 7) return L10n.current.companionWeekDays(n);
      if (coveredLeagueWeekTogether()) {
        return L10n.current.companionWeekClosed;
      }
    }
    return null;
  }

  /// Copy por faixa de atraso do parceiro (1–3 / 4–6 / 7+).
  CompanionDelayCopy? get delayCopy {
    if (awaitingPartner || theyWalkedToday) return null;
    final away = theyDaysAway;
    if (away == null || away < 1) return null;
    final l = L10n.current;
    final them = displayName.trim().isEmpty
        ? l.companionFallbackName
        : displayName.trim().split(' ').first;
    final footer = InviteDeepLinkService.openAppFooter();
    if (away <= 3) {
      return CompanionDelayCopy(
        daysAway: away,
        tier: CompanionDelayTier.fresh,
        headline: l.companionDelayFreshHeadline,
        statusLine: away == 1
            ? l.companionPartnerNotYet(them)
            : l.companionPartnerAwayAfterStep(them, away),
        insight: l.companionDelayFreshInsight,
        shareCardLine: l.companionDaysWithoutStudy(away),
        shareBody: '${l.companionShareFresh(them)}\n\n$footer'.trim(),
      );
    }
    if (away <= 6) {
      return CompanionDelayCopy(
        daysAway: away,
        tier: CompanionDelayTier.dusty,
        headline: l.companionDelayDustyHeadline,
        statusLine: l.companionPartnerAway(them, away),
        insight: l.companionDelayDustyInsight,
        shareCardLine: l.companionDaysWithoutStudy(away),
        shareBody: '${l.companionShareDusty(them, away)}\n\n$footer'.trim(),
      );
    }
    return CompanionDelayCopy(
      daysAway: away,
      tier: CompanionDelayTier.lost,
      headline: l.companionDelayLostHeadline,
      statusLine: l.companionPartnerAway(them, away),
      insight: l.companionDelayLostInsight,
      shareCardLine: l.companionDaysWithoutStudy(away),
      shareBody: '${l.companionShareLost(them, away)}\n\n$footer'.trim(),
    );
  }

  /// Primeiro nome do parceiro, para copy.
  String get partnerFirstName {
    final n = displayName.trim();
    // 'Companheiro' / 'Aguardando' são valores gravados, não texto de tela.
    if (n.isEmpty || n == 'Companheiro' || n == 'Aguardando') {
      return L10n.current.companionFallbackName;
    }
    return n.split(' ').first;
  }

  /// Mensagens curtas do aceno — o parceiro lê no app.
  List<String> get nudgePresets {
    final l = L10n.current;
    final away = theyDaysAway ?? 0;
    if (away >= 7) {
      return [
        l.companionDelayLostHeadline,
        l.companionPresetResume,
        l.companionPresetStepCome,
      ];
    }
    if (away >= 4) {
      return [
        l.companionPresetMissed,
        l.companionPresetComeBack,
        l.companionPresetStepCome,
      ];
    }
    return [
      l.companionPresetOnTrail,
      l.companionPresetYoursNext,
      l.companionPresetWalkToday,
    ];
  }

  /// Aceno visível pra mim (ainda não caminhei hoje).
  bool get hasIncomingNudge =>
      !awaitingPartner &&
      !iWalkedToday &&
      (incomingNudgeFromName?.trim().isNotEmpty ?? false);

  /// Texto para compartilhar e chamar atenção (WhatsApp etc.).
  String nudgeShareText() {
    final delay = delayCopy;
    if (delay != null) return delay.shareBody;
    final l = L10n.current;
    final them = displayName.trim().isEmpty
        ? l.companionShareFallbackName
        : displayName.trim().split(' ').first;
    return '${l.companionShareDefault(them)}\n\n'
            '${InviteDeepLinkService.openAppFooter()}'
        .trim();
  }

  /// Parceiro em atraso — card empoeirado (como na home).
  bool get theyAreDusty =>
      !awaitingPartner && !theyWalkedToday && (theyDaysAway ?? 0) >= 1;

  static String _dateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static DateTime? _parseYmd(String yyyyMmDd) {
    final parts = yyyyMmDd.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  static int? _daysSince(String? yyyyMmDd) {
    if (yyyyMmDd == null || yyyyMmDd.isEmpty) return null;
    final last = _parseYmd(yyyyMmDd);
    if (last == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(last).inDays.clamp(0, 999);
  }
}

/// Quem pintou o dia: você, o parceiro, os dois, ou ninguém.
class CompanionDayPresence {
  final bool me;
  final bool them;

  const CompanionDayPresence({required this.me, required this.them});

  static const empty = CompanionDayPresence(me: false, them: false);

  bool get both => me && them;
  int get walkers => (me ? 1 : 0) + (them ? 1 : 0);
}

enum CompanionDelayTier { fresh, dusty, lost }

class CompanionDelayCopy {
  final int daysAway;
  final CompanionDelayTier tier;
  final String headline;
  final String statusLine;
  final String insight;
  final String shareCardLine;
  final String shareBody;

  const CompanionDelayCopy({
    required this.daysAway,
    required this.tier,
    required this.headline,
    required this.statusLine,
    required this.insight,
    required this.shareCardLine,
    required this.shareBody,
  });
}
