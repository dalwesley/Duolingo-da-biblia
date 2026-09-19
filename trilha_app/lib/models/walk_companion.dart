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

  static const milestones = [3, 7, 14, 30, 60, 100];

  /// Bônus na Caravana quando a dupla fecha os 7 dias da semana (seg–dom).
  /// Uma vez por semana, não empilha por par. Mesmo valor de uma promoção.
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
    if (awaitingPartner) return 'Aguardando alguém entrar com o código';
    if (bothWalkedToday) {
      return sharedDays <= 1
          ? 'Vocês caminharam juntos hoje'
          : '$sharedDays dias caminhando juntos';
    }
    if (waitingOnThem) {
      final delay = delayCopy;
      if (delay != null) return delay.statusLine;
      return 'Você já deu o passo — anime $displayName';
    }
    if (waitingOnMe) return '$displayName já caminhou — sua vez';
    final delay = delayCopy;
    if (delay != null) return delay.statusLine;
    return 'Vamos dar o próximo passo juntos?';
  }

  /// Linha curta sob o status (passos / ausência / semana junta).
  String? get insightLine {
    if (awaitingPartner) return null;
    final parts = <String>[];
    final delay = delayCopy;
    if (delay != null) parts.add(delay.insight);
    if (coveredLeagueWeekTogether()) {
      parts.add(
        'Semana junta · +$weekTogetherBonusSteps na caravana',
      );
    } else if (bothWalkedToday) {
      final n = togetherDaysThisWeek();
      if (n > 0) parts.add('$n/7 nesta semana');
    }
    if (hasWeeklyStepsCompare) {
      final d = weeklyStepsDelta;
      if (d > 0) {
        parts.add('Você $d passos à frente esta semana');
      } else if (d < 0) {
        parts.add('$displayName ${-d} passos à frente esta semana');
      } else if (myWeeklySteps > 0) {
        parts.add('Empatados em $myWeeklySteps passos na semana');
      }
    }
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  /// Copy por faixa de atraso do parceiro (1–3 / 4–6 / 7+).
  CompanionDelayCopy? get delayCopy {
    if (awaitingPartner || theyWalkedToday) return null;
    final away = theyDaysAway;
    if (away == null || away < 1) return null;
    final them = displayName.trim().isEmpty
        ? 'Companheiro'
        : displayName.trim().split(' ').first;
    if (away <= 3) {
      return CompanionDelayCopy(
        daysAway: away,
        tier: CompanionDelayTier.fresh,
        headline: 'Ficando pra trás',
        statusLine: away == 1
            ? 'Você já deu o passo — $them ainda não apareceu'
            : 'Você já deu o passo — $them está ${away}d atrás',
        insight: 'Está ficando pra trás na nossa caminhada',
        shareCardLine: away == 1
            ? '1 dia pra trás na caminhada'
            : '$away dias pra trás na caminhada',
        shareBody:
            '''
Oi $them 👋
Você está ficando pra trás na nossa caminhada no Stway.
Já dei meus passos de hoje e tô te esperando!
Vem?

${InviteDeepLinkService.openAppFooter()}
'''
                .trim(),
      );
    }
    if (away <= 6) {
      return CompanionDelayCopy(
        daysAway: away,
        tier: CompanionDelayTier.dusty,
        headline: 'A trilha empoeirou',
        statusLine: 'Faz $away dias — a trilha sente falta de $them',
        insight: 'A poeira já cobriu o caminho',
        shareCardLine: '$away dias na poeira',
        shareBody:
            '''
Oi $them 👋
Faz $away dias que a gente não caminha juntos no Stway.
A poeira já cobriu a trilha — tô te esperando pra limpar o caminho!
Vem?

${InviteDeepLinkService.openAppFooter()}
'''
                .trim(),
      );
    }
    return CompanionDelayCopy(
      daysAway: away,
      tier: CompanionDelayTier.lost,
      headline: 'Te perdi na multidão',
      statusLine: 'Te perdi na multidão — $away dias sem $them',
      insight: 'Mas dá pra retomar nossa caminhada',
      shareCardLine: '$away dias sumido na multidão',
      shareBody:
          '''
Oi $them 👋
Te perdi na multidão!
Faz $away dias que a gente não caminha juntos no Stway.

Mas dá pra retomar nossa caminhada — já dei meus passos de hoje.
Vem?

${InviteDeepLinkService.openAppFooter()}
'''
              .trim(),
    );
  }

  /// Primeiro nome do parceiro, para copy.
  String get partnerFirstName {
    final n = displayName.trim();
    if (n.isEmpty || n == 'Companheiro' || n == 'Aguardando') {
      return 'Companheiro';
    }
    return n.split(' ').first;
  }

  /// Mensagens curtas do aceno — o parceiro lê no app.
  List<String> get nudgePresets {
    final away = theyDaysAway ?? 0;
    if (away >= 7) {
      return const [
        'Ainda tem lugar ao meu lado',
        'Dá pra retomar — tô aqui',
        'Dei meu passo hoje. Vem?',
      ];
    }
    if (away >= 4) {
      return const [
        'A poeira cobriu o caminho',
        'Tô te esperando pra limpar a trilha',
        'Dei meu passo hoje. Vem?',
      ];
    }
    return const [
      'Tô te esperando na trilha',
      'Já dei meu passo — falta o seu',
      'Vamos caminhar juntos hoje',
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
    final them = displayName.trim().isEmpty
        ? 'você'
        : displayName.trim().split(' ').first;
    return '''
Oi $them 👋
Já dei meus passos de hoje no Stway — tô te esperando!
Vem?

${InviteDeepLinkService.openAppFooter()}
'''
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
