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
