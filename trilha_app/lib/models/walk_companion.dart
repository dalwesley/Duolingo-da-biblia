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

  static const milestones = [3, 7, 14, 30, 60, 100];

  const WalkCompanion({
    required this.code,
    required this.displayName,
    required this.sharedDays,
    this.lastSharedDate,
    required this.iWalkedToday,
    required this.theyWalkedToday,
    required this.awaitingPartner,
    required this.isHost,
  });

  /// Ambos caminharam hoje — a companhia está viva.
  bool get bothWalkedToday => iWalkedToday && theyWalkedToday;

  /// Eu caminhei; ainda espero o outro.
  bool get waitingOnThem => iWalkedToday && !theyWalkedToday && !awaitingPartner;

  /// Eles caminharam; eu ainda não.
  bool get waitingOnMe => !iWalkedToday && theyWalkedToday && !awaitingPartner;

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
    if (waitingOnThem) return 'Você já deu o passo — anime $displayName';
    if (waitingOnMe) return '$displayName já caminhou — sua vez';
    return 'Vamos dar o próximo passo juntos?';
  }
}
